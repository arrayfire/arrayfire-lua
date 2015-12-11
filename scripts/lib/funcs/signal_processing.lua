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

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/fft.cpp

--
local function FFT (in_arr, dim0)
	local arr = CheckError(af.af_fft(GetHandle(in_arr), 1, dim0 or 0))

	return NewArray(arr)
end

--
local function FFT2 (in_arr, dim0, dim1)
	local arr = CheckError(af.af_fft2(GetHandle(in_arr), 1, dim0 or 0, dim1 or 0))

	return NewArray(arr)
end

--
local function FFT3 (in_arr, dim0, dim1, dim2)
	local arr = CheckError(af.af_fft3(GetHandle(in_arr), 1, dim0 or 0, dim1 or 0, dim2 or 0))

	return NewArray(arr)
end

--
function M.Add (into)
	for k, v in pairs{
		fft = FFT,
		fft2 = FFT2,
		fft3 = FFT3
	} do
		into[k] = v
	end
end

-- Export the module.
return M