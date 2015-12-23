--- Program-related functions.

-- Standard library imports --
local clock = os.clock
local error = error
local getenv = os.getenv
local max = math.max
local pcall = pcall
local print = print
local select = select
local tonumber = tonumber

-- Modules --
local array = require("impl.array")

-- Imports --
local GetLib = array.GetLib

-- Exports --
local M = {}

-- --
local IterPrev = 0
local TimePrev = 0
local MaxRate = 0

-- --
local T0

--
function M.Add (into)
	for k, v in pairs{
		--
		assets = function()
			return getenv("AF_PATH") .. "/assets"
		end,

--[[
union Data
{
    unsigned dim;
    char bytes[4];
};

unsigned char reverse_char(unsigned char b)
{
    b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
    b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
    b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
    return b;
}

// http://stackoverflow.com/a/9144870/2192361
unsigned reverse(unsigned x)
{
    x = ((x >> 1) & 0x55555555u) | ((x & 0x55555555u) << 1);
    x = ((x >> 2) & 0x33333333u) | ((x & 0x33333333u) << 2);
    x = ((x >> 4) & 0x0f0f0f0fu) | ((x & 0x0f0f0f0fu) << 4);
    x = ((x >> 8) & 0x00ff00ffu) | ((x & 0x00ff00ffu) << 8);
    x = ((x >> 16) & 0xffffu) | ((x & 0xffffu) << 16);
    return x;
}

template<class ty>
void read_idx(std::vector<dim_t> &dims, std::vector<ty> &data, const char *name)
{
    std::ifstream f(name, std::ios::in | std::ios::binary);
    if (!f.is_open()) throw std::runtime_error("Unable to open file");

    Data d;
    f.read(d.bytes, sizeof(d.bytes));

    if (d.bytes[2] != 8) {
        throw std::runtime_error("Unsupported data type");
    }

    unsigned numdims = d.bytes[3];
    unsigned elemsize = 1;

    // Read the dimensions
    size_t elem = 1;
    dims = std::vector<dim_t>(numdims);
    for (unsigned i = 0; i < numdims; i++) {
        f.read(d.bytes, sizeof(d.bytes));

        // Big endian to little endian
        for (int j = 0; j < 4; j++) d.bytes[j] = reverse_char(d.bytes[j]);
        unsigned dim = reverse(d.dim);

        elem *= dim;
        dims[i] = (dim_t)dim;
    }

    // Read the data
    std::vector<char> cdata(elem);
    f.read(&cdata[0], elem * elemsize);
    std::vector<unsigned char> ucdata(cdata.begin(), cdata.end());

    data = std::vector<ty>(ucdata.begin(), ucdata.end());

    f.close();
    return;
}
]]

		--
		main = function(func, ...)
			local argc, argv = select("#", ...), { ... }

			for i = 1, argc do -- Mimic C array
				argv[i - 1] = argv[i]
			end

			argv[argc] = nil

			local ok, err = pcall(function()
				local device = argc > 1 and tonumber(argv[1]) or 0
				local Lib = GetLib()

				-- Select a device and display arrayfire info
				Lib.setDevice(device)
				Lib.info()

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
		-- Also, rearrange for exit stuff?
		-- Are the windows redirecting IO?

		--
		progress = function(iter_curr, t, time_total)
			local Lib = GetLib()

			Lib.sync()

			local time_curr = Lib.timer_stop(t)

			if time_curr - TimePrev < 1 then
				return true
			end

			local rate = (iter_curr - IterPrev) / (time_curr - TimePrev)

			Lib.printf("  iterations per second: %.0f   (progress %.0f%%)", rate, 100.0 * time_curr / time_total)

			MaxRate = max(MaxRate, rate)

			IterPrev = iter_curr
			TimePrev = time_curr

			if time_curr < time_total then
				return true
			end

			Lib.printf(" ### %f iterations per second (max)", MaxRate)
			return false
		end,

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
		timer_stop = function(since)
			return clock() - (since or T0)
		end,

		--
		wait_for_windows = function(how, w1, w2, w3)
			--
			return function()
				local is_open

				if w3 and w3:close() then
					is_open = false
				elseif w2 and w2:close() then
					is_open = false
				else
					is_open = not w1:close()
				end

				if how == "until" then
					return not is_open
				else
					return is_open
				end
			end
		end,

		--
		wait_for_windows_close = function(how, w1, w2, w3)
			local going = GetLib().wait_for_windows(how, w1, w2, w3)

			return function()
				local is_going = going()
				local is_open = is_going

				if how == "until" then
					is_open = not is_open
				end
				
				if not is_open then
					if not w1:close() then
						w1:destroy() -- TODO: Do this right... how?
					end

					if w2 and not w2:close() then
						w2:destroy()
					end

					if w3 and not w3:close() then
						w3:destroy()
					end
				end

				return is_going
			end
			--
		end
		-- ^^^ TODO: Better stuff? (resolution, instantiable?)
	} do
		into[k] = v
	end
end

-- Export the module.
return M