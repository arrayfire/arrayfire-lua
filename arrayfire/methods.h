#ifndef METHODS_H
#define METHODS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

int ArrayMethods (lua_State * L);
int AssignIndex (lua_State * L);
int Device (lua_State * L);
int Features (lua_State * L);
int Helper (lua_State * L);
int MoveReorder (lua_State * L);

#endif // METHODS_H