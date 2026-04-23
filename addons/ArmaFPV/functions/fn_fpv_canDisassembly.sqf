params ["_uav"];

#include "\ArmaFPV\script_macros.hpp"

private _typeParts = typeOf _uav splitString "_";
private _coreType = _typeParts select [1, count _typeParts - 1] joinString "_";
private _itemType = format ["Item_%1", _coreType];
private _validItems = GETMVAR(DB_fpv_dronesArray_items, FPV_DRONE_ITEMS);

if !(_itemType in _validItems) exitWith { false };

alive _uav
	&& { player canAdd _itemType }
	&& { cameraOn == player }
	&& { (vectorMagnitude velocity _uav) < 0.3 }
	&& { !(isEngineOn _uav) }
