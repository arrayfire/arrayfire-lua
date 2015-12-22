--- Statistics functions.

-- Standard library imports --
local type = type

-- Modules --
local array = require("impl.array")

-- Imports --
local Call = array.Call
local CallWrap = array.CallWrap
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
			return ToType(a, Call("af_mean_all_weighted", b:get(), c:get()))
		else
			return ToType(a, Call("af_mean_all", b:get()))
		end
	elseif IsArray(b) then -- a: arr, b: weights, c: dim
		return CallWrap("mean_weighted", a:get(), b, GetFNSD(c))
	else -- a: arr, b: dim
		return HandleDim("af_mean", a, b)
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