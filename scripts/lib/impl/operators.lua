--- Operator overloads.

-- Standard library imports --
local type = type

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local CheckError
local GetConstant
local GetHandle
local IsConstant
local IsArray
local NewArray

-- Exports --
local M = {}

-- --
local Args = {}

--
local function ToArray (value, hother)
	if IsConstant(value) then
		value = GetConstant(value)
	end

	local btype = type(value)
	local ndims = CheckError(af.af_get_numdims(hother))

	Args[1], Args[2], Args[3], Args[4] = CheckError(af.af_get_dims(hother))				

	if btype == "table" then
		-- Complex...
	elseif btype == "number" then
		-- Argh... detect range, integer-ness, etc?

		return CheckError(af.af_constant(value, ndims, Args, af.f32))
	end
end

-- --
local Result

--
local function Binary (name, cmp)
	local func = af["af_" .. name]

	return function(a, b)
		Result = nil

		--
		local ha, hb

		if not IsArray(a) then
			hb = GetHandle(b)
			ha, a = ToArray(a, hb), "temp"
		elseif not IsArray(b) then
			ha = GetHandle(a)
			hb, b = ToArray(b, ha), "temp"
		else
			ha, hb = GetHandle(a), GetHandle(b)
		end

		--
		local arr = CheckError(func(ha, hb, true)) -- TODO: gforGet()

		if a == "temp" or b == "temp" then
			CheckError(af.af_release_array(a == "temp" and ha or hb))
		end

		--
		arr = NewArray(arr)

		if cmp then
			Result = arr
		else
			return arr
		end
	end
end

function M.Add (array_module, meta)
	-- Import these here since the array module is not yet registered.
	CheckError = array_module.CheckError
	GetConstant = array_module.GetConstant
	GetHandle = array_module.GetHandle
	IsConstant = array_module.IsConstant
	IsArray = array_module.IsArray
	NewArray = array_module.NewArray

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