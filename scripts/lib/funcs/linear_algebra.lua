--- Linear algebra functions.

-- Modules --
local af = require("arrayfire")
local array = require("lib.impl.array")

-- Imports --
local CallArr = array.CallArr
local CallArrWrap = array.CallArrWrap
local CallArr2Wrap = array.CallArr2Wrap
local CallArr3Wrap = array.CallArr3Wrap
local IsArray = array.IsArray
local SetHandle = array.SetHandle
local ToType = array.ToType

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/blas.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/lapack.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/transpose.cpp

--
local function MatMul2 (a, b, opt_lhs, opt_rhs)
	opt_lhs, opt_rhs = opt_lhs or "AF_MAT_NONE", opt_rhs or "AF_MAT_NONE"

	return CallArr2Wrap(af.af_matmul, a, b, af[opt_lhs], af[opt_rhs])
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
local function SVD (func)
	return function(u, s, vt, in_arr)
		local ul, sl, vtl = CallArr(func, in_arr)

		SetHandle(s, sl)
		SetHandle(u, ul)
		SetHandle(vt, vtl)
	end
end

--
function M.Add (into)
	for k, v in pairs{
		--
		cholesky = function(out, in_arr, is_upper)
			if is_upper == nil then
				is_upper = true
			end

			local res, info = CallArr(af.af_cholesky, in_arr, is_upper)

			SetHandle(out, res)

			return info
		end,

		--
		choleskyInPlace = function(in_arr, is_upper)
			if is_upper == nil then
				is_upper = true
			end

			return CallArr(af.af_cholesky_inplace, in_arr, is_upper)
		end,

		--
		det = function(rtype, arr)
			return ToType(rtype, CallArr(af.af_det, arr))
		end,

		--
		dot = function(a, b, opt_lhs, opt_rhs)
			return CallArr2Wrap(af.af_dot, a, b, af[opt_lhs or "AF_MAT_NONE"], af[opt_rhs or "AF_MAT_NONE"])
		end,

		--
		inverse = function(arr, options)
			return CallArrWrap(arr, af[options or "AF_MAT_NONE"])
		end,

		--
		lu = function(a, b, c, d)
			if IsArray(d) then -- a: lower, b: upper, c: pivot, d: in
				local l, u, p = CallArr(af.af_lu, d)

				SetHandle(a, l)
				SetHandle(b, u)
				SetHandle(c, p)
			else -- a: out, b: pivot, c: in, d: is_lapack_piv
				if d == nil then
					d = true
				end

				SetHandle(a, CallArr(af.af_copy_array, c))
				SetHandle(b, CallArr(af.af_lu_inplace, a, d))
			end
		end,

		--
		luInPlace = function(pivot, in_arr, is_lapack_piv)
			if is_lapack_piv == nil then
				is_lapack_piv = true
			end

			SetHandle(pivot, CallArr(af.af_lu_inplace, in_arr, is_lapack_piv))
		end,
	
		--
		matmul = function(a, b, c, d)
			if IsArray(d) then -- four arrays
				return MatMul4(a, b, c, d)
			elseif IsArray(c) then -- three arrays
				return MatMul3(a, b, c)
			else -- two arrays
				return MatMul2(a, b, c, d)
			end
		end,

		--
		matmulNT = function(a, b)
			return MatMul2(a, b, "AF_MAT_NONE", "AF_MAT_TRANS")
		end,
	
		--
		matmulTN = function(a, b)
			return MatMul2(a, b, "AF_MAT_TRANS", "AF_MAT_NONE")
		end,

		--
		matmulTT = function(a, b)
			return MatMul2(a, b, "AF_MAT_TRANS", "AF_MAT_TRANS")
		end,

		--
		norm = function(arr, norm_type, p, q)
			return CallArr(af.af_norm, af[norm_type or "AF_NORM_EUCLID"], p or 1, q or 1)
		end,

		--
		qr = function(a, b, c, d)
			if IsArray(d) then -- a: q, b: r, c: tau, d: in
				local q, r, t = CallArr(af.af_qr, d)

				SetHandle(a, q)
				SetHandle(b, r)
				SetHandle(c, t)
			else -- a: out, b: tau, c: in
				SetHandle(a, CallArr(af.af_copy_array, c))
				SetHandle(b, CallArr(af.af_qr_inplace, a))
			end
		end,

		--
		qrInPlace = function(tau, in_arr)
			SetHandle(tau, CallArr(af.af_qr_inplace, in_arr))
		end,

		--
		rank = function(arr, tol)
			return CallArr(af.af_rank, arr, tol or 1e-5)
		end,

		--
		solve = function(a, b, options)
			return CallArr2Wrap(af.af_solve, a, b, af[options or "AF_MAT_NONE"])
		end,

		--
		solveLU = function(a, piv, b, options)
			return CallArr3Wrap(af.af_solve_lu, a, piv, b, af[options or "AF_MAT_NONE"])
		end,

		--
		svd = SVD(af.af_svd),

		--
		svdInPlace = SVD(af.af_svd_inplace),

		--
		transpose = function(arr, conjugate)
			return CallArrWrap(af.af_transpose, arr, conjugate)
		end,

		--
		transposeInPlace = function(arr, conjugate)
			return CallArr(af.af_transpose_inplace, arr, conjugate)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M