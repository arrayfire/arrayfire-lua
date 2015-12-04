#include <arrayfire.h>
#include "funcs.h"
#include "utils.h"

template<af_err (*func)(af_array *, const void *, unsigned int, const dim_t *, af_dtype)> int Create (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

	LuaData arr(L, 1, dt.GetType());

	af_err err = func(arr_ud, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	return PushErr(L, err);	// data, ndims, dims, type, err, arr_ud
}

template<af_err (*func)(af_array *, const af_array, const int)> int Diag (lua_State * L)
{
	lua_settop(L, 2);	// arr, num

	af_array * arr_ud = NewArray(L);// arr, num, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), lua_tointeger(L, 2));

	return PushErr(L, err);	// arr, num, err, arr_ud
}

template<af_err (*func)(af_array *, const unsigned, const dim_t *, const af_dtype)> int DimsAndType (lua_State * L)
{
	lua_settop(L, 3);	// ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// ndims, dims, type, arr_ud

	af_err err = func(arr_ud, dt.GetNDims(), dt.GetDims(), GetDataType(L, 3));

	return PushErr(L, err);	// ndims, dims, type, err, arr_ud
}

template<af_err (*func)(af_array *, const af_array, bool)> int Triangle (lua_State * L)
{
	lua_settop(L, 2);	// arr, is_unit_diag

	af_array * arr_ud = NewArray(L);// arr, is_unit_diag, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), lua_toboolean(L, 2));

	return PushErr(L, err);	// arr, is_unit_diag, err, arr_ud
}

//
static const struct luaL_Reg create_funcs[] = {
	{
		"af_constant", [](lua_State * L)
		{
			lua_settop(L, 4);	// val, ndims, dims, type

			LuaDimsAndType dt(L, 2);

			af_array * arr_ud = NewArray(L);// val, ndims, dims, type, arr_ud

			af_err err = af_constant(arr_ud, lua_tonumber(L, 1), dt.GetNDims(), dt.GetDims(), dt.GetType());

			return PushErr(L, err);	// val, ndims, dims, type, err, arr_ud
		}
	}, {
		"af_constant_complex", [](lua_State * L)
		{
			lua_settop(L, 5);	// real, imag, ndims, dims, type

			LuaDimsAndType dt(L, 3);

			af_array * arr_ud = NewArray(L);// real, imag, ndims, dims, type, arr_ud

			af_err err = af_constant_complex(arr_ud, lua_tonumber(L, 1), lua_tonumber(L, 2), dt.GetNDims(), dt.GetDims(), dt.GetType());

			return PushErr(L, err);	// real, imag, ndims, dims, type, err, arr_ud
		}
	}, {
		"af_constant_long", [](lua_State * L)
		{
			lua_settop(L, 3);	// val, ndims, dims

			LuaDimsAndType dims(L, 2, true);// Just dims, no type

			af_array * arr_ud = NewArray(L);// val, ndims, dims, arr_ud

			af_err err = af_constant_long (arr_ud, (intl)lua_tointeger(L, 1), dims.GetNDims(), dims.GetDims());

			return PushErr(L, err);	// val, ndims, dims, err, arr_ud
		}
	}, {
		"af_constant_ulong", [](lua_State * L)
		{
			lua_settop(L, 3);	// val, ndims, dims

			LuaDimsAndType dims(L, 2, true);// Just dims, no type

			af_array * arr_ud = NewArray(L);// val, ndims, dims, arr_ud

			af_err err = af_constant_ulong (arr_ud, (uintl)lua_tointeger(L, 1), dims.GetNDims(), dims.GetDims());

			return PushErr(L, err);	// val, ndims, dims, err, arr_ud
		}
	}, {
		"af_create_array", Create<&af_create_array>
	}, {
		"af_create_handle", DimsAndType<&af_create_handle>
	}, {
		"af_device_array", Create<&af_device_array>
	}, {
		"af_diag_create", Diag<&af_diag_create>
	}, {
		"af_diag_extract", Diag<&af_diag_extract>
	}, {
		"af_get_seed", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			uintl seed;

			af_err err = af_get_seed(&seed);

			lua_pushinteger(L, seed);	// seed

			return PushErr(L, err);	// err, seed
		}
	}, {
		"af_identity", DimsAndType<&af_identity>
	}, {
		"af_iota", [](lua_State * L)
		{
			lua_settop(L, 5);	// ndims, dims, t_ndims, tdims, type

			LuaDimsAndType dims(L, 1, false);	// Just dims, no type
			LuaDimsAndType t_dt(L, 3);

			af_array * arr_ud = NewArray(L);// ndims, dims, t_ndims, tdims, type, arr_ud

			af_err err = af_iota(arr_ud, dims.GetNDims(), dims.GetDims(), t_dt.GetNDims(), t_dt.GetDims(), t_dt.GetType());

			return PushErr(L, err);	// ndims, dims, t_ndims, tdims, type, err, arr_ud
		}
	}, {
		"af_load_image", [](lua_State * L)
		{
			lua_settop(L, 2);	// filename, is_color

			af_array * arr_ud = NewArray(L);// filename, is_color, arr_ud

			af_err err = af_load_image(arr_ud, lua_tostring(L, 1), lua_toboolean(L, 2));

			return PushErr(L, err);	// filename, is_color, err, arr_ud
		}
	}, {
		"af_load_image_memory", [](lua_State * L)
		{
			lua_settop(L, 1);	// ptr

			af_array * arr_ud = NewArray(L);// ptr, arr_ud

			af_err err = af_load_image_memory(arr_ud, GetMemory(L, 1));

			return PushErr(L, err);	// ptr, err, arr_ud
		}
	}, {
		"af_lower", Triangle<&af_lower>
	}, {
		"af_randn", DimsAndType<&af_randn>
	}, {
		"af_randu", DimsAndType<&af_randu>
	}, {
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

			af_err err = af_set_seed(lua_tointeger(L, 1));

			lua_pushinteger(L, err);// seed, err

			return 1;
		}
	}, {
		"af_upper", Triangle<&af_upper>
	},

	{ NULL, NULL }
};

// load_image_native?

int CreateArrayFuncs (lua_State * L)
{
	luaL_register(L, NULL, create_funcs);

	return 0;
}