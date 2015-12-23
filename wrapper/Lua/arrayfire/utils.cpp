#include "utils.h"
#include "lua_compat.h"

af_dtype GetDataType (lua_State * L, int index)
{
	af_dtype types[] = {
		f32, c32, f64, c64, b8, s32, u32, u8, s64, u64,
#if AF_API_VERSION >= 32
		s16, u16
#endif
	};

	const char * names[] = {
		"f32", "c32", "f64", "c64", "b8", "s32", "u32", "u8", "s64", "u64",
#if AF_API_VERSION >= 32
		"s16", "u16"
#endif
	};

	return types[luaL_checkoption(L, index, "f32", names)];
}

#define RESULT_CODE(what) case what: \
	lua_pushliteral(L, #what);		 \
	break;

void PushResult (lua_State * L, af_err err)
{
	switch (err)
	{
	RESULT_CODE(AF_SUCCESS)
	RESULT_CODE(AF_ERR_NO_MEM)
	RESULT_CODE(AF_ERR_DRIVER)
	RESULT_CODE(AF_ERR_RUNTIME)
	RESULT_CODE(AF_ERR_INVALID_ARRAY)
	RESULT_CODE(AF_ERR_ARG)
	RESULT_CODE(AF_ERR_SIZE)
	RESULT_CODE(AF_ERR_TYPE)
	RESULT_CODE(AF_ERR_DIFF_TYPE)
	RESULT_CODE(AF_ERR_BATCH)
	RESULT_CODE(AF_ERR_NOT_SUPPORTED)
	RESULT_CODE(AF_ERR_NOT_CONFIGURED)
#if AF_API_VERSION >= 32
	RESULT_CODE(AF_ERR_NONFREE)
#endif
	RESULT_CODE(AF_ERR_NO_DBL)
	RESULT_CODE(AF_ERR_NO_GFX)
#if AF_API_VERSION >= 32
    RESULT_CODE(AF_ERR_LOAD_LIB)
	RESULT_CODE(AF_ERR_LOAD_SYM)
    RESULT_CODE(AF_ERR_ARR_BKND_MISMATCH)
#endif
	RESULT_CODE(AF_ERR_INTERNAL)
	RESULT_CODE(AF_ERR_UNKNOWN)
	}
}

#undef RESULT_CODE

int PushErr(lua_State * L, af_err err, int nret)
{
	lua_pushinteger(L, err);// ..., ret1, [ret2, ...], err
	lua_insert(L, -(nret + 1));	// ..., err, ret1[, ret2, ...]

	return nret + 1;
}

void * GetMemory (lua_State * L, int index)
{
	if (lua_type(L, index) == LUA_TSTRING) return (void *)lua_tostring(L, index);

	else return lua_touserdata(L, index);
}

af_array GetArray (lua_State * L, int index)
{
	af_array * ptr_to = (af_array *)lua_touserdata(L, index);

#ifndef NDEBUG
	// Assert? (error to access after Clear...)
#endif

	return *ptr_to;
}

af_features GetFeatures (lua_State * L, int index)
{
	af_features * ptr_to = (af_features *)lua_touserdata(L, index);

#ifndef NDEBUG
	// Assert? (ditto)
#endif

	return *ptr_to;
}

af_index_t * GetIndexer (lua_State * L, int index)
{
	af_index_t ** ptr_to = (af_index_t **)lua_touserdata(L, index);

#ifndef NDEBUG
	// Assert? (error to access after Clear...)
#endif

	return *ptr_to;
}

static void AddMetatable (lua_State * L, const char * name, lua_CFunction func)
{
	if (luaL_newmetatable(L, name))	// ..., object, mt
	{
		lua_pushcfunction(L, func);	// ..., object, mt, func
		lua_setfield(L, -2, "__gc");// ..., object, mt = { __gc = func }
	}

	lua_setmetatable(L, -2);// ..., object
}

af_array * NewArray (lua_State * L)
{
	void * ptr = lua_newuserdata(L, sizeof(af_array)); // ..., array

	AddMetatable(L, "af_array", [](lua_State * L)
	{
		lua_settop(L, 1);	// array

		af_array ptr = GetArray(L, 1);

		if (ptr) af_release_array(ptr);

		ClearArray(L, 1);

		return 0;
	});

	*(af_array*)ptr = nullptr;

	return (af_array *)ptr;
}

af_features * NewFeatures (lua_State * L)
{
	void * ptr = lua_newuserdata(L, sizeof(af_features));	// ..., features

	AddMetatable(L, "af_features", [](lua_State * L)
	{
		lua_settop(L, 1);	// features

		af_features ptr = GetFeatures(L, 1);

		if (ptr) af_release_features(ptr);

		ClearFeatures(L, 1);

		return 0;
	});

	*(af_features*)ptr = nullptr;

	return (af_features *)ptr;
}

af_index_t ** NewIndexer (lua_State * L)
{
	void * ptr = lua_newuserdata(L, sizeof(af_index_t *));	// ..., indexer

	AddMetatable(L, "af_index_t", [](lua_State * L)
	{
		lua_settop(L, 1);	// indexer

		af_index_t * ptr = GetIndexer(L, 1);

		if (ptr) af_release_indexers(ptr);

		ClearIndexer(L, 1);

		return 0;
	});

	*(af_index_t **)ptr = nullptr;

	return (af_index_t **)ptr;
}

void ClearArray (lua_State * L, int index)
{
	*(af_array *)lua_touserdata(L, index) = nullptr;
}

void ClearFeatures (lua_State * L, int index)
{
	*(af_features *)lua_touserdata(L, index) = nullptr;
}

void ClearIndexer (lua_State * L, int index)
{
	*(af_index_t **)lua_touserdata(L, index) = nullptr;
}

LuaDims::LuaDims (lua_State * L, int first)
{
	luaL_checktype(L, first + 1, LUA_TTABLE);

	int n = (int)luaL_checkinteger(L, first);

	for (int i = 0; i < n; ++i)
	{
		lua_rawgeti(L, first + 1, i + 1);	// ..., n, t, [type,] ..., dim

		mDims.push_back(lua_tointeger(L, -1));

		lua_pop(L, 1);	// ..., n, t, [type,] ...
	}
}

template<typename T> void AddToVector (std::vector<char> & arr, T value)
{
	const char * bytes = (const char *)&value;

	for (size_t i = 0; i < sizeof(T); ++i) arr.push_back(*bytes++);
}

template<typename T> void AddFloat (std::vector<char> & arr, lua_State * L, int index, int pos)
{
	lua_rawgeti(L, index, pos + 1);	// ..., arr, ..., float

	AddToVector(arr, Arg<T>(L, -1));

	lua_pop(L, 1); // ..., arr, ...
}

template<typename T> void AddInt (std::vector<char> & arr, lua_State * L, int index, int pos)
{
	lua_rawgeti(L, index, pos + 1);	// ..., arr, ..., int

	AddToVector(arr, Arg<T>(L, -1));

	lua_pop(L, 1); // ..., arr, ...
}

template<typename T, typename C> void AddComplex (std::vector<char> & arr, lua_State * L, int index, int pos)
{
	lua_rawgeti(L, index, pos + 1);	// ..., arr, ... complex
	lua_rawgeti(L, -1, 1);	// ..., arr, ..., complex, real
	lua_rawgeti(L, -2, 2);	// ..., arr, ..., complex, real, imag

	C comp(Arg<T>(L, -2), Arg<T>(L, -1));

	AddToVector(arr, comp);

	lua_pop(L, 3);	// ..., arr, ...
}

LuaData::LuaData (lua_State * L, int index, int type_index, bool copy) : mDataPtr(0)
{
	mType = Arg<af_dtype>(L, type_index);

	// Non-string: build up from Lua array.
	if (!lua_isstring(L, index))
	{
		int count = lua_objlen(L, index);

		switch (mType)
		{
		case b8:
		case u8:
			mData.reserve(count);
			break;
#if AF_API_VERSION >= 32
		case s16:
		case u16:
			mData.reserve(count * 2);
			break;
#endif
		case f32:
		case s32:
		case u32:
			mData.reserve(count * 4);
			break;
		case c32:
		case f64:
		case s64:
		case u64:
			mData.reserve(count * 8);
			break;
		case c64:
			mData.reserve(count * 16);
			break;
		}

		for (int i = 0; i < count; ++i)
		{
			switch (mType)
			{
			case f32:
				AddFloat<float>(mData, L, index, i);
				break;
			case c32:
				AddComplex<float, af::af_cfloat>(mData, L, index, i);
				break;
			case f64:
				AddFloat<double>(mData, L, index, i);
				break;
			case c64:
				AddComplex<double, af::af_cdouble>(mData, L, index, i);
				break;
			case b8:
				AddInt<char>(mData, L, index, i);
				break;
#if AF_API_VERSION >= 32
			case s16:
				AddInt<short>(mData, L, index, i);
				break;
			case u16:
				AddInt<unsigned short>(mData, L, index, i);
				break;
#endif
			case s32:
				AddInt<int>(mData, L, index, i);
				break;
			case u32:
				AddInt<unsigned int>(mData, L, index, i);
				break;
			case u8:
				AddInt<unsigned char>(mData, L, index, i);
				break;
			case s64:
				AddInt<intl>(mData, L, index, i);
				break;
			case u64:
				AddInt<uintl>(mData, L, index, i);
				break;
			}
		}
	}

	// Already a Lua string: make a copy or simply point to it.
	else
	{
		const char * str = lua_tostring(L, index);

		if (copy) mData.assign(str, str + lua_objlen(L, index));

		else mDataPtr = str;
	}

	if (!mDataPtr) mDataPtr = &mData.front();
}
