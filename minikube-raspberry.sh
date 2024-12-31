#!/bin/bash

# Exit on any error
set -e

# Create temporary directory
TEMP_DIR="/tmp/minikube-installation"
mkdir -p $TEMP_DIR
cd $TEMP_DIR

echo "Starting Minikube installation process..."
echo "Using temporary directory: $TEMP_DIR"

# Function to clean up
cleanup() {
    local exit_code=$?
    echo "Cleaning up temporary files..."
    cd ~
    rm -rf $TEMP_DIR
    exit $exit_code
}

# Register the cleanup function
trap cleanup EXIT

# 1. Update system
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# 2. Install dependencies
echo "Installing dependencies..."
sudo apt install -y curl wget apt-transport-https ca-certificates software-properties-common

# 3. Check and Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o $TEMP_DIR/get-docker.sh
    sudo sh $TEMP_DIR/get-docker.sh
    
    # Add user to docker group and activate changes
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    newgrp docker << EONG
    # Verify docker is running
    echo "Verifying Docker installation..."
    docker run hello-world
EONG
else
    echo "Docker already installed, skipping Docker installation..."
fi

# 4. Check and Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    sudo install -o root -g root -m 0755 $TEMP_DIR/kubectl /usr/local/bin/kubectl
    echo "kubectl installation complete"
else
    echo "kubectl already installed, skipping kubectl installation..."
fi

# 5. Check and Install Minikube
if ! command -v minikube &> /dev/null; then
    echo "Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
    sudo install $TEMP_DIR/minikube-linux-arm64 /usr/local/bin/minikube
    
    # Start Minikube with resource limits
    echo "Starting Minikube..."
    newgrp docker << EONG
    minikube start --driver=docker --memory=2048 --cpus=2
EONG
    echo "Minikube installation complete"
else
    echo "Minikube already installed, checking if it's running..."
    if ! minikube status &> /dev/null; then
        echo "Starting Minikube..."
        newgrp docker << EONG
        minikube start --driver=docker --memory=2048 --cpus=2
EONG
    fi
fi

# 6. Final verification
echo "Verifying installation..."
newgrp docker << EONG
kubectl get nodes
minikube status
EONG

echo "Installation complete! You can now use Minikube."
