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
local AF = require("lib.af_lib")

AF.main(function()
	local h_buffer = {1, 4, 2, 5, 3, 6 }  -- host array
	local in_arr = AF.array(2, 3, h_buffer)                        -- copy host data to device
	local u
	local s_vec
	local vt
	AF.svd(u, s_vec, vt, in_arr)
	local s_mat = lib.diag(s_vec, 0, false)
--	local in_recon = AF.matmul(u, s_mat, vt(seq(2), span))
	AF.print("in", in_arr)
	AF.print("s_vec", s_vec)
	AF.print("u", u)
	AF.print("s_mat", s_mat)
	AF.print("vt", vt)
	AF.print("in_recon", in_recon)
end)