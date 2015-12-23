--- Utility functions.

-- Standard library imports --
local print = print

-- Modules --
local array = require("impl.array")

-- Imports --
local Call = array.Call

-- Exports --
local M = {}

--
function M.Add (into)
	for k, v in pairs{
		--
		print = function(exp, arr, precision)
			Call("af_print_array_gen", exp, arr:get(), precision or 4) -- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/util.cpp
		end,

		--
		printf = function(s, ...)
			print(s:format(...))
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M