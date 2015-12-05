#include "../methods.h"

/*
	af_err af_assign_gen (af_array *, const af_array, const dim_t, const af_index_t *, const af_array);
	af_err af_assign_seq (af_array *, const af_array, const unsigned, const af_seq * const, const af_array);
	af_err af_index (af_array *, const af_array, const unsigned, const af_seq * const);
	af_err af_index_gen (af_array *, const af_array, const dim_t, const af_index_t *);
	af_err af_lookup (af_array *, const af_array, const af_array, const unsigned);
*/
static const struct luaL_Reg assign_index_methods[] = {
	{ NULL, NULL }
};

int AssignIndex (lua_State * L)
{
	luaL_register(L, NULL, assign_index_methods);

	return 0;
}