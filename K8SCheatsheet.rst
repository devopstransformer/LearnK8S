====================
Kubernetes Cheatsheet
====================

A quick reference guide for common Kubernetes commands and operations.

Cluster Commands
================

Get cluster information:

.. code-block:: bash

    kubectl cluster-info
    kubectl version
    kubectl api-resources

Get cluster nodes:

.. code-block:: bash

    kubectl get nodes
    kubectl get nodes -o wide
    kubectl describe node <node-name>

Context Management
==================

List available contexts:

.. code-block:: bash

    kubectl config get-contexts

Switch context:

.. code-block:: bash

    kubectl config use-context <context-name>

Set default namespace:

.. code-block:: bash

    kubectl config set-context --current --namespace=<namespace>

Pod Commands
============

List pods:

.. code-block:: bash

    kubectl get pods
    kubectl get pods -n <namespace>
    kubectl get pods -o wide
    kubectl get pods --all-namespaces

Create and run pods:

.. code-block:: bash

    # Run a single pod
    kubectl run <pod-name> --image=<image>
    kubectl run nginx --image=nginx

    # Run with multiple options
    kubectl run nginx --image=nginx --port=80 --env="KEY=value"

Get pod details:

.. code-block:: bash

    kubectl describe pod <pod-name>
    kubectl get pod <pod-name> -o yaml
    kubectl get pod <pod-name> -o json

Execute commands in pod:

.. code-block:: bash

    kubectl exec -it <pod-name> -- /bin/bash
    kubectl exec <pod-name> -- <command>

Delete pods:

.. code-block:: bash

    kubectl delete pod <pod-name>
    kubectl delete pod <pod-name> --grace-period=0 --force

Deployment Commands
===================

Create deployment:

.. code-block:: bash

    kubectl create deployment <name> --image=<image>
    kubectl create deployment nginx --image=nginx

Get deployments:

.. code-block:: bash

    kubectl get deployments
    kubectl get deployments -o wide
    kubectl describe deployment <name>

Scale deployment:

.. code-block:: bash

    kubectl scale deployment <name> --replicas=3
    kubectl scale deployment nginx --replicas=5

Update deployment image:

.. code-block:: bash

    kubectl set image deployment/<name> <container>=<new-image>
    kubectl set image deployment/nginx nginx=nginx:1.19

Rollout management:

.. code-block:: bash

    kubectl rollout status deployment/<name>
    kubectl rollout history deployment/<name>
    kubectl rollout undo deployment/<name>
    kubectl rollout undo deployment/<name> --to-revision=2

Delete deployment:

.. code-block:: bash

    kubectl delete deployment <name>

Service Commands
================

Create service:

.. code-block:: bash

    kubectl expose pod <pod-name> --port=80 --target-port=8080
    kubectl expose deployment <deployment-name> --port=80 --type=LoadBalancer

Get services:

.. code-block:: bash

    kubectl get svc
    kubectl get services -o wide
    kubectl describe service <service-name>

Port forwarding:

.. code-block:: bash

    kubectl port-forward svc/<service-name> 8080:80
    kubectl port-forward pod/<pod-name> 8080:80

ConfigMap and Secrets
=====================

Create ConfigMap:

.. code-block:: bash

    kubectl create configmap <name> --from-literal=key=value
    kubectl create configmap <name> --from-file=<file>

Get ConfigMap:

.. code-block:: bash

    kubectl get configmap
    kubectl get configmap <name> -o yaml

Create Secret:

.. code-block:: bash

    kubectl create secret generic <name> --from-literal=username=user --from-literal=password=pass
    kubectl create secret docker-registry <name> --docker-server=<server> --docker-username=<username> --docker-password=<password>

Get Secret:

.. code-block:: bash

    kubectl get secrets
    kubectl get secret <name> -o yaml

Namespace Commands
==================

List namespaces:

.. code-block:: bash

    kubectl get namespaces
    kubectl get ns

Create namespace:

.. code-block:: bash

    kubectl create namespace <namespace-name>

Delete namespace:

.. code-block:: bash

    kubectl delete namespace <namespace-name>

Get resources in namespace:

.. code-block:: bash

    kubectl get pods -n <namespace>
    kubectl get all -n <namespace>

Logs and Debugging
==================

View pod logs:

.. code-block:: bash

    kubectl logs <pod-name>
    kubectl logs <pod-name> -f  # Follow logs
    kubectl logs <pod-name> --previous  # Previous logs

View logs from all containers:

.. code-block:: bash

    kubectl logs <pod-name> --all-containers=true

View events:

.. code-block:: bash

    kubectl get events
    kubectl get events -n <namespace>
    kubectl get events --sort-by='.lastTimestamp'

Debug pod:

.. code-block:: bash

    kubectl describe pod <pod-name>
    kubectl logs <pod-name>
    kubectl exec -it <pod-name> -- /bin/sh

Get pod status:

.. code-block:: bash

    kubectl get pod <pod-name> -o jsonpath='{.status.phase}'

Resource Management
===================

Get resource usage:

.. code-block:: bash

    kubectl top nodes
    kubectl top pods
    kubectl top pods -n <namespace>

Describe resource:

.. code-block:: bash

    kubectl describe <resource-type> <resource-name>
    kubectl describe pod <pod-name>
    kubectl describe deployment <deployment-name>

Get all resources:

.. code-block:: bash

    kubectl get all
    kubectl get all -n <namespace>
    kubectl get all --all-namespaces

Label Management
================

Add label to pod:

.. code-block:: bash

    kubectl label pod <pod-name> <key>=<value>
    kubectl label pod nginx app=web

Get resources by label:

.. code-block:: bash

    kubectl get pods -l <key>=<value>
    kubectl get pods -l app=web

Update label:

.. code-block:: bash

    kubectl label pod <pod-name> <key>=<new-value> --overwrite

Remove label:

.. code-block:: bash

    kubectl label pod <pod-name> <key>-

YAML and Manifest Management
=============================

Apply manifest:

.. code-block:: bash

    kubectl apply -f <file.yaml>
    kubectl apply -f <directory>

Create from manifest:

.. code-block:: bash

    kubectl create -f <file.yaml>

Delete by manifest:

.. code-block:: bash

    kubectl delete -f <file.yaml>

Edit resource:

.. code-block:: bash

    kubectl edit pod <pod-name>
    kubectl edit deployment <deployment-name>

Export resource as YAML:

.. code-block:: bash

    kubectl get pod <pod-name> -o yaml > pod.yaml
    kubectl get deployment <deployment-name> -o yaml > deployment.yaml

Dry run (preview without applying):

.. code-block:: bash

    kubectl apply -f <file.yaml> --dry-run=client
    kubectl create deployment nginx --image=nginx --dry-run=client -o yaml

Useful Aliases
==============

Add to your ~/.bashrc or ~/.zshrc:

.. code-block:: bash

    alias k='kubectl'
    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias kl='kubectl logs'
    alias ke='kubectl exec'
    alias ka='kubectl apply'
    alias kdel='kubectl delete'
    alias kgn='kubectl get nodes'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get svc'
    alias kgd='kubectl get deployments'

Common Patterns
===============

**Restart a pod:**

.. code-block:: bash

    kubectl rollout restart deployment/<deployment-name>

**Get pod IP:**

.. code-block:: bash

    kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'

**Get all resources in a namespace:**

.. code-block:: bash

    kubectl get all -n <namespace>

**Delete all pods in a namespace:**

.. code-block:: bash

    kubectl delete pods --all -n <namespace>

**Watch resource changes:**

.. code-block:: bash

    kubectl get pods -w
    kubectl get pods --watch

**Get shell into pod:**

.. code-block:: bash

    kubectl run -it --rm debug --image=busybox --restart=Never -- sh

**Copy files to/from pod:**

.. code-block:: bash

    kubectl cp <pod-name>:<path> <local-path>
    kubectl cp <local-path> <pod-name>:<path>

**Get resource in JSON format:**

.. code-block:: bash

    kubectl get pod <pod-name> -o json | jq .

Quick Manifest Template
=======================

Pod manifest:

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80

Deployment manifest:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:latest
            ports:
            - containerPort: 80

Service manifest:

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-service
    spec:
      selector:
        app: nginx
      type: LoadBalancer
      ports:
      - protocol: TCP
        port: 80
        targetPort: 80

Troubleshooting Tips
====================

**Pod stuck in pending:**

.. code-block:: bash

    kubectl describe pod <pod-name>
    # Check for resource constraints, image pull errors, etc.

**Pod not starting:**

.. code-block:: bash

    kubectl logs <pod-name>
    kubectl describe pod <pod-name>

**Check node status:**

.. code-block:: bash

    kubectl describe node <node-name>
    kubectl get nodes -o wide

**View resource quotas:**

.. code-block:: bash

    kubectl describe resourcequota -n <namespace>

**Check persistent volumes:**

.. code-block:: bash

    kubectl get pv
    kubectl get pvc
    kubectl describe pvc <pvc-name>

References
==========

- `Kubernetes Official Documentation <https://kubernetes.io/docs/>`_
- `kubectl Cheat Sheet <https://kubernetes.io/docs/reference/kubectl/cheatsheet/>`_
- `API Reference <https://kubernetes.io/docs/reference/generated/kubernetes-api/>`_
