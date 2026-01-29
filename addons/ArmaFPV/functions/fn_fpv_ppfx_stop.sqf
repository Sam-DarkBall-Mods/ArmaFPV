/*
	ArmaFPV: stop FPV PPFX module.
	Purpose: removes the EachFrame handler and destroys all PP effects.
	Context: client only.
	Params: none.
	Returns: nothing.
*/

if (!hasInterface) exitWith {};

private _ehId = missionNamespace getVariable ["DB_fpv_ppfx_ehId", -1];
if (_ehId >= 0) then {
	removeMissionEventHandler ["EachFrame", _ehId];
};

private _fxColor = missionNamespace getVariable ["DB_fpv_ppfx_fxColor", -1];
private _fxGrain = missionNamespace getVariable ["DB_fpv_ppfx_fxGrain", -1];
private _fxBlur = missionNamespace getVariable ["DB_fpv_ppfx_fxBlur", -1];
private _fxChrom = missionNamespace getVariable ["DB_fpv_ppfx_fxChrom", -1];
private _fxResolution = missionNamespace getVariable ["DB_fpv_ppfx_fxResolution", -1];
private _fxInvert = missionNamespace getVariable ["DB_fpv_ppfx_fxInvert", -1];
private _fxRadial = missionNamespace getVariable ["DB_fpv_ppfx_fxRadial", -1];
private _fxWet = missionNamespace getVariable ["DB_fpv_ppfx_fxWet", -1];

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 4]];
	_fxColor ppEffectCommit 0;
	ppEffectDestroy _fxColor;
};

if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [0, 1, 1, 0, 0, true];
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
	_fxResolution ppEffectAdjust [1];
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
	_fxWet ppEffectAdjust [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	_fxWet ppEffectCommit 0;
	ppEffectDestroy _fxWet;
};

private _usedPriorities = missionNamespace getVariable ["DB_fpv_ppfx_usedPriorities", []];
private _instancePriorities = missionNamespace getVariable ["DB_fpv_ppfx_priorities", []];

{
	private _idx = _usedPriorities find _x;
	if (_idx >= 0) then {
		_usedPriorities deleteAt _idx;
	};
} forEach _instancePriorities;

missionNamespace setVariable ["DB_fpv_ppfx_usedPriorities", _usedPriorities];
missionNamespace setVariable ["DB_fpv_ppfx_priorities", []];
missionNamespace setVariable ["DB_fpv_ppfx_handles", []];
missionNamespace setVariable ["DB_fpv_ppfx_fxColor", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxGrain", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxBlur", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxChrom", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxResolution", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxInvert", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxRadial", -1];
missionNamespace setVariable ["DB_fpv_ppfx_fxWet", -1];
missionNamespace setVariable ["DB_fpv_ppfx_ehId", -1];
missionNamespace setVariable ["DB_fpv_ppfx_active", false];
missionNamespace setVariable ["DB_fpv_ppfx_glitch", []];
