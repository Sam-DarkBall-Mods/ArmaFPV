/*
	Register WeaponAssembled interop for player-built UAVs.
	Purpose: start SDB autonomy for KVN/Crocus drones assembled from inventory.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_assemblePatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_assemblePatchQueued, true);

if (!hasInterface) exitWith {};

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
if !(_log isEqualTo {}) then {
	["Assemble patch queued", []] call _log;
};

[
	{ !isNull player && {!isNil "CBA_fnc_addBISPlayerEventHandler"} },
	{
		private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
		if (SDB_GET_MVAR(SDB_it_assemblePatchApplied, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_assemblePatchApplied, true);

		if (isNil "SDB_it_fnc_handleAssembledUAV") then {
			SDB_it_fnc_handleAssembledUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_handleAssembledUAV.sqf";
			SDB_SET_MVAR(SDB_it_fnc_handleAssembledUAV, SDB_it_fnc_handleAssembledUAV);
		};

		private _classMapFn = missionNamespace getVariable ["SDB_it_fnc_getInteropClassMap", { [[], []] }];
		private _classMap = call _classMapFn;
		private _supportedClasses = _classMap param [0, [], [[]]];
		_supportedClasses append (_classMap param [1, [], [[]]]);
		missionNamespace setVariable ["SDB_it_supportedUavClasses", _supportedClasses];

		private _added = [
			"SDB_it_weaponAssembled",
			"WeaponAssembled",
			{
				private _fn = missionNamespace getVariable ["SDB_it_fnc_handleAssembledUAV", {}];
				if !(_fn isEqualTo {}) then {
					_this call _fn;
				};
			}
		] call CBA_fnc_addBISPlayerEventHandler;

		if !(_log isEqualTo {}) then {
			["Assemble patch applied", [_added, count _supportedClasses]] call _log;
		};
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
