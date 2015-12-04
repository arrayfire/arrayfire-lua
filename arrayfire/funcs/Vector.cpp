#include "../funcs.h"

/*
	af_err af_accum (af_array *, const af_array, const int);
	af_err af_all_true (af_array *, const af_array, const int);
	af_err af_any_true (af_array *, const af_array, const int);
	af_err af_count (af_array *, const af_array, const int);
	af_err af_diff1 (af_array *, const af_array, const int);
	af_err af_diff2 (af_array *, const af_array, const int);
	af_err af_max (af_array *, const af_array, const int);
	af_err af_min (af_array *, const af_array, const int);
	af_err af_product (af_array *, const af_array, const int);
	af_err af_sum (af_array *, const af_array, const int);

	af_err af_all_true_all (double *, double *, const af_array);
	af_err af_any_true_all (double *, double *, const af_array);
	af_err af_count_all (double *, double *, const af_array);
	af_err af_max_all (double *, double *, const af_array);
	af_err af_min_all (double *, double *, const af_array);
	af_err af_product_all (double *, double *, const af_array);
	af_err af_sum_all (double *, double *, const af_array);

	af_err af_imax (af_array *, af_array *, const af_array, const int);
	af_err af_imin (af_array *, af_array *, const af_array, const int);
	af_err af_gradient (af_array *, af_array *, const af_array);

	af_err af_imax_all (double *, double *, unsigned *, const af_array);
	af_err af_imin_all (double *, double *, unsigned *, const af_array);

	af_err af_product_nan (af_array *, const af_array, const int, const double);
	af_err af_sum_nan (af_array *, const af_array, const int, const double);

	af_err af_product_nan_all (double *, double *, const af_array, const double);
	af_err af_sum_nan_all (double *, double *, const af_array, const double);

	af_err af_set_intersect (af_array *, const af_array, const af_array, const bool);
	af_err af_set_union (af_array *, const af_array, const af_array, const bool);
	af_err af_set_unique (af_array *, const af_array, const bool);
	af_err af_sort (af_array *, const af_array, const unsigned, const bool);
	af_err af_sort_by_key (af_array *, af_array *, const af_array, const af_array, const unsigned, const bool);
	af_err af_sort_index (af_array *, af_array *, const af_array, const unsigned, const bool);
	af_err af_where (af_array *, const af_array);
*/

int Vector (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}