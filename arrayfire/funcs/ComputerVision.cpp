#include "../funcs.h"
#include "../utils.h"

template<af_err (*func)(af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float)> int SIFT (lua_State * L)
{
	lua_settop(L, 8);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio

	af_features * features_ud = NewFeatures(L);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, features_ud
	af_array * arr_ud = NewArray(L);// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, features_ud, arr_ud

	af_err err = func(features_ud, arr_ud, GetArray(L, 1), (const unsigned)lua_tointeger(L, 2), (const float)lua_tonumber(L, 3), (const float)lua_tonumber(L, 4), (const float)lua_tonumber(L, 5), lua_toboolean(L, 6), (const float)lua_tonumber(L, 7), (const float)lua_tonumber(L, 8));

	return PushErr(L, err, 2);	// arr, nlayers, constrast_thr, edge_thr, init_sigma, double_input, intensity_scale, feature_ratio, err, features_ud, arr_ud
}

static const struct luaL_Reg computer_vision_funcs[] = {
	{
		"af_dog", [](lua_State * L)
		{
			lua_settop(L, 3);	// arr, radius1, radius2

			af_array * arr_ud = NewArray(L);// arr, radius1, radius2, arr_ud

			af_err err = af_dog(arr_ud, GetArray(L, 1), (const int)lua_tointeger(L, 2), (const int)lua_tonumber(L, 3));

			return PushErr(L, err);	// arr, radius1, radius2, err, arr_ud
		}
	}, {
		"af_fast", [](lua_State * L)
		{
			lua_settop(L, 6);	// arr, thr, arc_length, non_max, feature_ratio, edge

			af_features * features_ud = NewFeatures(L);	// arr, thr, arc_length, non_max, feature_ratio, edge, features_ud

			af_err err = af_fast(features_ud, GetArray(L, 1), (const float)lua_tonumber(L, 2), (const unsigned)lua_tointeger(L, 3), lua_toboolean(L, 4), (const float)lua_tonumber(L, 5), (const unsigned)lua_tointeger(L, 6));

			return PushErr(L, err);	// arr, thr, arc_length, non_max, feature_ratio, edge, err, features_ud
		}
	}, 
	/*{
		"af_gloh", SIFT<&af_gloh>
		}, */
	{
		"af_harris", [](lua_State * L)
		{
			lua_settop(L, 6);	// arr, max_corners, min_response, sigma, block_size, k_thr

			af_features * features_ud = NewFeatures(L);	// arr, max_corners, min_response, sigma, block_size, k_thr, features_ud

			af_err err = af_harris(features_ud, GetArray(L, 1), (const unsigned)lua_tointeger(L, 2), (const float)lua_tonumber(L, 3), (const float)lua_tonumber(L, 4), (const unsigned)lua_tointeger(L, 5), (const float)lua_tonumber(L, 6));

			return PushErr(L, err);	// arr, max_corners, min_response, sigma, block_size, k_thr, err, features_ud
		}
	}, {
		"af_orb", [](lua_State * L)
		{
			lua_settop(L, 6);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img

			af_features * features_ud = NewFeatures(L);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img, features_ud
			af_array * arr_ud = NewArray(L);// arr, fast_thr, max_feat, scl_factor, levels, blur_img, features_ud, arr_ud

			af_err err = af_orb(features_ud, arr_ud, GetArray(L, 1), (const float)lua_tonumber(L, 2), (const unsigned)lua_tointeger(L, 3), (const float)lua_tonumber(L, 4), (const unsigned)lua_tonumber(L, 5), lua_toboolean(L, 6));

			return PushErr(L, err, 2);	// arr, fast_thr, max_feat, scl_factor, levels, blur_img, err, features_ud, arr_ud
		}
	}, {
		"af_sift", SIFT<&af_sift>
	}, {
		"af_susan", [](lua_State * L)
		{
			lua_settop(L, 6);	// arr, radius, diff_thr, geom_thr, feature_ratio, edge

			af_features * features_ud = NewFeatures(L);	// arr, radius, diff_thr, geom_thr, feature_ratio, edge, features_ud

			af_err err = af_susan(features_ud, GetArray(L, 1), (const unsigned)lua_tointeger(L, 2), (const float)lua_tonumber(L, 3), (const float)lua_tonumber(L, 4), (const float)lua_tonumber(L, 5), (const unsigned)lua_tointeger(L, 6));

			return PushErr(L, err);	// arr, radius, diff_thr, geom_thr, feature_ratio, edge, err, features_ud
		}
	},

	{ NULL, NULL }
};

int ComputerVision (lua_State * L)
{
	luaL_register(L, NULL, computer_vision_funcs);

	return 0;
}