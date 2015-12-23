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
	local myWindow = AF.Window(512, 512, "Histogram example using ArrayFire")
	local imgWnd = AF.Window(480, 640, "Input Image")
	local img = AF.loadImage(AF.assets() .. "/examples/images/arrow.jpg", false)
	local hist_out = AF.histogram(img, 256, 0, 255)
	AF.EnvLoopWhile(function()
		myWindow:hist(hist_out, 0, 255)
		imgWnd:image(img:as("u8"))
	end, AF.wait_for_windows_close("while", myWindow, imgWnd))
end)