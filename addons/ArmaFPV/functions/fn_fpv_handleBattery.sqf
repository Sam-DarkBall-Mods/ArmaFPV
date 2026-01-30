/*
	ArmaFPV: battery indicator handler.
	Purpose: updates the battery icon and percentage on the OSD.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _prevPfh = GETMVAR(DB_fpv_batteryPFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	_this params ["_args", "_handle"];
	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	private _uav = getConnectedUAV _player;

	if (isNull _player || { isNull _uav }) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};

	private _currentBattery = fuel _uav;
	private _leftVolt = GETUVAR(ArmaFPV_LeftVoltText, controlNull);
	private _leftCurrent = GETUVAR(ArmaFPV_LeftCurrentText, controlNull);
	private _leftMah = GETUVAR(ArmaFPV_LeftMahText, controlNull);
	private _rightVolt = GETUVAR(ArmaFPV_RightVoltText, controlNull);
	private _batteryPicture = GETUVAR(ArmaFPV_BatteryPicture, controlNull);
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

	if !(GETMVAR(ArmaFPV_isControl, false)) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};
}, 0, []] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_batteryPFH, _pfhId);
