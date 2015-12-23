--- Operator overloads.

-- Modules --
local af = require("arrayfire_lib")

-- Forward declarations --
local CallWrap
local GetLib
local TwoArrays

-- Exports --
local M = {}

-- --
local Result

--
local function Binary (name, cmp)
	name = "af_" .. name

	return function(a, b)
-- TODO: disable for proxies?
		Result = nil

		local arr = TwoArrays(name, a, b, GetLib().gforGet())

		if cmp then
			Result = arr
		else
			return arr
		end
	end
end

--
function M.Add (array_module, meta)
	-- Import these here since the array module is not yet registered.
	GetLib = array_module.GetLib
	CallWrap = array_module.CallWrap
	TwoArrays = array_module.TwoArrays

	--
	function array_module.CompareResult () -- to be called as CompareResult(a < b), etc.
		local result = Result

		Result = nil

		return result
	end

	--
	for k, v in pairs{
		__add = Binary("add"),
		__band = Binary("bitand"),
		__bnot = function(a)
			return CallWrap("af_not", a:get())
		end,
		__bor = Binary("bitor"),
		__bxor = Binary("bitxor"),
		__call = function(a, ...)
			-- operator()... ugh (proxy types, __index and __newindex shenanigans)
		end,
		__div = Binary("div"),
		__eq = Binary("eq", true),
		__lt = Binary("lt", true),
		__le = Binary("le", true),
		__mod = Binary("rem"),
		__mul = Binary("mul"),
		__newindex = function(a, k, v)
			-- TODO: disable for non-proxies?

			if k == "_" then
				-- lvalue assign of v
			end
		end,
		__pow = Binary("pow"),
		__shl = Binary("bitshiftl"),
		__shr = Binary("bitshiftr"),
		__sub = Binary("sub"),
		__unm = function(a)
			return 0 - a
		end
	} do
		meta[k] = v
	end
end

-- Export the module.
return M