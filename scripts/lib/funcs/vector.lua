--- Vector functions.

-- Standard library imports --
local min = math.min
local select = select
local type = type

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CheckError = array.CheckError
local GetHandle = array.GetHandle
local IsArray = array.IsArray
local SetHandle = array.SetHandle

-- Exports --
local M = {}

--
local function Bool (value)
	if value ~= nil then
		return not not value
	else
		return true
	end
end

--
local function Sort (a, b, c, d, e, f)
	if IsArray(d) then
		local keys, values = CheckError(af.af_sort_by_key(GetHandle(c), GetHandle(d), e or 0, Bool(f)))

		SetHandle(a, keys)
		SetHandle(b, values)
	elseif IsArray(c) then
	    local arr, indices = CheckError(af.af_sort_index(GetHandle(c), d or 0, Bool(e)))

		SetHandle(a, arr)
		SetHandle(b, indices)
	else
		local arr = CheckError(af.af_sort(GetHandle(a), b or 0, Bool(c)))

		return NewArray(arr)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		sort = Sort
	} do
		into[k] = v
	end
end

-- Export the module.
return M