using DotEnv

# Load .env file if it exists (for development)
if isfile(".env")
    DotEnv.config()
    @info "Loaded environment variables from .env file"
else
    @info "No .env file found, using existing environment variables"
end

using Revise
using Oxygen
using OxygenTrial

# start the web server
OxygenTrial.serve(revise=:eager)
