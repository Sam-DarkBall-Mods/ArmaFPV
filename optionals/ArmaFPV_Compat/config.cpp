class CfgPatches
{
	class ArmaFPV_Data_Compat
	{
		author="DarkBall & Sam";
		name="ArmaFPV";
		url="";
		requiredAddons[]=
		{
			"A3_Data_F_AoW_Loadorder",
			"ArmaFPV_Data"
		};
		requiredVersion=0.1;
		units[]={};
		weapons[]={};
	};
};
class CfgAmmo
{
	class R_PG32V_F;
	class FPV_RPG42_AT: R_PG32V_F
	{
		hit=5;
		indirectHit=5;
		indirectHitRange=1;
		fuseDistance=1;
		warheadName="HEAT";
		submunitionAmmo="FPV_RPG42_AT_Penetrator";
		submunitionDirectionType="SubmunitionModelDirection";
		submunitionInitSpeed=1053;
		submunitionParentSpeedCoef=0;
		submunitionInitialOffset[]={0,0,-0.1};
		triggerOnImpact=1;
		deleteParentWhenTriggered=0;
	};
	class ammo_Penetrator_Base;
	class FPV_RPG42_AT_Penetrator: ammo_Penetrator_Base
	{
		caliber=30;
		hit=240;
	};
};
class cfgMods
{
	author="[SEAL TEAM] DarkBall";
	timepacked="1706542334";
};
