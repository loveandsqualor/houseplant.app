# 🌿 Botanical Bliss Production Dockerfile
# Multi-stage build for optimal performance and security

# Stage 1: Build stage with full Rust toolchain
# Use Rust nightly for edition2024 features
FROM rustlang/rust:nightly-slim as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    libssl-dev \
    sqlite3 \
    libsqlite3-dev \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Update certificates for secure builds
RUN update-ca-certificates --fresh

# Set working directory
WORKDIR /app

# Configure Cargo for optimal builds
ENV CARGO_NET_RETRY=10
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ENV RUSTFLAGS="-C target-cpu=native -C opt-level=3"
ENV RUST_BACKTRACE=1

# Copy dependency files first for better caching
COPY Cargo.toml Cargo.lock ./

# Create dummy source to cache dependencies
RUN mkdir -p src && \
    echo 'fn main() { println!("Building dependencies..."); }' > src/main.rs

# Build dependencies (this layer will be cached)
RUN cargo build --release && rm src/main.rs && rm -rf target/release/deps/houseplant_app_rust*

# Copy actual source code
COPY src/ ./src/
COPY templates/ ./templates/
COPY static/ ./static/
COPY .env ./

# Build the actual application with optimizations
RUN cargo build --release

# Stage 2: Runtime stage with minimal dependencies
FROM debian:bookworm-slim AS runtime

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    sqlite3 \
    libssl3 \
    libsqlite3-0 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN groupadd -r botanicalbliss && useradd -r -g botanicalbliss botanicalbliss

# Set working directory
WORKDIR /app

# Copy binary and required files from builder
COPY --from=builder /app/target/release/houseplant_app_rust ./botanicalbliss
COPY --from=builder /app/templates/ ./templates/
COPY --from=builder /app/static/ ./static/
COPY --from=builder /app/.env ./

# Create necessary directories
RUN mkdir -p uploads logs data && \
    chown -R botanicalbliss:botanicalbliss /app

# Create database file with correct permissions
RUN touch houseplants.db && \
    chown botanicalbliss:botanicalbliss houseplants.db

# Switch to non-root user
USER botanicalbliss

# Set environment variables for production
ENV RUST_LOG=info
ENV DATABASE_URL=sqlite:houseplants.db
ENV APP_HOST=0.0.0.0
ENV APP_PORT=8080
ENV APP_ENV=production

# Expose application port
EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["./botanicalbliss"]

# Metadata labels for better container management
LABEL org.opencontainers.image.title="Botanical Bliss"
LABEL org.opencontainers.image.description="Modern botanical ecommerce platform"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="Botanical Bliss Team"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/loveandsqualor/houseplant.app"
