/*
    SDB_it_fnc_patchArmaFPVMapKeyInterop
    Lets the map key open the map while watching an autonomous Crocus.
    Author: DarkBall
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (SDB_GET_MVAR(SDB_it_armafpvMapKeyPatchQueued, false)) exitWith {};
SDB_SET_MVAR(SDB_it_armafpvMapKeyPatchQueued, true);

if (!hasInterface) exitWith {};

private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
if !(_log isEqualTo {}) then {
	["ArmaFPV map-key patch queued", []] call _log;
};

[
	{ !isNull findDisplay 46 && {!isNil "DB_fpv_keyEHAdded"} },
	{
		if (SDB_GET_MVAR(SDB_it_armafpvMapKeyPatchApplied, false)) exitWith {};
		SDB_SET_MVAR(SDB_it_armafpvMapKeyPatchApplied, true);

		private _display = findDisplay 46;
		if (isNull _display) exitWith {};

		private _ehId = _display displayAddEventHandler ["KeyDown", {
			params ["_display", "_dikCode"];

			if !(_dikCode in (actionKeys "showMap")) exitWith { false };
			if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith { false };

			private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
			if (isNull _player) exitWith { false };

			private _uav = getConnectedUAV _player;
			if (isNull _uav) exitWith { false };
			if !(_uav getVariable ["SDB_autonomyEnabled", false]) exitWith { false };

			if (!visibleMap && { "ItemMap" in assignedItems _player }) then { openMap [true, false]; };
			true
		}];

		SDB_SET_MVAR(SDB_it_armafpvMapKeyPatchEhId, _ehId);

		private _log = missionNamespace getVariable ["SDB_it_fnc_log", {}];
		if !(_log isEqualTo {}) then {
			["ArmaFPV map-key patch applied", [_ehId]] call _log;
		};
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
