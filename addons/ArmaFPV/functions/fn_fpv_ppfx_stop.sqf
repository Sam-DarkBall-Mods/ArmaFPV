/*
	ArmaFPV: stop FPV PPFX module.
	Purpose: removes the EachFrame handler and destroys all PP effects.
	Context: client only.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};

private _pfhId = GETMVAR(DB_fpv_ppfx_pfhId, -1);
if (_pfhId >= 0) then {
	[_pfhId] call CBA_fnc_removePerFrameHandler;
};

private _fxColor = GETMVAR(DB_fpv_ppfx_fxColor, -1);
private _fxGrain = GETMVAR(DB_fpv_ppfx_fxGrain, -1);
private _fxBlur = GETMVAR(DB_fpv_ppfx_fxBlur, -1);
private _fxChrom = GETMVAR(DB_fpv_ppfx_fxChrom, -1);
private _fxResolution = GETMVAR(DB_fpv_ppfx_fxResolution, -1);
private _fxInvert = GETMVAR(DB_fpv_ppfx_fxInvert, -1);
private _fxRadial = GETMVAR(DB_fpv_ppfx_fxRadial, -1);
private _fxWet = GETMVAR(DB_fpv_ppfx_fxWet, -1);

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]];
	_fxColor ppEffectCommit 0;
	ppEffectDestroy _fxColor;
};

if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [0, 1, 1, 0, 0, 0];
	_fxGrain ppEffectCommit 0;
	ppEffectDestroy _fxGrain;
};

if (_fxBlur >= 0) then {
	_fxBlur ppEffectAdjust [0];
	_fxBlur ppEffectCommit 0;
	ppEffectDestroy _fxBlur;
};

if (_fxChrom >= 0) then {
	_fxChrom ppEffectAdjust [0, 0, true];
	_fxChrom ppEffectCommit 0;
	ppEffectDestroy _fxChrom;
};

if (_fxResolution >= 0) then {
	_fxResolution ppEffectAdjust [-1];
	_fxResolution ppEffectCommit 0;
	ppEffectDestroy _fxResolution;
};

if (_fxInvert >= 0) then {
	_fxInvert ppEffectAdjust [0, 0, 0];
	_fxInvert ppEffectCommit 0;
	ppEffectDestroy _fxInvert;
};

if (_fxRadial >= 0) then {
	_fxRadial ppEffectAdjust [0, 0, 0, 0];
	_fxRadial ppEffectCommit 0;
	ppEffectDestroy _fxRadial;
};

if (_fxWet >= 0) then {
	_fxWet ppEffectAdjust [0, 0, 0, 4.10, 3.70, 2.50, 1.85, 0, 0, 0, 0, 0, 0, 0, 0];
	_fxWet ppEffectCommit 0;
	ppEffectDestroy _fxWet;
};

private _usedPriorities = GETMVAR(DB_fpv_ppfx_usedPriorities, []);
private _instancePriorities = GETMVAR(DB_fpv_ppfx_priorities, []);

{
	private _idx = _usedPriorities find _x;
	if (_idx >= 0) then {
		_usedPriorities deleteAt _idx;
	};
} forEach _instancePriorities;

SETMVAR(DB_fpv_ppfx_usedPriorities, _usedPriorities);
private _ppfxPriorities = [];
SETMVAR(DB_fpv_ppfx_priorities, _ppfxPriorities);
private _ppfxHandles = [];
SETMVAR(DB_fpv_ppfx_handles, _ppfxHandles);
SETMVAR(DB_fpv_ppfx_fxColor, -1);
SETMVAR(DB_fpv_ppfx_fxGrain, -1);
SETMVAR(DB_fpv_ppfx_fxBlur, -1);
SETMVAR(DB_fpv_ppfx_fxChrom, -1);
SETMVAR(DB_fpv_ppfx_fxResolution, -1);
SETMVAR(DB_fpv_ppfx_fxInvert, -1);
SETMVAR(DB_fpv_ppfx_fxRadial, -1);
SETMVAR(DB_fpv_ppfx_fxWet, -1);
SETMVAR(DB_fpv_ppfx_pfhId, -1);
SETMVAR(DB_fpv_ppfx_active, false);
SETMVAR(DB_fpv_ppfx_input, 1);
SETMVAR(DB_fpv_ppfx_prevQ, 1);
SETMVAR(DB_fpv_ppfx_lastDropGlitch, -1);
SETMVAR(DB_fpv_ppfx_state, "CLEAN");
SETMVAR(DB_fpv_ppfx_stateSince, diag_tickTime);
private _ppfxContext = [];
SETMVAR(DB_fpv_ppfx_context, _ppfxContext);
private _ppfxGlitch = [];
SETMVAR(DB_fpv_ppfx_glitch, _ppfxGlitch);
