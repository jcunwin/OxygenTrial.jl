using Oxygen
using OxygenTrial

# Read port from environment variable, default to 8080 for local dev
port = parse(Int, get(ENV, "PORT", "8080"))

# start the web server
OxygenTrial.serve(host="0.0.0.0", port=port)