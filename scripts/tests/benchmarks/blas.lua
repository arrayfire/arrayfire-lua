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
    local B = lib.matmul(A, A) -- matrix multiply
    B:eval()               -- ensure evaluated
end

lib.main(function(argc, argv)
	local peak, stdout = 0, io.output()
    print("Benchmark N-by-N matrix multiply")
	for n = 128, 2048, 128 do
        lib.printf("%4d x %4d: ", n, n)
        A = lib.constant(1, n, n)
        local time = lib.timeit(fn) -- time in seconds
        local gflops = 2.0 * n^3 / (time * 1e9)
        if gflops > peak then
            peak = gflops
		end
        lib.printf(" %4.0f Gflops", gflops)
        stdout:flush()
    end
    if argc == 2 and argv[1]:sub(1, 1) == '-' then -- TODO: this has "finally" semantics in sample... worth implementing?
		lib.printf(" ### peak %g GFLOPS", peak)
	end
end)