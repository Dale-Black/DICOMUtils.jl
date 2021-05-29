include("./imports.jl")

@testset ExtendedTestSet "io_orientation" begin
    @testset ExtendedTestSet "io_orientation" begin
        eye =  [1 0 0 0
                0 1 0 0
                0 0 1 0
                0 0 0 1]
        answer =  [ 1.0  1.0
                    2.0  1.0
                    3.0  1.0]
        @test io_orientation(eye) == answer
    end
end