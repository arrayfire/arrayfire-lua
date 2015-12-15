#ifndef ARGS_TEMPLATE_H
#define ARGS_TEMPLATE_H

#include <arrayfire.h>

template <typename T> struct SelectType {
	typedef T type;
	typedef T * out_type;
};

#define TN(t) typename SelectType<t>::type
#define TN_OUT(t) typename SelectType<t>::out_type

template<typename T, typename R = T> R Arg (lua_State * L, int index)
{
	return (R)lua_tointeger(L, index);
}

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

typedef struct { af_array * mUD; } ARRAY_PROXY;
typedef struct { af_features * mUD; } FEATURES_PROXY;

bool B (lua_State * L, int index);
double D (lua_State * L, int index);
float F (lua_State * L, int index);
int I (lua_State * L, int index);
unsigned U (lua_State * L, int index);
const char * S (lua_State * L, int index);
void * UD (lua_State * L, int index);	// N.B. Does not use Arg<void *>, since these are ambiguous with af_array / af_features

#endif