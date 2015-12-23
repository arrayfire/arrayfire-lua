--- Core array module.

-- Standard library imports --
local error = error
local getmetatable = getmetatable
local rawequal = rawequal
local setmetatable = setmetatable
local tostring = tostring
local traceback = debug and debug.traceback
local type = type

-- Modules --
local af = require("arrayfire_lib")

-- Cached module references --
local _AddToCurrentEnvironment_
local _Call_
local _CallWrap_
local _CheckError_
local _GetConstant_
local _GetFNSD_
local _IsArray_
local _IsConstant_
local _ToArray_
local _WrapArray_

-- Exports --
local M = {}

-- --
local ArrayMethodsAndMetatable = {}

local MetaValue = {}

local Constants = setmetatable({}, { __mode = "k" })

--
local function ErrorOut (what)
	if traceback then
		print(traceback())
	end

	error(what)
end

--
local function CallFromName_Checked (name, ...)
	local func = af[name]

	if type(func) ~= "function" then
		if type(name) ~= "string" then
			ErrorOut("Expected string name, got: " .. tostring(name))
		else
			ErrorOut(name .. " is not a function")
		end
	end

	Name = name

	return _CheckError_(func(...))
end

--
local function CallFromName_Unchecked (name, ...)
	Name = name

	return _CheckError_(af[name](...))
end

-- --
local CallFromName

--- DOCME
-- @string name
-- @param ... Arguments to function.
-- @return Any non-error return values.
function M.Call (name, ...)
	return CallFromName(name, ...)
end

--
local function WrapAndReturn (arr, ...)
	return _WrapArray_(arr), ...
end

--- DOCME
-- @string name
-- @param ... Arguments to function.
-- @treturn LuaArray X
-- @return Any additional return values.
function M.CallWrap (name, ...)
	return WrapAndReturn(CallFromName(name, ...))
end

-- --
local SUCCESS = af.AF_SUCCESS

--- DOCME
-- @tparam af_err err
-- @param ...
-- @return ...
function M.CheckError (err, ...)
	if err ~= SUCCESS then
		local name = Name or ""

		Name = nil

		error(("%s: %i"):format(name, err))
	end

	return ...
end

--- DOCME
function M.CheckNames (check)
	CallFromName = check and CallFromName_Checked or CallFromName_Unchecked
end

-- --
local Dim = {}

--- DOCME
-- @tparam af_array ha
-- @int dim
-- @treturn int FNSD
function M.GetFNSD (ha, dim)
	if dim < 0 then
		local ndims = _Call_("af_get_numdims", ha)

		Dim[1], Dim[2], Dim[3], Dim[4] = _Call_("af_get_dims", ha)

		for i = 1, 4 do
			if Dim[i] > 1 then
				return i - 1
			end
		end

		return 0
	else
		return dim
	end
end

--- DOCME
-- @tparam Constant k
-- @return R
function M.GetConstant (k)
	return Constants[k] and k[1]
end

--- DOCME
-- @tparam LuaArray arr
-- @treturn ?|af_array|nil X
function M.GetHandle (arr)
-- TODO: If proxy, add reference?
	return arr.m_handle
end

-- --
local Lib

--- DOCME
function M.GetLib ()
	Lib = Lib or require("arrayfire")
	return Lib
end

--- DOCME
-- @tparam function func
-- @tparam LuaArray arr
-- @number[opt=-1] dim
-- @string[opt] how
-- @return Results of _func_.
function M.HandleDim (func, arr, dim, how)
	local harr = arr:get()

	return (how ~= "no_wrap" and _CallWrap_ or _Call_)(func, harr, _GetFNSD_(harr, dim or -1))
end

--- DOCME
-- @param item
-- @treturn boolean B
function M.IsArray (item)
	return rawequal(getmetatable(item), MetaValue) and not Constants[item]
end

--- DOCME
-- @param item
-- @treturn boolean B
function M.IsConstant (item)
	return not not Constants[item] -- metatable redundant; coerce to false if missing
end

-- TODO: IsProxy(), MakeProxy()...

--- DOCME
-- @tparam LuaArray arr
-- @tparam ?|af_array|nil handle
function M.SetHandle (arr, handle)
-- TODO: disable for proxies
	local cur = arr.m_handle

	if cur ~= nil then
		_Call_("af_release_array", cur)
	end

	arr.m_handle = handle
end

-- --
local Args = {}

--- DOCME
-- @param value
-- @tparam LuaArray other
-- @treturn LuaArray A
function M.ToArray (value, other)
	if _IsConstant_(value) then
		value = _GetConstant_(value)
	end

	local btype, hother = type(value), other:get()
	local ndims = _Call_("af_get_numdims", hother)

	Args[1], Args[2], Args[3], Args[4] = _Call_("af_get_dims", hother)

	if btype == "table" then
		-- Complex...
	elseif btype == "number" then
		-- Argh... detect range, integer-ness, etc?

		return _Call_("af_constant", value, ndims, Args, af.f32)
	end
end

--- DOCME
-- @string ret_type
-- @param real
-- @param imag
-- @treturn RetType RT
function M.ToType (ret_type, real, imag)
	if rtype == "c32" or rtype == "c64" then
		return { real = real, imag = imag }
	else
		return real -- TODO: Improve this!
	end
end

--- DOCME
-- @string name
-- @param a
-- @param b
-- @param ...
-- @treturn LuaArray X
function M.TwoArrays (name, a, b, ...)
	local atemp, btemp, ha, hb

	if not _IsArray_(a) then
		hb, ha, atemp = b:get(), _ToArray_(a, b), true
	elseif not _IsArray_(b) then
		ha, hb, btemp = a:get(), _ToArray_(b, a), true
	else
		ha, hb = a:get(), b:get()
	end

	--
	local err, arr = af[name](ha, hb, ...)

	if atemp or btemp then
		_Call_("af_release_array", atemp and ha or hb)
	end

	Name = name

	_CheckError_(err)

	return _WrapArray_(arr)
end

--- DOCME
-- @tparam af_array arr
-- @treturn LuaArray X
function M.WrapArray (arr)
	local wrapped = setmetatable({ m_handle = arr }, ArrayMethodsAndMetatable)

	_AddToCurrentEnvironment_("array", wrapped)

	return wrapped
end

--- DOCME
-- @param k constant
-- @treturn Constant Y
function M.WrapConstant (k)
	k = { k }

	Constants[k] = true

	return setmetatable(k, ArrayMethodsAndMetatable) -- allow comparison operators
end

--
for _, v in ipairs{
	"impl.ephemeral",
	"impl.operators",
	"impl.seq", -- depends on ephemeral
	"impl.index", -- depends on ephemeral, seq
	"methods.methods"
} do
	require(v).Add(M, ArrayMethodsAndMetatable)
end

ArrayMethodsAndMetatable.__index = ArrayMethodsAndMetatable
ArrayMethodsAndMetatable.__metatable = MetaValue

-- Register array environment type.
M.RegisterEnvironmentCleanup("array", function(arr)
	local ha = arr:get()

	arr.m_handle = nil -- set() can error out

	return not ha or af.af_release_array(ha) == SUCCESS
	-- TODO: pooling?
end, "Errors releasing %i arrays")
-- TODO: Register "array_proxy"?

-- By default, check valid names.
M.CheckNames(true)

-- Cache module members.
_AddToCurrentEnvironment_ = M.AddToCurrentEnvironment
_Call_ = M.Call
_CallWrap_ = M.CallWrap
_CheckError_ = M.CheckError
_GetConstant_ = M.GetConstant
_GetFNSD_ = M.GetFNSD
_IsArray_ = M.IsArray
_IsConstant_ = M.IsConstant
_ToArray_ = M.ToArray
_WrapArray_ = M.WrapArray

-- Export the module.
return M
