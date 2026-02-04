using DotEnv

# Load .env file if it exists (for development)
if isfile(".env")
    DotEnv.config()
    @info "Loaded environment variables from .env file"
else
    @info "No .env file found, using existing environment variables"
end

using Oxygen
using OxygenTrial

# Read port from environment variable, default to 8080 for local dev
port = parse(Int, get(ENV, "PORT", "8080"))

# start the web server
OxygenTrial.serve(host="0.0.0.0", port=port)