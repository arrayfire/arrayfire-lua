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
local lib = require("arrayfire")

lib.main(function()
	-- 5x5 derivative with separable kernels
	local h_dx = {1. / 12, -8. / 12, 0, 8. / 12, -1. / 12} -- five point stencil
	local h_spread = {1. / 5, 1. / 5, 1. / 5, 1. / 5, 1. / 5}

	local function fail (left, right)
		return lib.max("f32", lib.abs(left - right)) > 1e-6
	end

	-- setup image and device copies of kernels
	local img = lib.randu(640, 480)
	-- device kernels
	local dx = lib.array(5, 1, h_dx) -- 5x1 kernel
	local spread = lib.array(1, 5, h_spread) -- 1x5 kernel
	local kernel = lib.matmul(dx, spread) -- 5x5 kernel
	local full_out, dsep_out
	lib.printf("full 2D convolution:         %.5f seconds", lib.timeit(function() full_out = lib.convolve2(img, kernel) end))
	lib.printf("separable, device pointers:  %.5f seconds", lib.timeit(function() dsep_out = lib.convolve(dx, spread, img) end))
	-- ensure values are all the same across versions
	assert(not fail(full_out, dsep_out), "full != dsep")
end)