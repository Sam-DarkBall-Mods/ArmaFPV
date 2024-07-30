params ["_uav"];

if (isNull _uav) exitWith {};
if !(typeOf _uav in ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP"]) exitWIth {};

cutText ["", "PLAIN"];

private _killer = driver _uav;
private _instigator = (UAVControl _uav) # 0;
private _missileType = "";
private _uavType = toLower (typeOf _uav);

if (_uavType find "at" > -1) then {
	_missileType = "FPV_RPG42_AT";
} else {
	if (_uavType find "ap" > -1) then {
		_missileType = "R_TBG32V_F";
	};
};

if (local _killer) then {
	_killer setCaptive false;
} else {
	[_killer, false] remoteExec ["setCaptive", 2];
};

private _missile = createVehicle [_missileType, _uav modelToWorld [0, 0, 0]];

_missile setVectorDirAndUp [vectorDir _uav, vectorUp _uav];

[_missile, [_killer, _instigator]] remoteExec ["setShotParents", 2];
[_missile, true] remoteExec ["hideObjectGlobal", 2];

deleteVehicle _uav;

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
