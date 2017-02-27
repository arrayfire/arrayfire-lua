require('arrayfire.lib')
require('arrayfire.defines')
require('arrayfire.dim4')
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
local c_ptr_t = af.ffi.c_ptr_t
local Dim4 = af.Dim4

function release_array(ptr)
   local res = af.clib.af_release_array(ptr)
   -- TODO: Error handling logic
end

local c_array_p = function(ptr)
   local arr_ptr = ffi.new('void *[1]', ptr)
   return arr_ptr
end

local init = function(ptr)
   local self = setmetatable({}, Array)
   self._ptr = ffi.gc(ptr, release_array)
   return self
end

Array.__init = function(data, dims, dtype, source)
   if data then
      assert(af.istable(data))
   end

   if dims then
      assert(af.istable(dims))
   end

   c_dims = c_dim4_t(dims or (data and {#data} or {}))
   c_ndims = c_uint_t(dims and #dims or (data and 1 or 0))

   count = 1
   for i = 1,tonumber(c_ndims) do
      count = count * c_dims[i - 1]
   end
   count = tonumber(count)

   local atype = dtype or af.dtype.f32
   local res = c_array_p()
   if not data then
      af.clib.af_create_handle(res, c_ndims, c_dims, atype)
   else
      c_data = c_ptr_t(af.dtype_names[atype + 1], count, data)
      af.clib.af_create_array(res, c_data, c_ndims, c_dims, atype)
   end
   return Array.init(res[0])
end

Array.__tostring = function(self)
   return 'arrayfire.Array\n'
end

Array.get = function(self)
   return self._ptr
end

-- TODO: implement Array.write

Array.copy = function(self)
   local res = c_array_p()
   af.clib.af_copy_array(res, self:get())
   return Array.init(res[0])
end

Array.softCopy = function(self)
   local res = c_array_p()
   af.clib.af_copy_array(res, self:get())
   return Array.init(res[0])
end

Array.elements = function(self)
   local res = c_ptr_t('dim_t')
   af.clib.af_get_elements(res, self:get())
   return tonumber(res[0])
end

Array.type = function(self)
   local res = c_ptr_t('af_dtype')
   af.clib.af_get_type(res, self:get())
   return tonumber(res[0])
end

Array.typeName = function(self)
   local res = c_ptr_t('af_dtype')
   af.clib.af_get_type(res, self:get())
   return af.dtype_names[tonumber(res[0])]
end

Array.dims = function(self)
   local res = c_dim4_t()
   af.clib.af_get_dims(res + 0, res + 1, res + 2, res + 3, self:get())
   return Dim4(tonumber(res[0]), tonumber(res[1]),
               tonumber(res[2]), tonumber(res[3]))
end

Array.numdims = function(self)
   local res = c_ptr_t('unsigned int')
   af.clib.af_get_numdims(res, self:get())
   return tonumber(res[0])
end

local funcs = {
   isEmpty        = 'is_empty',
   isScalar       = 'is_scalar',
   isRow          = 'is_row',
   isColumn       = 'is_column',
   isVector       = 'is_vector',
   isComplex      = 'is_complex',
   isReal         = 'is_real',
   isDouble       = 'is_double',
   isSingle       = 'is_single',
   isRealFloating = 'is_realfloating',
   isFloating     = 'is_floating',
   isInteger      = 'is_integer',
   isBool         = 'is_bool',
}

for name, cname in pairs(funcs) do
   Array[name] = function(self)
      local res = c_ptr_t('bool')
      af.clib['af_' .. cname](res, self:get())
      return res[0]
   end
end

Array.eval = function(self)
   af.clib.af_eval(self:get())
end

-- Useful aliases
Array.ndims = Array.numdims
Array.nElement = Array.elements
Array.clone = Array.copy

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
af.ffi.c_array_p = c_array_p
af.Array.init = init
