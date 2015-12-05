#include <arrayfire.h>
#include "../graphics.h"

template<af_err (*func)(const af_window, const unsigned, const unsigned)> int TwoUnsigned (lua_State * L)
{
	lua_settop(L, 3);	// window, u1, u2

	af_err err = func((const af_window)lua_tointeger(L, 1), (const unsigned)lua_tointeger(L, 2), (const unsigned)lua_tointeger(L, 3));

	lua_pushinteger(L, err);// window, u1, u2, err

	return 1;
}

static const struct luaL_Reg window_funcs[] = {
	{
		"af_destroy_window", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			af_err err = af_destroy_window((const af_window)lua_tointeger(L, 1));

			lua_pushinteger(L, err);// window, err

			return 1;
		}
	}, {
		"af_grid", [](lua_State * L)
		{
			lua_settop(L, 3);	// window, rows, cols

			af_err err = af_grid((const af_window)lua_tointeger(L, 1), (const int)lua_tointeger(L, 2), (const int)lua_tointeger(L, 3));

			lua_pushinteger(L, err);// window, rows, cols, err

			return 1;
		}
	}, {
		"af_is_window_closed", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			bool is_closed;

			af_err err = af_is_window_closed(&is_closed, (const af_window)lua_tointeger(L, 1));

			lua_pushinteger(L, err);// window, err
			lua_pushboolean(L, is_closed);	// window, err, is_closed

			return 2;
		}
	}, {
		"af_set_position", TwoUnsigned<&af_set_position>
	}, {
		"af_set_size", TwoUnsigned<&af_set_size>
	}, {
		"af_set_title", [](lua_State * L)
		{
			lua_settop(L, 2);	// window, title

			af_err err = af_set_title((const af_window)lua_tointeger(L, 1), lua_tostring(L, 2));

			lua_pushinteger(L, err);// window, title, err

			return 1;
		}
	}, {
		"af_show", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			af_err err = af_show((const af_window)lua_tointeger(L, 1));

			lua_pushinteger(L, err);// window, err

			return 1;
		}
	},

	{ NULL, NULL }
};

int Window (lua_State * L)
{
	luaL_register(L, NULL, window_funcs);

	return 0;
}