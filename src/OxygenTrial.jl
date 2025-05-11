module OxygenTrial

using Oxygen ; @oxidise
using Dates

staticfiles("assets", "assets")

include("HealthCheck.jl")

# Write your package code here.
get("/") do req::Request
    return html("""
    <!DOCTYPE html>
    <head>
        <link rel="icon" href="/assets/favicon-16x16.png" sizes="16x16">
        <link rel="icon" href="/assets/favicon-32x32.png" sizes="32x32">
    </head>
    <h1>Oxygen</h1>
    <p>Nothing to see here!</p>
    <footer>
        <p>250130.1</p>
    </footer>
    """)
end

get("/favicon.ico") do req::Request
    @info "favicon.ico endpoint responding"
    return file("assets/favicon-16x16.png")
end

get("/greet") do req::Request
    return "hello Makara!"
end

get("/hi") do req::Request
    return html("<!DOCTYPE html>Hi you!")
end

get("/hi/{who}") do req::Request, who::String
    return html("<!DOCTYPE html>Hi $(who)!")
end

get("/addpath/{x}/{y}") do req::Request, x::Int, y::Int
    return text("$x + $y = " * string(add(x, y)))
end

get("/addparms") do req::Request, x::Int, y::Int
    return text("$x + $y = " * string(add(x, y)))
end

function add(a, b)
    return a + b
end

end
