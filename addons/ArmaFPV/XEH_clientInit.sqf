/*
	ArmaFPV: ClientInit.
	Purpose: basic client initialization for UI/state variables.
	Context: interface clients only.
*/

if (!hasInterface) exitWith {};

if (isNil "ArmaFPV_isControl") then {
	ArmaFPV_isControl = false;
};

if (isNil "DB_FPV_Layer_ID") then {
	DB_FPV_Layer_ID = -1;
};
