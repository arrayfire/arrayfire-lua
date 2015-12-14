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
	print("Running QR InPlace")
	local in_arr = lib.randu(5, 8)
	lib.print("in", in_arr)
	local qin = in_arr:copy()
	local tau = lib.EmptyArray()
	lib.qrInPlace(tau, qin)
	lib.print("qin", qin)
	lib.print("tau", tau)
	print("Running QR with Q and R factorization")
	local q, r = lib.EmptyArray(), lib.EmptyArray()
	lib.qr(q, r, tau, in_arr)
	lib.print("q", q)
	lib.print("r", r)
	lib.print("tau", tau)
end)