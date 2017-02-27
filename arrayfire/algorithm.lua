require('arrayfire.lib')
require('arrayfire.defines')
require('arrayfire.array')
local ffi  = require( "ffi" )

local funcs = {}

funcs[30] = [[
    af_err af_sum(af_array *out, const af_array in, const int dim);
    af_err af_product(af_array *out, const af_array in, const int dim);
    af_err af_min(af_array *out, const af_array in, const int dim);
    af_err af_max(af_array *out, const af_array in, const int dim);
    af_err af_all_true(af_array *out, const af_array in, const int dim);
    af_err af_any_true(af_array *out, const af_array in, const int dim);
    af_err af_count(af_array *out, const af_array in, const int dim);
    af_err af_sum_all(double *real, double *imag, const af_array in);
    af_err af_product_all(double *real, double *imag, const af_array in);
    af_err af_min_all(double *real, double *imag, const af_array in);
    af_err af_max_all(double *real, double *imag, const af_array in);
    af_err af_all_true_all(double *real, double *imag, const af_array in);
    af_err af_any_true_all(double *real, double *imag, const af_array in);
    af_err af_count_all(double *real, double *imag, const af_array in);
    af_err af_imin(af_array *out, af_array *idx, const af_array in, const int dim);
    af_err af_imax(af_array *out, af_array *idx, const af_array in, const int dim);
    af_err af_imin_all(double *real, double *imag, unsigned *idx, const af_array in);
    af_err af_imax_all(double *real, double *imag, unsigned *idx, const af_array in);
    af_err af_accum(af_array *out, const af_array in, const int dim);
    af_err af_where(af_array *idx, const af_array in);
    af_err af_diff1(af_array *out, const af_array in, const int dim);
    af_err af_diff2(af_array *out, const af_array in, const int dim);
    af_err af_sort(af_array *out, const af_array in, const unsigned dim, const bool isAscending);
    af_err af_sort_index(af_array *out, af_array *indices, const af_array in,
                               const unsigned dim, const bool isAscending);
    af_err af_sort_by_key(af_array *out_keys, af_array *out_values,
                                const af_array keys, const af_array values,
                                const unsigned dim, const bool isAscending);
    af_err af_set_unique(af_array *out, const af_array in, const bool is_sorted);
    af_err af_set_union(af_array *out, const af_array first, const af_array second, const bool is_unique);
    af_err af_set_intersect(af_array *out, const af_array first, const af_array second, const bool is_unique);
]]

funcs[31] = [[
    af_err af_sum_nan(af_array *out, const af_array in, const int dim, const double nanval);
    af_err af_product_nan(af_array *out, const af_array in, const int dim, const double nanval);
    af_err af_sum_nan_all(double *real, double *imag, const af_array in, const double nanval);
    af_err af_product_nan_all(double *real, double *imag, const af_array in, const double nanval);
]]

funcs[34] = [[
    af_err af_scan(af_array *out, const af_array in, const int dim, af_binary_op op, bool inclusive_scan);
    af_err af_scan_by_key(af_array *out, const af_array key, const af_array in, const int dim, af_binary_op op, bool inclusive_scan);
]]

af.lib.cdef(funcs)

local c_array_p = af.ffi.c_array_p
local init = af.Array.init
local c_ptr_t = af.ffi.c_ptr_t

local reduceFuncsWithNan = {'sum', 'product'}
for _, func in pairs(reduceFuncsWithNan) do
   af[func] = function(input, dim, nanval)
      if dim then
         local res = c_array_p()
         if nanval then
            af.clib['af_' .. func .. '_nan'](res, input:get(), dim, nanval)
         else
            af.clib['af_' .. func .. ''](res, input:get(), dim)
         end
         return init(res[0])
      else
         local res = c_ptr_t('double', 2)
         if nanval then
            af.clib['af_' .. func .. '_nan_all'](res + 0, res + 1, input:get(), nanval)
         else
            af.clib['af_' .. func .. '_all'](res + 0, res + 1, input:get())
         end
         return (res[1] == 0) and res[0] or {real = res[0], imag = res[1]}
      end
   end
end

local reduceFuncs = {
   min = 'min',
   max = 'max',
   anyTrue = 'any_true',
   allTrue = 'all_true',
   count = count,
}

for func,cfunc in pairs(reduceFuncs) do
   af[func] = function(input, dim)
      if dim then
         local res = c_array_p()
         af.clib['af_' .. cfunc .. ''](res, input:get(), dim)
         return init(res[0])
      else
         local res = c_ptr_t('double', 2)
         af.clib['af_' .. cfunc .. '_all'](res + 0, res + 1, input:get())
         return (res[1] == 0) and res[0] or {real = res[0], imag = res[1]}
      end
   end
end

local ireduceFuncs = {'imin', 'imax'}

for _,func in pairs(reduceFuncs) do
   af[func] = function(input, dim)
      if dim then
         local val = c_array_p()
         local idx = c_array_p()
         af.clib['af_' .. func .. ''](val, idx, input:get(), dim)
         return init(val[0]), init(idx[0])
      else
         local val = c_ptr_t('double', 2)
         local idx = c_ptr_t('unsigned int')
         af.clib['af_' .. func .. '_all'](val + 0, val + 1, idx + 0, input:get())
         if (val[1] == 0) then
            return val[0], idx[0]
         else
            return {real = val[0], imag = val[1]}, idx[0]
         end
      end
   end
end

local dimAlgos = {
   'accum',
   'diff1',
   'diff2',
}

for _, func in ipairs(dimAlgos) do
   af[func] = function(input, dim)
      local res = c_array_p()
      af.clib['af_' .. func](res, input:get(), dim or 0)
      return init(res[0])
   end
end

af.where = function(input)
   local res = c_array_p()
   af.clib.af_where(res, input:get());
   return init(res[0])
end

af.sort = function(input, dim, isAscending)
   local res = c_array_p()
   af.clib.af_sort(res, input:get(), dim or 0, isAscending == nil and true or isAscending)
   return init(res[0])
end

af.sortIndex = function(input, dim, isAscending)
   local val = c_array_p()
   local idx = c_array_p()
   af.clib.af_sort_index(val, idx, input:get(), dim or 0, isAscending == nil and true or isAscending)
   return init(val[0]), init(res[0])
end

af.sortByKey = function(inputKeys, inputVals, dim, isAscending)
   local outVals = c_array_p()
   local outKeys = c_array_p()
   af.clib.af_sort_by_key(outKeys, outVals,
                          inputKeys:get(), inputVals:get(),
                          dim or 0, isAscending == nil and true or isAscending)
   return init(outKeys[0]), init(outVals[0])
end

af.setUnique = function(input, isSorted)
   local res = c_array_p()
   af.clib.af_set_unique(res, input:get(), isSorted == nil and false or isSorted)
   return init(res[0])
end

local setOps = {
   setUnion = 'set_union',
   setIntersect = 'set_intersect',
}

for func, cfunc in pairs(setOps) do
   af[func] = function(first, second, isUnique)
      local res = c_array_p()
      af.clib['af_' .. cfunc](res, first:get(), second:get(), isUnique == nil and false or isUnique)
      return init(res[0])
   end
end

af.scan = function(input, dim, op, isInclusive)
   local res = c_array_p()
   af.clib.af_scan(res, input:get(), dim or 0,
                   op or af.binary_op.add, isInclusive == nil and true or isInclusive)
   return init(res[0])
end

af.scanByKey = function(inputKey, inputVal, dim, op, isInclusive)
   local res = c_array_p()
   af.clib.af_scan_by_key(res, inputKey:get(), inputVal:get(), dim or 0,
                          op or af.binary_op.add, isInclusive == nil and true or isInclusive)
   return init(res[0])
end
