#include "../funcs.h"
#include "../utils.h"
#include "../out_template.h"

static const struct luaL_Reg io_funcs[] = {
	{
		"af_delete_image_memory", [](lua_State * L)
		{
			lua_settop(L, 1);	// ptr

			af_err err = af_delete_image_memory(GetMemory(L, 1));

			lua_pushinteger(L, err);// ptr, err

			return 1;
		}
	},
	OUT_ARG2(load_image, const char *, bool),
	{
		"af_load_image_memory", [](lua_State * L)
		{
			lua_settop(L, 1);	// ptr

			af_array * arr_ud = NewArray(L);// ptr, arr_ud

			af_err err = af_load_image_memory(arr_ud, GetMemory(L, 1));

			return PushErr(L, err);	// ptr, err, arr_ud
		}
	},
	OUT_ARG2(read_array_index, const char *, unsigned),
	OUT_ARG2(read_array_key, const char *, const char *),
	{
		"af_read_array_key_check", [](lua_State * L)
		{
			lua_settop(L, 2);	// filename, key

			int index;

			af_err err = af_read_array_key_check(&index, S(L, 1), S(L, 2));

			lua_pushinteger(L, err);// filename, key, err
			lua_pushinteger(L, index);	// filename, key, err, index

			return 2;
		}
	}, {
		"af_save_array", [](lua_State * L)
		{
			lua_settop(L, 4);	// key, arr, filename, append

			int index;

			af_err err = af_save_array(&index, S(L, 1), GetArray(L, 2), S(L, 3), B(L, 4));

			lua_pushinteger(L, err);// key, arr, filename, append, err
			lua_pushinteger(L, index);	// key, arr, filename, append, err, index

			return 2;
		}
	}, {
		"af_save_image", [](lua_State * L)
		{
			lua_settop(L, 2);	// filename, arr

			af_err err = af_save_image(S(L, 1), GetArray(L, 2));

			lua_pushinteger(L, err);// filename, arr, err

			return 1;
		}
	}, {
		"af_save_image_memory", [](lua_State * L)
		{
			lua_settop(L, 2);	// arr, format

			void * ptr;

			af_err err = af_save_image_memory(&ptr, GetArray(L, 1), Arg<af_image_format>(L, 2));

			lua_pushinteger(L, err);// arr, format, err
			lua_pushlightuserdata(L, ptr);	// arr, format, err, ptr

			return 2;
		}
	},

	{ NULL, NULL }
};

// TODO: 3.2

int IO (lua_State * L)
{
	luaL_register(L, NULL, io_funcs);

	return 0;
}