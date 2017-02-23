require('arrayfire.lib')
require('arrayfire.defines')
local ffi  = require( "ffi" )

local funcs = {}
funcs[30] = [[
    af_err af_create_array(af_array *arr, const void * const data,
                           const unsigned ndims, const dim_t * const dims, const af_dtype type);

    af_err af_create_handle(af_array *arr, const unsigned ndims,
                            const dim_t * const dims, const af_dtype type);

    af_err af_copy_array(af_array *arr, const af_array in);

    af_err af_write_array(af_array arr, const void *data, const size_t bytes, af_source src);

    af_err af_get_data_ptr(void *data, const af_array arr);

    af_err af_release_array(af_array arr);

    af_err af_retain_array(af_array *out, const af_array in);

    af_err af_get_elements(dim_t *elems, const af_array arr);

    af_err af_get_type(af_dtype *type, const af_array arr);
    af_err af_get_dims(dim_t *d0, dim_t *d1, dim_t *d2, dim_t *d3,
                             const af_array arr);

    af_err af_get_numdims(unsigned *result, const af_array arr);

    af_err af_is_empty        (bool *result, const af_array arr);

    af_err af_is_scalar       (bool *result, const af_array arr);

    af_err af_is_row          (bool *result, const af_array arr);
    af_err af_is_column       (bool *result, const af_array arr);

    af_err af_is_vector       (bool *result, const af_array arr);
    af_err af_is_complex      (bool *result, const af_array arr);

    af_err af_is_real         (bool *result, const af_array arr);
    af_err af_is_double       (bool *result, const af_array arr);
    af_err af_is_single       (bool *result, const af_array arr);
    af_err af_is_realfloating (bool *result, const af_array arr);
    af_err af_is_floating     (bool *result, const af_array arr);
    af_err af_is_integer      (bool *result, const af_array arr);
    af_err af_is_bool         (bool *result, const af_array arr);
    af_err af_eval(af_array in);
]]

funcs[31] = [[
    af_err af_get_data_ref_count(int *use_count, const af_array in);
]]


funcs[34] = [[
    af_err af_eval_multiple(const int num, af_array *arrays);
    af_err af_set_manual_eval_flag(bool flag);
    af_err af_get_manual_eval_flag(bool *flag);
    af_err af_is_sparse       (bool *result, const af_array arr);
]]

af.lib.cdef(funcs)

local Array = {}
Array.__index = Array

local c_dim4_t = af.ffi.c_dim4_t
local c_uint_t = af.ffi.c_uint_t
local c_array_p = af.ffi.c_array_p

local add_finalizer = function(arr_ptr)
   return ffi.gc(arr_ptr[0], af.clib.af_release_array)
end

Array.__init = function(data, dims, dtype, source)
   local self = setmetatable({}, Array)

   if data then
      assert(af.istable(data))
   end

   if dims then
      assert(af.istable(dims))
   end

   c_dims = c_dim4_t(dims or (data and {#data} or {}))
   c_ndims = c_uint_t(dims and #dims or (data and 1 or 0))

   nelement = 1
   for i = 1,tonumber(c_ndims) do
      nelement = nelement * c_dims[i - 1]
   end
   nelement = tonumber(nelement)

   local atype = dtype or af.dtype.f32
   local res = c_array_p()
   if not data then
      af.clib.af_create_handle(res, c_ndims, c_dims, atype)
   else
      c_data = ffi.new(af.dtype_names[atype + 1] .. '[?]', nelement, data)
      af.clib.af_create_array(res, c_data, c_ndims, c_dims, atype)
   end
   self.__arr = add_finalizer(res)
   return self
end

Array.__tostring = function(self)
   return 'arrayfire.Array\n'
end

Array.get = function(self)
   return self.__arr
end

setmetatable(
   Array,
   {
      __call = function(cls, ...)
         return cls.__init(...)
      end
   }
)

af.Array = Array
af.ffi.add_finalizer = add_finalizer
