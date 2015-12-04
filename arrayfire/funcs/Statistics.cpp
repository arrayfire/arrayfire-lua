#include "../funcs.h"

/*
	af_err af_corrcoef (double *, double *, const af_array, const af_array);
	af_err af_cov (	af_array *, const af_array, const af_array, const bool);
	af_err af_median (af_array *, const af_array, const dim_t);
	af_err af_median_all (double *, double *, const af_array);
	af_err af_mean (af_array *, const af_array, const dim_t);
	af_err af_mean_all (double *, double *, const af_array);
	af_err af_mean_all_weighted (double *, double *, const af_array, const af_array);	
	af_err af_mean_weighted (af_array *, const af_array, const af_array, const dim_t);
	af_err af_stdev (af_array *, const af_array, const dim_t);
	af_err af_stdev_all (double *, double *, const af_array);
	af_err af_var (af_array *, const af_array, const bool, const dim_t);
	af_err af_var_all (double *, double *, const af_array, const bool);	
	af_err af_var_all_weighted (double *, double *, const af_array, const af_array);
	af_err af_var_weighted (af_array *, const af_array, const af_array, const dim_t);
*/

int Statistics (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}