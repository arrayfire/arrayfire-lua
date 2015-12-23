#ifndef OUT2_IN_TEMPLATE_H
#define OUT2_IN_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(af_array *, af_array *, const af_array)>
int Out2In (lua_State * L)
{
	lua_settop(L, 1);	// a

	af_array * out1 = NewArray(L);	// a, out1
	af_array * out2 = NewArray(L);	// a, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1));

	return PushErr(L, err, 2);	// a, err, out1, out2

}

template<typename T, af_err (*func)(af_array *, af_array *, const af_array, rtype_t<T>)>
int Out2In_Arg (lua_State * L)
{
	lua_settop(L, 2);	// a, arg

	af_array * out1 = NewArray(L);	// a, arg, out1
	af_array * out2 = NewArray(L);	// a, arg, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1), Arg<T>(L, 2));

	return PushErr(L, err, 2);	// a, arg, err, out1, out2

}

template<typename T1, typename T2, af_err (*func)(af_array *, af_array *, const af_array, rtype_t<T1>, rtype_t<T2>)>
int Out2In_Arg2 (lua_State * L)
{
	lua_settop(L, 3);	// a, arg1, arg2

	af_array * out1 = NewArray(L);	// a, arg1, arg2, out1
	af_array * out2 = NewArray(L);	// a, arg1, arg2, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3));

	return PushErr(L, err, 2);	// a, arg1, arg2, err, out1, out2

}

// ^^ TODO: Variadic template?

#define OUT2IN(name) { "af_"#name, Out2In<&af_##name> }
#define OUT2IN_ARG(name, t) { "af_"#name, Out2In_Arg<t, &af_##name> }
#define OUT2IN_ARG2(name, t1, t2) { "af_"#name, Out2In_Arg2<t1, t2, &af_##name> }

#endif