"""
A health check for the application. 
It can be used by Docker to monitor the state of the application.
It can be used to verify that the application is up and running.
"""

# Structure to track application state
mutable struct AppHealth
    start_time::DateTime
    healthy::Bool
    last_check::DateTime
    error_count::Int
    # Add any other metrics you want to track
    
    AppHealth() = new(now(), true, now(), 0)
end

# Global health state
const app_health = AppHealth()

# Helper function to check critical services
function check_critical_services()
    try
        # Add checks for critical dependencies, e.g.:
        # - Database connectivity
        # - External API availability
        # - File system access
        # - Memory usage
        # Example:
        # if !is_database_connected()
        #     return false, "Database connection failed"
        # end
        
        #return false, "Just tricking!"
        return true, "All services operational"
    catch e
        app_health.error_count += 1
        return false, "Service check failed: $e"
    end
end

@get "/health" function()
    app_health.last_check = now()
    
    # Perform health checks
    services_ok, message = check_critical_services()
    app_health.healthy = services_ok
    
    # Calculate uptime
    uptime = now() - app_health.start_time

    # Construct health response
    health_status = Dict(
        "status" => services_ok ? "healthy" : "unhealthy",
        "timestamp" => now(),
        "uptime_seconds" => Dates.value(uptime) / 1000,
        "error_count" => app_health.error_count,
        "message" => message,
        "details" => Dict(
            "version" => "1.0.0",  # Add your app version
            "environment" => Base.get(ENV, "JULIA_ENV", "development"),
            "threads" => Threads.nthreads()
        )
    )

    # Set appropriate HTTP status code
    if !services_ok
        #return HTTP.Response(503, health_status)  # Service Unavailable
        return json(health_status, status=503)
    end
    
    return health_status    
end
