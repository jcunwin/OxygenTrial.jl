using OxygenTrial
using Test
using Aqua

@testset "OxygenTrial.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            OxygenTrial; 
            stale_deps=(; ignore=[:Revise])
        )
    end
    # Write your tests here.
end

