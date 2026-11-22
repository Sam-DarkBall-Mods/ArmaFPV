/*
    DB_fnc_fpv_droneInit
    Marks a local Crocus for the jammer mod and applies the AI captive setting; runs on spawn and on locality change.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

params ["_uav"];

if (isNull _uav) exitWith {};
if (!local _uav) exitWith {};

[
	{
		params ["_uav"];
		if (isNull _uav || { !local _uav }) exitWith {};

		_uav setVariable ["DB_jammer_customUavBehavior", true, true];

		private _isCaptive = GETMVAR(FPV_isUavCaptive, true);
		_uav setCaptive _isCaptive;
	},
	[_uav]
] call CBA_fnc_execNextFrame;
