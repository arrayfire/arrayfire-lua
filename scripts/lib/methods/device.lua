--- Device functions.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local Call

-- Exports --
local M = {}

--
local function Info ()
	Call(af.af_info)
end

--
local function SetDevice (device)
	Call(af.af_set_device, device)
end

--
local function Sync (device)
	Call(af.af_sync, device or -1)
end

--
function M.Add (into)
	--
	for k, v in pairs{
		info = Info,
		setDevice = SetDevice,
		sync = Sync
	} do
		into[k] = v
	end
end

-- Export the module.
return M