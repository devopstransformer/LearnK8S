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

# Create kind cluster
create_kind_cluster() {
   
    local CLUSTER_NAME="test-cluster"
    print_info "Creating kind cluster:  TEST $CLUSTER_NAME..."
    
    if kind create cluster --name "$CLUSTER_NAME"; then
        print_success "Cluster '$CLUSTER_NAME' created successfully"
        echo ""
        print_info "Cluster information:"
        kubectl cluster-info --context "kind-${CLUSTER_NAME}"
        echo ""
        print_info "View nodes:"
        kubectl get nodes --context "kind-${CLUSTER_NAME}"
        echo ""
        print_success "Ready to use! Context: kind-${CLUSTER_NAME}"
    else
        print_error "Failed to create cluster '$CLUSTER_NAME'"
    fi
}

# Main
main() {
    echo "================================"
    echo "Kind Cluster Creator"
    echo "================================"
    echo ""
    
    # Check if kind is installed
    if ! command -v kind &> /dev/null; then
        print_error "kind is not installed. Please run install.sh first."
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
    fi
    
    # Check if Docker daemon is running
    print_info "Checking if Docker daemon is running..."
    if ! docker ps &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
    fi
    print_success "Docker daemon is running"
    echo ""
    
    # Get cluster name from argument or use default
    CLUSTER_NAME="${1:-kind}"
    
    create_kind_cluster "$CLUSTER_NAME"
}

main "$@"
