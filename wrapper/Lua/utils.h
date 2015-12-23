#ifndef UTILS_H
#define UTILS_H

#include "template/args.h"
#include <arrayfire.h>
#include <vector>

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

af_dtype GetDataType (lua_State * L, int index);

void PushResult (lua_State * L, af_err err);

int PushErr (lua_State * L, af_err err, int nret = 1);

void * GetMemory (lua_State * L, int index);

af_array GetArray (lua_State * L, int index);
af_features GetFeatures (lua_State * L, int index);
af_index_t * GetIndexer (lua_State * L, int index);

af_array * NewArray (lua_State * L);
af_features * NewFeatures (lua_State * L);
af_index_t ** NewIndexer (lua_State * L);

void ClearArray (lua_State * L, int index);
void ClearFeatures (lua_State * L, int index);
void ClearIndexer (lua_State * L, int index);

class LuaDims {
	std::vector<dim_t> mDims;

public:
	LuaDims (lua_State * L, int first);

	int GetNDims (void) const { return mDims.size(); }
	const dim_t * GetDims (void) const { return &mDims.front(); }
};

class LuaData {
	af_dtype mType;
	std::vector<char> mData;
	const char * mDataPtr;

public:
	LuaData (lua_State * L, int index, int type_index, bool copy = false);

	const char * GetData (void) const { return mDataPtr; }
	af_dtype GetType (void) const { return mType; }
};

template<af_err (*func)(af_array *, const unsigned, const dim_t *, const af_dtype)> int DimsAndType(lua_State * L)
{
	lua_settop(L, 3);	// ndims, dims, type

	LuaDims dt(L, 1);

	af_array * arr_ud = NewArray(L);// ndims, dims, type, arr_ud

	af_err err = func(arr_ud, dt.GetNDims(), dt.GetDims(), Arg<af_dtype>(L, 3));

	return PushErr(L, err);	// ndims, dims, type, err, arr_ud
}

#define DIMS_AND_TYPE(name) { "af_"#name, DimsAndType<&af_##name> }

#endif
