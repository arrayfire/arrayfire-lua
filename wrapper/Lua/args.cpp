extern "C" {
	#include <lua.h>
}

#include "template/args.h"
#include "utils.h"

template<> inline af_array * Out (ARRAY_PROXY & proxy)
{
	return proxy.mUD;
}

template<> inline af_features * Out (FEATURES_PROXY & proxy)
{
	return proxy.mUD;
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

template<> inline void Push (lua_State * L, ARRAY_PROXY) {}
template<> inline void Push (lua_State * L, FEATURES_PROXY) {}

template<> inline const char * Declare (lua_State * L)
{
	return nullptr;
}

template<> inline void * Declare (lua_State * L)
{
	return nullptr;
}

template<> inline ARRAY_PROXY Declare (lua_State * L)
{
	ARRAY_PROXY proxy;

	proxy.mUD = NewArray(L);// ..., arr_ud

	return proxy;
}

template<> inline FEATURES_PROXY Declare (lua_State * L)
{
	FEATURES_PROXY proxy;

	proxy.mUD = NewFeatures(L);	// ..., features_ud

	return proxy;
}

bool B (lua_State * L, int index) { return Arg<bool>(L, index); }
double D (lua_State * L, int index) { return Arg<double>(L, index); }
float F (lua_State * L, int index) { return Arg<float>(L, index); }
int I (lua_State * L, int index) { return Arg<int>(L, index); }
const char * S (lua_State * L, int index) { return Arg<STRING_PROXY>(L, index); }
unsigned U (lua_State * L, int index) { return Arg<unsigned>(L, index); }
void * UD (lua_State * L, int index) { return lua_touserdata(L, index); }