/*
    SDB_it_fnc_tryStartAutonomy
    Starts autonomy for a drone once, where the drone is local.
    Author: DarkBall
*/

params [
	["_uav", objNull, [objNull]],
	["_unit", objNull, [objNull]],
	["_source", "unknown", [""]],
	["_enforceSupported", true, [true]]
];

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];

if (isNull _uav) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: UAV is null", [_source]] call _log;
	};
	false
};

if !(alive _uav) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: UAV not alive", [_source, typeOf _uav]] call _log;
	};
	false
};

if !(_uav isKindOf "Air") exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: object is not Air", [_source, typeOf _uav]] call _log;
	};
	false
};

if (isPlayer _unit && { !(missionNamespace getVariable ["sdbAutoAllowPlayers", true]) }) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: disabled for players by the server", [_source, typeOf _uav]] call _log;
	};
	false
};

private _supported = [];
private _unsupported = false;
if (_enforceSupported) then {
	private _supportedFn = missionNamespace getVariable ["SDB_it_fnc_getSupportedUavClasses", {}];
	if (_supportedFn isEqualTo {}) then {
		_supported = missionNamespace getVariable ["SDB_it_supportedUavClasses", []];
	} else {
		_supported = call _supportedFn;
	};

	private _uavClassUpper = toUpper typeOf _uav;
	_unsupported = (_supported findIf { (toUpper _x) isEqualTo _uavClassUpper }) < 0;
};
if (_unsupported) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: unsupported class", [_source, typeOf _uav, _supported]] call _log;
	};
	false
};

if (_uav getVariable ["SDB_autonomyStarted", false]) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: already started", [_source, typeOf _uav]] call _log;
	};
	false
};

_uav setVariable ["SDB_autonomyEnabled", true, true];
_uav setVariable ["ddtTasked", true, true];

private _autonomyStart = missionNamespace getVariable ["SDB_fnc_fpvAutonomyStart", {}];
if (_autonomyStart isEqualTo {}) exitWith {
	if !(_log isEqualTo {}) then {
		["Autonomy start skipped: start function is missing", [_source, typeOf _uav]] call _log;
	};
	false
};

if (local _uav) then {
	[_uav, _unit] call _autonomyStart;
} else {
	[_uav, _unit] remoteExecCall ["SDB_fnc_fpvAutonomyStart", owner _uav];
};

_uav setVariable ["SDB_autonomyStarted", true, true];
_uav setVariable ["SDB_autonomyStartedBy", _source, true];

if !(_log isEqualTo {}) then {
	[
		"Autonomy start dispatched",
		[_source, typeOf _uav, local _uav, if (local _uav) then { clientOwner } else { owner _uav }]
	] call _log;
};

true
