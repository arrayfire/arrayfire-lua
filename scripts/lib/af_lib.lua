--- Library entry point.

-- Modules --
require("lib.impl.array")

-- Exports --
local M = {}

--
for _, v in ipairs{
	"funcs.linear_algebra",
	"funcs.mathematics",
	"funcs.signal_processing",
	"funcs.statistics",
	"funcs.util",
	"funcs.vector",
	"methods.constructors",
	"methods.device",
	"methods.move_reorder"
} do
	require("lib." .. v).Add(M)
end

-- Export the module.
return M