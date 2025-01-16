module OxygenTrial

using Oxygen ; @oxidise
#using HTTP

include("HealthCheck.jl")

# Write your package code here.
get("/") do req::Request
    return "Nothing to see here!"
end

get("/greet") do req::Request
    return "hello Makara!"
end

get("/hi") do req::Request
    return "Hi Northland!"
end

get("/addpath/{x}/{y}") do req::Request, x::Int, y::Int
    return text("$x + $y = " * string(add(x, y)))
end

get("/addparms") do req::Request, x::Int, y::Int
    return text("$x + $y = " * string(add(x, y)))
end

function add(a, b)
    return a + b + 12
end

end
