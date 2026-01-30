params ["_uav", "_player"];

private _typeParts = typeOf _uav splitString "_";
private _coreType = _typeParts select [1, count _typeParts - 1] joinString "_";
private _itemType = format ["Item_%1", _coreType];

_player addItem _itemType;
deleteVehicle _uav;

_player action ["TakeBag", objNull];
