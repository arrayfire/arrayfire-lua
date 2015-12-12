--- Array methods.

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local CheckError
local GetHandle

-- Forward declarations --
local Lib

-- Exports --
local M = {}

-- --
local Dims = {}

--
local function Eval (arr)
	CheckError(af.af_eval(GetHandle(arr)))
end

--
function M.Add (array_module, meta)
	-- Import these here since the array module is not yet registered.
	CheckError = array_module.CheckError
	GetHandle = array_module.GetHandle

	--
	for k, v in pairs{
		dims = function(self, i)
			Lib = Lib or require("lib.af_lib")

			return Lib.GetDims(self, Dims)[i + 1]
		end,
		eval = Eval
	} do
		meta[k] = v
	end
end

-- Export the module.
return M