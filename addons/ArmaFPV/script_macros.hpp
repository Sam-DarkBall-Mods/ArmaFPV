#ifndef ARMAFPV_SCRIPT_MACROS_HPP
#define ARMAFPV_SCRIPT_MACROS_HPP

#include "\x\cba\addons\main\script_macros_common.hpp"

#define GETMVAR(NAME,DEFAULT) (missionNamespace getVariable [#NAME, DEFAULT])
#define SETMVAR(NAME,VALUE) (missionNamespace setVariable [#NAME, VALUE])
#define GETUVAR(NAME,DEFAULT) (uiNamespace getVariable [#NAME, DEFAULT])
#define SETUVAR(NAME,VALUE) (uiNamespace setVariable [#NAME, VALUE])

#define FPV_FEET_PER_METER 3.28084
#define FPV_SPEED_SCALE 1
#define FPV_SPEED_MAX 60
#define FPV_ALT_MAX 120

#define FPV_SIGNAL_LOSS_THRESHOLD 0.05
#define FPV_SIGNAL_LOSS_DURATION 5
#define FPV_SIGNAL_UPDATE_INTERVAL 0.2
#define FPV_PPFX_UPDATE_INTERVAL 0.05
#define FPV_CONNECT_LOOP_INTERVAL 0.1
#define FPV_TIME_SYNC_INTERVAL 1

#define FPV_DRONE_TYPES ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP", "O_Crocus_AT_TI", "O_Crocus_AP_TI", "B_Crocus_AT_TI", "B_Crocus_AP_TI", "I_Crocus_AT_TI", "I_Crocus_AP_TI"]
#define FPV_DRONE_ITEMS ["Item_Crocus_AT", "Item_Crocus_AP", "Item_Crocus_AT_TI", "Item_Crocus_AP_TI"]
#define FPV_TERMINAL_TYPES ["B_UavTerminal", "O_UavTerminal", "I_UavTerminal"]

#endif
