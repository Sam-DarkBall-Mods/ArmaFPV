#include "\ArmaFPV\script_macros.hpp"

private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
private _uav = getConnectedUAV _player;

if (isNull _player) exitWith {};
if (isNull _uav) exitWith {};

if (_uav isNil "DB_fpv_savedTime") then {
	_uav setVariable ["DB_fpv_savedTime", 0];
};

private _savedTime = _uav getVariable ["DB_fpv_savedTime", 0];
private _startTime = time - _savedTime;
private _syncInterval = GETMVAR(FPV_TimeSyncInterval, FPV_TIME_SYNC_INTERVAL);
private _publicSyncInterval = GETMVAR(FPV_TimePublicSyncInterval, 5);

private _prevPfh = GETMVAR(DB_fpv_timePFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _state = [_startTime, _uav, -1, _syncInterval, time, _publicSyncInterval];

private _pfhId = [{
	_this params ["_args", "_handle"];
	_args params ["_state"];
	_state params ["_startTime", "_uav", "_lastSync", "_syncInterval", "_lastPublicSync", "_publicSyncInterval"];

	if (isNull _uav) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};

	private _timeElapsed = time - _startTime;
	private _now = time;
	private _controlText = GETUVAR(ArmaFPV_TimeText, controlNull);

	if (!isNull _controlText) then {
		private _mins = floor (_timeElapsed / 60);
		private _secs = floor (_timeElapsed mod 60);
		private _mm = if (_mins < 10) then { format ["0%1", _mins] } else { str _mins };
		private _ss = if (_secs < 10) then { format ["0%1", _secs] } else { str _secs };
		_controlText ctrlSetText format ["%1:%2", _mm, _ss];
	};

	if ((_now - _lastSync) >= _syncInterval) then {
		_uav setVariable ["DB_fpv_savedTime", _timeElapsed];
		_state set [2, _now];

		if ((_now - _lastPublicSync) >= _publicSyncInterval) then {
			_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];
			_state set [4, _now];
		};
	};

	if !(GETMVAR(ArmaFPV_isControl, false)) exitWith {
		_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];
		[_handle] call CBA_fnc_removePerFrameHandler;
	};
}, 0, [_state]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_timePFH, _pfhId);
