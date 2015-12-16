#ifndef OUT_TEMPLATE_H
#define OUT_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<typename T1, typename T2, af_err (*func)(af_array *, rtype_t<T1>, rtype_t<T2>)> int Out_Arg2 (lua_State * L)
{
	lua_settop(L, 2);	// arg1, arg2

	af_array * arr_ud = NewArray(L);// arg1, arg2, arr_ud

	af_err err = func(arr_ud, Arg<T1>(L, 1), Arg<T2>(L, 2));

	return PushErr(L, err);	// arg1, arg2, err, arr_ud
}

#define OUT_ARG2(name, t1, t2) { "af_"#name, Out_Arg2<t1, t2, &af_##name> }

#endif