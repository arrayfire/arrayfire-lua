#include "../funcs.h"
#include "../template/doubles.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"

static const struct luaL_Reg statistics_funcs[] = {
	DDIN2(corrcoef),
	OUTIN2_ARG(cov, bool),
	OUTIN_ARG(mean, dim_t),
	DDIN(mean_all),
	DDIN2(mean_all_weighted),
	OUTIN2_ARG(mean_weighted, dim_t),
	OUTIN_ARG(median, dim_t),
	DDIN(median_all),
	OUTIN_ARG(stdev, dim_t),
	DDIN(stdev_all),
	OUTIN_ARG2(var, bool, dim_t),
	DDIN_ARG(var_all, bool),
	DDIN2(var_all_weighted),
	OUTIN2_ARG(var_weighted, dim_t),

	{ NULL, NULL }
};

int Statistics (lua_State * L)
{
	luaL_register(L, NULL, statistics_funcs);

	return 0;
}