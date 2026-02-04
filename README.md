# OxygenTrial

[![Build Status](https://github.com/jcunwin/OxygenTrial.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jcunwin/OxygenTrial.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia web application built with [Oxygen.jl](https://github.com/ndortega/Oxygen.jl) featuring Auth0 OAuth2 authentication.

## Features

- **Web Framework**: Built on Oxygen.jl for fast, lightweight web serving
- **HTMX Integration**: Dynamic form validation without JavaScript
- **OAuth Authentication**: Secure Auth0 integration with session management
- **Health Monitoring**: Built-in health check endpoint for Docker/Kubernetes
- **Docker Ready**: Containerized deployment support

## Quick Start

### Prerequisites

- Julia 1.12 or higher
- Auth0 account (for authentication features)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jcunwin/OxygenTrial.jl.git
   cd OxygenTrial.jl
   ```

2. Install dependencies:
   ```bash
   julia --project -e 'using Pkg; Pkg.instantiate()'
   ```

3. Configure Auth0 (optional - see [Auth0 Setup Guide](docs/AUTH0_SETUP.md)):
   ```bash
   cp .env.example .env
   # Edit .env with your Auth0 credentials
   ```

4. Start the server:
   ```bash
   # .env file is automatically loaded on startup
   julia --project web-server.jl
   ```

5. Open your browser to `http://localhost:8080`

## OAuth Authentication

This application includes a complete OAuth 2.0 authentication implementation with Auth0:

- **Login/Logout**: Secure user authentication
- **Session Management**: HTTP-only cookie-based sessions
- **Protected Routes**: Example of route protection
- **User Profile**: Display authenticated user information

See the [Auth0 Setup Guide](docs/AUTH0_SETUP.md) for detailed configuration instructions.

### OAuth Endpoints

- `GET /auth/login` - Initiate OAuth login
- `GET /auth/callback` - OAuth callback handler
- `GET /auth/logout` - Logout and clear session
- `GET /profile` - Protected user profile page

## Development

### Running with Hot Reload

For development with automatic code reloading:

```bash
julia --project web-server-revise.jl
```

### Running Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

## Architecture

- **`src/OxygenTrial.jl`** - Main application module with routes
- **`src/Auth0.jl`** - Auth0 OAuth implementation
- **`src/SessionManager.jl`** - Session management
- **`src/Auth0Config.jl`** - Configuration loader
- **`src/HealthCheck.jl`** - Health monitoring

## Docker Deployment

Build and run with Docker:

```bash
docker build -t oxygentrial .
docker run -p 8080:8080 \
  -e AUTH0_DOMAIN=your-domain.auth0.com \
  -e AUTH0_CLIENT_ID=your_client_id \
  -e AUTH0_CLIENT_SECRET=your_client_secret \
  -e AUTH0_CALLBACK_URL=http://localhost:8080/auth/callback \
  oxygentrial
```

## Security Notes

- Sessions are stored in-memory (use Redis/database for production)
- Use HTTPS in production
- Never commit `.env` files to version control
- Review [Auth0 Setup Guide](docs/AUTH0_SETUP.md) security section

## Contributing

Contributions are welcome! Please ensure:
- Tests pass (`julia --project -e 'using Pkg; Pkg.test()'`)
- Code follows Julia style guidelines
- New features include tests

## License

MIT License - see LICENSE file for details
