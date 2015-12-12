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

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/data.cpp

-- --
local DimsAndType = {}

local function GetDimsAndType (...)
	--
	DimsAndType[1], DimsAndType[2], DimsAndType[3], DimsAndType[4], DimsAndType[5] = ...

	--
	local n, dtype = min(select("#", ...), 5)
	local last = DimsAndType[n]

	if type(last) == "string" then
		n, dtype = n - 1, af[last]
	end

	--
	local dims = DimsAndType

	if type(DimsAndType[1]) == "table" then
		dims, n = DimsAndType[1], 4
	end

	return n, dims, dtype
end

--
local function Constant (value, ...)
	local n, dims, dtype = GetDimsAndType(...)

	if type(value) == "table" then
		if dtype == "c32" or dtype == "c64" then
			local carr = CheckError(af.af_constant_complex(value.real, value.imag, n, dims, dtype))

			return NewArray(carr)
		else
			value = value.real -- TODO: syntax? (ditto above)
		end
	end

	local arr

	if dtype == "s64" or dtype == "u64" then
		local name = dtype == "s64" and "af_constant_long" or "af_constant_ulong"

		arr = CheckError(af[name](value, n, dims))
	else
		arr = CheckError(af.af_constant(value, n, dims, dtype or af.f32))
	end

	return NewArray(arr)
end

--
local function Rand (func)
	return function(...)
		local n, dims, dtype = GetDimsAndType(...)
		local arr = CheckError(func(n, dims, dtype or af.f32))

		return NewArray(arr)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		constant = Constant,
		randn = Rand(af.af_randn),
		randu = Rand(af.af_randu)
	} do
		into[k] = v
	end
end

-- Export the module.
return M