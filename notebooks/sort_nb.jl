### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 9cc959a0-d500-4d24-980c-5de0c765fabd
begin
	let
		# Set up temporary environment
		env = mktempdir()
		import Pkg
		Pkg.activate(env)
		Pkg.Registry.update()
		
		# Download packages
		Pkg.add("PlutoUI")
		Pkg.add(Pkg.PackageSpec(url="https://github.com/Dale-Black/DICOMUtils.jl"))
	end
	
	# Import packages
	using PlutoUI
	using DICOMUtils
end

# ╔═╡ 7c871f7d-d46e-4b48-8683-35002b9ce17e
md"""
## Set up
"""

# ╔═╡ f011d8a4-dc21-4c03-ae7e-132c8493cdeb
TableOfContents()

# ╔═╡ 5abd2b07-e290-4740-adcf-7968e6984864
md"""
## Filepaths
"""

# ╔═╡ beb3294f-c78f-4715-8b94-a5295bce3b2e
filepath = "/Users/daleblack/Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Volumes/128.200.49.44 – FTP/NeptuneData/Datasets/DynamicPhantom/DICOM/D202104/DD2708";

# ╔═╡ 163288c1-acac-41c0-9d49-ae91a0413725
filepath_new = "/Users/daleblack/Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Volumes/128.200.49.44 – FTP/NeptuneData/Datasets/DynamicPhantom/DICOM/D202104/clean_data";

# ╔═╡ 97fc414c-3041-42bb-baf1-b318f6466435
isdir(filepath_new) || mkdir(filepath_new)

# ╔═╡ bfb89ccf-f9fc-4179-ba2e-fb942dd5782b
const SeriesNumber = (0x0020,0x0011)

# ╔═╡ d81a47a8-7e49-46f2-a0a4-ce94ab55c39d
const AccessionNumber = (0x0008,0x0050)

# ╔═╡ 8891e374-6823-4a92-8b86-d3b8275bc2bb
const PatientName = (0x0010,0x0010)

# ╔═╡ df97d503-2b6a-49d7-9a35-4f10b3168eb0
DICOMUtils.sortbytag(filepath, filepath_new, PatientName)

# ╔═╡ Cell order:
# ╟─7c871f7d-d46e-4b48-8683-35002b9ce17e
# ╠═9cc959a0-d500-4d24-980c-5de0c765fabd
# ╠═f011d8a4-dc21-4c03-ae7e-132c8493cdeb
# ╟─5abd2b07-e290-4740-adcf-7968e6984864
# ╠═beb3294f-c78f-4715-8b94-a5295bce3b2e
# ╠═163288c1-acac-41c0-9d49-ae91a0413725
# ╠═97fc414c-3041-42bb-baf1-b318f6466435
# ╠═bfb89ccf-f9fc-4179-ba2e-fb942dd5782b
# ╠═d81a47a8-7e49-46f2-a0a4-ce94ab55c39d
# ╠═8891e374-6823-4a92-8b86-d3b8275bc2bb
# ╠═df97d503-2b6a-49d7-9a35-4f10b3168eb0
