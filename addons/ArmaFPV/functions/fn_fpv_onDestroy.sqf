/*
	ArmaFPV: FPV drone detonation.
	Purpose: replaces the drone with a munition and triggers the explosion.
	Context: local where called (usually the operator client).
	Params: [_uav]
		_uav - FPV drone object.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

params ["_uav"];

if (isNull _uav) exitWith {};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, FPV_DRONE_TYPES);
if !(typeOf _uav in _droneTypes) exitWith {};
if (_uav getVariable ["DB_fpv_isDetonating", false]) exitWith {};
_uav setVariable ["DB_fpv_isDetonating", true, true];

cutText ["", "PLAIN"];

if (hasInterface) then {
	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	if (!isNull _player && { (getConnectedUAV _player) isEqualTo _uav }) then {
		call DB_fnc_fpv_destroyUI;
	};
};

private _killer = driver _uav;
private _instigator = (UAVControl _uav) # 0;
private _operator = _instigator;
private _missileType = "";
private _uavType = toLower (typeOf _uav);

if (isNull _operator && { hasInterface }) then {
	_operator = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
};

if (_uavType find "at" > -1) then {
	_missileType = "FPV_RPG42_AT";
};

if (_uavType find "ap" > -1) then {
	_missileType = "R_TBG32V_F";
};

if (_missileType isEqualTo "") exitWith {};

if (!isNull _killer) then {
	if (local _killer) then {
		_killer setCaptive false;
	} else {
		[_killer, false] remoteExec ["setCaptive", 2];
	};
};

private _missile = createVehicle [_missileType, _uav modelToWorld [0, 0, 0]];
_missile setVectorDirAndUp [vectorDir _uav, vectorUp _uav];

[_missile, [_killer, _instigator]] remoteExec ["setShotParents", 2];
[_missile, true] remoteExec ["hideObjectGlobal", 2];

{
	_uav deleteVehicleCrew _x;
} forEach crew _uav;

deleteVehicle _uav;

if (!isNull _operator && { isPlayer _operator }) then {
	[
		{
			params ["_operator"];
			if (!isNull _operator) then {
				[_operator, 1] remoteExecCall ["addScore", 2];
			};
		},
		[_operator],
		0.25
	] call CBA_fnc_waitAndExecute;
};

[
	{
		_this params ["_missile", "_shotParents"];
		(getShotParents _missile) isEqualTo _shotParents;
	},
	{
		_this params ["_missile"];
		triggerAmmo _missile;
	},
	[_missile, [_killer, _instigator]]
] call CBA_fnc_waitUntilAndExecute;
