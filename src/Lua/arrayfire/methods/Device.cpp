#include "../methods.h"
#include "../utils.h"
#include "../template/in.h"

template<af_err (*func)(void **, const dim_t)> int Alloc (lua_State * L)
{
	lua_settop(L, 1);	// bytes

	void * ptr = nullptr;

	af_err err = func(&ptr, Arg<dim_t>(L, 1));

	lua_pushinteger(L, err);// bytes, err
	lua_pushlightuserdata(L, ptr);	// bytes, err, ptr

	return 2;
}

template<af_err (*func)(void *)> int Free (lua_State * L)
{
	lua_settop(L, 1);	// ptr

	af_err err = func(UD(L, 1));

	lua_pushinteger(L, err);// ptr, err

	return 1;
}

template<typename T, af_err (*func)(T *)> int GetInt (lua_State * L)
{
	lua_settop(L, 0);	// (empty)

	T value = 0;

	af_err err = func(&value);

	lua_pushinteger(L, err);// err
	lua_pushinteger(L, value);	// err, value

	return 2;
}

template<typename T, af_err (*func)(const T)> int IntArg (lua_State * L)
{
	lua_settop(L, 1);	// arg

	af_err err = func(Arg<T>(L, 1));

	lua_pushinteger(L, err);// arg, err

	return 1;
}

template<af_err (*func)(void)> int NoArgs (lua_State * L)
{
	lua_settop(L, 0);	// (clear)

	af_err err = func();

	lua_pushinteger(L, err);// err

	return 1;
}

static const struct luaL_Reg device_methods[] = {
	{
		"af_alloc_device", Alloc<&af_alloc_device>
	}, {
		"af_alloc_pinned", Alloc<&af_alloc_pinned>
	}, {
		"af_device_gc", NoArgs<&af_device_gc>
	}, {
		"af_device_info", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			char name[256], platform[256], toolkit[256], compute[256];
			// ^^ TODO: max size?

			af_err err = af_device_info(name, platform, toolkit, compute);

			lua_pushinteger(L, err);// err
			lua_pushstring(L, name);// err, name
			lua_pushstring(L, platform);// err, name, platform
			lua_pushstring(L, toolkit);	// err, name, platform, toolkit
			lua_pushstring(L, compute);	// err, name, platform, toolkit, compute

			return 5;
		}
	}, {
		"af_device_mem_info", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			size_t alloc_bytes, alloc_buffers, lock_bytes, lock_buffers;

			af_err err = af_device_mem_info(&alloc_bytes, &alloc_buffers, &lock_bytes, &lock_buffers);

			lua_pushinteger(L, err);// err
			lua_pushinteger(L, alloc_bytes);// err, alloc_bytes
			lua_pushinteger(L, alloc_buffers);	// err, alloc_bytes, alloc_buffers
			lua_pushinteger(L, lock_bytes);	// err, alloc_bytes, alloc_buffers, lock_bytes
			lua_pushinteger(L, lock_buffers);	// err, alloc_bytes, alloc_buffers, lock_bytes, lock_buffers

			return 5;
		}
	}, {
		"af_free_device", Free<&af_free_device>
	}, {
		"af_free_pinned", Free<&af_free_pinned>
	}, {
		"af_get_device", GetInt<int, &af_get_device>
	}, {
		"af_get_device_count", GetInt<int, &af_get_device_count>
	}, {
		"af_get_device_ptr", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			void * ptr = nullptr;

			af_err err = af_get_device_ptr(&ptr, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushlightuserdata(L, ptr);	// arr, err, ptr

			return 2;
		}
	}, {
		"af_get_dbl_support", [](lua_State * L)
		{
			lua_settop(L, 1);	// device

			bool is_available;

			af_err err = af_get_dbl_support(&is_available, I(L, 1));

			lua_pushinteger(L, err);// device, err
			lua_pushboolean(L, is_available);	// device, err, is_available

			return 2;
		}
	}, {
		"af_get_mem_step_size", GetInt<size_t, &af_get_mem_step_size>
	}, {
		"af_info", NoArgs<&af_info>
	},

#if AF_API_VERSION >= 31
	{
		"af_lock_device_ptr", In<&af_lock_device_ptr>
	},
#endif

	{
		"af_set_device", IntArg<int, &af_set_device>
	}, {
		"af_set_mem_step_size", IntArg<size_t, &af_set_mem_step_size>
	}, {
		"af_sync", IntArg<int, &af_sync>
	},

#if AF_API_VERSION >= 31
	{
		"af_unlock_device_ptr", In<&af_unlock_device_ptr>
	},
#endif

	{ NULL, NULL }
};

int Device (lua_State * L)
{
	luaL_register(L, NULL, device_methods);

	return 0;
}