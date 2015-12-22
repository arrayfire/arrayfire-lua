--- Public imports from implementation functions.

-- Modules --
local array = require("impl.array")

-- Exports --
local M = {}

--
function M.Add (into)
	for k, v in pairs{
		CallWithEnvironment = array.CallWithEnvironment,
		CallWithEnvironment_Args = array.CallWithEnvironment_Args,
		CompareResult = array.CompareResult,
		WrapConstant = array.WrapConstant
	} do
		into[k] = v
	end
end

-- Export the module.
return M