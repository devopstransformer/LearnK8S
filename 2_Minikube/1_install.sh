#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux";;
        Darwin*)    OS="Darwin";;
        *)          print_error "Unsupported operating system";;
    esac
    print_info "Detected OS: $OS"
}

# Check for Docker
check_docker() {
    print_info "Checking for Docker..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first: https://docs.docker.com/get-docker/"
    fi
    DOCKER_VERSION=$(docker --version)
    print_success "Docker found: $DOCKER_VERSION"
}

# Check if Docker daemon is running
check_docker_daemon() {
    print_info "Checking if Docker daemon is running..."
    if ! docker ps &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
    fi
    print_success "Docker daemon is running"
}

# Install Minikube
install_minikube() {
    print_info "Installing Minikube..."
    
    if [ "$OS" = "Linux" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        MINIKUBE_URL="https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-${ARCH}"
    elif [ "$OS" = "Darwin" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        MINIKUBE_URL="https://github.com/kubernetes/minikube/releases/latest/download/minikube-darwin-${ARCH}"
    fi
    
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT
    
    MINIKUBE_BIN="$TMP_DIR/minikube"
    
    print_info "Downloading Minikube from $MINIKUBE_URL..."
    if curl -sL -o "$MINIKUBE_BIN" "$MINIKUBE_URL"; then
        print_success "Minikube binary downloaded"
    else
        print_error "Failed to download Minikube binary"
    fi
    
    chmod +x "$MINIKUBE_BIN"
    
    print_info "Installing Minikube to /usr/local/bin/..."
    if sudo install "$MINIKUBE_BIN" /usr/local/bin/minikube; then
        print_success "Minikube installed successfully"
    else
        print_error "Failed to install Minikube. You may need elevated privileges."
    fi
}

# Verify installation
verify_installation() {
    print_info "Verifying Minikube installation..."
    if ! command -v minikube &> /dev/null; then
        print_error "Minikube installation verification failed"
    fi
    MINIKUBE_VERSION=$(minikube version)
    print_success "Minikube installed: $MINIKUBE_VERSION"
}

# Check for kubectl
check_kubectl() {
    print_info "Checking for kubectl..."
    if ! command -v kubectl &> /dev/null; then
        print_info "kubectl is not installed. It is recommended for working with Minikube clusters."
        read -p "Would you like to install kubectl? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_kubectl
        fi
    else
        KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null)
        print_success "kubectl found: $KUBECTL_VERSION"
    fi
}

# Install kubectl
install_kubectl() {
    print_info "Installing kubectl..."
    
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    
    if [ "$OS" = "Linux" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
    elif [ "$OS" = "Darwin" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/darwin/${ARCH}/kubectl"
    fi
    
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT
    
    KUBECTL_BIN="$TMP_DIR/kubectl"
    
    print_info "Downloading kubectl..."
    if curl -sL -o "$KUBECTL_BIN" "$KUBECTL_URL"; then
        print_success "kubectl binary downloaded"
    else
        print_error "Failed to download kubectl binary"
    fi
    
    chmod +x "$KUBECTL_BIN"
    
    print_info "Installing kubectl to /usr/local/bin/..."
    if sudo install "$KUBECTL_BIN" /usr/local/bin/kubectl; then
        print_success "kubectl installed successfully"
    else
        print_error "Failed to install kubectl"
    fi
}

# Main installation flow
main() {
    echo "================================"
    echo "Minikube Installation Script"
    echo "================================"
    echo ""
    
    detect_os
    check_docker
    check_docker_daemon
    install_minikube
    verify_installation
    check_kubectl
    
    echo ""
    echo "================================"
    print_success "Installation complete!"
    echo "================================"
    echo ""
    echo "Next steps:"
    echo "  1. Start a cluster: ./2_createcluster.sh"
    echo "  2. Run nginx pod: ./3_RunNginxPod.sh"
    echo ""
}

main "$@"
