#include <arrayfire.h>
#include "funcs.h"
#include "utils.h"

static void PushErr (lua_State * L, af_err err)
{
	lua_pushinteger(L, err);// ..., arr_ud, err
	lua_insert(L, -2);	// ..., err, arr_ud
}

template<af_err (*func)(af_array *, const void *, unsigned int, const dim_t *, af_dtype)> int Create (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

	LuaData arr(L, 1, dt.GetType());

	//	dim_t dims[] = { 2, 2 }; // ndims = 2

	af_err err = func(arr_ud, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	PushErr(L, err);// data, ndims, dims, type, err, arr_ud

	return 2;
}

template<af_err (*func)(af_array *, const af_array, const int)> int Diag (lua_State * L)
{
	lua_settop(L, 2);	// arr, num

	af_array * arr_ud = NewArray(L);// arr, num, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), lua_tointeger(L, 2));

	PushErr(L, err);// arr, num, err, arr_ud

	return 2;
}
/*

AFAPI af_err 	af_range(af_array *out, const unsigned ndims, const dim_t *const dims, const int seq_dim, const af_dtype type)
// ^^^ Can use some swapping?
*/

template<af_err (*func)(af_array *, const unsigned, const dim_t *, const af_dtype)> int DimsAndType (lua_State * L)
{
	lua_settop(L, 3);	// ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// ndims, dims, type, arr_ud

	af_err err = func(arr_ud, dt.GetNDims(), dt.GetDims(), GetDataType(L, 3));

	PushErr(L, err);// ndims, dims, type, err, arr_ud

	return 2;
}

template<af_err (*func)(af_array *, const af_array, bool)> int Triangle (lua_State * L)
{
	lua_settop(L, 2);	// arr, is_unit_diag

	af_array * arr_ud = NewArray(L);// arr, is_unit_diag, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), lua_toboolean(L, 2));

	PushErr(L, err);// arr, is_unit_diag, err, arr_ud

	return 2;
}

static void * GetMemory (lua_State * L, int index)
{
	if (lua_type(L, index) == LUA_TSTRING) return (void *)lua_tostring(L, index);

	else return lua_touserdata(L, index);
}

//
static const struct luaL_Reg create_funcs[] = {
	/*
	AFAPI af_err 	af_constant (af_array *arr, const double val, const unsigned ndims, const dim_t *const dims, const af_dtype type)

	AFAPI af_err 	af_constant_complex (af_array *arr, const double real, const double imag, const unsigned ndims, const dim_t *const dims, const af_dtype type)

	AFAPI af_err 	af_constant_long (af_array *arr, const intl val, const unsigned ndims, const dim_t *const dims)

	AFAPI af_err 	af_constant_ulong (af_array *arr, const uintl val, const unsigned ndims, const dim_t *const dims)
	*/
	{
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

			PushErr(L, err);// err, seed

			return 2;
		}
	}, {
		"af_identity", DimsAndType<&af_identity>
	}, {
		"af_iota", [](lua_State * L)
		{
			lua_settop(L, 5);	// ndims, dims, t_ndims, tdims, type

		//	LuaDims dims(L, 1);
			LuaDimsAndType t_dt(L, 3);

			af_array * arr_ud = NewArray(L);// ndims, dims, t_ndims, tdims, type, arr_ud

		//	af_err err = af_iota(af_array *out, const unsigned ndims, const dim_t *const dims, const unsigned t_ndims, const dim_t *const tdims, const af_dtype type)

		//	PushErr(L, err);// ndims, dims, t_ndims, tdims, type, err, arr_ud

			return 2;
		}
	}, {
		"af_load_image", [](lua_State * L)
		{
			lua_settop(L, 2);	// filename, is_color

			af_array * arr_ud = NewArray(L);// filename, is_color, arr_ud

			af_err err = af_load_image(arr_ud, lua_tostring(L, 1), lua_toboolean(L, 2));

			PushErr(L, err);// filename, is_color, err, arr_ud

			return 2;
		}
	}, {
		"af_load_image_memory", [](lua_State * L)
		{
			lua_settop(L, 1);	// ptr

			af_array * arr_ud = NewArray(L);// data, ndims, dims, type, parr

			af_err err = af_load_image_memory(arr_ud, GetMemory(L, 1));

			PushErr(L, err);// ptr, err, arr_ud

			return 2;
		}
	}, {
		"af_lower", Triangle<&af_lower>
	}, {
		"af_randn", DimsAndType<&af_randn>
	}, {
		"af_randu", DimsAndType<&af_randu>
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