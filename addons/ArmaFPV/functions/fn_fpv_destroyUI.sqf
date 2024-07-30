private _delEffects = {
	private _layer = missionNamespace getVariable ["DB_FPV_Layer_ID", -1];

	_layer cutText ["", "PLAIN"];

	private _ppEffect = missionNameSpace getVariable ["DB_fpv_ppEffect", []];
		
	if (_ppEffect isNotEqualTo []) then {
		{
			ppEffectDestroy _x;
		} forEach _ppEffect;
	};

	if !(isNil "PP_chrom") then {
		ppEffectDestroy PP_chrom;
	};

	if !(isNil "PP_wetD") then {
		ppEffectDestroy PP_wetD;
	};

	if !(isNil "PP_colorC") then {
		ppEffectDestroy PP_colorC;
	};

	if !(isNil "PP_dynamic") then {
		ppEffectDestroy PP_dynamic;
	};

	if !(isNil "PP_film") then {
		ppEffectDestroy PP_film;
	};
};

call _delEffects;

sleep 1;

call _delEffects;