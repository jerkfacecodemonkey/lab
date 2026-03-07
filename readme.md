This project is for my k8s home lab.

Current setup:

Control Plane k3s server: 192.168.1.67
Worker node: 192.168.1.9

## Argo CD Bootstrap

Install Argo CD chart:

```bash
cd charts/argocd
helm dependency update
helm upgrade --install argocd . \
	--namespace argocd \
	--create-namespace
```

## Load Applications Into Argo CD

1. Confirm `repoURL` is set correctly in:

- `argocd/applications/argocd.yaml`
- `argocd/applications/adguard-home.yaml`

2. Apply application manifests:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/applications/argocd.yaml
kubectl apply -f argocd/applications/adguard-home.yaml
```

3. Open the Argo CD UI and verify both apps are listed:

- `argocd`
- `adguard-home`

## Traefik Dashboard

Permanent Traefik dashboard manifests are in:

- `argocd/infra/traefik-dashboard/`

Apply with:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-dashboard/
```

Access:

- `http://traefik.donethanks.com/dashboard/`
- `https://traefik.donethanks.com/dashboard/` (after `donethanks-wildcard-tls` secret is created)

## Traefik Default TLS (Wildcard)

Set a cluster-wide default wildcard cert for `*.donethanks.com`:

- `argocd/infra/traefik-tls-default/tlsstore-default.yaml`

Create/update TLS secret:

```bash
kubectl -n kube-system create secret tls donethanks-wildcard-tls \
	--cert=/path/to/fullchain.pem \
	--key=/path/to/privkey.pem \
	--dry-run=client -o yaml | kubectl apply -f -
```

Apply TLSStore:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-tls-default/
```

## Traefik App TLS Routes

HTTPS routes for Argo CD and AdGuard are in:

- `argocd/infra/traefik-app-routes/`

Apply:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-app-routes/
```

Endpoints:

- `https://argo.donethanks.com`
- `https://adguard.donethanks.com`