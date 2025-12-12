==========================
Minikube Installation Guide
==========================

This guide will help you get started with `Minikube <https://minikube.sigs.k8s.io/>`_ (Kubernetes locally).

Prerequisites
=============

Before installing Minikube, ensure you have one of the following installed:

- **Docker**: Version 17.03 or newer
- **VirtualBox**: Version 5.2 or newer
- **KVM**: For Linux systems
- **Hyper-V**: For Windows

Additionally:

- **kubectl**: Version 1.16 or newer (recommended)

Check Docker installation:

.. code-block:: bash

    docker --version

Installing Minikube
===================

On Linux
--------

Using the official binary:

.. code-block:: bash

    curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube

Using Homebrew (if available):

.. code-block:: bash

    brew install minikube

Verify the installation:

.. code-block:: bash

    minikube version

On macOS
--------

Using Homebrew:

.. code-block:: bash

    brew install minikube

Using the official binary:

.. code-block:: bash

    curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-darwin-amd64
    sudo install minikube-darwin-amd64 /usr/local/bin/minikube

Verify the installation:

.. code-block:: bash

    minikube version

On Windows
----------

Using Chocolatey:

.. code-block:: powershell

    choco install minikube

Using the official binary:

1. Download from the `Minikube releases page <https://github.com/kubernetes/minikube/releases>`_
2. Add it to your PATH
3. Restart PowerShell

Verify the installation:

.. code-block:: powershell

    minikube version

Quick Start
===========

Start your first Minikube cluster:

.. code-block:: bash

    minikube start --driver=docker

This starts a single-node Kubernetes cluster using Docker as the driver.

Check cluster status:

.. code-block:: bash

    minikube status
    kubectl cluster-info

Interact with the cluster:

.. code-block:: bash

    kubectl get nodes
    kubectl get pods --all-namespaces

Stop the cluster:

.. code-block:: bash

    minikube stop

Delete the cluster:

.. code-block:: bash

    minikube delete

Advanced: Custom Configuration
===============================

Start cluster with specific resources:

.. code-block:: bash

    minikube start --cpus=4 --memory=8192 --driver=docker

List available addons:

.. code-block:: bash

    minikube addons list

Enable an addon (e.g., ingress):

.. code-block:: bash

    minikube addons enable ingress

Access Kubernetes Dashboard:

.. code-block:: bash

    minikube dashboard

Port Forwarding
===============

Forward a port from your local machine to a pod:

.. code-block:: bash

    kubectl port-forward pod/POD_NAME 8080:80

Or to a service:

.. code-block:: bash

    kubectl port-forward svc/SERVICE_NAME 8080:80

Troubleshooting
===============

**Docker driver not found**

.. code-block:: bash

    minikube start --driver=virtualbox

**Cannot connect to Minikube**

.. code-block:: bash

    eval $(minikube docker-env)

**Insufficient resources**

Stop and restart with more resources:

.. code-block:: bash

    minikube stop
    minikube start --cpus=4 --memory=8192

**kubectl not found**

Install kubectl:

.. code-block:: bash

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

Additional Resources
====================

- `Minikube Official Documentation <https://minikube.sigs.k8s.io/>`_
- `Kubernetes Official Site <https://kubernetes.io/>`_
- `Minikube GitHub Repository <https://github.com/kubernetes/minikube>`_
