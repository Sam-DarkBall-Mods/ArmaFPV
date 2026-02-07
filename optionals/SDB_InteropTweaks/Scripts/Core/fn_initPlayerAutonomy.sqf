/*
	Player-side autonomy state bootstrap.
	Uses CBA player event type "unit" to refresh action after respawn/teamswitch.
*/

#include "\SDB_InteropTweaks\script_macros.hpp"

if (!hasInterface) exitWith {};

[
	{ !isNull player },
	{
		private _fnToggle = SDB_GET_MVAR(SDB_it_fnc_addAutonomyToggleAction, {});
		if (_fnToggle isEqualTo {}) exitWith {};

		if (isNil { player getVariable "SDB_autonomyNextLaunch" }) then {
			player setVariable [
				"SDB_autonomyNextLaunch",
				missionNamespace getVariable ["sdbAutoEnableByDefault", false],
				true
			];
		};
		[player] call _fnToggle;

		if ((SDB_GET_MVAR(SDB_it_playerUnitEhId, -1)) >= 0) exitWith {};

		private _ehId = [
			"unit",
			{
				private _newUnit = _this param [0, objNull, [objNull]];
				private _oldUnit = _this param [1, objNull, [objNull]];

				if (!isNull _oldUnit) then {
					private _oldAction = _oldUnit getVariable ["SDB_autonomyToggleAction", -1];
					if (_oldAction >= 0) then {
						_oldUnit removeAction _oldAction;
						_oldUnit setVariable ["SDB_autonomyToggleAction", -1];
					};
				};

				if (isNull _newUnit) exitWith {};
				if !(isPlayer _newUnit) exitWith {};

				if (isNil { _newUnit getVariable "SDB_autonomyNextLaunch" }) then {
					_newUnit setVariable [
						"SDB_autonomyNextLaunch",
						missionNamespace getVariable ["sdbAutoEnableByDefault", false],
						true
					];
				};

				private _fn = missionNamespace getVariable ["SDB_it_fnc_addAutonomyToggleAction", {}];
				if (_fn isEqualTo {}) exitWith {};
				[_newUnit] call _fn;
			},
			true
		] call CBA_fnc_addPlayerEventHandler;

		SDB_SET_MVAR(SDB_it_playerUnitEhId, _ehId);
	},
	[]
] call CBA_fnc_waitUntilAndExecute;
