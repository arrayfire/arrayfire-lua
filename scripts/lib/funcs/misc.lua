--- Miscellaneous functions.

-- Standard library imports --
local remove = table.remove

-- Modules --
local array = require("lib.impl.array")

-- Imports --
local CallWithEnvironment = array.CallWithEnvironment
local CallWithEnvironment_Args = array.CallWithEnvironment_Args
local IsArray = array.IsArray

-- Exports --
local M = {}

--
local function Eval1 (a, b, c, d, e, f)
	a:eval()

	if b then
		return Eval1(b, c, d, e, f)
	end
end

--
local function Eval (a, b, c, d, e, f)
	if IsArray(f) then
		Eval1(a, b, c, d, e, f)
	elseif IsArray(e) then
		Eval1(a, b, c, d, e)
	elseif IsArray(d) then
		Eval1(a, b, c, d)
	elseif IsArray(c) then
		Eval1(a, b, c)
	elseif IsArray(b) then
		Eval1(a, b)
	else
		a:eval()

		return a
	end
end

-- --
local EnvArgsStack = {}

--
local function GetEnvArgs (mode)
	local env_args = remove(EnvArgsStack) or {}

	env_args.mode, env_args.step = mode

	return env_args
end

--
local function AuxEnvIter (env_args)
	local inc, i1, ok = env_args.inc, env_args.step

	i1 = i1 + inc

	if inc > 0 then
		ok = i1 <= env_args.i2
	else
		ok = i2 >= env_args.i2
	end

	if ok then
		env_args.step = i1

		return env_args
	else
		EnvArgsStack[#EnvArgsStack + 1] = env_args
	end
end

--
local function EnvIter (mode, i1, i2, inc)
	inc = inc or 1

	local env_args = GetEnvArgs(mode)

	env_args.inc, env_args.step, env_args.i2 = inc, i1 - inc, i2

	return AuxEnvIter, env_args
end

--
function M.Add (into)
	for k, v in pairs{
		eval = Eval,

		--
		EnvLoopFromTo = function(i1, i2, func, ...)
			for args in EnvIter(nil, i1, i2) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopFromTo_Mode = function(i1, i2, mode, func, ...)
			for args in EnvIter(mode, i1, i2) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopFromToStep = function(i1, i2, step, func, ...)
			for args in EnvIter(nil, i1, i2, step) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopFromToStep_Mode = function(i1, i2, step, mode, func, ...)
			for args in EnvIter(mode, i1, i2, step) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopN = function(n, func, ...)
			for args in EnvIter(nil, 1, n) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopN_Mode = function(n, func, mode, ...)
			for args in EnvIter(mode, 1, n) do
				CallWithEnvironment_Args(func, args, ...)
			end
		end,
		EnvLoopUntil = function(func, pred, ...)
			repeat
				CallWithEnvironment(func, ...)
			until pred(...)
		end,
		EnvLoopUntil_Mode = function(func, pred, mode, ...)
			local args = GetEnvArgs(mode)

			repeat
				CallWithEnvironment_Args(func, args, ...)
			until pred(...)

			EnvArgsStack[#EnvArgsStack + 1] = args
		end,
		EnvLoopWhile = function(func, pred, ...)
			while pred(...) do
				CallWithEnvironment(func, ...)
			end
		end,
		EnvLoopWhile_Mode = function(func, pred, mode, ...)
			local args = GetEnvArgs(mode)

			while pred(...) do
				CallWithEnvironment_Args(func, args, ...)
			end

			EnvArgsStack[#EnvArgsStack + 1] = args
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M