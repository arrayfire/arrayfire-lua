-- Standard library imports --
local floor = math.floor

-- Modules --
local AF = require("arrayfire")

AF.main(function(argc, arv)
	local win
	local function normalize (a, max)
		local mx = max * 0.5
		local mn = -max * 0.5
		return (a-mn)/(mx-mn)
	end
	local function swe (console)
		local time_total = 20 -- run for N seconds
		-- Grid length, number and spacing
		local Lx, Ly = 512, 512
		local nx, ny = Lx + 1, Ly + 1
		local dx = Lx / (nx - 1)
		local dy = Ly / (ny - 1)
		local ZERO = AF.constant(0, nx, ny)
		local um, vm = ZERO:copy(), ZERO:copy()
		local io, jo, k = floor(Lx  / 5.0),	floor(Ly / 5.0), 20
		local x = AF.tile(AF.moddims(AF.array(AF.seq(nx)),nx,1), 1,ny)
		local y = AF.tile(AF.moddims(AF.array(AF.seq(ny)),1,ny), nx,1)
		-- Initial condition
		local etam = 0.01 * AF.exp((-((x - io) * (x - io) + (y - jo) * (y - jo))) / (k * k))
		local m_eta = AF.max("f32", etam)
		local eta = etam:copy()
		local dt = 0.5
		-- conv kernels
		local h_diff_kernel = {9.81 * (dt / dx), 0, -9.81 * (dt / dx)}
		local h_lap_kernel = {0, 1, 0, 1, -4, 1, 0, 1, 0}
		local h_diff_kernel_arr = AF.array(3, h_diff_kernel)
		local h_lap_kernel_arr = AF.array(3, 3, h_lap_kernel)
		if not console then
			win = AF.Window(512, 512,"Shallow Water Equations")
			win:setColorMap("AF_COLORMAP_MOOD")
		end
		local t = AF.timer_start()
		local iter = 0
		AF.EnvLoopWhile_Mode(function(env)
			-- compute
			local up = um + AF.convolve(eta, h_diff_kernel_arr)
			local vp = um + AF.convolve(eta, h_diff_kernel_arr:T())
			local e = AF.convolve(eta, h_lap_kernel_arr)
			local etap = 2 * eta - etam + (2 * dt * dt) / (dx * dy) * e
			etam = env(eta:copy())
			eta = env(etap:copy())
			if not console then
				win:image(normalize(eta, m_eta))
				-- viz
			else
				AF.eval(eta, up, vp)
			end
			iter = iter + 1
		end, function()
			return AF.progress(iter, t, time_total)
		end, "normal_gc") -- evict old states every now and then
	--	win:destroy() -- err...
	end

	print("Simulation of shallow water equations")
	swe(argc > 2 and argv[2][0] == '-' )
end)