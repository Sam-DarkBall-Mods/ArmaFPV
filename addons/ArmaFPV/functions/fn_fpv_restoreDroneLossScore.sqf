params ["_operator"];

if (!isServer) exitWith {};
if (isNull _operator) exitWith {};
if !(isPlayer _operator) exitWith {};

// Air score is weighted as 5 points, so subtract 4 to only cancel the -1 loss.
_operator addPlayerScores [0, 0, 0, 1, 0];
_operator addScore -4;
