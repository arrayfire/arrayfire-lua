--- Signal processing functions.

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
local function FFT (in_arr, dim0)
	local arr = CheckError(af.af_fft(GetHandle(in_arr), 1, dim0 or 0)) -- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/fft.cpp

	return NewArray(arr)
end

--
function M.Add (into)
	for k, v in pairs{
		fft = FFT
	} do
		into[k] = v
	end
end

-- Export the module.
return M