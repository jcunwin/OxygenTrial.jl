"""
Auth0 Configuration Management

Loads Auth0 credentials from environment variables.
"""
module Auth0Configuration

using ..Auth0: Auth0Config

export load_auth0_config, get_auth0_config

# Cache for the configuration
const CACHED_CONFIG = Ref{Union{Auth0Config,Nothing}}(nothing)

"""
    load_auth0_config()

Load Auth0 configuration from environment variables.

# Required Environment Variables
- `AUTH0_DOMAIN`: Your Auth0 domain (e.g., "myapp.us.auth0.com")
- `AUTH0_CLIENT_ID`: OAuth client ID
- `AUTH0_CLIENT_SECRET`: OAuth client secret
- `AUTH0_CALLBACK_URL`: Callback URL (e.g., "http://localhost:8080/auth/callback")

# Optional Environment Variables
- `AUTH0_SCOPE`: OAuth scopes (default: "openid profile email")
- `AUTH0_AUDIENCE`: API identifier (optional)

# Returns
- `Auth0Config`: Configuration object

# Throws
- `ErrorException`: If required environment variables are missing
"""
function load_auth0_config()
    domain = get(ENV, "AUTH0_DOMAIN", "")
    client_id = get(ENV, "AUTH0_CLIENT_ID", "")
    client_secret = get(ENV, "AUTH0_CLIENT_SECRET", "")
    callback_url = get(ENV, "AUTH0_CALLBACK_URL", "")

    # Validate required fields
    missing_vars = String[]
    domain == "" && push!(missing_vars, "AUTH0_DOMAIN")
    client_id == "" && push!(missing_vars, "AUTH0_CLIENT_ID")
    client_secret == "" && push!(missing_vars, "AUTH0_CLIENT_SECRET")
    callback_url == "" && push!(missing_vars, "AUTH0_CALLBACK_URL")

    if !isempty(missing_vars)
        error("Missing required environment variables: $(join(missing_vars, ", "))")
    end

    # Optional fields
    scope = get(ENV, "AUTH0_SCOPE", "openid profile email")
    audience = get(ENV, "AUTH0_AUDIENCE", nothing)

    config = Auth0Config(
        domain = domain,
        client_id = client_id,
        client_secret = client_secret,
        redirect_uri = callback_url,
        scope = scope,
        audience = audience
    )

    # Cache the configuration
    CACHED_CONFIG[] = config

    return config
end

"""
    get_auth0_config()

Get the cached Auth0 configuration, loading it if not already loaded.

# Returns
- `Auth0Config`: Configuration object
"""
function get_auth0_config()
    if CACHED_CONFIG[] === nothing
        load_auth0_config()
    end
    return CACHED_CONFIG[]
end

"""
    is_configured()

Check if Auth0 is configured (all required environment variables are set).

# Returns
- `Bool`: true if configured, false otherwise
"""
function is_configured()
    required = ["AUTH0_DOMAIN", "AUTH0_CLIENT_ID", "AUTH0_CLIENT_SECRET", "AUTH0_CALLBACK_URL"]
    return all(haskey(ENV, var) && ENV[var] != "" for var in required)
end

end # module
