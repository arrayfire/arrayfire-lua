#include "../funcs.h"
#include "../utils.h"
#include "../template/doubles.h"
#include "../template/in.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out_in3.h"

template<af_err (*func)(af_array *, af_array *, af_array *, const af_array)> int Out3In (lua_State * L)
{
	lua_settop(L, 1);	// arr

	af_array * out1 = NewArray(L);	// arr, out1
	af_array * out2 = NewArray(L);	// arr, out1, out2
	af_array * out3 = NewArray(L);	// arr, out1, out2, out3

	af_err err = func(out1, out2, out3, GetArray(L, 1));

	return PushErr(L, err, 3);	// a, err, out1, out2, out3
}

#define OUT3IN(name) { "af_"#name, Out3In<&af_##name> }

static const struct luaL_Reg linear_algebra_funcs[] = {
	{
		"af_cholesky", [](lua_State * L)
		{
			lua_settop(L, 2);	// arr, is_upper

			af_array * arr_ud = NewArray(L);// arr, is_upper, arr_ud

			int info = 0;

			af_err err = af_cholesky(arr_ud, &info, GetArray(L, 1), B(L, 2));

			lua_pushinteger(L, info);	// arr, is_upper, arr_ud, info

			return PushErr(L, err, 2);	// arr, is_upper, err, arr_ud, info
		}
	}, {
		"af_cholesky_inplace", [](lua_State * L)
		{
			lua_settop(L, 2);	// arr, is_upper

			int info = 0;

			af_err err = af_cholesky_inplace(&info, GetArray(L, 1), B(L, 2));

			lua_pushinteger(L, err);// arr, is_upper, err
			lua_pushinteger(L, info);	// arr, is_upper, err, info

			return 2;
		}
	},
	DDIN(det),
	OUTIN2_ARG2(dot, af_mat_prop, af_mat_prop),
	OUTIN_ARG(inverse, af_mat_prop),
	OUT3IN(lu),
	OUTIN_ARG(lu_inplace, bool),
	OUTIN2_ARG2(matmul, af_mat_prop, af_mat_prop),
	{
		"af_norm", [](lua_State * L)
		{
			lua_settop(L, 4);	// arr, type, p, q

			double norm = 0.0;

			af_err err = af_norm(&norm, GetArray(L, 1), Arg<af_norm_type>(L, 2), D(L, 3), D(L, 4));

			lua_pushinteger(L, err);// arr, type, p, q, err
			lua_pushnumber(L, norm);// arr, type, p, q, err, norm

			return 2;
		}
	},
	OUT3IN(qr),
	OUTIN(qr_inplace),
	{
		"af_rank", [](lua_State * L)
		{
			lua_settop(L, 2);	// arr, tol

			unsigned rank = 0;

			af_err err = af_rank(&rank, GetArray(L, 1), D(L, 2));

			lua_pushinteger(L, err);// arr, tol, err
			lua_pushinteger(L, rank);	// arr, tol, err, rank

			return 2;
		}
	},
	OUTIN2_ARG(solve, af_mat_prop),
	OUTIN3_ARG(solve_lu, af_mat_prop),
#if AF_API_VERSION >= 31
	OUT3IN(svd),
	OUT3IN(svd_inplace),
#endif
	OUTIN_ARG(transpose, bool),
	IN_ARG(transpose_inplace, bool),

	{ NULL, NULL }
};

#undef OUT3IN

int LinearAlgebra (lua_State * L)
{
	luaL_register(L, NULL, linear_algebra_funcs);

	return 0;
}