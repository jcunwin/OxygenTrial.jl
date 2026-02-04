module OxygenTrial

const APP_VERSION = "260128.0"

export APP_VERSION

using Oxygen
@oxidize
using Dates
using URIs

staticfiles("assets", "assets")

include("HealthCheck.jl")
include("Auth0.jl")
include("SessionManager.jl")
include("Auth0Config.jl")

using .Auth0
using .SessionManager
using .Auth0Configuration

# Helper to get session from request cookies
function get_session_from_request(req::Request)
    # Access Cookie header from HTTP.Request headers
    cookies = ""
    for (key, value) in req.headers
        if lowercase(key) == "cookie"
            cookies = value
            break
        end
    end

    if cookies == ""
        return nothing
    end

    # Parse cookies (simple implementation)
    for cookie in split(cookies, ";")
        parts = split(strip(cookie), "=", limit=2)
        if length(parts) == 2 && strip(parts[1]) == "session_id"
            session_id = strip(parts[2])
            return SessionManager.get_session(session_id)
        end
    end

    return nothing
end

# Helper for HTML layout
function base_html(title, content; req::Union{Request,Nothing}=nothing)
    # Check if user is authenticated
    auth_links = ""
    if req !== nothing
        session = get_session_from_request(req)
        if session !== nothing
            user_info = ""
            if session.name !== nothing
                user_info = "Logged in as: $(session.name)"
            elseif session.email !== nothing
                user_info = "Logged in as: $(session.email)"
            else
                user_info = "Logged in"
            end
            auth_links = """$user_info | <a href="/auth/logout">Logout</a>"""
        else
            auth_links = """<a href="/auth/login">Login</a>"""
        end
    end

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
            <a href="/">Home</a> | <a href="/add">Add Numbers</a> | <a href="/profile">Profile</a>
            $(isempty(auth_links) ? "" : " | " * auth_links)
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
""",
        req=req
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

""",
        req=req
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

# ============================================
# OAuth Authentication Routes
# ============================================

@get "/auth/login" function (req::Request)
    # Check if Auth0 is configured
    if !Auth0Configuration.is_configured()
        return base_html(
            "Auth0 Not Configured",
            """
            <h1>Authentication Not Configured</h1>
            <p>Auth0 authentication is not configured. Please set the following environment variables:</p>
            <ul>
                <li>AUTH0_DOMAIN</li>
                <li>AUTH0_CLIENT_ID</li>
                <li>AUTH0_CLIENT_SECRET</li>
                <li>AUTH0_CALLBACK_URL</li>
            </ul>
            """,
            req=req
        )
    end

    try
        config = Auth0Configuration.get_auth0_config()

        # Generate CSRF state token
        state = bytes2hex(rand(UInt8, 16))

        # Get authorization URL
        auth_url = Auth0.get_authorization_url(config, state=state)

        # Redirect to Auth0
        return redirect(auth_url)
    catch e
        @error "Failed to initiate OAuth login" exception=(e, catch_backtrace())
        return base_html(
            "Login Error",
            """
            <h1>Login Error</h1>
            <p>Failed to initiate login. Please check the server logs.</p>
            <p><a href="/">Return to Home</a></p>
            """,
            req=req
        )
    end
end

@get "/auth/callback" function (req::Request)
    # Extract code and state from query parameters
    params = queryparams(req)

    code = Base.get(params, "code", nothing)
    state = Base.get(params, "state", nothing)
    error_param = Base.get(params, "error", nothing)

    # Check for OAuth errors
    if error_param !== nothing
        error_desc = Base.get(params, "error_description", "Unknown error")
        @error "OAuth error" error=error_param description=error_desc
        return base_html(
            "Login Failed",
            """
            <h1>Login Failed</h1>
            <p>Authentication error: $(error_desc)</p>
            <p><a href="/">Return to Home</a></p>
            """,
            req=req
        )
    end

    # Validate code parameter
    if code === nothing
        return base_html(
            "Login Failed",
            """
            <h1>Login Failed</h1>
            <p>Missing authorization code.</p>
            <p><a href="/">Return to Home</a></p>
            """,
            req=req
        )
    end

    try
        config = Auth0Configuration.get_auth0_config()

        # Exchange code for tokens
        tokens = Auth0.exchange_code_for_tokens(config, code)

        # Get user info
        user = Auth0.get_user_info(config, tokens.access_token)

        @info "User authenticated" user
        
        # Create session
        session_id = SessionManager.create_session(
            user.sub,
            user.email,
            user.name,
            user.picture,
            tokens.access_token,
            tokens.refresh_token
        )

        # Set session cookie and redirect
        return HTTP.Response(
            302,
            [
                "Location" => "/profile",
                "Set-Cookie" => "session_id=$(session_id); Path=/; HttpOnly; SameSite=Lax; Max-Age=3600"
            ]
        )
    catch e
        @error "Failed to complete OAuth callback" exception=(e, catch_backtrace())
        return base_html(
            "Login Failed",
            """
            <h1>Login Failed</h1>
            <p>Failed to complete authentication. Please try again.</p>
            <p><a href="/">Return to Home</a></p>
            """,
            req=req
        )
    end
end

@get "/auth/logout" function (req::Request)
    # Get session and destroy it
    session = get_session_from_request(req)
    if session !== nothing
        SessionManager.destroy_session(session.id)
    end

    # Determine logout redirect URL
    logout_url = "/"

    # If Auth0 is configured, redirect to Auth0 logout to clear SSO session
    if Auth0Configuration.is_configured()
        try
            config = Auth0Configuration.get_auth0_config()

            # Build Auth0 logout URL
            # This clears the Auth0 session and redirects back to our app
            return_to = Base.get(ENV, "AUTH0_LOGOUT_REDIRECT", "http://localhost:8080/")

            @info "Redirecting to Auth0 logout" return_to=return_to

            logout_url = "https://$(config.domain)/v2/logout?" *
                        "returnTo=$(URIs.escapeuri(return_to))&" *
                        "client_id=$(URIs.escapeuri(config.client_id))"
        catch e
            @warn "Failed to build Auth0 logout URL, redirecting to home" exception=(e, catch_backtrace())
            logout_url = "/"
        end
    end

    # Clear cookie and redirect
    return HTTP.Response(
        302,
        [
            "Location" => logout_url,
            "Set-Cookie" => "session_id=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0"
        ]
    )
end

@get "/profile" function (req::Request)
    # Check if user is authenticated
    session = get_session_from_request(req)

    if session === nothing
        return base_html(
            "Login Required",
            """
            <h1>Login Required</h1>
            <p>You must be logged in to view this page.</p>
            <p><a href="/auth/login">Login with Auth0</a></p>
            """,
            req=req
        )
    end

    # Display user profile
    profile_info = """
    <h1>User Profile</h1>
    <div class="profile">
    """

    if session.picture !== nothing
        profile_info *= """<img src="$(session.picture)" alt="Profile Picture" style="max-width: 150px; border-radius: 50%;"><br>"""
    end

    profile_info *= """
        <p><strong>User ID:</strong> $(session.user_id)</p>
    """

    if session.name !== nothing
        profile_info *= """<p><strong>Name:</strong> $(session.name)</p>"""
    end

    if session.email !== nothing
        profile_info *= """<p><strong>Email:</strong> $(session.email)</p>"""
    end

    profile_info *= """
        <p><strong>Session Created:</strong> $(session.created_at)</p>
        <p><strong>Session Expires:</strong> $(session.expires_at)</p>
    </div>
    <p><a href="/auth/logout">Logout</a></p>
    """

    return base_html("Profile", profile_info, req=req)
end

end
