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
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Main
main() {
    echo "================================"
    echo "Helm Complete Uninstall Script"
    echo "================================"
    echo ""
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_info "Helm is not installed"
    else
        # Uninstall Helm Dashboard release if exists
        print_info "Uninstalling Helm Dashboard release..."
        helm uninstall helm-dashboard -n helm-dashboard 2>/dev/null || print_info "Dashboard not installed"
        
        # Remove Helm repositories
        print_info "Removing Helm repositories..."
        helm repo remove komodorio 2>/dev/null || print_info "Komodor repository not found"
        helm repo remove bitnami 2>/dev/null || print_info "Bitnami repository not found"
        helm repo remove prometheus-community 2>/dev/null || print_info "Prometheus repository not found"
    fi
    
    # Delete helm-dashboard namespace
    print_info "Deleting helm-dashboard namespace..."
    kubectl delete namespace helm-dashboard --ignore-not-found=true
    
    # Remove Helm configuration
    print_info "Removing Helm configuration directories..."
    rm -rf ~/.config/helm
    rm -rf ~/.cache/helm
    rm -rf ~/.local/share/helm
    print_success "Helm configuration removed"
    
    # Uninstall Helm package
    print_info "Uninstalling Helm package..."
    sudo apt-get remove helm --yes 2>/dev/null || print_error "Helm not found via apt"
    
    echo ""
    echo "================================"
    print_success "Helm completely uninstalled!"
    echo "================================"
    echo ""
    echo "Verification:"
    which helm 2>/dev/null && echo "Warning: Helm still in PATH" || print_success "Helm removed from PATH"
    
    echo ""
}

main "$@"
echo "Helm uninstalled successfully"