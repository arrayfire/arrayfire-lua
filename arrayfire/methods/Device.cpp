#include "../methods.h"

/*
	af_err af_alloc_device (void **, const dim_t);
	af_err af_alloc_pinned (void **, const dim_t);
	af_err af_device_gc ();
	af_err af_device_info (char *, char *, char *, char *);
	af_err af_device_mem_info (size_t *, size_t *, size_t *, size_t *);
	af_err af_free_device (void *);
	af_err af_get_device (int *);
	af_err af_get_device_count (int *);
	af_err af_get_device_ptr (void **, const af_array);
	af_err af_get_dbl_support (bool *, const int);
	af_err af_get_mem_step_size (size_t *);
	af_err af_info ();
	af_err af_lock_device_ptr (const af_array);
	af_err af_set_device (const int);
	af_err af_set_mem_step_size (const size_t);
	af_err af_sync (const int);
	af_err af_unlock_device_ptr (const af_array);
*/
static const struct luaL_Reg device_methods[] = {
	{ NULL, NULL }
};

int Device (lua_State * L)
{
	luaL_register(L, NULL, device_methods);

	return 0;
}