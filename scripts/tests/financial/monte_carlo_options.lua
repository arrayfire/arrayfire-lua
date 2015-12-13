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
local lib = require("lib.af_lib")

-- Shorthands --
local Comp, WC = lib.CompareResult, lib.WrapConstant

local function monte_carlo_barrier (_, ty, use_barrier, N, K, t, vol, r, strike, steps, B)
    local payoff = lib.constant(0, N, 1, ty)
    local dt = t / (steps - 1)
    local s = lib.constant(strike, N, 1, ty)
    local randmat = lib.randn(N, steps - 1, ty);
    randmat = lib.exp((r - (vol * vol * 0.5)) * dt + vol * sqrt(dt) * randmat)
    local S = lib.product(lib.join(1, s, randmat), 1)
    if use_barrier then
        S = S * lib.allTrue(Comp(S < WC(B)), 1)
    end
    payoff = lib.max(0.0, S - K, "arith")
    local P = lib.mean(ty, payoff) * exp(-r * t)
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
    lib.timer_start()
	-- loop 10 times in ephemeral environment (to clean up intermediate arrays)
	lib.EnvLoopN(10, monte_carlo_barrier, ty, use_barrier, N, stock_price, maturity, volatility, rate, strike, steps, barrier)
    return lib.timer_stop() / 10
end

lib.main(function()
	-- Warm up and caching
	monte_carlo_bench("f32", true, 1000)
	monte_carlo_bench("f32", true, 1000)
	for n = 10000, 100000, 10000 do
		lib.printf("Time for %7d paths - " ..
			   "vanilla method: %4.3f ms,  " ..
			   "barrier method: %4.3f ms", n,
			   1000 * monte_carlo_bench("f32", false, n),
			   1000 * monte_carlo_bench("f32", true, n))
	end
end)