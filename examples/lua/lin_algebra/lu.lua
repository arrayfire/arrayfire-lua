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
	local in_arr = AF.randu(5, 8)
	AF.print("in", in_arr)
	local lin = in_arr:copy()
	print("Running LU InPlace")
	local pivot = AF.array()
	AF.luInPlace(pivot, lin)
	AF.print("lin", lin)
	AF.print("pivot", pivot)
	print("Running LU with Upper Lower Factorization")
	local lower, upper = AF.array(), AF.array()
	AF.lu(lower, upper, pivot, in_arr)
	AF.print("lower", lower)
	AF.print("upper", upper)
	AF.print("pivot", pivot);
end)