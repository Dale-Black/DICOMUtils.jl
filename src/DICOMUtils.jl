module DICOMUtils

using DICOM
using LinearAlgebra

include("./load.jl")
include("./orientation.jl")
include("./sort.jl")

export
    # Export load.jl functions
    load_dcm_array,

    # Export orientation.jl functions
    io_orientation,
    axcodes2ornt,
    ornt_transform,
    apply_orientation,

    # Export sort.jl functions
    sortbytag_copy,
    sortbytag_move

end
