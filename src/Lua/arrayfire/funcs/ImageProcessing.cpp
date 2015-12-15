#include "../funcs.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out2_in.h"
#include "../template/out2_in2.h"

static const struct luaL_Reg image_processing_funcs[] = {
	OUTIN_ARG3(bilateral, float, float, bool),
	OUTIN_ARG2(color_space, af_cspace_t, af_cspace_t),
	OUTIN2(dilate),
	OUTIN2(dilate3),
	OUTIN2(erode),
	OUTIN2(erode3),
	{
		"af_gaussian_kernel", [](lua_State * L)
		{
			lua_settop(L, 4);	// row, col, sigma_r, sigma_c

			af_array * arr_ud = NewArray(L);// row, col, sigma_r, sigma_c, arr_ud

			af_err err = af_gaussian_kernel(arr_ud, I(L, 1), I(L, 2), D(L, 3), D(L, 4));

			return PushErr(L, err);	// row, col, sigma_r, sigma_c, err, arr_ud
		}
	},
	OUTIN_ARG3(gray2rgb, float, float, float),
	OUTIN2(hist_equal),
	OUTIN_ARG3(histogram, unsigned, double, double),
	OUTIN(hsv2rgb),
	OUTIN_ARG3(maxfilt, dim_t, dim_t, af_border_type),
	OUTIN_ARG4(mean_shift, float, float, unsigned, bool),
	OUTIN_ARG3(medfilt, dim_t, dim_t, af_border_type),
	OUTIN_ARG3(minfilt, dim_t, dim_t, af_border_type),
	OUTIN(rgb2hsv),
	OUTIN_ARG2(regions, af_connectivity, af_dtype),
	OUTIN_ARG3(resize, dim_t, dim_t, af_interp_type),
	OUTIN_ARG3(rgb2gray, float, float, float),
#if AF_API_VERSION >= 31
	OUTIN_ARG(rgb2ycbcr, af_ycc_std),
#endif
	OUTIN_ARG3(rotate, float, bool, af_interp_type),
#if AF_API_VERSION >= 31
	OUTIN(sat),
#endif
	OUTIN_ARG5(scale, float, float, dim_t, dim_t, af_interp_type),
	OUTIN_ARG6(skew, float, float, dim_t, dim_t, af_interp_type, bool),
	OUT2IN_ARG(sobel_operator, unsigned),
	OUTIN2_ARG4(transform, dim_t, dim_t, af_interp_type, bool),
	OUTIN_ARG5(translate, float, float, dim_t, dim_t, af_interp_type),
#if AF_API_VERSION >= 31
	OUTIN_ARG7(unwrap, dim_t, dim_t, dim_t, dim_t, dim_t, dim_t, bool),
	OUTIN_ARG9(wrap, dim_t, dim_t, dim_t, dim_t, dim_t, dim_t, dim_t, dim_t, bool),
	OUTIN_ARG(ycbcr2rgb, af_ycc_std),
#endif

	{ NULL, NULL }
};

int ImageProcessing (lua_State * L)
{
	luaL_register(L, NULL, image_processing_funcs);

	return 0;
}