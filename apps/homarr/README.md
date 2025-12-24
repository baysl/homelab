# Homarr

Dashboard application for managing homelab services. This implementation is based on the [Helm installation guide from Homarr](https://homarr.dev/docs/getting-started/installation/helm).

## Deployment notes

### Port configuration:
Homarr runs on port 3000 by default, not 7575 like the Helm chart expects. We override `containerPorts`, service ports, and health probes to use 3000. Setting the `PORT` env var causes binding issues, so don't use it.

### Tailscale ingress
The device shows as "homarr-homarr-ingress" in Tailscale's admin console (generated from the Helm release). The device name can be shortened in Tailscale admin.

### Storage
Uses a 1Gi Longhorn PVC mounted at `/appdata` for SQLite database persistence.

### Database encryption
Requires the `db-encryption` secret (managed in [`secrets/homarr-db-encryption.yaml`](https://github.com/baysl/homelab/blob/main/secrets/homarr-db-encryption.yaml)) with a random key generated via `openssl rand -hex 32`.
