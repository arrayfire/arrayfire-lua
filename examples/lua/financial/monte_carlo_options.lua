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
local exp = math.exp
local sqrt = math.sqrt

-- Modules --
local AF = require("arrayfire")

-- Shorthands --
local Comp, WC = AF.CompareResult, AF.WrapConstant

local function monte_carlo_barrier (_, ty, use_barrier, N, K, t, vol, r, strike, steps, B)
    local payoff = AF.constant(0, N, 1, ty)
    local dt = t / (steps - 1)
    local s = AF.constant(strike, N, 1, ty)
    local randmat = AF.randn(N, steps - 1, ty);
    randmat = AF.exp((r - (vol * vol * 0.5)) * dt + vol * sqrt(dt) * randmat)
    local S = AF.product(AF.join(1, s, randmat), 1)
    if use_barrier then
        S = S * AF.allTrue(Comp(S < WC(B)), 1)
    end
    payoff = AF.max(0.0, S - K)
    local P = AF.mean(ty, payoff) * exp(-r * t)
    return P
end

local function monte_carlo_bench (ty, use_barrier, N)
    local steps = 180
    local stock_price = 100.0
    local maturity = 0.5
    local volatility = .30
    local rate = .01
    local strike = 100
    local barrier = 115.0
    AF.timer_start()
	-- loop 10 times in ephemeral environment (to clean up intermediate arrays)
	AF.EnvLoopN(10, monte_carlo_barrier, ty, use_barrier, N, stock_price, maturity, volatility, rate, strike, steps, barrier)
    return AF.timer_stop() / 10
end

AF.main(function()
	-- Warm up and caching
	monte_carlo_bench("f32", true, 1000)
	monte_carlo_bench("f32", true, 1000)
	for n = 10000, 100000, 10000 do
		AF.printf("Time for %7d paths - " ..
			   "vanilla method: %4.3f ms,  " ..
			   "barrier method: %4.3f ms", n,
			   1000 * monte_carlo_bench("f32", false, n),
			   1000 * monte_carlo_bench("f32", true, n))
	end
end)