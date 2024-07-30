params ["_player", "_uav"];

private _fnc_evaluateTerrainImpact = {  
    params ["_startPoint", "_endPoint"];
    private _terrainInterceptionValue = 0; 
    private _initialPos = eyePos _startPoint; 
    private _finalPos = getPosWorld _endPoint; 
    private _isIntersecting = terrainIntersectASL[_initialPos, _finalPos];
    _terrainInterceptionValue = if (_isIntersecting) then { 1 } else { (_finalPos select 2) / 500 };
    _terrainInterceptionValue
};

private _fnc_countInterferingObjects = { 
    params ["_from", "_to"];
    private _intersectedSurfaces = lineIntersectsSurfaces [
        eyepos _from,
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
    private _retranslators = _position nearObjects ["FPV_Retranslator", _radius];
    _retranslators
};

private _fnc_findJammers = {
    params ["_position", "_radius"];
    private _jammers = _position nearEntities [["Sania", "Sania_with_tripod"], _radius];
    _jammers = _jammers select { _x getVariable ["DB_jammer_isActive", false] };
    _jammers
};

private _fnc_distanceImpact = {
    params ["_distance", "_maxDistance"];
    private _distanceFactor = 1 - (_distance / _maxDistance);
    _distanceFactor
};

private _retranslatorsNearUAV = [_uav, 1500] call _fnc_findRetranslators;
private _retranslatorsNearPlayer = [_player, 1500] call _fnc_findRetranslators;

private _jammersNearUAV = [_uav, 1000] call _fnc_findJammers;

private _maxDistance = if (count _retranslatorsNearUAV > 0 || count _retranslatorsNearPlayer > 0) then { FPV_MaxFlightDistance + 2500 } else { FPV_MaxFlightDistance };

private _terrainInterception = [_player, _uav] call _fnc_evaluateTerrainImpact;
private _objectCount = [_player, _uav] call _fnc_countInterferingObjects;
private _distance = _player distance _uav;

private _signalStrength = 1 - (_objectCount * 0.05);

private _distanceImpact = [_distance, _maxDistance] call _fnc_distanceImpact;
_signalStrength = _signalStrength * (1 - (_terrainInterception * (_distance / _maxDistance))) * _distanceImpact;

if ((_retranslatorsNearUAV isNotEqualTo []) || (_retranslatorsNearPlayer isNotEqualTo [])) then {
    _signalStrength = _signalStrength * 1.8;
};


if (isNil "DB_timeInJammerZone") then {
    DB_timeInJammerZone = 0;
};

if (_jammersNearUAV isNotEqualTo []) then {
    DB_timeInJammerZone = DB_timeInJammerZone + diag_deltaTime;

    private _jammerImpact = 1 - (DB_timeInJammerZone * 1.75);
    _signalStrength = _signalStrength * _jammerImpact max 0;
} else {
    DB_timeInJammerZone = 0;
};

if (_distance > _maxDistance) then {
    _signalStrength = 0;
};

_signalStrength = _signalStrength max 0 min 1;
_signalStrength;
