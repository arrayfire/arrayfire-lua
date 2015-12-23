--- Ephemeral array environments.

-- Standard library imports --
local assert = assert
local concat = table.concat
local collectgarbage = collectgarbage
local error = error
local pairs = pairs
local pcall = pcall
local rawequal = rawequal
local remove = table.remove

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
local function Remove (lists, elem)
	for elem_type, list in pairs(lists) do
		if list[elem] then
			list[elem] = nil

			return elem_type
		end
	end
end

-- --
local Types = {}

--
local function NewEnv ()
	local id, lists, mode, step = ID, {}

	ID = ID + 1

	for elem_type in pairs(Types) do
		lists[elem_type] = {}
	end

	return function(a, b, c)
		if rawequal(a, _command) then -- a: _command, b: what, c: arg
			if b == "set_mode" then
				mode = c
			elseif b == "get_id" then
				return id
			elseif b == "get_lists" then
				return lists
			elseif b == "set_step" then
				step = c
			end
		elseif a == "get_step" then -- a: "get_step"
			return step
		else -- a: element?
			local env = Stack[Top]

			assert(env and env(_command, "get_id") == id, "Environment not active") -- is self?

			local elem_type = Remove(lists, a)

			if elem_type then
				local lower_env = (mode == "parent" or mode == "parent_gc") and Stack[Top - 1]
-- TODO: pingpong, pingpong_gc
				if lower_env then
					lower_env(_command, "get_lists")[elem_type][a] = true
				end

				return a
			end
		end
	end
end

--
local function Purge (lists)
	local errs

	for elem_type, type_info in pairs(Types) do
		local elem_list, cleanup, nerrs = lists[elem_type], type_info.cleanup, 0

		--
		for elem in pairs(elem_list) do
			if not cleanup(elem) then
				nerrs = nerrs + 1
			end

			elem_list[elem] = nil
		end

		--
		if nerrs > 0 then
			errs = errs or {}

			errs[#errs + 1] = type_info.message:format(nerrs)
		end
	end

	return errs and concat(errs, "\n")
end

-- --
local Cache = {}

--
local function GetResults (env, ok, a, ...)
	local mode = env(_command, "get_mode")

	env(_command, "set_mode", nil)

	local errs = Purge(env(_command, "get_lists"))
-- Pingpong or normal? (How to end?)
	Cache[#Cache + 1] = env
	Top, Stack[Top] = Top - 1

	if mode == "normal_gc" or mode == "parent_gc" then
		collectgarbage()
	end
-- TODO: pingpong_gc
	if ok and not errs then
		return a, ...
	else
-- Clean up if pingpong
		error(not ok and a or errs)
	end
end

--
function M.Add (array_module)
	--
	function array_module.AddToCurrentEnvironment (elem_type, arr)
		local env = Top > 0 and Stack[Top]

		if env then
			env(_command, "get_lists")[elem_type][arr] = true
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

	--
	function array_module.RegisterEnvironmentCleanup (elem_type, cleanup, message)
		assert(Top == 0 and #Cache == 0, "Attempt to register new environment type after launch")

		Types[elem_type] = { cleanup = cleanup, message = message }
	end
end

-- Export the module.
return M