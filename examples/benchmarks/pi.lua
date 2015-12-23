--[[
/*******************************************************
 * Copyright (c) 2014, ArrayFire
 * All rights reserved.
 *
 * This file is distributed under 3-clause BSD license.
 * The complete license agreement can be obtained at:
 * http://arrayfire.com/licenses/BSD-3-Clause
 ********************************************************/

   monte-carlo estimation of PI
   algorithm:
   - generate random (x,y) samples uniformly
   - count what percent fell inside (top quarter) of unit circle
]]

-- Standard library imports --
local random = math.random
local sqrt = math.sqrt

-- Modules --
local AF = require("arrayfire")

-- generate millions of random samples
local samples = 20e6

-- Shorthands --
local Comp, K = AF.CompareResult, AF.WrapConstant

--[[ Self-contained code to run host and device estimates of PI.  Note that
   each is generating its own random values, so the estimates of PI
   will differ. ]]
local function pi_device ()
    local x, y = AF.randu(samples, "f32"), AF.randu(samples, "f32")
    return 4.0 * AF.sum("f32", Comp(AF.sqrt(x * x + y * y) < K(1))) / samples
end

local function pi_host ()
	local count = 0
    for _ = 1, samples do
        local x = random()
        local y = random()
        if sqrt(x * x + y * y) < 1 then
            count = count + 1
		end
    end
    return 4.0 * count / samples
end

AF.main(function()
    AF.printf("device:  %.5f seconds to estimate  pi = %.5f", AF.timeit(pi_device), pi_device()) -- Lua fine with original signature
    AF.printf("  host:  %.5f seconds to estimate  pi = %.5f", AF.timeit(pi_host), pi_host())
end)