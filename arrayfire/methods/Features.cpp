#include "../methods.h"

/*
af_err af_create_features (af_features *, dim_t);
af_err af_get_features_num (dim_t *, const af_features);
af_err af_get_features_orientation (af_array *, const af_features);
af_err af_get_features_score (af_array *, const af_features);
af_err af_get_features_size (af_array *, const af_features);
af_err af_get_features_xpos (af_array *, const af_features);
af_err af_get_features_ypos (af_array *, const af_features);
af_err af_release_features (af_features);
af_err af_retain_features (af_features *, const af_features);
*/
static const struct luaL_Reg features_methods[] = {
	{ NULL, NULL }
};

int Features (lua_State * L)
{
	luaL_register(L, NULL, features_methods);

	return 0;
}