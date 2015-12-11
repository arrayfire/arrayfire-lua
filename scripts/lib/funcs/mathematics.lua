--- Mathematics functions.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CheckError = array.CheckError
local GetHandle = array.GetHandle
local NewArray = array.NewArray

-- Exports --
local M = {}

--
local function Binary (func)
	return function(a, b, batch)
		local ah, bh = GetHandle(a), GetHandle(b)
		local arr = CheckError(func(ah, bh, batch))

		return NewArray(arr)
	end
end

--
local function Unary (func)
	return function(in_arr)
		local ah = GetHandle(in_arr)
		local arr = CheckError(func(ah))

		return NewArray(arr)
	end
end

local function LoadFuncs (into, funcs, op)
	for _, v in ipairs(funcs) do
		local func = af["af_" .. v]

		into[v] = func and op(func) -- ignore conditionally unavailable functions
	end
end

--
function M.Add (into)
	LoadFuncs(into, {
		"abs",
		"acos",
		"acosh",
		"arg",
		"asin",
		"asinh",
		"atan",
		"atanh",
		"cbrt",
		"ceil",
		"conjg",
		"cos",
		"cosh",
		"cplx",
		"erf",
		"erfc",
		"exp",
		"expm1",
		"factorial",
		"floor",
		"imag",
		"lgamma",
		"log",
		"log10",
		"log1p",
		"not",
		"real",
		"round",
		"sigmoid",
		"sign",
		"sin",
		"sinh",
		"sqrt",
		"tan",
		"tanh",
		"trunc",
		"tgamma"
	}, Unary)
	
	LoadFuncs(into, {
		"add",
		"and",
		"atan2",
		"bitand",
		"bitor",
		"bitshiftl",
		"bitshiftr",
		"bitxor",
		"cplx2",
		"div",
		"eq",
		"ge",
		"gt",
		"hypot",
		"le",
		"lt",
		"maxof",
		"minof",
		"mod",
		"mul",
		"neq",
		"or",
		"pow",
		"rem",
		"root",
		"sub"
	}, Binary)
end

-- Export the module.
return M