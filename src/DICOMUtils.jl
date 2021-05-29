module DICOMUtils

using DICOM

include("./sort.jl")

export
    # Export sort.jl functions
    sortbytag_copy,
    sortbytag_move,
    load_dcm_array

end
