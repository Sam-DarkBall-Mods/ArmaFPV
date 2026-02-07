/*
	Autonomous DeployUAV path.
	Purpose: spawn the drone like DDT, but run SDB autonomous FPV loop for FPV/FPVAT.
*/

params ["_man", "_type"];

if !(simulationEnabled _man) exitWith {};

if (ddtDebug) then {
	private _t = format ["%1 deploying %2 (autonomy)", _man, _type];
	_t call DDT_fnc_Debug;
};

private _droneClass = [_man, _type] call DDT_fnc_ManGetUAV;
if (_droneClass == "") exitWith {};
if (_droneClass == "1Rnd_RC40_shell_RF") exitWith {
	_man setUnitPos "MIDDLE";
	[_man, _man] spawn lxRF_fnc_RC40_recon;
};
if (_droneClass == "1Rnd_RC40_HE_shell_RF") exitWith {};

(group _man) setVariable ["Vcm_Disable", true, true];

_man forceSpeed 0;
[_man, "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_1"] remoteExec ["playMoveNow", _man];

private _fn_finishDeploy = {
	params ["_man", "_type", "_droneClass"];
	if !(alive _man) exitWith {};

	private _packType = "";
	private _magType = "";
	private _itemType = "";

	if (_man getVariable ["ddtRemovePack", false]) then {
		_man setVariable ["ddtRemovePack", false, true];
		_packType = backpack _man;
		removeBackpackGlobal _man;
		[_man] spawn DDT_fnc_RemovePack;
	};

	private _mag = _man getVariable ["ddtRemoveMag", ""];
	if !(_mag == "") then {
		_man removeMagazine _mag;
		_man setVariable ["ddtRemoveMag", "", true];
	};

	private _item = _man getVariable ["ddtRemoveItem", ""];
	if !(_item == "") then {
		_man removeItem _item;
		_man setVariable ["ddtRemoveItem", "", true];
	};

	[_man, "AmovPercMstpSlowWrflDnon"] remoteExec ["playMoveNow", _man];

	private _pos = getPos _man;
	private _foundPos = false;
	for "_distance" from 1 to 10 do {
		private _probePos = _pos getPos [_distance, getDir _man];
		if !((ATLtoASL _probePos) call DDT_fnc_PosIsInside) exitWith {
			_pos = _probePos;
			_foundPos = true;
		};
	};
	if (!_foundPos) then {
		_pos = [_pos, 1, 50, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	};

	private _switchBlades = [
		"SwitchBlade_300_Tube_Desert",
		"SwitchBlade_600_Tube_Desert",
		"SwitchBlade_300_Tube_Woodland",
		"SwitchBlade_600_Tube_Woodland"
	];

	if ([[_droneClass], _switchBlades] call DDT_fnc_InArray) exitWith {
		[_man, _pos, _droneClass] execVM "DrongosDroneTweaks\Scripts\Misc\SwitchBlade.sqf";
	};

	private _drone = _droneClass createVehicle _pos;
	createVehicleCrew _drone;
	(group _drone) setVariable ["daoExclude", true, true];
	(group _drone) setVariable ["dceExclude", true, true];

	if (ddtDebug) then {
		(format ["%1 deployed %2 (%3) [autonomy]", _man, _droneClass, _drone]) call DDT_fnc_debug;
	};

	if !((side _drone) == (side _man)) then {
		private _side = side _man;
		(crew _drone) joinSilent (createGroup _side);
		(group _drone) setVariable ["daoExclude", true, true];
		(group _drone) setVariable ["dceExclude", true, true];
	};

	_drone setVariable ["lambs_danger_disableai", true, true];
	(group _drone) setVariable ["lambs_Danger_disableGroupAI", true, true];
	(group _drone) setVariable ["Vcm_Disable", true, true];
	_drone setVariable ["ddtPackType", _packType, true];
	_drone setVariable ["ddtMagType", _magType, true];
	_drone setVariable ["ddtItemType", _itemType, true];
	_drone setVariable ["ddtOwner", str _man, true];
	_drone setVariable ["SDB_autonomyEnabled", true, true];

	_man forceSpeed -1;
	_drone setVariable ["ddtTasked", true, true];
	(leader (group _drone)) action ["CollisionLightOff", _drone];
	_drone disableAI "LIGHTS";
	_drone setPilotLight false;
	_drone setCombatMode "BLUE";
	_drone setBehaviour "AWARE";

	[_drone, _man] spawn DDT_fnc_ReportContacts;

	if (_type == "FPV" || {_type == "FPVAT"}) exitWith {
		private _autonomyStart = missionNamespace getVariable ["SDB_fnc_fpvAutonomyStart", {}];
		if (_autonomyStart isEqualTo {}) exitWith {
			[_drone, _man] execVM "\SDB_InteropTweaks\Scripts\DDT\AI_FPV_Autonomy.sqf";
		};
		[_drone, _man] call _autonomyStart;
	};
	if (_type == "BOMBER") exitWith {
		[_drone, _man] execVM "DrongosDroneTweaks\Scripts\Drones\AI_Bomber.sqf";
	};
	if (_type == "UGV") exitWith {
		[_drone, _man] execVM "DrongosDroneTweaks\Scripts\Drones\AI_UGV.sqf";
	};

	if ((random 100) < (missionNamespace getVariable ["ddtLoiterChance", 50])) then {
		[_drone, _man] execVM "DrongosDroneTweaks\Scripts\Drones\AI_Loiter.sqf";
	} else {
		[_drone, _man] execVM "DrongosDroneTweaks\Scripts\Drones\AI_Recon.sqf";
	};
};

[
	{
		params ["_args"];
		_args params ["_fn_finishDeploy", "_man", "_type", "_droneClass"];
		[_man, _type, _droneClass] call _fn_finishDeploy;
	},
	[_fn_finishDeploy, _man, _type, _droneClass],
	1
] call CBA_fnc_waitAndExecute;
