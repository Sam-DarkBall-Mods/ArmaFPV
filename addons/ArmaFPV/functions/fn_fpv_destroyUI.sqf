/*
	ArmaFPV: UI/effects cleanup.
	Purpose: hides the OSD and removes post-process effects.
	Context: client when leaving FPV control.
	Params: none.
	Returns: nothing.
*/

private _clearEffects = {
	private _layer = missionNamespace getVariable ["DB_FPV_Layer_ID", -1];
	if (_layer >= 0) then {
		_layer cutText ["", "PLAIN"];
	};

	call DB_fnc_fpv_ppfx_stop;
};

call _clearEffects;

sleep 1;

call _clearEffects;
