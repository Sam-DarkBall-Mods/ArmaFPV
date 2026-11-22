/*
    DB_fnc_fpv_onDestroy
    Detonates a hit or killed Crocus: fires its warhead credited to the pilot, deletes the drone and cancels the aircraft loss score.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

params ["_uav"];

if (isNull _uav) exitWith {};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, FPV_DRONE_TYPES);
if !(typeOf _uav in _droneTypes) exitWith {};
if (_uav getVariable ["DB_fpv_isDetonating", false]) exitWith {};
_uav setVariable ["DB_fpv_isDetonating", true, true];

if (hasInterface) then {
	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	if (!isNull _player && { (getConnectedUAV _player) isEqualTo _uav }) then {
		call DB_fnc_fpv_destroyUI;
	};
};

private _controllers = UAVControl [_uav, "crew"];
if (_controllers isEqualTo []) then {
	_controllers = UAVControl [_uav, "allbutdead"];
};
private _instigator = _controllers param [0, objNull];
private _operator = _instigator;

if (isNull _operator && { hasInterface }) then {
	_operator = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
};
if (isNull _instigator) then {
	_instigator = _operator;
};

private _missileType = ["FPV_RPG42_AT", "R_TBG32V_F"] select ("_ap" in toLower typeOf _uav);
private _missile = createVehicle [_missileType, _uav modelToWorld [0, 0, 0]];
_missile setVectorDirAndUp [vectorDir _uav, vectorUp _uav];

private _shotParents = [_uav, _instigator];
[_missile, _shotParents] remoteExec ["setShotParents", 2];
[_missile, true] remoteExec ["hideObjectGlobal", 2];

[
	{
		_this params ["_missile", "_shotParents", "", "", "_deadline"];
		(getShotParents _missile) isEqualTo _shotParents || { diag_tickTime > _deadline };
	},
	{
		_this params ["_missile", "", "_uav", "_operator"];
		deleteVehicleCrew _uav;
		triggerAmmo _missile;
		deleteVehicle _uav;

		if (!isNull _operator && { isPlayer _operator }) then {
			[
				{
					params ["_operator"];
					if (!isNull _operator) then {
						[_operator] remoteExecCall ["DB_fnc_fpv_restoreDroneLossScore", 2];
					};
				},
				[_operator],
				0.25
			] call CBA_fnc_waitAndExecute;
		};
	},
	[_missile, _shotParents, _uav, _operator, diag_tickTime + 1]
] call CBA_fnc_waitUntilAndExecute;
