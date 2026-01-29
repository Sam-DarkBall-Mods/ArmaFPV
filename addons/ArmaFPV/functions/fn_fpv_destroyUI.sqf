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

	private _ppEffect = missionNamespace getVariable ["DB_fpv_ppEffect", []];
	if (_ppEffect isNotEqualTo []) then {
		{ ppEffectDestroy _x; } forEach _ppEffect;
		missionNamespace setVariable ["DB_fpv_ppEffect", []];
	};

	private _specialEffects = missionNamespace getVariable ["DB_fpv_specialEffects", []];
	if (_specialEffects isNotEqualTo []) then {
		{ ppEffectDestroy _x; } forEach _specialEffects;
		missionNamespace setVariable ["DB_fpv_specialEffects", []];
	};
};

call _clearEffects;

sleep 1;

call _clearEffects;
