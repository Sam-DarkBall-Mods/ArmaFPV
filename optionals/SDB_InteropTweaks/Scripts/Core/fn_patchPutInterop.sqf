/*
	Register Put event interop for inventory-drop UAV workflows.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_putPatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_putPatchQueued, true);

if (!hasInterface) exitWith {};

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
if !(_log isEqualTo {}) then {
	["Put patch queued", []] call _log;
};

[
	{ !isNull player && {!isNil "CBA_fnc_addBISPlayerEventHandler"} },
	{
		if (SDB_GET_MVAR(SDB_it_putPatchApplied, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_putPatchApplied, true);

		if (isNil "SDB_it_fnc_handlePlayerPut") then {
			SDB_it_fnc_handlePlayerPut = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\Core\fn_handlePlayerPut.sqf";
			SDB_SET_MVAR(SDB_it_fnc_handlePlayerPut, SDB_it_fnc_handlePlayerPut);
		};

		private _added = [
			"SDB_it_put",
			"Put",
			{
				private _fn = missionNamespace getVariable ["SDB_it_fnc_handlePlayerPut", {}];
				if !(_fn isEqualTo {}) then {
					_this call _fn;
				};
			}
		] call CBA_fnc_addBISPlayerEventHandler;

		private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
		if !(_log isEqualTo {}) then {
			["Put interop patch applied", [_added]] call _log;
		};
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
