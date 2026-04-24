/*
	ArmaFPV: restore operator score after FPV loss.
	Purpose: neutralizes the engine aircraft-loss score entry for disposable FPV drones.
	Context: server.
	Params: [_operator]
		_operator - player unit that controlled the drone.
	Returns: nothing.
*/

params ["_operator"];

if (!isServer) exitWith {};
if (isNull _operator) exitWith {};
if !(isPlayer _operator) exitWith {};

// Air score is weighted as 5 points, so subtract 4 to only cancel the -1 loss.
_operator addPlayerScores [0, 0, 0, 1, 0];
_operator addScore -4;
