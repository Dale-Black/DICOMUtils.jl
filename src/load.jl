"""
	dcm_list_builder(path)

Function to get list of DICOM files from a directory
"""
function dcm_list_builder(path)
    dcm_path_list = []
    for (dirpath, dirnames, filenames) in walkdir(path, topdown=true)
        if (dirpath in dcm_path_list) == false
            for filename in filenames
                try
                    tmp_str = string(dirpath, "/", filename)
                    ds = dcm_parse(tmp_str)
                    if (dirpath in dcm_path_list) == false
                        push!(dcm_path_list, dirpath)
					end
				catch
                    nothing
				end
			end
        else
                nothing
		end
	end
    return dcm_path_list
end

"""
	dcm_reader(dcm_path)

Read dcm_files from path. Path certainly contains DCM files, 
as tested by `dcm_list_builder` function
"""
function dcm_reader(dcm_path)
    dcm_files = []
    for (dirpath, dirnames, filenames) in walkdir(dcm_path, topdown=false)
        for filename in filenames
            try
                if (filename == "DIRFILE") == false   
                    dcm_file = string(dirpath, "/", filename)
                    dcm_parse(dcm_file)
                    push!(dcm_files, dcm_file)
				end
			catch
				nothing
			end
		end
	end

    read_RefDs = true
	local RefDs
    while read_RefDs
        for index in range(1, length(dcm_files))
            try
                RefDs = dcm_parse(dcm_files[index])
                read_RefDs = false
                break
			catch
                nothing
			end
		end
	end

	header = RefDs.meta
	slice_thick_ori = header[(0x0018, 0x0050)]
	rows, cols = Int(header[(0x0028, 0x0010)]), Int(header[(0x0028, 0x0011)])
    
    ConstPixelDims = (rows, cols, length(dcm_files))
    dcm_array = zeros(ConstPixelDims...)

    instances = []    
    for filenameDCM in dcm_files
        try
            ds = dcm_parse(filenameDCM)
			head = ds.meta
			InstanceNumber = head[(0x0020, 0x0013)]
            push!(instances, InstanceNumber)
		catch
            nothing
		end
	end
    
    sort!(instances)
    instances = unique(instances)

    index = 0
    for filenameDCM in dcm_files
        try
            ds = dcm_parse(filenameDCM)
			head = ds.meta
			InstanceNumber = head[(0x0020, 0x0013)]
			index = findall(x -> x==InstanceNumber, instances)
			pixel_array = head[(0x7fe0, 0x0010)]
            dcm_array[:, :, index] = pixel_array
            index += 1
		catch
            nothing
		end
	end
	
    RescaleSlope = header[(0x0028, 0x1053)]
	RescaleIntercept = header[(0x0028, 0x1052)]
    dcm_array = dcm_array .* RescaleSlope .+ RescaleIntercept
    return RefDs.meta, dcm_array, slice_thick_ori
end

"""
    load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
Given some DICOM.DICOMData, `load_dcm_array` loads the pixels
of each slice into a 3D array and returns the array
"""
function load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
    return array = cat(
        [dcm_data[i][(0x7fe0, 0x0010)] for i in 1:length(dcm_data)]...; dims=3
    )
end

"""
    get_pixel_size(header)

Get the pixel information of the DICOM image given the `header` info.
Returns the x, y, and z values, where `z` corresponds to slice thickness

"""
function get_pixel_size(header)
	head = copy(header)
	pixel_size = 
		try
			pixel_size = (head[(0x0028, 0x0030)])
            push!(pixel_size, head[(0x0018, 0x0050)])
		catch
			FOV = (head[(0x0018, 0x1100)])
			matrix_size = head[(0x0028, 0x0010)]
		
			pixel_size = FOV / matrix_size
            push!(pixel_size, head[(0x0018, 0x0050)])
		end
	return pixel_size
end
