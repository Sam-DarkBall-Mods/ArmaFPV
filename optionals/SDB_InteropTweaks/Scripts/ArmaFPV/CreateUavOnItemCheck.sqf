/*
	ArmaFPV create handler wrapper.
	Purpose: keep original spawn flow and attach SDB autonomy when launched from inventory workflow.
*/

params ["_unit", "_container", "_item"];

private _original = missionNamespace getVariable ["DB_fnc_fpv_createUavOnItemCheck_original", {}];
if (_original isEqualTo {}) exitWith {};

private _useAutonomy = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
if !(_useAutonomy) exitWith {
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

_this call _original;

if (_expectedClass == "" || {isNull _container}) exitWith {};

private _after = nearestObjects [getPosATL _container, [_expectedClass], 8];
private _spawned = objNull;
{
	if !(_x in _before) exitWith {
		_spawned = _x;
	};
} forEach _after;

if (isNull _spawned && {(count _after) > 0}) then {
	_spawned = _after # 0;
};
if (isNull _spawned) exitWith {};

_spawned setVariable ["SDB_autonomyEnabled", true, true];
_spawned setVariable ["ddtTasked", true, true];

private _autonomyStart = missionNamespace getVariable ["SDB_fnc_fpvAutonomyStart", {}];
if (_autonomyStart isEqualTo {}) exitWith {};

if (local _spawned) then {
	[_spawned, _unit] call _autonomyStart;
} else {
	[_spawned, _unit] remoteExecCall ["SDB_fnc_fpvAutonomyStart", owner _spawned];
};
