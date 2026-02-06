#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing ArgoCD via Kustomize..."
kubectl apply -k "$SCRIPT_DIR/argocd" --server-side --force-conflicts

echo "==> Waiting for ArgoCD server to be ready..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo "==> Applying root app-of-apps..."
kubectl apply -f "$SCRIPT_DIR/apps/root-app.yaml"

echo ""
echo "=== ArgoCD is ready ==="
echo ""
echo "Admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo ""
echo ""
echo "Port-forward the ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open https://localhost:8080 (user: admin)"
