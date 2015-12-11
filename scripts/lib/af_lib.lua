--- Library entry point.

-- Modules --
require("lib.impl.array")

-- Exports --
local M = {}

--
for _, v in ipairs{
	"funcs.mathematics",
	"funcs.signal_processing",
	"funcs.util",
	"funcs.vector",
	"methods.constructors"
} do
	require("lib." .. v).Add(M)
end

-- Export the module.
return M