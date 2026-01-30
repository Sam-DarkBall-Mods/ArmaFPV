if (!hasInterface) exitWith {};

#include "\ArmaFPV\script_macros.hpp"

private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
if (!isNull _player) then {
	private _id = _player addEventHandler ["Put", { _this call DB_fnc_fpv_createUavOnItemCheck }];
	_player setVariable ["DB_armafpv_playerPutID", _id];
};

call DB_fnc_fpv_handleConnect;

["loadout", {
	params ["_player"];

	private _oldId = _player getVariable ["DB_armafpv_playerPutID", -1];
	if (_oldId != -1) then { _player removeEventHandler ["Put", _oldId]; };
	if !(isPlayer _player) exitWith {};

	private _newId = _player addEventHandler ["Put", { _this call DB_fnc_fpv_createUavOnItemCheck }];
	_player setVariable ["DB_armafpv_playerPutID", _newId];
}] call CBA_fnc_addPlayerEventHandler;

if (hasInterface && {!isServer}) then {
	[
		{ !hasInterface || serverCommandAvailable "#kick" },
		{
			if (!hasInterface) exitWith {};
			private _register = GETMVAR(DB_fpv_registerAdminSettings, {});
			call _register;
		}
	] call CBA_fnc_waitUntilAndExecute;
};
