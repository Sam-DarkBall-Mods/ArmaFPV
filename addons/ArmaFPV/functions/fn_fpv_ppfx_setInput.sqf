#include "\ArmaFPV\script_macros.hpp"

params [
	"_signalQuality",
	["_context", [], [[]]]
];

private _q = (_signalQuality max 0) min 1;
SETMVAR(DB_fpv_ppfx_input, _q);

if (_context isNotEqualTo []) then {
	SETMVAR(DB_fpv_ppfx_context, _context);
};
