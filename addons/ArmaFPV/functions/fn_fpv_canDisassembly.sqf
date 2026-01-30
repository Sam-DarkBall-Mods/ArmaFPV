params ["_uav"];

private _typeParts = typeOf _uav splitString "_";
private _coreType = _typeParts select [1, count _typeParts - 1] joinString "_";
private _itemType = format ["Item_%1", _coreType];

alive _uav
	&& { player canAdd _itemType }
	&& { cameraOn == player }
	&& { (speed _uav) < 1 }
	&& { !(isEngineOn _uav) }
