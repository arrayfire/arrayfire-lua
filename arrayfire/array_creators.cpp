#include <arrayfire.h>
#include "funcs.h"
#include "utils.h"

static void PushErr (lua_State * L, af_err err)
{
	lua_pushinteger(L, err);// ..., arr_ud, err
	lua_insert(L, -2);	// ..., err, arr_ud
}

static int CreateArray (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

	LuaData arr(L, 1, dt.GetType());

//	dim_t dims[] = { 2, 2 }; // ndims = 2

	af_err err = af_create_array(arr_ud, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	PushErr(L, err);// data, ndims, dims, type, err, arr_ud
	
	return 2;
}

static int CreateHandle (lua_State * L)
{
	lua_settop(L, 3);	// ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * arr_ud = NewArray(L);// ndims, dims, type, arr_ud

	af_err err = af_create_handle(arr_ud, dt.GetNDims(), dt.GetDims(), GetDataType(L, 3));

	PushErr(L, err);// ndims, dims, type, err, arr_ud

	return 2;
}

static int DeviceArray (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDimsAndType dt(L, 2);

	af_array * parr = NewArray(L);	// data, ndims, dims, type, parr

	LuaData arr(L, 1, dt.GetType());

	af_err err = af_device_array(parr, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	PushErr(L, err);// data, ndims, dims, type, err, arr_ud

	return 2;
}

//
static const struct luaL_Reg create_funcs[] = {
	{ "af_create_array", CreateArray },
	{ "af_create_handle", CreateHandle },
	{ "af_device_array", DeviceArray },
	{ NULL, NULL }
};

int CreateArrayFuncs (lua_State * L)
{
	luaL_register(L, NULL, create_funcs);

	return 0;
}

/*
AFAPI af_err 	af_constant (af_array *arr, const double val, const unsigned ndims, const dim_t *const dims, const af_dtype type)
 
AFAPI af_err 	af_constant_complex (af_array *arr, const double real, const double imag, const unsigned ndims, const dim_t *const dims, const af_dtype type)
 
AFAPI af_err 	af_constant_long (af_array *arr, const intl val, const unsigned ndims, const dim_t *const dims)
 
AFAPI af_err 	af_constant_ulong (af_array *arr, const uintl val, const unsigned ndims, const dim_t *const dims)

AFAPI af_err 	af_diag_create (af_array *out, const af_array in, const int num)
 
AFAPI af_err 	af_diag_extract (af_array *out, const af_array in, const int num)

AFAPI af_err 	af_get_seed (uintl *seed)

AFAPI af_err 	af_identity (af_array *out, const unsigned ndims, const dim_t *const dims, const af_dtype type)

AFAPI af_err 	af_iota (af_array *out, const unsigned ndims, const dim_t *const dims, const unsigned t_ndims, const dim_t *const tdims, const af_dtype type)

AFAPI af_err 	af_lower (af_array *out, const af_array in, bool is_unit_diag)

AFAPI af_err 	af_randn (af_array *out, const unsigned ndims, const dim_t *const dims, const af_dtype type)

AFAPI af_err 	af_randu (af_array *out, const unsigned ndims, const dim_t *const dims, const af_dtype type)

AFAPI af_err 	af_range (af_array *out, const unsigned ndims, const dim_t *const dims, const int seq_dim, const af_dtype type)

AFAPI af_err 	af_set_seed (const uintl seed)

AFAPI af_err 	af_upper (af_array *out, const af_array in, bool is_unit_diag)



AFAPI af_err 	af_load_image (af_array *out, const char *filename, const bool isColor)
 	C Interface for loading an image. More...
 
AFAPI af_err 	af_load_image_native (af_array *out, const char *filename)
 	C Interface for loading an image as is original type. More...

AFAPI af_err 	af_load_image_memory (af_array *out, const void *ptr)
 	C Interface for loading an image from memory. More...
*/