"""
    io_orientation(affine, tol=nothing)

Orientation of input axes in terms of output axes for `affine`

Ported from nibabel 
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L22)

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
	if (tol === nothing)
		tol = maximum(S) * maximum(size(RS)) * floatmin(typeof(S[1]))
	end
	keep = S .> tol
	R = P[:,keep] * Qs[keep, :]
	ornt = Int8.(ones((p, 2))) .* NaN
	for in_ax = 1:p
		col = R[:, in_ax]
		if ((all(x->x==0.0, col)) == false)
			out_ax = argmax(abs.(col))
			ornt[in_ax, 1] = out_ax
			@assert col[out_ax] != 0
			if col[out_ax] < 0
				ornt[in_ax, 2] = -1
			else
				ornt[in_ax, 2] = 1
			end
			R[out_ax, :] .= 0
		end
	end
	return ornt
end

"""
	axcodes2ornt(axcodes, labels=nothing)

Convert axis codes `axcodes` to an orientation

Ported from nibabel
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L309)

Parameters
----------
axcodes : (N,) tuple
	axis codes - see ornt2axcodes docstring
labels : optional, None or sequence of (2,) sequences
	(2,) sequences are labels for (beginning, end) of output axis.  That
	is, if the first element in `axcodes` is ``front``, and the second
	(2,) sequence in `labels` is ('back', 'front') then the first
	row of `ornt` will be ``[1, 1]``. If None, equivalent to
	``(('L','R'),('P','A'),('I','S'))`` - that is - RAS axes.
Returns
-------
ornt : (N,2) array-like
	orientation array - see io_orientation docstring

"""
function axcodes2ornt(axcodes, labels=nothing)
	if (labels === nothing)
		labels = zip(["L" "P" "I"], ["R", "A", "S"])
	else
		labels = labels
	end
	n_axes = length(axcodes)
	ornt = Int8.(ones(n_axes, 2)) .* NaN
	for (code_idx, code) in enumerate(axcodes)
		for (label_idx, codes) in enumerate(labels)
			# println(label_idx, codes)
			if (code == nothing)
				continue
			end
			if (code in codes)
				if (code == codes[1])
					ornt[code_idx,:] = [label_idx, -1]
				else
					ornt[code_idx,:] = [label_idx, 1]
					break
				end
			end
		end
	end
	return ornt
end