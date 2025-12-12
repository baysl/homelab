# ActualBudget

## HTTPS Access

[ActualBudget](https://actualbudget.org/) requires HTTPS access. This is setup using Ingress resource with Tailscale Operator.

HTTPS termination: done by Tailscale Ingress:
- [`ingress.yaml`](ingress.yaml) uses `ingressClassName: tailscale` and `tailscale.com/hostname: "actualbudget"`.
- Service is `ClusterIP`
- Requires Tailscale Operator installed (see [`infra/tailscale-operator/`](../../infra/tailscale-operator/)).
Persistent data: PVC uses `storageClassName: longhorn` (ensure Longhorn exists, see [`infra/longhorn/`](../../infra/longhorn/)).
Readiness: Deployment has an HTTP readinessProbe on `/` (port 5006). If startup is slow, bump `initialDelaySeconds` or `failureThreshold`.

Access (tailnet-only):
```
https://<address-shown-by-ingress>.ts.net
```
