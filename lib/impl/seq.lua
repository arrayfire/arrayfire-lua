--- Core seq module.

-- Standard library imports --
local abs = math.abs
local assert = assert
local getmetatable = getmetatable
local rawequal = rawequal
local setmetatable = setmetatable
local type = type

-- Cached module references --
local _IsSeq_
local _MakeSeq_

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/seq.cpp

-- --
local SeqMT = {}

-- --
local MetaValue = {}

--
local function IsSeqA (a, b)
	local is_a, is_b = _IsSeq_(a), _IsSeq_(b)

	assert(is_a ~= is_b, "Arithmetic not defined on two seq arguments")

	return is_a
end

--
local function SwapIfB (a, b)
	if IsSeqA(a, b) then
		return a, b
	else
		return b, a
	end
end

--
function SeqMT.__add (a, b)
	a, b = SwapIfB(a, b)

	return _MakeSeq_(a.begin + b, a["end"] + b, a.step)
end

--
function SeqMT.__mul (a, b)
	a, b = SwapIfB(a, b)

	return _MakeSeq_(a.begin * b, a["end"] * b, a.step * b)
end

--
function SeqMT.__sub (a, b)
	if IsSeqA(a) then
		return _MakeSeq_(a.begin - b, a["end"] - b, a.step)
	else
		return _MakeSeq_(a - b.begin, a - b["end"], -b.step) -- TODO: double-check step
	end
end

--
function SeqMT:__unm ()
	return _MakeSeq_(-self.begin, -self["end"], -self.step)
end

--[[
int end = -1;
seq span(af_span);
]]

--
function M.Add (array_module)
	-- Import these here since the array module is not yet registered.
	local CallWithEnvironment = array_module.CallWithEnvironment
	local GetLib = array_module.GetLib

	--- DOCME
	function array_module.IsSeq (item)
		return rawequal(getmetatable(item), MetaValue)
	end

	-- DOCME
	function array_module.MakeSeq (sbegin, send, step)
		if type(sbegin) == "table" then
			local s = sbegin

			sbegin, send, step = s.begin, s["end"], s.step
		end

		local seq = {}

		seq.begin, seq["end"], seq.step = sbegin, send, step

		if step ~= 0 then -- not span
			seq.size = abs((send - sbegin) / step) + 1
		else
			seq.size = 0
		end

		return setmetatable(seq, SeqMT)
	end

	--
	local function SignBit (x)
		return x < 0 and -1 or 0
	end

	--- DOCME
	function array_module.NewSeq (a, b, c)
		if _IsSeq_(a) then -- a: seq, b: gfor
			local copy = _MakeSeq_(a)

			copy.m_gfor = not not b

			return copy	
		elseif b == "seq" then -- a: seq (table), "seq"
			return _MakeSeq_(a)
		elseif b then -- a: begin, b: end, c: step
			c = c or 1

			if c == 0 then
				assert(a ~= b, "Invalid step size") -- AF_ERR_ARG
			end

			assert(not(b >= 0 and a >= 0 and SignBit(b - a) ~= SignBit(c)), "Sequence is invalid") -- AF_ERR_ARG

			return _MakeSeq_(a, b, c)
		else -- a: length
			if a and a < 0 then
				return _MakeSeq_(0, a, 1)
			else
				return _MakeSeq_(0, (a or 0) - 1, 1)
			end
		end
	end

	--
	local function AuxToArray (env, seq)
		local diff = seq["end"] - seq.begin
		local len = (diff + abs(seq.step) * (SignBit(diff) == 0 and 1 or -1)) / seq.step
		local range = GetLib().range
		local tmp = seq.m_gfor and range(1, 1, 1, len, 3) or range(len)

		return env(seq.begin + seq.step * tmp)
	end

	--- DOCME
	function array_module.SeqToArray (seq)
		return CallWithEnvironment(AuxToArray, seq)
	end

	-- Cache module members.
	_IsSeq_ = array_module.IsSeq
	_MakeSeq_ = array_module.MakeSeq
end

--
SeqMT.__index = SeqMT
SeqMT.__metatable = MetaValue

-- TODO: Add "seq" environment type?

-- Export the module.
return M