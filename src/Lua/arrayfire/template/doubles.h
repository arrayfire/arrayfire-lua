#ifndef DOUBLES_TEMPLATE_H
#define DOUBLES_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(double *, double *, const af_array)> int TwoDoublesIn (lua_State * L)
{
	lua_settop(L, 1);	// arr

	double d1 = 0.0, d2 = 0.0;

	af_err err = func(&d1, &d2, GetArray(L, 1));

	lua_pushinteger(L, err);// arr, err
	lua_pushnumber(L, d1);	// arr, err, d1
	lua_pushnumber(L, d2);	// arr, err, d1, d2

	return 3;
}

template<typename T, af_err (*func)(double *, double *, const af_array, const T)> int TwoDoublesInArg (lua_State * L)
{
	lua_settop(L, 2);	// arr, arg

	double d1 = 0.0, d2 = 0.0;

	af_err err = func(&d1, &d2, GetArray(L, 1), Arg<T>(L, 2));

	lua_pushinteger(L, err);// arr, arg, err
	lua_pushnumber(L, d1);	// arr, arg, err, d1
	lua_pushnumber(L, d2);	// arr, arg, err, d1, d2

	return 3;
}

template<af_err (*func)(double *, double *, const af_array, const af_array)> int TwoDoublesIn2 (lua_State * L)
{
	lua_settop(L, 2);	// arr1, arr2

	double d1 = 0.0, d2 = 0.0;

	af_err err = func(&d1, &d2, GetArray(L, 1), GetArray(L, 2));

	lua_pushinteger(L, err);// arr1, arr2, err
	lua_pushnumber(L, d1);	// arr1, arr2, err, d1
	lua_pushnumber(L, d2);	// arr1, arr2, err, d1, d2

	return 3;
}

#define DDIN(name) { "af_"#name, TwoDoublesIn<&af_##name> }
#define DDIN_ARG(name, t) { "af_"#name, TwoDoublesInArg<t, &af_##name> }
#define DDIN2(name) { "af_"#name, TwoDoublesIn2<&af_##name> }

#endif