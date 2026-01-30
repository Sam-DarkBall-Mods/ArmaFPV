#ifndef ARMAFPV_CONFIG_MACROS_HPP
#define ARMAFPV_CONFIG_MACROS_HPP

#define QARMAFPV_PATH(P) "\ArmaFPV\" #P
#define QARMAFPV_DATA(P) QARMAFPV_PATH(data\P)
#define QARMAFPV_PIC(P) QARMAFPV_PATH(pictures\P)
#define QARMAFPV_FONT(P) QARMAFPV_PATH(font\P)
#define QARMAFPV_SOUND(P) QARMAFPV_PATH(sounds\P)

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
