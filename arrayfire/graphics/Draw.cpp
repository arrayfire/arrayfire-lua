#include "../graphics.h"
#include "../utils.h"

/*
	af_err af_draw_plot3 (const af_window, const af_array, const af_cell *);
	af_err af_draw_surface (const af_window, const af_array, const af_array, const af_array, const af_cell *);
*/
//
static const struct luaL_Reg draw_funcs[] = {
	{
		"af_draw_hist", [](lua_State * L)
		{
			lua_settop(L, 5);	// window, arr, min, max, props

			// TODO: const af_cell *...

			af_err err = af_draw_hist((af_window)lua_tointeger(L, 1), GetArray(L, 2), lua_tonumber(L, 3), lua_tonumber(L, 4), nullptr);

			lua_pushinteger(L, err);// window, arr, min, max, props, err

			return 1;
		}
	}, {
		"af_draw_image", [](lua_State * L)
		{
			lua_settop(L, 3);	// window, arr, props

			// TODO: const af_cell *...

			af_err err = af_draw_image((af_window)lua_tointeger(L, 1), GetArray(L, 2), nullptr);

			lua_pushinteger(L, err);// window, arr, props, err

			return 1;
		}
	}, {
		"af_draw_plot", [](lua_State * L)
		{
			lua_settop(L, 4);	// window, x, y, props

			// TODO: const af_cell *...

			af_err err = af_draw_plot((af_window)lua_tointeger(L, 1), GetArray(L, 2), GetArray(L, 3), nullptr);

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	}/*, {
		"af_draw_plot3", [](lua_State * L)
		{
			lua_settop(L, 3);	// window, P, props

			// TODO: const af_cell *...

			af_err err = af_draw_plot3((af_window)lua_tointeger(L, 1), GetArray(L, 2), nullptr);

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	}, , {
		"af_draw_surface", [](lua_State * L)
		{
			lua_settop(L, 4);	// window, xvals, yvals, S, props

			// TODO: const af_cell *...

			af_err err = af_draw_surface((af_window)lua_tointeger(L, 1), GetArray(L, 2), GetArray(L, 3), GetArray(L, 4), nullptr);

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	}*/,

	{ NULL, NULL }
};

int Draw (lua_State * L)
{
	luaL_register(L, NULL, draw_funcs);

	return 0;
}