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

print("")
print("N.B. THIS IS A WIP")
print("")

AF.main(function()
	print("\n=== ArrayFire signed(s32) / unsigned(u32) Integer Example ===")
	local h_A = {1, 2, 4, -1, 2, 0, 4, 2, 3}
	local h_B = {2, 3, -5, 6, 0, 10, -12, 0, 1}
	local A = AF.array(3, 3, h_A)
	local B = AF.array(3, 3, h_B)
	print("--\nSub-refencing and Sub-assignment")
	AF.print("A", A)
--    af_print(A.col(0))
--    af_print(A.row(0))
--    A(0) = 11
--    A(1) = 100
	AF.print("A", A)
	AF.print("B", B)
--    A(1,span) = B(2,span);
	AF.print("A", A)
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
	AF.print("A", A)
	AF.print("A.T()", A:T())
	print("\n--Flip Vertically / Horizontally")
	AF.print("A", A)
	AF.print("flip(A,0)", AF.flip(A,0))
	AF.print("flip(A,1)", AF.flip(A,1))
	print("\n--Sum along columns")
	AF.print("A", A)
	AF.print("sum(A)", AF.sum(A))
	print("\n--Product along columns")
	AF.print("A", A)
	AF.print("product(A)", AF.product(A))
	print("\n--Minimum along columns")
	AF.print("A", A)
	AF.print("min(A)", AF.min(A))
	print("\n--Maximum along columns")
	AF.print("A", A)
	AF.print("max(A)", AF.max(A))
	print("\n--Minimum along columns with index")
	AF.print("A", A)
	local out, idx = AF.array(), AF.array()
	AF.min(out, idx, A)
	AF.print("out", out)
	AF.print("idx", idx)
end)