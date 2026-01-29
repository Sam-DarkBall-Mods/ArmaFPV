/*
	ArmaFPV: FPV connection handler.
	Purpose: manages UAV connectability and OSD lifecycle.
	Context: client, runs post-init.
	Params: none.
	Returns: nothing.
*/

if (!hasInterface) exitWith {};

[] spawn {
	private _droneTypes = missionNamespace getVariable ["DB_fpv_droneTypes", ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP"]];
	private _terminalTypes = missionNamespace getVariable ["DB_fpv_terminalTypes", ["B_UavTerminal", "O_UavTerminal", "I_UavTerminal"]];
	private _connectRange = missionNamespace getVariable ["DB_fpv_connectRange", 4000];
	private _loopInterval = missionNamespace getVariable ["DB_fpv_connectLoopInterval", 0.1];

	while { true } do {
		private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

		if (isNull _player) then {
			sleep _loopInterval;
		} else {
			private _assignedItems = assignedItems _player;
			private _hasTerminal = (_terminalTypes findIf { _x in _assignedItems }) != -1;

			if (_hasTerminal) then {
				private _drones = vehicles select { (typeOf _x) in _droneTypes };
				private _dronesNear = _player nearEntities [_droneTypes, _connectRange];

				{ _player disableUAVConnectability [_x, true]; } forEach (_drones - _dronesNear);

				{
					if (!(_x getVariable ["DB_fpv_isUAVsignalLost", false])) then {
						_player enableUAVConnectability [_x, true];
					};
				} forEach _dronesNear;
			};

			private _uav = getConnectedUAV _player;
			private _uavType = typeOf _uav;

			if ((_uavType in _droneTypes) && { cameraView == "GUNNER" } && { (typeOf cameraOn) in _droneTypes }) then {
				missionNamespace setVariable ["ArmaFPV_isControl", true];
				_uav setVariable ["DB_fpv_isUAVsignalLost", false];

				call DB_fnc_fpv_createDialog;

				waitUntil {
					!((typeOf (getConnectedUAV _player)) in _droneTypes)
					|| (cameraView != "GUNNER")
					|| !((typeOf cameraOn) in _droneTypes)
				};

				missionNamespace setVariable ["ArmaFPV_isControl", false];
				call DB_fnc_fpv_destroyUI;
			};

			sleep _loopInterval;
		};
	};
};

[] spawn {
	waitUntil { !isNull findDisplay 46 };

	findDisplay 46 displayAddEventHandler ["KeyDown", {
		private _handled = false;

		if (missionNamespace getVariable ["ArmaFPV_isControl", false]) then {
			if (inputAction "showMap" > 0) then {
				_handled = true;
			};
		};

		_handled;
	}];
};

[] spawn {
	private _droneTypes = missionNamespace getVariable ["DB_fpv_droneTypes", ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP"]];
	private _signalLossThreshold = missionNamespace getVariable ["DB_fpv_signalLossThreshold", 0.05];
	private _signalLossDuration = missionNamespace getVariable ["DB_fpv_signalLossDuration", 5];
	private _loopInterval = missionNamespace getVariable ["DB_fpv_connectLoopInterval", 0.1];
	private _signalDropTime = -1;

	while { true } do {
		private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
		private _uav = getConnectedUAV _player;

		if (!isNull _uav && { (typeOf _uav) in _droneTypes }) then {
			if (_uav getVariable ["DB_fpv_isUAVsignalLost", false]) then {
				_signalDropTime = -1;
			} else {
				private _uavSignal = [_player, _uav] call DB_fnc_fpv_getSignal;

				if (_uavSignal < _signalLossThreshold) then {
					if (_signalDropTime == -1) then {
						_signalDropTime = time;
					} else {
						private _currentTime = time - _signalDropTime;

						if (_currentTime >= _signalLossDuration) then {
							[_player, _uav] call DB_fnc_fpv_onSignalLost;
							_signalDropTime = -1;
						};
					};
				} else {
					_signalDropTime = -1;
				};
			};
		} else {
			_signalDropTime = -1;
		};

		sleep _loopInterval;
	};
};
