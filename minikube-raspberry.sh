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
    local exit_status=$?
    echo "Cleaning up temporary files..."
    cd $HOME
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    return $exit_status
}

# Register the cleanup function
trap cleanup EXIT ERR

# Function to check if user needs to be added to docker group
need_docker_group() {
    if ! groups | grep -q docker; then
        return 0
    else
        return 1
    fi
}

# Function to start minikube in new session
start_minikube_session() {
    echo "Starting new session for Minikube initialization..."
    
    # Create a script for the new session
    cat > $TEMP_DIR/start_minikube.sh << 'EOF'
#!/bin/bash
export PATH=$PATH:/usr/local/bin
echo "Starting Minikube..."
minikube start --driver=docker --memory=2048 --cpus=2
if [ $? -eq 0 ]; then
    echo "Verifying installation..."
    kubectl get nodes
    minikube status
    echo "MINIKUBE_START_SUCCESS=true" > $TEMP_DIR/minikube_status
else
    echo "MINIKUBE_START_SUCCESS=false" > $TEMP_DIR/minikube_status
fi
EOF
    
    chmod +x $TEMP_DIR/start_minikube.sh
    
    echo "Starting new session with docker group permissions..."
    # Run the script as current user but with new group session
    sudo -u $USER sg docker -c "$TEMP_DIR/start_minikube.sh" 2>&1 | tee $TEMP_DIR/minikube_output.log
    
    # Check the result
    if [ -f "$TEMP_DIR/minikube_status" ]; then
        source $TEMP_DIR/minikube_status
        if [ "$MINIKUBE_START_SUCCESS" = "true" ]; then
            echo "Minikube started successfully!"
        else
            echo "Failed to start Minikube. Please check the output above."
            return 1
        fi
    fi
}

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
    
    echo "Docker installed successfully."
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
    echo "Minikube installation complete"
fi

# 6. Start Minikube with proper permissions
if need_docker_group; then
    echo "Docker group was just added. Starting new session for Minikube..."
    start_minikube_session
else
    # Only start minikube if docker group is already active
    if ! minikube status &> /dev/null; then
        echo "Starting Minikube in current session..."
        minikube start --driver=docker --memory=2048 --cpus=2
        
        echo "Verifying installation..."
        kubectl get nodes
        minikube status
    else
        echo "Minikube is already running"
    fi
fi

echo "Installation complete!"
