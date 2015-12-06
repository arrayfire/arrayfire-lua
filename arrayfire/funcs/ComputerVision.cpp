#include "../funcs.h"
#include "../utils.h"
#include "../out_in_template.h"
#include "../out_in2_template.h"
#include "../out2_in2_template.h"

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
	{
		"af_dog", OutIn_Arg2<int, int, &af_dog>
	}, {
		"af_fast", FiveArgs<float, unsigned, bool, float, unsigned, &af_fast>
	},

#if AF_API_VERSION >= 32
	{
		"af_gloh", SIFT<&af_gloh>
	},
#endif

	{
		"af_hamming_matcher", Out2In2_Arg2<dim_t, unsigned, &af_hamming_matcher>
	},	{
		"af_harris", FiveArgs<unsigned, float, float, unsigned, float, &af_harris>
	}, {
		"af_match_template", OutIn2_Arg<af_match_type, &af_match_template>
	}, {
		"af_nearest_neighbour", Out2In2_Arg3<dim_t, unsigned, af_match_type, &af_nearest_neighbour>
	}, {
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
	}, {
		"af_susan", FiveArgs<unsigned, float, float, float, unsigned, &af_susan>
	},

	{ NULL, NULL }
};

int ComputerVision (lua_State * L)
{
	luaL_register(L, NULL, computer_vision_funcs);

	return 0;
}