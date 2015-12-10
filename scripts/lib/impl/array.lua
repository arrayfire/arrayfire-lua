--- Core array module.

-- Standard library imports --
local error = error
local getmetatable = getmetatable
local setmetatable = setmetatable

-- Modules --
local af = require("arrayfire")

-- Exports --
local M = {}

-- --
local ArrayMethodsAndMetatable = {}

local MetaValue = {}

function M.IsArray (item)
	return getmetatable(item) == MetaValue
end

function M.CheckError (err, ...)
	if err ~= af.AF_SUCCESS then
		error(("%i"):format(err))
	end

	return ...
end

function M.GetHandle (arr)
	return arr.m_handle
end

function M.NewArray (arr)
	return setmetatable({ m_handle = arr }, ArrayMethodsAndMetatable)
end

require("lib.impl.operators").Add(M, ArrayMethodsAndMetatable)

ArrayMethodsAndMetatable.__index = ArrayMethodsAndMetatable
ArrayMethodsAndMetatable.__metatable = MetaValue

-- Export the module.
return M