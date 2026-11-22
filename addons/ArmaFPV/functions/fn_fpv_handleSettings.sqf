/*
    DB_fnc_fpv_handleSettings
    Applies the CBA settings: the OSD craft name and AI captivity of local Crocus drones.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

private _defaultText = GETMVAR(FPV_DefaultText, "CROCUS");
private _isCaptive = GETMVAR(FPV_isUavCaptive, true);

if (hasInterface) then {
	private _textControl = GETUVAR(ArmaFPV_DefaultText, controlNull);
	if (!isNull _textControl) then {
		_textControl ctrlSetText _defaultText;
	};
};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, FPV_DRONE_TYPES);
{
	if (local _x) then {
		_x setCaptive _isCaptive;
	};
} forEach (vehicles select { (typeOf _x) in _droneTypes });
