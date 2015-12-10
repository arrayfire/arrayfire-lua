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

-- Exports --
local M = {}

--
local function Print (exp, array, precision)
	CheckError(af.af_print_array_gen(exp, GetHandle(array), precision or 5)) -- TODO: look up a good default
end

--
function M.Add (into)
	for k, v in pairs{
		print = Print
	} do
		into[k] = v
	end
end

-- Export the module.
return M