/*
	Convert Item_Crocus_* inventory items to side-specific vehicle class.
*/

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
