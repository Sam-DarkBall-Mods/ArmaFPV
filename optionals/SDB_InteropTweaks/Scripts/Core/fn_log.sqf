/*
	Interop diagnostics logger.
*/

params ["_message", ["_payload", []]];

private _payloadText = if (_payload isEqualType "") then {
	_payload
} else {
	str _payload
};

diag_log format ["[SDB_InteropTweaks] %1 | %2", _message, _payloadText];
