params ["_uav"];

waitUntil {time > 1};

_uav disableAI "ALL";
_uav setVariable ["DB_jammer_customUavBehavior", true, true];

