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

-- Shorthands --
local Comp, WC = AF.CompareResult, AF.WrapConstant

AF.main(function()
	local h_kernel = {1, 1, 1, 1, 0, 1, 1, 1, 1}
	local reset = 500
	local game_w, game_h = 128, 128

	print("This example demonstrates the Conway's Game of Life using ArrayFire")
	print("There are 4 simple rules of Conways's Game of Life")
	print("1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.")
	print("2. Any live cell with two or three live neighbours lives on to the next generation.")
	print("3. Any live cell with more than three live neighbours dies, as if by overcrowding.")
	print("4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.")
	print("Each white block in the visualization represents 1 alive cell, black space represents dead cells")

	local _0_5, _2, _3 = WC(0.5), WC(2), WC(3)

	local myWindow = AF.Window(512, 512, "Conway's Game of Life using ArrayFire")
	local frame_count = 0
	-- Initialize the kernel array just once
	local kernel = AF.array(3, 3, h_kernel, "afHost")
	local state
	state = Comp(AF.randu(game_h, game_w, "f32") > _0_5):as("f32")
	AF.EnvLoopWhile_Mode(function(env)
		myWindow:image(state)
		frame_count = frame_count + 1
		-- Generate a random starting state
		if frame_count % reset == 0 then
			state = Comp(AF.randu(game_h, game_w, "f32") > _0_5):as("f32")
		end
		-- Convolve gets neighbors
		local nHood = AF.convolve(state, kernel)
		-- Generate conditions for life
		-- state == 1 && nHood < 2 ->> state = 0
		-- state == 1 && nHood > 3 ->> state = 0
		-- else if state == 1 ->> state = 1
		-- state == 0 && nHood == 3 ->> state = 1
		local C0 = Comp(nHood == _2)
		local C1 = Comp(nHood == _3)
		-- Update state
		state = env(state * C0 + C1)
	end, AF.wait_for_windows_close("while", myWindow), "normal_gc") -- evict old states every now and then
end)