--- Array methods.

-- Modules --
local af = require("arrayfire_lib")

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/array.cpp

-- --
local Dims = {}

--
function M.Add (array_module, meta)
	local Call = array_module.Call
	local CallWrap = array_module.CallWrap
	local GetLib = array_module.GetLib

	--
	local function Get (name)
		name = "af_" .. name

		return function(arr)
			return Call(name, arr:get())
		end
	end

	-- --
	local SizeOf = {}

	for prefix, size in ("f32 f64 s32 u32 s64 u64 u8 b8 c32 c64 s16 u16"):gmatch "(%a)(%d+)" do
		local k = af[prefix .. size]

		if k then -- account for earlier versions
			SizeOf[k] = tonumber(size) / (prefix == "c" and 4 or 8) -- 8 bits to a byte; double complex types
		end
	end

	--
	for k, v in pairs{
		--
		as = function(arr, atype)
			return CallWrap("af_cast", arr:get(), af[atype])
		end,

		--
		bytes = function(arr)
			local ha = arr:get()
			local n, dtype = Call("af_get_elements", ha), Call("af_get_type", ha)

			return n * (SizeOf[dtype] or 4)
		end,

		--
		copy = function(arr)
			return CallWrap("af_copy_array", arr:get())
		end,

		--
		dims = function(arr, i)
			if i then
				return GetLib().getDims(arr, Dims)[i + 1]
			else
				return GetLib().getDims(arr)
			end
		end,

		--
		elements = Get("get_elements"),

		--
		eval = function(arr)
			Call("af_eval", arr:get())
		end,

		--
		get = array_module.GetHandle,

		--
		isbool = Get("is_bool"),

		--
		iscolumn = Get("is_column"),

		--
		iscomplex = Get("is_complex"),

		--
		isdouble = Get("is_double"),

		--
		isempty = Get("is_empty"),

		--
		isfloating = Get("is_floating"),

		--
		isinteger = Get("is_integer"),

		--
		isrealfloating = Get("is_real_floating"),

		--
		isrow = Get("is_row"),

		--
		isscalar = Get("is_scalar"),

		--
		issingle = Get("is_single"),

		--
		isvector = Get("is_vector"),

		--
		H = function(arr)
			return GetLib().transpose(arr, true)
		end,

		--
		numdims = function(arr)
			return GetLib().numDims(arr)
		end,

		--
		set = array_module.SetHandle,

		--
		T = function(arr)
			return GetLib().transpose(arr)
		end,

		type = Get("get_type")
	} do
		meta[k] = v
	end
end

-- Export the module.
return M