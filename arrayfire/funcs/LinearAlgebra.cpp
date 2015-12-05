#include "../funcs.h"

/*
	af_err af_cholesky (af_array *, int *, const af_array, const bool);
	af_err af_cholesky_inplace (int *, const af_array, const bool);
	af_err af_det (double *, double *, const af_array);
	af_err af_dot (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_inverse (af_array *, const af_array, const af_array, const af_mat_prop);
	af_err af_lu (af_array *, af_array *, af_array *, const af_array);
	af_err af_lu_inplace (af_array *, af_array, const bool);		
	af_err af_matmul (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_norm (double *, const af_array, const af_norm_type, const double, const double);
	af_err af_qr (af_array *, af_array *, af_array *, const af_array);
	af_err af_qr_inplace ( af_array *, af_array);
	af_err af_rank (unsigned *, const af_array, const double);
	af_err af_solve (af_array *, const af_array, const af_array, const af_mat_prop);
	af_err af_solve_lu (af_array *, const af_array, const af_array, const af_array, const af_mat_prop);
	af_err af_svd (af_array *, af_array *, af_array *, const af_array);
	af_err af_svd_inplace (af_array *, af_array *, af_array *, const af_array);
	af_err af_transpose (af_array *, af_array, const bool);
	af_err af_transpose_inplace (af_array, const bool);
*/
static const struct luaL_Reg linear_algebra_funcs[] = {
	{ NULL, NULL }
};

int LinearAlgebra (lua_State * L)
{
	luaL_register(L, NULL, linear_algebra_funcs);

	return 0;
}