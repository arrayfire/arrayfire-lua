--[[
/*******************************************************
 * Copyright (c) 2014, ArrayFire
 * All rights reserved.
 *
 * This file is distributed under 3-clause BSD license.
 * The complete license agreement can be obtained at:
 * http://arrayfire.com/licenses/BSD-3-Clause
 ********************************************************/
 --]]
 
 --[[
#include <arrayfire.h>
#include <cstdio>
#include <cstdlib>
using namespace af;
int main(int argc, char *argv[])
{
]]
local af = require("arrayfire")
local lib = require("lib.af_lib")

local ok, err = pcall(function(device)
	-- Select a device and display arrayfire info
	af.af_set_device(device)
	af.af_info()
	print("A")
    print("Create a 5-by-3 matrix of random floats on the GPU")
	print("B")
	local A = lib.randu(5, 32, { type = af.f32 })
	print("C")
	lib.print("A", A)
    print("Element-wise arithmetic")
	local B = lib.sin(A) + 1.5
    lib.print("B", B)
    print("Negate the first three elements of second column")
--[[
        B(seq(0, 2), 1) = B(seq(0, 2), 1) * -1;
        af_print(B);
]]
--[[
    print("Fourier transform the result")
        array C = fft(B);
        af_print(C);
]]
--[[
    print("Grab last row")
        array c = C.row(end);
        af_print(c);
]]
--[[
    print("Create 2-by-3 matrix from host data")
        float d[] = { 1, 2, 3, 4, 5, 6 };
        array D(2, 3, d, afHost);
        af_print(D);
]]
--[[
    print("Copy last column onto first")
        D.col(0) = D.col(end);
        af_print(D);
]]
--[[
    -- Sort A
    print("Sort A and print sorted array and corresponding indices")
        array vals, inds;
        sort(vals, inds, A);
        af_print(vals);
        af_print(inds);
    }
	]]
--[[
    #ifdef WIN32 // pause in Windows
    if (!(argc == 2 && argv[1][0] == '-')) {
        printf("hit [enter]...");
        fflush(stdout);
        getchar();
    }
    #endif
    return 0;
]]
-- ^^^ Preserve this? Not impossible, but maybe can subsume into call site...
end, ... or 0) -- pass command line args

if not ok then
	print(err)
	-- throw
end