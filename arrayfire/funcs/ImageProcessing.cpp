#include "../funcs.h"

/*
	af_err af_bilateral (af_array *, const af_array, const float, const float, const bool);
	af_err af_color_space ( af_array *, const af_array, const af_cspace_t, const af_cspace_t);
	af_err af_dilate (af_array *, const af_array, const af_array);
	af_err af_dilate3 (af_array *, const af_array, const af_array);
	af_err af_erode (af_array *, const af_array, const af_array);
	af_err af_erode3 (af_array *, const af_array, const af_array);
	af_err af_gaussian_kernel (af_array *, const int, const int, const double, const double);
	af_err af_gray2rgb (af_array *, const af_array, const float, const float, const float);
	af_err af_hist_equal (af_array *, const af_array, const af_array);
	af_err af_histogram (af_array *, const af_array, const unsigned, const double, const double);
	af_err af_hsv2rgb (af_array *, const af_array);
	af_err af_minfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_mean_shift (af_array *, const af_array, const float, const float, const unsigned, const bool);
	af_err af_medfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_maxfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_regions (af_array *, const af_array, const af_connectivity, const af_dtype);
	af_err af_resize (af_array *, const af_array, const dim_t, const dim_t, const af_interp_type);
	af_err af_rgb2gray (af_array *, const af_array, const float, const float, const float);
	af_err af_rgb2hsv (af_array *, const af_array);
	af_err af_rgb2ycbcr (af_array *, const af_array, const af_ycc_std);	
	af_err af_rotate (af_array *, const af_array, const float, const bool, const af_interp_type);
	af_err af_sat (af_array *, const af_array);
	af_err af_scale (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
	af_err af_skew (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_sobel_operator (af_array *, af_array *, const af_array, const unsigned);
	af_err af_transform (af_array *, const af_array, const af_array, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_translate (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
	af_err af_unwrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_wrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_ycbcr2rgb (af_array *, const af_array, const af_ycc_std);
	*/
static const struct luaL_Reg image_processing_funcs[] = {
		{ NULL, NULL }
};

int ImageProcessing (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}