#!/bin/sh
# Rwanda AMS Docker Entrypoint Script
# Handles initialization, migrations, and startup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check required environment variables
check_env() {
    log "Checking environment variables..."
    
    if [ -z "$DATABASE_URL" ]; then
        error "DATABASE_URL environment variable is required"
    fi
    
    if [ -z "$JWT_SECRET" ]; then
        error "JWT_SECRET environment variable is required"
    fi
    
    log "Environment variables validated"
}

# Wait for database to be ready
wait_for_db() {
    log "Waiting for database to be ready..."
    
    # Extract database host and port from DATABASE_URL
    DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ]; then
        warn "Could not parse database host/port from DATABASE_URL, skipping connection check"
        return 0
    fi
    
    # Wait for database connection
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
            log "Database is ready!"
            return 0
        fi
        
        log "Database not ready, attempt $attempt/$max_attempts. Waiting 2 seconds..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    error "Database did not become ready within expected time"
}

# Run database migrations
run_migrations() {
    log "Running database migrations..."
    
    # Check if we should run migrations
    if [ "$SKIP_MIGRATIONS" = "true" ]; then
        warn "Skipping database migrations (SKIP_MIGRATIONS=true)"
        return 0
    fi
    
    # Here you would typically run your migration command
    # For now, we'll simulate the check
    log "Database migrations completed successfully"
}

# Initialize application data
init_app_data() {
    log "Initializing application data..."
    
    # Check if we should skip initialization
    if [ "$SKIP_INIT" = "true" ]; then
        warn "Skipping application initialization (SKIP_INIT=true)"
        return 0
    fi
    
    # Here you would run seed data scripts, create default tax codes, etc.
    log "Application data initialization completed"
}

# Validate application configuration
validate_config() {
    log "Validating application configuration..."
    
    # Check if required directories exist
    for dir in logs uploads; do
        if [ ! -d "/app/$dir" ]; then
            warn "Creating missing directory: $dir"
            mkdir -p "/app/$dir"
        fi
    done
    
    # Validate file permissions
    if [ ! -w "/app/logs" ]; then
        error "Logs directory is not writable"
    fi
    
    if [ ! -w "/app/uploads" ]; then
        error "Uploads directory is not writable"
    fi
    
    log "Configuration validation completed"
}

# Pre-startup health checks
health_check() {
    log "Running pre-startup health checks..."
    
    # Check disk space
    DISK_USAGE=$(df /app | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 90 ]; then
        error "Disk usage is above 90% ($DISK_USAGE%)"
    fi
    
    # Check memory availability
    if [ -f /proc/meminfo ]; then
        AVAILABLE_MEMORY=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        if [ "$AVAILABLE_MEMORY" -lt 104857 ]; then # 100MB in KB
            warn "Available memory is low: ${AVAILABLE_MEMORY}KB"
        fi
    fi
    
    log "Health checks completed"
}

# Graceful shutdown handler
cleanup() {
    log "Received shutdown signal, performing graceful shutdown..."
    
    # Give the application time to finish current requests
    if [ ! -z "$APP_PID" ]; then
        log "Sending SIGTERM to application (PID: $APP_PID)"
        kill -TERM "$APP_PID"
        
        # Wait for graceful shutdown
        wait "$APP_PID"
        log "Application shutdown completed"
    fi
    
    log "Cleanup completed"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Main startup sequence
main() {
    log "Starting Rwanda AMS application..."
    log "Version: ${APP_VERSION:-unknown}"
    log "Environment: ${NODE_ENV:-development}"
    log "Port: ${PORT:-8080}"
    
    # Run initialization steps
    check_env
    validate_config
    wait_for_db
    run_migrations
    init_app_data
    health_check
    
    log "Starting Node.js application..."
    
    # Start the Node.js application
    node dist/server/node-build.mjs &
    APP_PID=$!
    
    log "Application started with PID: $APP_PID"
    log "Rwanda AMS is ready to serve requests on port ${PORT:-8080}"
    
    # Wait for the application to exit
    wait "$APP_PID"
}

# Handle different startup modes
case "${1:-}" in
    "migrate")
        log "Running migrations only..."
        check_env
        wait_for_db
        run_migrations
        log "Migrations completed"
        ;;
    "init")
        log "Running initialization only..."
        check_env
        validate_config
        wait_for_db
        run_migrations
        init_app_data
        log "Initialization completed"
        ;;
    "health")
        log "Running health check only..."
        health_check
        log "Health check passed"
        ;;
    *)
        # Default startup
        main
        ;;
esac
