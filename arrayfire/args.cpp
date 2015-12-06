extern "C" {
	#include <lua.h>
}

#include "args_template.h"

template<> inline bool Arg<bool> (lua_State * L, int index)
{
	return lua_toboolean(L, index);
}

template<> inline float Arg<float> (lua_State * L, int index)
{
	return lua_tonumber(L, index);
}

template<> inline double Arg<double> (lua_State * L, int index)
{
	return lua_tonumber(L, index);
}

template<> inline const char * Arg<const char *> (lua_State * L, int index)
{
	return lua_tostring(L, index);
}

template<> inline void Push (lua_State * L, bool b)
{
	lua_pushboolean(L, b);	// ..., bool
}

template<> inline void Push (lua_State * L, float f)
{
	lua_pushnumber(L, f);	// ..., float
}

template<> inline void Push (lua_State * L, double d)
{
	lua_pushnumber(L, d);	// ..., double
}

template<> inline void Push (lua_State * L, const char * s)
{
	lua_pushstring(L, s);	// ..., string
}

template<> inline void Push (lua_State * L, void * ptr)
{
	lua_pushlightuserdata(L, ptr);	// ..., ptr
}

bool B (lua_State * L, int index) { return Arg<bool>(L, index); }
double D (lua_State * L, int index) { return Arg<double>(L, index); }
float F (lua_State * L, int index) { return Arg<float>(L, index); }
int I (lua_State * L, int index) { return Arg<int>(L, index); }
const char * S (lua_State * L, int index) { return Arg<const char *>(L, index); }
unsigned U (lua_State * L, int index) { return Arg<unsigned>(L, index); }
void * UD (lua_State * L, int index) { return lua_touserdata(L, index); }