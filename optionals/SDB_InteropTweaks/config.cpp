class CfgPatches
{
	class SDB_InteropTweaks
	{
		author = "DarkBall";
		name = "SDB Interop Tweaks";
		units[] = {};
		weapons[] = {};
		requiredAddons[] =
		{
			"DrongosDroneTweaks",
			"ArmaFPV_Data",
			"cba_main",
			"cba_settings"
		};
		requiredVersion = 0.1;
	};
};

class Extended_PostInit_EventHandlers
{
	SDB_InteropTweaks_postInit = "execVM '\SDB_InteropTweaks\Scripts\Start.sqf'";
};
