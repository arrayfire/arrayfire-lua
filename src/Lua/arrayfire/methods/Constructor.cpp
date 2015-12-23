#include <arrayfire.h>
#include "../funcs.h"
#include "../utils.h"
#include "../template/args.h"
#include "../template/out_in.h"

template<typename T, af_err(*func)(af_array *, const T, const unsigned, const dim_t *)> int Long (lua_State * L)
{
	lua_settop(L, 3);	// val, ndims, dims

	LuaDims dims(L, 2);

	af_array * arr_ud = NewArray(L);// val, ndims, dims, arr_ud

	af_err err = af_constant_ulong(arr_ud, Arg<T>(L, 1), dims.GetNDims(), dims.GetDims());

	return PushErr(L, err);	// val, ndims, dims, err, arr_ud
}

#define LONG(name, t) { "af_"#name, Long<t, &af_##name> }

//
static const struct luaL_Reg constructor_funcs[] = {
	{
		"af_constant", [](lua_State * L)
		{
			lua_settop(L, 4);	// val, ndims, dims, type

			LuaDims dt(L, 2);

			af_array * arr_ud = NewArray(L);// val, ndims, dims, type, arr_ud

			af_err err = af_constant(arr_ud, D(L, 1), dt.GetNDims(), dt.GetDims(), Arg<af_dtype>(L, 4));

			return PushErr(L, err);	// val, ndims, dims, type, err, arr_ud
		}
	}, {
		"af_constant_complex", [](lua_State * L)
		{
			lua_settop(L, 5);	// real, imag, ndims, dims, type

			LuaDims dt(L, 3);

			af_array * arr_ud = NewArray(L);// real, imag, ndims, dims, type, arr_ud

			af_err err = af_constant_complex(arr_ud, D(L, 1), D(L, 2), dt.GetNDims(), dt.GetDims(), Arg<af_dtype>(L, 5));

			return PushErr(L, err);	// real, imag, ndims, dims, type, err, arr_ud
		}
	},
	LONG(constant_long, intl),
	LONG(constant_ulong, uintl),
	OUTIN_ARG(diag_create, int),
	OUTIN_ARG(diag_extract, int),
	{
		"af_get_seed", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			uintl seed = 0;

			af_err err = af_get_seed(&seed);

			lua_pushinteger(L, seed);	// seed

			return PushErr(L, err);	// err, seed
		}
	},
	DIMS_AND_TYPE(identity),
	{
		"af_iota", [](lua_State * L)
		{
			lua_settop(L, 5);	// ndims, dims, t_ndims, tdims, type

			LuaDims dims(L, 1);
			LuaDims t_dt(L, 3);

			af_array * arr_ud = NewArray(L);// ndims, dims, t_ndims, tdims, type, arr_ud

			af_err err = af_iota(arr_ud, dims.GetNDims(), dims.GetDims(), t_dt.GetNDims(), t_dt.GetDims(), Arg<af_dtype>(L, 5));

			return PushErr(L, err);	// ndims, dims, t_ndims, tdims, type, err, arr_ud
		}
	},
	OUTIN_ARG(lower, bool),
	DIMS_AND_TYPE(randn),
	DIMS_AND_TYPE(randu),
	{
		"af_range", [](lua_State * L)
		{
			lua_settop(L, 4);	// ndims, dims, seq_dim, type

			LuaDims dt(L, 1);

			af_array * arr_ud = NewArray(L);// ndims, dims, seq_dim, type, arr_ud

			af_err err = af_range(arr_ud, dt.GetNDims(), dt.GetDims(), I(L, 3), Arg<af_dtype>(L, 4));

			return PushErr(L, err);	// ndims, dims, seq_dim, type, err, arr_ud
		}
	}, {
		"af_set_seed", [](lua_State * L)
		{
			lua_settop(L, 1);	// seed

			af_err err = af_set_seed(Arg<uintl>(L, 1));

			lua_pushinteger(L, err);// seed, err

			return 1;
		}
	},
	OUTIN_ARG(upper, bool),

	{ NULL, NULL }
};

#undef LONG

int Constructor (lua_State * L)
{
	luaL_register(L, NULL, constructor_funcs);

	return 0;
}