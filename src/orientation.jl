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

"""
	ornt_transform(start_ornt, end_ornt)

Return the orientation that transforms from `start_ornt` to `end_ornt`

Ported from nibabel
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L309)

Parameters
----------
start_ornt : (n,2) orientation array
	Initial orientation.
end_ornt : (n,2) orientation array
	Final orientation.

Returns
-------
orientations : (p, 2) array
	The orientation that will transform the `start_ornt` to the `end_ornt`.
"""
function ornt_transform(start_ornt, end_ornt)
	@assert size(start_ornt) == size(end_ornt)
	
	result = Array{Float64}(undef, size(start_ornt))
	for (end_in_idx, (end_out_idx, end_flip)) in enumerate(eachrow(end_ornt))
		for (start_in_idx, (start_out_idx, start_flip)) in enumerate(eachrow(start_ornt))
			if (end_out_idx == start_out_idx)
				if (start_flip == end_flip)
					flip = 1
				else
					flip = -1
				end
				result[start_in_idx, :] = [end_in_idx, flip]
				break
			end
		end
	end
	return result
end

"""
	apply_orientation(arr, ornt)
	
Apply transformations implied by `ornt` to the first n axes of the array `arr`

Ported from nibabel
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L309)

Parameters
----------
arr : array-like of data with ndim >= n
ornt : (n,2) orientation array
   orientation transform. ``ornt[N,1]` is flip of axis N of the
   array implied by `shape`, where 1 means no flip and -1 means
   flip.  For example, if ``N==0`` and ``ornt[0,1] == -1``, and
   there's an array ``arr`` of shape `shape`, the flip would
   correspond to the effect of ``np.flipud(arr)``.  ``ornt[:,0]`` is
   the transpose that needs to be done to the implied array, as in
   ``arr.transpose(ornt[:,0])``

Returns
-------
t_arr : array
   data array `arr` transformed according to ornt
"""
function apply_orientation(arr, ornt)
	t_arr = arr
	n = size(ornt)[1]
	if (length(size(t_arr)) < n)
		error("Data array has fewer dimensions than `orientation`")
	end
	for (ax, flip) in enumerate(ornt[:,2])
		if (flip == -1)
			t_arr = reverse(t_arr, dims=ax)
		end
	end
	full_transpose = collect(1:length(size(t_arr)))
	full_transpose[1:n] = sortperm(ornt[:,1])
	t_arr = permutedims(t_arr, full_transpose)
end