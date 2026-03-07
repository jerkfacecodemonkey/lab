# Argo CD Helm Chart (Simple)

This chart installs Argo CD via the official upstream chart as a dependency.

## Prerequisites

- Kubernetes cluster
- Helm 3.10+

## Install

```bash
cd charts/argocd
helm dependency update
helm upgrade --install argocd . \
  --namespace argocd \
  --create-namespace
```

## Access UI (default: Caddy + NodePort)

This chart defaults to a fixed NodePort so an external reverse proxy (Caddy) can provide public TLS:

- Argo URL: `https://argo.donethanks.com`
- Service type: `NodePort`
- HTTP NodePort: `30080`

Expected proxy on host `192.168.1.67`:

```caddy
argo.donethanks.com {
  tls /certs/live/donethanks.com/fullchain.pem /certs/live/donethanks.com/privkey.pem
  reverse_proxy 192.168.1.67:30080
}
```

Open: `https://argo.donethanks.com`

## Optional: Ingress instead of NodePort

If you prefer Kubernetes ingress directly (for example with Traefik + cert-manager), run:

```bash
helm upgrade --install argocd . \
  --namespace argocd \
  --create-namespace \
  --set argo-cd.server.ingress.enabled=true \
  --set argo-cd.server.service.type=ClusterIP
```

## Temporary fallback: port-forward

```bash
kubectl -n argocd port-forward svc/argocd-argo-cd-server 8080:80
```

Open: http://localhost:8080

## Get initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 --decode; echo
```

## Customize values

Edit `values.yaml` and run:

```bash
helm upgrade --install argocd . \
  --namespace argocd \
  --create-namespace
```
