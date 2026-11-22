/*
    DB_fnc_fpv_ppfx_setInput
    Feeds the link quality and flight context to the analog video effects.
    Author: DarkBall
*/
#include "\ArmaFPV\script_macros.hpp"

params [
	"_signalQuality",
	["_context", [], [[]]]
];

private _q = (_signalQuality max 0) min 1;
SETMVAR(DB_fpv_ppfx_drop, GETMVAR(DB_fpv_ppfx_drop, 0) max (GETMVAR(DB_fpv_ppfx_input, _q) - _q));
SETMVAR(DB_fpv_ppfx_input, _q);

if (_context isNotEqualTo []) then {
	SETMVAR(DB_fpv_ppfx_context, _context);
};
