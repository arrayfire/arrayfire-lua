extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

#if LUA_VERSION_NUM > 501
#define lua_objlen(L,i)		lua_rawlen(L, (i))
#endif
