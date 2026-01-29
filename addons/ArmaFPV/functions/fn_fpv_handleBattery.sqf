/*
	ArmaFPV: battery indicator handler.
	Purpose: updates the battery icon and percentage on the OSD.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

addMissionEventHandler ["EachFrame", {
	private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
	private _uav = getConnectedUAV _player;

	if (isNull _player) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};

	if (isNull _uav) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};

	private _currentBattery = fuel _uav;
	private _controlPicture = uiNameSpace getVariable ["ArmaFPV_BatteryPicture", controlNull];
	private _controlText = uiNameSpace getVariable ["ArmaFPV_BatteryText", controlNull];
	private _picture = "";

	switch (true) do {
		case (_currentBattery > 0.75): { _picture = "\ArmaFPV\pictures\A100.paa" };
		case (_currentBattery > 0.5): { _picture = "\ArmaFPV\pictures\A75.paa" };
		case (_currentBattery > 0.25): { _picture = "\ArmaFPV\pictures\A50.paa" };
		case (_currentBattery > 0): { _picture = "\ArmaFPV\pictures\A25.paa" };
		case (_currentBattery <= 0): { _picture = "\ArmaFPV\pictures\A0.paa" };
		default { _picture = "\ArmaFPV\pictures\A75.paa" };
	};

	if (!isNull _controlPicture) then {
		_controlPicture ctrlSetText _picture;
	};

	if (!isNull _controlText) then {
		_controlText ctrlSetText str(round(_currentBattery * 100));
	};

	if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
}];
