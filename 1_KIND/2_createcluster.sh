#!/bin/bash

set -e

source ../.env



# Create kind cluster from starter.yml
create_kind_cluster() {
    
    
    # Check if starter.yml exists
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file '$CONFIG_FILE' not found in current directory"
    fi
    
    print_info "Creating kind cluster from $CONFIG_FILE..."
    
    if kind create cluster --config "$CONFIG_FILE"; then
        print_success "Cluster created successfully from $CONFIG_FILE"
        echo ""
        print_info "Cluster information:"
        #if you don´t want the prefix "kind-" in the context name, remove it from starter.yml with the option --no-prefex
        #otherwise always kind- is added
        kubectl cluster-info --context kind-$CLUSTER_NAME
        echo ""
        print_info "View nodes:"
        kubectl get nodes --context kind-$CLUSTER_NAME
        echo ""
        print_success "Ready to use! Context: $CLUSTER_NAME"
    else
        print_error "Failed to create cluster from $CONFIG_FILE"
    fi
}

# Main
main() {
    echo "================================"
    echo "Kind Cluster Creator"
    echo "================================"
    
    
    # Check if kind is installed
    if ! command -v kind &> /dev/null; then
        print_error "kind is not installed. Please run 1_install.sh first."
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
    
    create_kind_cluster
}

main "$@"
