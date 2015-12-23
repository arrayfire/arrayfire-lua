--- Move and reorder operations.

-- Standard library imports --
local type = type

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local CallWrap = array.CallWrap
local CheckError = array.CheckError
local IsArray = array.IsArray
local WrapArray = array.WrapArray

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/data.cpp

-- --
local Arrays = {} 

--
function M.Add (into)
	for k, v in pairs{
		--
		flip = function(in_arr, dim)
			return CallWrap("af_flip", in_arr:get(), dim)
		end,

		--
		join = function(dim, a1, a2, a3, a4)
			if IsArray(a3) then -- three or four arrays
				Arrays[1], Arrays[2], Arrays[3] = a1:get(), a2:get(), a3:get()

				if IsArray(a4) then -- four arrays
					Arrays[4] = a4:get()
				end

				local err, arr = af.af_join_many(dim, Arrays[4] and 4 or 3, Arrays)

				Arrays[1], Arrays[2], Arrays[3], Arrays[4] = nil

				CheckError(err) -- do after wiping Arrays

				return WrapArray(arr)
			else -- two arrays
				return CallWrap("af_join", dim, a1:get(), a2:get())
			end
		end,

		--
		tile = function(in_arr, a, b, c, d)
			if type(a) == "table" then -- a: dims
				a, b, c, d = a[1], a[2], a[3], a[4]
			else  -- a: x, b: y, c: z, d: w
				b, c, d = b or 1, c or 1, d or 1
			end

			return CallWrap("af_tile", in_arr:get(), a, b, c, d)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M