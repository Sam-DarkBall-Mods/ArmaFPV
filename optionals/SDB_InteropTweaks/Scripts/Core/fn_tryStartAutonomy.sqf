/*
	Common autonomy starter.
	Purpose: dedupe launch attempts and centralize local/remote autonomy start.
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

if (_enforceSupported) then {
	private _supported = missionNamespace getVariable ["SDB_it_supportedUavClasses", []];
	if (_supported isEqualTo []) then {
		private _classMapFn = missionNamespace getVariable ["SDB_it_fnc_getInteropClassMap", { [[], []] }];
		private _classMap = call _classMapFn;
		_supported = +(_classMap param [0, [], [[]]]);
		_supported append (_classMap param [1, [], [[]]]);
		missionNamespace setVariable ["SDB_it_supportedUavClasses", _supported];
	};

	private _uavClass = typeOf _uav;
	if !(_uavClass in _supported) exitWith {
		if !(_log isEqualTo {}) then {
			["Autonomy start skipped: unsupported class", [_source, _uavClass]] call _log;
		};
		false
	};
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
