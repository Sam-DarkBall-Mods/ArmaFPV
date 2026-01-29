/*
	ArmaFPV: drone initialization.
	Purpose: disables AI and enables custom jammer behavior for the drone.
	Context: server/client when the drone is created.
	Params: [_uav]
		_uav - drone object.
	Returns: nothing.
*/

params ["_uav"];

if (isNull _uav) exitWith {};

waitUntil { time > 1 };

_uav disableAI "ALL";
_uav setVariable ["DB_jammer_customUavBehavior", true, true];
