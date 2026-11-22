/*
    DB_fnc_fpv_ppfx_update
    Analog video look at the PAL frame rate: a soft picture whose colour fades, line snow and sparkles over the OSD, line tears and rolling frames as the link degrades.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};
if (!(GETMVAR(DB_fpv_ppfx_active, false))) exitWith {};

private _now = diag_tickTime;
if (_now < GETMVAR(DB_fpv_ppfx_nextFrame, 0)) exitWith {};
private _dt = (_now - GETMVAR(DB_fpv_ppfx_lastFrame, _now)) min 0.25;
SETMVAR(DB_fpv_ppfx_lastFrame, _now);
SETMVAR(DB_fpv_ppfx_nextFrame, _now + FPV_FX_FRAME);

(GETMVAR(DB_fpv_ppfx_handles, [])) params [["_fxColor", -1], ["_fxGrain", -1], ["_fxBlur", -1], ["_fxChrom", -1], "", ["_fxWet", -1]];

private _q = (GETMVAR(DB_fpv_ppfx_input, 1) max 0) min 1;
private _qDrop = GETMVAR(DB_fpv_ppfx_drop, 0);
SETMVAR(DB_fpv_ppfx_drop, (_qDrop - _dt * 1.5) max 0);

private _ctx = GETMVAR(DB_fpv_ppfx_context, []);
private _get = {
	params ["_key", "_default"];
	private _i = _ctx find _key;
	[_default, _ctx param [_i + 1, _default]] select (_i >= 0)
};
private _multipath = ((["obstacleCount", 0] call _get) min 10) / 20
	+ ((["terrainMask", 0] call _get) min 1) * 0.5
	+ ((1 - (["altAGL", 100] call _get) / 8) max 0) * 0.3;

private _ramp = {
	params ["_hi", "_lo"];
	private _t = (((_hi - _q) / (_hi - _lo)) max 0) min 1;
	_t * _t * (3 - 2 * _t)
};

(GETMVAR(DB_fpv_ppfx_glitch, [])) params [["_type", ""], ["_start", 0], ["_end", 0]];
if (_now >= _end) then { _type = ""; };
if (_type == "") then {
	private _burst = 1.5 * ([0.85, 0.3] call _ramp) + 2.5 * _multipath * (1 - _q);
	private _tearRate = 2.5 * ([0.7, 0.25] call _ramp) + 1.5 * _multipath * (1 - _q);
	private _rollRate = 1.2 * ([0.4, 0.12] call _ramp);
	private _total = _burst + _tearRate + _rollRate;
	private _pick = random _total;
	if (_qDrop >= 0.08 && { _q < 0.85 }) then {
		_pick = 0;
		_total = 1e6;
		SETMVAR(DB_fpv_ppfx_drop, 0);
	};
	if (random 1 < _total * _dt) then {
		_type = "ROLL";
		if (_pick < _burst + _tearRate) then { _type = "TEAR"; };
		if (_pick < _burst) then { _type = "BURST"; };
		_start = _now;
		_end = _now + (switch (_type) do {
			case "BURST": { 0.1 + random 0.3 };
			case "TEAR": { 0.06 + random 0.2 };
			default { 0.3 + random 0.5 };
		});
		missionNamespace setVariable ["DB_fpv_ppfx_glitch", [_type, _start, _end]];
	};
};

private _clean = _q >= 0.97 && { _type == "" };
if (_clean && { GETMVAR(DB_fpv_ppfx_clean, false) }) exitWith {};
SETMVAR(DB_fpv_ppfx_clean, _clean);

private _snow = ((((0.55 - _q) / 0.5) max 0) min 1) ^ 1.5;
private _tear = 0;
private _roll = -1;
switch (_type) do {
	case "BURST": { _snow = (_snow + 0.45) min 1; };
	case "TEAR": { _tear = 0.12 + 0.25 * (1 - _q); };
	case "ROLL": { _roll = (_now - _start) / ((_end - _start) max 0.01); };
};

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [1, 1.04, 0, [0, 0, 0, 0], [1, 1, 1, 1.1 * (1 - ([0.6, 0.25] call _ramp))], [0.299, 0.587, 0.114, 0]];
	_fxColor ppEffectCommit 0;
};
if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [0.05 + 0.2 * (1 - _q), 1, 1.25, 0.5, 0.5, 1];
	_fxGrain ppEffectCommit 0;
};
if (_fxBlur >= 0) then {
	_fxBlur ppEffectAdjust [0.12 + 0.25 * ([0.7, 0.2] call _ramp)];
	_fxBlur ppEffectCommit 0;
};
if (_fxChrom >= 0) then {
	_fxChrom ppEffectAdjust [0.004 + 0.008 * (1 - _q), 0.0006, true];
	_fxChrom ppEffectCommit 0;
};
if (_fxWet >= 0) then {
	private _s = 0.2 + _tear;
	_fxWet ppEffectAdjust ([
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[_tear, _tear * 0.6, _tear * 0.4, 4.10, 3.70, 2.50, 1.85, 0.0054 * (0.2 + _tear * 1.4), 0.0041 * (0.2 + _tear * 1.4), 0.0090 * (0.2 + _tear * 1.4), 0.0070 * (0.2 + _tear * 1.4), 0.5 * _s, 0.3 * _s, 10 * _s, 6 * _s]
	] select (_tear > 0));
	_fxWet ppEffectCommit 0;
};

{
	_x params ["_name", "_alpha", "_kind"];
	private _ctrl = uiNamespace getVariable [_name, controlNull];
	if (_alpha > 0.01) then {
		_ctrl ctrlSetText format ["\ArmaFPV\pictures\fx\%1_%2_%3.paa", _kind, floor random FPV_FX_FRAMES, ["ca", "co"] select (_kind == "snow")];
	};
	_ctrl ctrlSetTextColor [1, 1, 1, _alpha];
} forEach [
	["ArmaFPV_FX_Spark1", [0.92, 0.65] call _ramp, "spark"],
	["ArmaFPV_FX_Spark2", [0.75, 0.45] call _ramp, "spark"],
	["ArmaFPV_FX_Spark3", [0.55, 0.25] call _ramp, "spark"],
	["ArmaFPV_FX_Snow", _snow, "snow"]
];

private _osd = uiNamespace getVariable ["ArmaFPV_FX_osd", []];
if (_osd isEqualTo [] || { isNull (_osd # 0 # 0) }) then {
	_osd = (["ArmaFPV_OSD_LQ", "ArmaFPV_OSD_Rssi", "ArmaFPV_OSD_Cross", "ArmaFPV_OSD_Warn", "ArmaFPV_OSD_Alt", "ArmaFPV_OSD_Volt", "ArmaFPV_OSD_Mah", "ArmaFPV_DefaultText", "ArmaFPV_OSD_Amp", "ArmaFPV_OSD_Time"]
		apply { private _c = uiNamespace getVariable [_x, controlNull]; [_c, ctrlPosition _c] }) select { !isNull (_x # 0) };
	uiNamespace setVariable ["ArmaFPV_FX_osd", _osd];
};

(ctrlPosition (uiNamespace getVariable ["ArmaFPV_FX_Snow", controlNull])) params ["_ax", "_ay", "_aw", "_ah"];
private _bar = uiNamespace getVariable ["ArmaFPV_FX_Bar", controlNull];
private _dy = 0;
if (_roll >= 0) then {
	_dy = _roll * _ah;
	_bar ctrlSetPosition [_ax, _ay + _dy - _ah * 0.035, _aw, _ah * 0.07];
	_bar ctrlCommit 0;
};
_bar ctrlShow (_roll >= 0);

private _shifted = _roll >= 0 || { _tear > 0 };
if (_shifted || { uiNamespace getVariable ["ArmaFPV_FX_osdShifted", false] }) then {
	{
		_x params ["_ctrl", "_pos"];
		_pos params ["_x0", "_y0", "_w", "_h"];
		private _y = _y0 + _dy;
		if (_y > _ay + _ah) then { _y = _y - _ah; };
		private _dx = [0, (random 2 - 1) * _tear * _aw * 0.12] select (random 1 < 0.5);
		_ctrl ctrlSetPosition [_x0 + _dx, _y, _w, _h];
		_ctrl ctrlCommit 0;
	} forEach _osd;
	uiNamespace setVariable ["ArmaFPV_FX_osdShifted", _shifted];
};
