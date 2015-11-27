#include <arrayfire.h>
#include "methods.h"
#include "utils.h"

extern "C" {
	#include <lauxlib.h>
}

template<af_err (*OP)(bool *, const af_array)> int Predicate (lua_State * L)
{
	bool result;

	af_err err = OP(&result, GetArray(L, 1));

	lua_pushboolean(L, result);	// arr, result

	PushResult(L, err);	// arr, result, err

	return 2;
}

#define PRED_REG(cond) { "is" #cond, Predicate<&af_is_##cond> }

//
static const struct luaL_Reg array_methods[] = {
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
	// TODO: Other methods
	{ NULL, NULL }
};

#undef PRED_REG

// Populate with array methods, metamethods
void ArrayMethods (lua_State * L)
{
	luaL_newmetatable(L, "af_array"); // mt
	lua_pushvalue(L, -1);	// mt, mt
	lua_setfield(L, -2, "__index"); // mt = { __index = mt }
	luaL_register(L, NULL, array_methods);
	lua_pop(L, 1);	// (clear)
}