class CfgAmmo
{
    class M_Vorona_HEAT;
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
