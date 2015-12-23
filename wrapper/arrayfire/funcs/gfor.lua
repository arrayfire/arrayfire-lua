--- gfor() mechanism.

-- Standard library imports --
local assert = assert

-- Modules --
local array = require("impl.array")

-- Imports --
local GetLib = array.GetLib

-- Exports --
local M = {}

--- See also: https://github.com/arrayfire/arrayfire/blob/devel/include/af/gfor.h
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/gfor.cpp

-- --
local Status = false

--
local function AuxGfor (seq)
	Status = not Status

	if Status then
		return seq
	end
end

--
function M.Add (into)
	for k, v in pairs{
		--
		batchFunc = function(lhs, rhs, func)
			assert(not Status, "batchFunc can not be used inside GFOR") -- TODO: AF_ERR_ARG

			Status = true

			local res = func(lhs, rhs)

			Status = false

			return res
		end,

		--
		gfor = function(...)
			local lib = GetLib()

			return AuxGfor, lib.seq(lib.seq(...), true)
		end,

		--
		gforGet = function()
			return Status
		end,

		--
		gforSet = function(val)
			Status = not not val
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M