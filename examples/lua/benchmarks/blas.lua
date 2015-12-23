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

-- create a small wrapper to benchmark
local A -- populated before each timing
local function fn ()
    local B = AF.matmul(A, A) -- matrix multiply
    B:eval()               -- ensure evaluated
end

AF.main(function(argc, argv)
	local peak, stdout = 0, io.output()
    print("Benchmark N-by-N matrix multiply")
	for n = 128, 2048, 128 do
        AF.printf("%4d x %4d: ", n, n)
        A = AF.constant(1, n, n)
        local time = AF.timeit(fn) -- time in seconds
        local gflops = 2.0 * n^3 / (time * 1e9)
        if gflops > peak then
            peak = gflops
		end
        AF.printf(" %4.0f Gflops", gflops)
        stdout:flush()
    end
    if argc == 2 and argv[1]:sub(1, 1) == '-' then -- TODO: this has "finally" semantics in sample... worth implementing?
		AF.printf(" ### peak %g GFLOPS", peak)
	end
end)