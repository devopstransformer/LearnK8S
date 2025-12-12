#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default cluster name
CLUSTER_NAME="${1:-minikube}"

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

# Start Minikube cluster
start_minikube_cluster() {
    print_info "Starting Minikube cluster: $CLUSTER_NAME..."
    
    if [ "$CLUSTER_NAME" = "minikube" ]; then
        # Default cluster
        minikube start --driver=docker
    else
        # Named cluster
        minikube start --profile="$CLUSTER_NAME" --driver=docker
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Minikube cluster '$CLUSTER_NAME' started successfully"
        echo ""
        print_info "Cluster information:"
        minikube status -p "$CLUSTER_NAME"
        echo ""
        print_info "Kubernetes nodes:"
        kubectl get nodes
        echo ""
        print_success "Ready to use!"
    else
        print_error "Failed to start Minikube cluster"
    fi
}

# Main
main() {
    echo "================================"
    echo "Minikube Cluster Starter"
    echo "================================"
    echo ""
    
    # Check if Minikube is installed
    if ! command -v minikube &> /dev/null; then
        print_error "Minikube is not installed. Please run 1_install.sh first."
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
    
    start_minikube_cluster
}

main "$@"
