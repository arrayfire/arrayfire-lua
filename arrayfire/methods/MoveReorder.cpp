#include "../methods.h"

/*
	af_err af_flat (af_array *, const af_array);
	af_err af_flip (af_array *, const af_array, const unsigned);
	af_err af_join (af_array *, const int, const af_array, const af_array);
	af_err af_join_many (af_array *, const int, const unsigned, const af_array *);
	af_err af_moddims (af_array *, const af_array, const unsigned, const dim_t *);
	af_err af_reorder (af_array *, const af_array, const unsigned, const unsigned, const unsigned, const unsigned);
	af_err af_shift (af_array *, const af_array, const int, const int, const int, const int);
	af_err af_tile (af_array *, const af_array, const unsigned, const unsigned, const unsigned, const unsigned);
	af_err af_transpose (af_array *, af_array, const bool);
	af_err af_transpose_inplace (af_array, const bool);
*/

int MoveReorder (lua_State * L)
{
//	luaL_register(L, NULL, array_methods);

	return 0;
}