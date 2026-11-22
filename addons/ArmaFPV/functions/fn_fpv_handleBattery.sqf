/*
    DB_fnc_fpv_handleBattery
    Battery model of the 6S LiPo pack: returns [cell volts under load, amps, mAh drawn]; charge follows the drone's fuel, current follows the thrust the flight needs.
    Author: DarkBall
*/
params ["_uav"];

#include "\ArmaFPV\script_macros.hpp"

private _fuel = fuel _uav;
private _now = time;
private _vel = velocity _uav;
if (_uav isNil "DB_fpv_battery") then {
    _uav setVariable ["DB_fpv_battery", [_vel, _now, 0]];
};
(_uav getVariable "DB_fpv_battery") params ["_lastVel", "_lastTime", "_amps"];

private _dt = _now - _lastTime;
if (_dt > 0) then {
    private _load = 0;
    if (isEngineOn _uav) then {
        if (isTouchingGround _uav) exitWith { _load = 0.05; };
        private _thrust = ((_vel vectorDiff _lastVel) vectorMultiply (1 / _dt)) vectorAdd [0, 0, 9.81] vectorAdd (_vel vectorMultiply (0.02 * vectorMagnitude _vel));
        _load = ((vectorMagnitude _thrust) / 9.81) ^ 1.5 min 4;
    };
    _amps = _amps + (FPV_BATT_HOVER_AMPS * _load - _amps) * (_dt * 4 min 1);
    _uav setVariable ["DB_fpv_battery", [_vel, _now, _amps]];
};

private _curve = [3.30, 3.62, 3.70, 3.75, 3.79, 3.82, 3.87, 3.93, 4.00, 4.08, 4.20];
private _i = floor (_fuel * 10) min 9;
private _rest = (_curve # _i) + ((_curve # (_i + 1)) - (_curve # _i)) * (_fuel * 10 - _i);

[_rest - _amps * FPV_BATT_SAG, _amps, (1 - _fuel) * FPV_BATT_CAPACITY]
