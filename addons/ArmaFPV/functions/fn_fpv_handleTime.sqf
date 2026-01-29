/*
	ArmaFPV: flight time timer.
	Purpose: shows the control time on the OSD.
	Context: client, active only while controlling the drone.
	Params: none.
	Returns: nothing.
*/

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _uav = getConnectedUAV _player;

if (isNull _player) exitWith {};
if (isNull _uav) exitWith {};

if (isNil { _uav getVariable ["DB_fpv_savedTime", nil] }) then {
	_uav setVariable ["DB_fpv_savedTime", 0];
};

private _savedTime = _uav getVariable ["DB_fpv_savedTime", 0];
private _startTime = time - _savedTime;

addMissionEventHandler ["EachFrame", {
	_thisArgs params ["_startTime", "_uav"];

	if (isNull _uav) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};

	private _timeElapsed = time - _startTime;
	private _controlText = uiNameSpace getVariable ["ArmaFPV_OnTimeText", controlNull];

	if (!isNull _controlText) then {
		_controlText ctrlSetText ([_timeElapsed, "MM:SS"] call BIS_fnc_secondsToString);
	};

	_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];

	if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
}, [_startTime, _uav]];
