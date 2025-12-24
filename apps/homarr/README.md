# Homarr

Dashboard application for managing homelab services. This implementation is based on the [Helm installation guide from Homarr](https://homarr.dev/docs/getting-started/installation/helm).

## Deployment notes

**Port configuration:**
Homarr runs on port 3000 by default, not 7575 like the Helm chart expects. We override `containerPorts`, service ports, and health probes to use 3000. Setting the `PORT` env var causes binding issues, so don't use it.

**Tailscale ingress:**
The ingress needs `hosts: [paths: [...]]` without a host field. The hostname comes from the `tailscale.com/hostname` annotation only.

The device shows as "homarr-homarr-ingress" in Tailscale's admin console (generated from the Helm release), but it's accessible via **http://homarr** thanks to MagicDNS. You can rename the device in Tailscale admin if needed.

**Storage:**
Uses a 1Gi Longhorn PVC mounted at `/appdata` for SQLite database persistence.

**Database encryption:**
Requires the `db-encryption` secret (managed in `secrets/homarr-db-encryption.yaml`) with a random key generated via `openssl rand -hex 32`.
