================================
Kubernetes Dashboard with Helm
================================

This guide covers installing and using the Kubernetes Dashboard via Helm.

What is Kubernetes Dashboard?
=============================

Kubernetes Dashboard is a web-based Kubernetes user interface that allows you to:

- **View cluster resources** - Nodes, pods, deployments, services, etc.
- **Manage applications** - Deploy, update, and delete applications
- **Monitor resources** - CPU and memory usage
- **View logs** - Check pod and container logs
- **Execute commands** - Run commands in containers
- **Manage namespaces** - Switch between different namespaces

Installation
============

The installation is a three-step process:

**Step 1: Install Helm**

.. code-block:: bash

    ./1_install.sh

This installs Helm with all required dependencies on Linux/Debian systems.

**Step 2: Add Dashboard Repository**

.. code-block:: bash

    ./2_adddashboardrepo.sh

This adds the official Kubernetes Dashboard Helm repository.

**Step 3: Install the Dashboard**

.. code-block:: bash

    ./3_installdashboard.sh

This installs the dashboard in the `kubernetes-dashboard` namespace.

Accessing the Dashboard
=======================

After installation, the dashboard will be available as a LoadBalancer service.

Get the external IP:

.. code-block:: bash

    kubectl get svc -n kubernetes-dashboard

If no external IP is available (e.g., on local clusters), use port forwarding:

.. code-block:: bash

    kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 &

Then access: `https://localhost:8443`

Authentication
===============

The dashboard requires authentication. You can get the bearer token using:

.. code-block:: bash

    kubectl -n kubernetes-dashboard create token kubernetes-dashboard

Copy the token and paste it into the dashboard login page.

Manual Token Retrieval
----------------------

For older Kubernetes versions:

.. code-block:: bash

    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret -o name | grep kubernetes-dashboard)

Look for the `token:` field in the output.

Dashboard Features
==================

**Workloads**

- View and manage Pods
- View and manage Deployments
- View and manage ReplicaSets
- View and manage StatefulSets
- View and manage DaemonSets
- View and manage Jobs
- View and manage CronJobs

**Discovery and Load Balancing**

- View Services
- View Ingresses

**Config and Storage**

- View ConfigMaps
- View Secrets
- View PersistentVolumes
- View PersistentVolumeClaims
- View StorageClasses

**Cluster**

- View Nodes
- View Namespaces
- View Events
- View Cluster Roles
- View Cluster Role Bindings

**Monitoring**

- View CPU and memory usage
- View pod resource metrics
- View node resource metrics

Common Tasks
============

**Creating a Deployment**

1. Navigate to "Workloads" → "Deployments"
2. Click "+ CREATE"
3. Choose "Create from text input"
4. Paste your deployment YAML
5. Click "UPLOAD"

**Viewing Pod Logs**

1. Navigate to "Workloads" → "Pods"
2. Click on a pod
3. Click the "Logs" tab

**Scaling a Deployment**

1. Navigate to "Workloads" → "Deployments"
2. Click on a deployment
3. Click the scale button (up/down arrows)
4. Enter the new replica count

**Executing Commands in a Pod**

1. Navigate to "Workloads" → "Pods"
2. Click on a pod
3. Click the "Exec" tab
4. Enter your command
5. Click "Execute"

Helm Commands for Dashboard
============================

List dashboard releases:

.. code-block:: bash

    helm list -n kubernetes-dashboard

Get dashboard status:

.. code-block:: bash

    helm status kubernetes-dashboard -n kubernetes-dashboard

View dashboard values:

.. code-block:: bash

    helm get values kubernetes-dashboard -n kubernetes-dashboard

Upgrade dashboard:

.. code-block:: bash

    helm upgrade kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
      -n kubernetes-dashboard

Uninstall dashboard:

.. code-block:: bash

    helm uninstall kubernetes-dashboard -n kubernetes-dashboard

kubectl Commands for Dashboard
===============================

Get dashboard service:

.. code-block:: bash

    kubectl get svc -n kubernetes-dashboard

Get dashboard pods:

.. code-block:: bash

    kubectl get pods -n kubernetes-dashboard

View dashboard logs:

.. code-block:: bash

    kubectl logs -n kubernetes-dashboard -l app.kubernetes.io/name=kubernetes-dashboard

Describe dashboard service:

.. code-block:: bash

    kubectl describe svc kubernetes-dashboard -n kubernetes-dashboard

Port forward to dashboard:

.. code-block:: bash

    kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443

Create token for dashboard:

.. code-block:: bash

    kubectl -n kubernetes-dashboard create token kubernetes-dashboard

Troubleshooting
===============

**Cannot access dashboard**

Check if the service is running:

.. code-block:: bash

    kubectl get svc -n kubernetes-dashboard
    kubectl get pods -n kubernetes-dashboard

**Pod not starting**

Check logs:

.. code-block:: bash

    kubectl logs -n kubernetes-dashboard -l app.kubernetes.io/name=kubernetes-dashboard

**Authentication fails**

Generate a new token:

.. code-block:: bash

    kubectl -n kubernetes-dashboard create token kubernetes-dashboard

**RBAC permission issues**

Create a service account with admin privileges:

.. code-block:: bash

    kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
    kubectl create clusterrolebinding dashboard-admin \
      --clusterrole=cluster-admin \
      --serviceaccount=kubernetes-dashboard:dashboard-admin

Get the token:

.. code-block:: bash

    kubectl -n kubernetes-dashboard create token dashboard-admin

Security Best Practices
=======================

**1. Use RBAC**

Create a dedicated service account with limited permissions instead of using admin token.

**2. Network Policies**

Restrict access to the dashboard using Kubernetes NetworkPolicies:

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: dashboard-access
      namespace: kubernetes-dashboard
    spec:
      podSelector:
        matchLabels:
          app.kubernetes.io/name: kubernetes-dashboard
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: default

**3. Use HTTPS**

Always access the dashboard over HTTPS (default port 443).

**4. Limit Token Lifetime**

Create tokens with limited lifetime:

.. code-block:: bash

    kubectl -n kubernetes-dashboard create token kubernetes-dashboard --duration=1h

**5. Rotate Credentials**

Regularly rotate service account tokens and credentials.

Resources
=========

- `Kubernetes Dashboard GitHub <https://github.com/kubernetes/dashboard>`_
- `Kubernetes Dashboard Documentation <https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>`_
- `Helm Kubernetes Dashboard Chart <https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm/kubernetes-dashboard>`_
