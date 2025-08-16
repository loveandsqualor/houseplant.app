
# --- Stage 1: Build Stage ---
FROM rust:latest as builder

WORKDIR /usr/src/app

# Install build dependencies
RUN apt-get update && apt-get install -y libsqlite3-dev pkg-config build-essential

# Copy source code
COPY . .

# Build the application in release mode
RUN cargo build --release

# --- Stage 2: Final Stage ---
FROM debian:bullseye-slim

WORKDIR /usr/src/app

# Install runtime dependencies
RUN apt-get update && apt-get install -y libsqlite3-0

# Copy the built binary from the builder stage
COPY --from=builder /usr/src/app/target/release/houseplant_app_rust .

# Copy templates and static files
COPY templates ./templates
COPY static ./static
COPY .env ./.env

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./houseplant_app_rust"]
