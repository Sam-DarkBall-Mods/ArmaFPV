/*
	SDB Interop Tweaks settings registration.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_settingsRegistered, false)) exitWith {};
SDB_SET_MVAR(SDB_it_settingsRegistered, true);

[
	"sdbAutoEnableByDefault",
	"CHECKBOX",
	["Autonomy Default (Player)", "Use autonomous FPV mode by default for player launches."],
	"SDB Interop Tweaks",
	false,
	false,
	{
		params ["_value"];
		if (hasInterface && {!isNull player}) then {
			if (isNil { player getVariable "SDB_autonomyNextLaunch" }) then {
				player setVariable ["SDB_autonomyNextLaunch", _value, true];
			};
		};
	}
] call CBA_fnc_addSetting;

[
	"sdbAutoScanInterval",
	"SLIDER",
	["Scan Interval (s)", "Target search interval."],
	"SDB Interop Tweaks",
	[0.05, 2, 0.25, 2],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoGuideTick",
	"SLIDER",
	["Guidance Tick (s)", "Autonomy guidance loop interval."],
	"SDB Interop Tweaks",
	[0.02, 0.2, 0.05, 2],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoMaxRange",
	"SLIDER",
	["Detection Range", "Maximum autonomous target detection range (m)."],
	"SDB Interop Tweaks",
	[300, 6000, 2500, 0],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoLockThreshold",
	"SLIDER",
	["Lock Threshold", "Score required to lock a target."],
	"SDB Interop Tweaks",
	[0.2, 1, 0.62, 2],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoReleaseThreshold",
	"SLIDER",
	["Release Threshold", "Score below which target lock is dropped."],
	"SDB Interop Tweaks",
	[0.1, 0.9, 0.45, 2],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoHorizontalFov",
	"SLIDER",
	["Horizontal FOV", "Horizontal search cone (degrees)."],
	"SDB Interop Tweaks",
	[30, 160, 95, 0],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoDownAngle",
	"SLIDER",
	["Down Angle", "Search angle below horizon (degrees)."],
	"SDB Interop Tweaks",
	[5, 80, 45, 0],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoCruiseSpeed",
	"SLIDER",
	["Cruise Speed", "Autonomy cruise speed (m/s)."],
	"SDB Interop Tweaks",
	[10, 90, 38, 0],
	true
] call CBA_fnc_addSetting;

[
	"sdbAutoTerminalDistance",
	"SLIDER",
	["Terminal Distance", "Distance at which terminal attack starts (m)."],
	"SDB Interop Tweaks",
	[1, 40, 10, 0],
	true
] call CBA_fnc_addSetting;
