# 🏡 Homelab

Welcome to my personal homelab, fully managed via GitOps.
This repository contains the complete configuration of my multi-node K3s cluster, maintained using FluxCD.

I'm constantly learning and improving this setup.

---

## 🧱 Stack Overview

- **Kubernetes**: [K3s](https://k3s.io) (multi-node setup)
- **GitOps**: [FluxCD](https://fluxcd.io)
- **CNI**: [Flannel](https://github.com/flannel-io/flannel)
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
## 📁 Repo Structure

```bash
clusters/
  homelab/
    apps/                  # Workloads: komga, actualBudget, etc.
    flux-system/           # Flux bootstrap manifests
    networking/            # Ingress setup (nginx)
    storage/               # Longhorn
````