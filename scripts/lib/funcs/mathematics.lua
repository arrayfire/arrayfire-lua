--- Library entry point.

-- Standard library imports --
local min = math.min
local select = select
local type = type

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CheckError = array.CheckError
local GetHandle = array.GetHandle
local NewArray = array.NewArray

-- Exports --
local M = {}

--
local function OneArg (func)
	return function(arr)
		local ah = GetHandle(arr)
		local arr = CheckError(func(ah))

		return NewArray(arr)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		sin = OneArg(af.af_sin)
		-- TODO: Others easy
	} do
		into[k] = v
	end
end

-- Export the module.
return M