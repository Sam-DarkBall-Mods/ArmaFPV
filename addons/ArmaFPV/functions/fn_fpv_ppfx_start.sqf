/*
	ArmaFPV: start FPV PPFX module.
	Purpose: creates post-process effects once and registers an EachFrame update.
	Context: client only.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};
if (GETMVAR(DB_fpv_ppfx_active, false)) exitWith {};

if (isNil "DB_fpv_ppfx_input") then {
	SETMVAR(DB_fpv_ppfx_input, 1);
};

if (isNil "DB_fpv_ppfx_hysteresis") then {
	SETMVAR(DB_fpv_ppfx_hysteresis, 0.05);
};

if (isNil "DB_fpv_ppfx_minStateTime") then {
	SETMVAR(DB_fpv_ppfx_minStateTime, 0.4);
};

if (isNil "DB_fpv_ppfx_priorityBase") then {
	SETMVAR(DB_fpv_ppfx_priorityBase, 1650);
};

private _priorityBase = GETMVAR(DB_fpv_ppfx_priorityBase, 1650);
private _usedPriorities = missionNamespace getVariable ["DB_fpv_ppfx_usedPriorities", []];
private _instancePriorities = [];

private _createEffect = {
	params ["_name", "_base", "_used"];
	private _priority = _base;
	private _limit = _base + 200;
	private _handle = -1;

	while { _priority < _limit && { _handle < 0 } } do {
		if (!(_priority in _used)) then {
			_handle = ppEffectCreate [_name, _priority];
			if (_handle >= 0) then {
				_handle ppEffectEnable true;
				_used pushBack _priority;
			} else {
				_handle = -1;
			};
		};

		if (_handle < 0) then {
			_priority = _priority + 1;
		};
	};

	if (_handle < 0) exitWith { [-1, _used, -1] };
	[_handle, _used, _priority]
};

private _result = ["ColorCorrections", _priorityBase, _usedPriorities] call _createEffect;
private _fxColor = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["FilmGrain", _priorityBase, _usedPriorities] call _createEffect;
private _fxGrain = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["DynamicBlur", _priorityBase, _usedPriorities] call _createEffect;
private _fxBlur = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["ChromAberration", _priorityBase, _usedPriorities] call _createEffect;
private _fxChrom = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["Resolution", _priorityBase, _usedPriorities] call _createEffect;
private _fxResolution = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["ColorInversion", _priorityBase, _usedPriorities] call _createEffect;
private _fxInvert = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["RadialBlur", _priorityBase, _usedPriorities] call _createEffect;
private _fxRadial = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

_result = ["WetDistortion", _priorityBase, _usedPriorities] call _createEffect;
private _fxWet = _result # 0;
_usedPriorities = _result # 1;
if ((_result # 2) >= 0) then { _instancePriorities pushBack (_result # 2); };

SETMVAR(DB_fpv_ppfx_usedPriorities, _usedPriorities);
private _ppfxPriorities = _instancePriorities;
SETMVAR(DB_fpv_ppfx_priorities, _ppfxPriorities);
private _ppfxHandles = [_fxColor, _fxGrain, _fxBlur, _fxChrom, _fxResolution, _fxInvert, _fxRadial, _fxWet];
SETMVAR(DB_fpv_ppfx_handles, _ppfxHandles);
SETMVAR(DB_fpv_ppfx_fxColor, _fxColor);
SETMVAR(DB_fpv_ppfx_fxGrain, _fxGrain);
SETMVAR(DB_fpv_ppfx_fxBlur, _fxBlur);
SETMVAR(DB_fpv_ppfx_fxChrom, _fxChrom);
SETMVAR(DB_fpv_ppfx_fxResolution, _fxResolution);
SETMVAR(DB_fpv_ppfx_fxInvert, _fxInvert);
SETMVAR(DB_fpv_ppfx_fxRadial, _fxRadial);
SETMVAR(DB_fpv_ppfx_fxWet, _fxWet);
SETMVAR(DB_fpv_ppfx_active, true);
SETMVAR(DB_fpv_ppfx_state, "CLEAN");
SETMVAR(DB_fpv_ppfx_stateSince, diag_tickTime);
SETMVAR(DB_fpv_ppfx_prevQ, GETMVAR(DB_fpv_ppfx_input, 1));
SETMVAR(DB_fpv_ppfx_lastDropGlitch, -1);
private _ppfxGlitch = [];
SETMVAR(DB_fpv_ppfx_glitch, _ppfxGlitch);

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]];
	_fxColor ppEffectCommit 0;
};

if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [0, 1, 1, 0, 0, 0];
	_fxGrain ppEffectCommit 0;
};

if (_fxBlur >= 0) then {
	_fxBlur ppEffectAdjust [0];
	_fxBlur ppEffectCommit 0;
};

if (_fxChrom >= 0) then {
	_fxChrom ppEffectAdjust [0, 0, true];
	_fxChrom ppEffectCommit 0;
};

if (_fxResolution >= 0) then {
	_fxResolution ppEffectAdjust [-1];
	_fxResolution ppEffectCommit 0;
};

if (_fxInvert >= 0) then {
	_fxInvert ppEffectAdjust [0, 0, 0];
	_fxInvert ppEffectCommit 0;
};

if (_fxRadial >= 0) then {
	_fxRadial ppEffectAdjust [0, 0, 0, 0];
	_fxRadial ppEffectCommit 0;
};

if (_fxWet >= 0) then {
	_fxWet ppEffectAdjust [0, 0, 0, 4.10, 3.70, 2.50, 1.85, 0, 0, 0, 0, 0, 0, 0, 0];
	_fxWet ppEffectCommit 0;
};

private _prevPfh = GETMVAR(DB_fpv_ppfx_pfhId, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	call DB_fnc_fpv_ppfx_update;
}, 0, []] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_ppfx_pfhId, _pfhId);
