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

-- Standard library imports --
local pi = math.pi

-- Modules --
local AF = require("arrayfire")

--
local ITERATIONS = 100
local PRECISION = 1.0/ITERATIONS

AF.main(function()
	local myWindow = AF.Window(512, 512, "2D Plot example: ArrayFire")
	local Y
	local sign = 1
	local X = AF.array(AF.seq(-pi, pi, PRECISION))
	local val = -pi
	AF.EnvLoopWhile_Mode(function(env)
		Y = AF.sin(X)
		myWindow:plot(X, Y)
		X = env(X + PRECISION * sign)
		val = val + PRECISION * sign
		if val > pi then
			sign = -1
		elseif val < -pi then
			sign = 1
		end
	end, AF.wait_for_windows_close("while", myWindow), "normal_gc") -- evict old states every now and then
end)