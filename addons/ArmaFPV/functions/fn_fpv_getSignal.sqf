#include "\ArmaFPV\script_macros.hpp"

params ["_player", "_uav"];

private _fnc_countInterferingObjects = {
	params ["_from", "_to"];
	private _intersectedSurfaces = lineIntersectsSurfaces [
		eyePos _from,
		getPosWorld _to,
		_from,
		_to,
		true,
		10,
		"FIRE",
		"NONE"
	];

	private _filteredObstacles = _intersectedSurfaces select {
		private _intersectedObject = _x # 2;
		private _isParent = (_intersectedObject isEqualTo objectParent _from) || (_intersectedObject isEqualTo objectParent _to);
		!_isParent && !(_intersectedObject isKindOf "Man")
	};

	count _filteredObstacles
};

private _fnc_findRetranslators = {
	params ["_position", "_radius"];
	private _retranslators = _position nearObjects ["FPV_Retranslator", _radius];
	_retranslators select { alive _x }
};

private _retranslatorsNearUAV = [_uav, 1500] call _fnc_findRetranslators;
private _retranslatorsNearPlayer = [_player, 1500] call _fnc_findRetranslators;
private _hasRetranslator = (_retranslatorsNearUAV isNotEqualTo []) || (_retranslatorsNearPlayer isNotEqualTo []);
private _jammersNearUAV = _uav nearEntities [["Sania", "Sania_with_tripod"], 1000];
_jammersNearUAV = _jammersNearUAV select { _x getVariable ["DB_jammer_isActive", false] };

private _baseMaxDistance = GETMVAR(FPV_MaxFlightDistance, 4000);
private _maxDistance = if (_hasRetranslator) then {
	_baseMaxDistance + 2500
} else {
	_baseMaxDistance
};

private _objectCount = [_player, _uav] call _fnc_countInterferingObjects;
private _distance = _player distance _uav;
private _startASL = eyePos _player;
private _endASL = getPosWorld _uav;
private _terrainBlocked = terrainIntersectASL [_startASL, _endASL];
private _altAGL = (getPosATL _uav) # 2;
private _altFactor = (_altAGL / 40) min 1;

private _distanceImpact = 1 - ((_distance / _maxDistance) min 1);
private _obstacleFactor = (1 - ((_objectCount min 8) * 0.05)) max 0;
private _terrainFactor = if (_terrainBlocked) then {
	0.3 + (0.4 * _altFactor)
} else {
	1
};
if (_terrainBlocked && { _distance <= FPV_CLOSE_DISTANCE }) then {
	private _closeAlpha = 1 - ((_distance / FPV_CLOSE_DISTANCE) min 1);
	private _closeMin = FPV_CLOSE_TERRAIN_MIN + ((1 - FPV_CLOSE_TERRAIN_MIN) * _closeAlpha);
	_terrainFactor = _terrainFactor max _closeMin;
};
if (_hasRetranslator) then {
	private _boost = 0.75 + (0.2 * _altFactor);
	_terrainFactor = _terrainFactor max _boost;
};
private _signalStrength = _distanceImpact * _terrainFactor * _obstacleFactor;

if (_hasRetranslator) then {
	_signalStrength = _signalStrength * 1.2;
};

private _now = diag_tickTime;
private _lastSignalUpdate = _uav getVariable ["DB_fpv_lastSignalUpdate", _now];
private _elapsed = (_now - _lastSignalUpdate) max 0;
private _inJammer = _jammersNearUAV isNotEqualTo [];
private _timeInJammerZone = _uav getVariable ["DB_fpv_timeInJammerZone", 0];
private _jammerFactor = 0;

if (_inJammer) then {
	_timeInJammerZone = _timeInJammerZone + _elapsed;
	private _jammerImpact = (1 - (_timeInJammerZone * 1.75)) max 0;
	_jammerFactor = 1 - _jammerImpact;
	_signalStrength = _signalStrength * _jammerImpact;
} else {
	_timeInJammerZone = 0;
};

_uav setVariable ["DB_fpv_lastSignalUpdate", _now];
_uav setVariable ["DB_fpv_timeInJammerZone", _timeInJammerZone];
_uav setVariable ["DB_fpv_inJammer", _inJammer];
_uav setVariable ["DB_fpv_jammerFactor", _jammerFactor];

if (_distance > _maxDistance) then {
	_signalStrength = 0;
};

private _terrainMask = if (_terrainBlocked) then { 1 } else { (1 - _altFactor) max 0 };
if (_hasRetranslator) then {
	_terrainMask = _terrainMask * 0.4;
};
_uav setVariable ["DB_fpv_signalMaxDistance", _maxDistance];
_uav setVariable ["DB_fpv_signalObstacles", _objectCount];
_uav setVariable ["DB_fpv_signalTerrainMask", _terrainMask];

_signalStrength = _signalStrength max 0 min 1;
_signalStrength;
