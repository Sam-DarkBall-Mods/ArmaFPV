/*
    DB_fnc_fpv_canDisassembly
    Tells whether the player can pack a landed Crocus back into an item.
    Author: DarkBall
*/
params ["_uav"];

#include "\ArmaFPV\script_macros.hpp"

private _itemType = "Item_" + (typeOf _uav select [2]);

alive _uav
	&& { _itemType in GETMVAR(DB_fpv_dronesArray_items, FPV_DRONE_ITEMS) }
	&& { player canAdd _itemType }
	&& { cameraOn == player }
	&& { (vectorMagnitude velocity _uav) < 0.3 }
	&& { !(isEngineOn _uav) }
