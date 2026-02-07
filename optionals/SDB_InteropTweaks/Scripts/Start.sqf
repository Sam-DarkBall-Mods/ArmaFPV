/*
	SDB Interop Tweaks bootstrap.
	Purpose: load SDB interop abstractions and run patch entrypoints.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_patchInitialized, false)) exitWith {};
SDB_SET_MVAR(SDB_it_patchInitialized, true);

if (isNil "SDB_it_fnc_registerSettings") then {
	SDB_it_fnc_registerSettings = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_registerSettings.sqf";
	SDB_SET_MVAR(SDB_it_fnc_registerSettings, SDB_it_fnc_registerSettings);
};
if (isNil "SDB_it_fnc_addAutonomyToggleAction") then {
	SDB_it_fnc_addAutonomyToggleAction = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_addAutonomyToggleAction.sqf";
	SDB_SET_MVAR(SDB_it_fnc_addAutonomyToggleAction, SDB_it_fnc_addAutonomyToggleAction);
};
missionNamespace setVariable ["SDB_fnc_addAutonomyToggleAction", SDB_it_fnc_addAutonomyToggleAction];
if (isNil "SDB_it_fnc_initPlayerAutonomy") then {
	SDB_it_fnc_initPlayerAutonomy = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_initPlayerAutonomy.sqf";
	SDB_SET_MVAR(SDB_it_fnc_initPlayerAutonomy, SDB_it_fnc_initPlayerAutonomy);
};
if (isNil "SDB_it_fnc_getInteropClassMap") then {
	SDB_it_fnc_getInteropClassMap = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_getInteropClassMap.sqf";
	SDB_SET_MVAR(SDB_it_fnc_getInteropClassMap, SDB_it_fnc_getInteropClassMap);
};
if (isNil "SDB_it_fnc_resolveCrocusClass") then {
	SDB_it_fnc_resolveCrocusClass = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_resolveCrocusClass.sqf";
	SDB_SET_MVAR(SDB_it_fnc_resolveCrocusClass, SDB_it_fnc_resolveCrocusClass);
};
if (isNil "SDB_it_fnc_patchDDTInterop") then {
	SDB_it_fnc_patchDDTInterop = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_patchDDTInterop.sqf";
	SDB_SET_MVAR(SDB_it_fnc_patchDDTInterop, SDB_it_fnc_patchDDTInterop);
};
if (isNil "SDB_it_fnc_patchArmaFPVInterop") then {
	SDB_it_fnc_patchArmaFPVInterop = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_patchArmaFPVInterop.sqf";
	SDB_SET_MVAR(SDB_it_fnc_patchArmaFPVInterop, SDB_it_fnc_patchArmaFPVInterop);
};

call SDB_it_fnc_registerSettings;
call SDB_it_fnc_initPlayerAutonomy;
call SDB_it_fnc_patchDDTInterop;
call SDB_it_fnc_patchArmaFPVInterop;
