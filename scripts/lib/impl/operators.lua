--- Operator overloads.

-- Standard library imports --
local type = type

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local CheckError
local GetHandle
local IsArray
local NewArray

-- Exports --
local M = {}

local Args = {}

local function ToArray (value, hother)
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

local function Binary (func)
	return function(a, b)
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

		local arr = CheckError(func(ha, hb, true)) -- TODO: gforGet()

		if a == "temp" or b == "temp" then
			CheckError(af.af_release_array(a == "temp" and ha or hb))
		end

		return NewArray(arr)
	end
end

function M.Add (array_module, meta)
	-- Import these here since the array module is not yet registered.
	CheckError = array_module.CheckError
	GetHandle = array_module.GetHandle
	IsArray = array_module.IsArray
	NewArray = array_module.NewArray

	--
	for k, v in pairs{
		__add = Binary(af.af_add),
		__call = function(a, ...)
			-- operator()... ugh (proxy types, __index and __newindex shenanigans)
		end,
		__div = Binary(af.af_div),
		__eq = Binary(af.af_eq),
		__lt = Binary(af.af_lt),
		__le = Binary(af.af_le),
		__mod = Binary(af.af_mod),
		__mul = Binary(af.af_mul),
		__sub = Binary(af.af_sub),
	--	__unm = ...
		-- TODO: 5.3 supports bitwise ops...
	} do
		meta[k] = v
	end
end

-- Export the module.
return M