/*
	ArmaFPV: set PPFX input.
	Purpose: updates signal quality and context for the PPFX module.
	Context: scheduled or unscheduled.
	Params:
		0: signalQuality (Number, 0..1)
		1: context (Array, optional)
	Returns: nothing.
*/

params [
	"_signalQuality",
	["_context", [], [[]]]
];

private _q = (_signalQuality max 0) min 1;
missionNamespace setVariable ["DB_fpv_ppfx_input", _q];

if (_context isNotEqualTo []) then {
	missionNamespace setVariable ["DB_fpv_ppfx_context", _context];
};
