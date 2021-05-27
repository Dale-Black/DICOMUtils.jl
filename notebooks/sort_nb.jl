### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 8c1ba773-e9ca-4269-9519-d893b4e062e8
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
		Pkg.add(Pkg.PackageSpec(url="https://github.com/Dale-Black/DICOMUtils.jl"))
	end
	
	# Import packages
	using PlutoUI
	using DICOM
	using DICOMUtils
end

# ╔═╡ bae6661b-1e81-4006-b52a-76938bfafa2a
md"""
## Set up
"""

# ╔═╡ dcf61796-1f8b-414c-9854-5b62ae653ddb
TableOfContents()

# ╔═╡ 2d9983f2-b9ae-424d-bb0e-90ca7b89aee7
filepath_new = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\clean_data";

# ╔═╡ 6ba2428e-9507-4b74-a815-0a59a4d5feb2
isdir(filepath_new) || mkdir(filepath_new)

# ╔═╡ 0d171ffa-e5f0-4148-b553-e4fa240a91e5
md"""
## 1. Organize by PatientName
Not needed, already completed
"""

# ╔═╡ 5765c970-67b6-4f58-9b38-66dca0681d03
filepath = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\DD2710";

# ╔═╡ 8f2f872e-2916-4bc5-bd72-1ece24e5c8a7
const PatientName = (0x0010,0x0010)

# ╔═╡ edaf8e6f-edcd-43c6-8c12-de5839a95bf9
# DICOMUtils.sortbytag_move(filepath, filepath_new, PatientName)

# ╔═╡ 2f3f06fe-7db4-42c3-b84e-d7a81da85983
md"""
## 2. Organize by SeriesNumber
"""

# ╔═╡ d13b882a-e91b-451e-bec0-e0e7b1aff6de
const SeriesNumber = (0x0020,0x0011)

# ╔═╡ 7503aac9-f9c2-4c0d-ab1c-42088e82211e
config1_path = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\clean_data\CONFIG 8^350";

# ╔═╡ 79b490af-264c-4bb8-832f-ca38795ba002
# DICOMUtils.sortbytag_move(config1_path, config1_path, SeriesNumber)

# ╔═╡ 8cb32b19-5d78-4327-af3e-b00d279b55c3
md"""
## 3a. Organize by kVp
This should be done for the static (0 bpm) helical scan folders
"""

# ╔═╡ 0c1379e4-9576-459a-94cb-ad8f190e122e
const kVp = (0x0018,0x0060)

# ╔═╡ a1a24093-ae31-42ec-a8ca-adf197c3232a
kv_path = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\clean_data\CONFIG 6^275\54"

# ╔═╡ a1fab547-777d-4511-94ea-5a9966c88cea
 # DICOMUtils.sortbytag_move(kv_path, kv_path, kVp)

# ╔═╡ 5500af3a-06b3-47c1-8594-6ac5aeff6bc4
md"""
## 3b. Organize by ImageComments
This should be done for the dynamic (60, 80, 100 bpm) helical scan folders
"""

# ╔═╡ ae75f4be-82d9-4a0f-9430-2b72e8c58525
const ImageComments =  (0x0020,0x4000)

# ╔═╡ 71fb31d3-a204-49ac-9683-4265058cd014
hel_path = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\clean_data\CONFIG 7^275\49"

# ╔═╡ 4563ad8d-e2f3-4cc0-a95f-491d40be2408
# DICOMUtils.sortbytag_move(hel_path, hel_path, ImageComments)

# ╔═╡ 238ee3f5-3f1b-432d-acd2-29035c0a0791
md"""
## (Extra) Sort through every directory at once
"""

# ╔═╡ 3eb6343a-1f78-47ac-96f8-e2bfb82d7b2b
head_dir = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom"

# ╔═╡ 85f3fcd7-d644-4fe0-9233-3374aa2b9bdb
dirs = readdir(head_dir)

# ╔═╡ abc8e616-20ce-487d-aa56-028fe4a5f9e3
head_dir * "/" * dirs[1]

# ╔═╡ 2be55e24-1478-4e94-a02d-71b999c52117
# for i = 1:(length(dirs) - 1)
# 	DICOMUtils.sortbytag_move(head_dir * "/" * dirs[i], filepath_new, PatientName)
# end

# ╔═╡ Cell order:
# ╟─bae6661b-1e81-4006-b52a-76938bfafa2a
# ╠═8c1ba773-e9ca-4269-9519-d893b4e062e8
# ╟─dcf61796-1f8b-414c-9854-5b62ae653ddb
# ╠═2d9983f2-b9ae-424d-bb0e-90ca7b89aee7
# ╠═6ba2428e-9507-4b74-a815-0a59a4d5feb2
# ╟─0d171ffa-e5f0-4148-b553-e4fa240a91e5
# ╠═5765c970-67b6-4f58-9b38-66dca0681d03
# ╠═8f2f872e-2916-4bc5-bd72-1ece24e5c8a7
# ╠═edaf8e6f-edcd-43c6-8c12-de5839a95bf9
# ╟─2f3f06fe-7db4-42c3-b84e-d7a81da85983
# ╠═d13b882a-e91b-451e-bec0-e0e7b1aff6de
# ╠═7503aac9-f9c2-4c0d-ab1c-42088e82211e
# ╠═79b490af-264c-4bb8-832f-ca38795ba002
# ╟─8cb32b19-5d78-4327-af3e-b00d279b55c3
# ╠═0c1379e4-9576-459a-94cb-ad8f190e122e
# ╠═a1a24093-ae31-42ec-a8ca-adf197c3232a
# ╠═a1fab547-777d-4511-94ea-5a9966c88cea
# ╟─5500af3a-06b3-47c1-8594-6ac5aeff6bc4
# ╠═ae75f4be-82d9-4a0f-9430-2b72e8c58525
# ╠═71fb31d3-a204-49ac-9683-4265058cd014
# ╠═4563ad8d-e2f3-4cc0-a95f-491d40be2408
# ╟─238ee3f5-3f1b-432d-acd2-29035c0a0791
# ╠═3eb6343a-1f78-47ac-96f8-e2bfb82d7b2b
# ╠═85f3fcd7-d644-4fe0-9233-3374aa2b9bdb
# ╠═abc8e616-20ce-487d-aa56-028fe4a5f9e3
# ╠═2be55e24-1478-4e94-a02d-71b999c52117
