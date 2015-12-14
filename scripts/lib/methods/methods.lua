--- Array methods.

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local CallArr
local CallArrWrap

-- Forward declarations --
local Lib

-- Exports --
local M = {}

-- --
local Dims = {}

--
local function Copy (arr)
	return CallArrWrap(af.af_copy_array, arr)
end

--
local function Eval (arr)
	CallArr(af.af_eval, arr)
end

--
function M.Add (array_module, meta)
	-- Import these here since the array module is not yet registered.
	CallArr = array_module.CallArr
	CallArrWrap = array_module.CallArrWrap

	--
	for k, v in pairs{
		copy = Copy,
		dims = function(self, i)
			Lib = Lib or require("lib.af_lib")

			if i then
				return Lib.getDims(self, Dims)[i + 1]
			else
				return Lib.getDims(self)
			end
		end,
		eval = Eval
	} do
		meta[k] = v
	end
end

-- Export the module.
return M