#ifndef ARMAFPV_SCRIPT_MACROS_HPP
#define ARMAFPV_SCRIPT_MACROS_HPP

#include "\x\cba\addons\main\script_macros_common.hpp"

#define GETMVAR(NAME,DEFAULT) (missionNamespace getVariable [#NAME, DEFAULT])
#define SETMVAR(NAME,VALUE) (missionNamespace setVariable [#NAME, VALUE])
#define GETUVAR(NAME,DEFAULT) (uiNamespace getVariable [#NAME, DEFAULT])
#define SETUVAR(NAME,VALUE) (uiNamespace setVariable [#NAME, VALUE])

#define FPV_SPEED_SCALE 1
#define FPV_SPEED_MAX 60
#define FPV_ALT_MAX 120

#define FPV_SIGNAL_LOSS_THRESHOLD 0.05
#define FPV_SIGNAL_LOSS_DURATION 5
#define FPV_SIGNAL_UPDATE_INTERVAL 0.1
#define FPV_PPFX_UPDATE_INTERVAL 0.05
#define FPV_CONNECT_LOOP_INTERVAL 0.1
#define FPV_TIME_SYNC_INTERVAL 1
#define FPV_CLOSE_DISTANCE 75
#define FPV_CLOSE_TERRAIN_MIN 0.65

#define FPV_BATT_CELLS 6
#define FPV_BATT_CAPACITY 5000
#define FPV_BATT_HOVER_AMPS 21
#define FPV_BATT_SAG 0.004
#define FPV_VBAT_MIN 3.3
#define FPV_VBAT_WARN 3.5
#define FPV_OSD_TICK 0.1
#define FPV_OSD_BLINK 0.2
#define FPV_LQ_ALARM 80
#define FPV_SYM(CODE) (toString [57344 + CODE])
#define FPV_FX_FRAME 0.04
#define FPV_FX_FRAMES 8

#define FPV_DRONE_TYPES ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP", "O_Crocus_AT_TI", "O_Crocus_AP_TI", "B_Crocus_AT_TI", "B_Crocus_AP_TI", "I_Crocus_AT_TI", "I_Crocus_AP_TI"]
#define FPV_DRONE_ITEMS ["Item_Crocus_AT", "Item_Crocus_AP", "Item_Crocus_AT_TI", "Item_Crocus_AP_TI"]
#endif
