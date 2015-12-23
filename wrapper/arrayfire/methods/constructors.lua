--- Array constructors.

-- Standard library imports --
local assert = assert
local error = error
local select = select
local type = type
local unpack = unpack

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local CallWrap = array.CallWrap
local IsArray = array.IsArray
local IsSeq = array.IsSeq
local SeqToArray = array.SeqToArray
local ToType = array.ToType
local WrapArray = array.WrapArray

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/array.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/data.cpp

-- TODO: put these somewhere better... might need to fix up some things?

--
local function GetElements (dims)
	return dims[1] * dims[2] * dims[3] * dims[4]
end

--
local function GetNDims (dims)
    local num = GetElements(dims)

	if num < 2 then
		return num
	else
		for i = 4, 2, -1 do
			if dims[i] ~= 1 then
				return i
			end
		end
	end

	return 1
end

-- --
local DimsAndType = {}

local function GetDimsAndType (...)
	--
	DimsAndType[1], DimsAndType[2], DimsAndType[3], DimsAndType[4], DimsAndType[5] = ...

	--
	local n = 0

	while type(DimsAndType[n + 1]) == "number" do
		n = n + 1
	end

	local last, dtype = DimsAndType[n + 1]
	local last_type = n > 0 and type(last)

	if last_type == "string" or last_type == "table" then
		if last_type == "table" then
			dtype, DimsAndType[n + 1] = last -- remove table ref
		else
			dtype = af[last]
		end
	end

	--
	local dims = DimsAndType

	if type(DimsAndType[1]) == "table" then
		dims, n, DimsAndType[1] = DimsAndType[1], 4 -- remove table ref
	end

	return n, dims, dtype
end

--
local function DimsAndTypeFunc (func)
	return function(...)
		local n, dims, dtype = GetDimsAndType(...)

		return CallWrap(func, n, dims, dtype or af.f32)
	end
end

-- --
local Dims = DimsAndType

--
local function PrepDims (d0, d1, d2, d3)
	Dims[1], Dims[2], Dims[3], Dims[4] = d0, d1 or 1, d2 or 1, d3 or 1

	return Dims
end

--
local function InitEmptyArray (dtype, d0, d1, d2, d3)
	return CallWrap("af_create_handle", 4, PrepDims(d0, d1, d2, d3), dtype)
end

--
local function InitDataArray (dtype, ptr, src, d0, d1, d2, d3)
	local func

	if src == "afHost" then
		func = "af_create_array"
	elseif src == "afDevice" then
		func = "af_device_array"
	else
		error("Can not create array from the requested source pointer") -- TODO: AF_ERR_ARG?
	end

	return CallWrap(func, ptr, 4, PrepDims(d0, d1, d2, d3), af[dtype])
end

--
function M.Add (into)
	for k, v in pairs{
		--
		array = function(a, b, c, d, e, f)
			if b == "handle" then -- a: handle, b: "handle"
				return WrapArray(a)
			elseif IsArray(a) then
				if type(b) == "table" then -- a: input, b: dims
					return CallWrap("af_moddims", a:get(), 4, b)
				elseif b then -- a: input, b...e: dims
					return CallWrap("af_moddims", a:get(), 4, PrepDims(b, c, d, e))
				else -- a: input
					return CallWrap("af_retain_array", a:get())
				end
			elseif IsSeq(a) then -- a: seq
				return SeqToArray(a)
			elseif type(a) == "table" then
				if type(b) == "table" then -- a: dims, b: ptr, c: src
					return InitDataArray("f32", b, c or "afHost", a[1], a[2], a[3], a[4])
				else -- a: dims, b: type
					return InitEmptyArray(af[b or "f32"], a[1], a[2], a[3], a[4])
				end
			elseif a then
				local n, dims, dtype = GetDimsAndType(a, b, c, d, e)

				if type(dtype) == "table" then -- a...: dims, second-to-last: ptr, last?: source
					return InitDataArray("f32", dtype, select(n + 2, a, b, c, d, e, f) or "afHost", unpack(dims, 1, n))
				else -- a...: dims, last?: type
					return InitEmptyArray(dtype or af.f32, unpack(dims, 1, n))
				end
			else
				return InitEmptyArray(af.f32, 0, 0, 0, 0)
			end
		end,

		--
		constant = function(value, ...)
			local n, dims, dtype = GetDimsAndType(...)

			if type(value) == "table" then
				if dtype == "c32" or dtype == "c64" then
					return CallWrap("af_constant_complex", value.real, value.imag, n, dims, dtype)
				else
					value = value.real -- TODO: syntax? (ditto above)
				end
			end

			if dtype == "s64" or dtype == "u64" then
				local name = dtype == "s64" and "af_constant_long" or "af_constant_ulong"

				return CallWrap(name, value, n, dims)
			else
				return CallWrap("af_constant", value, n, dims, dtype or af.f32)
			end
		end,

		--
		diag = function(in_arr, num, extract)
			if extract == nil then
				extract = true
			end

			return CallWrap(extract and "af_diag_extract" or "af_diag_create", in_arr:get(), num or 0)
		end,

		--
		flat = function(in_arr)
			return CallWrap("af_flat", in_arr:get())
		end,

		--
		identity = DimsAndTypeFunc("af_identity"),

		--
		moddims = function(in_arr, a, b, c, d)
			local ndims, dims

			if type(a) == "table" then -- a: dims
				ndims, dims = GetNDims(a), a
			elseif type(b) == "table" then -- a: ndims, b: dims
				ndims, dims = a, b
			else -- a: d0, b: d1, c: d2, d: d3
				ndims, dims = 4, PrepDims(a, b, c, d)
			end

			return CallWrap("af_moddims", in_arr:get(), ndims, dims)
		end,

		--
		randn = DimsAndTypeFunc("af_randn"),

		--
		randu = DimsAndTypeFunc("af_randu"),

		--
		range = function(a, b, c, d, e, f)
			local dims, seq_dim, dtype

			if type(a) == "table" then -- a: dims, b: seq_dim, c: type
				dims, seq_dim, dtype = a, b, c
			else -- a: dim0, b: dim1, c: dim2, d: dim3, e: seq_dim, f: type
				dims, seq_dim, dtype = PrepDims(a, b, c, d), e, f
			end

			return CallWrap("af_range", GetNDims(dims), dims, seq_dim or -1, af[dtype or "f32"])
		end,

		--
		seq = array.NewSeq
	} do
		into[k] = v
	end
end

-- Export the module.
return M