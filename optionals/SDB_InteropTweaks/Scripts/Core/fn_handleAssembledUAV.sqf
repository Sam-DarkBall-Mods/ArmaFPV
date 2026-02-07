/*
	Handle WeaponAssembled event.
	Purpose: enable autonomy for supported FPV drones assembled by player.
*/

params ["_unit", "_uav"];

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
private _unitName = if (isNull _unit) then { "<null>" } else { name _unit };
private _uavClass = if (isNull _uav) then { "<null>" } else { typeOf _uav };
if !(_log isEqualTo {}) then {
	["WeaponAssembled event", [_unitName, _uavClass]] call _log;
};

if (isNull _unit || {isNull _uav}) exitWith {};

private _useAutonomy = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
if !(_useAutonomy) exitWith {
	if !(_log isEqualTo {}) then {
		["WeaponAssembled skipped: autonomy disabled", [_unitName, _uavClass]] call _log;
	};
};

private _starter = missionNamespace getVariable ["SDB_it_fnc_tryStartAutonomy", {}];
if (_starter isEqualTo {}) exitWith {
	if !(_log isEqualTo {}) then {
		["WeaponAssembled skipped: starter function missing", [_unitName, _uavClass]] call _log;
	};
};

private _started = [_uav, _unit, "assemble", true] call _starter;
if !(_log isEqualTo {}) then {
	["WeaponAssembled pipeline finished", [_unitName, _uavClass, _started]] call _log;
};
