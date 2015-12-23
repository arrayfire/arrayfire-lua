--- Mathematics functions.

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local CallWrap = array.CallWrap
local GetLib = array.GetLib
local IsArray = array.IsArray
local TwoArrays = array.TwoArrays

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/binary.cpp

--
local function Binary (name)
	return function(a, b)
		return TwoArrays(name, a, b, IsArray(a) and IsArray(b) and GetLib().gforGet())
	end
end

--
local function Unary (name)
	return function(in_arr)
		return CallWrap(name, in_arr:get())
	end
end

local function LoadFuncs (into, funcs, op)
	for _, v in ipairs(funcs) do
		local name = "af_" .. v

		into[v] = af[name] and op(name) -- ignore conditionally unavailable functions
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

	-- Use C++ name. (TODO: maxof, minof... re. vector)
	into.complex, into.cplx2 = into.cplx2
end

-- Export the module.
return M