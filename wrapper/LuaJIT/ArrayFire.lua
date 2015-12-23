-- Adapted from https://github.com/malkia/ufo/blob/master/ffi/OpenCL.lua

local ffi  = require( "ffi" )

local name, path = "af", os.getenv("AF_PATH") .. "/"
local is_32_bit = ffi.abi("32bit") -- used to typedef dim_t

if ArrayFireMode == "cl" or ArrayFireMode == "cuda" or ArrayFireMode == "cpu" then
	name = name .. ArrayFireMode
end

local libs = ffi_ArrayFireLibs or {
   -- OSX     = { x86 = path .. name, x64 = path .. name },
   Windows = { x86 = path .. name, x64 = path .. name },
   -- Linux   = { x86 = path .. "lib" .. name, x64 = path .. "lib" .. name, arm = "bin/Linux/arm/lib" .. name }
}

local lib = ffi_ArrayFire_lib or libs[ ffi.os ][ ffi.arch ]
local af  = ffi.load( lib )

ffi.cdef[[ af_err af_get_version (int *, int *, int *); ]]

local major, minor, patch = ffi.new("int[1]"), ffi.new("int[1]"), ffi.new("int[1]")

af.af_get_version(major, minor, patch)

local Version, Patch = major[0] * 10 + minor[0], patch[0]
local UsesCUDA = name == "af" or name == "afcuda"
local UsesOpenCL = name == "af" or name == "afcl"

local def = ([[
	typedef enum {
		///
		/// The function returned successfully
		///
		AF_SUCCESS            =   0,

		// 100-199 Errors in environment

		///
		/// The system or device ran out of memory
		///
		AF_ERR_NO_MEM         = 101,

		///
		/// There was an error in the device driver
		///
		AF_ERR_DRIVER         = 102,

		///
		/// There was an error with the runtime environment
		///
		AF_ERR_RUNTIME        = 103,

		// 200-299 Errors in input parameters

		///
		/// The input array is not a valid af_array object
		///
		AF_ERR_INVALID_ARRAY  = 201,

		///
		/// One of the function arguments is incorrect
		///
		AF_ERR_ARG            = 202,

		///
		/// The size is incorrect
		///
		AF_ERR_SIZE           = 203,

		///
		/// The type is not suppported by this function
		///
		AF_ERR_TYPE           = 204,

		///
		/// The type of the input arrays are not compatible
		///
		AF_ERR_DIFF_TYPE      = 205,

		///
		/// Function does not support GFOR / batch mode
		///
		AF_ERR_BATCH          = 207,


		// 300-399 Errors for missing software features

		///
		/// The option is not supported
		///
		AF_ERR_NOT_SUPPORTED  = 301,

		///
		/// This build of ArrayFire does not support this feature
		///
		AF_ERR_NOT_CONFIGURED = 302,

$MIN_VERSION(32)$
		///
		/// This build of ArrayFire is not compiled with "nonfree" algorithms
		///
		AF_ERR_NONFREE       = 303,
$END_MIN$

		// 400-499 Errors for missing hardware features

		///
		/// This device does not support double
		///
		AF_ERR_NO_DBL         = 401,

		///
		/// This build of ArrayFire was not built with graphics or this device does
		/// not support graphics
		///
		AF_ERR_NO_GFX         = 402,

		// 500-599 Errors specific to heterogenous API

$MIN_VERSION(32)$
		///
		/// There was an error when loading the libraries
		///
		AF_ERR_LOAD_LIB       = 501,

		///
		/// There was an error when loading the symbols
		///
		AF_ERR_LOAD_SYM       = 502,

		///
		/// There was a mismatch between the input array and the active backend
		///
		AF_ERR_ARR_BKND_MISMATCH    = 503,
$END_MIN$
		
		// 900-999 Errors from upstream libraries and runtimes

		///
		/// There was an internal error either in ArrayFire or in a project
		/// upstream
		///
		AF_ERR_INTERNAL       = 998,

		///
		/// Unknown Error
		///
		AF_ERR_UNKNOWN        = 999
	} af_err;

	typedef enum {
		f32,    ///< 32-bit floating point values
		c32,    ///< 32-bit complex floating point values
		f64,    ///< 64-bit complex floating point values
		c64,    ///< 64-bit complex floating point values
		b8,     ///< 8-bit boolean values
		s32,    ///< 32-bit signed integral values
		u32,    ///< 32-bit unsigned integral values
		u8,     ///< 8-bit unsigned integral values
		s64,    ///< 64-bit signed integral values
		u64,    ///< 64-bit unsigned integral values
$MIN_VERSION(32)$
		s16,    ///< 16-bit signed integral values
		u16,    ///< 16-bit unsigned integral values
$END_MIN$
	} af_dtype;

	typedef enum {
		afDevice,   ///< Device pointer
		afHost,     ///< Host pointer
	} af_source;

	// A handle for an internal array object
	typedef void * af_array;

	typedef enum {
		AF_INTERP_NEAREST,  ///< Nearest Interpolation
		AF_INTERP_LINEAR,   ///< Linear Interpolation
		AF_INTERP_BILINEAR, ///< Bilinear Interpolation
		AF_INTERP_CUBIC,    ///< Cubic Interpolation
		AF_INTERP_LOWER     ///< Floor Indexed
	} af_interp_type;

	typedef enum {
		///
		/// Out of bound values are 0
		///
		AF_PAD_ZERO = 0,

		///
		/// Out of bound values are symmetric over the edge
		///
		AF_PAD_SYM
	} af_border_type;

	typedef enum {
		///
		/// Connectivity includes neighbors, North, East, South and West of current pixel
		///
		AF_CONNECTIVITY_4 = 4,

		///
		/// Connectivity includes 4-connectivity neigbors and also those on Northeast, Northwest, Southeast and Southwest
		///
		AF_CONNECTIVITY_8 = 8
	} af_connectivity;

	typedef enum {

		///
		/// Output of the convolution is the same size as input
		///
		AF_CONV_DEFAULT,

		///
		/// Output of the convolution is signal_len + filter_len - 1
		///
		AF_CONV_EXPAND,
	} af_conv_mode;

	typedef enum {
		AF_CONV_AUTO,    ///< ArrayFire automatically picks the right convolution algorithm
		AF_CONV_SPATIAL, ///< Perform convolution in spatial domain
		AF_CONV_FREQ,    ///< Perform convolution in frequency domain
	} af_conv_domain;

	typedef enum {
		AF_SAD = 0,   ///< Match based on Sum of Absolute Differences (SAD)
		AF_ZSAD,      ///< Match based on Zero mean SAD
		AF_LSAD,      ///< Match based on Locally scaled SAD
		AF_SSD,       ///< Match based on Sum of Squared Differences (SSD)
		AF_ZSSD,      ///< Match based on Zero mean SSD
		AF_LSSD,      ///< Match based on Locally scaled SSD
		AF_NCC,       ///< Match based on Normalized Cross Correlation (NCC)
		AF_ZNCC,      ///< Match based on Zero mean NCC
		AF_SHD        ///< Match based on Sum of Hamming Distances (SHD)
	} af_match_type;

$MIN_VERSION(31)$
	typedef enum {
		AF_YCC_601 = 601,  ///< ITU-R BT.601 (formerly CCIR 601) standard
		AF_YCC_709 = 709,  ///< ITU-R BT.709 standard
		AF_YCC_2020 = 2020  ///< ITU-R BT.2020 standard
	} af_ycc_std;
$END_MIN$

	typedef enum {
		AF_GRAY = 0, ///< Grayscale
		AF_RGB,      ///< 3-channel RGB
		AF_HSV,      ///< 3-channel HSV
$MIN_VERSION(31)$
		AF_YCbCr     ///< 3-channel YCbCr
$END_MIN$
	} af_cspace_t;

	typedef enum {
		AF_MAT_NONE       = 0,    ///< Default
		AF_MAT_TRANS      = 1,    ///< Data needs to be transposed
		AF_MAT_CTRANS     = 2,    ///< Data needs to be conjugate tansposed
		AF_MAT_CONJ       = 4,    ///< Data needs to be conjugate
		AF_MAT_UPPER      = 32,   ///< Matrix is upper triangular
		AF_MAT_LOWER      = 64,   ///< Matrix is lower triangular
		AF_MAT_DIAG_UNIT  = 128,  ///< Matrix diagonal contains unitary values
		AF_MAT_SYM        = 512,  ///< Matrix is symmetric
		AF_MAT_POSDEF     = 1024, ///< Matrix is positive definite
		AF_MAT_ORTHOG     = 2048, ///< Matrix is orthogonal
		AF_MAT_TRI_DIAG   = 4096, ///< Matrix is tri diagonal
		AF_MAT_BLOCK_DIAG = 8192  ///< Matrix is block diagonal
	} af_mat_prop;

	typedef enum {
		AF_NORM_VECTOR_1,      ///< treats the input as a vector and returns the sum of absolute values
		AF_NORM_VECTOR_INF,    ///< treats the input as a vector and returns the max of absolute values
		AF_NORM_VECTOR_2,      ///< treats the input as a vector and returns euclidean norm
		AF_NORM_VECTOR_P,      ///< treats the input as a vector and returns the p-norm
		AF_NORM_MATRIX_1,      ///< return the max of column sums
		AF_NORM_MATRIX_INF,    ///< return the max of row sums
		AF_NORM_MATRIX_2,      ///< returns the max singular value). Currently NOT SUPPORTED
		AF_NORM_MATRIX_L_PQ,   ///< returns Lpq-norm

		AF_NORM_EUCLID = AF_NORM_VECTOR_2, ///< The default. Same as AF_NORM_VECTOR_2
	} af_norm_type;

	typedef enum {
		AF_COLORMAP_DEFAULT = 0,    ///< Default grayscale map
		AF_COLORMAP_SPECTRUM= 1,    ///< Spectrum map
		AF_COLORMAP_COLORS  = 2,    ///< Colors
		AF_COLORMAP_RED     = 3,    ///< Red hue map
		AF_COLORMAP_MOOD    = 4,    ///< Mood map
		AF_COLORMAP_HEAT    = 5,    ///< Heat map
		AF_COLORMAP_BLUE    = 6     ///< Blue hue map
	} af_colormap;

$MIN_VERSION(31)$
	typedef enum {
		AF_FIF_BMP          = 0,    ///< FreeImage Enum for Bitmap File
		AF_FIF_ICO          = 1,    ///< FreeImage Enum for Windows Icon File
		AF_FIF_JPEG         = 2,    ///< FreeImage Enum for JPEG File
		AF_FIF_JNG          = 3,    ///< FreeImage Enum for JPEG Network Graphics File
		AF_FIF_PNG          = 13,   ///< FreeImage Enum for Portable Network Graphics File
		AF_FIF_PPM          = 14,   ///< FreeImage Enum for Portable Pixelmap (ASCII) File
		AF_FIF_PPMRAW       = 15,   ///< FreeImage Enum for Portable Pixelmap (Binary) File
		AF_FIF_TIFF         = 18,   ///< FreeImage Enum for Tagged Image File Format File
		AF_FIF_PSD          = 20,   ///< FreeImage Enum for Adobe Photoshop File
		AF_FIF_HDR          = 26,   ///< FreeImage Enum for High Dynamic Range File
		AF_FIF_EXR          = 29,   ///< FreeImage Enum for ILM OpenEXR File
		AF_FIF_JP2          = 31,   ///< FreeImage Enum for JPEG-2000 File
		AF_FIF_RAW          = 34    ///< FreeImage Enum for RAW Camera Image File
	} af_image_format;
$END_MIN$

$MIN_VERSION(32)$
	typedef enum {
		AF_HOMOGRAPHY_RANSAC = 0,   ///< Computes homography using RANSAC
		AF_HOMOGRAPHY_LMEDS  = 1    ///< Computes homography using Least Median of Squares
	} af_homography_type;

	// These enums should be 2^x
	typedef enum {
		AF_BACKEND_DEFAULT = 0,  ///< Default backend order: OpenCL -> CUDA -> CPU
		AF_BACKEND_CPU     = 1,  ///< CPU a.k.a sequential algorithms
		AF_BACKEND_CUDA    = 2,  ///< CUDA Compute Backend
		AF_BACKEND_OPENCL  = 4,  ///< OpenCL Compute Backend
	} af_backend;
$END_MIN$

	// Below enum is purely added for example purposes
	// it doesn't and shoudn't be used anywhere in the
	// code. No Guarantee's provided if it is used.
	typedef enum {
		AF_ID = 0
	} af_someenum_t;

	typedef ]] .. (is_32_bit and "int" or "long long") .. [[ dim_t;
	
	typedef long long intl;
	typedef unsigned long long uintl;

	typedef void * af_features;

	typedef struct af_cfloat {
		float real;
		float imag;
	} af_cfloat;

	typedef struct af_cdouble {
		double real;
		double imag;
	} af_cdouble;
	
	typedef struct af_seq {
		double begin, end;
		double step;
	} af_seq;

	typedef struct af_index_t{
		union {
			af_array arr;   ///< The af_array used for indexing
			af_seq   seq;   ///< The af_seq used for indexing
		} idx;

		bool     isSeq;     ///< If true the idx value represents a seq
		bool     isBatch;   ///< If true the seq object is a batch parameter
	} af_index_t;

	typedef struct {
		int row;
		int col;
		const char* title;
		af_colormap cmap;
	} af_cell;

	typedef unsigned long long af_window;

$USES_CUDA$
	typedef struct CUstream_st* cudaStream_t;
$END_USES_CUDA$

$USES_OPENCL$
	typedef struct _cl_device_id *      cl_device_id;
	typedef struct _cl_context *        cl_context;
	typedef struct _cl_command_queue *  cl_command_queue;
$END_USES_OPENCL$
	
	/* Constructors */
	af_err af_create_array (af_array *, const void * const, const unsigned, const dim_t * const, const af_dtype);
	af_err af_create_handle (af_array *, const unsigned, const dim_t * const, const af_dtype);
	af_err af_device_array (af_array *, const void *, const unsigned, const dim_t * const, const af_dtype)

	/* Create Array */
	af_err af_constant (af_array *, const double val, const unsigned, const dim_t * const, const af_dtype);
	af_err af_constant_complex (af_array *, const double, const double, const unsigned, const dim_t * const, const af_dtype);
	af_err af_constant_long (af_array *, const intl, const unsigned, const dim_t * const);
	af_err af_constant_ulong (af_array *, const uintl, const unsigned, const dim_t * const);
	af_err af_diag_create (af_array *, const af_array, const int);
	af_err af_diag_extract (af_array *, const af_array, const int);
	af_err af_get_seed (uintl *);
	af_err af_identity (af_array *, const unsigned, const dim_t * const, const af_dtype);
	af_err af_iota (af_array *, const unsigned, const dim_t * const, const unsigned, const dim_t * const, const af_dtype);
	af_err af_lower (af_array *, const af_array, bool);
	af_err af_randn (af_array *, const unsigned, const dim_t * const, const af_dtype);
	af_err af_randu (af_array *, const unsigned, const dim_t * const, const af_dtype);
	af_err af_range (af_array *, const unsigned, const dim_t * const, const int, const af_dtype);
	af_err af_set_seed (const uintl);
	af_err af_upper (af_array *, const af_array, bool);

	/* Backends */
$MIN_VERSION(32)$
	af_err af_get_available_backends (int *);
	af_err af_get_backend_count (unsigned *);
	af_err af_get_backend_id (af_backend *, const af_array);
	af_err af_set_backend (const af_backend);
$END_MIN$

	/* Computer Vision */
$MIN_VERSION(31)$
	af_err af_dog (af_array *, const af_array, const int, const int);
$END_MIN$
	af_err af_fast (af_features *, const af_array, const float, const unsigned, const bool, const float, const unsigned);
$MIN_VERSION(32)$
	af_err af_gloh (af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float);
$END_MIN$
	af_err af_hamming_matcher (af_array *, af_array *, const af_array, const af_array, const dim_t, const unsigned);
$MIN_VERSION(31)$
	af_err af_harris (af_features *, const af_array, const unsigned, const float, const float, const unsigned, const float);
$END_MIN$
$MIN_VERSION(32)$
	af_err af_homography (af_array *, int *, const af_array, const af_array, const af_array, const af_array, const af_homography_type, const float, const unsigned, const af_dtype);
$END_MIN$
	af_err af_match_template (af_array *, const af_array, const af_array, const af_match_type);
	af_err af_orb (af_features *, af_array *, const af_array, const float, const unsigned, const float, const unsigned, const bool);
$MIN_VERSION(31)$
	af_err af_nearest_neighbour (af_array *, af_array *, const af_array, const af_array, const dim_t, const unsigned, const af_match_type);
	af_err af_sift (af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float);
	af_err af_susan (af_features *, const af_array, const unsigned, const float, const float, const float, const unsigned);
$END_MIN$

	/* Features */
	af_err af_create_features (af_features *, dim_t);
	af_err af_get_features_num (dim_t *, const af_features);
	af_err af_get_features_orientation (af_array *, const af_features);
	af_err af_get_features_score (af_array *, const af_features);
	af_err af_get_features_size (af_array *, const af_features);
	af_err af_get_features_xpos (af_array *, const af_features);
	af_err af_get_features_ypos (af_array *, const af_features);
	af_err af_release_features (af_features);
	af_err af_retain_features (af_features *, const af_features);

	/* Image Processing */
	af_err af_bilateral (af_array *, const af_array, const float, const float, const bool);
	af_err af_color_space (af_array *, const af_array, const af_cspace_t, const af_cspace_t);
	af_err af_dilate (af_array *, const af_array, const af_array);
	af_err af_dilate3 (af_array *, const af_array, const af_array);
	af_err af_erode (af_array *, const af_array, const af_array);
	af_err af_erode3 (af_array *, const af_array, const af_array);
	af_err af_gaussian_kernel (af_array *, const int, const int, const double, const double);
	af_err af_gray2rgb (af_array *, const af_array, const float, const float, const float);
	af_err af_hist_equal (af_array *, const af_array, const af_array);
	af_err af_histogram (af_array *, const af_array, const unsigned, const double, const double);
	af_err af_hsv2rgb (af_array *, const af_array);
	af_err af_maxfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_mean_shift (af_array *, const af_array, const float, const float, const unsigned, const bool);
	af_err af_medfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_minfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_regions (af_array *, const af_array, const af_connectivity, const af_dtype);
	af_err af_resize (af_array *, const af_array, const dim_t, const dim_t, const af_interp_type);
	af_err af_rgb2gray (af_array *, const af_array, const float, const float, const float);
	af_err af_rgb2hsv (af_array *, const af_array);
$MIN_VERSION(31)$
	af_err af_rgb2ycbcr (af_array *, const af_array, const af_ycc_std);
$END_MIN$
	af_err af_rotate (af_array *, const af_array, const float, const bool, const af_interp_type);
$MIN_VERSION(31)$
	af_err af_sat (af_array *, const af_array);
$END_MIN$
	af_err af_scale (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
	af_err af_skew (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_sobel_operator (af_array *, af_array *, const af_array, const unsigned);
	af_err af_transform (af_array *, const af_array, const af_array, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_translate (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
$MIN_VERSION(31)$
	af_err af_unwrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_wrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_ycbcr2rgb (af_array *, const af_array, const af_ycc_std);
$END_MIN$

	/* Interface */
$MIN_VERSION(32)$
$USES_OPENCL$
	af_err afcl_get_context (cl_context *, const bool);
	af_err afcl_get_device_id (cl_device_id *);
	af_err afcl_get_queue (cl_command_queue *, const bool);
$END_USES_OPENCL$

$USES_CUDA$
	af_err afcu_get_native_id (int *, int);
	af_err afcu_get_stream (cudaStream_t *, int);
$END_USES_CUDA$
$END_MIN$

	/* IO */
$MIN_VERSION(31)$
	af_err af_delete_image_memory (void *);
$END_MIN$
	af_err af_load_image (af_array *, const char *, const bool);
$MIN_VERSION(31)$
	af_err af_load_image_memory (af_array *, const void *);
$END_MIN$
$MIN_VERSION(32)$
	af_err af_load_image_native (af_array *, const char *);
$END_MIN$
	af_err af_read_array_index (af_array *, const char *, const unsigned);
	af_err af_read_array_key (af_array *, const char *, const char *);
	af_err af_read_array_key_check (int *, const char *, const char *);
	af_err af_save_array (int *, const char *, const af_array, const char *, const bool);
	af_err af_save_image (const char *, const af_array);
$MIN_VERSION(31)$
	af_err af_save_image_memory (void **, const af_array, const af_image_format);
$END_MIN$
$MIN_VERSION(32)$
    af_err af_save_image_native (const char *, const af_array);
$END_MIN$

	/* Linear Algebra */
	af_err af_cholesky (af_array *, int *, const af_array, const bool);
	af_err af_cholesky_inplace (int *, const af_array, const bool);
	af_err af_det (double *, double *, const af_array);
	af_err af_dot (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_inverse (af_array *, const af_array, const af_mat_prop);
	af_err af_lu (af_array *, af_array *, af_array *, const af_array);
	af_err af_lu_inplace (af_array *, af_array, const bool);		
	af_err af_matmul (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_norm (double *, const af_array, const af_norm_type, const double, const double);
	af_err af_qr (af_array *, af_array *, af_array *, const af_array);
	af_err af_qr_inplace (af_array *, af_array);
	af_err af_rank (unsigned *, const af_array, const double);
	af_err af_solve (af_array *, const af_array, const af_array, const af_mat_prop);
	af_err af_solve_lu (af_array *, const af_array, const af_array, const af_array, const af_mat_prop);
$MIN_VERSION(31)$
	af_err af_svd (af_array *, af_array *, af_array *, const af_array);
	af_err af_svd_inplace (af_array *, af_array *, af_array *, const af_array);
$END_MIN$
	af_err af_transpose (af_array *, af_array, const bool);
	af_err af_transpose_inplace (af_array, const bool);

	/* Mathematics */
	af_err af_abs (af_array *, const af_array);
	af_err af_acos (af_array *, const af_array);
	af_err af_acosh (af_array *, const af_array);
	af_err af_add (af_array *, const af_array, const af_array, const bool);
	af_err af_and (af_array *, const af_array, const af_array, const bool);
	af_err af_arg (af_array *, const af_array);
	af_err af_asin (af_array *, const af_array);
	af_err af_asinh (af_array *, const af_array);
	af_err af_atan (af_array *, const af_array);
	af_err af_atanh (af_array *, const af_array);
	af_err af_atan2 (af_array *, const af_array, const af_array, const bool);
	af_err af_bitand (af_array *, const af_array, const af_array, const bool);	
	af_err af_bitor (af_array *, const af_array, const af_array, const bool);
	af_err af_bitshiftl (af_array *, const af_array, const af_array, const bool);	
	af_err af_bitshiftr (af_array *, const af_array, const af_array, const bool);
	af_err af_bitxor (af_array *, const af_array, const af_array, const bool);
	af_err af_cbrt (af_array *, const af_array);
	af_err af_ceil (af_array *, const af_array);
	af_err af_conjg (af_array *, const af_array);
	af_err af_cos (af_array *, const af_array);
	af_err af_cosh (af_array *, const af_array);
	af_err af_cplx (af_array *, const af_array);
	af_err af_cplx2 (af_array *, const af_array, const af_array, const bool);
	af_err af_div (af_array *, const af_array, const af_array, const bool);
	af_err af_eq (af_array *, const af_array, const af_array, const bool);
	af_err af_erf (af_array *, const af_array);	
	af_err af_erfc (af_array *, const af_array);	
	af_err af_exp (af_array *, const af_array);
	af_err af_expm1 (af_array *, const af_array);	
	af_err af_factorial (af_array *, const af_array);
	af_err af_floor (af_array *, const af_array);
	af_err af_ge (af_array *, const af_array, const af_array, const bool);
	af_err af_gt (af_array *, const af_array, const af_array, const bool);
	af_err af_hypot (af_array *, const af_array, const af_array, const bool);
	af_err af_imag (af_array *, const af_array);
	af_err af_le (af_array *, const af_array, const af_array, const bool);
	af_err af_lgamma (af_array *, const af_array);
	af_err af_lt (af_array *, const af_array, const af_array, const bool);
	af_err af_log (af_array *, const af_array);	
	af_err af_log10 (af_array *, const af_array);	
	af_err af_log1p (af_array *, const af_array);
	af_err af_maxof (af_array *, const af_array, const af_array, const bool);
	af_err af_minof (af_array *, const af_array, const af_array, const bool);
	af_err af_mod (af_array *, const af_array, const af_array, const bool);
	af_err af_mul (af_array *, const af_array, const af_array, const bool);
	af_err af_neq (af_array *, const af_array, const af_array, const bool);	
	af_err af_not (af_array *, const af_array);
	af_err af_or (af_array *, const af_array, const af_array, const bool);
	af_err af_pow (af_array *, const af_array, const af_array, const bool);
	af_err af_real (af_array *, const af_array);
	af_err af_rem (af_array *, const af_array, const af_array, const bool);
	af_err af_root (af_array *, const af_array, const af_array, const bool);
	af_err af_round (af_array *, const af_array);
$MIN_VERSION(31)$
	AFAPI af_err af_sigmoid (af_array *, const af_array);
$END_MIN$
	af_err af_sign (af_array *, const af_array);
	af_err af_sin (af_array *, const af_array);
	af_err af_sinh (af_array *, const af_array);
	af_err af_sub (af_array *, const af_array, const af_array, const bool);
	af_err af_sqrt (af_array *, const af_array);
	af_err af_tan (af_array *, const af_array);
	af_err af_tanh (af_array *, const af_array);
	af_err af_trunc (af_array *, const af_array);
	af_err af_tgamma (af_array *, const af_array);

	/* Signal Processing */
	af_err af_approx1 (af_array *, const af_array, const af_array, const af_interp_type, const float);
	af_err af_approx2 (af_array *, const af_array, const af_array, const af_array, const af_interp_type, const float);
	af_err af_convolve1 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2_sep (af_array *, const af_array, const af_array, const af_array, const af_conv_mode);	
	af_err af_convolve3 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_fft (af_array *, const af_array, const double, const dim_t);	
	af_err af_fft_convolve2	(af_array *, const af_array, const af_array, const af_conv_mode);
	af_err af_fft_convolve3	(af_array *, const af_array, const af_array, const af_conv_mode);
$MIN_VERSION(31)$	
	af_err af_fft_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft_inplace (af_array, const double);
	af_err af_fft_r2c (af_array *, const af_array, const double, const dim_t);
$END_MIN$
	af_err af_fft2 (af_array *, const af_array, const double, const dim_t, const dim_t);
$MINVER(31)$
	af_err af_fft2_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft2_inplace (af_array, const double);
	af_err af_fft2_r2c (af_array *, const af_array, const double, const dim_t, const dim_t);
$/MINVER$
	af_err af_fft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);
$MIN_VERSION(31)$	
	af_err af_fft3_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft3_inplace (af_array, const double);
	af_err af_fft3_r2c (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);
$END_MIN$
	af_err af_fir (af_array *, const af_array, const af_array);
	af_err af_ifft (af_array *, const af_array, const double, const dim_t);
$MIN_VERSION(31)$
	af_err af_ifft_inplace (af_array, const double);
$END_MIN
	af_err af_ifft2 (af_array *, const af_array, const double, const dim_t, const dim_t);
$MIN_VERSION(31)$
	af_err af_ifft2_inplace (af_array, const double);
$END_MIN$
	af_err af_ifft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);
$MIN_VERSION(31)$
	af_err af_ifft3_inplace (af_array, const double);
$END_MIN$
	af_err af_iir (af_array *, const af_array, const af_array, const af_array);

	/* Statistics */
	af_err af_corrcoef (double *, double *, const af_array, const af_array);
	af_err af_cov (	af_array *, const af_array, const af_array, const bool);
	af_err af_mean (af_array *, const af_array, const dim_t);
	af_err af_mean_all (double *, double *, const af_array);
	af_err af_mean_all_weighted (double *, double *, const af_array, const af_array);	
	af_err af_mean_weighted (af_array *, const af_array, const af_array, const dim_t);
	af_err af_median (af_array *, const af_array, const dim_t);
	af_err af_median_all (double *, double *, const af_array);
	af_err af_stdev (af_array *, const af_array, const dim_t);
	af_err af_stdev_all (double *, double *, const af_array);
	af_err af_var (af_array *, const af_array, const bool, const dim_t);
	af_err af_var_all (double *, double *, const af_array, const bool);	
	af_err af_var_all_weighted (double *, double *, const af_array, const af_array);
	af_err af_var_weighted (af_array *, const af_array, const af_array, const dim_t);

	/* Util */
    af_err af_print_array (af_array arr);
$MIN_VERSION(31)$
    af_err af_print_array_gen (const char *, const af_array, const int);
	af_err af_array_to_string (char **, const char *, const af_array, const int, const bool);
$END_MIN$
	
	/* Vector */
	af_err af_accum (af_array *, const af_array, const int);
	af_err af_all_true (af_array *, const af_array, const int);
	af_err af_all_true_all (double *, double *, const af_array);
	af_err af_any_true (af_array *, const af_array, const int);
	af_err af_any_true_all (double *, double *, const af_array);
	af_err af_count (af_array *, const af_array, const int);
	af_err af_count_all (double *, double *, const af_array);
	af_err af_diff1 (af_array *, const af_array, const int);
	af_err af_diff2 (af_array *, const af_array, const int);
	af_err af_gradient (af_array *, af_array *, const af_array);
	af_err af_imax (af_array *, af_array *, const af_array, const int);
	af_err af_imax_all (double *, double *, unsigned *, const af_array);
	af_err af_imin (af_array *, af_array *, const af_array, const int);
	af_err af_imin_all (double *, double *, unsigned *, const af_array);
	af_err af_max (af_array *, const af_array, const int);
	af_err af_max_all (double *, double *, const af_array);
	af_err af_min (af_array *, const af_array, const int);
	af_err af_min_all (double *, double *, const af_array);
	af_err af_product (af_array *, const af_array, const int);
	af_err af_product_all (double *, double *, const af_array);
$MIN_VERSION(31)$
	af_err af_product_nan (af_array *, const af_array, const int, const double);
	af_err af_product_nan_all (double *, double *, const af_array, const double);
$END_MIN$
	af_err af_set_intersect (af_array *, const af_array, const af_array, const bool);
	af_err af_set_union (af_array *, const af_array, const af_array, const bool);
	af_err af_set_unique (af_array *, const af_array, const bool);
	af_err af_sort (af_array *, const af_array, const unsigned, const bool);
	af_err af_sort_by_key (af_array *, af_array *, const af_array, const af_array, const unsigned, const bool);
	af_err af_sort_index (af_array *, af_array *, const af_array, const unsigned, const bool);
	af_err af_sum (af_array *, const af_array, const int);
	af_err af_sum_all (double *, double *, const af_array);
$MIN_VERSION(31)$
	af_err af_sum_nan (af_array *, const af_array, const int, const double);
	af_err af_sum_nan_all (double *, double *, const af_array, const double);
$END_MIN$
	af_err af_where (af_array *, const af_array);

	/* Array Methods */
	af_err af_copy_array (af_array *, const af_array);
	af_err af_eval (af_array);
$MIN_VERSION(31)$
	af_err af_get_data_ref_count (int *, const af_array);
$END_MIN$
	af_err af_get_dims (dim_t *, dim_t *, dim_t *, dim_t *, const af_array);
	af_err af_get_elements (dim_t *, const af_array);
	af_err af_get_data_ptr (void *, const af_array);
	af_err af_get_numdims (unsigned *, const af_array);
	af_err af_get_type (af_dtype *, const af_array);
	af_err af_is_bool (bool *, const af_array);
	af_err af_is_column (bool *, const af_array);
	af_err af_is_complex (bool *, const af_array);
	af_err af_is_double (bool *, const af_array);
	af_err af_is_empty (bool *, const af_array);
	af_err af_is_floating (bool *, const af_array);
	af_err af_is_integer (bool *, const af_array);
	af_err af_is_real (bool *, const af_array);
	af_err af_is_realfloating (bool *, const af_array);
	af_err af_is_row (bool *, const af_array);
	af_err af_is_scalar (bool *, const af_array);
	af_err af_is_single (bool *, const af_array);
	af_err af_is_vector (bool *, const af_array);
	af_err af_release_array (af_array);
	af_err af_retain_array (af_array *, const af_array);
	af_err af_write_array (af_array, const void *, const size_t, af_source);

	/* Assign / Index */
	af_err af_assign_gen (af_array *, const af_array, const dim_t, const af_index_t *, const af_array);
	af_err af_assign_seq (af_array *, const af_array, const unsigned, const af_seq * const, const af_array);
$MIN_VERSION(32)$
	af_err af_create_indexers (af_index_t **);
$END_MIN$
	af_err af_index (af_array *, const af_array, const unsigned, const af_seq * const);
	af_err af_index_gen (af_array *, const af_array, const dim_t, const af_index_t *);
	af_err af_lookup (af_array *, const af_array, const af_array, const unsigned);
$MIN_VERSION(32)$
	af_err af_release_indexers (af_index_t *);
	af_err af_set_array_indexer (af_index_t *, const af_array, const dim_t);
	af_err af_set_seq_indexer (af_index_t *, const af_seq *, const dim_t, const bool);
	af_err af_set_seq_param_indexer (af_index_t *, const double, const double, const double, const dim_t, const bool);
$END_MIN$
	af_seq af_make_seq (double, double, double);

	static const af_seq af_span = {1, 1, 0};

	/* Device */
	af_err af_alloc_device (void **, const dim_t);
	af_err af_alloc_pinned (void **, const dim_t);
	af_err af_device_gc ();
	af_err af_device_info (char *, char *, char *, char *);
	af_err af_device_mem_info (size_t *, size_t *, size_t *, size_t *);
	af_err af_free_device (void *);
	af_err af_free_pinned (void *);
	af_err af_get_device (int *);
	af_err af_get_device_count (int *);
	af_err af_get_device_ptr (void **, const af_array);
	af_err af_get_dbl_support (bool *, const int);
	af_err af_get_mem_step_size (size_t *);
	af_err af_info ();
$MIN_VERSION(31)$
	af_err af_lock_device_ptr (const af_array);
$END_MIN$
	af_err af_set_device (const int);
	af_err af_set_mem_step_size (const size_t);
	af_err af_sync (const int);
$MIN_VERSION(31)$
	af_err af_unlock_device_ptr (const af_array);
$END_MIN$

	/* Helper */
	af_err af_cast (af_array *, const af_array, const af_dtype);
	af_err af_isinf (af_array *, const af_array);
	af_err af_iszero (af_array *, const af_array);

	/* Move / Reorder */
	af_err af_flat (af_array *, const af_array);
	af_err af_flip (af_array *, const af_array, const unsigned);
	af_err af_join (af_array *, const int, const af_array, const af_array);
	af_err af_join_many (af_array *, const int, const unsigned, const af_array *);
	af_err af_moddims (af_array *, const af_array, const unsigned, const dim_t *);
	af_err af_reorder (af_array *, const af_array, const unsigned, const unsigned, const unsigned, const unsigned);
$MIN_VERSION(31)$
	af_err af_replace (af_array, const af_array, const af_array);
	af_err af_replace_scalar (af_array, const af_array, const double);
    af_err af_select (af_array *, const af_array, const af_array, const af_array);
    af_err af_select_scalar_r (af_array *, const af_array, const af_array, const double);
    af_err af_select_scalar_l (af_array *, const af_array, const double, const af_array);
$END_MIN$
	af_err af_shift (af_array *, const af_array, const int, const int, const int, const int);
	af_err af_tile (af_array *, const af_array, const unsigned, const unsigned, const unsigned, const unsigned);

	/* Draw */
	af_err af_draw_hist (const af_window, const af_array, const double, const double, const af_cell *);
	af_err af_draw_image (const af_window, const af_array, const af_cell *);
	af_err af_draw_plot (const af_window, const af_array, const af_array, const af_cell *);
$MIN_VERSION(32)$
	af_err af_draw_plot3 (const af_window, const af_array, const af_cell *);
$END_MIN$
$MIN_VERSION(32.1)$
	af_err af_draw_surface (const af_window, const af_array, const af_array, const af_array, const af_cell *);
$END_MIN$

	/* Window */
	af_err af_create_window (af_window *, const int, const int, const char * const);	
	af_err af_destroy_window (const af_window);
	af_err af_grid (const af_window, const int, const int);
	af_err af_is_window_closed (bool *, const af_window);
	af_err af_set_position (const af_window, const unsigned, const unsigned);
$MIN_VERSION(31)$
	af_err af_set_size (const af_window, const unsigned, const unsigned);
$END_MIN$
	af_err af_set_title (const af_window, const char * const);
	af_err af_show (const af_window);
]]):gsub("%$MIN_VERSION%((%d+)%.?(%d*)%)%$(.-)%$END_MIN%$", function (version, patch_id, code)
	version, patch_id = tonumber(version), tonumber(patch_id) or -1

	if Version >= version and (Version > version or Patch >= patch_id) then
		return code
	else
		return ""
	end
end):gsub("%$USES_CUDA%$(.-)%END_USES_CUDA%$", function (code) -- strip CUDA if not supported
	return UsesCUDA and code or ""
end):gsub("%$USES_OPENCL%$(.-)%$END_USES_OPENCL%$", function (code) -- strip OpenCL if not supported
	return UsesOpenCL and code or ""
end)

ffi.cdef(def)

return af