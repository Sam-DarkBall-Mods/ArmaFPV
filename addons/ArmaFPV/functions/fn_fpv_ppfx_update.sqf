/*
	ArmaFPV: update FPV PPFX module.
	Purpose: updates PP effects every frame based on signal quality.
	Context: unscheduled (EachFrame).
	Params: none.
	Returns: nothing.
*/

if (!hasInterface) exitWith {};
if (!(missionNamespace getVariable ["DB_fpv_ppfx_active", false])) exitWith {};

private _now = diag_tickTime;
private _dt = diag_deltaTime max 0.001;

private _handles = missionNamespace getVariable ["DB_fpv_ppfx_handles", []];
if (_handles isEqualTo []) exitWith {};

private _fxColor = missionNamespace getVariable ["DB_fpv_ppfx_fxColor", -1];
private _fxGrain = missionNamespace getVariable ["DB_fpv_ppfx_fxGrain", -1];
private _fxBlur = missionNamespace getVariable ["DB_fpv_ppfx_fxBlur", -1];
private _fxChrom = missionNamespace getVariable ["DB_fpv_ppfx_fxChrom", -1];
private _fxResolution = missionNamespace getVariable ["DB_fpv_ppfx_fxResolution", -1];
private _fxInvert = missionNamespace getVariable ["DB_fpv_ppfx_fxInvert", -1];
private _fxRadial = missionNamespace getVariable ["DB_fpv_ppfx_fxRadial", -1];
private _fxWet = missionNamespace getVariable ["DB_fpv_ppfx_fxWet", -1];

private _q = missionNamespace getVariable ["DB_fpv_ppfx_input", 1];
_q = (_q max 0) min 1;

private _context = missionNamespace getVariable ["DB_fpv_ppfx_context", []];
private _getCtx = {
	params ["_ctx", "_key", "_default"];
	private _idx = _ctx find _key;
	if (_idx >= 0 && { (_idx + 1) < count _ctx }) then {
		_ctx # (_idx + 1)
	} else {
		_default
	};
};

private _altAGL = [_context, "altAGL", 0] call _getCtx;
private _distance = [_context, "distance", 0] call _getCtx;
private _maxDistance = [_context, "maxDistance", 1500] call _getCtx;
private _inJammer = [_context, "inJammer", false] call _getCtx;
private _jammerFactor = [_context, "jammerFactor", 0] call _getCtx;
private _obstacles = [_context, "obstacleCount", 0] call _getCtx;
private _terrainMask = [_context, "terrainMask", 0] call _getCtx;
private _lowAltFactor = (1 - ((_altAGL max 0) / 20) min 1) max 0;
private _lowAltImpact = _lowAltFactor * _severity;

private _hysteresis = missionNamespace getVariable ["DB_fpv_ppfx_hysteresis", 0.05];
private _minStateTime = missionNamespace getVariable ["DB_fpv_ppfx_minStateTime", 0.4];

private _state = missionNamespace getVariable ["DB_fpv_ppfx_state", "CLEAN"];
private _stateSince = missionNamespace getVariable ["DB_fpv_ppfx_stateSince", _now];

private _nextState = _state;

switch (_state) do {
	case "CLEAN": {
		if (_q < 0.85 - _hysteresis) then { _nextState = "MINOR"; };
	};
	case "MINOR": {
		if (_q >= 0.85 + _hysteresis) then { _nextState = "CLEAN"; };
		if (_q < 0.65 - _hysteresis) then { _nextState = "MED"; };
	};
	case "MED": {
		if (_q >= 0.65 + _hysteresis) then { _nextState = "MINOR"; };
		if (_q < 0.40 - _hysteresis) then { _nextState = "SEVERE"; };
	};
	case "SEVERE": {
		if (_q >= 0.40 + _hysteresis) then { _nextState = "MED"; };
		if (_q < 0.15 - _hysteresis) then { _nextState = "LOST"; };
	};
	case "LOST": {
		if (_q >= 0.15 + _hysteresis) then { _nextState = "SEVERE"; };
	};
	default { _nextState = "CLEAN"; };
};

if (_nextState != _state && { (_now - _stateSince) >= _minStateTime }) then {
	_state = _nextState;
	_stateSince = _now;
};

missionNamespace setVariable ["DB_fpv_ppfx_state", _state];
missionNamespace setVariable ["DB_fpv_ppfx_stateSince", _stateSince];

private _smoothstepInv = {
	params ["_x", "_high", "_low"];
	private _t = (_high - _x) / (_high - _low);
	_t = (_t max 0) min 1;
	_t * _t * (3 - 2 * _t)
};

private _severity = 1 - _q;
private _noiseWeight = [_q, 0.95, 0.35] call _smoothstepInv;
private _blurWeight = _severity ^ 1.7;
private _aberrWeight = _severity ^ 2.2;

private _envBoost = 1;
if (_altAGL < 20 && { _q < 0.5 }) then { _envBoost = _envBoost * 1.25; };
if (_inJammer) then { _envBoost = _envBoost * 1.35; };
if (_jammerFactor > 0) then { _envBoost = _envBoost * (1 + (_jammerFactor min 1) * 0.8); };
if (_obstacles > 0) then { _envBoost = _envBoost * (1 + (0.03 * (_obstacles min 10))); };
if (_terrainMask > 0) then { _envBoost = _envBoost * (1 + (_terrainMask min 1) * 0.4); };
if (_maxDistance > 0) then { _envBoost = _envBoost * (1 + ((_distance / _maxDistance) min 1) * 0.25); };

_noiseWeight = _noiseWeight * 1.1;
_blurWeight = _blurWeight * 0.6;
_aberrWeight = _aberrWeight * 0.9;

_noiseWeight = (_noiseWeight * _envBoost) min 1;
_blurWeight = (_blurWeight * _envBoost) min 1;
_aberrWeight = (_aberrWeight * _envBoost) min 1;

private _glitch = missionNamespace getVariable ["DB_fpv_ppfx_glitch", []];
private _glitchType = "";
private _glitchEnd = 0;

if (_glitch isEqualType [] && { count _glitch >= 2 }) then {
	_glitchType = _glitch # 0;
	_glitchEnd = _glitch # 1;
};

if (_glitchType != "" && { _now >= _glitchEnd }) then {
	_glitchType = "";
	_glitchEnd = 0;
	missionNamespace setVariable ["DB_fpv_ppfx_glitch", []];
};

if (_glitchType isEqualTo "") then {
	private _chanceBase = 0.01 + (_severity ^ 2) * 0.35;
	if (_altAGL < 20) then { _chanceBase = _chanceBase + (0.03 * _severity); };
	if (_lowAltImpact > 0) then { _chanceBase = _chanceBase + (_lowAltImpact * 0.08); };
	if (_inJammer) then { _chanceBase = _chanceBase + 0.06; };
	if (_obstacles > 0) then { _chanceBase = _chanceBase + 0.02; };
	if (_severity > 0.6) then { _chanceBase = _chanceBase + 0.04; };
	private _chance = _chanceBase * _dt;

	if ((random 1) < _chance) then {
		private _types = ["LINE_TEAR", "COLOR_SHIFT", "BLACK_PULSE"];
		if (_severity > 0.6) then {
			_types pushBack "BLACKOUT";
		};
		_glitchType = selectRandom _types;
		private _duration = 0.08 + (random 0.25) * (0.5 + _severity);
		if (_glitchType isEqualTo "BLACKOUT") then {
			private _short = 0.02 + (random 0.05);
			if (_lowAltFactor > 0.4) then { _short = 0.02 + (random 0.04); };
			_duration = _short;
		};
		_glitchEnd = _now + _duration;
		missionNamespace setVariable ["DB_fpv_ppfx_glitch", [_glitchType, _glitchEnd]];
	};
};

private _glitchNoise = 0;
private _glitchBlur = 0;
private _glitchRadial = 0;
private _glitchWet = 0;
private _colorShift = 0;
private _pulse = 0;
private _blackout = 0;
private _invert = 0;

switch (_glitchType) do {
	case "LINE_TEAR": {
		_glitchWet = 0.08 + _severity * 0.25;
		_glitchNoise = 0.4;
		_glitchRadial = 0.03;
	};
	case "COLOR_SHIFT": {
		_colorShift = 0.08 + _severity * 0.12;
	};
	case "BLACK_PULSE": {
		_pulse = -0.35;
		_glitchNoise = 0.2;
	};
	case "BLACKOUT": {
		_blackout = 0.5;
		_glitchNoise = 0.6;
	};
	default {};
};

private _commitTime = if (_glitchType isEqualTo "") then { 0.03 } else { 0 };

private _analogBase = 0.06;
private _drift = (sin (_now * 2.1) * 0.03 + sin (_now * 0.7) * 0.015) * _severity;
private _baseBrightness = 1 + _drift + _pulse;
if (_severity > 0.8) then {
	_baseBrightness = _baseBrightness max 0.28;
};
private _flickerBlackout = 0;
if (_severity > 0.35) then {
	private _flickerHz = 18 + (_severity * 14);
	private _phase = (_now * _flickerHz);
	private _wave = ((sin (_phase * 6.283) + 1) * 0.5);
	_flickerBlackout = _wave * (0.25 + (_severity * 0.2));
	if (_lowAltFactor > 0.4) then { _flickerBlackout = _flickerBlackout + (0.06 * _severity); };
};

private _finalBlackout = (_blackout max _flickerBlackout) min 0.55;
private _brightness = _baseBrightness * (1 - _finalBlackout);
if (_severity > 0.7) then {
	_brightness = _brightness max 0.16;
};
private _contrast = (1 + (_severity * 0.4) + (_analogBase * 0.12)) * (1 - _finalBlackout) + (1 * _finalBlackout);
private _offset = 0;

private _colorA = [0, 0, 0, _finalBlackout];
private _colorB = [1 + _colorShift + (_analogBase * 0.02), 1, 1 - _colorShift - (_analogBase * 0.01), 1];

private _grain = (_noiseWeight + _glitchNoise + _analogBase * 0.35) min 1;
private _blur = (_blurWeight + _glitchBlur + _analogBase * 0.08) min 1;
private _chrom = (_aberrWeight * 0.025 + _analogBase * 0.004) min 0.06;

private _resTarget = -1;

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [
		_brightness,
		_contrast,
		_offset,
		_colorA,
		_colorB,
		[0.299, 0.587, 0.114, 0]
	];
	_fxColor ppEffectCommit _commitTime;
};

if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [_grain, 1, 1 + (_grain * 5), 0.5, 0.5, 0];
	_fxGrain ppEffectCommit _commitTime;
};

if (_fxBlur >= 0) then {
	_fxBlur ppEffectAdjust [_blur];
	_fxBlur ppEffectCommit _commitTime;
};

if (_fxChrom >= 0) then {
	_fxChrom ppEffectAdjust [_chrom, _chrom, true];
	_fxChrom ppEffectCommit _commitTime;
};

if (_fxResolution >= 0) then {
	_fxResolution ppEffectAdjust [_resTarget];
	_fxResolution ppEffectCommit _commitTime;
};

if (_fxInvert >= 0) then {
	_fxInvert ppEffectAdjust [_invert, _invert, _invert];
	_fxInvert ppEffectCommit _commitTime;
};

if (_fxRadial >= 0) then {
	_fxRadial ppEffectAdjust [_glitchRadial, _glitchRadial, 0.5, 0.5];
	_fxRadial ppEffectCommit _commitTime;
};

if (_fxWet >= 0) then {
	private _wetParams = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	if (_glitchWet > 0) then {
		private _ampScale = 0.2 + (_glitchWet * 1.4);
		private _randScale = 0.2 + (_glitchWet * 0.8);
		private _posScale = 0.2 + (_glitchWet * 0.8);
		_wetParams = [
			_glitchWet,
			_glitchWet * 0.6,
			_glitchWet * 0.4,
			4.10,
			3.70,
			2.50,
			1.85,
			0.0054 * _ampScale,
			0.0041 * _ampScale,
			0.0090 * _ampScale,
			0.0070 * _ampScale,
			0.5 * _randScale,
			0.3 * _randScale,
			10.0 * _posScale,
			6.0 * _posScale
		];
	};
	_fxWet ppEffectAdjust _wetParams;
	_fxWet ppEffectCommit _commitTime;
};

if (_q >= 0.99) then {
	if (_fxColor >= 0) then { _fxColor ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]]; _fxColor ppEffectCommit 0; };
	if (_fxGrain >= 0) then { _fxGrain ppEffectAdjust [0, 1, 1, 0, 0, 0]; _fxGrain ppEffectCommit 0; };
	if (_fxBlur >= 0) then { _fxBlur ppEffectAdjust [0]; _fxBlur ppEffectCommit 0; };
	if (_fxChrom >= 0) then { _fxChrom ppEffectAdjust [0, 0, true]; _fxChrom ppEffectCommit 0; };
	if (_fxResolution >= 0) then { _fxResolution ppEffectAdjust [-1]; _fxResolution ppEffectCommit 0; };
	if (_fxInvert >= 0) then { _fxInvert ppEffectAdjust [0, 0, 0]; _fxInvert ppEffectCommit 0; };
	if (_fxRadial >= 0) then { _fxRadial ppEffectAdjust [0, 0, 0, 0]; _fxRadial ppEffectCommit 0; };
	if (_fxWet >= 0) then { _fxWet ppEffectAdjust [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; _fxWet ppEffectCommit 0; };
};
