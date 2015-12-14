--[[
/*******************************************************
 * Copyright (c) 2014, ArrayFire
 * All rights reserved.
 *
 * This file is distributed under 3-clause BSD license.
 * The complete license agreement can be obtained at:
 * http://arrayfire.com/licenses/BSD-3-Clause
 ********************************************************/
]]
 
 -- Modules --
local lib = require("lib.af_lib")

lib.main(function()
	local n = 5
	local t = lib.randu(n, n)
	local in_arr = lib.matmulNT(t, t) + lib.identity(n, n) * n
	print("C")
	lib.print("in", in_arr)
	print("Running Cholesky InPlace")
	local cin = in_arr:copy()
	lib.print("cin", cin)
	print("Running Cholesky Out of place")
	local out_upper = lib.EmptyArray()
	local out_lower = lib.EmptyArray()
	lib.cholesky(out_upper, in_arr, true)
	lib.cholesky(out_lower, in_arr, false)
	lib.print("out_upper", out_upper)
	lib.print("out_lower", out_lower)
end)