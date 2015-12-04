#include <arrayfire.h>
#include "methods.h"
#include "out_in_template.h"
#include "utils.h"

extern "C" {
	#include <lauxlib.h>
}

template<af_err (*func)(af_array)> int ArrayOnly (lua_State * L)
{
	lua_settop(L, 1);	// in

	af_err err = func(GetArray(L, 1));

	lua_pushinteger(L, err);// in, err

	return 1;
}

template<af_err (*func)(bool *, const af_array)> int Predicate (lua_State * L)
{
	lua_settop(L, 1);	// arr

	bool result;

	af_err err = func(&result, GetArray(L, 1));

	lua_pushinteger(L, err);// arr, err
	lua_pushboolean(L, result);	// arr, err, result

	return 2;
}

#define PRED_REG(cond) { "af_is_" #cond, Predicate<&af_is_##cond> }

//
static const struct luaL_Reg array_methods[] = {
	{
		"af_copy_array", OutIn<&af_copy_array>
	}, {
		"af_eval", ArrayOnly<&af_eval>
	}, {
		"af_get_data_ref_count", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			int count;

			af_err err = af_get_data_ref_count(&count, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushinteger(L, count);	// arr, err, count

			return 2;
		}
	}, {
		"af_get_data_ptr", [](lua_State * L)
		{
			lua_settop(L, 2);	// data, arr

			int count;

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
	}, {
		"af_get_elements", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			dim_t elems;

			af_err err = af_get_elements(&elems, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushinteger(L, elems);	// arr, err, elems

			return 2;
		}
	}, {
		"af_get_numdims", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			unsigned int ndims;

			af_err err = af_get_numdims(&ndims, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushinteger(L, ndims);	// arr, err, ndims

			return 2;
		}
	}, {
		"af_get_type", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			af_dtype type;

			af_err err = af_get_type(&type, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushinteger(L, type);	// arr, err, type

			return 2;
		}
	},

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

	{
		"af_release_array", ArrayOnly<&af_release_array>
	}, {
		"af_retain_array", OutIn<&af_retain_array>
	}, {
		"af_write_array", [](lua_State * L)
		{
			lua_settop(L, 4);	// arr, data, bytes, src

			af_err err = af_write_array(GetArray(L, 1), GetMemory(L, 2), lua_tointeger(L, 3), (af_source)lua_tointeger(L, 4));

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