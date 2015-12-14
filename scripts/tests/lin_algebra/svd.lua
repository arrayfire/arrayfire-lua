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
	local h_buffer = {1, 4, 2, 5, 3, 6 }  -- host array
--	array in_arr(2, 3, h_buffer)                        -- copy host data to device
	local u
	local s_vec
	local vt
	lib.svd(u, s_vec, vt, in_arr)
--	array s_mat = diag(s_vec, 0, false)
--	local in_recon = lib.matmul(u, s_mat, vt(seq(2), span))
	lib.print("in", in_arr)
	lib.print("s_vec", s_vec)
	lib.print("u", u)
	lib.print("s_mat", s_mat)
	lib.print("vt", vt)
	lib.print("in_recon", in_recon)
end)