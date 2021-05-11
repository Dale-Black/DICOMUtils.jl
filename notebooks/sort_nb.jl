### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 3ae1dd50-aeb0-11eb-3fb1-77aa043fe6e4
begin
	let
		# Set up temporary environment
		env = mktempdir()
		import Pkg
		Pkg.activate(env)
		Pkg.Registry.update()
		
		# Download packages
		Pkg.add("PlutoUI")
		Pkg.add("DICOM")
	end
	
	# Import packages
	using PlutoUI
	using DICOM
end

# ╔═╡ 16e05577-e692-41a7-b969-f260f0141af6
md"""
## Set up
"""

# ╔═╡ 8b40bea7-4a23-4f4d-8daf-9cff851dc4ac
TableOfContents()

# ╔═╡ b29bd465-7fb5-4b72-b378-972f43dc011f
md"""
## Filepaths
"""

# ╔═╡ 418ac8e5-f6a5-4305-bd6e-f786174eb024
filepath = "/Volumes/NeptuneData/Datasets/DynamicPhantom/DICOM/D202104/test_small";

# ╔═╡ 3efeaf94-1f43-4132-857e-e5c2aa3578de
filepath_new = "/Volumes/NeptuneData/Datasets/DynamicPhantom/DICOM/D202104/test_small_new";

# ╔═╡ c90d16f7-919d-45c9-a904-676a3acc2b1d
isdir(filepath_new) || mkdir(filepath_new)

# ╔═╡ 71a99e79-ae78-49f0-8baa-8901dbaf19ae
md"""
## Sorting
"""

# ╔═╡ d8725163-1c2e-469b-afff-94d3be585f58
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

# ╔═╡ 17575e39-2a94-4160-b563-7632eafe046e
const SeriesNumber = (0x0020,0x0011)

# ╔═╡ 17579e7f-aba5-4e95-ac78-9aed97b9c93f
const AccessionNumber = (0x0008,0x0050)

# ╔═╡ 6a8779af-6c69-41cf-81a5-9358712888c1
const PatientName = (0x0010,0x0010)

# ╔═╡ 66e73828-1d20-4ebd-ae46-33d866f56dd9
sortbytag(filepath, filepath_new, PatientName)

# ╔═╡ Cell order:
# ╟─16e05577-e692-41a7-b969-f260f0141af6
# ╠═3ae1dd50-aeb0-11eb-3fb1-77aa043fe6e4
# ╠═8b40bea7-4a23-4f4d-8daf-9cff851dc4ac
# ╟─b29bd465-7fb5-4b72-b378-972f43dc011f
# ╠═418ac8e5-f6a5-4305-bd6e-f786174eb024
# ╠═3efeaf94-1f43-4132-857e-e5c2aa3578de
# ╠═c90d16f7-919d-45c9-a904-676a3acc2b1d
# ╟─71a99e79-ae78-49f0-8baa-8901dbaf19ae
# ╠═d8725163-1c2e-469b-afff-94d3be585f58
# ╠═17575e39-2a94-4160-b563-7632eafe046e
# ╠═17579e7f-aba5-4e95-ac78-9aed97b9c93f
# ╠═6a8779af-6c69-41cf-81a5-9358712888c1
# ╠═66e73828-1d20-4ebd-ae46-33d866f56dd9
