#include "funcs.h"
#include "methods.h"

void Register (lua_State * L, lua_CFunction func)
{
	int top = lua_gettop(L);

	lua_pushcfunction(L, func);	// ..., func

	if (lua_pcall(L, 0, LUA_MULTRET, 0)) // ...[, err]
	{
		printf("%s\n", lua_tostring(L, -1));

		lua_settop(L, top); // ...
	}
}

extern "C" __declspec(dllexport) int luaopen_arrayfire (lua_State * L)
{
	Register(L, &CreateArrayFuncs);
	// TODO: Other functions!

	Register(L, &ArrayMethods);
	// TODO: Other objects!

	lua_getglobal(L, "af");	// af
	lua_pushnil(L);	// af, nil
	lua_setglobal(L, "af");	// af

	return 1;
}