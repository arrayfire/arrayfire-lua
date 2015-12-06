#ifndef ARGS_TEMPLATE_H
#define ARGS_TEMPLATE_H

template<typename T> T Arg (lua_State * L, int index)
{
	return (T)lua_tointeger(L, index);
}

template<typename T> void Push (lua_State * L, T value)
{
	lua_pushinteger(L, value);	// ..., value
}

bool B (lua_State * L, int index);
double D (lua_State * L, int index);
float F (lua_State * L, int index);
int I (lua_State * L, int index);
unsigned U (lua_State * L, int index);
const char * S (lua_State * L, int index);
void * UD (lua_State * L, int index);	// N.B. Does not use Arg<void *>, since these are ambiguous with af_array / af_features

#endif