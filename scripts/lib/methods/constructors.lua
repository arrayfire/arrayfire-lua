--- Array constructors.

-- Standard library imports --
local min = math.min
local select = select
local type = type

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CheckError = array.CheckError
local NewArray = array.NewArray

-- Exports --
local M = {}

-- --
local Params = {}

--
local function Rand (func)
	return function(...)
		--
		Params[1], Params[2], Params[3], Params[4], Params[5] = ...

		--
		local n, dtype = min(select("#", ...), 5)

		if type(Params[n]) == "table" then
			n, dtype = n - 1, Params[n].type or dtype
		end

		--
		local args = Params

		if type(Params[1]) == "table" then
			args, n = Params[1], 4
		end

		--
		local arr = CheckError(func(n, args, dtype or af.f32))

		return NewArray(arr)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		randn = Rand(af.af_randn),
		randu = Rand(af.af_randu)
	} do
		into[k] = v
	end
end

-- Export the module.
return M