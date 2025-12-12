#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Release name
RELEASE_NAME="helm-dashboard"
NAMESPACE="${1:-helm-dashboard}"

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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

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
        --wait; then
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
    print_header "Release Information:"
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    echo ""
    print_header "Pods:"
    kubectl get pods -n "$NAMESPACE"
    
    echo ""
    print_header "Services:"
    kubectl get svc -n "$NAMESPACE"
}

# Get access information
get_access_info() {
    echo ""
    print_header "Helm Dashboard Access Information:"
    
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
    print_header "Helm Dashboard Installer"
    echo "================================"
    echo ""
    
    check_helm
    check_kubectl
    echo ""
    
    add_helm_dashboard_repo
    echo ""
    
    update_repos
    echo ""
    
    create_namespace
    echo ""
    
    cleanup_conflicting_resources
    echo ""
    
    install_helm_dashboard
    echo ""
    
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
