/*
    DB_fnc_fpv_handleTime
    Flight timer: adds the time the motors run to the seconds stored on the drone and returns them; publishes them when asked.
    Author: DarkBall
*/
params ["_uav", ["_publish", false]];

if (_uav isNil "DB_fpv_savedTime") then {
    _uav setVariable ["DB_fpv_savedTime", 0];
};

private _now = time;
private _flown = _uav getVariable ["DB_fpv_savedTime", 0];
if (isEngineOn _uav) then {
    _flown = _flown + ((_now - (_uav getVariable ["DB_fpv_timeTick", _now])) min 0.5);
};
_uav setVariable ["DB_fpv_timeTick", if (_publish) then { nil } else { _now }];
_uav setVariable ["DB_fpv_savedTime", _flown, _publish];

_flown
