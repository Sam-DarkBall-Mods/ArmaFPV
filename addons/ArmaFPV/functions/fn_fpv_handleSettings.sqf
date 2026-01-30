/*
	ArmaFPV: apply UI/UAV settings.
	Purpose: updates OSD text and captive mode for FPV drones.
	Context: client or server when settings change or UI starts.
	Params: none.
	Returns: nothing.
*/

private _defaultText = missionNamespace getVariable ["FPV_DefaultText", "CROCUS"];
private _isCaptive = missionNamespace getVariable ["FPV_isUavCaptive", true];
private _textArray = toArray _defaultText;
private _allowedChars = toArray "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,;\\/ ";

private _isValid = true;
{
	if !(_x in _allowedChars) exitWith { _isValid = false; };
} forEach _textArray;

if (hasInterface) then {
	private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
	private _mainText = uiNameSpace getVariable ["ArmaFPV_MainText", controlNull];

	if (!isNull _mainText && { !isNull _player }) then {
		if (_isValid) then {
			_mainText ctrlSetText _defaultText;
		} else {
			_mainText ctrlSetText "";
		};
	};
};

private _droneTypes = missionNamespace getVariable ["DB_fpv_droneTypes", []];
if (_droneTypes isEqualTo []) exitWith {};

{
	_x setCaptive _isCaptive;
} forEach (vehicles select { (typeOf _x) in _droneTypes });
