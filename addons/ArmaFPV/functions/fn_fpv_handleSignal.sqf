/*
	ArmaFPV: signal level handler.
	Purpose: updates the signal indicator and post-process effects based on link quality.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

[] spawn {
	private _weakSignalDuration = 0;
	private _loopInterval = missionNamespace getVariable ["DB_fpv_signalUpdateInterval", 0.2];
	private _signalLossThreshold = missionNamespace getVariable ["DB_fpv_signalLossThreshold", 0.05];
	private _signalLossDuration = missionNamespace getVariable ["DB_fpv_signalLossDuration", 5];

	private _stop = false;

	call DB_fnc_fpv_ppfx_start;

	while { (missionNamespace getVariable ["ArmaFPV_isControl", false]) && !_stop } do {
		private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
		private _uav = getConnectedUAV _player;

		if (isNull _player || { isNull _uav }) then {
			_stop = true;
		};

		if (!_stop && { _uav getVariable ["DB_fpv_isUAVsignalLost", false] }) then {
			_stop = true;
		};

		if (!_stop) then {
			private _signal = [_player, _uav] call DB_fnc_fpv_getSignal;
			private _altitude = (getPosATL _uav) select 2;
			private _controlPicture = uiNameSpace getVariable ["ArmaFPV_SignalPicture", controlNull];
			private _controlText = uiNameSpace getVariable ["ArmaFPV_SignalText", controlNull];
			private _picture = "";

			if (_signal < _signalLossThreshold) then {
				_weakSignalDuration = _weakSignalDuration + _loopInterval;
				if (_weakSignalDuration >= _signalLossDuration) then {
					[_player, _uav] call DB_fnc_fpv_onSignalLost;
					_weakSignalDuration = 0;
				};
			} else {
				_weakSignalDuration = 0;
			};

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

			private _distance = _player distance _uav;
			private _maxDistance = missionNamespace getVariable ["FPV_MaxFlightDistance", 1500];
			private _inJammer = (missionNamespace getVariable ["DB_timeInJammerZone", 0]) > 0;
			private _obstacles = missionNamespace getVariable ["DB_fpv_signal_obstacles", 0];
			private _terrainMask = missionNamespace getVariable ["DB_fpv_signal_terrainMask", 0];

			private _context = [
				"altAGL", _altitude,
				"distance", _distance,
				"maxDistance", _maxDistance,
				"inJammer", _inJammer,
				"obstacleCount", _obstacles,
				"terrainMask", _terrainMask
			];

			[_signal, _context] call DB_fnc_fpv_ppfx_setInput;

			sleep _loopInterval;
		};
	};

	call DB_fnc_fpv_ppfx_stop;
};
