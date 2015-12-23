#include "../methods.h"
#include "../template/out_in2.h"

template<typename T> void Load (lua_State * L, T & value) {}

template<> void Load (lua_State * L, af_seq & seq)
{
	lua_getfield(L, -1, "begin");	// ..., seq, begin
	lua_getfield(L, -2, "end");	// ..., seq, begin, end
	lua_getfield(L, -3, "step");// ..., seq, begin, end, step

	seq = af_make_seq(D(L, -3), D(L, -2), D(L, -1));

	lua_pop(L, 3);	// ..., seq
}

template<> void Load (lua_State * L, af_index_t & index)
{
	lua_getfield(L, -1, "isBatch");	// ..., index, isBatch
	lua_getfield(L, -2, "isSeq");	// ..., index, isBatch, isSeq
	lua_getfield(L, -3, "idx");	// ..., index, isBatch, isSeq, idx

	index.isBatch = B(L, -3);
	index.isSeq = B(L, -2);

	if (index.isSeq) Load(L, index.idx.seq);

	else index.idx.arr = GetArray(L, -1);

	lua_pop(L, 3);	// ..., index
}

template<typename T> void LoadVector (lua_State * L, int index, std::vector<T> & v, unsigned count)
{
	for (unsigned i = 1; i <= count; ++i)
	{
		lua_rawgeti(L, index, i);	// ..., value

		T item;

		Load(L, item);

		v.push_back(item);

		lua_pop(L, 1);	// ...
	}
}

template<typename T, typename E, af_err (*func)(af_array *, const af_array, const T, const E *, const af_array)> int Assign (lua_State * L)
{
	lua_settop(L, 4);	// lhs, ndims, elems, rhs

	af_array * arr_ud = NewArray(L);// lhs, ndims, elems, rhs, arr_ud

	T count = Arg<T>(L, 2);

	std::vector<E> elems(count);

	LoadVector(L, 3, elems, count);

	af_err err = func(arr_ud, GetArray(L, 1), count, &elems.front(), GetArray(L, 4));

	return PushErr(L, err);	// lhs, ndims, elems, rhs, err, arr_ud
}

template<typename T, typename E, af_err (*func)(af_array *, const af_array, const T, const E *)> int Index (lua_State * L)
{
	lua_settop(L, 3);	// arr, ndims, index

	af_array * arr_ud = NewArray(L);// arr, ndims, index, arr_ud

	T count = Arg<T>(L, 2);

	std::vector<E> elems(count);

	LoadVector(L, 3, elems, count);

	af_err err = func(arr_ud, GetArray(L, 1), count, &elems.front());

	return PushErr(L, err);	// arr, ndims, index, err, arr_ud
}

#define ASSIGN(name, t, e) { "af_"#name, Assign<t, e, &af_##name> }
#define INDEX(name, t, e) { "af_"#name, Index<t, e, &af_##name> }

static const struct luaL_Reg assign_index_methods[] = {
	ASSIGN(assign_gen, dim_t, af_index_t),
	ASSIGN(assign_seq, unsigned, af_seq),
#if AF_API_VERSION >= 32
	{
		"af_create_indexers", [](lua_State * L)
		{
			lua_settop(L, 0);	// (empty)

			af_index_t ** indexer_ud = NewIndexer(L);	// indexer_ud

			af_err err = af_create_indexers(indexer_ud);

			return PushErr(L, err);	// err, indexer_ud
		}
	},
#endif
	INDEX(index, unsigned, af_seq),
	INDEX(index_gen, dim_t, af_index_t),
	OUTIN2_ARG(lookup, unsigned),
#if AF_API_VERSION >= 32
	{
		"af_release_indexers", [](lua_State * L)
		{
			lua_settop(L, 1);	// indexer

			af_err err = af_release_indexers(GetIndexer(L, 1));

			ClearIndexer(L, 1);

			lua_pushinteger(L, err);// indexer, err

			return 1;
		}
	}, {
		"af_set_array_indexer", [](lua_State * L)
		{
			lua_settop(L, 3);	// indexer, idx, dim

			af_err err = af_set_array_indexer(GetIndexer(L, 1), GetArray(L, 2), Arg<dim_t>(L, 3));

			lua_pushinteger(L, err);// indexer, idx, dim, err

			return 1;
		}
	}, {
		"af_set_seq_indexer", [](lua_State * L)
		{
			lua_settop(L, 4);	// indexer, idx, dim, is_batch
			lua_pushvalue(L, 2);// indexer, idx, dim, is_batch, idx

			af_seq seq;

			Load(L, seq);

			af_err err = af_set_seq_indexer(GetIndexer(L, 1), &seq, Arg<dim_t>(L, 3), B(L, 4));

			lua_pushinteger(L, err);// indexer, idx, dim, is_batch, idx, err

			return 1;
		}
	}, {
		"af_set_seq_param_indexer", [](lua_State * L)
		{
			lua_settop(L, 6);	// indexer, begin, end, step, dim, is_batch

			af_err err = af_set_seq_param_indexer(GetIndexer(L, 1), D(L, 2), D(L, 3), D(L, 4), Arg<dim_t>(L, 5), B(L, 6));

			lua_pushinteger(L, err);// indexer, begin, end, step, dim, is_batch, err

			return 1;
		}
	},
#endif

	{ NULL, NULL }
};

#undef ASSIGN
#undef INDEX

int AssignIndex (lua_State * L)
{
	luaL_register(L, NULL, assign_index_methods);

	return 0;
}