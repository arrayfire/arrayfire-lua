--- Static companions of array methods.

-- Modules --
local array = require("impl.array")

-- Imports --
local Call = array.Call
local IsArray = array.IsArray

-- Exports --
local M = {}

--
local function Eval1 (a, b, c, d, e, f)
	a:eval()

	if b then
		return Eval1(b, c, d, e, f)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		--
		eval = function(a, b, c, d, e, f)
			if IsArray(f) then
				Eval1(a, b, c, d, e, f)
			elseif IsArray(e) then
				Eval1(a, b, c, d, e)
			elseif IsArray(d) then
				Eval1(a, b, c, d)
			elseif IsArray(c) then
				Eval1(a, b, c)
			elseif IsArray(b) then
				Eval1(a, b)
			else
				a:eval()

				return a
			end
		end,

		--
		getDims = function(arr, out)
			out = out or {}

			out[1], out[2], out[3], out[4] = Call("af_get_dims", arr:get())

			return out
		end,

		--
		numDims = function(arr)
			return Call("af_get_numdims", arr:get())
		end,
	} do
		into[k] = v
	end
end

-- Export the module.
return M