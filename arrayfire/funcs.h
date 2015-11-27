#ifndef FUNCS_H
#define FUNCS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

int CreateArrayFuncs (lua_State * L);

#endif // FUNCS_H