/*
	Add or refresh local player action that toggles autonomy for next launch.
*/

params ["_unit"];
if (isNull _unit) exitWith {};

private _oldAction = _unit getVariable ["SDB_autonomyToggleAction", -1];
if (_oldAction >= 0) then {
	_unit removeAction _oldAction;
	_unit setVariable ["SDB_autonomyToggleAction", -1];
};

private _state = _unit getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]];
private _label = if (_state) then { "ON" } else { "OFF" };
private _title = format ["SDB FPV: Toggle Autonomy [%1]", _label];

private _id = _unit addAction [
	_title,
	{
		params ["_target", "_caller", "_actionId"];
		if (_caller isNotEqualTo _target) exitWith {};

		private _newState = !(_caller getVariable ["SDB_autonomyNextLaunch", missionNamespace getVariable ["sdbAutoEnableByDefault", false]]);
		_caller setVariable ["SDB_autonomyNextLaunch", _newState, true];

		private _newLabel = if (_newState) then { "ON" } else { "OFF" };
		_target setUserActionText [_actionId, format ["SDB FPV: Toggle Autonomy [%1]", _newLabel]];
		systemChat format ["SDB FPV autonomy: %1", _newLabel];
	},
	[],
	1.5,
	false,
	true,
	"",
	"true"
];

_unit setVariable ["SDB_autonomyToggleAction", _id];
