/*
	ArmaFPV: UI/effects cleanup.
	Purpose: hides the OSD and removes post-process effects.
	Context: client when leaving FPV control.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _clearEffects = {
	private _layer = GETMVAR(DB_FPV_Layer_ID, -1);
	if (_layer >= 0) then {
		diag_log text format ["[ArmaFPV] destroyUI: layer=%1 time=%2", _layer, diag_tickTime];
		_layer cutText ["", "PLAIN"];
	};

	call DB_fnc_fpv_ppfx_stop;
};

call _clearEffects;

[
	{
		params ["_clearEffects"];
		call _clearEffects;
	},
	[_clearEffects],
	1
] call CBA_fnc_waitAndExecute;
