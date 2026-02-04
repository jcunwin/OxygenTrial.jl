"""
Auth0 OAuth 2.0 Authentication Module

Provides OAuth 2.0 authentication flow with Auth0.
"""
module Auth0

using HTTP
using JSON3
using URIs

export Auth0Config, Auth0Tokens, Auth0User
export get_authorization_url, exchange_code_for_tokens, get_user_info

"""
Configuration for Auth0 OAuth

# Fields
- `domain::String`: Your Auth0 domain (e.g., "myapp.us.auth0.com")
- `client_id::String`: OAuth client ID from Auth0
- `client_secret::String`: OAuth client secret from Auth0
- `redirect_uri::String`: Callback URL registered in Auth0
- `scope::String`: Space-separated OAuth scopes (default: "openid profile email")
- `audience::Union{String,Nothing}`: Optional API identifier
"""
struct Auth0Config
    domain::String
    client_id::String
    client_secret::String
    redirect_uri::String
    scope::String
    audience::Union{String,Nothing}

    function Auth0Config(;
        domain::String,
        client_id::String,
        client_secret::String,
        redirect_uri::String,
        scope::String = "openid profile email",
        audience::Union{String,Nothing} = nothing
    )
        new(domain, client_id, client_secret, redirect_uri, scope, audience)
    end
end

"""
OAuth tokens returned from Auth0
"""
struct Auth0Tokens
    access_token::String
    id_token::String
    token_type::String
    expires_in::Int
    refresh_token::Union{String,Nothing}
    scope::Union{String,Nothing}
end

"""
User profile information from Auth0
"""
struct Auth0User
    sub::String                          # Unique user identifier
    name::Union{String,Nothing}
    nickname::Union{String,Nothing}
    picture::Union{String,Nothing}
    email::Union{String,Nothing}
    email_verified::Union{Bool,Nothing}
    updated_at::Union{String,Nothing}
end

"""
    get_authorization_url(config::Auth0Config; state::Union{String,Nothing}=nothing)

Generate the Auth0 authorization URL to redirect users to for login.

# Arguments
- `config::Auth0Config`: Auth0 configuration
- `state::Union{String,Nothing}`: Optional CSRF protection token

# Returns
- `String`: Complete authorization URL
"""
function get_authorization_url(config::Auth0Config; state::Union{String,Nothing}=nothing)
    auth_url = "https://$(config.domain)/authorize"

    params = Dict{String,String}(
        "response_type" => "code",
        "client_id" => config.client_id,
        "redirect_uri" => config.redirect_uri,
        "scope" => config.scope
    )

    if state !== nothing
        params["state"] = state
    end

    if config.audience !== nothing
        params["audience"] = config.audience
    end

    # Build query string
    query = join([URIs.escapeuri(k) * "=" * URIs.escapeuri(v) for (k, v) in params], "&")

    return auth_url * "?" * query
end

"""
    exchange_code_for_tokens(config::Auth0Config, code::String)

Exchange an authorization code for access tokens.

# Arguments
- `config::Auth0Config`: Auth0 configuration
- `code::String`: Authorization code from Auth0 callback

# Returns
- `Auth0Tokens`: Token information
"""
function exchange_code_for_tokens(config::Auth0Config, code::String)
    token_url = "https://$(config.domain)/oauth/token"

    body = Dict(
        "grant_type" => "authorization_code",
        "client_id" => config.client_id,
        "client_secret" => config.client_secret,
        "code" => code,
        "redirect_uri" => config.redirect_uri
    )

    headers = ["Content-Type" => "application/json"]

    try
        response = HTTP.post(token_url, headers, JSON3.write(body))

        if response.status == 200
            data = JSON3.read(String(response.body))

            @info "Exchanged code for tokens" data
            
            return Auth0Tokens(
                get(data, :access_token, ""),
                get(data, :id_token, ""),
                get(data, :token_type, "Bearer"),
                get(data, :expires_in, 0),
                get(data, :refresh_token, nothing),
                get(data, :scope, nothing)
            )
        else
            error("Token exchange failed with status $(response.status): $(String(response.body))")
        end
    catch e
        @error "Failed to exchange authorization code for tokens" exception=(e, catch_backtrace())
        rethrow(e)
    end
end

"""
    get_user_info(config::Auth0Config, access_token::String)

Retrieve user profile information using an access token.

# Arguments
- `config::Auth0Config`: Auth0 configuration
- `access_token::String`: Access token from Auth0

# Returns
- `Auth0User`: User profile information
"""
function get_user_info(config::Auth0Config, access_token::String)
    userinfo_url = "https://$(config.domain)/userinfo"

    headers = ["Authorization" => "Bearer $(access_token)"]

    try
        response = HTTP.get(userinfo_url, headers)

        if response.status == 200
            data = JSON3.read(String(response.body))

            @info "Retrieved user info" data

            return Auth0User(
                get(data, :sub, ""),
                get(data, :name, nothing),
                get(data, :nickname, nothing),
                get(data, :picture, nothing),
                get(data, :email, nothing),
                get(data, :email_verified, nothing),
                get(data, :updated_at, nothing)
            )
        else
            error("Failed to get user info with status $(response.status): $(String(response.body))")
        end
    catch e
        @error "Failed to retrieve user information" exception=(e, catch_backtrace())
        rethrow(e)
    end
end

end # module
