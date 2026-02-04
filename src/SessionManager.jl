"""
Simple Session Management for OAuth Authentication

Provides in-memory session storage for authenticated users.
For production, consider using Redis or a database-backed session store.
"""
module SessionManager

using Dates
using Random

export Session, create_session, get_session, destroy_session, cleanup_expired_sessions!

"""
User session data
"""
mutable struct Session
    id::String
    user_id::String
    email::Union{String,Nothing}
    name::Union{String,Nothing}
    picture::Union{String,Nothing}
    access_token::String
    refresh_token::Union{String,Nothing}
    created_at::DateTime
    expires_at::DateTime
end

# In-memory session store (use Redis/database in production)
const SESSIONS = Dict{String,Session}()

# Session expiration time (1 hour)
const SESSION_LIFETIME = Hour(1)

"""
    create_session(user_id::String, email, name, picture, access_token::String, refresh_token)

Create a new session for an authenticated user.

# Arguments
- `user_id::String`: Unique user identifier
- `email`: User's email address
- `name`: User's full name
- `picture`: User's profile picture URL
- `access_token::String`: OAuth access token
- `refresh_token`: OAuth refresh token (if available)

# Returns
- `String`: Session ID (secure random token)
"""
function create_session(
    user_id::String,
    email::Union{String,Nothing},
    name::Union{String,Nothing},
    picture::Union{String,Nothing},
    access_token::String,
    refresh_token::Union{String,Nothing}
)
    session_id = bytes2hex(Random.rand(UInt8, 32))  # 256-bit random token
    now = Dates.now()

    session = Session(
        session_id,
        user_id,
        email,
        name,
        picture,
        access_token,
        refresh_token,
        now,
        now + SESSION_LIFETIME
    )

    SESSIONS[session_id] = session

    return session_id
end

"""
    get_session(session_id::String)

Retrieve a session by ID.

# Arguments
- `session_id::String`: Session identifier

# Returns
- `Union{Session,Nothing}`: Session object if found and not expired, otherwise nothing
"""
function get_session(session_id::String)
    if !haskey(SESSIONS, session_id)
        return nothing
    end

    session = SESSIONS[session_id]

    # Check if session is expired
    if Dates.now() > session.expires_at
        delete!(SESSIONS, session_id)
        return nothing
    end

    # Extend session lifetime on access
    session.expires_at = Dates.now() + SESSION_LIFETIME

    return session
end

get_session(session::AbstractString) = get_session(String(session))

"""
    destroy_session(session_id::String)

Delete a session (logout).

# Arguments
- `session_id::String`: Session identifier to destroy
"""
function destroy_session(session_id::String)
    delete!(SESSIONS, session_id)
    return nothing
end

"""
    cleanup_expired_sessions!()

Remove all expired sessions from memory.
Should be called periodically to prevent memory leaks.
"""
function cleanup_expired_sessions!()
    now = Dates.now()
    expired = [id for (id, session) in SESSIONS if now > session.expires_at]

    for id in expired
        delete!(SESSIONS, id)
    end

    return length(expired)
end

"""
    get_session_count()

Get the current number of active sessions.
Useful for monitoring/debugging.
"""
function get_session_count()
    return length(SESSIONS)
end

end # module
