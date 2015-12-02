#include "funcs.h"
#include "methods.h"

void Register (lua_State * L, lua_CFunction func)
{
	int top = lua_gettop(L);

	lua_pushcfunction(L, func);	// ..., af, func
	lua_pushvalue(L, -2);	// ..., af, func, af

	if (lua_pcall(L, 1, 0, 0)) // ...[, err]
	{
		printf("%s\n", lua_tostring(L, -1));

		lua_settop(L, top); // ...
	}
}

extern "C" __declspec(dllexport) int luaopen_arrayfire (lua_State * L)
{
	lua_createtable(L, 0, 0);	// af

	Register(L, &CreateArrayFuncs);
	// TODO: Other functions!

	Register(L, &ArrayMethods);
	// TODO: Other objects!

	return 1;
}