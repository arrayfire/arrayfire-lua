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
local lib = require("lib.af_lib")

-- Shorthands --
local Comp, WC = lib.CompareResult, lib.WrapConstant

lib.main(function()
	local days, sites = 9, 4
	local n = 10 -- measurements
	local day_ =         {0, 0, 1, 2, 5, 5, 6, 6, 7, 8 } -- ascending
	local site_ =        {2, 3, 0, 1, 1, 2, 0, 1, 2, 1 }
	local measurement_ = {9, 5, 6, 3, 3, 8, 2, 6, 5, 10} -- inches
	local day = lib.array(n,day_)
	local site = lib.array(n,site_)
	local measurement = lib.array(n,measurement_)
	local rainfall = lib.constant(0, sites)
--[[
	gfor (seq s, sites) {
		rainfall(s) = sum(measurement * (site == s));
	}
]]
	print("total rainfall at each site:")
	lib.print("rainfall", rainfall)
	local is_between = lib["and"](Comp(WC(1) <= day), Comp(day <= WC(5))) -- days 1 and 5
	local rain_between = lib.sum("f32", measurement * is_between)
	lib.printf("rain between days: %g", rain_between)
	lib.printf("number of days with rain: %g", lib.sum("f32", Comp(lib.diff1(day) > WC(0))) + 1)
	local per_day = lib.constant(0, days)
--[[
	gfor (seq d, days)
		per_day(d) = sum(measurement * (day == d))
]]
	print("total rainfall each day:")
	lib.print("per_day", per_day)
	lib.printf("number of days over five: %g", lib.sum("f32", Comp(per_day > WC(5))))
end)