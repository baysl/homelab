# ActualBudget

This directory contains the Kubernetes manifests for deploying [ActualBudget](https://actualbudget.org/) to the homelab cluster using GitOps with FluxCD.

## Overview

ActualBudget is a local-first personal finance tool. This deployment includes:

- **Namespace**: `actualbudget` - Isolated namespace for the application
- **Deployment**: Runs the ActualBudget server (actualbudget/actual-server:25.12.0)
- **PersistentVolumeClaim**: 1Gi storage backed by Longhorn for persistent data
- **Service**: LoadBalancer service with Tailscale annotations exposing port 5006

## Access

Once deployed, ActualBudget will be accessible via Tailscale at:

```
https://actualbudget.<your-tailnet>.ts.net
```

The Tailscale operator will automatically create a LoadBalancer service with the hostname `actualbudget` in your Tailscale network with HTTPS enabled.

## Configuration

### Storage

The deployment uses Longhorn as the storage class for persistent data. The PVC requests 1Gi of storage, which can be adjusted in `deployment.yaml` if needed.

### Resources

Default resource limits:
- Memory: 512Mi limit, 128Mi request
- CPU: 500m limit, 100m request

Adjust these in `deployment.yaml` based on your usage patterns.

### Image

The deployment uses `actualbudget/actual-server:25.12.0`. To update to a newer version:

1. Check available versions at https://hub.docker.com/r/actualbudget/actual-server/tags
2. Update the image tag in `deployment.yaml`
3. Commit and push the change - FluxCD will automatically deploy the new version

### Tailscale Exposure

The Service uses Tailscale annotations to expose ActualBudget securely:
- `tailscale.com/expose: "true"` - Enables Tailscale exposure
- `tailscale.com/hostname: "actualbudget"` - Sets the hostname in your Tailnet

The service type is set to `LoadBalancer`, which allows the Tailscale operator to provision the external access.

## Deployment

This application is automatically deployed via FluxCD when changes are pushed to the repository. FluxCD will:

1. Monitor this directory for changes
2. Apply the manifests to the cluster
3. Reconcile any drift from the desired state

To manually verify the deployment status:

```bash
kubectl get all -n actualbudget
kubectl get svc -n actualbudget
```

## Troubleshooting

Check pod status:
```bash
kubectl get pods -n actualbudget
kubectl logs -n actualbudget -l app=actualbudget
```

Check Service and Tailscale status:
```bash
kubectl describe svc actualbudget -n actualbudget
kubectl logs -n tailscale -l app=tailscale-operator
```

Check PVC status:
```bash
kubectl get pvc -n actualbudget
```
