module OxygenTrial

const APP_VERSION = "260125.0"

export APP_VERSION

using Oxygen
@oxidize
using Dates

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
        <script src="https://unpkg.com/htmx.org@2.0.4"></script>
        <style>
            body { font-family: sans-serif; padding: 2rem; max-width: 800px; margin: 0 auto; line-height: 1.6; }
            footer { margin-top: 2rem; border-top: 1px solid #ccc; padding-top: 1rem; color: #666; }
            input { padding: 0.5rem; margin: 0.5rem 0; }
            button { padding: 0.5rem 1rem; cursor: pointer; }
            #result { margin-top: 1rem; padding: 1rem; background: #f4f4f4; border-radius: 4px; }
        </style>
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
<p>HTMX is now enabled.</p>
"""
    )
end

@get "/add" function (req::Request)
    return base_html(
        "Add Numbers",
        """
<h1>Add Numbers</h1>
<form hx-post="/calculate" hx-target="#result" hx-indicator="#loading">
    <div>
        <label>Number X:</label><br>
        <input type="number" name="x" value="0" required>
    </div>
    <div>
        <label>Number Y:</label><br>
        <input type="number" name="y" value="0" required>
    </div>
    <button type="submit">Calculate Sum</button>
    <span id="loading" class="htmx-indicator">Calculating...</span>
</form>
<div id="result">
    Result will appear here.
</div>
"""
    )
end

@post "/calculate" function (req::Request)
    params = formdata(req)
    @info "Calculate POST received" params
    x = parse(Int, params["x"])
    y = parse(Int, params["y"])
    res = add(x, y)
    return html("<p><strong>$x + $y = $res</strong></p>")
end

function isvalidnumber(number)
    try
        parsedvalue = parse(Int64, number)
        println("Parsed ok: $parsedvalue")
        return true
    catch e
        println("Exception: $e")
        return false
    end
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
