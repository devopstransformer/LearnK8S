#!/bin/bash

#At the moment the nginx might not working behind a company proxy
#and stuck ar Waiting for nginx pod to be ready...
#you can try to pull the image local and use t

set -e

source ../.env

# Check if cluster exists
check_cluster() {
    print_info "Checking if cluster exists (context: $CLUSTER_CONTEXT)..."
    
    if ! kubectl cluster-info --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_error "Cluster not found. Please run 2_createcluster.sh first."
    fi
    print_success "Cluster is running"
}

# Deploy nginx pod
deploy_nginx() {
    print_info "Deploying nginx pod to the cluster..."
    
    kubectl run nginx-pod --image=nginx:latest --context="$CLUSTER_CONTEXT"
    
    if [ $? -eq 0 ]; then
        print_success "Nginx pod deployment initiated"
    else
        print_error "Failed to deploy nginx pod"
    fi
}

# Wait for pod to be ready
wait_for_pod() {
    print_info "Waiting for nginx pod to be ready..."
    
    kubectl wait --for=condition=ready pod/nginx-pod --timeout=300s --context="$CLUSTER_CONTEXT"
    
    if [ $? -eq 0 ]; then
        print_success "Nginx pod is ready"
    else
        print_error "Timeout waiting for nginx pod to be ready"
    fi
}

# Get pod details
show_pod_details() {
    echo ""
    print_info "Pod Details:"
    kubectl get pod nginx-pod -o wide --context="$CLUSTER_CONTEXT"
    
    echo ""
    print_info "Pod Description:"
    kubectl describe pod nginx-pod --context="$CLUSTER_CONTEXT"
}

# Port forward nginx
port_forward_nginx() {
    echo ""
    print_info "Setting up port forward to nginx pod..."
    echo "Forwarding localhost:8080 -> nginx-pod:80"
    echo ""
    print_info "Access nginx at: http://localhost:8080"
    print_info "Press Ctrl+C to stop port forwarding"
    echo ""
    
    kubectl port-forward pod/nginx-pod 8080:80 --context="$CLUSTER_CONTEXT"
}

# Check nginx logs
show_nginx_logs() {
    echo ""
    print_header "Nginx Pod Logs:"
    kubectl logs nginx-pod --context="$CLUSTER_CONTEXT"
}

# Main
main() {
    echo "================================"
    print_info "Nginx Pod Deployment"
    echo "================================"
    echo ""
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
    fi
    
    check_cluster
    echo ""
    
    # Check if pod already exists
    if kubectl get pod nginx-pod --context="$(get_cluster_name)" &> /dev/null 2>&1; then
        print_info "Nginx pod already exists"
        
        read -p "Do you want to delete and recreate it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete pod nginx-pod --context="$(get_cluster_name)"
            print_success "Pod deleted"
            echo ""
            deploy_nginx
            wait_for_pod
        fi
    else
        deploy_nginx
        echo ""
        wait_for_pod
    fi
    
    show_pod_details
    
    echo ""
    read -p "Do you want to setup port forwarding? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        port_forward_nginx
    else
        show_nginx_logs
    fi
}

main "$@"
