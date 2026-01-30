/*
	ArmaFPV: control signal calculation.
	Purpose: computes link strength between the operator and the UAV.
	Context: client or server (called locally where needed).
	Params: [_player, _uav]
		_player - operator/player object.
		_uav - UAV object.
	Returns: Number (0..1) - signal strength.
*/

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
		private _intersectedObject = _x select 2;
		private _isParent = (_intersectedObject isEqualTo objectParent _from) || (_intersectedObject isEqualTo objectParent _to);
		!_isParent && !(_intersectedObject isKindOf "Man")
	};

	count _filteredObstacles
};

private _fnc_findRetranslators = {
	params ["_position", "_radius"];
	_position nearObjects ["FPV_Retranslator", _radius]
};

private _fnc_findJammers = {
	params ["_position", "_radius"];
	private _jammers = _position nearEntities [["Sania", "Sania_with_tripod"], _radius];
	_jammers select { _x getVariable ["DB_jammer_isActive", false] }
};

private _fnc_distanceImpact = {
	params ["_distance", "_maxDistance"];
	1 - ((_distance / _maxDistance) min 1)
};

private _retranslatorsNearUAV = [_uav, 1500] call _fnc_findRetranslators;
private _retranslatorsNearPlayer = [_player, 1500] call _fnc_findRetranslators;
private _hasRetranslator = (_retranslatorsNearUAV isNotEqualTo []) || (_retranslatorsNearPlayer isNotEqualTo []);
private _jammersNearUAV = [_uav, 1000] call _fnc_findJammers;

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
private _altAGL = (getPosATL _uav) select 2;
private _altFactor = (_altAGL / 40) min 1;

private _distanceImpact = [_distance, _maxDistance] call _fnc_distanceImpact;
private _obstacleFactor = (1 - ((_objectCount min 8) * 0.05)) max 0;
private _terrainFactor = if (_terrainBlocked) then {
	0.3 + (0.4 * _altFactor)
} else {
	1
};
if (_hasRetranslator) then {
	private _boost = 0.75 + (0.2 * _altFactor);
	_terrainFactor = _terrainFactor max _boost;
};
private _signalStrength = _distanceImpact * _terrainFactor * _obstacleFactor;

if (_hasRetranslator) then {
	_signalStrength = _signalStrength * 1.2;
};

private _timeInJammerZone = GETMVAR(DB_timeInJammerZone, 0);

if (_jammersNearUAV isNotEqualTo []) then {
	_timeInJammerZone = _timeInJammerZone + diag_deltaTime;
	private _jammerImpact = 1 - (_timeInJammerZone * 1.75);
	_signalStrength = (_signalStrength * _jammerImpact) max 0;
} else {
	_timeInJammerZone = 0;
};

SETMVAR(DB_timeInJammerZone, _timeInJammerZone);

if (_distance > _maxDistance) then {
	_signalStrength = 0;
};

private _terrainMask = if (_terrainBlocked) then { 1 } else { (1 - _altFactor) max 0 };
if (_hasRetranslator) then {
	_terrainMask = _terrainMask * 0.4;
};
SETMVAR(DB_fpv_signal_obstacles, _objectCount);
SETMVAR(DB_fpv_signal_terrainMask, _terrainMask);

_signalStrength = _signalStrength max 0 min 1;
_signalStrength;
