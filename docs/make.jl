using DICOMUtils
using Documenter

DocMeta.setdocmeta!(DICOMUtils, :DocTestSetup, :(using DICOMUtils); recursive=true)

makedocs(;
    modules=[DICOMUtils],
    authors="Dale <djblack@uci.edu> and contributors",
    repo="https://github.com/Dale-Black/DICOMUtils.jl/blob/{commit}{path}#{line}",
    sitename="DICOMUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Dale-Black.github.io/DICOMUtils.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Dale-Black/DICOMUtils.jl",
)
