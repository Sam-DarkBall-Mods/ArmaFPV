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
	private _leftVolt = uiNameSpace getVariable ["ArmaFPV_LeftVoltText", controlNull];
	private _leftCurrent = uiNameSpace getVariable ["ArmaFPV_LeftCurrentText", controlNull];
	private _leftMah = uiNameSpace getVariable ["ArmaFPV_LeftMahText", controlNull];
	private _rightVolt = uiNameSpace getVariable ["ArmaFPV_RightVoltText", controlNull];
	private _batteryPicture = uiNameSpace getVariable ["ArmaFPV_BatteryPicture", controlNull];
	private _picture = "";

	switch (true) do {
		case (_currentBattery > 0.75): { _picture = "\ArmaFPV\pictures\A100.paa" };
		case (_currentBattery > 0.5): { _picture = "\ArmaFPV\pictures\A75.paa" };
		case (_currentBattery > 0.25): { _picture = "\ArmaFPV\pictures\A50.paa" };
		case (_currentBattery > 0): { _picture = "\ArmaFPV\pictures\A25.paa" };
		case (_currentBattery <= 0): { _picture = "\ArmaFPV\pictures\A0.paa" };
		default { _picture = "\ArmaFPV\pictures\A75.paa" };
	};

	private _volt = (12 + (_currentBattery * 4.8));
	private _cur = (5 + ((1 - _currentBattery) * 10));
	private _mah = round (2000 + ((1 - _currentBattery) * 800));
	private _voltRight = (10 + (_currentBattery * 4.0));
	private _voltTxt = str ((round (_volt * 10)) / 10);
	private _curTxt = str ((round (_cur * 10)) / 10);
	private _voltRightTxt = str ((round (_voltRight * 10)) / 10);

	if (!isNull _leftVolt) then {
		_leftVolt ctrlSetText format ["%1V", _voltTxt];
	};

	if (!isNull _leftCurrent) then {
		_leftCurrent ctrlSetText format ["%1A", _curTxt];
	};

	if (!isNull _leftMah) then {
		_leftMah ctrlSetText format ["%1mAh", _mah];
	};

	if (!isNull _rightVolt) then {
		_rightVolt ctrlSetText format ["%1V", _voltRightTxt];
	};

	if (!isNull _batteryPicture) then {
		_batteryPicture ctrlSetText _picture;
	};

	if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
}];
