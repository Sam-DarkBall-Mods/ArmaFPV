#include "ArmaFPV_config_macros.hpp"

class CfgMagazines
{
	class Laserbatteries;

	class Item_Crocus_AT: Laserbatteries
	{
		_generalMacro="Item_Crocus_AT";
		scope=2;
		ARMAFPV_MAG_COMMON("Crocus FPV Drone AT (Anti-Tank)", "Crocus AT Drone", QARMAFPV_PATH(drone.p3d));
	};

	class Item_Crocus_AP: Laserbatteries
	{
		_generalMacro="Item_Crocus_AP";
		scope=2;
		ARMAFPV_MAG_COMMON("Crocus FPV Drone AP (Anti-Personnel)", "Crocus AP Drone", QARMAFPV_PATH(drone2\drone2.p3d));
	};

	class Item_Crocus_AT_TI: Laserbatteries
	{
		_generalMacro="Item_Crocus_AT_TI";
		scope=2;
		ARMAFPV_MAG_COMMON("Crocus FPV Drone AT-TI (Anti-Tank, Thermal)", "Crocus AT TI Drone", QARMAFPV_PATH(drone.p3d));
	};

	class Item_Crocus_AP_TI: Laserbatteries
	{
		_generalMacro="Item_Crocus_AP_TI";
		scope=2;
		ARMAFPV_MAG_COMMON("Crocus FPV Drone AP-TI (Anti-Personnel, Thermal)", "Crocus AP TI Drone", QARMAFPV_PATH(drone2\drone2.p3d));
	};
};
