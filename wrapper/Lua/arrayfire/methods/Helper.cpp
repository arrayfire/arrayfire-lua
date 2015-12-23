#include "../methods.h"
#include "../template/out_in.h"

//
static const struct luaL_Reg helper_methods[] = {
	OUTIN_ARG(cast, af_dtype),
	OUTIN(isinf),
	OUTIN(iszero),

	{ NULL, NULL }
};

int Helper (lua_State * L)
{
	luaL_register(L, NULL, helper_methods);

	return 0;
}