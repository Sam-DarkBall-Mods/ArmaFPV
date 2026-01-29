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

private _devEnabled = missionNamespace getVariable ["DB_fpv_ppfx_devEnabled", false];
private _q = missionNamespace getVariable ["DB_fpv_ppfx_input", 1];
private _profile = missionNamespace getVariable ["DB_fpv_ppfx_profile", "ANALOG"];

if (_devEnabled) then {
	_q = missionNamespace getVariable ["DB_fpv_ppfx_devSignal", 1];
	_profile = missionNamespace getVariable ["DB_fpv_ppfx_devProfile", "ANALOG"];
};

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
private _noiseWeight = [_q, 0.9, 0.2] call _smoothstepInv;
private _blurWeight = _severity ^ 1.7;
private _aberrWeight = _severity ^ 2.2;
private _resWeight = _severity ^ 2.0;

private _envBoost = 1;
if (_altAGL < 20 && { _q < 0.5 }) then { _envBoost = _envBoost * 1.25; };
if (_inJammer) then { _envBoost = _envBoost * 1.35; };
if (_jammerFactor > 0) then { _envBoost = _envBoost * (1 + (_jammerFactor min 1) * 0.8); };
if (_obstacles > 0) then { _envBoost = _envBoost * (1 + (0.03 * (_obstacles min 10))); };
if (_terrainMask > 0) then { _envBoost = _envBoost * (1 + (_terrainMask min 1) * 0.4); };
if (_maxDistance > 0) then { _envBoost = _envBoost * (1 + ((_distance / _maxDistance) min 1) * 0.25); };

private _isAnalog = _profile isEqualTo "ANALOG";
private _isDigital = _profile isEqualTo "DIGITAL";

if (_isAnalog) then {
	_noiseWeight = _noiseWeight * 1.1;
	_blurWeight = _blurWeight * 0.6;
	_aberrWeight = _aberrWeight * 0.9;
	_resWeight = 0;
};

if (_isDigital) then {
	_noiseWeight = _noiseWeight * 0.45;
	_blurWeight = _blurWeight * 0.9;
	_aberrWeight = _aberrWeight * 0.3;
	_resWeight = _resWeight * 1.0;
};

_noiseWeight = (_noiseWeight * _envBoost) min 1;
_blurWeight = (_blurWeight * _envBoost) min 1;
_aberrWeight = (_aberrWeight * _envBoost) min 1;
_resWeight = (_resWeight * _envBoost) min 1;

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
	if (_altAGL < 20) then { _chanceBase = _chanceBase + 0.03; };
	if (_inJammer) then { _chanceBase = _chanceBase + 0.06; };
	if (_obstacles > 0) then { _chanceBase = _chanceBase + 0.02; };
	private _chance = _chanceBase * _dt;

	if ((random 1) < _chance) then {
		private _types = if (_isDigital) then {
			["FRAME_DROP", "FREEZE_HINT", "BLACK_PULSE", "WHITE_PULSE"]
		} else {
			["LINE_TEAR", "COLOR_SHIFT", "BLACK_PULSE", "WHITE_PULSE"]
		};
		_glitchType = selectRandom _types;
		private _duration = 0.08 + (random 0.25) * (0.5 + _severity);
		_glitchEnd = _now + _duration;
		missionNamespace setVariable ["DB_fpv_ppfx_glitch", [_glitchType, _glitchEnd]];
	};
};

private _glitchNoise = 0;
private _glitchBlur = 0;
private _glitchRes = 0;
private _glitchRadial = 0;
private _glitchWet = 0;
private _colorShift = 0;
private _pulse = 0;
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
	case "FRAME_DROP": {
		_glitchBlur = 0.5 + _severity * 0.4;
		_glitchRes = 0.6 + _severity * 0.3;
		_glitchRadial = 0.05;
	};
	case "FREEZE_HINT": {
		_glitchBlur = 0.7 + _severity * 0.5;
		_glitchRes = 0.7 + _severity * 0.3;
		_glitchNoise = 0.35;
	};
	case "BLACK_PULSE": {
		_pulse = -0.6;
		_invert = 0.4;
	};
	case "WHITE_PULSE": {
		_pulse = 0.7;
		_invert = 0.9;
	};
	default {};
};

private _commitTime = if (_glitchType isEqualTo "") then { 0.03 } else { 0 };

private _drift = (sin (_now * 2.1) * 0.03 + sin (_now * 0.7) * 0.015) * _severity;
private _brightness = 1 + _drift + _pulse;
private _contrast = 1 + (_severity * 0.4);
private _offset = 0;

private _colorA = [0, 0, 0, 0];
private _colorB = [1 + _colorShift, 1, 1 - _colorShift, 1];
private _colorC = [0.33, 0.33, 0.15, 0.2];
private _colorD = [0, 0, 0, 0, 0, 0, 4];

private _grain = (_noiseWeight + _glitchNoise) min 1;
private _blur = (_blurWeight + _glitchBlur) min 1;
private _chrom = (_aberrWeight * 0.025) min 0.06;

private _resScale = 1;
if (_isDigital) then {
	private _drop = (_resWeight + _glitchRes) min 1;
	_resScale = (1 - (_drop * 0.65)) max 0.35;
};

if (_fxColor >= 0) then {
	_fxColor ppEffectAdjust [_brightness, _contrast, _offset, _colorA, _colorB, _colorC, _colorD];
	_fxColor ppEffectCommit _commitTime;
};

if (_fxGrain >= 0) then {
	_fxGrain ppEffectAdjust [_grain, 1, 1 + (_grain * 5), 0.5, 0.5, true];
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
	_fxResolution ppEffectAdjust [_resScale];
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
		_wetParams = [
			_glitchWet,
			_glitchWet * 0.6,
			_glitchWet * 0.4,
			_glitchWet * 0.8,
			_glitchWet * 0.5,
			_glitchWet * 0.5,
			_now * 0.25,
			_now * 0.33,
			_glitchWet * 0.2,
			_glitchWet * 0.2,
			0,
			0,
			0,
			0,
			0
		];
	};
	_fxWet ppEffectAdjust _wetParams;
	_fxWet ppEffectCommit _commitTime;
};

missionNamespace setVariable [
	"DB_fpv_ppfx_debug",
	[
		"q", _q,
		"state", _state,
		"profile", _profile,
		"weights", ["noise", _grain, "blur", _blur, "aberr", _chrom, "resScale", _resScale],
		"glitch", _glitchType
	]
];

if (_devEnabled) then {
	private _lastLog = missionNamespace getVariable ["DB_fpv_ppfx_lastLog", 0];
	if ((_now - _lastLog) > 0.5) then {
		missionNamespace setVariable ["DB_fpv_ppfx_lastLog", _now];
		diag_log format ["[ArmaFPV PPFX] q=%1 state=%2 profile=%3 glitch=%4", _q, _state, _profile, _glitchType];
	};
};
