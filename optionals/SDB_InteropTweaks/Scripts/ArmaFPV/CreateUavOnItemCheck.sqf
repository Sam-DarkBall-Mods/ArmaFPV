/*
	ArmaFPV create handler wrapper.
	Purpose: keep original spawn flow and attach SDB autonomy when launched from inventory workflow.
*/

params ["_unit", "_container", "_item"];

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
private _unitName = if (isNull _unit) then { "<null>" } else { name _unit };
private _containerClass = if (isNull _container) then { "<null>" } else { typeOf _container };
if !(_log isEqualTo {}) then {
	["ArmaFPV CreateUavOnItemCheck", [_unitName, _item, _containerClass]] call _log;
};

private _original = missionNamespace getVariable ["DB_fnc_fpv_createUavOnItemCheck_original", {}];
if (_original isEqualTo {}) exitWith {};

private _useAutonomy = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
if !(_useAutonomy) exitWith {
	if !(_log isEqualTo {}) then {
		["ArmaFPV wrapper skipped: autonomy disabled", [_unitName, _item]] call _log;
	};
	_this call _original;
};

private _resolve = missionNamespace getVariable ["SDB_fnc_ddt_resolveCrocusClass", missionNamespace getVariable ["SDB_it_fnc_resolveCrocusClass", {}]];
private _expectedClass = "";
if !(_resolve isEqualTo {}) then {
	_expectedClass = [_item, side _unit] call _resolve;
	if (_expectedClass isEqualTo _item) then {
		_expectedClass = "";
	};
};

private _before = [];
if (_expectedClass != "" && {!isNull _container}) then {
	_before = nearestObjects [getPosATL _container, [_expectedClass], 8];
};

if !(_log isEqualTo {}) then {
	["ArmaFPV expected class resolved", [_item, _expectedClass, count _before]] call _log;
};

_this call _original;

if (_expectedClass == "" || {isNull _container}) exitWith {};

private _after = nearestObjects [getPosATL _container, [_expectedClass], 8];
private _spawned = objNull;
{
	if !(_x in _before) exitWith {
		_spawned = _x;
	};
} forEach _after;

if (isNull _spawned) exitWith {
	if !(_log isEqualTo {}) then {
		["ArmaFPV wrapper: UAV not found after spawn", [_unitName, _item, _expectedClass]] call _log;
	};
};

private _starter = missionNamespace getVariable ["SDB_it_fnc_tryStartAutonomy", {}];
if (_starter isEqualTo {}) exitWith {
	if !(_log isEqualTo {}) then {
		["ArmaFPV wrapper skipped: starter function missing", [_unitName, _item, typeOf _spawned]] call _log;
	};
};

private _started = [_spawned, _unit, format ["armafpv:%1", _item], true] call _starter;
if !(_log isEqualTo {}) then {
	["ArmaFPV wrapper finished", [_unitName, _item, typeOf _spawned, _started]] call _log;
};
