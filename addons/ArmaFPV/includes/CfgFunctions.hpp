class CfgFunctions
{
	class DB
	{
		class FPV
		{
            file = "\ArmaFPV\functions";

			class fpv_createDialog {};
			class fpv_getSignal {};
			class fpv_handleBattery {};
			class fpv_handleConnect { postInit = 1; };
			class fpv_handleSignal {};
			class fpv_handleSettings {};
			class fpv_handleTime {};
			class fpv_onDestroy {};
			class fpv_onSignalLost {};
			class fpv_destroyUI {};
			class fpv_droneInit {};
		};
	};
};