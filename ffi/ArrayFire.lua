-- Adapted from https://github.com/malkia/ufo/blob/master/ffi/OpenCL.lua

local ffi  = require( "ffi" )

local name, path = "af", os.getenv("AF_PATH") .. "/"
local is_32_bit = ffi.abi("32bit") -- used to typedef dim_t


if ArrayFireMode == "cl" or ArrayFireMode == "cuda" then
	name = name .. ArrayFireMode
else
	name = name .. "cpu"
end

local libs = ffi_ArrayFireLibs or {
   -- OSX     = { x86 = path .. name, x64 = path .. name },
   Windows = { x86 = path .. name, x64 = path .. name },
   -- Linux   = { x86 = path .. "lib" .. name, x64 = path .. "lib" .. name, arm = "bin/Linux/arm/lib" .. name }
}

local lib  = ffi_ArrayFire_lib or libs[ ffi.os ][ ffi.arch ]
local af   = ffi.load( lib )

ffi.cdef([[
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

		///
		/// This build of ArrayFire is not compiled with "nonfree" algorithms
		///
		AFF_ERR_NONFREE       = 303,

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
		u64     ///< 64-bit unsigned integral values
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

	typedef enum {
		AF_YCC_601 = 601,  ///< ITU-R BT.601 (formerly CCIR 601) standard
		AF_YCC_709 = 709,  ///< ITU-R BT.709 standard
		AF_YCC_2020 = 2020  ///< ITU-R BT.2020 standard
	} af_ycc_std;

	typedef enum {
		AF_GRAY = 0, ///< Grayscale
		AF_RGB,      ///< 3-channel RGB
		AF_HSV,      ///< 3-channel HSV
		AF_YCbCr     ///< 3-channel YCbCr
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

	typedef ]] .. (is_32_bit and "int" or "long long") .. [[ dim_t;
	
	typedef long long intl;
	typedef unsigned long long uintl;

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

	/* Computer Vision */
	af_err af_dog (af_array *, const af_array, const int, const int);
	af_err af_fast (af_features *, const af_array, const float, const unsigned, const bool, const float, const unsigned);
	af_err af_gloh (af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float);
	af_err af_harris (af_features *, const af_array, const unsigned, const float, const float, const unsigned, const float);
	af_err af_orb (af_features *, af_array *, const af_array, const float, const unsigned, const float, const unsigned, const bool);
	af_err af_sift (af_features *, af_array *, const af_array, const unsigned, const float, const float, const float, const bool, const float, const float);
	af_err af_susan (af_features *, const af_array, const unsigned, const float, const float, const float, const unsigned);

	/* Image Processing */
	af_err af_bilateral (af_array *, const af_array, const float, const float, const bool);
	af_err af_color_space ( af_array *, const af_array, const af_cspace_t, const af_cspace_t);
	af_err af_dilate (af_array *, const af_array, const af_array);
	af_err af_dilate3 (af_array *, const af_array, const af_array);
	af_err af_erode (af_array *, const af_array, const af_array);
	af_err af_erode3 (af_array *, const af_array, const af_array);
	af_err af_gaussian_kernel (af_array *, const int, const int, const double, const double);
	af_err af_gray2rgb (af_array *, const af_array, const float, const float, const float);
	af_err af_hist_equal (af_array *, const af_array, const af_array);
	af_err af_histogram (af_array *, const af_array, const unsigned, const double, const double);
	af_err af_hsv2rgb (af_array *, const af_array);
	af_err af_minfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_mean_shift (af_array *, const af_array, const float, const float, const unsigned, const bool);
	af_err af_medfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_maxfilt (af_array *, const af_array, const dim_t, const dim_t, const af_border_type);
	af_err af_regions (af_array *, const af_array, const af_connectivity, const af_dtype);
	af_err af_resize (af_array *, const af_array, const dim_t, const dim_t, const af_interp_type);
	af_err af_rgb2gray (af_array *, const af_array, const float, const float, const float);
	af_err af_rgb2hsv (af_array *, const af_array);
	af_err af_rgb2ycbcr (af_array *, const af_array, const af_ycc_std);	
	af_err af_rotate (af_array *, const af_array, const float, const bool, const af_interp_type);
	af_err af_sat (af_array *, const af_array);
	af_err af_scale (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
	af_err af_skew (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_sobel_operator (af_array *, af_array *, const af_array, const unsigned);
	af_err af_transform (af_array *, const af_array, const af_array, const dim_t, const dim_t, const af_interp_type, const bool);
	af_err af_translate (af_array *, const af_array, const float, const float, const dim_t, const dim_t, const af_interp_type);
	af_err af_unwrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_wrap (af_array *, const af_array, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const dim_t, const bool);
	af_err af_ycbcr2rgb (af_array *, const af_array, const af_ycc_std);

	/* Interface */

	/* IO */

	/* Linear Algebra */
	af_err af_cholesky (af_array *, int *, const af_array, const bool);
	af_err af_cholesky_inplace (int *, const af_array, const bool);
	af_err af_det (double *, double *, const af_array);
	af_err af_dot (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_inverse (af_array *, const af_array, const af_array, const af_mat_prop);
	af_err af_lu (af_array *, af_array *, af_array *, const af_array);
	af_err af_lu_inplace (af_array *, af_array, const bool);		
	af_err af_matmul (af_array *, const af_array, const af_array, const af_mat_prop, const af_mat_prop);
	af_err af_norm (double *, const af_array, const af_norm_type, const double, const double);
	af_err af_qr (af_array *, af_array *, af_array *, const af_array);
	af_err af_qr_inplace ( af_array *, af_array);
	af_err af_rank (unsigned *, const af_array, const double);
	af_err af_solve (af_array *, const af_array, const af_array, const af_mat_prop);
	af_err af_solve_lu (af_array *, const af_array, const af_array, const af_array, const af_mat_prop);
	af_err af_svd (af_array *, af_array *, af_array *, const af_array);
	af_err af_svd_inplace (af_array *, af_array *, af_array *, const af_array);
	af_err af_transpose (af_array *, af_array, const bool);
	af_err af_transpose_inplace (af_array, const bool);

	/* Mathematics */
	af_err af_abs (af_array *, const af_array);
	af_err af_acos (af_array *, const af_array);
	af_err af_acosh (af_array *, const af_array);
	af_err af_arg (af_array *, const af_array);
	af_err af_asin (af_array *, const af_array);
	af_err af_asinh (af_array *, const af_array);
	af_err af_atan (af_array *, const af_array);	
	af_err af_atanh (af_array *, const af_array);	
	af_err af_cbrt (af_array *, const af_array);
	af_err af_ceil (af_array *, const af_array);
	af_err af_conjg (af_array *, const af_array);
	af_err af_cos (af_array *, const af_array);
	af_err af_cosh (af_array *, const af_array);
	af_err af_cplx (af_array *, const af_array);
	af_err af_erf (af_array *, const af_array);	
	af_err af_erfc (af_array *, const af_array);	
	af_err af_exp (af_array *, const af_array);
	af_err af_expm1 (af_array *, const af_array);	
	af_err af_factorial (af_array *, const af_array);
	af_err af_floor (af_array *, const af_array);
	af_err af_imag (af_array *, const af_array);
	af_err af_lgamma (af_array *, const af_array);
	af_err af_log (af_array *, const af_array);	
	af_err af_log10 (af_array *, const af_array);	
	af_err af_log1p (af_array *, const af_array);
	af_err af_not (af_array *, const af_array);
	af_err af_real (af_array *, const af_array);
	af_err af_round (af_array *, const af_array);
	af_err af_sign (af_array *, const af_array);
	af_err af_sin (af_array *, const af_array);
	af_err af_sinh (af_array *, const af_array);			
	af_err af_sqrt (af_array *, const af_array);
	af_err af_tan (af_array *, const af_array);
	af_err af_tanh (af_array *, const af_array);
	af_err af_trunc (af_array *, const af_array);
	af_err af_tgamma (af_array *, const af_array);

	af_err af_add (af_array *, const af_array, const af_array, const bool);
	af_err af_and (af_array *, const af_array, const af_array, const bool);
	af_err af_atan2 (af_array *, const af_array, const af_array, const bool);
	af_err af_bitand (af_array *, const af_array, const af_array, const bool);	
	af_err af_bitor (af_array *, const af_array, const af_array, const bool);
	af_err af_bitshiftl (af_array *, const af_array, const af_array, const bool);	
	af_err af_bitshiftr (af_array *, const af_array, const af_array, const bool);
	af_err af_bitxor (af_array *, const af_array, const af_array, const bool);
	af_err af_cplx2 (af_array *, const af_array, const af_array, const bool);
	af_err af_div (af_array *, const af_array, const af_array, const bool);
	af_err af_eq (af_array *, const af_array, const af_array, const bool);
	af_err af_ge (af_array *, const af_array, const af_array, const bool);
	af_err af_gt (af_array *, const af_array, const af_array, const bool);
	af_err af_hypot (af_array *, const af_array, const af_array, const bool);
	af_err af_le (af_array *, const af_array, const af_array, const bool);
	af_err af_maxof (af_array *, const af_array, const af_array, const bool);
	af_err af_minof (af_array *, const af_array, const af_array, const bool);
	af_err af_mod (af_array *, const af_array, const af_array, const bool);
	af_err af_mul (af_array *, const af_array, const af_array, const bool);
	af_err af_neq (af_array *, const af_array, const af_array, const bool);	
	af_err af_or (af_array *, const af_array, const af_array, const bool);
	af_err af_pow (af_array *, const af_array, const af_array, const bool);
	af_err af_rem (af_array *, const af_array, const af_array, const bool);
	af_err af_root (af_array *, const af_array, const af_array, const bool);
	af_err af_sub (af_array *, const af_array, const af_array, const bool);

	/* Signal Processing */
	af_err af_approx1 (af_array *, const af_array, const af_array, const af_interp_type, const float);
	af_err af_approx2 (af_array *, const af_array, const af_array, const af_array, const af_interp_type, const float);
	af_err af_convolve1 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_convolve2_sep (af_array *, const af_array, const af_array, const af_array, const af_conv_mode);	
	af_err af_convolve3 (af_array *, const af_array, const af_array, const af_conv_mode, af_conv_domain);
	af_err af_fir (af_array *, const af_array, const af_array);
	af_err af_ifft (af_array *, const af_array, const double, const dim_t);
	af_err af_ifft_inplace (af_array, const double);
	af_err af_ifft2 (af_array *, const af_array, const double, const dim_t, const dim_t);
	af_err af_ifft2_inplace (af_array, const double);
	af_err af_ifft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);	
	af_err af_ifft3_inplace (af_array, const double);
	af_err af_iir (af_array *, const af_array, const af_array, const af_array);
	af_err af_fft (af_array *, const af_array, const double, const dim_t);	
	af_err af_fft_convolve2	(af_array *, const af_array, const af_array, const af_conv_mode);
	af_err af_fft_convolve3	(af_array *, const af_array, const af_array, const af_conv_mode);	
	af_err af_fft_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft_inplace (af_array, const double);
	af_err af_fft_r2c (af_array *, const af_array, const double, const dim_t);
	af_err af_fft2 (af_array *, const af_array, const double, const dim_t, const dim_t);	
	af_err af_fft2_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft2_inplace (af_array, const double);
	af_err af_fft2_r2c (af_array *, const af_array, const double, const dim_t, const dim_t);
	af_err af_fft3 (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);	
	af_err af_fft3_c2r (af_array *, const af_array, const double, const bool);
	af_err af_fft3_inplace (af_array, const double);
	af_err af_fft3_r2c (af_array *, const af_array, const double, const dim_t, const dim_t, const dim_t);

	/* Statistics */
	af_err af_corrcoef (double *, double *, const af_array, const af_array);
	af_err af_cov (	af_array *, const af_array, const af_array, const bool);
	af_err af_median (af_array *, const af_array, const dim_t);
	af_err af_median_all (double *, double *, const af_array);
	af_err af_mean (af_array *, const af_array, const dim_t);
	af_err af_mean_all (double *, double *, const af_array);
	af_err af_mean_all_weighted (double *, double *, const af_array, const af_array);	
	af_err af_mean_weighted (af_array *, const af_array, const af_array, const dim_t);
	af_err af_stdev (af_array *, const af_array, const dim_t);
	af_err af_stdev_all (double *, double *, const af_array);
	af_err af_var (af_array *, const af_array, const bool, const dim_t);
	af_err af_var_all (double *, double *, const af_array, const bool);	
	af_err af_var_all_weighted (double *, double *, const af_array, const af_array);
	af_err af_var_weighted (af_array *, const af_array, const af_array, const dim_t);

	/* Vector */

	/* Array Methods */
	af_err af_copy_array (af_array *, const af_array);
	af_err af_eval (af_array);
	af_err af_get_data_ref_count (int *, const af_array);
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

	/* Device */

	/* Helper */

	/* Move / Reorder */

	/* Draw */

	/* Window */
	
]])

return af