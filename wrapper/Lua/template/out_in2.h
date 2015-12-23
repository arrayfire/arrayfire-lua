#ifndef OUT_IN2_TEMPLATE_H
#define OUT_IN2_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(af_array *, const af_array, const af_array)> int OutIn2 (lua_State * L)
{
	lua_settop(L, 2);	// a, b

	af_array * arr_ud = NewArray(L);// a, b, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2));

	return PushErr(L, err);	// a, b, err, arr_ud
}

template<typename T, af_err (*func)(af_array *, const af_array, const af_array, rtype_t<T>)>
int OutIn2_Arg (lua_State * L)
{
	lua_settop(L, 3);	// a, b, arg

	af_array * arr_ud = NewArray(L);// a, b, arg, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), Arg<T>(L, 3));

	return PushErr(L, err);	// a, b, arg, err, arr_ud
}

template<typename T1, typename T2, af_err (*func)(af_array *, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>)>
int OutIn2_Arg2 (lua_State * L)
{
	lua_settop(L, 4);	// a, b, arg1, arg2

	af_array * arr_ud = NewArray(L);// a, b, arg1, arg2, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), Arg<T1>(L, 3), Arg<T2>(L, 4));

	return PushErr(L, err);	// a, b, arg1, arg2, err, arr_ud
}

template<typename T1, typename T2, typename T3, af_err (*func)(af_array *, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>)>
int OutIn2_Arg3 (lua_State * L)
{
	lua_settop(L, 5);	// a, b, arg1, arg2, arg3

	af_array * arr_ud = NewArray(L);// a, b, arg1, arg2, arg3, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), Arg<T1>(L, 3), Arg<T2>(L, 4), Arg<T3>(L, 5));

	return PushErr(L, err);	// a, b, arg1, arg2, arg3, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, af_err (*func)(af_array *, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>)>
int OutIn2_Arg4 (lua_State * L)
{
	lua_settop(L, 6);	// a, b, arg1, arg2, arg3, arg4

	af_array * arr_ud = NewArray(L);// a, b, arg1, arg2, arg3, arg4, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), Arg<T1>(L, 3), Arg<T2>(L, 4), Arg<T3>(L, 5), Arg<T4>(L, 6));

	return PushErr(L, err);	// a, b, arg1, arg2, arg3, arg4, err, arr_ud
}

// ^^ TODO: Variadic template?

#define OUTIN2(name) { "af_"#name, OutIn2<&af_##name> }
#define OUTIN2_ARG(name, t) { "af_"#name, OutIn2_Arg<t, &af_##name> }
#define OUTIN2_ARG2(name, t1, t2) { "af_"#name, OutIn2_Arg2<t1, t2, &af_##name> }
#define OUTIN2_ARG3(name, t1, t2, t3) { "af_"#name, OutIn2_Arg3<t1, t2, t3, &af_##name> }
#define OUTIN2_ARG4(name, t1, t2, t3, t4) { "af_"#name, OutIn2_Arg4<t1, t2, t3, t4, &af_##name> }

#endif