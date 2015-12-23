--- Signal processing functions.

-- Standard library imports --
local min = math.min

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local CallWrap = array.CallWrap
local IsArray = array.IsArray

-- Forward declarations --
local Convolve1
local Convolve2
local Convolve3

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/convolve.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/fft.cpp

--
local function Convolve (dim)
	local name = "af_convolve" .. dim

	return function(signal, filter, mode, domain)
		return CallWrap(name, signal:get(), filter:get(), af[mode or "AF_CONV_DEFAULT"], af[domain or "AF_CONV_AUTO"])
	end
end

--
function M.Add (into)
	for k, v in pairs{
		--
		convolve = function(a, b, c, d)
			if IsArray(c) then -- a: col_filter, b: row_filter, c: signal, d: mode
				return CallWrap("af_convolve2_sep", a:get(), b:get(), c:get(), af[mode or "AF_CONV_DEFAULT"])
			else -- a: signal, b: filter, c: mode, d: domain
				local n, func = min(a:numdims(), b:numdims())

				if n == 1 then
					func = Convolve1
				elseif n == 2 then
					func = Convolve2
				else
					func = Convolve3
				end

				return func(a, b, c, d)
			end
		end,

		--
		convolve1 = Convolve("1"),

		--
		convolve2 = Convolve("2"),

		--
		convolve3 = Convolve("3"),

		--
		fft = function(in_arr, dim0)
			return CallWrap("af_fft", in_arr:get(), 1, dim0 or 0)
		end,

		--
		fft2 = function(in_arr, dim0, dim1)
			return CallWrap("af_fft2", in_arr:get(), 1, dim0 or 0, dim1 or 0)
		end,

		--
		fft3 = function(in_arr, dim0, dim1, dim2)
			return CallWrap("af_fft3", in_arr:get(), 1, dim0 or 0, dim1 or 0, dim2 or 0)
		end
	} do
		into[k] = v
	end

	-- Alias (TODO: deprecated)
	local filter_alias = into.convolve

	function into.filter (signal, filter)
		return filter_alias(signal, filter)
	end
	
	--
	Convolve1 = into.convolve1
	Convolve2 = into.convolve2
	Convolve3 = into.convolve3
end

-- Export the module.
return M