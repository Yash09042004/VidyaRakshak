#!/bin/bash

# ----------------------------------------------------------------------------
# Ensure the script is run with sudo
# ----------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit
fi

# ----------------------------------------------------------------------------
# Clone the repository
# ----------------------------------------------------------------------------
REPO_URL="https://github.com/Yash09042004/EduQuiz.git"
REPO_DIR="EduQuiz"

echo "Cloning the repository..."
git clone $REPO_URL


# Change directory to the cloned repository
cd $REPO_DIR || exit

# ----------------------------------------------------------------------------
# Check if Docker is already installed
# ----------------------------------------------------------------------------
if command -v docker &> /dev/null; then
    echo "Docker is already installed. Skipping Docker installation."
else
    # ----------------------------------------------------------------------------
    # Install Docker using APT
    # ----------------------------------------------------------------------------
    echo "Updating package list..."
    sudo apt-get update

    echo "Installing required packages..."
    sudo apt-get install -y ca-certificates curl gnupg

    # Add Docker's official GPG key
    echo "Adding Docker's official GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null

    # Add the Docker APT repository
    echo "Adding Docker APT repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine, CLI, and Containerd
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

    # Install Docker Compose
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker and Docker Compose installation completed successfully!"
fi

# ----------------------------------------------------------------------------
# Update the IP address in the .env file
# ----------------------------------------------------------------------------

# Get the IP address of the connected wireless network
IP_ADDRESS=$(ip addr show wlo1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Check if IP_ADDRESS is not empty
if [ -z "$IP_ADDRESS" ]; then
  echo "No wireless connection found or unable to retrieve IP address."
  exit 1
fi

# Define the .env file path
ENV_FILE=".env"

# Replace 'localhost' with the IP address in the .env file
sed -i "s|http://[^:]*:4400/|http://$IP_ADDRESS:4400/|g" $ENV_FILE

echo "Updated REACT_APP_BASE_API_URL in $ENV_FILE to http://$IP_ADDRESS:4400/"

# ----------------------------------------------------------------------------
# Build and start the Docker containers
# ----------------------------------------------------------------------------
echo "Building and starting Docker containers..."
sudo docker-compose build
sudo docker-compose up
