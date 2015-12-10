--- Library entry point.

-- Standard library imports --
local error = error
local type = type

-- Modules --
local af = require("arrayfire")

-- Exports --
local M = {}

local CheckError, GetHandle, IsArray, NewArray

local Args = {}

local function Commutative (func)
	return function(a, b)
		--
		if not IsArray(a) then
			a, b = b, a
		end

		--
		local ha, hb = GetHandle(a)

		if IsArray(b) then
			hb = GetHandle(b)

		--
		else
			local btype = type(b)
			local ndims = CheckError(af.af_get_numdims(ha))

			Args[1], Args[2], Args[3], Args[4] = CheckError(af.af_get_dims(ha))				

			if btype == "table" then
				-- Complex...
			elseif btype == "number" then
				-- Argh... detect range, integer-ness, etc?

				hb = CheckError(af.af_constant(b, ndims, Args, af.f32))
			end

			b = "temp"
		end

		local arr = CheckError(func(ha, hb, true)) -- batch?

		if b == "temp" then
			CheckError(af.af_release_array(hb))
		end

		return NewArray(arr)
	end
end

function M.Add (array_module, meta)
	CheckError, GetHandle, IsArray, NewArray = array_module.CheckError, array_module.GetHandle, array_module.IsArray, array_module.NewArray

	MetaValue = meta.__metatable or true

	for k, v in pairs{
		__add = Commutative(af.af_add),
		__call = function(a, ...)
			-- operator()... ugh
		end,
		__mul = Commutative(af.af_mul),
		-- TODO: 5.3 supports bitwise ops...
	} do
		meta[k] = v
	end
end

-- Export the module.
return M