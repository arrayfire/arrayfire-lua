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
	local in_arr = lib.randu(5, 8)
	lib.print("in", in_arr)
	local lin = in_arr:copy()
	print("Running LU InPlace")
	local pivot = lib.EmptyArray()
	lib.luInPlace(pivot, lin)
	lib.print("lin", lin)
	lib.print("pivot", pivot)
	print("Running LU with Upper Lower Factorization")
	local lower, upper = lib.EmptyArray(), lib.EmptyArray()
	lib.lu(lower, upper, pivot, in_arr)
	lib.print("lower", lower)
	lib.print("upper", upper)
	lib.print("pivot", pivot);
end)