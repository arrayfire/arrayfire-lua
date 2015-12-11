--- Array methods.

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local CheckError
local GetHandle

-- Exports --
local M = {}

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
		eval = Eval
	} do
		meta[k] = v
	end
end

-- Export the module.
return M