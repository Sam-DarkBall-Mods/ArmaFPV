/*
	SDB Interop Tweaks bootstrap.
	Purpose: patch DDT interoperability and optional FPV autonomy.
*/

if (missionNamespace getVariable ["SDB_it_patchInitialized", false]) exitWith {};
missionNamespace setVariable ["SDB_it_patchInitialized", true];

if (isNil "SDB_it_settingsRegistered") then {
	SDB_it_settingsRegistered = true;

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
		"sdbAutoNoise",
		"SLIDER",
		["Detection Noise", "Random noise added to confidence score."],
		"SDB Interop Tweaks",
		[0, 0.5, 0.12, 2],
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
};

if (hasInterface) then {
	[] spawn {
		waitUntil { !isNull player };

		if (isNil { player getVariable "SDB_autonomyNextLaunch" }) then {
			player setVariable [
				"SDB_autonomyNextLaunch",
				missionNamespace getVariable ["sdbAutoEnableByDefault", false],
				true
			];
		};

		private _fn_addToggleAction = {
			params ["_unit"];
			if (isNull _unit) exitWith {};

			private _oldAction = _unit getVariable ["SDB_autonomyToggleAction", -1];
			if (_oldAction >= 0) then {
				_unit removeAction _oldAction;
			};

			private _state = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
			private _label = if (_state) then { "ON" } else { "OFF" };
			private _title = format ["SDB FPV: Toggle Autonomy [%1]", _label];

			private _id = _unit addAction [
				_title,
				{
					params ["_target", "_caller", "_actionId"];
					if (_caller isNotEqualTo _target) exitWith {};

					private _newState = !(_caller getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]]);
					_caller setVariable ["SDB_autonomyNextLaunch", _newState, true];

					private _newLabel = if (_newState) then { "ON" } else { "OFF" };
					_target setUserActionText [_actionId, format ["SDB FPV: Toggle Autonomy [%1]", _newLabel]];
					systemChat format ["SDB FPV autonomy: %1", _newLabel];
				},
				[],
				1.5,
				false,
				true,
				"",
				"true"
			];

			_unit setVariable ["SDB_autonomyToggleAction", _id];
		};

		missionNamespace setVariable ["SDB_fnc_addAutonomyToggleAction", _fn_addToggleAction];
		[player] call _fn_addToggleAction;

		["respawn", {
			params ["_player"];
			private _fn = missionNamespace getVariable ["SDB_fnc_addAutonomyToggleAction", {}];
			if (_fn isEqualTo {}) exitWith {};
			if (isNil { _player getVariable "SDB_autonomyNextLaunch" }) then {
				_player setVariable [
					"SDB_autonomyNextLaunch",
					missionNamespace getVariable ["sdbAutoEnableByDefault", false],
					true
				];
			};
			[_player] call _fn;
		}] call CBA_fnc_addPlayerEventHandler;
	};
};

[] spawn {
	waitUntil { !isNil "DDT_fnc_ManGetUAV" && {!isNil "DDT_fnc_DeployUAV"} };

	if (isNil "ddtClassesFPV") then { ddtClassesFPV = []; };
	if (isNil "ddtClassesFPVAT") then { ddtClassesFPVAT = []; };

	{
		ddtClassesFPV pushBackUnique _x;
	} forEach [
		"Item_Crocus_AP",
		"Item_Crocus_AP_TI",
		"B_KVN_AP",
		"O_KVN_AP",
		"I_KVN_AP",
		"B_KVN_AP_TI",
		"O_KVN_AP_TI",
		"I_KVN_AP_TI",
		"B_Crocus_AP_TI_Bag",
		"O_Crocus_AP_TI_Bag",
		"I_Crocus_AP_TI_Bag",
		"B_CROCUS_AP_TI",
		"O_CROCUS_AP_TI",
		"I_CROCUS_AP_TI"
	];

	{
		ddtClassesFPVAT pushBackUnique _x;
	} forEach [
		"Item_Crocus_AT",
		"Item_Crocus_AT_TI",
		"B_KVN_AT",
		"O_KVN_AT",
		"I_KVN_AT",
		"B_KVN_AT_TI",
		"O_KVN_AT_TI",
		"I_KVN_AT_TI",
		"B_Crocus_AT_TI_Bag",
		"O_Crocus_AT_TI_Bag",
		"I_Crocus_AT_TI_Bag",
		"B_CROCUS_AT_TI",
		"O_CROCUS_AT_TI",
		"I_CROCUS_AT_TI"
	];

	if (isNil "DDT_fnc_ManGetUAV_original") then {
		DDT_fnc_ManGetUAV_original = DDT_fnc_ManGetUAV;
		missionNamespace setVariable ["DDT_fnc_ManGetUAV_original", DDT_fnc_ManGetUAV];
	};

	if (isNil "DDT_fnc_DeployUAV_original") then {
		DDT_fnc_DeployUAV_original = DDT_fnc_DeployUAV;
		missionNamespace setVariable ["DDT_fnc_DeployUAV_original", DDT_fnc_DeployUAV];
	};

	missionNamespace setVariable [
		"SDB_fnc_ddt_resolveCrocusClass",
		{
			params ["_itemClass", "_side"];

			private _prefix = switch (_side) do {
				case west: { "B_" };
				case east: { "O_" };
				case resistance: { "I_" };
				default { "" };
			};

			if (_prefix isEqualTo "") exitWith { _itemClass };

			private _suffix = switch (toUpper _itemClass) do {
				case "ITEM_CROCUS_AP": { "Crocus_AP" };
				case "ITEM_CROCUS_AP_TI": { "Crocus_AP_TI" };
				case "ITEM_CROCUS_AT": { "Crocus_AT" };
				case "ITEM_CROCUS_AT_TI": { "Crocus_AT_TI" };
				default { "" };
			};

			if (_suffix isEqualTo "") exitWith { _itemClass };
			format ["%1%2", _prefix, _suffix]
		}
	];

	missionNamespace setVariable [
		"SDB_fnc_ddt_deployUAVAutonomy",
		compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\DeployUAV_Autonomy.sqf"
	];

	DDT_fnc_ManGetUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\ManGetUAV.sqf";
	DDT_fnc_DeployUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\DeployUAV.sqf";

	missionNamespace setVariable ["DDT_fnc_ManGetUAV", DDT_fnc_ManGetUAV];
	missionNamespace setVariable ["DDT_fnc_DeployUAV", DDT_fnc_DeployUAV];
};
