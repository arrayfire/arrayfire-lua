#ifndef GRAPHICS_H
#define GRAPHICS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

int Draw (lua_State * L);
int Window (lua_State * L);

#endif // GRAPHICS_H