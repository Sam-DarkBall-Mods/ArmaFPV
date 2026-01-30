#ifndef ARMAFPV_SCRIPT_MACROS_HPP
#define ARMAFPV_SCRIPT_MACROS_HPP

#include "\x\cba\addons\main\script_macros_common.hpp"

#define GETMVAR(NAME,DEFAULT) (missionNamespace getVariable [#NAME, DEFAULT])
#define SETMVAR(NAME,VALUE) (missionNamespace setVariable [#NAME, VALUE])
#define GETUVAR(NAME,DEFAULT) (uiNamespace getVariable [#NAME, DEFAULT])
#define SETUVAR(NAME,VALUE) (uiNamespace setVariable [#NAME, VALUE])

#define FPV_FEET_PER_METER 3.28084
#define FPV_SPEED_SCALE 100
#define FPV_SPEED_MAX 3000
#define FPV_ALT_MAX 120

#define FPV_SIGNAL_LOSS_THRESHOLD 0.05
#define FPV_SIGNAL_LOSS_DURATION 5
#define FPV_SIGNAL_UPDATE_INTERVAL 0.2
#define FPV_CONNECT_LOOP_INTERVAL 0.1

#endif
