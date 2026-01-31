/*
	ArmaFPV: FPV connection handler.
	Purpose: manages OSD lifecycle while controlling FPV drones.
	Context: client, runs post-init.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, FPV_DRONE_TYPES);
private _loopInterval = GETMVAR(DB_fpv_connectLoopInterval, FPV_CONNECT_LOOP_INTERVAL);

private _prevPfh = GETMVAR(DB_fpv_connectPFH, -1);
if (_prevPfh >= 0) then {
	[_prevPfh] call CBA_fnc_removePerFrameHandler;
};

private _pfhId = [{
	params ["_args", "_pfhId"];
	_args params ["_droneTypes"];

	private _player = GETMVAR(bis_fnc_moduleRemoteControl_unit, player);
	if (isNull _player) exitWith {};

	private _uav = getConnectedUAV _player;
	private _uavType = typeOf _uav;
	private _lastUav = GETMVAR(DB_fpv_lastUav, objNull);

	if (!isNull _lastUav && { _uav isNotEqualTo _lastUav }) then {
		_lastUav setVariable ["DB_jammer_customUavBehavior", false, true];
	};

	if (isNull _uav) then {
		SETMVAR(DB_fpv_lastUav, objNull);
	} else {
		SETMVAR(DB_fpv_lastUav, _uav);
	};

	private _isFpv = (_uavType in _droneTypes) && { cameraOn isEqualTo _uav } && { cameraView != "EXTERNAL" };
	private _wasControl = GETMVAR(ArmaFPV_isControl, false);
	private _uiMissing = isNull GETUVAR(ArmaFPV_SignalPicture, controlNull);

	if (_isFpv) then {
		_uav setVariable ["DB_jammer_customUavBehavior", true, true];

		if (!_wasControl) then {
			private _currentHud = shownHUD;
			if ((count _currentHud) == 11) then {
				SETMVAR(ArmaFPV_savedHUD, _currentHud);
			} else {
				SETMVAR(ArmaFPV_savedHUD, []);
			};
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
		};

		if (!_wasControl || _uiMissing) then {
			SETMVAR(ArmaFPV_isControl, true);
			call DB_fnc_fpv_createDialog;
		};
	} else {
		if (_wasControl) then {
			SETMVAR(ArmaFPV_isControl, false);
			call DB_fnc_fpv_destroyUI;
			private _savedHud = GETMVAR(ArmaFPV_savedHUD, []);
			if ((count _savedHud) == 11) then {
				showHUD _savedHud;
			};
			SETMVAR(ArmaFPV_savedHUD, []);
		};
	};
}, _loopInterval, [_droneTypes]] call CBA_fnc_addPerFrameHandler;

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
