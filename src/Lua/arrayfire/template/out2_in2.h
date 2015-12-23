#ifndef OUT2_IN2_TEMPLATE_H
#define OUT2_IN2_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<typename T, af_err (*func)(af_array *, af_array *, const af_array, const af_array, rtype_t<T>)>
int Out2In2_Arg (lua_State * L)
{
	lua_settop(L, 3);	// a, b, arg

	af_array * out1 = NewArray(L);	// a, b, arg, out1
	af_array * out2 = NewArray(L);	// a, b, arg, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1), GetArray(L, 2), Arg<T>(L, 3));

	return PushErr(L, err, 2);	// a, b, arg, err, out1, out2

}

template<typename T1, typename T2, af_err (*func)(af_array *, af_array *, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>)>
int Out2In2_Arg2 (lua_State * L)
{
	lua_settop(L, 4);	// a, b, arg1, arg2

	af_array * out1 = NewArray(L);	// a, b, arg1, arg2, out1
	af_array * out2 = NewArray(L);	// a, b, arg1, arg2, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1), GetArray(L, 2), Arg<T1>(L, 3), Arg<T2>(L, 4));

	return PushErr(L, err, 2);	// a, b, arg1, arg2, err, out1, out2

}

template<typename T1, typename T2, typename T3, af_err (*func)(af_array *, af_array *, const af_array, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>)>
int Out2In2_Arg3 (lua_State * L)
{
	lua_settop(L, 5);	// a, b, arg1, arg2, arg3

	af_array * out1 = NewArray(L);	// a, b, arg1, arg2, arg3, out1
	af_array * out2 = NewArray(L);	// a, b, arg1, arg2, arg3, out1, out2

	af_err err = func(out1, out2, GetArray(L, 1), GetArray(L, 2), Arg<T1>(L, 3), Arg<T2>(L, 4), Arg<T3>(L, 5));

	return PushErr(L, err, 2);	// a, b, arg1, arg2, arg3, err, out1, out2
}

// ^^ TODO: Variadic template?

#define OUT2IN2_ARG(name, t) { "af_"#name, Out2In2_Arg<t, &af_##name> }
#define OUT2IN2_ARG2(name, t1, t2) { "af_"#name, Out2In2_Arg2<t1, t2, &af_##name> }
#define OUT2IN2_ARG3(name, t1, t2, t3) { "af_"#name, Out2In2_Arg3<t1, t2, t3, &af_##name> }

#endif