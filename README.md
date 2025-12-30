# Homelab

This is my personal Kubernetes homelab using FluxCD and k3s.

This is a work in progress, and I will be updating it regularly as I make changes to my setup.

## Overview

This repository contains the complete declarative configuration for my homelab infrastructure. Everything is managed as code and automatically reconciled to the cluster via FluxCD.

**Stack:**
- **Kubernetes**: [k3s](https://k3s.io) multi-node cluster
- **GitOps**: [FluxCD](https://fluxcd.io) + [Kustomize](https://kustomize.io)
- **Storage**: [Longhorn](https://longhorn.io) distributed block storage
- **Networking**: [Tailscale Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- **Monitoring / Alerting**: [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (Prometheus + Grafana + Alertmanager)
- **Secrets**: [SOPS](https://getsops.io) + [age](https://age-encryption.org) encryption
- **Tooling**: pre-commit hooks + [gitleaks](https://github.com/gitleaks/gitleaks) for secret scanning

## Repository Structure
```
├── apps/                           # Application deployments
│   ├── actualbudget/               # Budget management app
│   └── homarr/                     # Homelab dashboard
├── clusters/homelab/               # Flux configuration & kustomizations
├── infra/                          # Infrastructure components
│   ├── longhorn/                   # Distributed storage
│   ├── prometheus-operator/        # Monitoring stack
│   └── tailscale-operator/         # Secure networking
└── secrets/                        # SOPS-encrypted secrets
```

## Hardware
This is a multi-node cluster, running on mini PCs:
- `control-plane`: HP EliteDesk G4 i7-8700, 16 GB RAM, 256 GB SSD
- `worker-1` to `worker-3`: HP EliteDesk G3 i5-6500T, 8 GB RAM, 256 GB SSD

## Documentation

- [Secrets README](secrets/README.md) - Secret management with SOPS
- [Testing branches](clusters/homelab/README.md) - How to test feature branches
- [Apps README](apps/README.md) - Application deployment guide
- [Infra README](infra/README.md) - Infrastructure components
