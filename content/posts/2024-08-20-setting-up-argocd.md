---
categories:
  - kubernetes
comments: false
description: ArgoCD
headline: What is ArgoCD and how to get started
image:
  feature: kubernetes.png
mathjax: null
modified: 2024-08-20
tags:
  - kubernetes
title: ArgoCD getting started guide
url: /2024/08/20/argocd/
---

## what is it? 

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It allows you to manage the state of your applications using Git as the source of truth. This means that any changes made to your application configuration in Git are automatically applied to your Kubernetes cluster by ArgoCD.

### Key Features of ArgoCD:
- **Declarative GitOps**: Define the desired state of your applications in Git, and ArgoCD ensures that your Kubernetes cluster matches this state.
- **Automatic Synchronization**: Automatically sync your applications with their defined state in Git.
- **Multi-Cluster Support**: Manage applications across multiple Kubernetes clusters from a single ArgoCD instance.
- **Self-Healing**: Automatically detects and reverts changes made to your applications that do not match the Git state.
- **Customizable Rollbacks**: Easily roll back to a previous application version in case of issues.

## Why Use ArgoCD?

### 1. **Simplified Continuous Deployment**
ArgoCD integrates seamlessly with Kubernetes, simplifying the continuous deployment process. By using Git as the single source of truth, you can manage and deploy your applications more consistently and predictably.

### 2. **Enhanced Security**
ArgoCD operates within your Kubernetes cluster, leveraging RBAC policies and Kubernetes-native security mechanisms. This ensures that your deployment processes are secure and adhere to best practices.

### 3. **Visibility and Control**
ArgoCD provides a web UI and CLI that give you clear visibility into the state of your applications. You can monitor application health, view logs, and manually sync or roll back applications directly from the UI.

### 4. **GitOps Best Practices**
By following a GitOps approach with ArgoCD, you enforce a declarative model where all changes are made via pull requests. This improves collaboration, auditing, and the overall reliability of your deployment processes.

## Setting Up ArgoCD

Let's dive into the steps to set up ArgoCD on a Kubernetes cluster.

### Prerequisites
- A running Kubernetes cluster (v1.16 or later).
- `kubectl` CLI installed and configured to interact with your cluster.
- Admin access to the Kubernetes cluster.

### Step 1: Install ArgoCD

1. **Create the ArgoCD namespace**:

    {{< highlight bash >}}
    kubectl create namespace argocd
    {{< / highlight >}}

2. **Install ArgoCD in your Kubernetes cluster**:

    {{< highlight bash >}}
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    {{< / highlight >}}

3. **Verify the installation**:

    {{< highlight bash >}}
    kubectl get pods -n argocd
    {{< / highlight >}}

    Ensure that all pods are running and healthy.

### Step 2: Access the ArgoCD Web UI

1. **Port-forward the ArgoCD server**:

    {{< highlight bash >}}
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    {{< / highlight >}}

2. **Login to the ArgoCD UI**:

    Open your browser and go to `https://localhost:8080`. The default username is `admin`. To get the initial password, run:

    {{< highlight bash >}}
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    {{< / highlight >}}

    Use this password to log in.

### Step 3: Connect ArgoCD to Your Git Repository

1. **Add a Git repository** in the ArgoCD UI:
   - Navigate to the "Repositories" section.
   - Click "Connect Repo".
   - Enter the repository URL and credentials.

2. **Create an application**:
   - Go to the "Applications" section and click "New Application".
   - Fill out the necessary details, including the repository, path, and cluster information.

3. **Sync your application**:
   - Once the application is created, ArgoCD will automatically sync it. You can also manually trigger a sync from the UI.

## Conclusion

ArgoCD is a powerful tool that simplifies the continuous deployment of Kubernetes applications using a GitOps approach. By setting up ArgoCD, you gain enhanced control, visibility, and security over your deployment processes. With this guide, you're well on your way to leveraging ArgoCD to streamline your workflows and achieve more reliable deployments.

Happy deploying!