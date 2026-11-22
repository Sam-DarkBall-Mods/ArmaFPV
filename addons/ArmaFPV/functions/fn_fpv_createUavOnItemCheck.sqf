/*
    DB_fnc_fpv_createUavOnItemCheck
    Put handler: turns a Crocus item dropped on the ground into a ready drone of the player's side.
    Author: DarkBall
*/
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

if !(_item in magazineCargo _container) exitWith {};

private _uav = createVehicle [_uavClass, getPosATL _container, [], 0, "CAN_COLLIDE"];
if (isNull _uav) exitWith {};
_uav setVariable ["DB_fpv_spawnFrame", diag_frameNo];
createVehicleCrew _uav;
if (local _container) then {
	_uav disableCollisionWith _container;
} else {
	[_uav, _container] remoteExecCall ["disableCollisionWith", 0, _uav];
};

_container addMagazineCargoGlobal [_item, -1];
