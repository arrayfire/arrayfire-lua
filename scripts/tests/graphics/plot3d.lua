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
--[[
static const int ITERATIONS = 200;
static const float PRECISION = 1.0f/ITERATIONS;
	af::Window myWindow(800, 800, "3D Line Plot example: ArrayFire");
	static float t=0.1;
	array Z = seq( 0.1f, 10.f, PRECISION);
	array bounds = constant(1, Z.dims());
	do{
		array Y = sin((Z*t) + t) / Z;
		array X = cos((Z*t) + t) / Z;
		X = max(min(X, bounds),-bounds);
		Y = max(min(Y, bounds),-bounds);
		array Pts = join(1, X, Y, Z);
		//Pts can be passed in as a matrix in the form n x 3, 3 x n
		//or in the flattened xyz-triplet array with size 3n x 1
		myWindow.plot3(Pts);
		t+=0.01;
	} while(!myWindow.close());
]]
end)