/*
    DB_fnc_fpv_handleOSD
    Betaflight analog OSD loop at the real OSD rate: link quality, RSSI, altitude, battery, current, flight timer and blinking warnings; also drives the goggles' receiver noise.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

private _prev = GETMVAR(DB_fpv_osdPFH, -1);
if (_prev >= 0) then {
    [_prev] call CBA_fnc_removePerFrameHandler;
};

GETUVAR(ArmaFPV_OSD_Cross, controlNull) ctrlSetText (FPV_SYM(0x72) + FPV_SYM(0x73) + FPV_SYM(0x74));

private _pfh = [{
    params ["_args", "_handle"];
    _args params ["_lastUav"];

    private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
    private _uav = getConnectedUAV _player;
    if (isNull _uav || { isNull GETUVAR(ArmaFPV_OSD_Cross, controlNull) } || { !(GETMVAR(ArmaFPV_isControl, false)) }) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        SETMVAR(DB_fpv_osdPFH, -1);
        if (!isNull _lastUav) then { [_lastUav, true] call DB_fnc_fpv_handleTime; };
    };
    if (_uav isNotEqualTo _lastUav && { !isNull _lastUav }) then { [_lastUav, true] call DB_fnc_fpv_handleTime; };
    _args set [0, _uav];

    private _pad = {
        params ["_text", "_size"];
        while { count _text < _size } do { _text = " " + _text; };
        _text
    };
    private _two = { if (_this < 10) then { "0" + str _this } else { str _this } };
    private _on = (floor (diag_tickTime / FPV_OSD_BLINK)) mod 2 == 0;

    private _q = GETMVAR(DB_fpv_ppfx_input, 1);
    setCustomSoundController [_uav, "CustomSoundController1", 1 - _q];
    private _lq = round (100 * (((_q - 0.05) / 0.3) max 0 min 1));
    private _dbm = round (-105 + 65 * _q) - (floor random 3) + 1;

    ([_uav] call DB_fnc_fpv_handleBattery) params ["_cell", "_amps", "_mah"];
    private _battState = [0, 1] select (_cell < FPV_VBAT_WARN);
    if (_cell < FPV_VBAT_MIN) then { _battState = 2; };
    private _battSym = [0x96 - ((floor ((_cell - FPV_VBAT_MIN) * 8)) max 0 min 6), 0x97] select (_battState == 2);

    private _asl = (getPosASL _uav) # 2;
    if (!isEngineOn _uav || { _uav isNil "DB_fpv_armASL" }) then {
        _uav setVariable ["DB_fpv_armASL", [_asl, (getTerrainHeightASL getPosASL _uav) max 0] select (isEngineOn _uav)];
    };
    private _alt = round (_asl - (_uav getVariable ["DB_fpv_armASL", _asl]));

    private _flown = floor ([_uav] call DB_fnc_fpv_handleTime);

    private _warning = switch (true) do {
        case (_lq == 0): { "FAIL SAFE" };
        case (_lq < FPV_LQ_ALARM): { "LINK QUALITY" };
        case (_battState == 2): { " LAND NOW" };
        case (_battState == 1): { "LOW BATTERY" };
        default { "" };
    };

    GETUVAR(ArmaFPV_OSD_LQ, controlNull) ctrlSetText ([FPV_SYM(0x7B) + str _lq, ""] select (_lq < FPV_LQ_ALARM && { !_on }));
    GETUVAR(ArmaFPV_OSD_Rssi, controlNull) ctrlSetText (FPV_SYM(0x01) + str _dbm);
    GETUVAR(ArmaFPV_OSD_Alt, controlNull) ctrlSetText (FPV_SYM(0x7F) + str _alt + FPV_SYM(0x0C));
    GETUVAR(ArmaFPV_OSD_Volt, controlNull) ctrlSetText ([FPV_SYM(_battSym) + ((_cell * FPV_BATT_CELLS) toFixed 1) + FPV_SYM(0x06), ""] select (_battState > 0 && { !_on }));
    GETUVAR(ArmaFPV_OSD_Mah, controlNull) ctrlSetText (([str round _mah, 4] call _pad) + FPV_SYM(0x07));
    GETUVAR(ArmaFPV_OSD_Amp, controlNull) ctrlSetText (([_amps toFixed 2, 6] call _pad) + FPV_SYM(0x9A));
    GETUVAR(ArmaFPV_OSD_Time, controlNull) ctrlSetText (FPV_SYM(0x9C) + (floor (_flown / 60) call _two) + ":" + ((_flown mod 60) call _two));
    GETUVAR(ArmaFPV_OSD_Warn, controlNull) ctrlSetText ([_warning, ""] select !_on);
}, FPV_OSD_TICK, [objNull]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_osdPFH, _pfh);
