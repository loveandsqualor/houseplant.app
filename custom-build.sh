#!/bin/bash

# 🌿 Botanical Bliss Custom Build Script
# Advanced build process with optimization and development features

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
APP_NAME="botanical-bliss"
IMAGE_NAME="botanical-bliss:dev"
CONTAINER_NAME="botanical-bliss-dev"
BUILD_LOG="build-$(date +%Y%m%d-%H%M%S).log"

echo -e "${GREEN}🌿 Botanical Bliss Custom Build System 🌿${NC}"
echo -e "${CYAN}==============================================${NC}"
echo ""

# Function to log with timestamp
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[$timestamp]${NC} $message"
    echo "[$timestamp] $message" >> "$BUILD_LOG"
}

# Function to log success
success() {
    echo -e "${GREEN}✅ $1${NC}"
    echo "✅ $1" >> "$BUILD_LOG"
}

# Function to log warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    echo "⚠️  $1" >> "$BUILD_LOG"
}

# Function to log error
error() {
    echo -e "${RED}❌ $1${NC}"
    echo "❌ $1" >> "$BUILD_LOG"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    success "Docker is available"
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    success "Docker daemon is running"
    
    # Check for required files
    local required_files=("Cargo.toml" "src/main.rs" "Dockerfile")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file '$file' not found"
            exit 1
        fi
    done
    success "All required files present"
}

# Clean up function
cleanup() {
    log "Cleaning up previous builds..."
    
    # Remove old containers
    if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker rm -f "$CONTAINER_NAME" &> /dev/null || true
    fi
    
    # Remove old images (keep last 3)
    local old_images=$(docker images "$IMAGE_NAME" -q | tail -n +4)
    if [[ -n "$old_images" ]]; then
        echo "$old_images" | xargs docker rmi &> /dev/null || true
    fi
    
    success "Cleanup completed"
}

# Build function with progress tracking
build_image() {
    log "Starting Docker build process..."
    
    # Build with progress and cache
    if docker build \
        --progress=plain \
        --tag "$IMAGE_NAME" \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --label "build.date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --label "build.version=dev" \
        --label "build.environment=development" \
        . 2>&1 | tee -a "$BUILD_LOG"; then
        
        success "Docker image built successfully"
        
        # Show image details
        log "Image details:"
        docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
        
    else
        error "Docker build failed. Check $BUILD_LOG for details."
        exit 1
    fi
}

# Development server function
run_dev_server() {
    log "Starting development server..."
    
    # Create necessary directories
    mkdir -p logs uploads data backups
    
    # Run container with development settings
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p 8080:8080 \
        -v "$(pwd)/houseplants.db:/app/houseplants.db" \
        -v "$(pwd)/uploads:/app/uploads" \
        -v "$(pwd)/logs:/app/logs" \
        -v "$(pwd)/.env:/app/.env" \
        --env APP_ENV=development \
        --env RUST_LOG=debug \
        --env RUST_BACKTRACE=1 \
        "$IMAGE_NAME" 2>&1 | tee -a "$BUILD_LOG"
    
    if [[ $? -eq 0 ]]; then
        success "Development server started"
        
        # Wait for server to be ready
        log "Waiting for server to be ready..."
        local attempts=0
        local max_attempts=30
        
        while [[ $attempts -lt $max_attempts ]]; do
            if curl -s http://localhost:8080 &> /dev/null; then
                success "Server is ready!"
                break
            fi
            
            attempts=$((attempts + 1))
            echo -n "."
            sleep 1
        done
        
        if [[ $attempts -eq $max_attempts ]]; then
            warning "Server may not be ready yet. Check logs with: docker logs $CONTAINER_NAME"
        fi
        
    else
        error "Failed to start development server"
        exit 1
    fi
}

# Health check function
health_check() {
    log "Running health checks..."
    
    local endpoints=(
        "/"
        "/menu"
        "/login"
        "/signup"
        "/membership"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s -f "http://localhost:8080$endpoint" &> /dev/null; then
            success "✓ $endpoint"
        else
            warning "⚠ $endpoint (may require authentication)"
        fi
    done
}

# Performance test function
performance_test() {
    log "Running basic performance tests..."
    
    # Test response time
    local start_time=$(date +%s%N)
    curl -s http://localhost:8080 &> /dev/null
    local end_time=$(date +%s%N)
    local response_time=$(( (end_time - start_time) / 1000000 ))
    
    if [[ $response_time -lt 500 ]]; then
        success "Response time: ${response_time}ms (excellent)"
    elif [[ $response_time -lt 1000 ]]; then
        success "Response time: ${response_time}ms (good)"
    else
        warning "Response time: ${response_time}ms (could be improved)"
    fi
    
    # Test concurrent requests
    log "Testing concurrent requests..."
    if timeout 10s bash -c 'for i in {1..10}; do curl -s http://localhost:8080 &> /dev/null & done; wait'; then
        success "Concurrent request handling: OK"
    else
        warning "Some concurrent requests failed"
    fi
}

# Show development information
show_dev_info() {
    echo ""
    echo -e "${PURPLE}🚀 Development Server Information${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo ""
    echo -e "${GREEN}📱 Application URLs:${NC}"
    echo -e "   🏠 Homepage:     ${CYAN}http://localhost:8080${NC}"
    echo -e "   🛒 Plant Shop:   ${CYAN}http://localhost:8080/menu${NC}"
    echo -e "   💎 Membership:   ${CYAN}http://localhost:8080/membership${NC}"
    echo -e "   👑 Admin Panel:  ${CYAN}http://localhost:8080/admin${NC}"
    echo ""
    echo -e "${GREEN}🔧 Development Commands:${NC}"
    echo -e "   📝 View logs:    ${YELLOW}docker logs -f $CONTAINER_NAME${NC}"
    echo -e "   📊 Stats:        ${YELLOW}docker stats $CONTAINER_NAME${NC}"
    echo -e "   🔄 Restart:      ${YELLOW}docker restart $CONTAINER_NAME${NC}"
    echo -e "   🛑 Stop:         ${YELLOW}docker stop $CONTAINER_NAME${NC}"
    echo -e "   🧹 Clean up:     ${YELLOW}docker rm -f $CONTAINER_NAME${NC}"
    echo ""
    echo -e "${GREEN}📁 Important Files:${NC}"
    echo -e "   📋 Build log:    ${YELLOW}$BUILD_LOG${NC}"
    echo -e "   💾 Database:     ${YELLOW}houseplants.db${NC}"
    echo -e "   ⚙️  Environment:  ${YELLOW}.env${NC}"
    echo ""
}

# Main execution
main() {
    echo "Starting custom build process..." | tee "$BUILD_LOG"
    
    # Parse command line arguments
    local skip_cleanup=false
    local run_tests=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-cleanup)
                skip_cleanup=true
                shift
                ;;
            --with-tests)
                run_tests=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--skip-cleanup] [--with-tests] [--help]"
                echo "  --skip-cleanup: Skip cleanup of old containers/images"
                echo "  --with-tests: Run performance tests after build"
                echo "  --help: Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Execute build steps
    check_prerequisites
    
    if [[ "$skip_cleanup" != true ]]; then
        cleanup
    fi
    
    build_image
    run_dev_server
    
    # Give server time to start
    sleep 3
    
    health_check
    
    if [[ "$run_tests" == true ]]; then
        performance_test
    fi
    
    show_dev_info
    
    success "Build completed successfully!"
    
    # Optional: Open browser
    if command -v open &> /dev/null; then
        log "Opening application in browser..."
        open http://localhost:8080
    elif command -v xdg-open &> /dev/null; then
        log "Opening application in browser..."
        xdg-open http://localhost:8080
    fi
    
    echo -e "${GREEN}🌱 Botanical Bliss development environment is ready! 🌱${NC}"
}

# Trap for cleanup on exit
trap 'echo -e "\n${YELLOW}Build interrupted. Check $BUILD_LOG for details.${NC}"' INT TERM

# Run main function with all arguments
main "$@"
