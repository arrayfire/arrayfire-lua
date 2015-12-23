#ifndef OUT_IN_TEMPLATE_H
#define OUT_IN_TEMPLATE_H

#include "../utils.h"
#include "args.h"

template<af_err (*func)(af_array *, af_array)> int OutIn (lua_State * L)
{
	lua_settop(L, 1);	// in

	af_array * arr_ud = NewArray(L);// in, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1));

	return PushErr(L, err);	// in, err, arr_ud
}

template<typename T, af_err (*func)(af_array *, const af_array, rtype_t<T>)>
int OutIn_Arg (lua_State * L)
{
	lua_settop(L, 2);	// a, arg

	af_array * arr_ud = NewArray(L);// a, arg, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T>(L, 2));

	return PushErr(L, err);	// a, arg, err, arr_ud
}

/*
template<typename O1, typename I1, typename I2, af_err (*func)(TN_OUT(O1), const TN(I1), const TN(I2))>
int Out1_In2 (lua_State * L)
{
	lua_settop(L, 2);	// arg1, arg2

	O1 out1 = Declare<O1>(L);	// arg1, arg2, out1?

	af_err err = func(Out(out1), Arg<I1>(L, 1), Arg<I2>(L, 2));

	Push(L, out1);	//  arg1, arg2, out1

	return PushErr(L, err);	// arg1, arg2, err, out1
}
*/

template<typename T1, typename T2, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>)>
int OutIn_Arg2 (lua_State * L)
{
	lua_settop(L, 3);	// a, arg1, arg2

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3));

	return PushErr(L, err);	// a, arg1, arg2, err, arr_ud
}

template<typename T1, typename T2, typename T3, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>)>
int OutIn_Arg3 (lua_State * L)
{
	lua_settop(L, 4);	// a, arg1, arg2, arg3

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4));

	return PushErr(L, err);	// a, arg1, arg2, arg3, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>)>
int OutIn_Arg4 (lua_State * L)
{
	lua_settop(L, 5);	// a, arg1, arg2, arg3, arg4

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>, rtype_t<T5>)>
int OutIn_Arg5 (lua_State * L)
{
	lua_settop(L, 6);	// a, arg1, arg2, arg3, arg4, arg5

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arg5, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, arg5, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>, rtype_t<T5>, rtype_t<T6>)>
int OutIn_Arg6 (lua_State * L)
{
	lua_settop(L, 7);	// a, arg1, arg2, arg3, arg4, arg5, arg6

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arg5, arg6, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6), Arg<T6>(L, 7));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, arg5, arg6, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>, rtype_t<T5>, rtype_t<T6>, rtype_t<T7>)>
int OutIn_Arg7 (lua_State * L)
{
	lua_settop(L, 8);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6), Arg<T6>(L, 7), Arg<T7>(L, 8));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>, rtype_t<T5>, rtype_t<T6>, rtype_t<T7>, rtype_t<T8>)>
int OutIn_Arg8 (lua_State * L)
{
	lua_settop(L, 9);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6), Arg<T6>(L, 7), Arg<T7>(L, 8), Arg<T8>(L, 9));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, err, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, af_err (*func)(af_array *, const af_array, rtype_t<T1>, rtype_t<T2>, rtype_t<T3>, rtype_t<T4>, rtype_t<T5>, rtype_t<T6>, rtype_t<T7>, rtype_t<T8>, rtype_t<T9>)>
int OutIn_Arg9 (lua_State * L)
{
	lua_settop(L, 10);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9

	af_array * arr_ud = NewArray(L);// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6), Arg<T6>(L, 7), Arg<T7>(L, 8), Arg<T8>(L, 9), Arg<T9>(L, 10));

	return PushErr(L, err);	// a, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, err, arr_ud
}

// ^^ TODO: Variadic template?

#define OUTIN(name) { "af_"#name, OutIn<&af_##name> }
#define OUTIN_ARG(name, t) { "af_"#name, OutIn_Arg<t, &af_##name> }
#define OUTIN_ARG2(name, t1, t2) { "af_"#name, OutIn_Arg2<t1, t2, &af_##name> }
#define OUTIN_ARG3(name, t1, t2, t3) { "af_"#name, OutIn_Arg3<t1, t2, t3, &af_##name> }
#define OUTIN_ARG4(name, t1, t2, t3, t4) { "af_"#name, OutIn_Arg4<t1, t2, t3, t4, &af_##name> }
#define OUTIN_ARG5(name, t1, t2, t3, t4, t5) { "af_"#name, OutIn_Arg5<t1, t2, t3, t4, t5, &af_##name> }
#define OUTIN_ARG6(name, t1, t2, t3, t4, t5, t6) { "af_"#name, OutIn_Arg6<t1, t2, t3, t4, t5, t6, &af_##name> }
#define OUTIN_ARG7(name, t1, t2, t3, t4, t5, t6, t7) { "af_"#name, OutIn_Arg7<t1, t2, t3, t4, t5, t6, t7, &af_##name> }
#define OUTIN_ARG8(name, t1, t2, t3, t4, t5, t6, t7, t8) { "af_"#name, OutIn_Arg8<t1, t2, t3, t4, t5, t6, t7, t8, &af_##name> }
#define OUTIN_ARG9(name, t1, t2, t3, t4, t5, t6, t7, t8, t9) { "af_"#name, OutIn_Arg9<t1, t2, t3, t4, t5, t6, t7, t8, t9, &af_##name> }

#endif