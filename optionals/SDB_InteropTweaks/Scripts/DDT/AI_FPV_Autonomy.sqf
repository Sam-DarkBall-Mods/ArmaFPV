/*
	Autonomous FPV loop.
	Purpose: emulate noisy CV+tracking and direct intercept guidance with waypoint-route support.
*/

params ["_drone", "_man"];

if (isNull _drone) exitWith {};
if !(alive _drone) exitWith {};

// ArmaFPV disables UAV AI via disableAI "ALL" during init.
// Re-enable autonomy-critical features before starting guidance logic.
_drone enableAI "ALL";
_drone disableAI "LIGHTS";
_drone setPilotLight false;

if (ddtDebug) then {
	systemChat format ["%1 starting FPV AUTONOMY", _drone];
};

private _alt = 12 + (random 6);
private _takeOff = true;

if (_drone isKindOf "B_SwitchBlade_300") then {
	_alt = 50;
	_takeOff = false;
};
if (_drone isKindOf "B_SwitchBlade_600") then {
	_alt = 50;
	_takeOff = false;
};

_drone setAutonomous true;
_drone flyInHeight _alt;
_drone setVariable ["ddtAlt", _alt, true];

private _fpvAtClasses = ["DRA_UAV_01_B", "DRA_UAV_01_O", "DRA_UAV_01_0", "DRA_UAV_01_I"];

private _fn_flyTo = {
	params ["_vehicle", "_aimPosASL", "_speed"];

	private _from = getPosASLVisual _vehicle;
	if ((_from vectorDistance _aimPosASL) < 0.5) exitWith {};

	private _dirVec = _from vectorFromTo _aimPosASL;
	private _right = (_dirVec vectorCrossProduct [0, 0, 1]) vectorMultiply -1;
	if ((vectorMagnitude _right) < 0.001) then {
		_right = [1, 0, 0];
	};
	_right = vectorNormalized _right;
	private _up = _dirVec vectorCrossProduct _right;

	_vehicle setVectorDirAndUp [_dirVec, _up];
	_vehicle setVelocity (_dirVec vectorMultiply _speed);
};

private _fn_getRouteWaypoint = {
	params ["_vehicle"];

	private _group = group _vehicle;
	if (isNull _group) exitWith {
		[false, [0, 0, 0], -1, 0]
	};

	private _waypointCount = count waypoints _group;
	private _waypointIndex = currentWaypoint _group;
	if (_waypointCount <= 1 || {_waypointIndex <= 0} || {_waypointIndex >= _waypointCount}) exitWith {
		[false, [0, 0, 0], _waypointIndex, _waypointCount]
	};

	private _waypointPosAGL = waypointPosition [_group, _waypointIndex];
	private _waypointPosASL = AGLToASL _waypointPosAGL;
	[true, _waypointPosASL, _waypointIndex, _waypointCount]
};

private _fn_selectTarget = {
	params ["_vehicle", "_currentTarget", "_currentTrackedScore"];

	private _maxRange = missionNamespace getVariable ["sdbAutoMaxRange", 2500];
	private _lockThreshold = missionNamespace getVariable ["sdbAutoLockThreshold", 0.62];
	private _releaseThreshold = missionNamespace getVariable ["sdbAutoReleaseThreshold", 0.45];
	private _hFov = missionNamespace getVariable ["sdbAutoHorizontalFov", 95];
	private _downAngle = missionNamespace getVariable ["sdbAutoDownAngle", 45];

	private _cosHalfFov = cos (_hFov * 0.5);
	private _sinDown = sin _downAngle;
	private _from = getPosASLVisual _vehicle;
	private _fwd = vectorDir _vehicle;

	private _candidates = _vehicle nearEntities [["Man", "LandVehicle", "Air"], _maxRange];
	_candidates = _candidates select {
		alive _x
		&& {_x isNotEqualTo _vehicle}
		&& {!([side _x, side _vehicle] call BIS_fnc_sideIsFriendly)}
	};

	if ((count _candidates) > 24) then {
		_candidates = [_candidates, [], { _vehicle distance2D _x }, "ASCEND"] call BIS_fnc_sortBy;
		_candidates resize 24;
	};

	private _quick = [];
	{
		private _toPos = getPosASLVisual _x;
		private _toVec = _from vectorFromTo _toPos;
		private _dot = _fwd vectorDotProduct _toVec;
		private _isInCone = _dot >= _cosHalfFov;
		private _isInVerticalBand = (_toVec # 2) >= (-_sinDown);
		if (_isInCone && {_isInVerticalBand}) then {
			private _distance = _from vectorDistance _toPos;
			private _distanceScore = 1 - ((_distance / _maxRange) min 1);
			private _quickScore = (_distanceScore * 0.55) + (_dot * 0.45);
			_quick pushBack [_x, _quickScore];
		};
	} forEach _candidates;

	if (_quick isEqualTo []) exitWith {
		private _decayed = (_currentTrackedScore - 0.12) max 0;
		[objNull, 0, _decayed, _releaseThreshold]
	};

	_quick = [_quick, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;
	if ((count _quick) > 6) then { _quick resize 6; };

	private _bestTarget = objNull;
	private _best = 0;

	{
		private _candidate = _x # 0;
		private _quickScore = _x # 1;
		private _toPos = getPosASLVisual _candidate;
		private _hits = lineIntersectsSurfaces [_from, _toPos, _vehicle, _candidate, true, 1, "VIEW", "FIRE"];
		private _clearLOS = _hits isEqualTo [];

		if (_clearLOS) then {
			private _score = _quickScore;
			if !(_candidate isKindOf "Man") then {
				_score = _score + 0.08;
			};
			_score = (_score max 0) min 1;
			if (_score > _best) then {
				_best = _score;
				_bestTarget = _candidate;
			};
		};
	} forEach _quick;

	private _tracked = (_currentTrackedScore * 0.65) + (_best * 0.35);
	if (isNull _bestTarget) then {
		_tracked = (_currentTrackedScore - 0.12) max 0;
	};

	private _selected = _currentTarget;
	if (!isNull _bestTarget && {_best >= _lockThreshold}) then {
		_selected = _bestTarget;
	};

	if (!isNull _selected && {_tracked < _releaseThreshold}) then {
		_selected = objNull;
	};

	[_selected, _best, _tracked, _releaseThreshold]
};

private _fn_stopLoop = {
	params ["_drone", "_man", "_pfhId"];

	[_pfhId] call CBA_fnc_removePerFrameHandler;
	_drone setVariable ["SDB_auto_pfh", -1];

	private _engaged = _drone getVariable ["SDB_auto_engaged", false];
	if (_engaged) exitWith {};
	if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};
	[_drone, _man] spawn DDT_fnc_RTB;
};

private _fn_startLoop = {
	params ["_drone", "_man", "_fpvAtClasses", "_fn_flyTo", "_fn_getRouteWaypoint", "_fn_selectTarget", "_fn_stopLoop"];

	if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};

	private _oldPfh = _drone getVariable ["SDB_auto_pfh", -1];
	if (_oldPfh >= 0) then {
		[_oldPfh] call CBA_fnc_removePerFrameHandler;
	};

	_drone setCaptive false;
	_drone setVariable ["SDB_auto_target", objNull];
	_drone setVariable ["SDB_auto_trackedScore", 0];
	_drone setVariable ["SDB_auto_lastScan", -100];
	_drone setVariable ["SDB_auto_state", "SEARCH"];
	_drone setVariable ["SDB_auto_searchDir", getDir _drone];
	_drone setVariable ["SDB_auto_nextSearchTurn", time + 1];
	_drone setVariable ["SDB_auto_nextGuide", 0];
	_drone setVariable ["SDB_auto_engaged", false];

	private _pfhId = [
		{
			params ["_args", "_pfhId"];
			_args params ["_drone", "_man", "_fpvAtClasses", "_fn_flyTo", "_fn_getRouteWaypoint", "_fn_selectTarget", "_fn_stopLoop"];

			if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {
				[_drone, _man, _pfhId] call _fn_stopLoop;
			};
			if ((fuel _drone) <= 0.01) exitWith {
				[_drone, _man, _pfhId] call _fn_stopLoop;
			};

			private _now = time;
			private _guideTick = missionNamespace getVariable ["sdbAutoGuideTick", 0.05];
			private _nextGuide = _drone getVariable ["SDB_auto_nextGuide", 0];
			if (_now < _nextGuide) exitWith {};
			_drone setVariable ["SDB_auto_nextGuide", _now + _guideTick];

			private _scanInterval = missionNamespace getVariable ["sdbAutoScanInterval", 0.25];
			private _cruiseSpeed = missionNamespace getVariable ["sdbAutoCruiseSpeed", 38];
			private _terminalDistance = missionNamespace getVariable ["sdbAutoTerminalDistance", 10];

			private _target = _drone getVariable ["SDB_auto_target", objNull];
			private _trackedScore = _drone getVariable ["SDB_auto_trackedScore", 0];
			private _lastScan = _drone getVariable ["SDB_auto_lastScan", -100];
			private _state = _drone getVariable ["SDB_auto_state", "SEARCH"];
			private _searchDir = _drone getVariable ["SDB_auto_searchDir", getDir _drone];
			private _nextSearchTurn = _drone getVariable ["SDB_auto_nextSearchTurn", _now + 1];

			if ((_now - _lastScan) >= _scanInterval) then {
				_lastScan = _now;
				private _selection = [_drone, _target, _trackedScore] call _fn_selectTarget;
				_target = _selection # 0;
				_trackedScore = _selection # 2;
				if (isNull _target) then {
					_state = "SEARCH";
				} else {
					_state = "TRACK";
				};
			};

			if (_state == "TRACK" && {!isNull _target} && {alive _target}) then {
				private _from = getPosASLVisual _drone;
				private _toPos = getPosASLVisual _target;
				private _distance = _from vectorDistance _toPos;
				private _leadTime = (_distance / 70) min 1.2;
				if (_target isKindOf "Man") then {
					_leadTime = _leadTime min 0.7;
				};

				private _aimPos = _toPos vectorAdd ((velocity _target) vectorMultiply _leadTime);
				private _speed = linearConversion [8, 300, _distance, _cruiseSpeed * 0.45, _cruiseSpeed, true];
				[_drone, _aimPos, _speed] call _fn_flyTo;

				if (ddtDebug) then {
					private _t = format ["%1 AUTO score:%2 dist:%3", _drone, (round (_trackedScore * 100)), round _distance];
					_t call DDT_fnc_Debug;
				};

				if (_distance <= _terminalDistance) exitWith {
					_drone setVariable ["SDB_auto_engaged", true];
					[_pfhId] call CBA_fnc_removePerFrameHandler;
					_drone setVariable ["SDB_auto_pfh", -1];

					if ([[(typeOf _drone)], _fpvAtClasses] call DDT_fnc_InArray) then {
						[_drone, _target] spawn DDT_fnc_DRAattack;
					} else {
						[_drone, _target] spawn DDT_fnc_GuideToTarget;
					};
				};
			} else {
				private _routeInfo = [_drone] call _fn_getRouteWaypoint;
				private _hasRoute = _routeInfo # 0;

				if (_hasRoute) then {
					_state = "ROUTE";

					private _waypointPosASL = +(_routeInfo # 1);
					private _origin = getPosASLVisual _drone;
					_waypointPosASL set [2, (_origin # 2) max (_waypointPosASL # 2)];

					private _distanceToWaypoint = _origin vectorDistance _waypointPosASL;
					private _routeSpeed = linearConversion [10, 1500, _distanceToWaypoint, _cruiseSpeed * 0.55, _cruiseSpeed * 0.9, true];
					[_drone, _waypointPosASL, _routeSpeed] call _fn_flyTo;

					if (ddtDebug) then {
						private _wpIndex = _routeInfo # 2;
						private _wpCount = _routeInfo # 3;
						private _t = format ["%1 AUTO route wp:%2/%3 dist:%4", _drone, _wpIndex, _wpCount, round _distanceToWaypoint];
						_t call DDT_fnc_Debug;
					};
				} else {
					if (_now >= _nextSearchTurn) then {
						_nextSearchTurn = _now + 1.2 + (random 0.8);
						_searchDir = _searchDir + ((random 30) - 15);
					};

					if (!isNull _man && {alive _man}) then {
						if ((_drone distance2D _man) > ((missionNamespace getVariable ["sdbAutoMaxRange", 2500]) * 0.65)) then {
							_searchDir = _drone getDir _man;
						};
					};

					private _origin = getPosASLVisual _drone;
					private _searchVec = [sin _searchDir, cos _searchDir, 0] vectorMultiply 220;
					private _searchAim = _origin vectorAdd _searchVec;
					_searchAim set [2, (_origin # 2) max 8];
					[_drone, _searchAim, _cruiseSpeed * 0.65] call _fn_flyTo;
				};
			};

			_drone setVariable ["SDB_auto_target", _target];
			_drone setVariable ["SDB_auto_trackedScore", _trackedScore];
			_drone setVariable ["SDB_auto_lastScan", _lastScan];
			_drone setVariable ["SDB_auto_state", _state];
			_drone setVariable ["SDB_auto_searchDir", _searchDir];
			_drone setVariable ["SDB_auto_nextSearchTurn", _nextSearchTurn];
		},
		0,
		[_drone, _man, _fpvAtClasses, _fn_flyTo, _fn_getRouteWaypoint, _fn_selectTarget, _fn_stopLoop]
	] call CBA_fnc_addPerFrameHandler;

	_drone setVariable ["SDB_auto_pfh", _pfhId];
};

if (_takeOff) then {
	[_drone] spawn DDT_fnc_TakeOff;

	[
		{
			params ["_drone", "_man"];
			if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith { true };
			((getPosATL _drone) select 2) > 1
		},
		{
			params ["_drone", "_man", "_fpvAtClasses", "_fn_flyTo", "_fn_getRouteWaypoint", "_fn_selectTarget", "_fn_stopLoop", "_fn_startLoop"];
			if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};
			[_drone, _man, _fpvAtClasses, _fn_flyTo, _fn_getRouteWaypoint, _fn_selectTarget, _fn_stopLoop] call _fn_startLoop;
		},
		[_drone, _man, _fpvAtClasses, _fn_flyTo, _fn_getRouteWaypoint, _fn_selectTarget, _fn_stopLoop, _fn_startLoop]
	] call CBA_fnc_waitUntilAndExecute;
} else {
	[_drone, _man, _fpvAtClasses, _fn_flyTo, _fn_getRouteWaypoint, _fn_selectTarget, _fn_stopLoop] call _fn_startLoop;
};
