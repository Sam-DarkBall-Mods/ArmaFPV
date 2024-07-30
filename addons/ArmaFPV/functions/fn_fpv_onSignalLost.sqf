params ["_player", "_uav"];

_uav engineOn false;
_player connectTerminalToUAV objNull;
_uav setVariable ["DB_fpv_isUAVsignalLost", true];
_player disableUAVConnectability [_uav, true];

[driver _uav, gunner _uav] apply { _x setDamage 1 };