/*
	ArmaFPV: FPV connection handler.
	Purpose: manages OSD lifecycle while controlling FPV drones.
	Context: client, runs post-init.
	Params: none.
	Returns: nothing.
*/

if (!hasInterface) exitWith {};

[] spawn {
private _droneTypes = missionNamespace getVariable ["DB_fpv_droneTypes", ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP", "O_Crocus_AT_TI", "O_Crocus_AP_TI", "B_Crocus_AT_TI", "B_Crocus_AP_TI", "I_Crocus_AT_TI", "I_Crocus_AP_TI"]];
	private _loopInterval = missionNamespace getVariable ["DB_fpv_connectLoopInterval", 0.1];

	while { true } do {
		private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

		if (isNull _player) then {
			sleep _loopInterval;
		} else {
			private _uav = getConnectedUAV _player;
			private _uavType = typeOf _uav;

			if ((_uavType in _droneTypes) && { cameraView == "GUNNER" } && { (typeOf cameraOn) in _droneTypes }) then {
				missionNamespace setVariable ["ArmaFPV_isControl", true];

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
