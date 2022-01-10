"""
    get_affine(vol::Vector{DICOM.DICOMData})
    get_affine(slice::DICOM.DICOMData)

Extracts the affine matrix from the DICOM header of the input
volume or slice.

# Arguments

- `vol::Vector{DICOM.DICOMData}`: 3D DICOM volume or sequence of 2D DICOM
    slices
- `slice::DICOM.DICOMData`: 2D DICOM slice
"""
function get_affine(vol::Vector{DICOM.DICOMData})
	ImageOrientation = (0x0020, 0x0037)
	PixelSpacing = (0x0028, 0x0030)
	ImagePosition = (0x0020, 0x0032)

	img_ornt = vol[1][ImageOrientation]
	pix_space = vol[1][PixelSpacing]
	img_position = vol[1][ImagePosition]

	F11, F21, F31 = img_ornt[1:4]
	F12, F22, F32 = img_ornt[4:end]
	dr, dc = pix_space
	Sx, Sy, Sz = img_position

	a = [F11*dr F12*dc 0 Sx
		 F21*dr F22*dc 0 Sy
		 F31*dr F32*dc 0 Sz
		 0 0 0 1]
    return a
end

function get_affine(slice::DICOM.DICOMData)
	ImageOrientation = (0x0020, 0x0037)
	PixelSpacing = (0x0028, 0x0030)
	ImagePosition = (0x0020, 0x0032)

	img_ornt = vol[1][ImageOrientation]
	pix_space = vol[1][PixelSpacing]
	img_position = vol[1][ImagePosition]

	F11, F21, F31 = img_ornt[1:4]
	F12, F22, F32 = img_ornt[4:end]
	dr, dc = pix_space
	Sx, Sy, Sz = img_position

	a = [F11*dr F12*dc 0 Sx
		 F21*dr F22*dc 0 Sy
		 F31*dr F32*dc 0 Sz
		 0 0 0 1]
    return a
end

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
    q, p = size(affine)[1] - 1, size(affine)[2] - 1
    RZS = affine[1:q, 1:p]
    A = RZS * RZS
    zooms = sqrt.(sum(A; dims=1))
    zooms[map(x -> x == 0.0, zooms)] .= 1
    RS = RZS ./ zooms
    P, S, Qs = svd(collect(RS))
    if (tol === nothing)
        tol = maximum(S) * maximum(size(RS)) * floatmin(Float64.(S[1]))
    end
    keep = S .> tol
    R = P[:, keep] * Qs[keep, :]
    ornt = Int8.(ones((p, 2))) .* NaN
    for in_ax in 1:p
        col = R[:, in_ax]
        if ((all(x -> x == 0.0, col)) == false)
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
                    ornt[code_idx, :] = [label_idx, -1]
                else
                    ornt[code_idx, :] = [label_idx, 1]
                    break
                end
            end
        end
    end
    return ornt
end

"""
    ornt2axcodes(ornt, labels=nothing)

Convert orientation `ornt` to labels for axis directions

Ported from nibabel
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L309)

Parameters
----------
ornt : (N,2) array-like
    orientation array - see io_orientation docstring
labels : optional, None or sequence of (2,) sequences
    (2,) sequences are labels for (beginning, end) of output axis.  That
    is, if the first row in `ornt` is ``[1, 1]``, and the second (2,)
    sequence in `labels` is ('back', 'front') then the first returned axis
    code will be ``'front'``.  If the first row in `ornt` had been
    ``[1, -1]`` then the first returned value would have been ``'back'``.
    If None, equivalent to ``(('L','R'),('P','A'),('I','S'))`` - that is -
    RAS axes.
Returns
-------
axcodes : (N,) tuple
    labels for positive end of voxel axes.  Dropped axes get a label of
    None.
"""
function ornt2axcodes(ornt, labels=nothing)
	if labels == nothing
		labels = collect(zip(["L" "P" "I"], ["R", "A", "S"]))
	end
    axcodes = []
	 for row in eachrow(ornt)
		axno, direction = row[1], row[2]
        if isnan(axno)
            push!(axcodes, nothing)
            continue
		end
		axint = Int(round(axno))
		if axint != axno
			error("Non integer axis number $(axno)")
		elseif direction == 1
			axcode = labels[axint][2]
		elseif direction == -1
			axcode = labels[axint][1]
		else
			error("Direction should be -1 or 1")
		end
		push!(axcodes, axcode)
	end
    return axcodes
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
    for (ax, flip) in enumerate(ornt[:, 2])
        if (flip == -1)
            t_arr = reverse(t_arr; dims=ax)
        end
    end
    full_transpose = collect(1:length(size(t_arr)))
    full_transpose[1:n] = sortperm(ornt[:, 1])
    return t_arr = permutedims(t_arr, full_transpose)
end

"""
	inv_ornt_aff(ornt, shape::AbstractArray)

Affine transform reversing transforms implied in `ornt`

Ported from nibabel
(https://github.com/nipy/nibabel/blob/e51bcb43d9c6f5ad329ffb230afda0c26b9e8617/nibabel/orientations.py#L309)

Imagine you have an array ``arr`` of shape `shape`, and you apply the
    transforms implied by `ornt` (more below), to get ``tarr``.
    ``tarr`` may have a different shape ``shape_prime``.  This routine
    returns the affine that will take a array coordinate for ``tarr``
    and give you the corresponding array coordinate in ``arr``.
    Parameters
    ----------
    ornt : (p, 2) ndarray
       orientation transform. ``ornt[P, 1]` is flip of axis N of the array
       implied by `shape`, where 1 means no flip and -1 means flip.  For
       example, if ``P==0`` and ``ornt[0, 1] == -1``, and there's an array
       ``arr`` of shape `shape`, the flip would correspond to the effect of
       ``np.flipud(arr)``.  ``ornt[:,0]`` gives us the (reverse of the)
       transpose that has been done to ``arr``.  If there are any NaNs in
       `ornt`, we raise an ``OrientationError`` (see notes)
    shape : length p sequence
       shape of array you may transform with `ornt`
	
    Returns
    -------
    transform_affine : (p + 1, p + 1) ndarray
       An array ``arr`` (shape `shape`) might be transformed according to
       `ornt`, resulting in a transformed array ``tarr``.  `transformed_affine`
       is the transform that takes you from array coordinates in ``tarr`` to
       array coordinates in ``arr``.

    Notes
    -----
    If a row in `ornt` contains NaN, this means that the input row does not
    influence the output space, and is thus effectively dropped from the output
    space.  In that case one ``tarr`` coordinate maps to many ``arr``
    coordinates, we can't invert the transform, and we raise an error

"""
function inv_ornt_aff(ornt, shape::AbstractArray)
    if any(x -> x === NaN, ornt)
        error("Cannot invert the orientation transform")
    end
    p = size(ornt)[1]
    shape = shape[1:p]
    axis_transpose = [Int(v) for v in ornt[:, 1]]
    undo_reorder = I(p + 1)[append!(axis_transpose, p + 1), :]
    undo_flip = Float64.(diagm(append!(ornt[:, 2], 1)))
    center_trans = -(shape .- 1) ./ 2.0
    undo_flip[1:p, p + 1] = (ornt[:, 2] .* center_trans) .- center_trans
    return undo_flip * undo_reorder
end

"""
	orientation(data_array, axcodes=nothing, affine=nothing, as_closest_canonical=false,
				labels=zip(["L" "P" "I"], ["R", "A", "S"]))

Change the input image's orientation into the specified based on `axcodes`

Ported from Monai
(https://docs.monai.io/en/latest/_modules/monai/transforms/spatial/array.html#Orientation)
"""
function orientation(
    data_array,
    axcodes=nothing,
    affine=nothing,
    as_closest_canonical=false,
    labels=zip(["L" "P" "I"], ["R" "A" "S"]),
)
    sr = length(size(data_array)) - 1
    if (sr ≤ 0)
        error("data_array must have at least one spatial dimension.")
    end
    if (affine === nothing)
        affine = Float64.(I(sr + 1))
        affine_ = Float64.(I(sr + 1))
    else
        affine_ = affine
    end
    src = io_orientation(affine_)

    if as_closest_canonical
        spatial_ornt = src
    else
        if (axcodes === nothing)
            error("error")
        end
        dst = axcodes2ornt(axcodes[1:sr], labels)
        if (length(dst) .< sr)
            error("axcodes must match data_array spatially")
        end
        spatial_ornt = ornt_transform(src, dst)
    end
    ornt = copy(spatial_ornt)
    ornt[:, 1] .+= 1
    ornt = cat([1 1], ornt; dims=1)
    shape = size(data_array)[2:end]
    data_array = apply_orientation(data_array, ornt)
    new_affine = inv_ornt_aff(spatial_ornt, collect(shape))
    return data_array, affine, new_affine
end