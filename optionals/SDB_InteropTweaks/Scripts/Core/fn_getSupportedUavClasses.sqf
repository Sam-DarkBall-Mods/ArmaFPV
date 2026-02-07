/*
	Build normalized list of supported UAV vehicle classes.
	Returns only CfgVehicles classes that are Air and can be used by autonomy runtime checks.
*/

private _cached = missionNamespace getVariable ["SDB_it_supportedUavClasses", []];
if !(_cached isEqualTo []) exitWith {
	+_cached
};

private _classMapFn = missionNamespace getVariable ["SDB_it_fnc_getInteropClassMap", { [[], []] }];
private _classMap = call _classMapFn;
private _raw = +(_classMap param [0, [], [[]]]);
_raw append (_classMap param [1, [], [[]]]);

private _supported = [];
{
	private _cfg = configFile >> "CfgVehicles" >> _x;
	if (isClass _cfg && {_x isKindOf "Air"}) then {
		_supported pushBackUnique _x;
	};
} forEach _raw;

private _resolveFn = missionNamespace getVariable ["SDB_fnc_ddt_resolveCrocusClass", missionNamespace getVariable ["SDB_it_fnc_resolveCrocusClass", {}]];
if !(_resolveFn isEqualTo {}) then {
	private _itemClasses = _raw select { (toUpper _x) find "ITEM_CROCUS_" == 0 };
	if (_itemClasses isEqualTo []) then {
		_itemClasses = [
			"Item_Crocus_AP",
			"Item_Crocus_AP_TI",
			"Item_Crocus_AT",
			"Item_Crocus_AT_TI"
		];
	};

	{
		private _itemClass = _x;
		{
			private _resolved = [_itemClass, _x] call _resolveFn;
			private _cfgResolved = configFile >> "CfgVehicles" >> _resolved;
			if (_resolved != _itemClass && { isClass _cfgResolved } && { _resolved isKindOf "Air" }) then {
				_supported pushBackUnique _resolved;
			};
		} forEach [west, east, resistance];
	} forEach _itemClasses;
};

missionNamespace setVariable ["SDB_it_supportedUavClasses", _supported];
+_supported
