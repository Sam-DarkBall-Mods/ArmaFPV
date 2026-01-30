class CfgPatches
{
	class ArmaFPV_Data
	{
		author="DarkBall & Sam";
		name="ArmaFPV";
		url="";
		requiredAddons[]=
		{
			"A3_Data_F_AoW_Loadorder",
			"A3_Data_F",
			"A3_Drones_F",
			"cba_settings"
		};
		requiredVersion=0.1;
		units[]=
		{
			"O_Crocus_AT",
			"O_Crocus_AP",
			"B_Crocus_AT",
			"B_Crocus_AP",
			"I_Crocus_AT",
			"I_Crocus_AP",
			"O_Crocus_AT_TI",
			"O_Crocus_AP_TI",
			"B_Crocus_AT_TI",
			"B_Crocus_AP_TI",
			"I_Crocus_AT_TI",
			"I_Crocus_AP_TI",
			"FPV_Retranslator"
		};
		weapons[]={};
	};
};

#include "includes\ArmaFPV_interface.hpp"
#include "includes\CfgAmmo.hpp"
#include "includes\CfgFontFamilies.hpp"
#include "includes\CfgFunctions.hpp"
#include "includes\CfgMagazines.hpp"
#include "includes\CfgVehicles.hpp"
#include "includes\Extended_PreInit_EventHandlers.hpp"
#include "includes\Extended_PostInit_EventHandlers.hpp"
