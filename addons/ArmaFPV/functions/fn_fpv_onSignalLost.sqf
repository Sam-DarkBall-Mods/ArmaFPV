/*
    DB_fnc_fpv_onSignalLost
    Drops the link when the jammer wins: stops the motors, disconnects the pilot and kills the drone's AI crew.
    Author: DarkBall
*/
params ["_player", "_uav"];

if (isNull _uav) exitWith {};
if (_uav getVariable ["DB_fpv_isUAVsignalLost", false]) exitWith {};

if (local _uav) then {
	_uav engineOn false;
} else {
	[_uav, false] remoteExecCall ["engineOn", _uav];
};

if (!isNull _player) then {
	_player connectTerminalToUAV objNull;
	_player disableUAVConnectability [_uav, true];
};

_uav setVariable ["DB_fpv_isUAVsignalLost", true, true];

{
	if (!isNull _x) then {
		_x setDamage 1;
	};
} forEach [driver _uav, gunner _uav];
