/*
	ArmaFPV: create OSD interface.
	Purpose: creates the UI layer and starts battery/signal/time handlers.
	Context: client when entering FPV control.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _layer = ("DB_FPV_Layer" call BIS_fnc_rscLayer);
diag_log text format ["[ArmaFPV] createDialog: layer=%1 time=%2", _layer, diag_tickTime];
_layer cutRsc ["ArmaFPV_Dialog", "PLAIN"];

SETMVAR(DB_FPV_Layer_ID, _layer);

call DB_fnc_fpv_handleSettings;
call DB_fnc_fpv_handleBattery;
call DB_fnc_fpv_handleSignal;
call DB_fnc_fpv_handleTime;
