/*
	ArmaFPV: UI/effects cleanup.
	Purpose: hides the OSD and removes post-process effects.
	Context: client when leaving FPV control.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

private _cleanupToken = diag_frameNo;
SETMVAR(DB_fpv_pendingCleanupToken, _cleanupToken);

private _clearEffects = {
	params ["_token"];

	private _activeToken = GETMVAR(DB_fpv_pendingCleanupToken, -1);
	if (_token isNotEqualTo _activeToken) exitWith {};
	if (GETMVAR(ArmaFPV_isControl, false)) exitWith {};

	private _layer = GETMVAR(DB_FPV_Layer_ID, -1);
	if (_layer >= 0) then {
		_layer cutText ["", "PLAIN"];
	};

	call DB_fnc_fpv_ppfx_stop;
};

[_cleanupToken] call _clearEffects;

[
	{
		params ["_token", "_clearEffects"];
		[_token] call _clearEffects;
	},
	[_cleanupToken, _clearEffects],
	1
] call CBA_fnc_waitAndExecute;
