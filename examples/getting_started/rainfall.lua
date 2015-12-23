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

print("")
print("N.B. THIS IS A WIP")
print("")

-- Investigate rainfall measurements across sites and days
-- demonstrating various simple tasks
-- Compute various values:
-- - total rainfall at each site
-- - rain between days 1 and 5
-- - number of days with rain
-- - total rainfall on each day
-- - number of days with over five inches
-- - total rainfall at each site
-- note: example adapted from
--  "Rapid Problem Solving Using Thrust", Nathan Bell, NVIDIA
 -- Modules --
local AF = require("arrayfire")

-- Shorthands --
local Comp, WC = AF.CompareResult, AF.WrapConstant

AF.main(function()
	local days, sites = 9, 4
	local n = 10 -- measurements
	local day_ =         {0, 0, 1, 2, 5, 5, 6, 6, 7, 8 } -- ascending
	local site_ =        {2, 3, 0, 1, 1, 2, 0, 1, 2, 1 }
	local measurement_ = {9, 5, 6, 3, 3, 8, 2, 6, 5, 10} -- inches
	local day = AF.array(n,day_)
	local site = AF.array(n,site_)
	local measurement = AF.array(n,measurement_)
	local rainfall = AF.constant(0, sites)

	for s in AF.gfor(sites) do
	--	rainfall(s) = AF.sum(measurement * COMP(site == AF.array(s)))
	end
	print("total rainfall at each site:")
	AF.print("rainfall", rainfall)
	local is_between = AF["and"](Comp(WC(1) <= day), Comp(day <= WC(5))) -- days 1 and 5
	local rain_between = AF.sum("f32", measurement * is_between)
	AF.printf("rain between days: %g", rain_between)
	AF.printf("number of days with rain: %g", AF.sum("f32", Comp(AF.diff1(day) > WC(0))) + 1)
	local per_day = AF.constant(0, days)
	for d in AF.gfor(days) do
	--	per_day(d) = AF.sum(measurement * COMP(day == AF.array(d)))
	end
	print("total rainfall each day:")
	AF.print("per_day", per_day)
	AF.printf("number of days over five: %g", AF.sum("f32", Comp(per_day > WC(5))))
end)