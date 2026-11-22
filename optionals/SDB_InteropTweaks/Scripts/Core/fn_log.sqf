/*
    SDB_it_fnc_log
    Writes an SDB Interop Tweaks line to the RPT.
    Author: DarkBall
*/

params ["_message", ["_payload", []]];

private _payloadText = if (_payload isEqualType "") then {
	_payload
} else {
	str _payload
};

diag_log format ["[SDB_InteropTweaks] %1 | %2", _message, _payloadText];
