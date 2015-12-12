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
local NewArray = array.NewArray
local IsArray = array.IsArray
local SetHandle = array.SetHandle

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/reduce.cpp

--
local function Bool (value)
	if value ~= nil then
		return not not value
	else
		return true
	end
end

--[[
local function Reduce (func)
	--
end
]]

--
local Dim = {}

local function GetFNSD (ha, dim)
	if dim < 0 then
		local ndims = CheckError(af.af_get_numdims(ha))

		Dim[1], Dim[2], Dim[3], Dim[4] = CheckError(af.af_get_dims(ha))

		for i = 1, 4 do
			if Dim[i] > 1 then
				return i - 1
			end
		end

		return 0
	else
		return dim
	end
end

local function ReduceNaN (name)
	local func, func_nan = af["af_" .. name], af["af_" .. name .. "_nan"]
	local func_all, func_nan_all = af["af_" .. name .. "_all"], af["af_" .. name .. "_nan_all"]

	return function(in_arr, dim, nanval)
		local all = type(in_arr) == "string"

		if all then
			-- TODO: Use type?
			in_arr = dim
		end

		local ha = GetHandle(in_arr)

		if all then
			if nanval then
				return CheckError(func_nan_all(ha, nanval))
			else
				return CheckError(func_all(ha))
			end	
		else
			local arr

			if nanval then
				arr = CheckError(func_nan(ha, dim, nanval))
			else
				arr = CheckError(func(ha, GetFNSD(ha, dim or -1)))
			end

			return NewArray(arr)
		end
	end
end

-- TODO: lost in macroland :P (probably missing some stuff)

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
		sort = Sort,
		product = ReduceNaN("product"),
		sum = ReduceNaN("sum")
	} do
		into[k] = v
	end
end

-- Export the module.
return M