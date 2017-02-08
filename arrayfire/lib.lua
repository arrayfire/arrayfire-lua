-- Adapted from https://github.com/malkia/ufo/blob/master/ffi/OpenCL.lua
af = {}
local ffi  = require( "ffi" )

local AF_PATH = os.getenv("AF_PATH")

if not AF_PATH then
   error('AF_PATH not set')
end

local name, path = "af", AF_PATH .. "/lib/"
local is_32_bit = ffi.abi("32bit") -- used to typedef dim_t

if ArrayFireMode == "cl" or ArrayFireMode == "cuda" or ArrayFireMode == "cpu" then
	name = name .. ArrayFireMode
end

local lib_path = path .. "libaf"
af.clib  = ffi.load(ffi_ArrayFire_lib or lib_path )

-- Define some core requirements
if ffi.abi('32bit') then
   ffi.cdef[[typedef int dim_t;]]
else
   ffi.cdef[[typedef long long dim_t;]]
end
ffi.cdef[[
    typedef void * af_array;
    typedef int af_dtype;
    typedef int af_err;
    typedef int af_source;
    af_err af_get_version (int *, int *, int *);
]]

local major, minor, patch = ffi.new("int[1]"), ffi.new("int[1]"), ffi.new("int[1]")
af.clib.af_get_version(major, minor, patch)

af.lib = {}
af.lib.version = {major = major[0], minor = minor[0], patch = patch[0]}
af.lib.api = major[0] * 10 + minor[0]

af.lib.cdef = function(funcs)
   for k,v in pairs(funcs) do
      if af.lib.api >= k then
         ffi.cdef(v)
      end
   end
end
