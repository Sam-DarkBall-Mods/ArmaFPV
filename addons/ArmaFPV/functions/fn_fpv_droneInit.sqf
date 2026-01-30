/*
	ArmaFPV: drone initialization.
	Purpose: disables AI and enables custom jammer behavior for the drone.
	Context: server/client when the drone is created.
	Params: [_uav]
		_uav - drone object.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

params ["_uav"];

if (isNull _uav) exitWith {};

if (isNil "cba_common_waitUntilAndExecArray") exitWith {
	_uav disableAI "ALL";
	_uav setVariable ["DB_jammer_customUavBehavior", true, true];
};

[
	{
		params ["_uav"];
		!isNull _uav
	},
	{
		params ["_uav"];
		_uav disableAI "ALL";
		_uav setVariable ["DB_jammer_customUavBehavior", true, true];
	},
	[_uav]
] call CBA_fnc_waitUntilAndExecute;

if (!isServer) exitWith {};

private _prevPfh = _uav getVariable ["DB_fpv_jammerPFH", -1];
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	_this params ["_args", "_handle"];
	_args params ["_uav"];

	if (isNull _uav) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};

	if (_uav getVariable ["DB_fpv_isUAVsignalLost", false]) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};

	private _jammers = (getPosWorld _uav) nearEntities [["Sania", "Sania_with_tripod"], 1000];
	private _isActive = (_jammers findIf { _x getVariable ["DB_jammer_isActive", false] }) >= 0;
	private _jammerTime = _uav getVariable ["DB_fpv_jammerTime", 0];

	if (_isActive) then {
		_jammerTime = _jammerTime + diag_deltaTime;
	} else {
		_jammerTime = 0;
	};

	_uav setVariable ["DB_fpv_jammerTime", _jammerTime, true];

	if (_isActive && { _jammerTime >= FPV_SIGNAL_LOSS_DURATION }) then {
		[objNull, _uav] call DB_fnc_fpv_onSignalLost;
		[_handle] call CBA_fnc_removePerFrameHandler;
	};
}, FPV_SIGNAL_UPDATE_INTERVAL, [_uav]] call CBA_fnc_addPerFrameHandler;

_uav setVariable ["DB_fpv_jammerPFH", _pfhId];
