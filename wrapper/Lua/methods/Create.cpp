#include <arrayfire.h>
#include "../funcs.h"
#include "../utils.h"
#include "../template/out_in.h"

template<af_err (*func)(af_array *, const void *, unsigned int, const dim_t *, af_dtype)> int Create (lua_State * L)
{
	lua_settop(L, 4);	// data, ndims, dims, type

	LuaDims dt(L, 2);

	af_array * arr_ud = NewArray(L);// data, ndims, dims, type, arr_ud

	LuaData arr(L, 1, 4);

	af_err err = func(arr_ud, arr.GetData(), dt.GetNDims(), dt.GetDims(), arr.GetType());

	return PushErr(L, err);	// data, ndims, dims, type, err, arr_ud
}

#define CREATE(name) { "af_"#name, Create<&af_##name> }

//
static const struct luaL_Reg create_funcs[] = {
	CREATE(create_array),
	DIMS_AND_TYPE(create_handle),
	CREATE(device_array),

	{ NULL, NULL }
};

#undef CREATE

int Create (lua_State * L)
{
	luaL_register(L, NULL, create_funcs);

	return 0;
}