# GitOps Demo Deployment

A GitOps repository that deploys ArgoCD and two demo applications (nginx + httpbin) on a local Kubernetes cluster using the app-of-apps pattern.

## Prerequisites

- A running Kubernetes cluster (kind, k3d, or minikube)
- `kubectl` configured to talk to the cluster

## Repository Authentication

If this is a private repository, ArgoCD needs a credential to pull manifests. Create a GitHub Personal Access Token (PAT):

1. Go to **GitHub > Settings > Developer settings > Personal access tokens > Fine-grained tokens**
2. Click **Generate new token**
3. Set a name and expiration
4. Under **Repository access**, select **Only select repositories** and pick this repo
5. Under **Permissions > Repository permissions**, set **Contents** to **Read-only**
6. Click **Generate token** and copy the value

Then create and apply a credential template that covers all GitHub repos:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: github-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://github.com
  username: <your-github-username>
  password: <your-github-pat>
EOF
```

## Quick Start

```bash
./bootstrap.sh
```

This will:
1. Install ArgoCD into the `argocd` namespace
2. Wait for ArgoCD to become ready
3. Deploy the root app-of-apps, which manages the demo applications

## Accessing ArgoCD

Port-forward the ArgoCD server:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open https://localhost:8080 and log in with:
- **User:** `admin`
- **Password:** retrieve with:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
  ```

## Architecture

```
root-app (app-of-apps)
├── nginx-app  → apps/nginx/   → demo-nginx namespace
└── httpbin-app → apps/httpbin/ → demo-httpbin namespace
```

## Verify

```bash
kubectl get apps -n argocd
kubectl get pods -n demo-nginx
kubectl get pods -n demo-httpbin
```
