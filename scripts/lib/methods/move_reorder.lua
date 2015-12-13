--- Move and reorder operations.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CallWrap = array.CallWrap
local CheckError = array.CheckError
local GetHandle = array.GetHandle
local IsArray = array.IsArray
local WrapArray = array.WrapArray

-- Exports --
local M = {}

-- --
local Arrays = {} 

--
local function Join (dim, a1, a2, a3, a4)
	if IsArray(a3) then -- three or arrays
		Arrays[1], Arrays[2], Arrays[3] = GetHandle(a1), GetHandle(a2), GetHandle(a3)

		if IsArray(a4) then -- four arrays
			Arrays[4] = GetHandle(a4)
		end

		local err, arr = af.af_join_many(dim, Arrays[4] and 4 or 3, Arrays)

		Arrays[1], Arrays[2], Arrays[3], Arrays[4] = nil

		CheckError(err) -- do after wiping Arrays

		return WrapArray(arr)
	else -- two arrays
		return CallWrap(af.af_join, dim, GetHandle(a1), GetHandle(a2))
	end
end

--
function M.Add (into)
	for k, v in pairs{
		join = Join
	} do
		into[k] = v
	end
end

-- Export the module.
return M