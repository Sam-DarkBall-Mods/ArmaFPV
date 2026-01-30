/*
	ArmaFPV: FPV connection handler.
	Purpose: manages OSD lifecycle while controlling FPV drones.
	Context: client, runs post-init.
	Params: none.
	Returns: nothing.
*/

#include "\ArmaFPV\script_macros.hpp"

if (!hasInterface) exitWith {};

private _droneTypes = GETMVAR(DB_fpv_droneTypes, ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP", "O_Crocus_AT_TI", "O_Crocus_AP_TI", "B_Crocus_AT_TI", "B_Crocus_AP_TI", "I_Crocus_AT_TI", "I_Crocus_AP_TI"]);
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
	private _isFpv = (_uavType in _droneTypes) && { cameraView == "GUNNER" } && { (typeOf cameraOn) in _droneTypes };
	private _wasControl = GETMVAR(ArmaFPV_isControl, false);

	if (_isFpv) then {
		if (!_wasControl) then {
			SETMVAR(ArmaFPV_isControl, true);
			call DB_fnc_fpv_createDialog;
		};
	} else {
		if (_wasControl) then {
			SETMVAR(ArmaFPV_isControl, false);
			call DB_fnc_fpv_destroyUI;
		};
	};
}, _loopInterval, [_droneTypes]] call CBA_fnc_addPerFrameHandler;

SETMVAR(DB_fpv_connectPFH, _pfhId);

[{
	!isNull findDisplay 46
}, {
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
}, []] call CBA_fnc_waitUntilAndExecute;
