if (!hasInterface) exitWith {};

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
if (!isNull _player) then {
	private _id = _player addEventHandler ["Put", { _this call DB_fnc_fpv_createUavOnItemCheck }];
	_player setVariable ["DB_armafpv_playerPutID", _id];
};

["loadout", {
	params ["_player"];

	private _oldId = _player getVariable ["DB_armafpv_playerPutID", -1];
	if (_oldId != -1) then { _player removeEventHandler ["Put", _oldId]; };
	if !(isPlayer _player) exitWith {};

	private _newId = _player addEventHandler ["Put", { _this call DB_fnc_fpv_createUavOnItemCheck }];
	_player setVariable ["DB_armafpv_playerPutID", _newId];
}] call CBA_fnc_addPlayerEventHandler;
