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
			private _compassGroup = uiNameSpace getVariable ["ArmaFPV_CompassGroup", controlNull];
			private _compassN = uiNameSpace getVariable ["ArmaFPV_CompassN", controlNull];
			private _compassE = uiNameSpace getVariable ["ArmaFPV_CompassE", controlNull];
			private _compassS = uiNameSpace getVariable ["ArmaFPV_CompassS", controlNull];
			private _compassW = uiNameSpace getVariable ["ArmaFPV_CompassW", controlNull];
			private _vBarLeft = uiNameSpace getVariable ["ArmaFPV_VBarLeft", controlNull];
			private _vBarRight = uiNameSpace getVariable ["ArmaFPV_VBarRight", controlNull];
			private _vPointerLeft = uiNameSpace getVariable ["ArmaFPV_VPointerLeft", controlNull];
			private _vPointerRight = uiNameSpace getVariable ["ArmaFPV_VPointerRight", controlNull];
			private _altText = uiNameSpace getVariable ["ArmaFPV_AltText", controlNull];
			private _rightText = uiNameSpace getVariable ["ArmaFPV_RightText", controlNull];
			private _distText = uiNameSpace getVariable ["ArmaFPV_DistText", controlNull];
			private _topLeftText = uiNameSpace getVariable ["ArmaFPV_TopLeftText", controlNull];
			private _picture = "";
			private _heading = (round (getDir _uav)) mod 360;

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
				private _speedFtH = (vectorMagnitude (velocity _uav)) * 3.28084 * 3600;
				private _speedDisplay = round (_speedFtH / 100);
				_rightText ctrlSetText format ["%1", _speedDisplay];
			};

			if (!isNull _distText) then {
				private _dist = round ((_player distance _uav) * 3.28084);
				_distText ctrlSetText format ["%1ft", _dist];
			};

			if (!isNull _vBarLeft && !isNull _vPointerLeft) then {
				private _barPos = ctrlPosition _vBarLeft;
				private _barY = _barPos # 1;
				private _barH = _barPos # 3;
				private _ptrPos = ctrlPosition _vPointerLeft;
				private _ptrW = _ptrPos # 2;
				private _ptrH = _ptrPos # 3;
				private _altClamp = (_altitude max 0) min 120;
				private _altNorm = _altClamp / 120;
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
				private _speedFtH = (vectorMagnitude (velocity _uav)) * 3.28084 * 3600;
				private _speedDisplay = _speedFtH / 100;
				private _speedClamp = (_speedDisplay max 0) min 3000;
				private _speedNorm = _speedClamp / 3000;
				private _yPos = _barY + (_barH * (1 - _speedNorm)) - (_ptrH / 2);

				_vPointerRight ctrlSetPosition [_ptrPos # 0, _yPos, _ptrW, _ptrH];
				_vPointerRight ctrlCommit 0;
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
