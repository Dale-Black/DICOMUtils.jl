"""
    sortbytag(filepath, filepath_new, tag)
Sort DICOM files into folders by specific tags, using the format `tag=(0x0010,0x0010)`.
Returns an array of filepaths that were unable to be copied for whatever reason.
For more information look at DICOM.jl and https://www.dicomlibrary.com/dicom/dicom-tags/
"""
function sortbytag(filepath, filepath_new, tag)
	dir = readdir(filepath)
	error_paths = []
	for file = 1:length(dir)
		dcm_path = filepath * "/" * dir[file]
		try
			dcm = DICOM.dcm_parse(dcm_path)
			dcm_tag = string(dcm[tag])
			if occursin("\\", dcm_tag)
				dcm_tag = replace(dcm_tag, "\\" => "_")
			end
			new_dcm_dir = filepath_new * "/" * dcm_tag

			isdir(new_dcm_dir) || mkdir(new_dcm_dir)
			cp(dcm_path, new_dcm_dir * "/" * string(dir[file]))
		catch
			push!(error_paths, dcm_path)
		end
	end
	return error_paths
end

"""
    sortbytag_move(filepath, filepath_new, tag)
Just like `sortbytag` but instead of copying the DICOM file, the file is moved
into a new folder. Everything else is the same as before. Returns an array of
filepaths that were unable to be moved for whatever reason.
"""
function sortbytag_move(filepath, filepath_new, tag)
	dir = readdir(filepath)
	error_paths = []
	for file = 1:length(dir)
		dcm_path = filepath * "/" * dir[file]
		try
			dcm = DICOM.dcm_parse(dcm_path)
			dcm_tag = string(dcm[tag])
			if occursin("\\", dcm_tag)
				dcm_tag = replace(dcm_tag, "\\" => "_")
			end
			new_dcm_dir = filepath_new * "/" * dcm_tag

			isdir(new_dcm_dir) || mkdir(new_dcm_dir)
			mv(dcm_path, new_dcm_dir * "/" * string(dir[file]))
		catch
			push!(error_paths, dcm_path)
		end
	end
	return error_paths
end