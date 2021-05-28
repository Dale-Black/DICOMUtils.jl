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