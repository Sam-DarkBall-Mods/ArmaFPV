[ 
    "FPV_DefaultText",
    "EDITBOX",
    ["Default Text", "Enter the text"],
    "FPV Settings",
    "CROCUS",
    0
] call cba_settings_fnc_init;

// ["FPV Settings", "FPV_ManualDetonation", "Manual Detonation Key", ["player", [], -100, "[getConnectedUAV (missionNamespace getVariable [""bis_fnc_moduleRemoteControl_unit"", player])] call DB_fnc_fpv_onDestroy"], [35, [false, true, false]]] call cba_fnc_addKeybindToFleximenu;

if ((hasInterface && isServer) || (serverCommandAvailable "#kick")) then {
    [
        "FPV_isUavCaptive",
        "CHECKBOX",
        ["AI Cannot See FPV Drones", ""],
        "FPV Settings",
        true,
        1,
        { publicVariable "FPV_isUavCaptive" }
    ] call cba_settings_fnc_init;

    [
        "FPV_MaxFlightDistance", 
        "SLIDER",   
        ["Max Flight Distance", ""], 
        "FPV Settings", 
        [1500, 12000, 1500, 0],
        1,
        { publicVariable "FPV_MaxFlightDistance" }
    ] call cba_settings_fnc_init;
};



