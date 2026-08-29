params ["_unit", "_container", "_item"];

#include "\ArmaFPV\script_macros.hpp"

private _validItems = GETMVAR(DB_fpv_dronesArray_items, FPV_DRONE_ITEMS);
if !(_item in _validItems) exitWith {};
if (typeOf _container != "GroundWeaponHolder") exitWith {};

private _itemCfg = configFile >> "CfgMagazines" >> _item;
if !(isClass _itemCfg) exitWith {};

private _uavType = switch (_item) do {
	case "Item_Crocus_AT": { "Crocus_AT" };
	case "Item_Crocus_AP": { "Crocus_AP" };
	case "Item_Crocus_AT_TI": { "Crocus_AT_TI" };
	case "Item_Crocus_AP_TI": { "Crocus_AP_TI" };
	default { "" };
};
if (_uavType == "") exitWith {};

private _sidePrefix = switch (side _unit) do {
	case east: { "O_" };
	case west: { "B_" };
	case resistance: { "I_" };
	default { "" };
};
if (_sidePrefix isEqualTo "") exitWith {};

private _uavClass = format ["%1%2", _sidePrefix, _uavType];
if !(isClass (configFile >> "CfgVehicles" >> _uavClass)) exitWith {};

private _cargo = magazinesAmmoCargo _container;
if (_cargo findIf { (_x # 0) isEqualTo _item } < 0) exitWith {};

private _pos = getPosATL _container;
private _uav = createVehicle [_uavClass, _pos, [], 0, "CAN_COLLIDE"];
if (isNull _uav) exitWith {};
createVehicleCrew _uav;

if (local _uav && local _container) then {
	_uav disableCollisionWith _container;
} else {
	[_uav, _container] remoteExecCall ["disableCollisionWith", 0, _uav];
};

_container addMagazineAmmoCargo [_item, -1, 0];
