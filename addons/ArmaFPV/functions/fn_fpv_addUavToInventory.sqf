params ["_uav", "_player"];

#include "\ArmaFPV\script_macros.hpp"

private _typeParts = typeOf _uav splitString "_";
private _coreType = _typeParts select [1, count _typeParts - 1] joinString "_";
private _itemType = format ["Item_%1", _coreType];
private _validItems = GETMVAR(DB_fpv_dronesArray_items, FPV_DRONE_ITEMS);

if !(_itemType in _validItems) exitWith {};
if (isNull _player) exitWith {};
if !(_player canAdd _itemType) exitWith {};

_player addItem _itemType;

{
	_uav deleteVehicleCrew _x;
} forEach crew _uav;

deleteVehicle _uav;

_player action ["TakeBag", objNull];
