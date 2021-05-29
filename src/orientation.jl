"""
    io_orientation(affine, tol=nothing)
Ported from nibabel in Python.
Orientation of input axes in terms of output axes for `affine`

Parameters
----------
affine : (q+1, p+1) Array
Transformation affine from ``p`` inputs to ``q`` outputs.  Usually this
will be a shape (4,4) matrix, transforming 3 inputs to 3 outputs, but
the code also handles the more general case
tol : {None, float}, optional
threshold below which SVD values of the affine are considered zero. If
`tol` is None, and `S` is an array with singular values for `affine`,
and `eps` is the epsilon value for datatype of `S`, then `tol` set
to `maximum(S) * maximum(size(RS)) * floatmin(typeof(S[1]))`

Returns
-------
orientations : (p, 2) Array
one row per input axis, where the first value in each row is the closest
corresponding output axis. The second value in each row is 1 if the
input axis is in the same direction as the corresponding output axis and
-1 if it is in the opposite direction.  If a row is [NaN, NaN],
which can happen when p > q, then this row should be considered dropped.
"""
function io_orientation(affine, tol=nothing)
	q, p = size(affine)[1]-1, size(affine)[2]-1
	RZS = affine[1:q, 1:p]
	A = RZS * RZS
	zooms = sqrt.(sum(A, dims=1))
	zooms[map(x -> x == 0.0, zooms)] .= 1
	RS = RZS ./ zooms
	P, S, Qs = svd(RS)
	if (tol == nothing)
		tol = maximum(S) * maximum(size(RS)) * floatmin(typeof(S[1]))
	end
	keep = S .> tol
	R = P[:,keep] * Qs[:,keep]
	ornt = Int8.(ones((p, 2))) .* NaN
	for in_ax = 1:p
		col = R[:, in_ax]
		if (typeof(col) != typeof(0)) || (isapprox(col, 0) != true) # needs work
			out_ax = argmax(abs.(col))
			ornt[in_ax, 1] = out_ax
			@assert col[out_ax] != 0\
			if col[out_ax] < 0
				ornt[in_ax, 2] = -1
			else
				ornt[in_ax, 2] = 1
			end
			R[out_ax, :] .= 0
			println(R)
		end
	end
	return ornt
end