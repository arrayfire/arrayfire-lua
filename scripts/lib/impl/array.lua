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

--- DOCME
-- @param item
-- @treturn boolean B
function M.IsArray (item)
	return getmetatable(item) == MetaValue
end

--- DOCME
-- @tparam af_err err
-- @param ...
-- @return ...
function M.CheckError (err, ...)
	if err ~= af.AF_SUCCESS then
		error(("%i"):format(err))
	end

	return ...
end

--- DOCME
-- @treturn LuaArray X
function M.EmptyArray ()
	return setmetatable({}, ArrayMethodsAndMetatable)
end

--- DOCME
-- @tparam LuaArray arr
-- @treturn ?|af_array|nil X
function M.GetHandle (arr)
	return arr.m_handle
end

--- DOCME
-- @tparam af_array arr
-- @treturn LuaArray X
function M.NewArray (arr)
	return setmetatable({ m_handle = arr }, ArrayMethodsAndMetatable)
end

--- DOCME
-- @tparam LuaArray arr
-- @tparam ?|af_array|nil handle
function M.SetHandle (arr, handle)
	local cur = arr.m_handle

	if cur ~= nil then
		af.af_release_array(cur)
	end

	arr.m_handle = handle
end

--
require("lib.impl.operators").Add(M, ArrayMethodsAndMetatable)

ArrayMethodsAndMetatable.__index = ArrayMethodsAndMetatable
ArrayMethodsAndMetatable.__metatable = MetaValue

-- Export the module.
return M