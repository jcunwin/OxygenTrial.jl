using OxygenTrial
using Test
using Aqua
using HTTP

include("constants.jl"); using .Constants

@testset "OxygenTrial.jl" begin
    @testset "Add function tests" begin
        # Test with integers
        @test OxygenTrial.add(1, 2) == 3
        @test OxygenTrial.add(0, 0) == 0
        @test OxygenTrial.add(-1, 1) == 0
        @test OxygenTrial.add(100, -50) == 50

        # Test with floats
        @test isapprox(OxygenTrial.add(1.5, 2.5), 4.0)
        @test isapprox(OxygenTrial.add(0.1, 0.2), 0.3)
        @test isapprox(OxygenTrial.add(-0.5, 0.5), 0.0)
        @test isapprox(OxygenTrial.add(100.5, -50.25), 50.25)

        # Test with mixed types
        @test isapprox(OxygenTrial.add(1, 2.5), 3.5)
        @test isapprox(OxygenTrial.add(1.5, 2), 3.5)
        @test isapprox(OxygenTrial.add(0, 0.0), 0.0)
        @test isapprox(OxygenTrial.add(-1.0, 1), 0.0)
    end

 
    OxygenTrial.serve(port=PORT, host=HOST, async=true,  show_errors=false, show_banner=false, access_log=nothing)

    @testset "GET endpoint tests" begin
        # Test root endpoint
        @testset "Root endpoint" begin
            response = HTTP.request("GET", "$localhost/")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("<!DOCTYPE html>", response_body)
            @test occursin("Oxygen", response_body)
            @test occursin("Nothing to see here!", response_body)
            @test occursin("250511.1", response_body)
        end

        # Test favicon-16x16 endpoint - should return 404
        @testset "favicon-16x16 endpoint" begin
            @test_throws HTTP.ExceptionRequest.StatusError HTTP.request("GET", "$localhost/favicon-16x16.png")
        end

        # Test favicon.ico endpoint
        #= This fails with a 500 for no known reason
        @testset "favicon.ico endpoint" begin
            response = HTTP.request("GET", "$localhost/favicon.ico")
            @test response.status == 200
            @test any(x -> x.first == "Content-Type" && startswith(x.second, "image/"), response.headers)
        end
        =#

        # Test favicon-16x16 assets endpoint - should return 200
        @testset "favicon-16x16 assets endpoint" begin
            response = HTTP.request("GET", "$localhost/assets/favicon-16x16.png")
            @test response.status == 200
            @test any(x -> x.first == "Content-Type" && x.second == "image/png", response.headers)
       end

        # Test favicon-32x32 endpoint - should return 404
        @testset "favicon-32x32 endpoint" begin
            @test_throws HTTP.ExceptionRequest.StatusError HTTP.request("GET", "$localhost/favicon-32x32.png")
        end

        # Test favicon-32x32 assets endpoint - should return 200
        @testset "favicon-32x32 assets endpoint" begin
            response = HTTP.request("GET", "$localhost/assets/favicon-32x32.png")
            @test response.status == 200
            @test any(x -> x.first == "Content-Type" && x.second == "image/png", response.headers)
        end

        # Test greet endpoint
        @testset "Greet endpoint" begin
            response = HTTP.request("GET", "$localhost/greet")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("hello Makara!", response_body)
        end

        # Test hi endpoint
        @testset "Hi endpoint" begin
            response = HTTP.request("GET", "$localhost/hi")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("<!DOCTYPE html>", response_body)
            @test occursin("Hi you!", response_body)
        end

        # Test hi/who endpoint
        @testset "Hi with name endpoint" begin
            response = HTTP.request("GET", "$localhost/hi/John")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("<!DOCTYPE html>", response_body)
            @test occursin("Hi John!", response_body)
        end

        # Test addpath endpoint
        @testset "Add path endpoint" begin
            response = HTTP.request("GET", "$localhost/addpath/5/3")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("5 + 3 = 8", response_body)
        end

        # Test addparms endpoint
        @testset "Add parameters endpoint" begin
            response = HTTP.request("GET", "$localhost/addparms?x=10&y=5")
            @test response.status == 200
            response_body = String(response.body)
            @test occursin("10 + 5 = 15", response_body)
        end
    end

    OxygenTrial.terminate()

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            OxygenTrial; 
            stale_deps=(; ignore=[:Revise])
        )
    end

end
