#include "../funcs.h"
#include "../template/doubles.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out2_in.h"
#include "../template/out2_in2.h"

template<af_err (*func)(double *, double *, unsigned *, const af_array)> int IAll (lua_State * L)
{
	lua_settop(L, 1);	// arr

	double d1, d2;
	unsigned value;

	af_err err = func(&d1, &d2, &value, GetArray(L, 1));

	lua_pushinteger(L, err);// arr, err
	lua_pushnumber(L, d1);	// arr, err, d1
	lua_pushnumber(L, d2);	// arr, err, d1, d2
	lua_pushinteger(L, value);	// arr, err, d1, d2, value

	return 4;
}

#define IALL(name) { "af_"#name, IAll<&af_##name> }

static const struct luaL_Reg vector_funcs[] = {
	OUTIN_ARG(accum, int),
	OUTIN_ARG(all_true, int),
	DDIN(all_true_all),
	OUTIN_ARG(any_true, int),
	DDIN(any_true_all),
	OUTIN_ARG(count, int),
	DDIN(count_all),
	OUTIN_ARG(diff1, int),
	OUTIN_ARG(diff2, int),
	OUT2IN(gradient),
	OUT2IN_ARG(imax, int),
	IALL(imax_all),
	OUT2IN_ARG(imin, int),
	IALL(imin_all),
	OUTIN_ARG(max, int),
	DDIN(max_all),
	OUTIN_ARG(min, int),
	DDIN(min_all),
	OUTIN_ARG(product, int),
	DDIN(product_all),
#if AF_API_VERSION >= 31
	OUTIN_ARG2(product_nan, int, double),
	DDIN_ARG(product_nan_all, double),
#endif
	OUTIN2_ARG(set_intersect, bool),
	OUTIN2_ARG(set_union, bool),
	OUTIN_ARG(set_unique, bool),
	OUTIN_ARG2(sort, unsigned, bool),
	OUT2IN2_ARG2(sort_by_key, unsigned, bool),
	OUT2IN_ARG2(sort_index, unsigned, bool),
	OUTIN_ARG(sum, int),
	DDIN(sum_all),
#if AF_API_VERSION >= 31
	OUTIN_ARG2(sum_nan, int, double),
	DDIN_ARG(sum_nan_all, double),
#endif
	OUTIN(where),

	{ NULL, NULL }
};

#undef IALL

int Vector (lua_State * L)
{
	luaL_register(L, NULL, vector_funcs);

	return 0;
}