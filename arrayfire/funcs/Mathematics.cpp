#include "../funcs.h"
#include "../out_in_template.h"

template<af_err (*func)(af_array *, const af_array, const af_array, const bool)> int TwoArgs (lua_State * L)
{
	lua_settop(L, 3);	// lhs, rhs, batch

	af_array * arr_ud = NewArray(L);// lhs, rhs, batch, arr_ud

	af_err err = func(arr_ud, GetArray(L, 1), GetArray(L, 2), lua_toboolean(L, 3));

	return PushErr(L, err);	// lhs, rhs, batch, err, arr_ud
}

#define OUT_IN(name) { "af_" #name, OutIn<&af_##name> }
#define TWO_ARGS(name) { "af_"#name, TwoArgs<&af_##name> }

//
static const struct luaL_Reg math_funcs[] = {
	OUT_IN(abs),
	OUT_IN(acos),
	OUT_IN(acosh),
	TWO_ARGS(add),
	TWO_ARGS(and),
	OUT_IN(arg),
	OUT_IN(asin),
	OUT_IN(asinh),
	OUT_IN(atan),
	OUT_IN(atanh),
	TWO_ARGS(atan2),
	TWO_ARGS(bitand),
	TWO_ARGS(bitor),
	TWO_ARGS(bitshiftl),
	TWO_ARGS(bitshiftr),
	TWO_ARGS(bitxor),
	OUT_IN(cbrt),
	OUT_IN(ceil),
	OUT_IN(conjg),
	OUT_IN(cos),
	OUT_IN(cosh),
	OUT_IN(cplx),
	TWO_ARGS(cplx2),
	TWO_ARGS(div),
	TWO_ARGS(eq),
	OUT_IN(erf),
	OUT_IN(erfc),
	OUT_IN(exp),
	OUT_IN(expm1),
	OUT_IN(factorial),
	OUT_IN(floor),
	TWO_ARGS(ge),
	TWO_ARGS(gt),
	TWO_ARGS(hypot),
	OUT_IN(imag),
	TWO_ARGS(le),
	OUT_IN(lgamma),
	OUT_IN(log),
	OUT_IN(log10),
	OUT_IN(log1p),
	TWO_ARGS(maxof),
	TWO_ARGS(minof),
	TWO_ARGS(mod),
	TWO_ARGS(mul),
	TWO_ARGS(neq),
	OUT_IN(not),
	TWO_ARGS(or),
	TWO_ARGS(pow),
	OUT_IN(real),
	TWO_ARGS(rem),
	TWO_ARGS(root),
	OUT_IN(round),
	OUT_IN(sign),
	OUT_IN(sin),
	OUT_IN(sinh),
	OUT_IN(sqrt),
	TWO_ARGS(sub),
	OUT_IN(tan),
	OUT_IN(tanh),
	OUT_IN(trunc),
	OUT_IN(tgamma),

	{ NULL, NULL }
};

#undef OUT_IN
#undef TWO_ARGS

int Mathematics (lua_State * L)
{
	luaL_register(L, NULL, math_funcs);

	return 0;
}