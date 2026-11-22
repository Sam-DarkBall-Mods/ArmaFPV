/*
    DB_fnc_fpv_handleSignal
    Link loop: samples the signal, feeds the video effects and the OSD and drops the link after a long jam.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

private _loopInterval = GETMVAR(DB_fpv_signalUpdateInterval, FPV_SIGNAL_UPDATE_INTERVAL);
private _signalLossThreshold = GETMVAR(DB_fpv_signalLossThreshold, FPV_SIGNAL_LOSS_THRESHOLD);
private _signalLossDuration = GETMVAR(DB_fpv_signalLossDuration, FPV_SIGNAL_LOSS_DURATION);

call DB_fnc_fpv_ppfx_start;

private _prevPfh = GETMVAR(DB_fpv_signalPFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	params ["_args", "_handle"];
	_args params ["_signalLossThreshold", "_signalLossDuration", "_lastTick"];

	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	private _uav = getConnectedUAV _player;

	if (isNull _player || { isNull _uav } || { !(GETMVAR(ArmaFPV_isControl, false)) }) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
		call DB_fnc_fpv_ppfx_stop;
	};

	private _now = diag_tickTime;
	_args set [2, _now];

	private _signal = [_player, _uav] call DB_fnc_fpv_getSignal;
	private _inJammer = _uav getVariable ["DB_fpv_inJammer", false];
	[_signal, [
		"altAGL", (getPosATL _uav) # 2,
		"distance", _player distance _uav,
		"maxDistance", _uav getVariable ["DB_fpv_signalMaxDistance", GETMVAR(FPV_MaxFlightDistance, 4000)],
		"inJammer", _inJammer,
		"jammerFactor", _uav getVariable ["DB_fpv_jammerFactor", 0],
		"obstacleCount", _uav getVariable ["DB_fpv_signalObstacles", 0],
		"terrainMask", _uav getVariable ["DB_fpv_signalTerrainMask", 0]
	]] call DB_fnc_fpv_ppfx_setInput;

	private _jammerLowTime = 0;
	if (_inJammer && { _signal <= _signalLossThreshold } && { !(_uav getVariable ["DB_fpv_isUAVsignalLost", false]) }) then {
		_jammerLowTime = (_uav getVariable ["DB_fpv_jammerLowTime", 0]) + _now - _lastTick;
		if (_jammerLowTime >= _signalLossDuration) then {
			[_player, _uav] call DB_fnc_fpv_onSignalLost;
			_jammerLowTime = 0;
		};
	};
	_uav setVariable ["DB_fpv_jammerLowTime", _jammerLowTime];
}, _loopInterval, [_signalLossThreshold, _signalLossDuration, diag_tickTime]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_signalPFH, _pfhId);
