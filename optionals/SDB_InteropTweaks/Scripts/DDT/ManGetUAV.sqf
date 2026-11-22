/*
    DDT_fnc_ManGetUAV
    Wraps DDT drone class lookup and resolves Crocus items to the side's drone class.
    Author: DarkBall
*/

params ["_man", "_type"];

private _original = missionNamespace getVariable ["DDT_fnc_ManGetUAV_original", {}];
if (_original isEqualTo {}) exitWith { "" };

private _droneClass = _this call _original;
if !(_droneClass isEqualType "") exitWith { _droneClass };
if (_droneClass isEqualTo "") exitWith { "" };

private _upper = toUpper _droneClass;
if ((_upper find "ITEM_CROCUS_") isNotEqualTo 0) exitWith { _droneClass };

private _resolve = missionNamespace getVariable ["SDB_fnc_ddt_resolveCrocusClass", {}];
if (_resolve isEqualTo {}) exitWith { _droneClass };

[_droneClass, side _man] call _resolve;
