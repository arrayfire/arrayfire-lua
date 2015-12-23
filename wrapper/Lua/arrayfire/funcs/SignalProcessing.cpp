#include "../funcs.h"
#include "../template/in.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out_in3.h"

static const struct luaL_Reg signal_processing_funcs[] = {
	OUTIN2_ARG2(approx1, af_interp_type, float),
	OUTIN3_ARG2(approx2, af_interp_type, float),
	OUTIN2_ARG2(convolve1, af_conv_mode, af_conv_domain),
	OUTIN2_ARG2(convolve2, af_conv_mode, af_conv_domain),
	OUTIN3_ARG(convolve2_sep, af_conv_mode),
	OUTIN2_ARG2(convolve3, af_conv_mode, af_conv_domain),
	OUTIN_ARG2(fft, double, dim_t),
	OUTIN2_ARG(fft_convolve2, af_conv_mode),
	OUTIN2_ARG(fft_convolve3, af_conv_mode),
#if AF_API_VERSION >= 31
	OUTIN_ARG2(fft_c2r, double, bool),
	IN_ARG(fft_inplace, double),
	OUTIN_ARG2(fft_r2c, double, dim_t),
#endif
	OUTIN_ARG3(fft2, double, dim_t, dim_t),
#if AF_API_VERSION >= 31
	OUTIN_ARG2(fft2_c2r, double, bool),
	IN_ARG(fft2_inplace, double),
	OUTIN_ARG3(fft2_r2c, double, dim_t, dim_t),
#endif
	OUTIN_ARG4(fft3, double, dim_t, dim_t, dim_t),
#if AF_API_VERSION >= 31
	OUTIN_ARG2(fft3_c2r, double, bool),
	IN_ARG(fft3_inplace, double),
	OUTIN_ARG4(fft3_r2c, double, dim_t, dim_t, dim_t),
#endif
	OUTIN2(fir),
	OUTIN_ARG2(ifft, double, dim_t),
#if AF_API_VERSION >= 31
	IN_ARG(ifft_inplace, double),
#endif
	OUTIN_ARG3(ifft2, double, dim_t, dim_t),
#if AF_API_VERSION >= 31
	IN_ARG(ifft2_inplace, double),
#endif
	OUTIN_ARG4(ifft3, double, dim_t, dim_t, dim_t),
#if AF_API_VERSION >= 31
	IN_ARG(ifft3_inplace, double),
#endif
	OUTIN3(iir),

	{ NULL, NULL }
};

int SignalProcessing (lua_State * L)
{
	luaL_register(L, NULL, signal_processing_funcs);

	return 0;
}