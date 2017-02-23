require('arrayfire.lib')

af.err = {
   none              =   0,

   no_mem            = 101,
   driver            = 102,
   runtime           = 103,

   invalid_array     = 201,
   arg               = 202,
   size              = 203,
   type              = 204,
   diff_type         = 205,
   batch             = 207,
   device            = 208,

   not_supported     = 301,
   not_configured    = 302,
   nonfree           = 303,

   no_dbl            = 401,
   no_gfx            = 402,

   load_lib          = 501,
   load_sym          = 502,
   arr_bknd_mismatch = 503,

   internal          = 998,
   unknown           = 999
}

af.dtype = {
   f32 = 0,
   c32 = 1,
   f64 = 2,
   c64 = 3,
   b8  = 4,
   s32 = 5,
   u32 = 6,
   u8  = 7,
   s64 = 8,
   u64 = 9,
   s16 = 10,
   u16 = 11
}

af.source = {
   device = 0,
   host   = 1,
}

af.interp_type = {
   nearest         = 0,
   linear          = 1,
   bilinear        = 2,
   cubic           = 3,
   lower           = 4,
   linear_cosine   = 5,
   bilinear_cosine = 6,
   bicubic         = 7,
   cubic_spline    = 8,
   bicubic_spline  = 9,
}

af.border_type = {
   zero      = 0,
   symmetric = 1
}

af.connectivity = {}
af.connectivity[4] = 4
af.connectivity[8] = 8

af.conv_mode = {
   default = 0,
   expand  = 1
}

af.conv_domain = {
   auto      = 0,
   spatial   = 1,
   frequency = 2,
}

af.match_type = {
   sad  = 0,
   zsad = 1,
   lsad = 2,
   ssd  = 3,
   zssd = 4,
   lssd = 5,
   ncc  = 6,
   zncc = 7,
   shd  = 8
}

af.ycc_std = {}
af.ycc_std[601] = 601
af.ycc_std[709] = 709
af.ycc_std[2020] = 2020

af.cspace = {
   gray  = 0,
   rgb   = 1,
   hsv   = 2,
   ycbcr = 3
}

af.mat_prop = {
   none       = 0,
   trans      = 1,
   ctrans     = 2,
   conj       = 4,
   upper      = 32,
   lower      = 64,
   diag_unit  = 128,
   sym        = 512,
   posdef     = 1024,
   orthog     = 2048,
   tri_diag   = 4096,
   block_diag = 8192
}

af.norm_type = {
   vector_1    = 0,
   vector_inf  = 1,
   vector_2    = 2,
   vector_p    = 3,
   matrix_1    = 4,
   matrix_inf  = 5,
   matrix_2    = 6,
   matrix_l_pq = 7,
   euclid      = 2
}

af.image_format = {
   bmp    = 0,
   ico    = 1,
   jpeg   = 2,
   jng    = 3,
   png    = 13,
   ppm    = 14,
   ppmraw = 15,
   tiff   = 18,
   psd    = 20,
   hdr    = 26,
   exr    = 29,
   jp2    = 31,
   raw    = 34
}

af.moment_type = {
   m00 = 1,
   m01 = 2,
   m10 = 4,
   m11 = 8,
   first_order = 15
}

af.homography_type =  {
   ransac = 0,
   lmeds  = 1
}

af.backend = {
   default = 0,
   cpu     = 1,
   cuda    = 2,
   opencl  = 4,
}

af.binary_op = {
   add  = 0,
   mul  = 1,
   min  = 2,
   max  = 3
}

af.random_engine_type = {
   philox_4x32_10     = 100,
   threefry_2x32_16   = 200,
   mersenne_gp11213   = 300,
}
af.random_engine_type.philox = af.random_engine_type.philox_4x32_10
af.random_engine_type.threefry = af.random_engine_type.threefry_2x32_16
af.random_engine_type.mersenne = af.random_engine_type.mersenne_gp11213
af.random_engine_type.default = af.random_engine_type.philox

af.colormap = {
   default = 0,
   spectrum= 1,
   colors  = 2,
   red     = 3,
   mood    = 4,
   heat    = 5,
   blue    = 6
}

af.marker_type = {
   none     = 0,
   point    = 1,
   circle   = 2,
   square   = 3,
   triangle = 4,
   cross    = 5,
   plus     = 6,
   star     = 7
}

af.storage =  {
   dense     = 0,
   csr       = 1,
   csc       = 2,
   coo       = 3,
}

af.dtype_names = {
   'float',
   'af_cfloat',
   'double',
   'af_cdouble',
   'char',
   'int',
   'unsigned int',
   'unsigned char',
   'unsigned long long',
   'long long',
   'short',
   'unsigned shhort'
}
