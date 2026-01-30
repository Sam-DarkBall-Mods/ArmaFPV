params ["_unit", "_container", "_item"];

private _validItems = missionNamespace getVariable ["DB_fpv_dronesArray_items", []];
if !(_item in _validItems) exitWith {};
if (typeOf _container != "GroundWeaponHolder") exitWith {};

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
private _uavClass = format ["%1%2", _sidePrefix, _uavType];

private _pos = getPosATL _container;
private _uav = createVehicle [_uavClass, _pos, [], 0, "CAN_COLLIDE"];
createVehicleCrew _uav;

if (local _uav && local _container) then {
	_uav disableCollisionWith _container;
} else {
	[_uav, _container] remoteExecCall ["disableCollisionWith", 0, _uav];
};

private _cargo = magazineCargo _container;
private _newCargo = [];
{
	if (_x != _item) then { _newCargo pushBack _x };
} forEach _cargo;

clearMagazineCargo _container;
{
	_container addMagazineCargo [_x, 1];
} forEach _newCargo;
