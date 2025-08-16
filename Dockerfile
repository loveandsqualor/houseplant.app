
FROM rust:1.79-slim as builder

WORKDIR /usr/src/app
git commit -m "Fix actix-session and sqlx compatibility issues" AS builder

WORKDIR /app
COPY . .

# Build the application in release mode
RUN cargo build --release

# Stage 2: Final Stage
FROM debian:bullseye-slim AS runtime

WORKDIR /app
COPY --from=builder /app/target/release/your-binary-name .

CMD ["./houseplant_app_rust"]
