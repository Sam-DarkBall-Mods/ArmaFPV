/*
	ArmaFPV: set PPFX input.
	Purpose: updates signal quality, profile and context for the PPFX module.
	Context: scheduled or unscheduled.
	Params:
		0: signalQuality (Number, 0..1)
		1: profile (String, optional) "ANALOG" or "DIGITAL"
		2: context (Array, optional)
	Returns: nothing.
*/

params [
	"_signalQuality",
	["_profile", "", [""]],
	["_context", [], [[]]]
];

private _q = (_signalQuality max 0) min 1;
missionNamespace setVariable ["DB_fpv_ppfx_input", _q];

if (_profile isNotEqualTo "") then {
	missionNamespace setVariable ["DB_fpv_ppfx_profile", _profile];
};

if (_context isNotEqualTo []) then {
	missionNamespace setVariable ["DB_fpv_ppfx_context", _context];
};
