extern "C" {
	#include <lua.h>
}

#include "args_template.h"
#include "utils.h"

template <> struct SelectType<ARRAY_PROXY> {
	typedef af_array type;
	typedef af_array * out_type;
};

template <> struct SelectType<FEATURES_PROXY> {
	typedef af_features type;
	typedef af_features * out_type;
};

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

template<> inline af_array Arg<ARRAY_PROXY> (lua_State * L, int index)
{
	return GetArray(L, index);
}

template<> inline af_features Arg<FEATURES_PROXY> (lua_State * L, int index)
{
	return GetFeatures(L, index);
}

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
const char * S (lua_State * L, int index) { return Arg<const char *>(L, index); }
unsigned U (lua_State * L, int index) { return Arg<unsigned>(L, index); }
void * UD (lua_State * L, int index) { return lua_touserdata(L, index); }