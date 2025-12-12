============================
Helm Dashboard Installation
============================

This guide covers installing and using the Helm Dashboard by Komodor.

What is Helm Dashboard?
=======================

Helm Dashboard is a graphical user interface for Helm that provides:

- **Visual Helm Release Management** - View, create, update, and delete Helm releases
- **Intuitive Interface** - Easy-to-use dashboard for managing Helm charts
- **Real-time Monitoring** - Monitor application status and health
- **Log Viewing** - Access pod logs directly from the UI
- **Chart Management** - Browse and search available Helm charts
- **Write Actions** - Create, update, and delete applications
- **Cluster Awareness** - Runs inside your Kubernetes cluster

Key Features
============

**Release Management**

- View all Helm releases across namespaces
- See release details and version history
- Perform rollbacks from the UI
- Monitor release status in real-time

**Application Management**

- Deploy new applications from Helm charts
- Update existing applications
- Scale applications up and down
- View application logs and events

**Chart Management**

- Browse available Helm charts
- Search for specific charts
- View chart details and README
- Install charts with custom values

**Monitoring**

- View pod status and metrics
- Monitor resource usage
- Check application health
- View events and logs

Installation
============

The Helm Dashboard installation is a two-step process:

**Step 1: Install Helm**

.. code-block:: bash

    ./1_install.sh

This installs Helm with all required dependencies.

**Step 2: Install Helm Dashboard**

.. code-block:: bash

    ./2_install_helmdashboard.sh

This installs the Helm Dashboard in the `helm-dashboard` namespace.

Manual Installation
===================

If you prefer to install manually:

.. code-block:: bash

    # Add Komodor repository
    helm repo add komodorio https://helm-charts.komodor.io
    helm repo update

    # Install Helm Dashboard
    helm upgrade --install helm-dashboard komodorio/helm-dashboard \
      --set service.type=LoadBalancer \
      --set service.port=8080 \
      --set dashboard.allowWriteActions=true

Accessing the Dashboard
=======================

The Helm Dashboard will be available as a LoadBalancer service.

Get the external IP:

.. code-block:: bash

    kubectl get svc -n helm-dashboard

Access the dashboard at: `http://<EXTERNAL-IP>:8080`

Port Forwarding
---------------

If no external IP is available (local clusters), use port forwarding:

.. code-block:: bash

    kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080

Then access: `http://localhost:8080`

Common Tasks
============

**Viewing Helm Releases**

1. Open the Helm Dashboard
2. Click on "Releases" in the sidebar
3. See all Helm releases across all namespaces
4. Click on a release to view details

**Installing a Chart**

1. Click on "Charts" in the sidebar
2. Browse available charts or search
3. Click on a chart to view details
4. Click "Install" to deploy the chart
5. Configure values as needed
6. Click "Install" to deploy

**Viewing Release Details**

1. Go to "Releases"
2. Click on a release name
3. View release information including:
   - Current version
   - Deployed pods
   - Services
   - ConfigMaps
   - Secrets

**Scaling an Application**

1. Go to "Releases"
2. Click on a release
3. Find the deployment
4. Click the scale button
5. Adjust replica count
6. Confirm changes

**Viewing Logs**

1. Go to "Releases"
2. Click on a release
3. View pods section
4. Click on a pod
5. Select "Logs" tab
6. View application logs

Configuration
==============

Default Configuration
---------------------

The script installs Helm Dashboard with these defaults:

.. code-block:: yaml

    service:
      type: LoadBalancer
      port: 8080
    
    dashboard:
      allowWriteActions: true
    
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 1
        memory: 1Gi

Custom Configuration
--------------------

Install with custom values:

.. code-block:: bash

    helm upgrade --install helm-dashboard komodorio/helm-dashboard \
      -n helm-dashboard \
      --set service.type=ClusterIP \
      --set dashboard.allowWriteActions=false \
      --set resources.limits.memory=2Gi

Helm Commands
=============

List dashboard releases:

.. code-block:: bash

    helm list -n helm-dashboard

Get dashboard status:

.. code-block:: bash

    helm status helm-dashboard -n helm-dashboard

View dashboard values:

.. code-block:: bash

    helm get values helm-dashboard -n helm-dashboard

Upgrade dashboard:

.. code-block:: bash

    helm upgrade helm-dashboard komodorio/helm-dashboard \
      -n helm-dashboard

Uninstall dashboard:

.. code-block:: bash

    helm uninstall helm-dashboard -n helm-dashboard

kubectl Commands
=================

Get dashboard service:

.. code-block:: bash

    kubectl get svc -n helm-dashboard

Get dashboard pods:

.. code-block:: bash

    kubectl get pods -n helm-dashboard

View dashboard logs:

.. code-block:: bash

    kubectl logs -n helm-dashboard -l app.kubernetes.io/name=helm-dashboard -f

Describe dashboard service:

.. code-block:: bash

    kubectl describe svc helm-dashboard -n helm-dashboard

Port forward to dashboard:

.. code-block:: bash

    kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080

Troubleshooting
===============

**Cannot access dashboard**

Check if the service is running:

.. code-block:: bash

    kubectl get svc -n helm-dashboard
    kubectl get pods -n helm-dashboard

**Pod not starting**

Check logs:

.. code-block:: bash

    kubectl logs -n helm-dashboard -l app.kubernetes.io/name=helm-dashboard

Check pod events:

.. code-block:: bash

    kubectl describe pod -n helm-dashboard -l app.kubernetes.io/name=helm-dashboard

**LoadBalancer pending**

For local clusters (kind, Minikube), the LoadBalancer may stay in pending state. Use port forwarding instead:

.. code-block:: bash

    kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080

**Dashboard not responding**

Check resource usage:

.. code-block:: bash

    kubectl top pod -n helm-dashboard

Restart the dashboard:

.. code-block:: bash

    kubectl rollout restart deployment/helm-dashboard -n helm-dashboard

Comparing Dashboards
====================

+---------------------------+------------------+------------------+
| Feature                   | Kubernetes Dash. | Helm Dashboard   |
+===========================+==================+==================+
| Helm Release Management   | No               | Yes              |
+---------------------------+------------------+------------------+
| Helm Chart Installation   | No               | Yes              |
+---------------------------+------------------+------------------+
| Write Actions             | Limited          | Yes (optional)   |
+---------------------------+------------------+------------------+
| Kubernetes Resource View  | Yes              | Yes              |
+---------------------------+------------------+------------------+
| Log Viewing               | Yes              | Yes              |
+---------------------------+------------------+------------------+
| Pod Exec                  | Yes              | Limited          |
+---------------------------+------------------+------------------+
| User Authentication       | No (external)    | No (external)    |
+---------------------------+------------------+------------------+

Security Considerations
=======================

**1. Write Actions**

By default, write actions are enabled. Disable them in production:

.. code-block:: bash

    helm upgrade helm-dashboard komodorio/helm-dashboard \
      -n helm-dashboard \
      --set dashboard.allowWriteActions=false

**2. Network Policies**

Restrict access using NetworkPolicies:

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: helm-dashboard-access
      namespace: helm-dashboard
    spec:
      podSelector:
        matchLabels:
          app.kubernetes.io/name: helm-dashboard
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: default
        ports:
        - protocol: TCP
          port: 8080

**3. RBAC**

Limit dashboard service account permissions using RBAC (configured by default).

**4. Authentication Proxy**

Add authentication in front using oauth2-proxy:

.. code-block:: bash

    helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
    helm install oauth2-proxy oauth2-proxy/oauth2-proxy \
      -n helm-dashboard \
      --set config.clientID=<CLIENT_ID> \
      --set config.clientSecret=<CLIENT_SECRET>

Resources
=========

- `Helm Dashboard GitHub <https://github.com/komodorio/helm-dashboard>`_
- `Helm Dashboard on Artifact Hub <https://artifacthub.io/packages/helm/komodor/helm-dashboard>`_
- `Komodor Documentation <https://docs.komodor.com/>`_
- `Helm Official Documentation <https://helm.sh/docs/>`_
