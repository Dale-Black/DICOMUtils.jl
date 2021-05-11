<div align="center">
<h1>DICOMUtils</h1>

Utility functions for working with DICOM files, built on top of [DICOM.jl](https://github.com/JuliaHealth/DICOM.jl)
</div>

<details><summary><b>Sorting</b></summary>
Example of `sortbytag` functionality

```julia
const PatientName = (0x0010,0x0010)

sortbytag(filepath, filepath_new, PatientName)
```
</details>