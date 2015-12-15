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
	print("\n=== ArrayFire signed(s32) / unsigned(u32) Integer Example ===")
	local h_A = {1, 2, 4, -1, 2, 0, 4, 2, 3}
	local h_B = {2, 3, -5, 6, 0, 10, -12, 0, 1}
	local A = lib.array(3, 3, h_A)
	local B = lib.array(3, 3, h_B)
	print("--\nSub-refencing and Sub-assignment")
	lib.print("A", A)
--    af_print(A.col(0))
--    af_print(A.row(0))
--    A(0) = 11
--    A(1) = 100
	lib.print("A", A)
	lib.print("B", B)
--    A(1,span) = B(2,span);
	lib.print("A", A)
--[[
	print("--Bit-wise operations")
	-- Returns an array of type s32
	af_print(A & B)
	af_print(A | B)
	af_print(A ^ B)
	print("\n--Logical operations")
	-- Returns an array of type b8
	af_print(A && B)
	af_print(A || B)
]]
	print("\n--Transpose")
	lib.print("A", A)
	lib.print("A.T()", A:T())
	print("\n--Flip Vertically / Horizontally")
	lib.print("A", A)
	lib.print("flip(A,0)", lib.flip(A,0))
	lib.print("flip(A,1)", lib.flip(A,1))
	print("\n--Sum along columns")
	lib.print("A", A)
	lib.print("sum(A)", lib.sum(A))
	print("\n--Product along columns")
	lib.print("A", A)
	lib.print("product(A)", lib.product(A))
	print("\n--Minimum along columns")
	lib.print("A", A)
	lib.print("min(A)", lib.min(A))
	print("\n--Maximum along columns")
	lib.print("A", A)
	lib.print("max(A)", lib.max(A))
	print("\n--Minimum along columns with index")
	lib.print("A", A)
	local out, idx = lib.EmptyArray(), lib.EmptyArray()
	lib.min(out, idx, A)
	lib.print("out", out)
	lib.print("idx", idx)
end)