#include "../funcs.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"

#define TWO_ARGS(name) OUTIN2_ARG(name, bool)

//
static const struct luaL_Reg math_funcs[] = {
	OUTIN(abs),
	OUTIN(acos),
	OUTIN(acosh),
	TWO_ARGS(add),
	TWO_ARGS(and),
	OUTIN(arg),
	OUTIN(asin),
	OUTIN(asinh),
	OUTIN(atan),
	OUTIN(atanh),
	TWO_ARGS(atan2),
	TWO_ARGS(bitand),
	TWO_ARGS(bitor),
	TWO_ARGS(bitshiftl),
	TWO_ARGS(bitshiftr),
	TWO_ARGS(bitxor),
	OUTIN(cbrt),
	OUTIN(ceil),
	OUTIN(conjg),
	OUTIN(cos),
	OUTIN(cosh),
	OUTIN(cplx),
	TWO_ARGS(cplx2),
	TWO_ARGS(div),
	TWO_ARGS(eq),
	OUTIN(erf),
	OUTIN(erfc),
	OUTIN(exp),
	OUTIN(expm1),
	OUTIN(factorial),
	OUTIN(floor),
	TWO_ARGS(ge),
	TWO_ARGS(gt),
	TWO_ARGS(hypot),
	OUTIN(imag),
	TWO_ARGS(le),
	OUTIN(lgamma),
	OUTIN(log),
	OUTIN(log10),
	OUTIN(log1p),
	TWO_ARGS(lt),
	TWO_ARGS(maxof),
	TWO_ARGS(minof),
	TWO_ARGS(mod),
	TWO_ARGS(mul),
	TWO_ARGS(neq),
	OUTIN(not),
	TWO_ARGS(or),
	TWO_ARGS(pow),
	OUTIN(real),
	TWO_ARGS(rem),
	TWO_ARGS(root),
	OUTIN(round),
#if AF_API_VERSION >= 31
	OUTIN(sigmoid),
#endif
	OUTIN(sign),
	OUTIN(sin),
	OUTIN(sinh),
	OUTIN(sqrt),
	TWO_ARGS(sub),
	OUTIN(tan),
	OUTIN(tanh),
	OUTIN(trunc),
	OUTIN(tgamma),

	{ NULL, NULL }
};

#undef TWO_ARGS

int Mathematics (lua_State * L)
{
	luaL_register(L, NULL, math_funcs);

	return 0;
}