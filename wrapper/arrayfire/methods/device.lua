--- Device functions.

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local Call = array.Call

-- Exports --
local M = {}

--
function M.Add (into)
	--
	for k, v in pairs{
		--
		info = function()
			Call("af_info")
		end,

		--
		setDevice = function(device)
			Call("af_set_device", device)
		end,

		--
		sync = function(device)
			Call("af_sync", device or -1)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M