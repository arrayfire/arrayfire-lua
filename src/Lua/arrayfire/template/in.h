#ifndef IN_TEMPLATE_H
#define IN_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(af_array)> int In (lua_State * L)
{
	lua_settop(L, 1);	// in

	af_err err = func(GetArray(L, 1));

	lua_pushinteger(L, err);// in, err

	return 1;
}

template<typename T, af_err (*func)(af_array, rtype_t<T>)> int In_Arg (lua_State * L)
{
	lua_settop(L, 2);	// in, arg

	af_err err = func(GetArray(L, 1), Arg<T>(L, 2));

	lua_pushinteger(L, err);// in, err

	return 1;
}

#define IN_NONE(name) { "af_"#name, In<&af_##name> }
#define IN_ARG(name, t) { "af_"#name, In_Arg<t, &af_##name> }

#endif