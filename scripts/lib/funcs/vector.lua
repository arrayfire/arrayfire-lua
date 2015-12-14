--- Vector functions.

-- Standard library imports --
local min = math.min
local select = select
local type = type

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CallArr = array.CallArr
local CallArr2 = array.CallArr2
local CallArrWrap = array.CallArrWrap
local HandleDim = array.HandleDim
local IsArray = array.IsArray
local SetHandle = array.SetHandle
local ToType = array.ToType

-- Forward declarations --
local Lib

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

--
local function Funcs (name, prefix)
	name = (prefix or "af_") .. name

	return af[name], af[name .. "_all"]
end

--
local function Reduce (name)
	local func, func_all = Funcs(name)

	return function(in_arr, dim)
		local rtype

		if type(in_arr) == "string" then
			rtype, in_arr = in_arr, dim
		end

		if rtype then
			local r, i = CallArr(func_all, in_arr)

			return ToType(rtype, r, i)
		else
			return HandleDim(func, in_arr, dim)
		end
	end
end

--
local function ReduceMaxMin (name)
	local func, func_all = Funcs(name)
	local ifunc, ifunc_all = Funcs(name, "af_i")
	local arith = name .. "of"

	return function(a, b, c, d)
		if c == "arith" then -- a: lhs, b: rhs
			Lib = Lib or require("lib.af_lib")

			return Lib[arith](a, b)
		elseif type(a) == "string" then -- a: type, b: in_arr, c: get_index
			if c then
				local r, i, index = CallArr(ifunc_all, b)

				return ToType(a, r, i), index
			else
				return ToType(a, CallArr(func_all, b))
			end
		elseif IsArray(c) then -- a: val, b: idx, c: arr, d: dim
			local out, idx = HandleDim(ifunc, c, d, "no_wrap")

			SetHandle(a, out)
			SetHandle(b, idx)
		else -- a: arr, b: dim
			return HandleDim(func, a, b)
		end
	end
end

--
local function ReduceNaN (name)
	local func, func_all = Funcs(name)
	local func_nan, func_nan_all = Funcs(name .. "_nan")

	return function(in_arr, dim, nanval)
		local rtype

		if type(in_arr) == "string" then
			rtype, in_arr = in_arr, dim
		end

		if rtype then
			local r, i

			if nanval then
				r, i = CallArr(func_nan_all, in_arr, nanval)
			else
				r, i = CallArr(func_all, in_arr)
			end

			return ToType(rtype, r, i)
		else
			if nanval then
				return CallArrWrap(func_nan, in_arr, dim, nanval)
			else
				return HandleDim(func, in_arr, dim)
			end
		end
	end
end

-- TODO: lost in macroland :P (probably missing some stuff)

--
local AllTrue, AnyTrue = Reduce("all_true"), Reduce("any_true")

--
function M.Add (into)
	for k, v in pairs{
		--
		alltrue = AllTrue, allTrue = AllTrue,

		--
		anytrue = AnyTrue, anyTrue = AnyTrue,

		--
		count = Reduce("count"),

		--
		max = ReduceMaxMin("max"),

		--
		min = ReduceMaxMin("min"),

		--
		product = ReduceNaN("product"),

		--
		sort = function(a, b, c, d, e, f)
			if IsArray(d) then -- four arrays
				local keys, values = CallArr2(af.af_sort_by_key, c, d, e or 0, Bool(f))

				SetHandle(a, keys)
				SetHandle(b, values)
			elseif IsArray(c) then -- three arrays
				local arr, indices = CallArr(af.af_sort_index, c, d or 0, Bool(e))

				SetHandle(a, arr)
				SetHandle(b, indices)
			else -- one array
				return CallArrWrap(af.af_sort, a, b or 0, Bool(c))
			end
		end,

		--
		sum = ReduceNaN("sum")
	} do
		into[k] = v
	end
end

-- Export the module.
return M