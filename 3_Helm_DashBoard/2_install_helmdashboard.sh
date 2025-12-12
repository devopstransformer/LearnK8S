#!/bin/bash

set -e

source ../.env
RELEASE_NAME="helm-dashboard"
NAMESPACE="helm-dashboard"

# Check Helm is installed
check_helm() {
    print_info "Checking Helm installation..."
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please run 1_installHelm.sh first."
    fi
    HELM_VERSION=$(helm version --short)
    print_success "Helm is installed: $HELM_VERSION"
}

# Check kubectl is installed
check_kubectl() {
    print_info "Checking kubectl installation..."
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
    fi
    print_success "kubectl is installed"
}

# Add Helm Dashboard repository
add_helm_dashboard_repo() {
    print_info "Adding Komodor Helm Dashboard repository..."
    
    if helm repo add komodorio https://helm-charts.komodor.io; then
        print_success "Komodor repository added"
    else
        print_error "Failed to add Komodor repository"
    fi
}

# Update repositories
update_repos() {
    print_info "Updating Helm repositories..."
    
    if helm repo update; then
        print_success "Repositories updated"
    else
        print_error "Failed to update repositories"
    fi
}

# Create namespace
create_namespace() {
    print_info "Creating namespace '$NAMESPACE'..."
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        kubectl create namespace "$NAMESPACE"
        print_success "Namespace '$NAMESPACE' created"
    else
        print_info "Namespace '$NAMESPACE' already exists"
    fi
}

# Clean up conflicting resources
cleanup_conflicting_resources() {
    print_info "Checking for conflicting resources..."
    
    # Check if ClusterRole exists with wrong namespace annotation
    if kubectl get clusterrole "$RELEASE_NAME" &> /dev/null; then
        local current_namespace=$(kubectl get clusterrole "$RELEASE_NAME" -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-namespace}' 2>/dev/null || echo "default")
        
        if [ "$current_namespace" != "$NAMESPACE" ]; then
            print_info "Found conflicting ClusterRole with namespace annotation: $current_namespace"
            print_info "Deleting conflicting ClusterRole and ClusterRoleBinding..."
            kubectl delete clusterrole "$RELEASE_NAME" --ignore-not-found=true
            kubectl delete clusterrolebinding "$RELEASE_NAME" --ignore-not-found=true
            sleep 2
            print_success "Conflicting resources removed"
        fi
    fi
}

# Install Helm Dashboard
install_helm_dashboard() {
    print_info "Installing Helm Dashboard in namespace '$NAMESPACE'..."
    
    if helm upgrade --install "$RELEASE_NAME" komodorio/helm-dashboard \
        -n "$NAMESPACE" \
        --set service.type=LoadBalancer \
        --set service.port=8080 \
        --set dashboard.allowWriteActions=true \
        ; then
        print_success "Helm Dashboard installed successfully"
    else
        print_error "Failed to install Helm Dashboard"
    fi
}

# Wait for deployment
wait_for_deployment() {
    print_info "Waiting for Helm Dashboard deployment to be ready..."
    if kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=300s; then
        print_success "Helm Dashboard deployment is ready"
    else
        print_error "Timeout waiting for Helm Dashboard deployment"
    fi
}

# Show release information
show_release_info() {
    echo ""
    print_info "Release Information:"
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    echo ""
    print_info "Pods:"
    kubectl get pods -n "$NAMESPACE"
    
    echo ""
    print_info "Services:"
    kubectl get svc -n "$NAMESPACE"
}

# Get access information
get_access_info() {
    echo ""
    print_info "Helm Dashboard Access Information:"
    
    local service_type=$(kubectl get svc "$RELEASE_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.type}')
    echo "Service Type: $service_type"
    
    if [ "$service_type" = "LoadBalancer" ]; then
        echo ""
        echo "Getting external IP (this may take a moment)..."
        kubectl get svc "$RELEASE_NAME" -n "$NAMESPACE" -o wide
        
        echo ""
        echo "Access the dashboard at the External IP on port 8080"
        echo "Example: http://<EXTERNAL-IP>:8080"
    else
        echo ""
        echo "To access the dashboard, use port forwarding:"
        echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 8080:8080 &"
        echo ""
        echo "Then access: http://localhost:8080"
    fi
}

# Main
main() {
    echo "================================"
    print_info "Helm Dashboard Installer"
    echo "================================"
    echo ""
    
    check_helm
    check_kubectl
    
    
    add_helm_dashboard_repo
    
    
    update_repos
    print_info "Using namespace: $NAMESPACE"
    
    
    create_namespace
    
    
    cleanup_conflicting_resources
    
    
    install_helm_dashboard
    
    
    wait_for_deployment
    
    show_release_info
    
    get_access_info
    
    echo ""
    echo "================================"
    print_success "Helm Dashboard installation complete!"
    echo "================================"
    echo ""
    echo "Features:"
    echo "  • Visualize all your Helm releases"
    echo "  • Manage Helm charts and deployments"
    echo "  • View application status and logs"
    echo "  • Perform Helm operations via UI"
    echo ""
    echo "Useful commands:"
    echo "  View release status: helm status $RELEASE_NAME -n $NAMESPACE"
    echo "  View logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$RELEASE_NAME"
    echo "  Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 8080:8080"
    echo "  Upgrade release: helm upgrade $RELEASE_NAME komodorio/helm-dashboard -n $NAMESPACE"
    echo "  Uninstall: helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo ""
}

main "$@"
