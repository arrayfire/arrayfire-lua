#include <arrayfire.h>
#include "funcs.h"
#include "utils.h"
#include "out_in_template.h"

template<af_err (*func)(af_array *, const void *, unsigned int, const dim_t *, af_dtype)> int Create (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

	LuaData arr(L, 1, dt.GetType());

	af_err err = func(arr_ud, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	return PushErr(L, err);	// data, ndims, dims, type, err, arr_ud
}

template<af_err (*func)(af_array *, const unsigned, const dim_t *, const af_dtype)> int DimsAndType (lua_State * L)
{
	lua_settop(L, 3);	// ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// ndims, dims, type, arr_ud

	af_err err = func(arr_ud, dt.GetNDims(), dt.GetDims(), GetDataType(L, 3));

	return PushErr(L, err);	// ndims, dims, type, err, arr_ud
}

template<typename T, af_err (*func)(af_array *, const T, const unsigned, const dim_t *)> int Long (lua_State * L)
{
	lua_settop(L, 3);	// val, ndims, dims

	LuaDimsAndType dims(L, 2, true);// Just dims, no type

	af_array * arr_ud = NewArray(L);// val, ndims, dims, arr_ud

	af_err err = af_constant_ulong (arr_ud, Arg<T>(L, 1), dims.GetNDims(), dims.GetDims());

	return PushErr(L, err);	// val, ndims, dims, err, arr_ud
}

#define CREATE(name) { "af_"#name, Create<&af_##name> }
#define DIMS_AND_TYPE(name) { "af_"#name, DimsAndType<&af_##name> }
#define LONG(name, t) { "af_"#name, Long<t, &af_##name> }

//
static const struct luaL_Reg create_funcs[] = {
	{
		"af_constant", [](lua_State * L)
		{
			lua_settop(L, 4);	// val, ndims, dims, type

			LuaDimsAndType dt(L, 2);

			af_array * arr_ud = NewArray(L);// val, ndims, dims, type, arr_ud

			af_err err = af_constant(arr_ud, D(L, 1), dt.GetNDims(), dt.GetDims(), dt.GetType());

			return PushErr(L, err);	// val, ndims, dims, type, err, arr_ud
		}
	}, {
		"af_constant_complex", [](lua_State * L)
		{
			lua_settop(L, 5);	// real, imag, ndims, dims, type

			LuaDimsAndType dt(L, 3);

			af_array * arr_ud = NewArray(L);// real, imag, ndims, dims, type, arr_ud

			af_err err = af_constant_complex(arr_ud, D(L, 1), D(L, 2), dt.GetNDims(), dt.GetDims(), dt.GetType());

			return PushErr(L, err);	// real, imag, ndims, dims, type, err, arr_ud
		}
	},
	LONG(constant_long, intl),
	LONG(constant_ulong, uintl),
	CREATE(create_array),
	DIMS_AND_TYPE(create_handle),
	CREATE(device_array),
	OUTIN_ARG(diag_create, int),
	OUTIN_ARG(diag_extract, int),
	{
		"af_get_seed", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			uintl seed;

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

			LuaDimsAndType dims(L, 1, false);	// Just dims, no type
			LuaDimsAndType t_dt(L, 3);

			af_array * arr_ud = NewArray(L);// ndims, dims, t_ndims, tdims, type, arr_ud

			af_err err = af_iota(arr_ud, dims.GetNDims(), dims.GetDims(), t_dt.GetNDims(), t_dt.GetDims(), t_dt.GetType());

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
			lua_insert(L, 3);	// ndims, dims, type, seq_dim

			LuaDimsAndType dt(L, 1);
				
			af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

			af_err err = af_range(arr_ud, dt.GetNDims(), dt.GetDims(), lua_tointeger(L, 4), dt.GetType());

			return PushErr(L, err);	// data, ndims, dims, type, err, arr_ud
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

#undef CREATE
#undef DIMS_AND_TYPE
#undef LONG

int CreateArrayFuncs (lua_State * L)
{
	luaL_register(L, NULL, create_funcs);

	return 0;
}