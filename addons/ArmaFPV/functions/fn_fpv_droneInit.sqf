/*
	ArmaFPV: drone initialization.
	Purpose: disables AI and enables custom jammer behavior for the drone.
	Context: server/client when the drone is created.
	Params: [_uav]
		_uav - drone object.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

params ["_uav"];

if (isNull _uav) exitWith {};

if (isNil "cba_common_waitUntilAndExecArray") exitWith {
	_uav disableAI "ALL";
	_uav setVariable ["DB_jammer_customUavBehavior", true, true];
};

[
	{
		params ["_uav"];
		!isNull _uav
	},
	{
		params ["_uav"];
		_uav disableAI "ALL";
		_uav setVariable ["DB_jammer_customUavBehavior", true, true];
	},
	[_uav]
] call CBA_fnc_waitUntilAndExecute;
