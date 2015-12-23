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
local AF = require("arrayfire")

AF.main(function()
	local n = 5
	local t = AF.randu(n, n)
	local in_arr = AF.matmulNT(t, t) + AF.identity(n, n) * n
	print("C")
	AF.print("in", in_arr)
	print("Running Cholesky InPlace")
	local cin = in_arr:copy()
	AF.print("cin", cin)
	print("Running Cholesky Out of place")
	local out_upper = AF.array()
	local out_lower = AF.array()
	AF.cholesky(out_upper, in_arr, true)
	AF.cholesky(out_lower, in_arr, false)
	AF.print("out_upper", out_upper)
	AF.print("out_lower", out_lower)
end)