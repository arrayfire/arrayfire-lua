#include "../funcs.h"

/*
	af_err af_delete_image_memory (void *);
	af_err af_load_image (af_array *, const char *, const bool);
	af_err af_load_image_memory (af_array *, const void *);
	af_err af_read_array_index (af_array *, const char *, const unsigned);
	af_err af_read_array_key (af_array *, const char *, const char *);
	af_err af_read_array_key_check (int *, const char *, const char *);
	af_err af_save_array (int *, const char *, const af_array, const char *, const bool);
	af_err af_save_image (const char *, const af_array);
	af_err af_save_image_memory (void ** ptr, const af_array, const af_image_format);
*/

int IO (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}