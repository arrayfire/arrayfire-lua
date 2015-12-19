#include "../graphics.h"
#include "../utils.h"
#include "../template/args.h"

class LuaCell {
	af_cell mCell;

public:
	af_cell * GetCell (void) { return &mCell; }

	LuaCell (lua_State * L)
	{
		lua_getfield(L, -1, "row");	// ..., row
		lua_getfield(L, -2, "col");	// ..., row, col
		lua_getfield(L, -3, "title");	// ..., row, col, title
		lua_getfield(L, -4, "cmap");// ..., row, col, title, cmap

		mCell.row = I(L, -4);
		mCell.col = I(L, -3);
		mCell.title = !lua_isnil(L, -1) ? lua_tostring(L, -2) : nullptr;
		mCell.cmap = Arg<af_colormap>(L, -1);

		lua_pop(L, 4);	// ...
	}
};

static const struct luaL_Reg draw_funcs[] = {
	{
		"af_draw_hist", [](lua_State * L)
		{
			lua_settop(L, 5);	// window, arr, min, max, props

			LuaCell cell(L);

			af_err err = af_draw_hist(Arg<af_window>(L, 1), GetArray(L, 2), D(L, 3), D(L, 4), cell.GetCell());

			lua_pushinteger(L, err);// window, arr, min, max, props, err

			return 1;
		}
	}, {
		"af_draw_image", [](lua_State * L)
		{
			lua_settop(L, 3);	// window, arr, props

			LuaCell cell(L);

			af_err err = af_draw_image(Arg<af_window>(L, 1), GetArray(L, 2), cell.GetCell());

			lua_pushinteger(L, err);// window, arr, props, err

			return 1;
		}
	}, {
		"af_draw_plot", [](lua_State * L)
		{
			lua_settop(L, 4);	// window, x, y, props

			LuaCell cell(L);

			af_err err = af_draw_plot(Arg<af_window>(L, 1), GetArray(L, 2), GetArray(L, 3), cell.GetCell());

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	},

#if AF_API_VERSION >= 32
	{
		"af_draw_plot3", [](lua_State * L)
		{
			lua_settop(L, 3);	// window, P, props

			LuaCell cell(L);

			af_err err = af_draw_plot3(Arg<af_window>(L, 1), GetArray(L, 2), cell.GetCell());

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	},
#endif

#if AF_API_VERSION > 32	|| (AF_API_VERSION == 32 && AF_VERSION_PATCH >= 1)
	{
		"af_draw_surface", [](lua_State * L)
		{
			lua_settop(L, 5);	// window, xvals, yvals, S, props

			LuaCell cell(L);

			af_err err = af_draw_surface(Arg<af_window>(L, 1), GetArray(L, 2), GetArray(L, 3), GetArray(L, 4), cell.GetCell());

			lua_pushinteger(L, err);// window, x, y, props, err

			return 1;
		}
	},
#endif

	{ NULL, NULL }
};

int Draw (lua_State * L)
{
	luaL_register(L, NULL, draw_funcs);

	return 0;
}