#ifndef ARMAFPV_CONFIG_MACROS_HPP
#define ARMAFPV_CONFIG_MACROS_HPP

#define QSTR(x) #x
#define QARMAFPV_PATH(P) QSTR(\ArmaFPV\P)
#define QARMAFPV_DATA(P) QSTR(\ArmaFPV\data\P)
#define QARMAFPV_PIC(P) QSTR(\ArmaFPV\pictures\P)
#define QARMAFPV_FONT(P) QSTR(\ArmaFPV\font\P)
#define QARMAFPV_SOUND(P) QSTR(\ArmaFPV\sounds\P)

#define ARMAFPV_MAG_COMMON(DESC,NAME,MODEL) \
	author="DarkBall"; \
	descriptionShort=DESC; \
	displayName=NAME; \
	model=MODEL; \
	icon=QARMAFPV_DATA(drononmap.paa); \
	picture=QARMAFPV_DATA(drononmap.paa); \
	mass=150; \
	count=1; \
	ammo=""

#endif
