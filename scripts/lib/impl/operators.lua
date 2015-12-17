--- Operator overloads.

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local TwoArrays

-- Exports --
local M = {}

-- --
local Result

--
local function Binary (name, cmp)
	name = "af_" .. name

	return function(a, b)
		Result = nil

		local arr = TwoArrays(name, a, b, true) -- TODO: gforGet()

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
		__call = function(a, ...)
			-- operator()... ugh (proxy types, __index and __newindex shenanigans)
		end,
		__div = Binary("div"),
		__eq = Binary("eq", true),
		__lt = Binary("lt", true),
		__le = Binary("le", true),
		__mod = Binary("mod"),
		__mul = Binary("mul"),
		__pow = Binary("pow"),
		__sub = Binary("sub"),
		__unm = function(a)
			return 0 - a
		end,
		-- TODO: 5.3 supports bitwise ops...
	} do
		meta[k] = v
	end
end

-- Export the module.
return M