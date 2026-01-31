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

private _state = [true, [], []];

private _pfhId = [{
	params ["_args", "_pfhId"];
	_args params ["_droneTypes", "_state"];
	_state params ["_hudShown", "_lastLayerParams", "_lastCutLayers"];

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
	private _layerId = GETMVAR(DB_FPV_Layer_ID, -1);

	if (_isFpv) then {
		_uav setVariable ["DB_jammer_customUavBehavior", true, true];
		private _shown = shownHUD;
		private _scriptedHud = false;
		if (_shown isEqualType []) then {
			_shown params ["_hud"];
			_scriptedHud = _hud;
		};
		if (_scriptedHud != _hudShown) then {
			_hudShown = _scriptedHud;
			_state set [0, _hudShown];
			diag_log text format [
				"[ArmaFPV] showHUD change while control=true: scriptedHUD=%1 full=%2 time=%3",
				_scriptedHud,
				_shown,
				diag_tickTime
			];
		};

		if (_layerId >= 0) then {
			private _layerParams = activeTitleEffectParams _layerId;
			if !(_layerParams isEqualTo _lastLayerParams) then {
				_state set [1, _layerParams];
				diag_log text format [
					"[ArmaFPV] layer params change: layer=%1 params=%2 time=%3",
					_layerId,
					_layerParams,
					diag_tickTime
				];
			};
		};

		private _cutLayers = allCutLayers;
		if !(_cutLayers isEqualTo _lastCutLayers) then {
			_state set [2, _cutLayers];
			diag_log text format [
				"[ArmaFPV] allCutLayers change: %1 time=%2",
				_cutLayers,
				diag_tickTime
			];
		};
		if (!_wasControl || _uiMissing) then {
			if (_uiMissing && _wasControl) then {
				private _shown = shownHUD;
				private _layerParams = if (_layerId >= 0) then { activeTitleEffectParams _layerId } else { [] };
				diag_log text format [
					"[ArmaFPV] UI missing while control=true: uav=%1 camOn=%2 camView=%3 shownHUD=%4 layer=%5 layerParams=%6 cutLayers=%7 time=%8",
					_uav,
					cameraOn,
					cameraView,
					_shown,
					_layerId,
					_layerParams,
					allCutLayers,
					diag_tickTime
				];
			};
			SETMVAR(ArmaFPV_isControl, true);
			call DB_fnc_fpv_createDialog;
		};
	} else {
		if (_wasControl) then {
			SETMVAR(ArmaFPV_isControl, false);
			call DB_fnc_fpv_destroyUI;
		};
	};
}, _loopInterval, [_droneTypes, _state]] call CBA_fnc_addPerFrameHandler;

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
