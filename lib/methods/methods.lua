--- Array methods.

-- Modules --
local af = require("arrayfire")

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
	local function Wrap (name)
		name = "af_" .. name

		return function(arr)
			return CallWrap(name, arr:get())
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
		copy = Wrap("copy_array"),

		--
		dims = function(arr, i)
			if i then
				return GetLib().getDims(arr, Dims)[i + 1]
			else
				return GetLib().getDims(arr)
			end
		end,

		--
		elements = function(arr)
			return Call("af_get_elements", arr:get())
		end,

		--
		eval = Wrap("eval"),

		--
		get = array_module.GetHandle,

		--
		isbool = Wrap("is_bool"),

		--
		iscolumn = Wrap("is_column"),

		--
		iscomplex = Wrap("is_complex"),

		--
		isdouble = Wrap("is_double"),

		--
		isempty = Wrap("is_empty"),

		--
		isfloating = Wrap("is_floating"),

		--
		isinteger = Wrap("is_integer"),

		--
		isrealfloating = Wrap("is_real_floating"),

		--
		isrow = Wrap("is_row"),

		--
		isscalar = Wrap("is_scalar"),

		--
		issingle = Wrap("is_single"),

		--
		isvector = Wrap("is_vector"),

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

		type = Wrap("get_type")
	} do
		meta[k] = v
	end
end

-- Export the module.
return M