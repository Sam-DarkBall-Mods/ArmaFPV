/*
	ArmaFPV: signal level handler.
	Purpose: updates the signal indicator and post-process effects based on link quality.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

[] spawn {
	private _weakSignalDuration = 0;
	private _specialEffectTime = 0;
	private _specialEffects = [];
	private _loopInterval = missionNamespace getVariable ["DB_fpv_signalUpdateInterval", 0.2];
	private _signalLossThreshold = missionNamespace getVariable ["DB_fpv_signalLossThreshold", 0.05];
	private _signalLossDuration = missionNamespace getVariable ["DB_fpv_signalLossDuration", 5];

	private _stop = false;

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
			private _altitude = (getPos _uav) select 2;
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

			if (_signal < 0.3 && _altitude < 20) then {
				private _randomChance = random 1;

				if (_randomChance > 0.9 && _specialEffectTime <= 0) then {
					private _fxColor = ppEffectCreate ["ColorCorrections", 1500];
					_fxColor ppEffectEnable true;
					_fxColor ppEffectAdjust [1.08, 0.67, 0.06, [0, 0, 0.45, 0.06], [1, 1, 0.93, 1.61], [0.33, 0.33, 0.15, 0.2], [0, 0, 0, 0, 0, 0, 5]];
					_fxColor ppEffectCommit 0;

					private _fxDynamic = ppEffectCreate ["DynamicBlur", 500];
					_fxDynamic ppEffectEnable true;
					_fxDynamic ppEffectAdjust [0.4];
					_fxDynamic ppEffectCommit 0;

					private _fxFilm = ppEffectCreate ["FilmGrain", 2000];
					_fxFilm ppEffectEnable true;
					_fxFilm ppEffectAdjust [1, 0.47, 4.26, 0.5, 0.5, true];
					_fxFilm ppEffectCommit 0;

					_specialEffects = [_fxColor, _fxDynamic, _fxFilm];
					missionNamespace setVariable ["DB_fpv_specialEffects", _specialEffects];
					_specialEffectTime = 2;
				};
			};

			if (_specialEffectTime > 0) then {
				_specialEffectTime = _specialEffectTime - _loopInterval;

				if (_specialEffectTime <= 0) then {
					{ ppEffectDestroy _x; } forEach _specialEffects;
					_specialEffects = [];
					missionNamespace setVariable ["DB_fpv_specialEffects", _specialEffects];
				};
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

			private _ppEffect = missionNamespace getVariable ["DB_fpv_ppEffect", []];
			private _adjust = linearConversion [1, 0, _signal, 0.1, 1.0];

			if (_ppEffect isNotEqualTo []) then {
				{ ppEffectDestroy _x; } forEach _ppEffect;
			};

			private _ppColor = ppEffectCreate ["ColorCorrections", 1500];
			_ppColor ppEffectEnable true;
			_ppColor ppEffectAdjust [[1.08, 1.2, _adjust] call BIS_fnc_lerp, [0.67, 1, _adjust] call BIS_fnc_lerp, 0.06, [0, 0, 0.45, 0.06], [1, 1, 0.93, 1.61], [0.33, 0.33, 0.15, 0.2], [0, 0, 0, 0, 0, 0, 5]];
			_ppColor ppEffectCommit 0;

			private _ppDynamic = ppEffectCreate ["DynamicBlur", 500];
			_ppDynamic ppEffectEnable true;
			_ppDynamic ppEffectAdjust [[0.2, 0.7, _adjust] call BIS_fnc_lerp];
			_ppDynamic ppEffectCommit 0;

			private _ppFilm = ppEffectCreate ["FilmGrain", 2000];
			_ppFilm ppEffectEnable true;
			_ppFilm ppEffectAdjust [[0.04, 1, _adjust] call BIS_fnc_lerp, 1, [4.09, 4.5, _adjust] call BIS_fnc_lerp, 0.5, 0.5, true];
			_ppFilm ppEffectCommit 0;

			missionNamespace setVariable ["DB_fpv_ppEffect", [_ppColor, _ppDynamic, _ppFilm]];

			sleep _loopInterval;
		};
	};

	if (_specialEffects isNotEqualTo []) then {
		{ ppEffectDestroy _x; } forEach _specialEffects;
	};

	missionNamespace setVariable ["DB_fpv_specialEffects", []];
};
