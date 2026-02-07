/*
	Apply ArmaFPV interop patch once ArmaFPV creation handler is available.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_armafpvPatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_armafpvPatchQueued, true);

[
	{ !isNil "DB_fnc_fpv_createUavOnItemCheck" },
	{
		if (SDB_GET_MVAR(SDB_it_armafpvPatched, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_armafpvPatched, true);

		if (isNil "DB_fnc_fpv_createUavOnItemCheck_original") then {
			DB_fnc_fpv_createUavOnItemCheck_original = DB_fnc_fpv_createUavOnItemCheck;
			missionNamespace setVariable ["DB_fnc_fpv_createUavOnItemCheck_original", DB_fnc_fpv_createUavOnItemCheck];
		};

		DB_fnc_fpv_createUavOnItemCheck = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\ArmaFPV\CreateUavOnItemCheck.sqf";
		missionNamespace setVariable ["DB_fnc_fpv_createUavOnItemCheck", DB_fnc_fpv_createUavOnItemCheck];
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
