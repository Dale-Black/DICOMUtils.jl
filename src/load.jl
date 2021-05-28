"""
    load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
Given some DICOM.DICOMData, `load_dcm_array` loads the pixels
of each slice into a 3D array and returns the array
"""
function load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
	array = cat([dcm_data[i][(0x7fe0,0x0010)] for i = 1:length(dcm_data)]..., dims=3)
end