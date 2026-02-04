module OxygenTrial

const APP_VERSION = "260205.0"

export APP_VERSION

using Oxygen
@oxidize
using Dates
using OpenIDConnect
using JSON3
using HTTP

staticfiles("assets", "assets")

include("HealthCheck.jl")

# Helper for HTML layout
function base_html(title, content)
    return html("""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>$title</title>
        <link rel="icon" href="/assets/favicon-16x16.png" sizes="16x16">
        <link rel="icon" href="/assets/favicon-32x32.png" sizes="32x32">
        <script src="https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js" integrity="sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz" crossorigin="anonymous"></script>
        <link rel="stylesheet" href="/assets/styles.css">
    </head>
    <body>
        <nav>
            <a href="/">Home</a> | <a href="/add">Add Numbers</a>
        </nav>
        <main>
            $content
        </main>
        <footer>
            <p>Version: $APP_VERSION</p>
            <p><a href="https://htmx.org/">HTMX</a> is used.</p>
        </footer>
    </body>
    </html>
    """)
end

# Write your package code here.
@get "/" function (req::Request)
    return base_html(
        "Oxygen",
        """
<h1>Oxygen</h1>
<p>Welcome to OxygenTrial!</p>
<p>Not much to see here.</p>
"""
    )
end

@get "/add" function (req::Request)
    return base_html(
        "Add Numbers",
        """
<h1>Add Numbers</h1>
<p>
    <form hx-post="/sum" hx-target="#result">
        <div hx-target="this" hx-swap="outerHTML">
            <label >First number:</label><br>
            <input type="text" id="firstnumber" name="firstnumber" hx-post="/validatefirstnumber" hx-indicator="#ind">
            <img id="ind" src="/assets/bars.svg" class="htmx-indicator"/>
        </div>
        <div hx-target="this" hx-swap="outerHTML">
            <label >Second number:</label><br>
            <input type="text" id="secondnumber" name="secondnumber" hx-post="/validatesecondnumber" hx-indicator="#ind">
            <img id="ind" src="/assets/bars.svg" class="htmx-indicator"/>
        </div>
        <button class="btn btn-primary">Sum</button>
    </form>
</p>
<p>
Result: <div id="result" class="result"></div>
</p>

"""
    )
end

@post "/sum" function (req::Request)
    params = formdata(req)
    @info "Calculate POST received" params
    if !isvalidnumber(params["firstnumber"]) || !isvalidnumber(params["secondnumber"])
        return "There was a problem with one or more of your numbers."
    end
    res = add(parse(Int, params["firstnumber"]), parse(Int, params["secondnumber"]))
    return html("<p><strong>$(params["firstnumber"]) + $(params["secondnumber"]) = $res</strong></p>")
end

#TODO: Add validation like here: https://htmx.org/examples/inline-validation/
@post "/validatefirstnumber" function (request)
    validatenumber(request, "firstnumber", "First Number")
end

@post "/validatesecondnumber" function (request)
    validatenumber(request, "secondnumber", "Second Number")
end


function isvalidnumber(number)
    try
        parsedvalue = parse(Float64, number)
        println("Parsed ok: $parsedvalue")
        return true
    catch e
        println("Exception: $e")
        return false
    end
end

function validatenumber(request, number, label)
    println("Validating $number")
    data = formdata(request)
    println(data)
    rawdata = data[number]
    errormsg = ""
    class = ""
    if isvalidnumber(rawdata)
        class = "valid"
    else
        errormsg = """
        <div class='error-message'>That is not a number.  Please enter a valid number.</div>
        """
        class = "error"
    end
    return html("""
    <div hx-target="this" hx-swap="outerHTML" class="$class">
        <label>$label</label><br>
        <input name="$number" id="$number" hx-post="/validate$number" hx-indicator="#ind" value="$rawdata">
        <img id="ind" src="/assets/bars.svg" class="htmx-indicator"/>
        $errormsg
    </div>
    """)
end

@get "/favicon.ico" function (req::Request)
    @info "favicon.ico endpoint responding"
    return file("assets/favicon-16x16.png")
end

@get "/greet" function (req::Request)
    return "hello Makara!"
end

@get "/hi" function ()
    return html("<!DOCTYPE html>Hi you!")
end

@get "/hi/{who}" function (req, who::String)
    return html("<!DOCTYPE html>Hi $(who)!")
end

@get "/addpath/{x}/{y}" function (req::Request, x::Int, y::Int)
    return text("$x + $y = " * string(add(x, y)))
end

@get "/addparms" function (req::Request, x::Int, y::Int)
    return text("$x + $y = " * string(add(x, y)))
end

function add(a, b)
    return a + b
end

end
