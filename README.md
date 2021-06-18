<div align="center">
<h1>DICOMUtils</h1>

Utility functions for working with DICOM files, built on top of [DICOM.jl](https://github.com/JuliaHealth/DICOM.jl)
</div>

<details><summary><b>Sorting</b></summary>
Example of `sortbytag_copy` functionality

```julia
const PatientName = (0x0010,0x0010)

sortbytag_copy(filepath, filepath_new, PatientName)
```
</details>

<details><summary><b>Loading</b></summary>
Example of `load_dcm_array` functionality

```julia
dcm_data = dcmdir_parse(dcmdir_path)

vol = load_dcm_array(dcm_data) # returns a 3D array (volume)
```
</details>

<details><summary><b>Orientation</b></summary>
Example showing how to get the affine matrix of a DICOM volume or slice

```julia
vol = DICOM.dcmdir_parse(volpath);
affine = DICOMUtils.get_affine(vol) 

#= 
returns
affine = [-0.625  0.0   0.0 159.688
		   0.0   -0.625 0.0 159.688
		   0.0    0.0   0.5 820.0
		   0.0    0.0   0.0   1.0]
=#
```

Given an affine matrix, turn the matrix into axcodes (e.g. "RAS")

```julia
axcodes = DICOMUtils.ornt2axcodes(DICOMUtils.io_orientation(affine))

#=
returns
axcodes = ["L", "P", "S"]
=#
```

Given a sequence of DICOM slices `Vector{DICOM.DICOMData}` one can
reorient the image array based on axcodes (e.g. "RAS")

```julia
orient = (("L", "P", "S"))
arrvol = DICOMUtils.load_dcm_array(vol)
arrvol, affvol, new_affvol = DICOMUtils.orientation(arrvol, orient)
```
</details>