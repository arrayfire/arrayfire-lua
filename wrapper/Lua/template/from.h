#ifndef FROM_TEMPLATE_H
#define FROM_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<typename O, af_err (*func)(O *, const af_array)> int From (lua_State * L)
{
	lua_settop(L, 1);	// arr

	O out; // TODO: Declare...

	af_err err = func(&out, GetArray(L, 1));

	lua_pushinteger(L, err);// arr, err

	Push(L, out);	// arr, err, out

	return 2;
}

#define FROM_NONE(name, t) { "af_"#name, From<t, &af_##name> }

#endif