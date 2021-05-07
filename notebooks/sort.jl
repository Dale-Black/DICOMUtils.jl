### A Pluto.jl notebook ###
# v0.14.5

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

# ╔═╡ 71a99e79-ae78-49f0-8baa-8901dbaf19ae
md"""
## Sorting
"""

# ╔═╡ 418ac8e5-f6a5-4305-bd6e-f786174eb024
filepath = "//neptune.radsci.uci.edu/NeptuneData/Datasets/DynamicPhantom/DICOM/D202104/test";

# ╔═╡ 3b58d6b3-277b-45f6-81f5-75c0c2717fc1
dir = readdir(filepath);

# ╔═╡ 2b5fec38-22b8-4a33-ac5b-1599e8d546fd
dcms = [];

# ╔═╡ 3d43d662-633a-41a1-932e-7a278680cd70
begin
	for i = 1:3
		dcm_file = DICOM.dcm_parse(filepath * "/" * dir[i])
		push!(dcms, dcm_file)
	end
end

# ╔═╡ 7d7efb83-f951-455d-a692-0d47f30cdc09
dcm1 = dcms[1]

# ╔═╡ 22d1069f-e8cd-4cc9-bdf4-0b265ab00e99
dcm1[(0x0018, 0x9334)]

# ╔═╡ f9835e6a-4611-4f6f-aa78-668b3e58c87a
dcm_directory = DICOM.dcmdir_parse(filepath)

# ╔═╡ 51d0522a-52aa-4b10-a684-fe8b0f4e6bba
length(dcm_directory)

# ╔═╡ 803dbcdd-6730-4772-97ec-3875fa50e170
# with_terminal() do
# 	for i = 1:3
# 		println(dcm_directory[i])
# 	end
# end

# ╔═╡ 5bb06da7-1e98-4a94-9fc9-da3312a66a26
tag_array = []

# ╔═╡ ff06bf7b-83ee-4dce-957e-bcbe1940c811
push!(tag_array, dcm_directory[i][((0x0018, 0x9334))])

# ╔═╡ fdbeab00-adf3-42e8-89cf-207087e585f0
unique_tags = unique(tag_array)

# ╔═╡ 4473e79b-b458-433c-8fc2-357c34903f63
for i = 1:length(unique_tags)
	dcm_directory[i][unique_tags[i]]
end

# ╔═╡ e8086d23-46fc-42b8-b621-df84ad070d89
function sortby(directory, dcm_tag)
	dcm_directory = DICOM.dcmdir_parse(directory)
	length(dcm_directory)
	unique(dcm_dir)
end

# ╔═╡ e5bdde53-fdfc-4d44-869e-7387bbf27a50


# ╔═╡ Cell order:
# ╟─16e05577-e692-41a7-b969-f260f0141af6
# ╠═3ae1dd50-aeb0-11eb-3fb1-77aa043fe6e4
# ╠═8b40bea7-4a23-4f4d-8daf-9cff851dc4ac
# ╟─71a99e79-ae78-49f0-8baa-8901dbaf19ae
# ╠═418ac8e5-f6a5-4305-bd6e-f786174eb024
# ╠═3b58d6b3-277b-45f6-81f5-75c0c2717fc1
# ╠═2b5fec38-22b8-4a33-ac5b-1599e8d546fd
# ╠═3d43d662-633a-41a1-932e-7a278680cd70
# ╠═7d7efb83-f951-455d-a692-0d47f30cdc09
# ╠═22d1069f-e8cd-4cc9-bdf4-0b265ab00e99
# ╠═f9835e6a-4611-4f6f-aa78-668b3e58c87a
# ╠═51d0522a-52aa-4b10-a684-fe8b0f4e6bba
# ╠═803dbcdd-6730-4772-97ec-3875fa50e170
# ╠═5bb06da7-1e98-4a94-9fc9-da3312a66a26
# ╠═ff06bf7b-83ee-4dce-957e-bcbe1940c811
# ╠═fdbeab00-adf3-42e8-89cf-207087e585f0
# ╠═4473e79b-b458-433c-8fc2-357c34903f63
# ╠═e8086d23-46fc-42b8-b621-df84ad070d89
# ╠═e5bdde53-fdfc-4d44-869e-7387bbf27a50
