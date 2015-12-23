#ifndef METHODS_H
#define METHODS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

#include "lua_compat.h"

int AssignIndex (lua_State * L);
int Create (lua_State * L);
int Constructor (lua_State * L);
int Device (lua_State * L);
int Features (lua_State * L);
int Methods (lua_State * L);
int Helper (lua_State * L);
int MoveReorder (lua_State * L);

#endif // METHODS_H
