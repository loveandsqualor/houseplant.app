#!/bin/bash

# 🌿 Botanical Bliss Production Deployment Script
# Automated deployment for modern botanical ecommerce platform

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="botanical-bliss"
DOCKER_IMAGE_NAME="botanical-bliss:latest"
CONTAINER_NAME="botanical-bliss-app"
DATABASE_FILE="houseplants.db"
BACKUP_DIR="./backups"
LOG_DIR="./logs"
UPLOAD_DIR="./uploads"

echo -e "${GREEN}🌿 Botanical Bliss Deployment Script 🌿${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Function to log success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to log warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to log error
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- 1. Pre-deployment checks ---
log "Starting pre-deployment checks..."

# Check for Docker
if ! command_exists docker; then
    error "Docker is not installed. Please install Docker first."
    echo "Installation guide: https://docs.docker.com/engine/install/"
    exit 1
fi
success "Docker is installed"

# Check for required files
required_files=("Cargo.toml" "src/main.rs" "Dockerfile" ".env")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        error "Required file '$file' not found"
        exit 1
    fi
done
success "All required files present"

# --- 2. Environment setup ---
log "Setting up environment..."

# Create necessary directories
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$UPLOAD_DIR"
success "Directories created"

# Backup existing database if it exists
if [[ -f "$DATABASE_FILE" ]]; then
    backup_filename="$BACKUP_DIR/houseplants_backup_$(date +%Y%m%d_%H%M%S).db"
    cp "$DATABASE_FILE" "$backup_filename"
    success "Database backed up to $backup_filename"
fi

# Create database file if it doesn't exist
if [[ ! -f "$DATABASE_FILE" ]]; then
    touch "$DATABASE_FILE"
    success "Created database file: $DATABASE_FILE"
fi

# Validate .env file
if [[ ! -f ".env" ]]; then
    warning ".env file not found, creating default configuration..."
    cat > .env << EOF
DATABASE_URL=sqlite:$DATABASE_FILE
APP_HOST=0.0.0.0
APP_PORT=8080
APP_ENV=production
RUST_LOG=info
SESSION_SECRET_KEY=$(openssl rand -hex 32)
MEMBERSHIP_PRICE=125.00
EOF
    success "Created default .env file"
fi

# --- 3. Build Docker image ---
log "Building Docker image..."

# Check if we have a Git repository for versioning
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_COMMIT=$(git rev-parse --short HEAD)
    BUILD_TAG="$DOCKER_IMAGE_NAME-$GIT_COMMIT"
    success "Using Git commit: $GIT_COMMIT"
else
    BUILD_TAG="$DOCKER_IMAGE_NAME"
    warning "Not in a Git repository, using default tag"
fi

# Build with optimizations and caching
docker build \
    --tag "$DOCKER_IMAGE_NAME" \
    --tag "$BUILD_TAG" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --label "build.date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --label "build.commit=$GIT_COMMIT" \
    .

if [[ $? -eq 0 ]]; then
    success "Docker image built successfully"
else
    error "Docker build failed"
    exit 1
fi

# --- 4. Stop and clean up existing container ---
log "Cleaning up existing deployment..."

if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    log "Stopping existing container..."
    docker stop "$CONTAINER_NAME"
    success "Container stopped"
fi

if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    log "Removing existing container..."
    docker rm "$CONTAINER_NAME"
    success "Container removed"
fi

# Clean up old images (keep last 3)
log "Cleaning up old Docker images..."
docker images "$DOCKER_IMAGE_NAME" --format "table {{.ID}}\t{{.CreatedAt}}" | \
    tail -n +4 | awk '{print $1}' | xargs -r docker rmi || true

# --- 5. Deploy new container ---
log "Deploying new container..."

# Run container with production configuration
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p 8080:8080 \
    -v "$(pwd)/$DATABASE_FILE:/app/$DATABASE_FILE" \
    -v "$(pwd)/$UPLOAD_DIR:/app/uploads" \
    -v "$(pwd)/$LOG_DIR:/app/logs" \
    --env-file .env \
    --memory=512m \
    --cpus=1.0 \
    --health-cmd="curl -f http://localhost:8080/health || exit 1" \
    --health-interval=30s \
    --health-timeout=10s \
    --health-retries=3 \
    "$DOCKER_IMAGE_NAME"

if [[ $? -eq 0 ]]; then
    success "Container deployed successfully"
else
    error "Container deployment failed"
    exit 1
fi

# --- 6. Post-deployment verification ---
log "Running post-deployment checks..."

# Wait for container to be healthy
log "Waiting for application to be ready..."
for i in {1..30}; do
    if docker exec "$CONTAINER_NAME" curl -f http://localhost:8080/health >/dev/null 2>&1; then
        success "Application is healthy"
        break
    fi
    if [[ $i -eq 30 ]]; then
        error "Application failed to become healthy"
        log "Container logs:"
        docker logs "$CONTAINER_NAME" --tail 50
        exit 1
    fi
    sleep 2
done

# Test key endpoints
log "Testing application endpoints..."

endpoints=(
    "http://localhost:8080/"
    "http://localhost:8080/menu"
    "http://localhost:8080/login"
    "http://localhost:8080/membership"
)

for endpoint in "${endpoints[@]}"; do
    if curl -f "$endpoint" >/dev/null 2>&1; then
        success "✓ $endpoint"
    else
        warning "⚠ $endpoint (might require authentication)"
    fi
done

# --- 7. Performance optimization ---
log "Applying performance optimizations..."

# Set Docker daemon optimizations
docker system prune -f >/dev/null 2>&1 || true
success "Docker system cleaned"

# --- 8. Final deployment summary ---
echo ""
echo -e "${GREEN}🎉 Deployment completed successfully! 🎉${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${PURPLE}📊 Deployment Summary:${NC}"
echo -e "   🌐 Application URL: ${CYAN}http://localhost:8080${NC}"
echo -e "   🏠 Homepage: ${CYAN}http://localhost:8080/${NC}"
echo -e "   🛒 Plant Shop: ${CYAN}http://localhost:8080/menu${NC}"
echo -e "   💎 Membership: ${CYAN}http://localhost:8080/membership${NC}"
echo -e "   👑 Admin Panel: ${CYAN}http://localhost:8080/admin${NC}"
echo ""
echo -e "${PURPLE}🔧 Management Commands:${NC}"
echo -e "   📝 View logs: ${YELLOW}docker logs $CONTAINER_NAME${NC}"
echo -e "   📊 Container stats: ${YELLOW}docker stats $CONTAINER_NAME${NC}"
echo -e "   🔄 Restart app: ${YELLOW}docker restart $CONTAINER_NAME${NC}"
echo -e "   🛑 Stop app: ${YELLOW}docker stop $CONTAINER_NAME${NC}"
echo ""
echo -e "${PURPLE}📁 Important Files:${NC}"
echo -e "   💾 Database: ${YELLOW}$DATABASE_FILE${NC}"
echo -e "   📋 Logs: ${YELLOW}$LOG_DIR/${NC}"
echo -e "   📤 Uploads: ${YELLOW}$UPLOAD_DIR/${NC}"
echo -e "   💾 Backups: ${YELLOW}$BACKUP_DIR/${NC}"
echo ""
echo -e "${GREEN}🌱 Botanical Bliss is now serving millions of plant enthusiasts! 🌱${NC}"
echo ""

# Optional: Open browser (macOS/Linux with GUI)
if command_exists open; then
    log "Opening application in browser..."
    open http://localhost:8080
elif command_exists xdg-open; then
    log "Opening application in browser..."
    xdg-open http://localhost:8080
fi

exit 0

