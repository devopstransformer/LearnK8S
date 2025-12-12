#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="kubernetes-dashboard"

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

# Check kubectl is installed
check_kubectl() {
    print_info "Checking kubectl installation..."
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed."
    fi
    print_success "kubectl is installed"
}

# Install Kubernetes Dashboard
install_dashboard() {
    print_info "Installing Kubernetes Dashboard..."
    
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
    
    print_success "Kubernetes Dashboard installed"
}

# Wait for deployment
wait_for_deployment() {
    print_info "Waiting for dashboard to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/kubernetes-dashboard -n "$NAMESPACE"
    print_success "Dashboard is ready"
}

# Create admin user
create_admin_user() {
    print_info "Creating admin service account..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: $NAMESPACE
EOF
    
    print_success "Admin user created"
}

# Generate token
generate_token() {
    print_header "Generating access token..."
    echo ""
    
    TOKEN=$(kubectl -n "$NAMESPACE" create token admin-user)
    
    echo "=========================================="
    echo "ACCESS TOKEN:"
    echo "=========================================="
    echo "$TOKEN"
    echo "=========================================="
    echo ""
    print_info "Copy this token - you'll need it to login"
}

# Show access info
show_access_info() {
    echo ""
    print_header "Access Information:"
    echo ""
    echo "1. Start kubectl proxy:"
    echo "   kubectl proxy"
    echo ""
    echo "2. Access dashboard at:"
    echo "   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
    echo ""
    echo "3. Login with the token shown above"
    echo ""
    print_header "Alternative: Port Forward (Recommended)"
    echo ""
    echo "1. Start port forwarding:"
    echo "   kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443"
    echo ""
    echo "2. Access dashboard at:"
    echo "   https://localhost:8443"
    echo ""
    echo "3. Login with the token"
    echo ""
}

# Show status
show_status() {
    echo ""
    print_header "Dashboard Status:"
    kubectl get all -n "$NAMESPACE"
}

# Main
main() {
    echo "================================"
    print_header "Kubernetes Dashboard Installer"
    echo "================================"
    echo ""
    
    check_kubectl
    echo ""
    
    install_dashboard
    echo ""
    
    wait_for_deployment
    echo ""
    
    create_admin_user
    echo ""
    
    generate_token
    
    show_status
    
    show_access_info
    
    echo ""
    print_success "Kubernetes Dashboard installation complete!"
}

main "$@"
