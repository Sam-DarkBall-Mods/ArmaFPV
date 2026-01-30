/*
	ArmaFPV: PreInit and base settings.
	Purpose: registers CBA settings and shared module constants.
	Context: runs on all machines during preInit.
*/

if (isNil "DB_fpv_droneTypes") then {
	DB_fpv_droneTypes = [
		"O_Crocus_AT",
		"O_Crocus_AP",
		"B_Crocus_AT",
		"B_Crocus_AP",
		"I_Crocus_AT",
		"I_Crocus_AP",
		"O_Crocus_AT_TI",
		"O_Crocus_AP_TI",
		"B_Crocus_AT_TI",
		"B_Crocus_AP_TI",
		"I_Crocus_AT_TI",
		"I_Crocus_AP_TI"
	];
};

if (isNil "DB_fpv_dronesArray_items") then {
	DB_fpv_dronesArray_items = [
		"Item_Crocus_AT",
		"Item_Crocus_AP",
		"Item_Crocus_AT_TI",
		"Item_Crocus_AP_TI"
	];
};

if (isNil "DB_fpv_terminalTypes") then {
	DB_fpv_terminalTypes = ["B_UavTerminal", "O_UavTerminal", "I_UavTerminal"];
};

if (isNil "DB_fpv_signalLossThreshold") then {
	DB_fpv_signalLossThreshold = 0.05;
};

if (isNil "DB_fpv_signalLossDuration") then {
	DB_fpv_signalLossDuration = 5;
};

if (isNil "DB_fpv_signalUpdateInterval") then {
	DB_fpv_signalUpdateInterval = 0.2;
};

if (isNil "DB_fpv_connectLoopInterval") then {
	DB_fpv_connectLoopInterval = 0.1;
};

[ 
    "FPV_DefaultText",
    "EDITBOX",
    ["Default Text", "Enter the text"],
    "FPV Settings",
    "CROCUS",
    0,
    { call DB_fnc_fpv_handleSettings }
] call cba_settings_fnc_init;

private _fnc_registerAdminSettings = {
	if (missionNamespace getVariable ["DB_fpv_adminSettingsRegistered", false]) exitWith {};
	missionNamespace setVariable ["DB_fpv_adminSettingsRegistered", true];

	[
		"FPV_isUavCaptive",
		"CHECKBOX",
		["AI Cannot See FPV Drones", ""],
		"FPV Settings",
		true,
		1,
		{
			publicVariable "FPV_isUavCaptive";
			call DB_fnc_fpv_handleSettings;
		}
	] call cba_settings_fnc_init;

	[
		"FPV_MaxFlightDistance",
		"SLIDER",
		["Max Flight Distance", ""],
		"FPV Settings",
		[1500, 12000, 4000, 0],
		1,
		{ publicVariable "FPV_MaxFlightDistance" }
	] call cba_settings_fnc_init;

};

missionNamespace setVariable ["DB_fpv_registerAdminSettings", _fnc_registerAdminSettings];

if (hasInterface) then {
	if (isServer || { serverCommandAvailable "#kick" }) then {
		call _fnc_registerAdminSettings;
	} else {
		[] spawn {
			waitUntil { !hasInterface || serverCommandAvailable "#kick" };
			if (!hasInterface) exitWith {};
			private _register = missionNamespace getVariable ["DB_fpv_registerAdminSettings", {}];
			call _register;
		};
	};
};
