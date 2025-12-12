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

# Check for kubectl
check_kubectl() {
    print_info "Checking for kubectl..."
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
    fi
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null)
    print_success "kubectl found: $KUBECTL_VERSION"
}

# Install Helm on Linux (Debian/Ubuntu)
install_helm_linux() {
    print_info "Installing Helm on Linux (Debian/Ubuntu)..."
    
    # Install dependencies
    print_info "Installing dependencies..."
    if ! sudo apt-get install curl gpg apt-transport-https --yes; then
        print_error "Failed to install dependencies"
    fi
    print_success "Dependencies installed"
    
    # Add Helm GPG key
    print_info "Adding Helm GPG key..."
    if ! curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null; then
        print_error "Failed to add Helm GPG key"
    fi
    print_success "Helm GPG key added"
    
    # Add Helm repository
    print_info "Adding Helm repository..."
    if ! echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null; then
        print_error "Failed to add Helm repository"
    fi
    print_success "Helm repository added"
    
    # Update and install Helm
    print_info "Updating package list and installing Helm..."
    if ! sudo apt-get update; then
        print_error "Failed to update package list"
    fi
    
    if ! sudo apt-get install helm --yes; then
        print_error "Failed to install Helm"
    fi
    print_success "Helm installed successfully"
}

# Install Helm on macOS
install_helm_macos() {
    print_info "Installing Helm on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install Homebrew first: https://brew.sh"
    fi
    
    if ! brew install helm; then
        print_error "Failed to install Helm"
    fi
    print_success "Helm installed successfully"
}

# Verify installation
verify_installation() {
    print_info "Verifying Helm installation..."
    if ! command -v helm &> /dev/null; then
        print_error "Helm installation verification failed"
    fi
    HELM_VERSION=$(helm version)
    print_success "Helm installed: $HELM_VERSION"
}

# Main installation flow
main() {
    echo "================================"
    echo "Helm Installation Script"
    echo "================================"
    echo ""
    
    detect_os
    check_kubectl
    echo ""
    
    if [ "$OS" = "Linux" ]; then
        install_helm_linux
    elif [ "$OS" = "Darwin" ]; then
        install_helm_macos
    fi
    
    echo ""
    verify_installation
    
    echo ""
    echo "================================"
    print_success "Helm installation complete!"
    echo "================================"

}

main "$@"
