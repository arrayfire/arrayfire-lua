--- Linear algebra functions.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CheckError = array.CheckError
local GetHandle = array.GetHandle
local IsArray = array.IsArray
local NewArray = array.NewArray

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/blas.cpp

--
local function MatMul2 (a, b, opt_lhs, opt_rhs)
	opt_lhs, opt_rhs = opt_lhs or "AF_MAT_NONE", opt_rhs or "AF_MAT_NONE"

	local arr = CheckError(af.af_matmul(GetHandle(a), GetHandle(b), af[opt_lhs], af[opt_rhs]))

	return NewArray(arr)
end

--
local function MatMulNT (a, b)
	return MatMul2("AF_MAT_NONE", "AF_MAT_TRANS")
end

--
local function MatMulTN (a, b)
	return MatMul2("AF_MAT_TRANS", "AF_MAT_NONE")
end

--
local function MatMulTT (a, b)
	return MatMul2("AF_MAT_TRANS", "AF_MAT_TRANS")
end

--
local function MatMul3 (a, b, c)
	local tmp1 = a:dims(0) * b:dims(1)
	local tmp2 = b:dims(0) * c:dims(1)

	if tmp1 < tmp2 then
		return MatMul2(MatMul2(a, b), c)
	else
		return MatMul2(a, MatMul2(b, c))
	end
end

--
local function MatMul4 (a, b, c, d)
    local tmp1 = a:dims(0) * c:dims(1)
    local tmp2 = b:dims(0) * d:dims(1)

    if tmp1 < tmp2 then
        return MatMul2(MatMul3(a, b, c), d)
    else
        return MatMul2(a, MatMul3(b, c, d))
    end
end

--
local function MatMul (a, b, c, d)
	if IsArray(d) then
		return MatMul4(a, b, c, d)
	elseif IsArray(c) then
		return MatMul3(a, b, c)
	else
		return MatMul2(a, b, c, d)
	end
end

--
local function Dot (a, b, opt_lhs, opt_rhs)
	local arr = CheckError(af.af_dot(a, b, af[opt_lhs or "AF_MAT_NONE"], af[opt_rhs or "AF_MAT_NONE"]))

	return NewArray(arr)
end

--
function M.Add (into)
	for k, v in pairs{
		dot = Dot,
		matmul = MatMul,
		matmulNT = MatMulNT,
		matmulTN = MatMulTN,
		matmulTT = MatMulTT
	} do
		into[k] = v
	end
end

-- Export the module.
return M