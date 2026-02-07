/*
	Apply DDT interop patch once DDT function pointers are available.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_ddtPatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_ddtPatchQueued, true);

[
	{ !isNil "DDT_fnc_ManGetUAV" && {!isNil "DDT_fnc_DeployUAV"} },
	{
		if (SDB_GET_MVAR(SDB_it_ddtPatched, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_ddtPatched, true);

		if (isNil "ddtClassesFPV") then { ddtClassesFPV = []; };
		if (isNil "ddtClassesFPVAT") then { ddtClassesFPVAT = []; };

		private _classMapFn = missionNamespace getVariable ["SDB_it_fnc_getInteropClassMap", { [[], []] }];
		private _classMap = call _classMapFn;
		private _fpvClasses = _classMap param [0, [], [[]]];
		private _fpvatClasses = _classMap param [1, [], [[]]];

		{
			ddtClassesFPV pushBackUnique _x;
		} forEach _fpvClasses;

		{
			ddtClassesFPVAT pushBackUnique _x;
		} forEach _fpvatClasses;

		if (isNil "DDT_fnc_ManGetUAV_original") then {
			DDT_fnc_ManGetUAV_original = DDT_fnc_ManGetUAV;
			missionNamespace setVariable ["DDT_fnc_ManGetUAV_original", DDT_fnc_ManGetUAV];
		};

		if (isNil "DDT_fnc_DeployUAV_original") then {
			DDT_fnc_DeployUAV_original = DDT_fnc_DeployUAV;
			missionNamespace setVariable ["DDT_fnc_DeployUAV_original", DDT_fnc_DeployUAV];
		};

		private _resolveFn = SDB_GET_MVAR(SDB_it_fnc_resolveCrocusClass, {});
		if !(_resolveFn isEqualTo {}) then {
			missionNamespace setVariable ["SDB_fnc_ddt_resolveCrocusClass", _resolveFn];
		};

		missionNamespace setVariable [
			"SDB_fnc_ddt_deployUAVAutonomy",
			compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\DeployUAV_Autonomy.sqf"
		];
		missionNamespace setVariable [
			"SDB_fnc_fpvAutonomyStart",
			compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\AI_FPV_Autonomy.sqf"
		];

		DDT_fnc_ManGetUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\ManGetUAV.sqf";
		DDT_fnc_DeployUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\DeployUAV.sqf";

		missionNamespace setVariable ["DDT_fnc_ManGetUAV", DDT_fnc_ManGetUAV];
		missionNamespace setVariable ["DDT_fnc_DeployUAV", DDT_fnc_DeployUAV];
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
