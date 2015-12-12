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

-- create a small wrapper to benchmark
local A -- populated before each timing
local function fn ()
    local B = lib.fft2(A) -- matrix multiply
    B:eval()           -- ensure evaluated
end

lib.main(function()
    print("Benchmark N-by-N 2D fft")
	local stdout = io.output()
	for M = 7, 12 do
		local N = 2^(M - 1)
        lib.printf("%4d x %4d: ", N, N)
        A = lib.randu(N, N)
        local time = lib.timeit(fn) -- time in seconds
        local gflops = 10.0 * N * N * M / (time * 1e9)
        lib.printf(" %4.0f Gflops", gflops)
        stdout:flush()
	end
end)