--- Program-related functions.

-- Standard library imports --
local clock = os.clock
local error = error
local getenv = os.getenv
local pcall = pcall
local print = print
local select = select
local tonumber = tonumber

-- Modules --
local af = require("arrayfire")

-- Exports --
local M = {}

-- --
local T0

--
function M.Add (into)
	for k, v in pairs{
		main = function(func, ...)
			local argc, argv = select("#", ...), { ... }

			for i = 1, argc do -- Mimic C array
				argv[i - 1] = argv[i]
			end

			argv[argc] = nil

			local ok, err = pcall(function()
				local device = argc > 1 and tonumber(argv[1]) or 0

				-- Select a device and display arrayfire info
				af.af_set_device(device)
				af.af_info()

				func(argc, argv)

				if getenv("windir") ~= nil then -- pause in Windows
					if not (arc == 2 and argv[1]:sub(1, 1) == "-") then
						print("hit [enter]...")
						io.output():flush()
						-- getchar() io.input():read()?
					end
				end
			end)

			if not ok then
				print(err) -- TODO: more informative
				error("aborting")
			end
		end,

		-- ^^^ TODO: setfenv() / _ENV variant?

		--
		timeit = function(func)
			local t0 = clock()

			func()

			return clock() - t0
		end,

		--
		timer_start = function()
			T0 = clock()
		end,

		--
		timer_stop = function()
			return clock() - T0
		end
		-- ^^^ TODO: Better stuff? (resolution, instantiable)
	} do
		into[k] = v
	end
end

-- Export the module.
return M