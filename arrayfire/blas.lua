require('arrayfire.lib')
require('arrayfire.defines')
require('arrayfire.array')
local ffi  = require( "ffi" )

local funcs = {}

funcs[30] = [[
    af_err af_matmul( af_array *out ,
                      const af_array lhs, const af_array rhs,
                      const af_mat_prop optLhs, const af_mat_prop optRhs);
    af_err af_dot(af_array *out,
                  const af_array lhs, const af_array rhs,
                  const af_mat_prop optLhs, const af_mat_prop optRhs);
    af_err af_transpose(af_array *out, af_array in, const bool conjugate);
    af_err af_transpose_inplace(af_array in, const bool conjugate);
]]

funcs[35] = [[
    af_err af_dot_all(double *real, double *imag,
                      const af_array lhs, const af_array rhs,
                      const af_mat_prop optLhs, const af_mat_prop optRhs);
]]

af.lib.cdef(funcs)
local c_array_p = af.ffi.c_array_p
local init = af.Array.init
local c_ptr_t = af.ffi.c_ptr_t

af.matmul = function(lhs, rhs, lhsOpts, rhsOpts)
   local res = c_array_p()
   af.clib.af_matmul(res, lhs:get(), rhs:get(),
                     lhsOpts or af.mat_prop.none,
                     rhsOpts or af.mat_prop.none)
   return init(res[0])
end

af.dot = function(lhs, rhs, lhsOpts, rhsOpts)
   local res = c_array_p()
   af.clib.af_dot(res, lhs:get(), rhs:get(),
                  lhsOpts or af.mat_prop.none,
                  rhsOpts or af.mat_prop.none)
   return init(res[0])
end

af.transpose = function(input, inplace, conjugate)
   if inplace then
      af.clib.af_transpose_inplace(input:get(), conjugate == nil and false or true)
      return input
   else
      local res = c_array_p()
      af.clib.af_transpose(res, input:get(), conjugate == nil and false or true)
      return init(res[0])
   end
end

af.ctranspose = function(input, inplace)
   return af.transpose(input, inplace, true)
end

af.vecdot = function(lhs, rhs, lhsOpts, rhsOpts)
   local res = c_ptr_t('double', 2)
   af.clib.af_dot_all(res + 0, res + 1,
                      lhs:get(), rhs:get(),
                      lhsOpts or af.mat_prop.none,
                      rhsOpts or af.mat_prop.none)
   return (res[1] == 0) and res[0] or {real = res[0], imag = res[1]}
end
