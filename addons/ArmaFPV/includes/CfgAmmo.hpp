class CfgAmmo
{
	class M_Vorona_HEAT;
	class R_TBG32V_F;
	class FPV_RPG42_AT: M_Vorona_HEAT
	{
        explosive = 0.8;
        hit = 150;
        htMax = 1800;
        htMin = 60;
        indirectHit = 25;
        indirectHitRange = 3.5;
        submunitionInitSpeed = 1000;
        warheadName="TandemHEAT";
        submunitionAmmo="FPV_RPG42_AT_Penetrator";
        submunitionDirectionType="SubmunitionModelDirection";
        submunitionParentSpeedCoef=0;
        submunitionInitialOffset[]={0,0,-0.1};
        triggerOnImpact=1;
        deleteParentWhenTriggered=0;
		soundHit[] = {"", 0, 1};
		soundHit1[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_01", 1.35, 1, 850};
		soundHit2[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_02", 1.35, 1, 850};
		soundHit3[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_03", 1.35, 1, 850};
		multiSoundHit[] = {"soundHit1", 0.34, "soundHit2", 0.33, "soundHit3", 0.33};
    };

	class FPV_RPG32_AP: R_TBG32V_F
	{
		soundHit[] = {"", 0, 1};
		soundHit1[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_01", 1.25, 1, 850};
		soundHit2[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_02", 1.25, 1, 850};
		soundHit3[] = {"A3\Sounds_F\arsenal\explosives\shells\ShellLightA_closeExp_03", 1.25, 1, 850};
		multiSoundHit[] = {"soundHit1", 0.34, "soundHit2", 0.33, "soundHit3", 0.33};
	};

    class ammo_Penetrator_Vorona;
    class FPV_RPG42_AT_Penetrator: ammo_Penetrator_Vorona
    {
        hit = 480;
        indirectHit = 0;
        indirectHitRange = 0;
        warheadName = "TandemHEAT";
    };
};
