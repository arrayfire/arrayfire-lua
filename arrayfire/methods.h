#ifndef METHODS_H
#define METHODS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

void ArrayMethods (lua_State * L);

#endif // METHODS_H