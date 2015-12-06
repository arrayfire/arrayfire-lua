#include <arrayfire.h>
#include "methods.h"
#include "from_template.h"
#include "in_template.h"
#include "out_in_template.h"
#include "utils.h"

#define PRED_REG(cond) FROM_NONE(is_##cond, bool)

//
static const struct luaL_Reg array_methods[] = {
	OUTIN(copy_array),
	IN_NONE(eval),
	FROM_NONE(get_data_ref_count, int),
	{
		"af_get_data_ptr", [](lua_State * L)
		{
			lua_settop(L, 2);	// data, arr

			af_err err = af_get_data_ptr(lua_touserdata(L, 1), GetArray(L, 2));

			lua_pushinteger(L, err);// arr, err

			return 1;
		}
	}, {
		"af_get_dims", [](lua_State * L)
		{
			lua_settop(L, 1);	// in

			dim_t d1, d2, d3, d4;

			af_err err = af_get_dims(&d1, &d2, &d3, &d4, GetArray(L, 1));

			lua_pushinteger(L, err);// in, err
			lua_pushinteger(L, d1);	// in, err, d1
			lua_pushinteger(L, d2);	// in, err, d1, d2
			lua_pushinteger(L, d3);	// in, err, d1, d2, d3
			lua_pushinteger(L, d4);	// in, err, d1, d2, d3, d4

			return 5;
		}
	},
	FROM_NONE(get_elements, dim_t),
	FROM_NONE(get_numdims, unsigned),
	FROM_NONE(get_type, af_dtype),
	PRED_REG(empty),
	PRED_REG(scalar),
	PRED_REG(vector),
	PRED_REG(row),
	PRED_REG(column),
	PRED_REG(complex),
	PRED_REG(real),
	PRED_REG(double),
	PRED_REG(single),
	PRED_REG(realfloating),
	PRED_REG(floating),
	PRED_REG(integer),
	PRED_REG(bool),
	IN_NONE(release_array),
	OUTIN(retain_array),
	{
		"af_write_array", [](lua_State * L)
		{
			lua_settop(L, 4);	// arr, data, bytes, src

			af_err err = af_write_array(GetArray(L, 1), GetMemory(L, 2), Arg<size_t>(L, 3), Arg<af_source>(L, 4));

			lua_pushinteger(L, err);// arr, data, bytes, src, err

			return 1;
		}
	},

	{ NULL, NULL }
};

#undef PRED_REG

// Populate with array methods, metamethods
int ArrayMethods (lua_State * L)
{
	luaL_register(L, NULL, array_methods);

	return 0;
}