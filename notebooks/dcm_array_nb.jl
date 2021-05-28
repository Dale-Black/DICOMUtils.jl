### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 8f30a7e0-bf33-11eb-3200-133026b73bab
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
		Pkg.add("NIfTI")
		Pkg.add(Pkg.PackageSpec(url="https://github.com/Dale-Black/DICOMUtils.jl"))
		
		Pkg.add("Plots")
	end
	
	# Import packages
	using PlutoUI
	using DICOM
	using NIfTI
	using DICOMUtils
	using LinearAlgebra
	
	using Plots

end

# ╔═╡ adb8b582-8b11-4e3a-a2ce-5b40df63dcac
TableOfContents()

# ╔═╡ 7784d5d1-cbd2-4ddd-aee0-2fc55069ee7f
md"""
## Basic Functions
"""

# ╔═╡ f0d4c68d-56ab-4b4b-842d-b9e1ad6a4bef
md"""
## Load DICOM Array
"""

# ╔═╡ 0cb20f7d-ce8d-439f-9463-19c860c70b5b
dcmdir_path = raw"Y:\Canon Images for Dynamic Heart Phantom\Dynamic Phantom\clean_data\CONFIG 1^275\50\80.0";

# ╔═╡ d7f764de-6ea4-40cc-9e24-23034a0e1bcb
# dcm_data = dcmdir_parse(dcmdir_path)

# ╔═╡ 04d0807c-d112-4f7c-8048-19470bfe024a
# function load_dcm_array(path)
# 	global transform = [-1 0 0; 0 -1 0; 0 0 1]
# 	dcm_data = dcmdir_parse(path)
# 	slice = dcm_data[1]
	
# 	protocol_name = slice[(0x0018, 0x1030)]
# 	orientation = slice[(0x0020, 0x0037)]
# 	pixel_spacing = slice[(0x0028, 0x0030)]
# 	slice_thickness = slice[(0x0018, 0x0050)]
# 	# time_step = slice[(0x0018, 0x0080)] # This is the TR, but may not be the time step
# 	# phase_encoding_direction = slice[(0x0018, 0x1312)]
	
# 	# Convert orentation to RAS
# 	global orientation = transform*reshape(orientation, (3, 2))
	
# 	# Determine Z as cross product of X and Y
# 	orientation = hcat(orientation, cross(orientation[:, 1], orientation[:, 2]))
	
# 	# Scale by pixel size
# 	orientation = orientation*[pixel_spacing[1] 0 0; 0 pixel_spacing[2] 0; 0 0 slice_thickness]
	
# 	# Find Z coordinates of each slice
# 	image_positions = transform*hcat(
# 		[dcm_data[i][(0x0020, 0x0032)] for i = 1:length(dcm_data)]...)
	
# 	z_coords = [dot(image_positions[:, i], orientation[:, 3])
# 		for i = 1:size(image_positions, 2)]
	
# 	# Sort Z coordinates
# 	p = sortperm(z_coords)
# end

# ╔═╡ 90a1b034-e75e-4b24-8c9a-08ef0debda89
# with_terminal() do
# 	for (i, x) in enumerate(dcm_data)
# 		println(i)
# 	end
# end

# ╔═╡ cd0cb38c-b96c-4f00-8ef3-5fbed3b037bc
# for i = 1:length(dcm_data)
# 	global image_positions = Array{undef, }
# 	image_positions[i] = dcm_data[i][(0x0020, 0x0032)]
# 	# append!(image_positions, dcm_data[i][(0x0020, 0x0032)])
# end

# ╔═╡ cb74f9ad-d90a-4b75-9a31-73bc35b3f457


# ╔═╡ b3cfd438-a2db-4d0b-873e-9b128225dccb


# ╔═╡ 372cb632-b4e3-444c-88cc-7efcc326815e


# ╔═╡ 28d9674c-912a-4003-b0a1-8c0648382989
dcm_data = dcmdir_parse(dcmdir_path)

# ╔═╡ 4e118951-80d3-4601-9c6e-a00b9ad4157b
Plots.heatmap(dcm_data[130][(0x7fe0,0x0010)])

# ╔═╡ 407b8672-736b-47e6-b744-b4cfb44edf93
cat(
	[dcm_data[i][(0x7fe0,0x0010)] for i = 1:length(dcm_data)]..., dims=3)

# ╔═╡ 00cb7af0-7ffe-4fd4-baff-165f100f19da
image_positions = transform*hcat(
	[dcm_data[i][(0x0020, 0x0032)] for i = 1:length(dcm_data)]...)

# ╔═╡ 4e7979ab-3151-44e4-869a-64edb00454e6
z_coords = [dot(image_positions[:, i], orientation[:, 3])
	for i = 1:size(image_positions, 2)]

# ╔═╡ e7809b90-a28e-4065-8d34-dfc066025599
typeof(dcm_data)

# ╔═╡ 2857ee46-2d30-4b3c-89c5-b89ab9e9bc05
function load_dcm_array(dcm_data::Vector{DICOM.DICOMData})
	arr = cat([dcm_data[i][(0x7fe0,0x0010)] for i = 1:length(dcm_data)]..., dims=3)
	return (arr, dcm_data)
end

# ╔═╡ b893a0a6-41d1-4e31-bca2-9dd41bc3c3b5
load_dcm_array(dcmdir_path)

# ╔═╡ f65d7b84-bbb8-4df6-a147-c3bc805d74d0
vol = load_dcm_array(dcm_data)

# ╔═╡ abba8f18-0f65-4337-b1a1-8d42b1de9064
@bind a Slider(1:size(vol[1])[3], default=10, show_value=true)

# ╔═╡ 78b20c32-6da7-4e97-9adc-1a14ba974993
heatmap(vol[1][:,:,a], c=:grays)

# ╔═╡ Cell order:
# ╠═8f30a7e0-bf33-11eb-3200-133026b73bab
# ╠═adb8b582-8b11-4e3a-a2ce-5b40df63dcac
# ╟─7784d5d1-cbd2-4ddd-aee0-2fc55069ee7f
# ╟─f0d4c68d-56ab-4b4b-842d-b9e1ad6a4bef
# ╠═0cb20f7d-ce8d-439f-9463-19c860c70b5b
# ╠═d7f764de-6ea4-40cc-9e24-23034a0e1bcb
# ╠═4e118951-80d3-4601-9c6e-a00b9ad4157b
# ╠═04d0807c-d112-4f7c-8048-19470bfe024a
# ╠═407b8672-736b-47e6-b744-b4cfb44edf93
# ╠═b893a0a6-41d1-4e31-bca2-9dd41bc3c3b5
# ╠═00cb7af0-7ffe-4fd4-baff-165f100f19da
# ╠═4e7979ab-3151-44e4-869a-64edb00454e6
# ╠═90a1b034-e75e-4b24-8c9a-08ef0debda89
# ╠═cd0cb38c-b96c-4f00-8ef3-5fbed3b037bc
# ╠═cb74f9ad-d90a-4b75-9a31-73bc35b3f457
# ╠═b3cfd438-a2db-4d0b-873e-9b128225dccb
# ╠═372cb632-b4e3-444c-88cc-7efcc326815e
# ╠═28d9674c-912a-4003-b0a1-8c0648382989
# ╠═e7809b90-a28e-4065-8d34-dfc066025599
# ╠═2857ee46-2d30-4b3c-89c5-b89ab9e9bc05
# ╠═f65d7b84-bbb8-4df6-a147-c3bc805d74d0
# ╠═abba8f18-0f65-4337-b1a1-8d42b1de9064
# ╠═78b20c32-6da7-4e97-9adc-1a14ba974993
