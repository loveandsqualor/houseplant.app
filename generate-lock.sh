#!/bin/bash

# Generate a Cargo.lock file using Docker
docker run --rm -v "$(pwd):/app" -w /app rust:1.75 bash -c '
set -ex

# Install required packages
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
registry = "https://github.com/rust-lang/crates.io-index"

[http]
check-revoke = false
EOF

# Generate Cargo.lock file
cargo generate-lockfile

# Ensure the Cargo.lock file has the correct permissions
chmod 644 Cargo.lock
'
