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
	for k, v in pairs{
		--
		as = function(arr, atype)
			return CallWrap("af_cast", arr:get(), af[atype])
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
		elements = function(arr)
			return Call("af_get_elements", arr:get())
		end,

		--
		eval = function(arr)
			Call("af_eval", arr:get())
		end,

		--
		get = array_module.GetHandle,

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
		end
	} do
		meta[k] = v
	end
end

-- Export the module.
return M