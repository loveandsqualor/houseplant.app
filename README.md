README.ME
ouseplant App (Rust Version)Welcome to the Houseplant App, now powered by Rust! This application helps you manage your houseplant collection.FeaturesBrowse available houseplants.Admin panel to add, update, and delete products.Built with Rust, Actix-web, and SQLite for high performance and reliability.Deployment on Ubuntu 24.04This application is designed to be deployed using Docker.PrerequisitesAn Ubuntu 24.04 server.Docker and Docker Compose installed on the server.Git for cloning the repository.Deployment StepsClone the repository:git clone <your-repository-url>
cd houseplant_app_rust
Run the deployment script:This script will handle everything from creating the database file to building and running the Docker container.chmod +x deploy.sh
./deploy.sh
Access your application:Once the script finishes, your application will be running and accessible at http://<your-server-ip>:8080.Local DevelopmentInstall Rust:Follow the official instructions at rust-lang.org.Install sqlx-cli:cargo install sqlx-cli
Set up the database:cp .env.example .env # Edit .env to set DATABASE_URL
sqlx database create
sqlx migrate run
Run the application:cargo run
The app will be available at http://127.0.0.1:8080.App for delivering houseplants

