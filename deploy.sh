

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables
APP_NAME="houseplant-app-rust"
DOCKER_IMAGE_NAME="houseplant-app-rust-img"
DATABASE_FILE="houseplants.db"

echo "--- Starting deployment for $APP_NAME ---"

# --- 1. System Prerequisite Check ---
echo "Checking for Docker..."
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed. Please install Docker first."
  echo "You can follow the official instructions at: https://docs.docker.com/engine/install/ubuntu/"
  exit 1
fi
echo "Docker is installed."

# --- 2. Create Database File ---
if [ ! -f "$DATABASE_FILE" ]; then
    echo "Creating SQLite database file: $DATABASE_FILE"
    touch "$DATABASE_FILE"
fi

# --- 3. Create .env file if it doesn't exist ---
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    echo "DATABASE_URL=sqlite:$DATABASE_FILE" > .env
    # You would add your Stripe keys here for the full app
    # echo "STRIPE_SECRET_KEY=your_secret_key" >> .env
    # echo "STRIPE_PUBLISHABLE_KEY=your_publishable_key" >> .env
fi

# --- 4. Build Docker Image ---
echo "Building Docker image: $DOCKER_IMAGE_NAME..."
docker build -t "$DOCKER_IMAGE_NAME" .
echo "Docker image built successfully."

# --- 5. Stop and Remove Existing Container ---
if [ "$(docker ps -q -f name=$APP_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop "$APP_NAME"
fi
if [ "$(docker ps -aq -f name=$APP_NAME)" ]; then
    echo "Removing existing container..."
    docker rm "$APP_NAME"
fi

# --- 6. Run New Docker Container ---
echo "Running new Docker container..."
docker run -d \
  --name "$APP_NAME" \
  -p 8080:8080 \
  -v "$(pwd)/$DATABASE_FILE":/usr/src/app/$DATABASE_FILE \
  --restart always \
  "$DOCKER_IMAGE_NAME"

echo "--- Deployment complete! ---"
echo "Your application should be running at http://<your-server-ip>:8080"

