#ifndef UTILS_H
#define UTILS_H

#include <arrayfire.h>
#include <vector>

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

af_dtype GetDataType (lua_State * L, int index);

void PushResult (lua_State * L, af_err err);

af_array GetArray (lua_State * L, int index);

void * NewArray (lua_State * L);

class LuaDimsAndType {
	af_dtype mType;
	std::vector<dim_t> mDims;

public:
	LuaDimsAndType (lua_State * L, int first);

	int GetNDims (void) const { return mDims.size(); }
	const dim_t * GetDims (void) const { return &mDims.front(); }
	af_dtype GetType (void) const { return mType; }
};

class LuaData {
	af_dtype mType;
	std::vector<char> mData;

public:
	LuaData (lua_State * L, int index, af_dtype type);

	const char * GetData (void) const { return &mData.front(); }
	af_dtype GetType (void) const { return mType; }
};

#endif