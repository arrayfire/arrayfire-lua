--- Utility functions.

-- Standard library imports --
local print = print

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local Call = array.Call
local GetHandle = array.GetHandle

-- Exports --
local M = {}

--
function M.Add (into)
	for k, v in pairs{
		--
		print = function(exp, arr, precision)
			Call(af.af_print_array_gen, exp, GetHandle(arr), precision or 4) -- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/util.cpp
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