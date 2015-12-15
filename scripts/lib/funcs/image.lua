--- Image-related functions.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local Call = array.Call

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/histogram.cpp

--
local function HistEqual (in_arr, hist)
	return CallWrap(af.af_hist_equal, in_arr:get(), hist:get())
end

--
function M.Add (into)
	for k, v in pairs{
		--
		histEqual = HistEqual, histequal = HistEqual,

		--
		histogram = function(in_arr, nbins, minval, maxval)
			if not minval then
				local lib = into -- possibly delayed load

				minval, maxval = lib.min("f64", in_arr), lib.max("f64", in_arr)
			end

			return CallWrap(in_arr:get(), nbins, minval, maxval)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M