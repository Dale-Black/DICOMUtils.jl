"""
    sortbytag(filepath, filepath_new, tag)
Sort DICOM files into folders by specific tags, using the format `tag=(0x0010,0x0010)`.
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
			new_dcm_dir = filepath_new * "/" * dcm_tag

			isdir(new_dcm_dir) || mkdir(new_dcm_dir)
			cp(dcm_path, new_dcm_dir * "/" * string(dir[file]))
		catch
			push!(error_paths, dcm_path)
		end
	end
	return error_paths
end