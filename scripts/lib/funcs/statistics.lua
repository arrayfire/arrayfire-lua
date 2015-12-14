--- Statistics functions.

-- Standard library imports --
local type = type

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CallArr = array.CallArr
local CallArr2 = array.CallArr2
local CallArr2Wrap = array.CallArr2Wrap
local GetFNSD = array.GetFNSD
local HandleDim = array.HandleDim
local IsArray = array.IsArray
local ToType = array.ToType

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/mean.cpp

local function Mean (a, b, c)
	if type(a) == "string" then -- a: type, b: in_arr, c: weights
		if IsArray(c) then
			return ToType(a, CallArr2(af.af_mean_all_weighted, b, c))
		else
			return ToType(a, CallArr(af.af_mean_all, b))
		end
	elseif IsArray(b) then -- a: arr, b: weights, c: dim
		return CallArr2Wrap(af.mean_weighted, a, b, GetFNSD(c))
	else -- a: arr, b: dim
		return HandleDim(af.af_mean, a, b)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		mean = Mean
	} do
		into[k] = v
	end
end

-- Export the module.
return M