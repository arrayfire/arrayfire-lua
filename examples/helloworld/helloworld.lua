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

-- Modules --
local AF = require("arrayfire")

AF.main(function()
    print("Create a 5-by-3 matrix of random floats on the GPU")
	local A = AF.randu(5, 32, "f32")
	AF.print("A", A)
    print("Element-wise arithmetic")
	local B = AF.sin(A) + 1.5
    AF.print("B", B)
--[[
    print("Negate the first three elements of second column")
        B(seq(0, 2), 1) = B(seq(0, 2), 1) * -1;
        af_print(B);
]]
    print("Fourier transform the result")
    local C = AF.fft(B)
    AF.print("C", C)
--[[
    print("Grab last row")
        array c = C.row(end);
        af_print(c);
]]
    print("Create 2-by-3 matrix from host data")
    local d = { 1, 2, 3, 4, 5, 6 }
    local D = AF.array(2, 3, d, "afHost")
    AF.print("D", D)
--[[
    print("Copy last column onto first")
        D.col(0) = D.col(end);
        af_print(D);
]]
    -- Sort A
    print("Sort A and print sorted array and corresponding indices")
    local vals, inds = AF.array(), AF.array()
    AF.sort(vals, inds, A)
    AF.print("vals", vals)
    AF.print("inds", inds)
end)