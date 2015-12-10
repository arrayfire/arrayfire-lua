--- Library entry point.

-- Modules --
require("lib.impl.array")

-- Exports --
local M = {}

for _, v in ipairs{
	"funcs.mathematics",
	"funcs.util",
	"methods.constructors"
} do
	require("lib." .. v).Add(M)
end

-- Export the module.
return M