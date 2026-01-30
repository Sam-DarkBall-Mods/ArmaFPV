/*
	ArmaFPV: flight time timer.
	Purpose: shows the control time on the OSD.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
private _uav = getConnectedUAV _player;

if (isNull _player) exitWith {};
if (isNull _uav) exitWith {};

if (isNil { _uav getVariable ["DB_fpv_savedTime", nil] }) then {
	_uav setVariable ["DB_fpv_savedTime", 0];
};

private _savedTime = _uav getVariable ["DB_fpv_savedTime", 0];
private _startTime = time - _savedTime;

private _prevPfh = GETMVAR(DB_fpv_timePFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	_this params ["_args", "_handle"];
	_args params ["_startTime", "_uav"];

	if (isNull _uav) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};

	private _timeElapsed = time - _startTime;
	private _controlText = GETUVAR(ArmaFPV_TimeText, controlNull);

	if (!isNull _controlText) then {
		private _mins = floor (_timeElapsed / 60);
		private _secs = floor (_timeElapsed mod 60);
		private _mm = if (_mins < 10) then { format ["0%1", _mins] } else { str _mins };
		private _ss = if (_secs < 10) then { format ["0%1", _secs] } else { str _secs };
		_controlText ctrlSetText format ["%1:%2", _mm, _ss];
	};

	_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];

	if !(GETMVAR(ArmaFPV_isControl, false)) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};
}, 0, [_startTime, _uav]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_timePFH, _pfhId);
