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
			return CallWrap(af.af_cast, arr:get(), af[atype])
		end,

		--
		copy = function(arr)
			return CallWrap(af.af_copy_array, arr:get())
		end,

		--
		dims = function(self, i)
			if i then
				return GetLib().getDims(self, Dims)[i + 1]
			else
				return GetLib().getDims(self)
			end
		end,

		--
		eval = function(arr)
			Call(af.af_eval, arr:get())
		end,

		--
		get = array_module.GetHandle,

		--
		H = function(self)
			return GetLib().transpose(self, true)
		end,

		--
		numdims = function(self)
			return GetLib().numDims(self)
		end,

		--
		set = array_module.SetHandle,

		--
		T = function(self)
			return GetLib().transpose(self)
		end
	} do
		meta[k] = v
	end
end

-- Export the module.
return M