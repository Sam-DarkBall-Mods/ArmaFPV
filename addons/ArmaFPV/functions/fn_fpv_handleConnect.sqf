#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, FPV_DRONE_TYPES);
private _loopInterval = GETMVAR(DB_fpv_connectLoopInterval, FPV_CONNECT_LOOP_INTERVAL);
private _controlGracePeriod = GETMVAR(DB_fpv_controlGracePeriod, 0.75);

private _prevPfh = GETMVAR(DB_fpv_connectPFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	params ["_args", "_pfhId"];
	_args params ["_droneTypes", "_controlGracePeriod"];

	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	if (isNull _player) exitWith {};

	private _now = diag_tickTime;
	private _uav = getConnectedUAV _player;
	private _uavType = typeOf _uav;
	private _lastUav = GETMVAR(DB_fpv_lastUav, objNull);
	private _uavChanged = !isNull _lastUav && { _uav isNotEqualTo _lastUav };

	if (_uavChanged) then {
		_lastUav setVariable ["DB_jammer_customUavBehavior", false, true];
		SETMVAR(DB_fpv_controlGraceUntil, -1);
	};

	if (isNull _uav) then {
		SETMVAR(DB_fpv_lastUav, objNull);
		SETMVAR(DB_fpv_controlGraceUntil, -1);
	} else {
		SETMVAR(DB_fpv_lastUav, _uav);
	};

	private _cameraBound = cameraOn isEqualTo _uav;
	private _cameraMode = cameraView;
	private _directControlActive = (_uavType in _droneTypes) && { _cameraBound } && { _cameraMode in ["GUNNER", "EXTERNAL"] };
	private _wasControl = GETMVAR(ArmaFPV_isControl, false);
	private _graceUntil = GETMVAR(DB_fpv_controlGraceUntil, -1);

	if (_directControlActive) then {
		_graceUntil = _now + _controlGracePeriod;
		SETMVAR(DB_fpv_controlGraceUntil, _graceUntil);
	};

	private _connectedControl = (_uavType in _droneTypes) && { !isNull _uav };
	private _graceControlActive = _wasControl && { _connectedControl } && { _now <= _graceUntil };
	private _controlActive = _directControlActive || { _graceControlActive };
	private _uiActive = _controlActive && { _cameraBound } && { _cameraMode == "GUNNER" };
	private _uiMissing = isNull GETUVAR(ArmaFPV_SignalPicture, controlNull);
	private _uiNeedsReset = _uiMissing || { _uavChanged };
	private _hudApplied = GETMVAR(ArmaFPV_hudApplied, false);

	if (_controlActive) then {
		if (!_wasControl || { _uavChanged }) then {
			_uav setVariable ["DB_fpv_lastSignalUpdate", nil];
			_uav setVariable ["DB_fpv_timeInJammerZone", 0];
			_uav setVariable ["DB_fpv_jammerLowTime", 0];
		};

		_uav setVariable ["DB_jammer_customUavBehavior", true, true];

		if (!_wasControl) then {
			private _currentHud = shownHUD;
			if ((count _currentHud) == 11) then {
				SETMVAR(ArmaFPV_savedHUD, _currentHud);
			} else {
				SETMVAR(ArmaFPV_savedHUD, []);
			};
			SETMVAR(ArmaFPV_hudApplied, false);
		};

		if (!_wasControl) then {
			SETMVAR(ArmaFPV_isControl, true);
		};

		if (_uiActive) then {
			if (!_hudApplied) then {
				showHUD [
					true,  // scriptedHUD
					false, // info
					true,  // radar
					true,  // compass
					true,  // direction
					true,  // menu
					true,  // group
					true,  // cursors
					true,  // panels
					true,  // kills
					true   // showIcon3D
				];
				SETMVAR(ArmaFPV_hudApplied, true);
			};
			if (_uiNeedsReset) then {
				call DB_fnc_fpv_createDialog;
			};
		} else {
			if (!_uiMissing) then {
				call DB_fnc_fpv_destroyUI;
			};
			if (_hudApplied) then {
				private _savedHud = GETMVAR(ArmaFPV_savedHUD, []);
				if ((count _savedHud) == 11) then {
					showHUD _savedHud;
				};
				SETMVAR(ArmaFPV_hudApplied, false);
			};
		};
	} else {
		if (_wasControl) then {
			SETMVAR(ArmaFPV_isControl, false);
			SETMVAR(DB_fpv_controlGraceUntil, -1);
			call DB_fnc_fpv_destroyUI;
			private _savedHud = GETMVAR(ArmaFPV_savedHUD, []);
			if ((count _savedHud) == 11) then {
				showHUD _savedHud;
			};
			SETMVAR(ArmaFPV_savedHUD, []);
			SETMVAR(ArmaFPV_hudApplied, false);
		};
	};
}, _loopInterval, [_droneTypes, _controlGracePeriod]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_connectPFH, _pfhId);

[
	{ !isNull findDisplay 46 },
	{
		if (GETMVAR(DB_fpv_keyEHAdded, false)) exitWith {};
		SETMVAR(DB_fpv_keyEHAdded, true);

		findDisplay 46 displayAddEventHandler ["KeyDown", {
			private _handled = false;

			if (GETMVAR(ArmaFPV_isControl, false)) then {
				if (inputAction "showMap" > 0) then {
					_handled = true;
				};
			};

			_handled;
		}];
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
