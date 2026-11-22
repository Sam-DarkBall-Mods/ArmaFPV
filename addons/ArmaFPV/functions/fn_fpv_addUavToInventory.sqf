/*
    DB_fnc_fpv_addUavToInventory
    Packs a landed Crocus back into its inventory item for the player; runs where the drone is local.
    Author: DarkBall
*/
params ["_uav", "_player", ["_giveItem", ""]];

#include "\ArmaFPV\script_macros.hpp"

if (_giveItem isNotEqualTo "") exitWith {
	if (!local _player) exitWith {};
	if (_player canAdd _giveItem) exitWith { _player addItem _giveItem; };
	private _holder = createVehicle ["GroundWeaponHolder", getPosATL _player, [], 0, "CAN_COLLIDE"];
	_holder addMagazineCargoGlobal [_giveItem, 1];
};

if (isNull _uav || { isNull _player }) exitWith {};
if (!local _uav) exitWith {
	[_uav, _player] remoteExecCall ["DB_fnc_fpv_addUavToInventory", _uav];
};

private _itemType = "Item_" + (typeOf _uav select [2]);
if !(_itemType in GETMVAR(DB_fpv_dronesArray_items, FPV_DRONE_ITEMS)) exitWith {};
if (!alive _uav || { _uav getVariable ["DB_fpv_isDetonating", false] } || { _uav getVariable ["DB_fpv_packed", false] }) exitWith {};
if (isEngineOn _uav || { vectorMagnitude velocity _uav > 0.3 } || { _player distance _uav > 10 } || { !(_player canAdd _itemType) }) exitWith {};

_uav setVariable ["DB_fpv_packed", true];
deleteVehicleCrew _uav;
deleteVehicle _uav;
[objNull, _player, _itemType] remoteExecCall ["DB_fnc_fpv_addUavToInventory", _player];
