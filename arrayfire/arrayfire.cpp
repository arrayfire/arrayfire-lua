#include "funcs.h"
#include "graphics.h"
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

	// Library functions
	Register(L, &CreateArrayFuncs);
	Register(L, &Backends);
	Register(L, &ComputerVision);
	Register(L, &ImageProcessing);
	Register(L, &Interface);
	Register(L, &IO);
	Register(L, &LinearAlgebra);
	Register(L, &Mathematics);
	Register(L, &SignalProcessing);
	Register(L, &Statistics);
	Register(L, &Util);
	Register(L, &Vector);

	// Array methods
	Register(L, &ArrayMethods);
	Register(L, &AssignIndex);
	Register(L, &Device);
	Register(L, &Features);
	Register(L, &Helper);
	Register(L, &MoveReorder);

	// Graphics functions
	Register(L, &Draw);
	Register(L, &Window);

	return 1;
}