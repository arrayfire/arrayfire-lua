// plugin.arrayfire.cpp : Defines the exported functions for the DLL application.
//
#include <arrayfire.h>
#include "methods.h"
#include "utils.h"

//#include "stdafx.h"

// stack = data, ndims, dims, type
static int CreateArray (lua_State * L)
{
	LuaDimsAndType dt(L, 2);

	void * amem = NewArray(L); // ..., arr

	LuaData arr(L, 1, dt.GetType());

//	dim_t dims[] = { 2, 2 }; // ndims = 2

	PushResult(L, af_create_array((af_array *)amem, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType())); // ..., arr, code

	return 2;
}

// stack = ndims, dims, type
static int CreateHandle (lua_State * L)
{
	LuaDimsAndType dt(L, 2);

	void * amem = NewArray(L); // arr

	PushResult(L, af_create_handle((af_array *)amem, dt.GetNDims(), dt.GetDims(), GetDataType(L, 3))); // arr, code

	return 2;
}

// stack = data, ndims, dims, type
static int DeviceArray (lua_State * L)
{
	LuaDimsAndType dt(L, 2);

	void * amem = NewArray(L); // ..., arr

	LuaData arr(L, 1, dt.GetType());

	PushResult(L, af_device_array((af_array *)amem, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType())); // arr, code

	return 2;
}

//
static const struct luaL_Reg arrayfire_funcs[] = {
	{ "create_array", CreateArray },
	{ "create_handle", CreateHandle },
	{ "device_array", DeviceArray },
	{ NULL, NULL }
};

extern "C" __declspec(dllexport) int luaopen_arrayfire (lua_State * L)
{
	luaL_register(L, "af", arrayfire_funcs);
	// TODO: Other functions!

	ArrayMethods(L);
	// TODO: Other objects!

	return 1;
}