FROM julia:1.11.2-bookworm
# FROM julia:1.11.2-bullseye

# Add metadata
LABEL maintainer="john@fingertip.co.nz"
LABEL version="1.0"
LABEL description="Julia web application using Oxygen.jl"

# Create non-root user
RUN useradd -m -s /bin/bash julia-user
USER julia-user
WORKDIR /home/julia-user

# Set environment variables
ENV JULIA_NUM_THREADS=4 \
    JULIA_DEPOT_PATH=/home/julia-user/.julia

# Copy dependency files
#COPY --chown=julia-user:julia-user Project-container.toml ./Project.toml
#COPY --chown=julia-user:julia-user Project.toml ./
#COPY --chown=julia-user:julia-user Manifest.toml ./

# First, copy the project files
COPY --chown=julia-user:julia-user Project.toml Manifest.toml ./
# Copy application code
COPY --chown=julia-user:julia-user src/ ./src
COPY --chown=julia-user:julia-user test/ ./test
COPY --chown=julia-user:julia-user web-server.jl ./

# Install and precompile dependencies before copying application code
# Run in the same command to prevent a new layer
RUN julia --project -e 'using Pkg; Pkg.instantiate(); Pkg.resolve()' && \
    julia --project -e 'using Pkg; Pkg.precompile()'

# Run tests after all code is copied
RUN julia --project -e 'using Pkg; Pkg.test()'

# Run the whole lot!
#RUN julia --project -e 'using Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.precompile(); Pkg.test()'

# Claude: Single command for all package operations
# Use options that, in theory, mean the options for Test() are the same as elsewhere to avoid precompilation
#RUN julia --project --code-coverage=none --check-bounds=yes --warn-overwrite=yes --depwarn=yes \
#         --inline=yes --startup-file=no --track-allocation=none \
#         -e 'using Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.precompile(); Pkg.test()'

# Install dependencies only
#RUN julia --project -e 'using Pkg; Pkg.instantiate()'

# Now precompile and test with full application code
#RUN julia --project -e 'using Pkg; Pkg.Registry.update(); Pkg.resolve(); Pkg.test()'
#RUN julia --project -e 'using Pkg; Pkg.precompile(); Pkg.test()'
#RUN julia --project -e 'using Pkg; Pkg.resolve(); Pkg.precompile(); Pkg.test()'
# && \
#    julia --project -e 'using Pkg; Pkg.precompile()' && \
#    julia --project -e 'using Pkg; Pkg.test()'

USER root
RUN apt-get update && apt-get install -y curl
USER julia-user

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health | grep -q '"status":"healthy"' || exit 1

EXPOSE 8080

# Claude: Add this to ensure Julia uses the existing precompilation
# Did not work!
#ENV JULIA_PKG_PRECOMPILE_AUTO=0

ENTRYPOINT ["julia", "--project=.", "web-server.jl"]