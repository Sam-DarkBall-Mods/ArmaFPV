if (!hasInterface) exitWith {};

#include "\ArmaFPV\script_macros.hpp"

call DB_fnc_fpv_handleConnect;

["unit", {
	params ["_player", "_oldPlayer"];

	if (!isNull _oldPlayer) then {
		private _oldId = _oldPlayer getVariable ["DB_armafpv_playerPutID", -1];
		if (_oldId >= 0) then {
			_oldPlayer removeEventHandler ["Put", _oldId];
			_oldPlayer setVariable ["DB_armafpv_playerPutID", -1];
		};
	};

	if (isNull _player || { !isPlayer _player }) exitWith {};

	private _existingId = _player getVariable ["DB_armafpv_playerPutID", -1];
	if (_existingId >= 0) then {
		_player removeEventHandler ["Put", _existingId];
	};

	private _newId = _player addEventHandler ["Put", { _this call DB_fnc_fpv_createUavOnItemCheck }];
	_player setVariable ["DB_armafpv_playerPutID", _newId];
}, true] call CBA_fnc_addPlayerEventHandler;
