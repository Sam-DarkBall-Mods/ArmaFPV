/*
	ArmaFPV: signal level handler.
	Purpose: updates the signal indicator and post-process effects based on link quality.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _loopInterval = GETMVAR(DB_fpv_signalUpdateInterval, FPV_SIGNAL_UPDATE_INTERVAL);
private _state = [
	diag_tickTime,
	1
];

call DB_fnc_fpv_ppfx_start;

private _prevPfh = GETMVAR(DB_fpv_signalPFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	_this params ["_args", "_handle"];
	_args params ["_loopInterval", "_state"];

	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	private _uav = getConnectedUAV _player;

	if (isNull _player || { isNull _uav } || { !(GETMVAR(ArmaFPV_isControl, false)) }) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
		call DB_fnc_fpv_ppfx_stop;
	};

	private _now = diag_tickTime;
	private _lastUpdate = _state # 0;
	private _signal = _state # 1;
	private _doUpdate = (_now - _lastUpdate) >= _loopInterval;

	private _altitude = (getPosATL _uav) select 2;
	private _controlPicture = GETUVAR(ArmaFPV_SignalPicture, controlNull);
	private _controlText = GETUVAR(ArmaFPV_SignalText, controlNull);
	private _headingText = GETUVAR(ArmaFPV_HeadingText, controlNull);
	private _compassGroup = GETUVAR(ArmaFPV_CompassGroup, controlNull);
	private _compassN = GETUVAR(ArmaFPV_CompassN, controlNull);
	private _compassE = GETUVAR(ArmaFPV_CompassE, controlNull);
	private _compassS = GETUVAR(ArmaFPV_CompassS, controlNull);
	private _compassW = GETUVAR(ArmaFPV_CompassW, controlNull);
	private _vBarLeft = GETUVAR(ArmaFPV_VBarLeft, controlNull);
	private _vBarRight = GETUVAR(ArmaFPV_VBarRight, controlNull);
	private _vPointerLeft = GETUVAR(ArmaFPV_VPointerLeft, controlNull);
	private _vPointerRight = GETUVAR(ArmaFPV_VPointerRight, controlNull);
	private _altText = GETUVAR(ArmaFPV_AltText, controlNull);
	private _rightText = GETUVAR(ArmaFPV_RightText, controlNull);
	private _distText = GETUVAR(ArmaFPV_DistText, controlNull);
	private _heading = (round (getDir _uav)) mod 360;
	private _distance = _player distance _uav;
	private _distanceFt = _distance * FPV_FEET_PER_METER;
	private _speedFtH = (vectorMagnitude (velocity _uav)) * FPV_FEET_PER_METER * 3600;
	private _speedDisplay = round (_speedFtH / FPV_SPEED_SCALE);

	if (_doUpdate) then {
		_signal = [_player, _uav] call DB_fnc_fpv_getSignal;
		_state set [0, _now];
		_state set [1, _signal];

		private _picture = "";
		switch (true) do {
			case (_signal > 0.75): { _picture = "\ArmaFPV\pictures\100.paa"; };
			case (_signal > 0.5): { _picture = "\ArmaFPV\pictures\75.paa"; };
			case (_signal > 0.25): { _picture = "\ArmaFPV\pictures\50.paa"; };
			case (_signal > 0): { _picture = "\ArmaFPV\pictures\25.paa"; };
			case (_signal <= 0): { _picture = "\ArmaFPV\pictures\0.paa"; };
			default { _picture = "\ArmaFPV\pictures\100.paa"; };
		};

		if (!isNull _controlPicture) then {
			_controlPicture ctrlSetText _picture;
		};

		if (!isNull _controlText) then {
			_controlText ctrlSetText str(round(_signal * 100));
		};

		private _maxDistance = GETMVAR(FPV_MaxFlightDistance, 4000);
		private _inJammer = GETMVAR(DB_timeInJammerZone, 0) > 0;
		private _obstacles = GETMVAR(DB_fpv_signal_obstacles, 0);
		private _terrainMask = GETMVAR(DB_fpv_signal_terrainMask, 0);

		private _context = [
			"altAGL", _altitude,
			"distance", _distance,
			"maxDistance", _maxDistance,
			"inJammer", _inJammer,
			"obstacleCount", _obstacles,
			"terrainMask", _terrainMask
		];

		[_signal, _context] call DB_fnc_fpv_ppfx_setInput;
	};

	if (!isNull _headingText) then {
		private _hTxt = if (_heading < 10) then {
			format ["00%1", _heading]
		} else {
			if (_heading < 100) then { format ["0%1", _heading] } else { str _heading };
		};
		_headingText ctrlSetText _hTxt;
	};

	if (!isNull _compassGroup) then {
		private _groupPos = ctrlPosition _compassGroup;
		private _groupW = _groupPos # 2;
		private _centerX = _groupW / 2;
		private _halfW = _groupW / 2;
		private _letters = [
			[_compassN, 0],
			[_compassE, 90],
			[_compassS, 180],
			[_compassW, 270]
		];

		{
			private _ctrl = _x # 0;
			private _angle = _x # 1;

			if (!isNull _ctrl) then {
				private _pos = ctrlPosition _ctrl;
				private _w = _pos # 2;
				private _h = _pos # 3;
				private _y = _pos # 1;
				private _offset = ((_angle - _heading + 540) mod 360) - 180;
				private _xPos = _centerX + (_offset / 180) * _halfW - (_w / 2);

				_ctrl ctrlSetPosition [_xPos, _y, _w, _h];
				_ctrl ctrlCommit 0;
			};
		} forEach _letters;
	};

	if (!isNull _altText) then {
		private _alt = (round _altitude) max 0;
		_altText ctrlSetText format ["%1", _alt];
	};

	if (!isNull _rightText) then {
		_rightText ctrlSetText format ["%1", _speedDisplay];
	};

	if (!isNull _distText) then {
		_distText ctrlSetText format ["%1ft", round _distanceFt];
	};

	if (!isNull _vBarLeft && !isNull _vPointerLeft) then {
		private _barPos = ctrlPosition _vBarLeft;
		private _barY = _barPos # 1;
		private _barH = _barPos # 3;
		private _ptrPos = ctrlPosition _vPointerLeft;
		private _ptrW = _ptrPos # 2;
		private _ptrH = _ptrPos # 3;
		private _altClamp = (_altitude max 0) min FPV_ALT_MAX;
		private _altNorm = _altClamp / FPV_ALT_MAX;
		private _yPos = _barY + (_barH * (1 - _altNorm)) - (_ptrH / 2);

		_vPointerLeft ctrlSetPosition [_ptrPos # 0, _yPos, _ptrW, _ptrH];
		_vPointerLeft ctrlCommit 0;
	};

	if (!isNull _vBarRight && !isNull _vPointerRight) then {
		private _barPos = ctrlPosition _vBarRight;
		private _barY = _barPos # 1;
		private _barH = _barPos # 3;
		private _ptrPos = ctrlPosition _vPointerRight;
		private _ptrW = _ptrPos # 2;
		private _ptrH = _ptrPos # 3;
		private _speedClamp = (_speedDisplay max 0) min FPV_SPEED_MAX;
		private _speedNorm = _speedClamp / FPV_SPEED_MAX;
		private _yPos = _barY + (_barH * (1 - _speedNorm)) - (_ptrH / 2);

		_vPointerRight ctrlSetPosition [_ptrPos # 0, _yPos, _ptrW, _ptrH];
		_vPointerRight ctrlCommit 0;
	};
}, 0, [_loopInterval, _state]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_signalPFH, _pfhId);
