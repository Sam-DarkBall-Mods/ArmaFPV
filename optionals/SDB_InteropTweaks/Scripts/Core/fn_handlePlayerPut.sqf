/*
	Handle Put event from controlled player.
	Purpose: catch inventory drop workflows and attach autonomy to spawned UAV.
*/

params ["_unit", "_container", "_item"];

if (isNull _unit) exitWith {};

private _unitName = name _unit;
private _containerClass = if (isNull _container) then { "<null>" } else { typeOf _container };

private _useAutonomy = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
if !(_useAutonomy) exitWith {};

private _supportedFn = missionNamespace getVariable ["SDB_it_fnc_getSupportedUavClasses", {}];
private _supported = if (_supportedFn isEqualTo {}) then {
	missionNamespace getVariable ["SDB_it_supportedUavClasses", []]
} else {
	call _supportedFn
};

private _candidateClasses = [];
if (_item in _supported && { isClass (configFile >> "CfgVehicles" >> _item) }) then {
	_candidateClasses pushBackUnique _item;
};

private _resolve = missionNamespace getVariable ["SDB_fnc_ddt_resolveCrocusClass", missionNamespace getVariable ["SDB_it_fnc_resolveCrocusClass", {}]];
if !(_resolve isEqualTo {}) then {
	private _resolved = [_item, side _unit] call _resolve;
	if (_resolved != _item && {_resolved in _supported} && { isClass (configFile >> "CfgVehicles" >> _resolved) }) then {
		_candidateClasses pushBackUnique _resolved;
	};
};

private _assembleTo = "";
private _assembleCfg = configFile >> "CfgVehicles" >> _item >> "assembleInfo" >> "assembleTo";
if (isText _assembleCfg) then {
	_assembleTo = getText _assembleCfg;
};
if (_assembleTo != "" && {_assembleTo in _supported} && { isClass (configFile >> "CfgVehicles" >> _assembleTo) }) then {
	_candidateClasses pushBackUnique _assembleTo;
};

if (_candidateClasses isEqualTo []) exitWith {};

private _originPosATL = if (isNull _container) then {
	getPosATL _unit
} else {
	getPosATL _container
};
private _before = nearestObjects [_originPosATL, _candidateClasses, 12];

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
if !(_log isEqualTo {}) then {
	[
		"Put candidate detected",
		[_unitName, _item, _containerClass, _candidateClasses, _originPosATL, count _before]
	] call _log;
};

[
	{
		_this params ["_unit", "_originPosATL", "_candidateClasses", "_item", "_deadline", "_before"];
		if (time > _deadline) exitWith { true };
		private _near = nearestObjects [_originPosATL, _candidateClasses, 12];
		(_near findIf { alive _x && {!(_x in _before)} }) >= 0
	},
	{
		_this params ["_unit", "_originPosATL", "_candidateClasses", "_item", "_deadline", "_before"];

		private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
		private _near = nearestObjects [_originPosATL, _candidateClasses, 12];
		_near = _near select { alive _x && {!(_x in _before)} };

		if (_near isEqualTo []) exitWith {
			if !(_log isEqualTo {}) then {
				["Put candidate timed out: UAV not found", [name _unit, _item, _candidateClasses]] call _log;
			};
		};

		private _nearSorted = [_near, [], { _originPosATL distance2D _x }, "ASCEND"] call BIS_fnc_sortBy;
		private _spawned = _nearSorted # 0;

		private _starter = missionNamespace getVariable ["SDB_it_fnc_tryStartAutonomy", {}];
		if (_starter isEqualTo {}) exitWith {
			if !(_log isEqualTo {}) then {
				["Put candidate skipped: starter function missing", [name _unit, _item, typeOf _spawned]] call _log;
			};
		};

		private _started = [_spawned, _unit, format ["put:%1", _item], true] call _starter;
		if !(_log isEqualTo {}) then {
			["Put pipeline finished", [name _unit, _item, typeOf _spawned, _started]] call _log;
		};
	},
	[_unit, _originPosATL, _candidateClasses, _item, time + 1.6, _before]
] call CBA_fnc_waitUntilAndExecute;
