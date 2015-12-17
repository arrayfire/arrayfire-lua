--- Ephemeral array environments.

-- Standard library imports --
local assert = assert
local collectgarbage = collectgarbage
local error = error
local pairs = pairs
local pcall = pcall
local rawequal = rawequal
local remove = table.remove

-- Modules --
local af = require("arrayfire")

-- Forward declarations --
local IsArray

-- Cookies --
local _command = {}

-- Exports --
local M = {}

-- --
local ID = 0

-- --
local Stack = {}

-- --
local Top = 0

--
local function NewEnv ()
	local id, list, mode, step = ID, {}

	ID = ID + 1

	return function(a, b, c)
		if rawequal(a, _command) then -- a: _command, b: what, c: arg
			if b == "set_mode" then
				mode = c
			elseif b == "get_id" then
				return id
			elseif b == "get_list" then
				return list
			elseif b == "set_step" then
				step = c
			end
		elseif a == "get_step" then -- a: "get_step"
			return step
		elseif IsArray(a) then -- a: array?
			local env = Stack[Top]

			assert(env and env(_command, "get_id") == id, "Environment not active") -- is self?

			local lower_env = (mode == "parent" or mode == "parent_gc") and Stack[Top - 1]
-- TODO: pingpong, pingpong_gc
			if lower_env then
				lower_env(_command, "get_list")[a] = true
			end

			list[a] = nil

			return a
		end
	end
end

--
local function Purge (list)
	local nerrs = 0

	for arr in pairs(list) do
		local ha = arr:get(true)

		if ha then
			local err = af.af_release_array(ha)

			if err ~= af.AF_SUCCESS then
				nerrs = nerrs + 1
			end
		end

		list[arr] = nil
	end

	return nerrs
end

-- --
local Cache = {}

--
local function GetResults (env, ok, a, ...)
	local mode = env(_command, "get_mode")

	env(_command, "set_mode", nil)

	local nerrs = Purge(env(_command, "get_list"))
-- Pingpong or normal? (How to end?)
	Cache[#Cache + 1] = env
	Top, Stack[Top] = Top - 1

	if mode == "normal_gc" or mode == "parent_gc" then
		collectgarbage()
	end
-- TODO: pingpong_gc
	if ok and nerrs == 0 then
		return a, ...
	else
-- Clean up if pingpong
		error(not ok and a or ("Errors releasing %i arrays"):format(nerrs))
	end
end

--
function M.Add (array_module)
	-- Import these here since the array module is not yet registered.
	IsArray = array_module.IsArray

	--
	function array_module.AddToCurrentEnvironment (arr)
		local env = Top > 0 and Stack[Top]

		if env then
			env(_command, "get_list")[arr] = true
		end
	end
-- AddOneEnv
-- AddEnvs
	--
	function array_module.CallWithEnvironment (func, ...)
		local env = remove(Cache) or NewEnv()
-- AddOneEnv()
		Top = Top + 1

		Stack[Top] = env

		return GetResults(env, pcall(func, env, ...))
	end

	--
	function array_module.CallWithEnvironment_Args (func, args, ...)
		local env = remove(Cache) or NewEnv()

		Top = Top + 1
-- if pingpong
	-- AddEnvs
		env(_command, "set_mode", args.mode)
		env(_command, "set_step", args.step)

		Stack[Top] = env

		return GetResults(env, pcall(func, env, ...))
	end
end

-- Export the module.
return M