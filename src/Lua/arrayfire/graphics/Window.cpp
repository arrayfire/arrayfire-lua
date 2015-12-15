#include <arrayfire.h>
#include "../graphics.h"
#include "../template/args.h"

template<typename T, af_err (*func)(const af_window, const T, const T)> int TwoT (lua_State * L)
{
	lua_settop(L, 3);	// window, u1, u2

	af_err err = func(Arg<af_window>(L, 1), Arg<T>(L, 2), Arg<T>(L, 3));

	lua_pushinteger(L, err);// window, u1, u2, err

	return 1;
}

static const struct luaL_Reg window_funcs[] = {
	{
		"af_create_window", [](lua_State * L)
		{
			lua_settop(L, 3);	// width, height, title

			af_window wnd = 0;

			af_err err = af_create_window(&wnd, I(L, 1), I(L, 2), S(L, 3));

			lua_pushinteger(L, err);// width, height, title, err
			lua_pushinteger(L, wnd);// width, height, title, err, wnd

			return 2;
		}
	}, {
		"af_destroy_window", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			af_err err = af_destroy_window(Arg<af_window>(L, 1));

			lua_pushinteger(L, err);// window, err

			return 1;
		}
	}, {
		"af_grid", TwoT<int, &af_grid>
	}, {
		"af_is_window_closed", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			bool is_closed;

			af_err err = af_is_window_closed(&is_closed, Arg<af_window>(L, 1));

			lua_pushinteger(L, err);// window, err
			lua_pushboolean(L, is_closed);	// window, err, is_closed

			return 2;
		}
	}, {
		"af_set_position", TwoT<unsigned, &af_set_position>
	},
#if AF_API_VERSION >= 31
	{
		"af_set_size", TwoT<unsigned, &af_set_size>
	},
#endif
	{
		"af_set_title", [](lua_State * L)
		{
			lua_settop(L, 2);	// window, title

			af_err err = af_set_title(Arg<af_window>(L, 1), lua_tostring(L, 2));

			lua_pushinteger(L, err);// window, title, err

			return 1;
		}
	}, {
		"af_show", [](lua_State * L)
		{
			lua_settop(L, 1);	// window

			af_err err = af_show(Arg<af_window>(L, 1));

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