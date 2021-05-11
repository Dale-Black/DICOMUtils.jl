# DICOMUtils

Utility functions for working with DICOM files, built on top of DICOM.jl

<details><summary><b>Sorting</b></summary>
Example of using `sortbytag`
```julia
const PatientName = (0x0010,0x0010)

sortbytag(filepath, filepath_new, PatientName)
```
</details>
