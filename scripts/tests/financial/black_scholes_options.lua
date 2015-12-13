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

-- --
local sqrt2 = math.sqrt(2)

-- Shorthands --
local Comp, K = lib.CompareResult, lib.WrapConstant

local function cnd (x)
    local temp = Comp(x > K(0))
    local y = temp * (0.5 + lib.erf(x/sqrt2)/2) + (1-temp) * (0.5 - lib.erf((-x)/sqrt2)/2)
    return y
end

local function black_scholes (S, X, R, V, T)
    -- This function computes the call and put option prices based on
    -- Black-Scholes Model
    -- S = Underlying stock price
    -- X = Strike Price
    -- R = Risk free rate of interest
    -- V = Volatility
    -- T = Time to maturity
    local d1 = lib.log(S / X)
    d1 = d1 + (R + (V*V)*0.5) * T
    d1 = d1 / (V*lib.sqrt(T));
    local d2 = d1 - (V*lib.sqrt(T))
    local cnd_d1 = cnd(d1)
    local cnd_d2 = cnd(d2)
    local C = S * cnd_d1  - (X * lib.exp((-R)*T) * cnd_d2)
    local P = X * lib.exp((-R)*T) * (1 - cnd_d2) - (S * (1 - cnd_d1))
	return C, P
end
lib.main(function()
	print("** ArrayFire Black-Scholes Example **\n"
		   "**          by AccelerEyes         **\n")
--[[
	array GC1(4000, 1, C1);
	array GC2(4000, 1, C2);
	array GC3(4000, 1, C3);
	array GC4(4000, 1, C4);
	array GC5(4000, 1, C5);
]]
	-- Compile kernels
	-- Create GPU copies of the data
--[[
	array Sg = GC1;
	array Xg = GC2;
	array Rg = GC3;
	array Vg = GC4;
	array Tg = GC5;
	array Cg, Pg;
]]
	 Warm up black scholes example
	black_scholes(Sg,Xg,Rg,Vg,Tg)
--  eval(Cg, Pg)
	print("Warming up done")
	af::sync()
	local iter = 5
	for n = 50, 500, 50 do
		-- Create GPU copies of the data
		Sg = tile(GC1, n, 1)
		Xg = tile(GC2, n, 1)
		Rg = tile(GC3, n, 1)
		Vg = tile(GC4, n, 1)
		Tg = tile(GC5, n, 1)
		local dims = Xg:dims()
		lib.printf("Input Data Size = %d x %d", dims[1], dims[2])
		-- Force compute on the GPU
		lib.sync()
		lib.timer_start()
		for _ = 1, iter do
			Cg, Pg = black_scholes(Sg,Xg,Rg,Vg,Tg);
--			eval(Cg,Pg)
		}
		lib.sync()
		lib.printf("Mean GPU Time = %0.6fms\n\n", 1000 * lib.timer_stop()/iter)
	end
end)