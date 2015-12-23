extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

#if LUA_VERSION_NUM > 501

#define lua_objlen(L,i)		lua_rawlen(L, (i))

#define luaL_register(L, n, l) do {             \
        lua_getglobal(L, n);                    \
        if (lua_isnil(L, -1)) {                 \
            lua_pop(L, 1);                      \
            lua_newtable(L);                    \
        }                                       \
        luaL_setfuncs(L, l, 0);                 \
        lua_setglobal(L, n);                    \
    }while(0)

#endif
