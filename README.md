# 🏡 Homelab

Welcome to my personal homelab, fully managed via GitOps.
This repository contains the complete configuration of my multi-node K3s cluster, maintained using FluxCD.

I'm constantly learning and improving this setup.

---

## 🧱 Stack Overview

- **Kubernetes**: [K3s](https://k3s.io) (multi-node setup)
- **GitOps**: [FluxCD](https://fluxcd.io)
- **CNI**: Flannel
- **Ingress Controller**: [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/)
- **Storage**: [Longhorn](https://longhorn.io) (with replication and snapshots)
- **DNS**: Static entries in `/etc/hosts` (for now)
- **Remote access**: [Tailscale](https://tailscale.com)

---

## 📦 Deployed Applications

| Application     | Domain            | Notes                                 |
|-----------------|-------------------|---------------------------------------|
| Komga           | `komga.lab`       | Comic server, persistent with Longhorn volumes |
| Longhorn UI     | `longhorn.lab`    | Storage dashboard                     |
| Actual Budget   | `actual.lab`      | Self-hosted budgeting tool *(WIP)*    |
| Prometheus      | `prom.lab`        | Metrics and cluster monitoring *(planned)* |
| Grafana         | `grafana.lab`     | Dashboards *(planned)*                |


---
## 🚀 How It Works

1. Cluster bootstrapped manually with `k3s`
2. FluxCD manages HelmReleases and Kustomizations
3. Each application lives in `clusters/homelab/apps/<app-name>`
4. Ingress routing is done via `nginx` with per-app Ingress definitions
5. PVCs are backed by Longhorn with default 3x replication
6. Secrets are encrypted, but I don't use an external Vault

---
## 📁 Repo Structure

```bash
clusters/
  homelab/
    apps/                  # Workloads: komga, actual, etc.
    networking/            # Ingress setup (nginx, cert-manager)
    storage/               # Longhorn
    flux-system/           # Flux bootstrap manifests
````
