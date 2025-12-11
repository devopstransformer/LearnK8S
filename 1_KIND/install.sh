#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Versions
KIND_VERSION="${KIND_VERSION:-v0.20.0}"

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

# Check if running on a supported OS
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

# Install kind
install_kind() {
    print_info "Installing kind version $KIND_VERSION..."
    
    if [ "$OS" = "Linux" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
    elif [ "$OS" = "Darwin" ]; then
        ARCH="amd64"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        fi
        KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-darwin-${ARCH}"
    fi
    
    # Download kind binary
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT
    
    KIND_BIN="$TMP_DIR/kind"
    
    print_info "Downloading kind from $KIND_URL..."
    if curl -sL -o "$KIND_BIN" "$KIND_URL"; then
        print_success "Kind binary downloaded"
    else
        print_error "Failed to download kind binary"
    fi
    
    # Make it executable
    chmod +x "$KIND_BIN"
    
    # Move to /usr/local/bin
    print_info "Installing kind to /usr/local/bin/..."
    if sudo mv "$KIND_BIN" /usr/local/bin/kind; then
        print_success "Kind installed successfully"
    else
        print_error "Failed to install kind. You may need elevated privileges."
    fi
}

# Verify installation
verify_installation() {
    print_info "Verifying kind installation..."
    if ! command -v kind &> /dev/null; then
        print_error "Kind installation verification failed"
    fi
    KIND_VERSION_INSTALLED=$(kind --version)
    print_success "Kind installed: $KIND_VERSION_INSTALLED"
}

# Check for kubectl
check_kubectl() {
    print_info "Checking for kubectl..."
    if ! command -v kubectl &> /dev/null; then
        print_info "kubectl is not installed. It is recommended for working with kind clusters."
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
    if sudo mv "$KUBECTL_BIN" /usr/local/bin/kubectl; then
        print_success "kubectl installed successfully"
    else
        print_error "Failed to install kubectl"
    fi
}



# Main installation flow
main() {
    echo "================================"
    echo "Kind Installation Script"
    echo "================================"
    echo ""
    
    detect_os
    check_docker
    check_docker_daemon
    install_kind
    verify_installation
    check_kubectl
    
    echo ""
    echo "================================"
    print_success "Installation complete!"
    echo "================================"
    echo ""
    echo "Next steps:"
    echo "  1. Create a cluster: ./createcluster.sh"
    echo "  2. Check cluster info: kubectl cluster-info --context kind-kind"
    echo "  3. View nodes: kubectl get nodes"
    echo ""
}

main "$@"
