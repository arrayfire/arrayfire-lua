#include "../funcs.h"
#include "af/defines.h"

#define ENUM(name) { #name, (int)name }

struct Enum {
	const char * mName;
	int mValue;
};

static const Enum enums[] = {
    ENUM(AF_SUCCESS),
    ENUM(AF_ERR_NO_MEM),
	ENUM(AF_ERR_DRIVER),
	ENUM(AF_ERR_RUNTIME),
	ENUM(AF_ERR_INVALID_ARRAY),
	ENUM(AF_ERR_ARG),
	ENUM(AF_ERR_SIZE),
	ENUM(AF_ERR_TYPE),
	ENUM(AF_ERR_DIFF_TYPE),
	ENUM(AF_ERR_BATCH),
	ENUM(AF_ERR_NOT_SUPPORTED),
	ENUM(AF_ERR_NOT_CONFIGURED),
#if AF_API_VERSION >= 32
    ENUM(AF_ERR_NONFREE),
#endif
    ENUM(AF_ERR_NO_DBL),
	ENUM(AF_ERR_NO_GFX),
#if AF_API_VERSION >= 32
    ENUM(AF_ERR_LOAD_LIB),
    ENUM(AF_ERR_LOAD_SYM),
    ENUM(AF_ERR_ARR_BKND_MISMATCH),
#endif
    ENUM(AF_ERR_INTERNAL),
    ENUM(AF_ERR_UNKNOWN),
    ENUM(f32),
    ENUM(c32),
    ENUM(f64),
    ENUM(c64),
    ENUM(b8),
    ENUM(s32),
    ENUM(u32),
    ENUM(u8),
    ENUM(s64),
    ENUM(u64),
#if AF_API_VERSION >= 32
    ENUM(s16),
	ENUM(u16),
#endif
    ENUM(afDevice),
    ENUM(afHost),
    ENUM(AF_INTERP_NEAREST),
    ENUM(AF_INTERP_LINEAR),
    ENUM(AF_INTERP_BILINEAR),
    ENUM(AF_INTERP_CUBIC),
    ENUM(AF_INTERP_LOWER),
	ENUM(AF_PAD_ZERO),
	ENUM(AF_PAD_SYM),
	ENUM(AF_CONNECTIVITY_4),
	ENUM(AF_CONNECTIVITY_8),
	ENUM(AF_CONV_DEFAULT),
	ENUM(AF_CONV_EXPAND),
	ENUM(AF_CONV_AUTO),
    ENUM(AF_CONV_SPATIAL),
    ENUM(AF_CONV_FREQ),
	ENUM(AF_SAD),
    ENUM(AF_ZSAD),
    ENUM(AF_LSAD),
    ENUM(AF_SSD),
    ENUM(AF_ZSSD),
    ENUM(AF_LSSD),
    ENUM(AF_NCC),
    ENUM(AF_ZNCC),
    ENUM(AF_SHD),
#if AF_API_VERSION >= 31
	ENUM(AF_YCC_601),
    ENUM(AF_YCC_709),
    ENUM(AF_YCC_2020),
#endif
	ENUM(AF_GRAY),
    ENUM(AF_RGB),
    ENUM(AF_HSV),
#if AF_API_VERSION >= 31
    ENUM(AF_YCbCr),
#endif
	ENUM(AF_MAT_NONE),
    ENUM(AF_MAT_TRANS),
    ENUM(AF_MAT_CTRANS),
    ENUM(AF_MAT_CONJ),
    ENUM(AF_MAT_UPPER),
    ENUM(AF_MAT_LOWER),
    ENUM(AF_MAT_DIAG_UNIT),
    ENUM(AF_MAT_SYM),
    ENUM(AF_MAT_POSDEF),
    ENUM(AF_MAT_ORTHOG),
    ENUM(AF_MAT_TRI_DIAG),
    ENUM(AF_MAT_BLOCK_DIAG),
	ENUM(AF_NORM_VECTOR_1),
    ENUM(AF_NORM_VECTOR_INF),
    ENUM(AF_NORM_VECTOR_2),
    ENUM(AF_NORM_VECTOR_P),
    ENUM(AF_NORM_MATRIX_1),
    ENUM(AF_NORM_MATRIX_INF),
    ENUM(AF_NORM_MATRIX_2),
    ENUM(AF_NORM_MATRIX_L_PQ),
    ENUM(AF_NORM_EUCLID),
	ENUM(AF_COLORMAP_DEFAULT),
    ENUM(AF_COLORMAP_SPECTRUM),
    ENUM(AF_COLORMAP_COLORS),
    ENUM(AF_COLORMAP_RED),
    ENUM(AF_COLORMAP_MOOD),
    ENUM(AF_COLORMAP_HEAT),
    ENUM(AF_COLORMAP_BLUE),
#if AF_API_VERSION >= 31
	ENUM(AF_FIF_BMP),
    ENUM(AF_FIF_ICO),
    ENUM(AF_FIF_JPEG),
    ENUM(AF_FIF_JNG),
    ENUM(AF_FIF_PNG),
    ENUM(AF_FIF_PPM),
    ENUM(AF_FIF_PPMRAW),
    ENUM(AF_FIF_TIFF),
    ENUM(AF_FIF_PSD),
    ENUM(AF_FIF_HDR),
    ENUM(AF_FIF_EXR),
    ENUM(AF_FIF_JP2),
    ENUM(AF_FIF_RAW),
#endif
#if AF_API_VERSION >= 32
	ENUM(AF_HOMOGRAPHY_RANSAC),
    ENUM(AF_HOMOGRAPHY_LMEDS),
    ENUM(AF_BACKEND_DEFAULT),
    ENUM(AF_BACKEND_CPU),
    ENUM(AF_BACKEND_CUDA),
    ENUM(AF_BACKEND_OPENCL),
#endif
};

#undef ENUM

int AddEnums (lua_State * L)
{
	for (int i = 0; i < sizeof(enums) / sizeof(Enum); ++i)
	{
		lua_pushinteger(L, enums[i].mValue);// af, enum
		lua_setfield(L, -2, enums[i].mName);// af = { name = enum }
	}

	return 0;
}