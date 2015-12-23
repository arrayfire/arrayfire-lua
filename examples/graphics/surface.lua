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
--[[
static const int ITERATIONS = 30;
static const float PRECISION = 1.0f/ITERATIONS;
	af::Window myWindow(800, 800, "3D Surface example: ArrayFire");
	array X = seq(-1, 1, PRECISION);
	array Y = seq(-1, 1, PRECISION);
	array Z = randn(X.dims(0), Y.dims(0));
	static float t=0;
	while(!myWindow.close()) {
		t+=0.07;
		//Z = sin(tile(X,1, Y.dims(0))*t + t) + cos(transpose(tile(Y, 1, X.dims(0)))*t + t);
		array x = tile(X,1, Y.dims(0));
		array y = transpose(tile(Y, 1, X.dims(0)));
		Z = 10*x*-abs(y) * cos(x*x*(y+t))+sin(y*(x+t))-1.5;
		myWindow.surface(X, Y, Z, NULL);
	}
]]
end)