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
local input = require("financial.input")
local AF = require("arrayfire")

-- --
local sqrt2 = math.sqrt(2)

-- Shorthands --
local Comp, K = AF.CompareResult, AF.WrapConstant

local function cnd (x)
    local temp = Comp(x > K(0))
    local y = temp * (0.5 + AF.erf(x/sqrt2)/2) + (1-temp) * (0.5 - AF.erf((-x)/sqrt2)/2)
    return y
end

local function black_scholes (env, S, X, R, V, T)
    -- This function computes the call and put option prices based on
    -- Black-Scholes Model
    -- S = Underlying stock price
    -- X = Strike Price
    -- R = Risk free rate of interest
    -- V = Volatility
    -- T = Time to maturity
    local d1 = AF.log(S / X)
    d1 = d1 + (R + (V*V)*0.5) * T
    d1 = d1 / (V*AF.sqrt(T));
    local d2 = d1 - (V*AF.sqrt(T))
    local cnd_d1 = cnd(d1)
    local cnd_d2 = cnd(d2)
    local C = S * cnd_d1  - (X * AF.exp((-R)*T) * cnd_d2)
    local P = X * AF.exp((-R)*T) * (1 - cnd_d2) - (S * (1 - cnd_d1))
	return env(C), env(P)
end
AF.main(function()
	print("** ArrayFire Black-Scholes Example **\n" ..
		   "**          by AccelerEyes         **\n")
	local GC1 = AF.array(4000, 1, input.C1)
	local GC2 = AF.array(4000, 1, input.C2)
	local GC3 = AF.array(4000, 1, input.C3)
	local GC4 = AF.array(4000, 1, input.C4)
	local GC5 = AF.array(4000, 1, input.C5)

	-- Compile kernels
	-- Create GPU copies of the data
	local Sg = GC1:copy()
	local Xg = GC2:copy()
	local Rg = GC3:copy()
	local Vg = GC4:copy()
	local Tg = GC5:copy()
	local Cg, Pg

	--Warm up black scholes example
	Cg, Pg = AF.CallWithEnvironment(black_scholes, Sg,Xg,Rg,Vg,Tg)
    AF.eval(Cg, Pg)
	print("Warming up done")
	AF.sync()
	local iter = 5
	AF.EnvLoopFromToStep_Mode(50, 500, 50, "parent", function(env)
		local n = env("get_step")

		-- Create GPU copies of the data
		Sg = AF.tile(GC1, n, 1)
		Xg = AF.tile(GC2, n, 1)
		Rg = AF.tile(GC3, n, 1)
		Vg = AF.tile(GC4, n, 1)
		Tg = AF.tile(GC5, n, 1)
		local dims = Xg:dims()
		AF.printf("Input Data Size = %d x %d", dims[1], dims[2])
		-- Force compute on the GPU
		AF.sync()
		AF.timer_start()
		AF.EnvLoopN(iter, function(inner_env)
			Cg, Pg = black_scholes(inner_env, Sg,Xg,Rg,Vg,Tg)
			AF.eval(Cg,Pg)
		end)
		AF.sync()
		AF.printf("Mean GPU Time = %0.6fms\n\n", 1000 * AF.timer_stop()/iter)
	end)
end)