require('arrayfire.lib')
local ffi  = require( "ffi" )

local funcs = {}

funcs[30] = [[
    af_err af_print_array(af_array arr);
]]

funcs[31] = [[
    af_err af_print_array_gen(const char *exp, const af_array arr, const int precision);
    af_err af_save_array(int *index, const char* key, const af_array arr,
                      const char *filename, const bool append);
    af_err af_read_array_index(af_array *out, const char *filename, const unsigned index);
    af_err af_read_array_key(af_array *out, const char *filename, const char* key);
    af_err af_read_array_key_check(int *index, const char *filename, const char* key);
    af_err af_array_to_string(char **output, const char *exp, const af_array arr,
                           const int precision, const bool transpose);
]]

funcs[33] = [[
    const char *af_get_revision();
]]

funcs[34] = [[
    af_err af_get_size_of(size_t *size, af_dtype type);
]]

af.lib.cdef(funcs)

af.print = function(arr)
   if type(arr) == 'table' and arr.isArray then
      af.clib.af_print_array_gen(ffi.cast("char *", "ArrayFire Array"), arr:get(), 4)
   else
      print(arr)
   end
end
