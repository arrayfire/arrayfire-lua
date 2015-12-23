#ifndef OUT_IN3_TEMPLATE_H
#define OUT_IN3_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(af_array *, const af_array, const af_array, const af_array)> int OutIn3 (lua_State * L)
{
	lua_settop(L, 3);	// a, b, c

	af_array * arr_ud = NewArray(L);// a, b, c, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), GetArray(L, 3));

	return PushErr(L, err);	// a, b, c, err, arr_ud
}

template<typename T, af_err (*func)(af_array *, const af_array, const af_array, const af_array, rtype_t<T>)>
int OutIn3_Arg (lua_State * L)
{
	lua_settop(L, 4);	// a, b, c, arg

	af_array * arr_ud = NewArray(L);// a, b, c, arg, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), GetArray(L, 3), Arg<T>(L, 4));

	return PushErr(L, err);	// a, b, c, arg, err, arr_ud
}

template<typename T1, typename T2, af_err (*func)(af_array *, const af_array, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>)>
int OutIn3_Arg2 (lua_State * L)
{
	lua_settop(L, 5);	// a, b, c, arg1, arg2

	af_array * arr_ud = NewArray(L);// a, b, c, arg1, arg2, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), GetArray(L, 3), Arg<T1>(L, 4), Arg<T2>(L, 5));

	return PushErr(L, err);	// a, b, c, arg1, arg2, err, arr_ud
}

// ^^ TODO: Variadic template?

#define OUTIN3(name) { "af_"#name, OutIn3<&af_##name> }
#define OUTIN3_ARG(name, t) { "af_"#name, OutIn3_Arg<t, &af_##name> }
#define OUTIN3_ARG2(name, t1, t2) { "af_"#name, OutIn3_Arg2<t1, t2, &af_##name> }

#endif