# Auth0 Setup Guide

This guide explains how to set up Auth0 authentication for OxygenTrial.jl.

## Prerequisites

- An Auth0 account (sign up for free at [auth0.com](https://auth0.com))
- Julia 1.12 or higher installed

## Step 1: Create an Auth0 Application

1. Log in to your [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** → **Applications** in the sidebar
3. Click **Create Application**
4. Enter a name (e.g., "OxygenTrial")
5. Select **Regular Web Applications** as the application type
6. Click **Create**

## Step 2: Configure Application Settings

In your Auth0 application settings:

1. **Allowed Callback URLs**: Add your callback URL
   - For local development: `http://localhost:8080/auth/callback`
   - For production: `https://yourdomain.com/auth/callback`

2. **Allowed Logout URLs**: Add your logout redirect URL (IMPORTANT!)
   - For local development: `http://localhost:8080/`
   - For production: `https://yourdomain.com/`
   - Note: Include the trailing slash

3. **Allowed Web Origins**: Add your application URL
   - For local development: `http://localhost:8080`
   - For production: `https://yourdomain.com`

4. Click **Save Changes**

## Step 3: Get Your Credentials

From the application settings page, copy:
- **Domain** (e.g., `myapp.us.auth0.com`)
- **Client ID** (a long alphanumeric string)
- **Client Secret** (click "Show" to reveal it)

## Step 4: Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your Auth0 credentials:
   ```bash
   AUTH0_DOMAIN=your-domain.auth0.com
   AUTH0_CLIENT_ID=your_client_id_here
   AUTH0_CLIENT_SECRET=your_client_secret_here
   AUTH0_CALLBACK_URL=http://localhost:8080/auth/callback
   AUTH0_LOGOUT_REDIRECT=http://localhost:8080/
   ```

   **Important:** The `AUTH0_LOGOUT_REDIRECT` must match one of the URLs in your Auth0 Application's "Allowed Logout URLs" setting.

**Note:** The `.env` file is automatically loaded when you start the server using `web-server.jl` or `web-server-revise.jl`. You don't need to manually export environment variables.

## Step 5: Install Dependencies

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
```

## Step 6: Start the Server

```bash
julia --project web-server.jl
```

## Step 7: Test Authentication

1. Open your browser to `http://localhost:8080`
2. Click **Login** in the navigation
3. You'll be redirected to Auth0's login page
4. Sign up or log in with your credentials
5. After successful authentication, you'll be redirected back to your profile page

## OAuth Routes

The following routes are available:

- `GET /auth/login` - Initiates OAuth login flow
- `GET /auth/callback` - Handles Auth0 callback (don't visit directly)
- `GET /auth/logout` - Logs out the user and clears session
- `GET /profile` - Protected route showing user profile (requires login)

## Security Considerations

### Production Deployment

1. **Use HTTPS**: Always use HTTPS in production
   - Update callback URLs to use `https://`
   - Auth0 requires HTTPS for production

2. **Secure Secrets**: Never commit `.env` to git
   - The `.gitignore` file should include `.env`
   - Use environment variables or secret management services

3. **Session Security**:
   - Sessions are currently stored in memory (resets on server restart)
   - For production, use Redis, database, or distributed cache
   - Consider adding JWT validation for additional security

4. **Cookie Security**:
   - Enable `Secure` flag on cookies when using HTTPS
   - Consider shorter session lifetimes for sensitive applications

### Environment Variables in Production

Instead of `.env` files, use your hosting platform's environment variable system:

- **Docker**: Use `-e` flag or `docker-compose.yml` env section
- **Kubernetes**: Use ConfigMaps and Secrets
- **Cloud platforms**: Use their built-in secret management (AWS Secrets Manager, Azure Key Vault, etc.)

## Customization

### Change Session Lifetime

Edit `src/SessionManager.jl`:
```julia
const SESSION_LIFETIME = Hour(1)  # Change to your desired duration
```

### Add More OAuth Scopes

Edit your `.env` file:
```bash
AUTH0_SCOPE=openid profile email read:appointments write:appointments
```

### Use Auth0 API Audience

If you're using Auth0 to protect an API, add the audience:
```bash
AUTH0_AUDIENCE=https://your-api.example.com
```

## Troubleshooting

### "Authentication Not Configured" Error

- Ensure all environment variables are set correctly
- Restart the Julia server after changing `.env`
- Check that variables are exported in your shell

### "Callback URL mismatch" Error from Auth0

- Verify the callback URL in `.env` matches exactly what's in Auth0 settings
- Check for trailing slashes (use consistent format)

### Sessions Not Persisting

- Sessions are in-memory and reset when server restarts
- Implement persistent session storage for production (Redis, PostgreSQL, etc.)

### CORS Errors

- Ensure your application URL is in "Allowed Web Origins" in Auth0 settings
- Check that the domain matches exactly (including protocol and port)

## Additional Resources

- [Auth0 Documentation](https://auth0.com/docs)
- [Auth0 Julia Integration](https://auth0.com/docs/quickstart/webapp)
- [OAuth 2.0 Specification](https://oauth.net/2/)
