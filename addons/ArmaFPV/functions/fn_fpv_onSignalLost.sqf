/*
	ArmaFPV: signal loss handler.
	Purpose: disables drone control and marks the UAV as signal lost.
	Context: client/server depending on the caller.
	Params: [_player, _uav]
		_player - operator.
		_uav - UAV object.
	Returns: nothing.
*/

params ["_player", "_uav"];

if (isNull _player || { isNull _uav }) exitWith {};
if (_uav getVariable ["DB_fpv_isUAVsignalLost", false]) exitWith {};

_uav engineOn false;
_player connectTerminalToUAV objNull;
_uav setVariable ["DB_fpv_isUAVsignalLost", true];
_player disableUAVConnectability [_uav, true];

{
	if (!isNull _x) then {
		_x setDamage 1;
	};
} forEach [driver _uav, gunner _uav];
