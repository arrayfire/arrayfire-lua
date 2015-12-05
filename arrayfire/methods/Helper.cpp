#include "../methods.h"
#include "../out_in_template.h"
#include "../utils.h"

//
static const struct luaL_Reg helper_methods[] = {
	{
		"af_cast", [](lua_State * L)
		{
			lua_settop(L, 2);	// arr, type

			af_array * arr_ud = NewArray(L);// arr, type, arr_ud

			af_err err = af_cast(arr_ud, GetArray(L, 1), (af_dtype)lua_tointeger(L, 2));

			return PushErr(L, err);	// arr, type, err, arr_ud
		}
	}, {
		"af_isinf", OutIn<&af_isinf>
	}, {
		"af_iszero", OutIn<&af_iszero>
	},

	{ NULL, NULL }
};

int Helper (lua_State * L)
{
	luaL_register(L, NULL, helper_methods);

	return 0;
}