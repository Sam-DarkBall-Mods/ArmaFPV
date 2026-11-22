/*
    DDT_fnc_DeployUAV
    Wraps DDT drone deployment and sends FPV launches down the autonomy path when it is on.
    Author: DarkBall
*/

params ["_man", "_type"];

private _original = missionNamespace getVariable ["DDT_fnc_DeployUAV_original", {}];
if (_original isEqualTo {}) exitWith {};

private _t = toUpper _type;
if !(_t in ["FPV", "FPVAT"]) exitWith {
	_this call _original;
};

private _useAutonomy = _man getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
if (isPlayer _man && { !(missionNamespace getVariable ["sdbAutoAllowPlayers", true]) }) then { _useAutonomy = false; };
if !(_useAutonomy) exitWith {
	_this call _original;
};

private _autonomousDeploy = missionNamespace getVariable ["SDB_fnc_ddt_deployUAVAutonomy", {}];
if (_autonomousDeploy isEqualTo {}) exitWith {
	_this call _original;
};

_this call _autonomousDeploy;
