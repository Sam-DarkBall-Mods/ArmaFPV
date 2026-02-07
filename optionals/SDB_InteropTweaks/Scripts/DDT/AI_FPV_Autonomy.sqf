/*
	Autonomous FPV loop.
	Purpose: emulate noisy CV+tracking and direct intercept guidance without waypoint steering.
*/

private _drone = _this select 0;
private _man = _this select 1;

if (ddtDebug) then {
	systemChat format ["%1 starting FPV AUTONOMY", _drone];
};

private _droneType = toUpper (typeOf _drone);
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

if (_takeOff) then {
	[_drone] spawn DDT_fnc_TakeOff;
	while {true} do {
		if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};
		if (((getPosATL _drone) select 2) > 1) exitWith {};
		sleep 2;
	};
};
if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};

_drone setCaptive false;

private _target = objNull;
private _bestScore = 0;
private _trackedScore = 0;
private _lastScan = -100;
private _state = "SEARCH";
private _searchDir = getDir _drone;
private _nextSearchTurn = time + 1;
private _engaged = false;

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

private _fn_selectTarget = {
	params ["_vehicle", "_operator", "_currentTarget", "_currentTrackedScore"];

	private _maxRange = missionNamespace getVariable ["sdbAutoMaxRange", 2500];
	private _lockThreshold = missionNamespace getVariable ["sdbAutoLockThreshold", 0.62];
	private _releaseThreshold = missionNamespace getVariable ["sdbAutoReleaseThreshold", 0.45];
	private _noise = missionNamespace getVariable ["sdbAutoNoise", 0.12];
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
		private _score = _quickScore;
		if (!_clearLOS) then {
			_score = _score * 0.35;
		};
		if !(_candidate isKindOf "Man") then {
			_score = _score + 0.08;
		};
		_score = _score + ((random (_noise * 2)) - _noise);
		_score = (_score max 0) min 1;
		if (_score > _best) then {
			_best = _score;
			_bestTarget = _candidate;
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

while {true} do {
	if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};
	if ((fuel _drone) <= 0.01) exitWith {};

	private _now = time;
	private _scanInterval = missionNamespace getVariable ["sdbAutoScanInterval", 0.25];
	private _guideTick = missionNamespace getVariable ["sdbAutoGuideTick", 0.05];
	private _cruiseSpeed = missionNamespace getVariable ["sdbAutoCruiseSpeed", 38];
	private _terminalDistance = missionNamespace getVariable ["sdbAutoTerminalDistance", 10];

	if ((_now - _lastScan) >= _scanInterval) then {
		_lastScan = _now;
		private _selection = [_drone, _man, _target, _trackedScore] call _fn_selectTarget;
		_target = _selection # 0;
		_bestScore = _selection # 1;
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
		if (_target isKindOf "Man") then { _leadTime = _leadTime min 0.7; };

		private _aimPos = _toPos vectorAdd ((velocity _target) vectorMultiply _leadTime);
		private _speed = linearConversion [8, 300, _distance, _cruiseSpeed * 0.45, _cruiseSpeed, true];
		[_drone, _aimPos, _speed] call _fn_flyTo;

		if (ddtDebug) then {
			private _t = format ["%1 AUTO score:%2 dist:%3", _drone, (round (_trackedScore * 100)), round _distance];
			_t call DDT_fnc_Debug;
		};

		if (_distance <= _terminalDistance) exitWith {
			_engaged = true;
			if ([[(typeOf _drone)], _fpvAtClasses] call DDT_fnc_InArray) then {
				[_drone, _target] spawn DDT_fnc_DRAattack;
			} else {
				[_drone, _target] spawn DDT_fnc_GuideToTarget;
			};
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

	sleep _guideTick;
};

if (_engaged) exitWith {};
if !([_drone, _man] call DDT_fnc_DroneGroupAlive) exitWith {};
[_drone, _man] spawn DDT_fnc_RTB;
