require('arrayfire.lib')
local ffi  = require( "ffi" )
ffi.cdef[[ int af_info(void); ]]

af.info = function()
   af.clib.af_info()
end
