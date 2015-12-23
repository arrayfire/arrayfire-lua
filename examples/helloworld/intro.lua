--[[
/*******************************************************
 * Copyright (c) 2014, ArrayFire
 * All rights reserved.
 *
 * This file is distributed under 3-clause BSD license.
 * The complete license agreement can be obtained at:
 * http://arrayfire.com/licenses/BSD-3-Clause
 ********************************************************/
 --]]

local AF = require("arrayfire")

AF.main(function()
      local x = AF.randu(5, "f32")
      AF.print("x", x)
      AF.print("min of x", AF.min(x))
      AF.print("max of x", AF.max(x))
end)
