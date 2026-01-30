/*
	ArmaFPV: signal level handler.
	Purpose: updates the signal indicator and post-process effects based on link quality.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

[] spawn {
	private _loopInterval = missionNamespace getVariable ["DB_fpv_signalUpdateInterval", 0.2];

	private _stop = false;

	call DB_fnc_fpv_ppfx_start;

	while { (missionNamespace getVariable ["ArmaFPV_isControl", false]) && !_stop } do {
		private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
		private _uav = getConnectedUAV _player;

		if (isNull _player || { isNull _uav }) then {
			_stop = true;
		};

		if (!_stop) then {
			private _signal = [_player, _uav] call DB_fnc_fpv_getSignal;
			private _altitude = (getPosATL _uav) select 2;
			private _controlPicture = uiNameSpace getVariable ["ArmaFPV_SignalPicture", controlNull];
			private _controlText = uiNameSpace getVariable ["ArmaFPV_SignalText", controlNull];
			private _headingText = uiNameSpace getVariable ["ArmaFPV_HeadingText", controlNull];
			private _altText = uiNameSpace getVariable ["ArmaFPV_AltText", controlNull];
			private _rightText = uiNameSpace getVariable ["ArmaFPV_RightText", controlNull];
			private _distText = uiNameSpace getVariable ["ArmaFPV_DistText", controlNull];
			private _topLeftText = uiNameSpace getVariable ["ArmaFPV_TopLeftText", controlNull];
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

			if (!isNull _headingText) then {
				private _heading = (round (getDir _uav)) mod 360;
				private _hTxt = if (_heading < 10) then {
					format ["00%1", _heading]
				} else {
					if (_heading < 100) then { format ["0%1", _heading] } else { str _heading };
				};
				_headingText ctrlSetText _hTxt;
			};

			if (!isNull _altText) then {
				private _alt = (round _altitude) max 0;
				_altText ctrlSetText format ["%1", _alt];
			};

			if (!isNull _rightText) then {
				private _distFt = round ((_player distance _uav) * 3.28084);
				_rightText ctrlSetText format ["%1", _distFt];
			};

			if (!isNull _distText) then {
				private _dist = round ((_player distance _uav) * 3.28084);
				_distText ctrlSetText format ["%1ft", _dist];
			};

			if (!isNull _topLeftText) then {
				private _altDec = (round (_altitude * 10)) / 10;
				_topLeftText ctrlSetText format ["%1m", _altDec];
			};


			private _distance = _player distance _uav;
			private _maxDistance = missionNamespace getVariable ["FPV_MaxFlightDistance", 4000];
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
