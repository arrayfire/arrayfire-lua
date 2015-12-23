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

AF.main(function()
	print("Running QR InPlace")
	local in_arr = AF.randu(5, 8)
	AF.print("in", in_arr)
	local qin = in_arr:copy()
	local tau = AF.array()
	AF.qrInPlace(tau, qin)
	AF.print("qin", qin)
	AF.print("tau", tau)
	print("Running QR with Q and R factorization")
	local q, r = AF.array(), AF.array()
	AF.qr(q, r, tau, in_arr)
	AF.print("q", q)
	AF.print("r", r)
	AF.print("tau", tau)
end)