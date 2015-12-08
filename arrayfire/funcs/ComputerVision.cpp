#include "../funcs.h"
#include "../utils.h"
#include "../template/out_in.h"
#include "../template/out_in2.h"
#include "../template/out2_in2.h"

template<af_err (*func)(af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float)> int SIFT (lua_State * L)
{
	lua_settop(L, 8);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio

	af_features * features_ud = NewFeatures(L);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, features_ud
	af_array * arr_ud = NewArray(L);// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, features_ud, arr_ud

	af_err err = func(features_ud, arr_ud, GetArray(L, 1), U(L, 2), F(L, 3), F(L, 4), F(L, 5), B(L, 6), F(L, 7), F(L, 8));

	return PushErr(L, err, 2);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, err, features_ud, arr_ud
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, af_err (*func)(af_features *, af_array, const T1, const T2, const T3, const T4, const T5)> int FiveArgs (lua_State * L)
{
	lua_settop(L, 6);	// arr, arg1, arg2, arg3, arg4, arg5

	af_features * features_ud = NewFeatures(L);	// arr, arg1, arg2, arg3, arg4, arg5, features_ud

	af_err err = func(features_ud, GetArray(L, 1), Arg<T1>(L, 2), Arg<T2>(L, 3), Arg<T3>(L, 4), Arg<T4>(L, 5), Arg<T5>(L, 6));

	return PushErr(L, err);	// arr, arg1, arg2, arg3, arg4, arg5, err, features_ud
}

static const struct luaL_Reg computer_vision_funcs[] = {
#if AF_API_VERSION >= 31
	OUTIN_ARG2(dog, int, int),
#endif
	{
		"af_fast", FiveArgs<float, unsigned, bool, float, unsigned, &af_fast>
	},

#if AF_API_VERSION >= 32
	{
		"af_gloh", SIFT<&af_gloh>
	},
#endif
	{
		"af_hamming_matcher", Out2In2_Arg2<dim_t, unsigned, &af_hamming_matcher>
	},
#if AF_API_VERSION >= 31
	{
		"af_harris", FiveArgs<unsigned, float, float, unsigned, float, &af_harris>
	},
#endif
#if AF_API_VERSION >= 32
	{
		"af_homography", [](lua_State * L)
		{
			lua_settop(L, 8);	// xsrc, ysrc, xdst, ydst, htype, inlier_thr, iterations, otype

			af_array * arr_ud = NewArray(L);// xsrc, ysrc, xdst, ydst, htype, inlier_thr, iterations, otype, arr_ud

			int inliers;

			af_err err = af_homography(arr_ud, &inliers, GetArray(L, 1), GetArray(L, 2), GetArray(L, 3), GetArray(L, 4), Arg<af_homography_type>(L, 5), F(L, 6), U(L, 7), Arg<af_dtype>(L, 8));

			lua_pushinteger(L, inliers);// xsrc, ysrc, xdst, ydst, htype, inlier_thr, iterations, otype, arr_ud, inliers

			return PushErr(L, err, 2);	// xsrc, ysrc, xdst, ydst, htype, inlier_thr, iterations, otype, err, arr_ud, inliers
		}
	},
#endif
	{
		"af_match_template", OutIn2_Arg<af_match_type, &af_match_template>
	},
#if AF_API_VERSION >= 31
	OUT2IN2_ARG3(nearest_neighbour, dim_t, unsigned, af_match_type),
#endif
	{
		"af_orb", [](lua_State * L)
		{
			lua_settop(L, 6);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img

			af_features * features_ud = NewFeatures(L);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img, features_ud
			af_array * arr_ud = NewArray(L);// arr, fast_thr, max_feat, scl_factor, levels, blur_img, features_ud, arr_ud

			af_err err = af_orb(features_ud, arr_ud, GetArray(L, 1), F(L, 2), U(L, 3), F(L, 4), U(L, 5), B(L, 6));

			return PushErr(L, err, 2);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img, err, features_ud, arr_ud
		}
	}, {
		"af_sift", SIFT<&af_sift>
	},
#if AF_API_VERSION >= 31
	{
		"af_susan", FiveArgs<unsigned, float, float, float, unsigned, &af_susan>
	},
#endif

	{ NULL, NULL }
};

int ComputerVision (lua_State * L)
{
	luaL_register(L, NULL, computer_vision_funcs);

	return 0;
}