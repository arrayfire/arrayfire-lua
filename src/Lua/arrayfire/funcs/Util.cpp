#include "../funcs.h"
#include "../template/in.h"

static const struct luaL_Reg util_funcs[] = {
	IN_NONE(print_array),
#if AF_API_VERSION >= 31
	{
		"af_print_array_gen", [](lua_State * L)
		{
			lua_settop(L, 3);	// exp, arr, precision

			af_err err = af_print_array_gen(S(L, 1), GetArray(L, 2), I(L, 3));

			lua_pushinteger(L, err);// exp, arr, precision, err

			return 1;
		}
	}, {
		"af_array_to_string", [](lua_State * L)
		{
			lua_settop(L, 4);	// exp, arr, precision, transpose

			char * output;

			af_err err = af_array_to_string(&output, S(L, 1), GetArray(L, 2), I(L, 3), B(L, 4));

			lua_pushinteger(L, err);// exp, arr, precision, transpose, err
			lua_pushstring(L, output);	// exp, arr, precision, transpose, output

			free(output);

			return 2;
		}
	},
#endif
	{
		"af_get_version", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			int major, minor, patch;

			af_err err = af_get_version(&major, &minor, &patch);

			lua_pushinteger(L, err);// err
			lua_pushinteger(L, major);	// err, major
			lua_pushinteger(L, minor);	// err, major, minor
			lua_pushinteger(L, patch);	// err, major, minor, patch

			return 4;
		}
	},

	{ NULL, NULL }
};

int Util (lua_State * L)
{
	luaL_register(L, NULL, util_funcs);

	return 0;
}

