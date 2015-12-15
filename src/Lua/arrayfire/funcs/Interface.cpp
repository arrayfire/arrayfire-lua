#include <arrayfire.h>

#ifdef WANT_CUDA
	#include <../cuda.h>
#endif

#ifdef WANT_OPENCL
	#include <../opencl.h>
#endif

// ^^^ TODO: probably not right!

#include "../funcs.h"

static const struct luaL_Reg interface_funcs[] = {
#if AF_API_VERSION >= 32
#if WANT_OPENCL
	{
		// af_err afcl_get_context (cl_context * ctx, const bool retain);
	}, {
		// af_err afcl_get_device_id (cl_device_id * id);
	},
#endif

#if WANT_CUDA
	{
		// af_err afcu_get_native_id (int * nativeid, int id);
	},
#endif

#if WANT_OPENCL
	{
		// af_err afcl_get_queue (cl_command_queue * queue, const bool retain);
	},
#endif

#if WANT_CUDA
	{
		// af_err afcu_get_stream (cudaStream_t * stream, int id);
	},
#endif
#endif

	{ NULL, NULL }
};

int Interface (lua_State * L)
{
	luaL_register(L, NULL, interface_funcs);

	return 0;
}