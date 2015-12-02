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

	lua_pushinteger(L, err);// arr, err
	lua_pushboolean(L, result);	// arr, err, result

	return 2;
}

#define PRED_REG(cond) { "af_is_" #cond, Predicate<&af_is_##cond> }

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
int ArrayMethods (lua_State * L)
{
	luaL_register(L, NULL, array_methods);

	return 0;
}

/*
AFAPI af_err 	af_copy_array (af_array *arr, const af_array in)
 	Deep copy an array to another. More...
 
AFAPI af_err 	af_get_data_ref_count (int *use_count, const af_array in)
 	Get the use count of af_array More...
 
AFAPI af_err 	af_write_array (af_array arr, const void *data, const size_t bytes, af_source src)
 	Copy data from a C pointer (host/device) to an existing array. More...
 
AFAPI af_err 	af_get_data_ptr (void *data, const af_array arr)
 	Copy data from an af_array to a C pointer. More...
 
AFAPI af_err 	af_release_array (af_array arr)
 	Reduce the reference count of the af_array. More...
 
AFAPI af_err 	af_retain_array (af_array *out, const af_array in)
 	Increments an af_array reference count. More...
 
AFAPI af_err 	af_eval (af_array in)
 	Evaluate any expressions in the Array. More...
 
AFAPI af_err 	af_get_elements (dim_t *elems, const af_array arr)
 	Gets the number of elements in an array. More...
 
AFAPI af_err 	af_get_type (af_dtype *type, const af_array arr)
 	Gets the type of an array. More...
 
AFAPI af_err 	af_get_dims (dim_t *d0, dim_t *d1, dim_t *d2, dim_t *d3, const af_array arr)
 	Gets the dimseions of an array. More...
 
AFAPI af_err 	af_get_numdims (unsigned *result, const af_array arr)
*/