# 1. Actualizar el sistema
sudo apt update
sudo apt upgrade -y

# 2. Instalar dependencias necesarias
sudo apt install -y curl wget apt-transport-https ca-certificates software-properties-common

# 3. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# 4. Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 5. Instalar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube

# 6. Iniciar Minikube
# Después de reiniciar la sesión para aplicar los cambios de grupo de Docker:
minikube start --driver=docker

# 7. Verificar la instalación
kubectl get nodes
minikube status
