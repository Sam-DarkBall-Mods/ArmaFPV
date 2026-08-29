#include "\ArmaFPV\script_macros.hpp"

SETMVAR(DB_fpv_pendingCleanupToken, -1);

private _layer = ("DB_FPV_Layer" call BIS_fnc_rscLayer);
_layer cutRsc ["ArmaFPV_Dialog", "PLAIN"];

SETMVAR(DB_FPV_Layer_ID, _layer);

call DB_fnc_fpv_handleSettings;
call DB_fnc_fpv_handleBattery;
call DB_fnc_fpv_handleSignal;
call DB_fnc_fpv_handleTime;
