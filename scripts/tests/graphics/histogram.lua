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
	local myWindow = lib.Window(512, 512, "Histogram example using ArrayFire")
	local imgWnd = lib.Window(480, 640, "Input Image")
	local img = lib.loadImage(lib.assets() .. "/examples/images/arrow.jpg", false)
	local hist_out = lib.histogram(img, 256, 0, 255)
	lib.EnvLoopUntil(function()
		myWindow:hist(hist_out, 0, 255)
		imgWnd:image(img:as("u8"))
	end, function()
		return not myWindow:close() and not imgWnd:close()
	end)
--[[
	while (!myWindow.close() && !imgWnd.close()) {
		myWindow.hist(hist_out, 0, 255);
		imgWnd.image(img.as(u8));
	}
]]
end)