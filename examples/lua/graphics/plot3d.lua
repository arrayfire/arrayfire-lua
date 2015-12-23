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

local ITERATIONS = 200
local PRECISION = 1.0/ITERATIONS

AF.main(function()
	local myWindow = AF.Window(800, 800, "3D Line Plot example: ArrayFire")
	local t=0.1
	local Z = AF.array(AF.seq( 0.1, 10., PRECISION))
	local bounds = AF.constant(1, Z:dims())
	AF.EnvLoopUntil(function()
		local Y = AF.sin((Z*t) + t) / Z
		local X = AF.cos((Z*t) + t) / Z
		X = AF.max(AF.min(X, bounds),-bounds)
		Y = AF.max(AF.min(Y, bounds),-bounds)
		local Pts = AF.join(1, X, Y, Z)
		--Pts can be passed in as a matrix in the form n x 3, 3 x n
		--or in the flattened xyz-triplet array with size 3n x 1
		myWindow:plot3(Pts)
		t=t+0.01
	end, AF.wait_for_windows_close("until", myWindow))
end)