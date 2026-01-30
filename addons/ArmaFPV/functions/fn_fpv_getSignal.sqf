/*
	ArmaFPV: control signal calculation.
	Purpose: computes link strength between the operator and the UAV.
	Context: client or server (called locally where needed).
	Params: [_player, _uav]
		_player - operator/player object.
		_uav - UAV object.
	Returns: Number (0..1) - signal strength.
*/

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
	private _ratio = (_distance / _maxDistance) min 1;
	1 - (_ratio ^ 1.35)
};

private _retranslatorsNearUAV = [_uav, 1500] call _fnc_findRetranslators;
private _retranslatorsNearPlayer = [_player, 1500] call _fnc_findRetranslators;
private _jammersNearUAV = [_uav, 1000] call _fnc_findJammers;

private _baseMaxDistance = missionNamespace getVariable ["FPV_MaxFlightDistance", 1500];
private _maxDistance = if ((_retranslatorsNearUAV isNotEqualTo []) || (_retranslatorsNearPlayer isNotEqualTo [])) then {
	_baseMaxDistance + 2500
} else {
	_baseMaxDistance
};

private _objectCount = [_player, _uav] call _fnc_countInterferingObjects;
private _distance = _player distance _uav;
private _altAGL = (getPosATL _uav) select 2;

private _startASL = eyePos _player;
private _endASL = getPosWorld _uav;
private _terrainBlocked = terrainIntersectASL [_startASL, _endASL];
private _altFactor = (_altAGL / 40) min 1;

private _terrainFactor = if (_terrainBlocked) then {
	0.15 + (0.35 * _altFactor)
} else {
	0.6 + (0.4 * _altFactor)
};

private _distanceImpact = [_distance, _maxDistance] call _fnc_distanceImpact;
private _obstacleFactor = 0.86 ^ (_objectCount min 8);
private _signalStrength = _distanceImpact * _terrainFactor * _obstacleFactor;

if ((_retranslatorsNearUAV isNotEqualTo []) || (_retranslatorsNearPlayer isNotEqualTo [])) then {
	_signalStrength = _signalStrength * 1.35;
};

private _timeInJammerZone = missionNamespace getVariable ["DB_timeInJammerZone", 0];

if (_jammersNearUAV isNotEqualTo []) then {
	_timeInJammerZone = _timeInJammerZone + diag_deltaTime;
	private _jammerImpact = 1 - (_timeInJammerZone * 1.75);
	_signalStrength = (_signalStrength * _jammerImpact) max 0;
} else {
	_timeInJammerZone = 0;
};

missionNamespace setVariable ["DB_timeInJammerZone", _timeInJammerZone];

if (_distance > _maxDistance) then {
	_signalStrength = 0;
};

private _terrainMask = if (_terrainBlocked) then { 1 } else { (1 - _altFactor) max 0 };
missionNamespace setVariable ["DB_fpv_signal_obstacles", _objectCount];
missionNamespace setVariable ["DB_fpv_signal_terrainMask", _terrainMask];

_signalStrength = _signalStrength max 0 min 1;
_signalStrength;
