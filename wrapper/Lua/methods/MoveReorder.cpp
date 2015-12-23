#include "../methods.h"
#include "../utils.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out_in3.h"

static const struct luaL_Reg move_reorder_methods[] = {
	OUTIN(flat),
	OUTIN_ARG(flip, unsigned),
	{
		"af_join", [](lua_State * L)
		{
			lua_settop(L, 3);	// dim, first, second

			af_array * arr_ud = NewArray(L);// dim, first, second, arr_ud

			af_err err = af_join(arr_ud, I(L, 1), GetArray(L, 2), GetArray(L, 3));

			return PushErr(L, err);	// dim, first, second, err, arr_ud
		}
	}, {
		"af_join_many", [](lua_State * L)
		{
			lua_settop(L, 3);	// num, narrays, inputs

			af_array * arr_ud = NewArray(L);// num, narrays, inputs, arr_ud

			unsigned count = U(L, 2);

			std::vector<af_array> arrays;

			for (unsigned i = 1; i <= count; ++i)
			{
				lua_rawgeti(L, 3, i);	// num, narrays, inputs, arr_ud, array

				arrays.push_back(GetArray(L, 5));

				lua_pop(L, 1);	// num, arrays, inputs, arr_ud
			}

			af_err err = af_join_many(arr_ud, I(L, 1), count, &arrays.front());

			return PushErr(L, err);	// num, arrays, inputs, err, arr_ud
		}
	}, {
		"af_moddims", [](lua_State * L)
		{
			lua_settop(L, 3);	// arr, ndims, dims

			LuaDims dims(L, 2);

			af_array * arr_ud = NewArray(L);// arr, ndims, dims, arr_ud

			af_err err = af_moddims(arr_ud, GetArray(L, 1), dims.GetNDims(), dims.GetDims());

			return PushErr(L, err);	// arr, ndims, dims, err, arr_ud
		}
	},
	OUTIN_ARG4(reorder, unsigned, unsigned, unsigned, unsigned),
#if AF_API_VERSION >= 31
	{
		"af_replace", [](lua_State * L)
		{
			lua_settop(L, 3);	// a, cond, b

			af_err err = af_replace(GetArray(L, 1), GetArray(L, 2), GetArray(L, 3));

			lua_pushinteger(L, err);// a, cond, b, err

			return 1;
		}
	}, {
		"af_replace_scalar", [](lua_State * L)
		{
			lua_settop(L, 3);	// a, cond, b

			af_err err = af_replace_scalar(GetArray(L, 1), GetArray(L, 2), D(L, 3));

			lua_pushinteger(L, err);// a, cond, b, err

			return 1;
		}
	},
    OUTIN3(select),
    OUTIN2_ARG(select_scalar_r, double),
	{
		"af_select_scalar_l", [](lua_State * L)
		{
			lua_settop(L, 3);	// cond, a, b

			af_array * arr_ud = NewArray(L);// cond, a, b, arr_ud

			af_err err = af_select_scalar_l(arr_ud, GetArray(L, 1), D(L, 2), GetArray(L, 3));

			return PushErr(L, err);	// cond, a, b, err, arr_ud
		}
	},
#endif
	OUTIN_ARG4(shift, int, int, int, int),
	OUTIN_ARG4(tile, unsigned, unsigned, unsigned, unsigned),

	{ NULL, NULL }
};

int MoveReorder (lua_State * L)
{
	luaL_register(L, NULL, move_reorder_methods);

	return 0;
}