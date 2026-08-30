#define PREFIX DB
#define PREFIX_BEAUTIFIED DB
#define MOD_NAME "DB Example Mod"
#define QUOTE_INNER(value) #value
#define QUOTE(value) QUOTE_INNER(value)

#define MAJOR 1
#define MINOR 0
#define PATCHLVL 0
#define VERSION 1.0
#define VERSION_STR 1.0.0
#define VERSION_AR MAJOR,MINOR,PATCHLVL
#define VERSION_CONFIG version = VERSION; versionStr = QUOTE(VERSION_STR); versionAr[] = {VERSION_AR}
