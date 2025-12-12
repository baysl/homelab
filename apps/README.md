# Apps

Kubernetes application manifests managed by Flux. Each subfolder is a self-contained Kustomize package for one app (namespace, deployment, service, ingress, storage as needed).

## How it’s applied
- Cluster kustomization: `clusters/homelab/apps-kustomization.yaml` points to this `apps/` folder.
- Flux reconciles changes automatically after commits to the repo.
