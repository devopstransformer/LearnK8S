=======================
Kind Installation Guide
=======================

This guide will help you get started with `kind <https://kind.sigs.k8s.io/>`_ (Kubernetes in Docker).

Prerequisites
=============

Before installing kind, ensure you have the following installed:

- **Docker**: Version 17.03 or newer
- **Go**: Version 1.16 or newer (optional, only if building from source)

Check your Docker installation:

.. code-block:: bash

    docker --version

Installing Kind
===============

On Linux
--------

Using the official binary:

.. code-block:: bash

    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

Using Homebrew (if available):

.. code-block:: bash

    brew install kind

Verify the installation:

.. code-block:: bash

    kind --version

On macOS
--------

Using Homebrew:

.. code-block:: bash

    brew install kind

Using the official binary:

.. code-block:: bash

    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

Verify the installation:

.. code-block:: bash

    kind --version

On Windows
----------

Using Chocolatey:

.. code-block:: powershell

    choco install kind

Using the official binary:

1. Download the binary from the `kind releases page <https://github.com/kubernetes-sigs/kind/releases>`_
2. Rename the executable to ``kind.exe``
3. Add it to your PATH

Verify the installation:

.. code-block:: powershell

    kind --version

Quick Start
===========

Create your first Kubernetes cluster:

.. code-block:: bash

    kind create cluster

This creates a single-node cluster named ``kind`` by default.

Check cluster status:

.. code-block:: bash

    kind get clusters
    kubectl cluster-info --context kind-kind

Interact with the cluster:

.. code-block:: bash

    kubectl get nodes

Delete the cluster:

.. code-block:: bash

    kind delete cluster

Advanced: Custom Cluster Configuration
=======================================

Create a multi-node cluster with a custom configuration file:

.. code-block:: yaml

    # kind-config.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
    - role: worker
    - role: worker

Create the cluster:

.. code-block:: bash

    kind create cluster --config kind-config.yaml --name my-cluster

Troubleshooting
===============

**Docker daemon not running**

Make sure Docker is running:

.. code-block:: bash

    docker ps

If Docker is not installed, visit `Docker's official website <https://docs.docker.com/get-docker/>`_.

**kubectl not found**

Kind requires ``kubectl`` to interact with the cluster. Install it:

.. code-block:: bash

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

**Port conflicts**

If kind fails to create a cluster due to port conflicts, ensure no services are using the default ports (6443, 10250, etc.) or use a custom configuration.

Additional Resources
====================

- `Kind Official Documentation <https://kind.sigs.k8s.io/>`_
- `Kubernetes Official Site <https://kubernetes.io/>`_
- `kind GitHub Repository <https://github.com/kubernetes-sigs/kind>`_


Create a Cluster
=================

Creating your first cluster, just call the createcluster.sh This will kall kind and creates
a cluster with the name "test-cluster".

.. code-block:: bash

    ./createcluster.sh
This creates a single-node cluster named ``test-cluster`` by default.

Check cluster status:
.. code-block:: bash

    kind get clusters
    kubectl cluster-info --context kind-test-cluster

Interact with the cluster:
.. code-block:: bash

    kubectl get nodes
Delete the cluster:
.. code-block:: bash

    kind delete cluster --name test-cluster
    
