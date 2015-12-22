--- Vector functions.

-- Standard library imports --
local assert = assert
local min = math.min
local select = select
local type = type

-- Modules --
local array = require("impl.array")

-- Imports --
local Call = array.Call
local CallWrap = array.CallWrap
local GetLib = array.GetLib
local HandleDim = array.HandleDim
local IsArray = array.IsArray
local ToType = array.ToType

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/reduce.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/where.cpp

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

	return name, name .. "_all"
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
			local r, i = Call(func_all, in_arr:get())

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
		if type(a) == "string" then -- a: type, b: in_arr[, c: "get_index"]
			if c == "get_index" then -- TODO: This is ugly and doesn't resemble the C++ interface... maybe a table as first argument, as compromise?
				local r, i, index = Call(ifunc_all, b:get())

				return ToType(a, r, i), index
			else
				return ToType(a, Call(func_all, b:get()))
			end
		elseif IsArray(c) then -- a: val, b: idx, c: arr, d: dim
			local out, idx = HandleDim(ifunc, c, d, "no_wrap")

			a:set(out)
			b:set(idx)
		elseif not b or c == "dim" then -- a: arr, b: dim[, c: "dim"] (TODO: Again, ugly but no obvious alternative... IsConstant()?)
			return HandleDim(func, a, b)
		else -- a: lhs, b: rhs
			return GetLib()[arith](a, b)
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
				r, i = Call(func_nan_all, in_arr:get(), nanval)
			else
				r, i = Call(func_all, in_arr:get())
			end

			return ToType(rtype, r, i)
		else
			if nanval then
				return CallWrap(func_nan, in_arr:get(), dim, nanval)
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
		diff1 = function(in_arr, dim)
			return CallWrap("af_diff1", in_arr:get(), dim)
		end,

		--
		diff2 = function(in_arr, dim)
			return CallWrap("af_diff2", in_arr:get(), dim)
		end,

		--
		max = ReduceMaxMin("max"),

		--
		min = ReduceMaxMin("min"),

		--
		product = ReduceNaN("product"),

		--
		sort = function(a, b, c, d, e, f)
			if IsArray(d) then -- four arrays
				local keys, values = Call("af_sort_by_key", c:get(), d:get(), e or 0, Bool(f))

				a:set(keys)
				b:set(values)
			elseif IsArray(c) then -- three arrays
				local arr, indices = Call("af_sort_index", c:get(), d or 0, Bool(e))

				a:set(arr)
				b:set(indices)
			else -- one array
				return CallWrap("af_sort", a:get(), b or 0, Bool(c))
			end
		end,

		--
		sum = ReduceNaN("sum"),

		--
		where = function(in_arr)
			assert(not GetLib().gforGet(), "WHERE can not be used inside GFOR") -- TODO: AF_ERR_RUNTIME);
	
			return CallWrap("af_where", in_arr:get())
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M