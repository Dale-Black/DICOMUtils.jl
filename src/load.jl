"""
    load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
Given DICOM.DICOMData, `load_dcm_array` loads the pixels
into a 3D array and returns a tuple of the 3D array and the 
original DICOM.DICOMData
"""
function load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
	arr = cat([dcm_data[i][(0x7fe0,0x0010)] for i = 1:length(dcm_data)]..., dims=3)
	return (arr, dcm_data)
end