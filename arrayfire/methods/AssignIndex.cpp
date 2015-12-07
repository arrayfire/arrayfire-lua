#include "../methods.h"
#include "../out_in2_template.h"

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
// 	AFAPI af_err af_create_indexers(af_index_t** indexers);
#endif
	INDEX(index, unsigned, af_seq),
	INDEX(index_gen, dim_t, af_index_t),
	OUTIN2_ARG(lookup, unsigned),
#if AF_API_VERSION >= 32
//	AFAPI af_err af_release_indexers(af_index_t* indexers);
//	AFAPI af_err af_set_array_indexer(af_index_t* indexer, const af_array idx, const dim_t dim);
//	AFAPI af_err af_set_seq_indexer(af_index_t* indexer, const af_seq* idx, const dim_t dim, const bool is_batch);
//	AFAPI af_err af_set_seq_param_indexer(af_index_t* indexer, const double begin, const double end, const double step, const dim_t dim, const bool is_batch);
#endif

#if 0
	AFAPI af_seq af_make_seq(double begin, double end, double step);
#endif
	// TODO^^^^
	{ NULL, NULL }
};

#undef ASSIGN
#undef INDEX

int AssignIndex (lua_State * L)
{
	luaL_register(L, NULL, assign_index_methods);

	return 0;
}