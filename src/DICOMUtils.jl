module DICOMUtils

using DICOM
using LinearAlgebra

include("./load.jl")
include("./orientation.jl")
include("./sort.jl")

export
    # Export load.jl functions
    dcm_list_builder,
    dcm_reader,
    load_dcm_array,
    get_pixel_size,

    # Export orientation.jl functions
    get_affine,
    io_orientation,
    axcodes2ornt,
    ornt2axcodes,
    ornt_transform,
    apply_orientation,
    inv_ornt_aff,

    # Export sort.jl functions
    sortbytag_copy,
    sortbytag_move

end
