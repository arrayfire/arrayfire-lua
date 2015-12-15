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

--
local ITERATIONS = 100
local PRECISION = 1.0/ITERATIONS

-- Modules --
local lib = require("lib.af_lib")

lib.main(function()
--[[
	af::Window myWindow(512, 512, "2D Plot example: ArrayFire");
	array Y;
	int sign = 1;
	array X = seq(-af::Pi, af::Pi, PRECISION);
	for (double val=-af::Pi; !myWindow.close(); ) {
		Y = sin(X);
		myWindow.plot(X, Y);
		X = X + PRECISION * float(sign);
		val += PRECISION * float(sign);
		if (val>af::Pi) {
			sign = -1;
		} else if (val<-af::Pi) {
			sign = 1;
		}
	}
]]
end)