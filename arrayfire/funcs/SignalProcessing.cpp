#include "../funcs.h"

/*
	af_err af_approx1 (af_array *, const af_array, const af_array, const af_interp_type, const float);
	af_err af_approx2 (af_array *, const af_array, const af_array, const af_array, const af_interp_type, const float);
	af_err af_convolve1 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2_sep (af_array *, const af_array, const af_array, const af_array, const af_conv_mode);	
	af_err af_convolve3 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_fir (af_array *, const af_array, const af_array);
	af_err af_ifft (af_array *, const af_array, const double, const dim_t);
	af_err af_ifft_inplace (af_array, const double);
	af_err af_ifft2 (af_array *, const af_array, const double, const dim_t, const dim_t);
	af_err af_ifft2_inplace (af_array, const double);
	af_err af_ifft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);	
	af_err af_ifft3_inplace (af_array, const double);
	af_err af_iir (af_array *, const af_array, const af_array, const af_array);
	af_err af_fft (af_array *, const af_array, const double, const dim_t);	
	af_err af_fft_convolve2	(af_array *, const af_array, const af_array, const af_conv_mode);
	af_err af_fft_convolve3	(af_array *, const af_array, const af_array, const af_conv_mode);	
	af_err af_fft_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft_inplace (af_array, const double);
	af_err af_fft_r2c (af_array *, const af_array, const double, const dim_t);
	af_err af_fft2 (af_array *, const af_array, const double, const dim_t, const dim_t);	
	af_err af_fft2_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft2_inplace (af_array, const double);
	af_err af_fft2_r2c (af_array *, const af_array, const double, const dim_t, const dim_t);
	af_err af_fft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);	
	af_err af_fft3_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft3_inplace (af_array, const double);
	af_err af_fft3_r2c (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);
*/
static const struct luaL_Reg signal_processing_funcs[] = {
	{ NULL, NULL }
};

int SignalProcessing (lua_State * L)
{
	luaL_register(L, NULL, signal_processing_funcs);

	return 0;
}