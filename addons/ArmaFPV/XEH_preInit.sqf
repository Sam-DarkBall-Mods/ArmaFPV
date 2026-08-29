#include "\ArmaFPV\script_macros.hpp"

if (missionNamespace isNil "DB_fpv_droneTypes") then {
	DB_fpv_droneTypes = FPV_DRONE_TYPES;
};

if (missionNamespace isNil "DB_fpv_dronesArray_items") then {
	DB_fpv_dronesArray_items = FPV_DRONE_ITEMS;
};

if (missionNamespace isNil "DB_fpv_signalLossThreshold") then {
	DB_fpv_signalLossThreshold = FPV_SIGNAL_LOSS_THRESHOLD;
};

if (missionNamespace isNil "DB_fpv_signalLossDuration") then {
	DB_fpv_signalLossDuration = FPV_SIGNAL_LOSS_DURATION;
};

if (missionNamespace isNil "DB_fpv_signalUpdateInterval") then {
	DB_fpv_signalUpdateInterval = FPV_SIGNAL_UPDATE_INTERVAL;
};

if (missionNamespace isNil "DB_fpv_connectLoopInterval") then {
	DB_fpv_connectLoopInterval = FPV_CONNECT_LOOP_INTERVAL;
};

private _fnc_sanitizeText = {
	params ["_value"];
	private _allowedChars = toArray "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,;\/ ";
	if ((toArray _value) findIf { !(_x in _allowedChars) } >= 0) exitWith { "" };
	_value
};

[
	"FPV_DefaultText",
	"EDITBOX",
	["Default Text", "Enter the text"],
	"FPV Settings",
	["CROCUS", false, _fnc_sanitizeText],
	false,
	{ call DB_fnc_fpv_handleSettings }
] call CBA_fnc_addSetting;

[
	"FPV_isUavCaptive",
	"CHECKBOX",
	["AI Cannot See FPV Drones", ""],
	"FPV Settings",
	true,
	true,
	{ call DB_fnc_fpv_handleSettings }
] call CBA_fnc_addSetting;

[
	"FPV_MaxFlightDistance",
	"SLIDER",
	["Max Flight Distance", ""],
	"FPV Settings",
	[1500, 12000, 4000, 0],
	true
] call CBA_fnc_addSetting;
