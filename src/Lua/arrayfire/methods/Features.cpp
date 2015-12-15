#include "../methods.h"
#include "../utils.h"
#include "../template/args.h"

template<af_err (*func)(af_array *, const af_features)> int FeaturesProp (lua_State * L)
{
	lua_settop(L, 1);	// prop

	af_array * arr_ud = NewArray(L);// prop, arr

	af_err err = func(arr_ud, GetFeatures(L, 1));

	return PushErr(L, err);	// prop, err, arr
}

#define PROP(name) { "af_get_features_"#name, FeaturesProp<&af_get_features_##name> }

static const struct luaL_Reg features_methods[] = {
	{
		"af_create_features", [](lua_State * L)
		{
			lua_settop(L, 1);	// num

			af_features * features_ud = NewFeatures(L);	// num, features_ud

			af_err err = af_create_features(features_ud, Arg<dim_t>(L, 1));

			return PushErr(L, err);	// num, err, features_ud
		}
	}, {
		"af_get_features_num", [](lua_State * L)
		{
			lua_settop(L, 1);	// features

			dim_t num;

			af_err err = af_get_features_num(&num, GetFeatures(L, 1));

			lua_pushinteger(L, err);// features, err
			lua_pushinteger(L, num);// features, err, num

			return 2;
		}
	},
	PROP(orientation),
	PROP(score),
	PROP(size),
	PROP(xpos),
	PROP(ypos),
	{
		"af_release_features", [](lua_State * L)
		{
			lua_settop(L, 1);	// features

			af_err err = af_release_features(GetFeatures(L, 1));

			ClearFeatures(L, 1);

			lua_pushinteger(L, err);// features, err

			return 1;
		}
	}, {
		"af_retain_features", [](lua_State * L)
		{
			lua_settop(L, 1);	// features

			af_features * features_ud = NewFeatures(L);	// features, features_ud

			af_err err = af_retain_features(features_ud, GetFeatures(L, 1));

			return PushErr(L, err);	// features, err, features_ud
		}
	},

	{ NULL, NULL }
};

#undef PROP

int Features (lua_State * L)
{
	luaL_register(L, NULL, features_methods);

	return 0;
}