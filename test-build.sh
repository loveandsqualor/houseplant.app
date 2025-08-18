#!/bin/bash

# Test build script for diagnosing issues with Rust dependencies
echo "Testing build directly..."

# Create base Docker image for testing
docker run --rm -v "$(pwd):/app" -w /app rust:1.75 bash -c "
set -ex

# Install necessary packages
apt-get update
apt-get install -y pkg-config libssl-dev sqlite3 libsqlite3-dev ca-certificates
update-ca-certificates

# Create cargo config
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml << EOF
[net]
retry = 10
git-fetch-with-cli = true

[source.crates-io]
registry = \"https://github.com/rust-lang/crates.io-index\"

[http]
check-revoke = false
EOF

# Check cargo version
cargo --version

# Check dependencies
cargo check -v

echo 'Test build completed'
"
