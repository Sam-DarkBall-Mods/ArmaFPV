#ifndef SDB_INTEROPTWEAKS_SCRIPT_MACROS_HPP
#define SDB_INTEROPTWEAKS_SCRIPT_MACROS_HPP

#define SDB_GET_MVAR(NAME,DEFAULT) (missionNamespace getVariable [#NAME, DEFAULT])
#define SDB_SET_MVAR(NAME,VALUE) (missionNamespace setVariable [#NAME, VALUE])

#endif
