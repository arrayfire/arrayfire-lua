--- Library entry point.

-- Modules --
require("impl.array")

-- Exports --
local M = {}

--
for _, v in ipairs{
	"funcs.image",
	"funcs.io",
	"funcs.linear_algebra",
	"funcs.mathematics",
	"funcs.signal_processing",
	"funcs.static",
	"funcs.statistics",
	"funcs.util",
	"funcs.vector",
	"funcs.gfor",
	"graphics.window",
	"methods.constructors",
	"methods.device",
	"methods.move_reorder",
	"misc.env_loop",
	"misc.program",
	"misc.imports"
} do
	require(v).Add(M)
end

-- Export the module.
return M