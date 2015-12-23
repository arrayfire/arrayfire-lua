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
local abs = math.abs
local sqrt = math.sqrt

-- Modules --
local AF = require("arrayfire")

-- Shorthands --
local Comp, WC = AF.CompareResult, AF.WrapConstant

AF.main(function(argc, argv)
	local WIDTH = 400 -- Width of image
	local HEIGHT = 400 -- Width of image

	local function complex_grid (width, height, zoom, center)
		-- Generate sequences of length width, height
		local x = AF.array(AF.seq(height) - height / 2.0)
		local y = AF.array(AF.seq(width ) - width  / 2.0)
		-- Tile the sequences to generate grid of image size
		local X = AF.tile(x:T(), y:elements(), 1) / zoom + center[1]
		local Y = AF.tile(y    , 1, x:elements()) / zoom + center[2]
		-- Return the locations as a complex grid
		return AF.complex(X, Y)
	end
	local C, Z, mag
	local function AuxMandelbrot (env, maxval)
		local ii = env("get_step")
		-- Do the calculation
		Z = Z * Z + C
		-- Get indices where abs(Z) crosses maxval
		local cond = Comp(AF.abs(Z) > maxval):as("f32")
		mag = env(AF.max(mag, cond * ii))
		-- If abs(Z) cross maxval, turn off those locations
		C = env(C * (1 - cond))
		Z = env(Z * (1 - cond))
		-- Ensuring the JIT does not become too large
		C:eval()
		Z:eval()
	end
	local function mandelbrot (in_arr, iter, maxval)
		C = in_arr:copy();
		Z = C:copy()
		mag = AF.constant(0, C:dims())
		AF.EnvLoopFromTo_Mode(1, iter - 1, "parent_gc", AuxMandelbrot, maxval)
		-- Normalize
		return mag / maxval
	end
	local function normalize (a)
		local mx = AF.max("f32", a)
		local mn = AF.min("f32", a)
		return (a-mn)/(mx-mn)
	end
    local iter = argc > 2 and tonumber(argv[2]) or 100 -- Seems to never be used...
    local console = argc > 2 and argv[2][0] == '-'

	print("** ArrayFire Fractals Demo **")
	local wnd = AF.Window(WIDTH, HEIGHT, "Fractal Demo");
	wnd:setColorMap("AF_COLORMAP_SPECTRUM")
	local center = {-0.75, 0.1}
	-- Keep zooming out for each frame
	local _1000 = WC(1000)
	AF.EnvLoopFromTo(10, 399, function(env)
		local i = env("get_step")
		local zoom = i * i
		if i % 10 == 0 then
			AF.printf("iteration: %d zoom: %d", i, zoom)
			io.output():flush() -- n.b.: no braces in original
		end
		-- Generate the grid at the current zoom factor
		local c = complex_grid(WIDTH, HEIGHT, zoom, center)
		iter =sqrt(abs(2*sqrt(abs(1-sqrt(5*zoom)))))*100
		-- Generate the mandelbrot image
		local mag = mandelbrot(c, iter, _1000)
		if not console then
			if wnd:close() then
				return "stop_loop"
			end
			local mag_norm = normalize(mag)
			wnd:image(mag_norm)
		end
	end)
	wnd:destroy()
end)