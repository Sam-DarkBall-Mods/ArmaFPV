/*
	SDB Interop Tweaks bootstrap.
	Purpose: patch DDT to support Crocus inventory items from ArmaFPV.
*/

if (missionNamespace getVariable ["SDB_it_patchInitialized", false]) exitWith {};
missionNamespace setVariable ["SDB_it_patchInitialized", true];

[] spawn {
	waitUntil { !isNil "DDT_fnc_ManGetUAV" };

	if (isNil "ddtClassesFPV") then { ddtClassesFPV = []; };
	if (isNil "ddtClassesFPVAT") then { ddtClassesFPVAT = []; };

	{ ddtClassesFPV pushBackUnique _x; } forEach ["Item_Crocus_AP", "Item_Crocus_AP_TI"];
	{ ddtClassesFPVAT pushBackUnique _x; } forEach ["Item_Crocus_AT", "Item_Crocus_AT_TI"];

	if (isNil "DDT_fnc_ManGetUAV_original") then {
		DDT_fnc_ManGetUAV_original = DDT_fnc_ManGetUAV;
		missionNamespace setVariable ["DDT_fnc_ManGetUAV_original", DDT_fnc_ManGetUAV];
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

	DDT_fnc_ManGetUAV = compile preprocessFileLineNumbers "\SDB_InteropTweaks\Scripts\DDT\ManGetUAV.sqf";
	missionNamespace setVariable ["DDT_fnc_ManGetUAV", DDT_fnc_ManGetUAV];
};
