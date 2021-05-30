include("./imports.jl")

@testset ExtendedTestSet "io_orientation" begin
    @testset ExtendedTestSet "io_orientation" begin
        eye = [1 0 0 0
               0 1 0 0
               0 0 1 0
               0 0 0 1]
        answer = [ 1.0  1.0
                   2.0  1.0
                   3.0  1.0]
        @test io_orientation(eye) == answer
    end

    # TODO - FIX TEST BELOW
    # @testset ExtendedTestSet "io_orientation" begin
    #     aff =  [1 0 0 1; 1 0 0 1; 1 0 0 1; 1 0 0 1]
    #     answer = [2.0 1.0; NaN NaN; NaN NaN]
    #     test = io_orientation(aff)
    #     @test test == answer
    # end
end

@testset ExtendedTestSet "axcodes2ornt" begin
    @testset ExtendedTestSet "axcodes2ornt" begin
        answer = [1.0 1.0
                  2.0 1.0
                  3.0 1.0]
        test = axcodes2ornt(("R", "A", "S"))
        @test test == answer
    end

    @testset ExtendedTestSet "axcodes2ornt" begin
        answer = [2.0 1.0
                  1.0 -1.0
                  3.0 1.0]
        test = axcodes2ornt(('F', 'L', 'U'), (('L','R'),('B','F'),('D','U')))
        @test test == answer
    end
end

@testset ExtendedTestSet "ornt_transform" begin
    @testset ExtendedTestSet "ornt_transform" begin
        src = [1.0 1.0
               2.0 1.0
               3.0 1.0]
        dst = [2.0 1.0
               1.0 -1.0
               3.0 1.0]
        answer = [2.0 -1.0
                  1.0 1.0
                  3.0 1.0]
        test = ornt_transform(src, dst)
        @test test == answer
    end

    @testset ExtendedTestSet "ornt_transform" begin
        src = [1.0 1.0
               2.0 1.0
               3.0 1.0]
        dst = [2.0 1.0
               1.0 1.0
               3.0 1.0]
        answer = [2.0 1.0
                  1.0 1.0
                  3.0 1.0]
        test = ornt_transform(src, dst)
        @test test == answer
    end
end

@testset ExtendedTestSet "apply_orientation" begin
    @testset ExtendedTestSet "apply_orientation" begin
        d1 = [1 1 1 1
              1 1 1 1
              0 0 0 0
              1 0 0 1]
        d2 = [1 1 1 1
              1 1 1 1
              0 0 0 0
              1 0 0 1]
        data = cat(d1, d2, dims=3)
        o = [2.0 1.0
             1.0 1.0
             3.0 1.0]
        a1 = [1 1 0 1
              1 1 0 0
              1 1 0 0
              1 1 0 1]
        a2 = [1 1 0 1
              1 1 0 0
              1 1 0 0
              1 1 0 1]
        answer = cat(a1, a2, dims=3)
        test = apply_orientation(data, o)
        @test test == answer
    end
end