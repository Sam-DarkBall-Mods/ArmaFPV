/*
	Apply ArmaFPV interop patch once ArmaFPV creation handler is available.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_armafpvPatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_armafpvPatchQueued, true);

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
if !(_log isEqualTo {}) then {
	["ArmaFPV patch queued", []] call _log;
};

[
	{ !isNil "DB_fnc_fpv_createUavOnItemCheck" },
	{
		private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
		if (SDB_GET_MVAR(SDB_it_armafpvPatched, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_armafpvPatched, true);

		private _allowDirectPatch = missionNamespace getVariable ["sdbArmaFPVDirectPatch", false];
		if !(_allowDirectPatch) exitWith {
			if !(_log isEqualTo {}) then {
				[
					"ArmaFPV direct function patch skipped; relying on Put/WeaponAssembled interop",
					[_allowDirectPatch]
				] call _log;
			};
		};

		if (isNil "DB_fnc_fpv_createUavOnItemCheck_original") then {
			DB_fnc_fpv_createUavOnItemCheck_original = DB_fnc_fpv_createUavOnItemCheck;
			missionNamespace setVariable ["DB_fnc_fpv_createUavOnItemCheck_original", DB_fnc_fpv_createUavOnItemCheck];
		};

		DB_fnc_fpv_createUavOnItemCheck = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\ArmaFPV\CreateUavOnItemCheck.sqf";
		missionNamespace setVariable ["DB_fnc_fpv_createUavOnItemCheck", DB_fnc_fpv_createUavOnItemCheck];

		if !(_log isEqualTo {}) then {
			["ArmaFPV patch applied", [true]] call _log;
		};
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
