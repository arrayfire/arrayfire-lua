--- Windows and their methods.

-- Standard library imports --

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --

-- Exports --
local M = {}

--
function M.Add (into)
	for k, v in pairs{

	} do
		into[k] = v
	end
end

-- Export the module.
return M