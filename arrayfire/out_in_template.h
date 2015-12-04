#include "utils.h"

template<af_err (*func)(af_array *, af_array)> int OutIn (lua_State * L)
{
	lua_settop(L, 1);	// in

	af_array * arr_ud = NewArray(L);// in, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1));

	return PushErr(L, err);	// in, err, arr_ud
}