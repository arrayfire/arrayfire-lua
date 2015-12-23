--- Linear algebra functions.

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local Call = array.Call
local CallWrap = array.CallWrap
local IsArray = array.IsArray
local ToType = array.ToType

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/blas.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/lapack.cpp
-- https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/transpose.cpp

--
local function MatMul2 (a, b, opt_lhs, opt_rhs)
	opt_lhs, opt_rhs = opt_lhs or "AF_MAT_NONE", opt_rhs or "AF_MAT_NONE"

	return CallWrap("af_matmul", a:get(), b:get(), af[opt_lhs], af[opt_rhs])
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
		local ul, sl, vtl = Call(func, in_arr:get())

		s:set(sl)
		u:set(ul)
		vt:set(vtl)
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

			local res, info = Call("af_cholesky", in_arr:get(), is_upper)

			out:set(res)

			return info
		end,

		--
		choleskyInPlace = function(in_arr, is_upper)
			if is_upper == nil then
				is_upper = true
			end

			return Call("af_cholesky_inplace", in_arr:get(), is_upper)
		end,

		--
		det = function(rtype, arr)
			return ToType(rtype, Call("af_det", arr:get()))
		end,

		--
		dot = function(a, b, opt_lhs, opt_rhs)
			return CallWrap("af_dot", a:get(), b:get(), af[opt_lhs or "AF_MAT_NONE"], af[opt_rhs or "AF_MAT_NONE"])
		end,

		--
		inverse = function(arr, options)
			return CallWrap("af_inverse", arr:get(), af[options or "AF_MAT_NONE"])
		end,

		--
		lu = function(a, b, c, d)
			if IsArray(d) then -- a: lower, b: upper, c: pivot, d: in
				local l, u, p = Call("af_lu", d:get())

				a:set(l)
				b:set(u)
				c:set(p)
			else -- a: out, b: pivot, c: in, d: is_lapack_piv
				if d == nil then
					d = true
				end

				a:set(Call("af_copy_array", c:get()))
				b:set(Call("af_lu_inplace", a:get(), d))
			end
		end,

		--
		luInPlace = function(pivot, in_arr, is_lapack_piv)
			if is_lapack_piv == nil then
				is_lapack_piv = true
			end

			pivot:set(Call("af_lu_inplace", in_arr:get(), is_lapack_piv))
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
			return Call("af_norm", arr:get(), af[norm_type or "AF_NORM_EUCLID"], p or 1, q or 1)
		end,

		--
		qr = function(a, b, c, d)
			if IsArray(d) then -- a: q, b: r, c: tau, d: in
				local q, r, t = Call("af_qr", d:get())

				a:set(q)
				b:set(r)
				c:set(t)
			else -- a: out, b: tau, c: in
				a:set(Call("af_copy_array", c:get()))
				b:set(Call("af_qr_inplace", a:get()))
			end
		end,

		--
		qrInPlace = function(tau, in_arr)
			tau:set(Call("af_qr_inplace", in_arr:get()))
		end,

		--
		rank = function(arr, tol)
			return Call("af_rank", arr:get(), tol or 1e-5)
		end,

		--
		solve = function(a, b, options)
			return CallWrap("af_solve", a:get(), b:get(), af[options or "AF_MAT_NONE"])
		end,

		--
		solveLU = function(a, piv, b, options)
			return CallWrap("af_solve_lu", a:get(), piv:get(), b:get(), af[options or "AF_MAT_NONE"])
		end,

		--
		svd = SVD("af_svd"),

		--
		svdInPlace = SVD("af_svd_inplace"),

		--
		transpose = function(arr, conjugate)
			return CallWrap("af_transpose", arr:get(), conjugate)
		end,

		--
		transposeInPlace = function(arr, conjugate)
			return Call("af_transpose_inplace", arr:get(), conjugate)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M