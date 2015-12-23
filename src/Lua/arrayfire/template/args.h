#ifndef ARGS_TEMPLATE_H
#define ARGS_TEMPLATE_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

#include <arrayfire.h>

template<class T>
struct get_return { typedef T type; };

typedef struct { af_array * mUD; } ARRAY_PROXY;
typedef struct { af_features * mUD; } FEATURES_PROXY;
typedef struct { const char * mStr; } STRING_PROXY;

template<> struct get_return<ARRAY_PROXY> { typedef af_array type; };
template<> struct get_return<FEATURES_PROXY> { typedef af_features type; };
template<> struct get_return<STRING_PROXY> { typedef char * type; };

template<class T>
typename get_return<T>::type Arg (lua_State * L, int index);

template<typename T> typename get_return<T>::type Arg (lua_State * L, int index)
{
	return (T)lua_tointeger(L, index);
}

af_array GetArray (lua_State *, int);
af_features GetFeatures (lua_State *, int);

template<> inline get_return<ARRAY_PROXY>::type Arg<ARRAY_PROXY> (lua_State * L, int index)
{
	return GetArray(L, index);
}

template<> inline get_return<FEATURES_PROXY>::type Arg<FEATURES_PROXY> (lua_State * L, int index)
{
	return GetFeatures(L, index);
}

template<> inline get_return<STRING_PROXY>::type Arg<STRING_PROXY> (lua_State * L, int index)
{
	return const_cast<char *>(lua_tostring(L, index));
}

template<> inline get_return<bool>::type Arg<bool> (lua_State * L, int index)
{
	return lua_toboolean(L, index);
}

template<> inline get_return<float>::type Arg<float> (lua_State * L, int index)
{
	return lua_tonumber(L, index);
}

template<> inline get_return<double>::type Arg<double> (lua_State * L, int index)
{
	return lua_tonumber(L, index);
}

template <typename T>
struct rtype { using _type = const T; };

template <typename T>
struct rtype<T*> { using _type = const T *; };

template <typename T>
using rtype_t = typename rtype<typename get_return<T>::type>::_type;

template<typename T> T Declare (lua_State * L)
{
	return T(0);
}

template<typename T, typename R = T *> R Out (T & value)
{
	return &value;
}

template<typename T> void Push (lua_State * L, T value)
{
	lua_pushinteger(L, value);	// ..., value
}

bool B (lua_State * L, int index);
double D (lua_State * L, int index);
float F (lua_State * L, int index);
int I (lua_State * L, int index);
unsigned U (lua_State * L, int index);
const char * S (lua_State * L, int index);
void * UD (lua_State * L, int index);	// N.B. Does not use Arg<void *>, since these are ambiguous with af_array / af_features

#endif
