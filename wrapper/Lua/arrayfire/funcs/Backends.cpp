#include "../funcs.h"
#include "../utils.h"
#include "../template/args.h"

static const struct luaL_Reg backend_funcs[] = {
#if AF_API_VERSION >= 32
	{
		"af_get_available_backends", [](lua_State * L)
		{
			lua_settop(L, 0);	// (clear)

			int backends = 0;

			af_err err = af_get_available_backends(&backends);

			lua_pushinteger(L, err);// err
			lua_pushinteger(L, backends);	// err, backends

			return 2;
		}
	}, {
		"af_get_backend_count", [](lua_State * L)
		{
			lua_settop(L, 0);	// (clear)

			unsigned num = 1;

			af_err err = af_get_backend_count(&num);

			lua_pushinteger(L, err);// err
			lua_pushinteger(L, num);// err, num

			return 2;
		}
	}, {
		"af_get_backend_id", [](lua_State * L)
		{
			lua_settop(L, 1);	// arr

			af_backend backend = (af_backend)0;

			af_err err = af_get_backend_id(&backend, GetArray(L, 1));

			lua_pushinteger(L, err);// arr, err
			lua_pushinteger(L, backend);// arr, err, backend

			return 2;
		}
	}, {
		"af_set_backend", [](lua_State * L)
		{
			lua_settop(L, 1);	// bknd

			af_err err = af_set_backend(Arg<af_backend>(L, 1));

			lua_pushinteger(L, err);// bknd, err

			return 1;
		}
	},
#endif

	{ NULL, NULL }
};

int Backends (lua_State * L)
{
	luaL_register(L, NULL, backend_funcs);

	return 0;
}