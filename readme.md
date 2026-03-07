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
- `argocd/applications/cert-manager.yaml`
- `argocd/applications/cert-manager-infra.yaml`
- `argocd/applications/traefik-dashboard.yaml`
- `argocd/applications/traefik-app-routes.yaml`
- `argocd/applications/traefik-tls-default.yaml`

2. Apply application manifests:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/applications/argocd.yaml
kubectl apply -f argocd/applications/adguard-home.yaml
kubectl apply -f argocd/applications/cert-manager.yaml
kubectl apply -f argocd/applications/cert-manager-infra.yaml
kubectl apply -f argocd/applications/traefik-dashboard.yaml
kubectl apply -f argocd/applications/traefik-app-routes.yaml
kubectl apply -f argocd/applications/traefik-tls-default.yaml
```

3. Open the Argo CD UI and verify apps are listed:

- `argocd`
- `adguard-home`
- `cert-manager`
- `cert-manager-infra`
- `traefik-dashboard`
- `traefik-app-routes`
- `traefik-tls-default`

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

## cert-manager Wildcard Renewal

Wildcard renewal resources are in:

- `argocd/infra/cert-manager/`

Detailed runbook:

- `argocd/infra/cert-manager/README.md`

Create/update Cloudflare token secret used by cert-manager:

```bash
kubectl -n cert-manager create secret generic cloudflare-api-token \
	--from-literal=api-token='YOUR_CLOUDFLARE_API_TOKEN' \
	--dry-run=client -o yaml | kubectl apply -f -
```

Quick verification:

```bash
kubectl get clusterissuer letsencrypt-wildcard
kubectl -n kube-system get certificate donethanks-wildcard
kubectl -n kube-system get secret donethanks-wildcard-tls
```

Cloudflare TXT note:

- Cloudflare may display a warning that TXT content should be quoted. This is expected for ACME DNS-01 records and does not break validation.
- Do not create or edit `_acme-challenge` TXT records manually; cert-manager creates and removes them automatically during issuance/renewal.
- If you previously added manual `_acme-challenge` TXT records, remove them in Cloudflare so only cert-manager-managed challenge records are used.

Wildcard DNS-01 automation requires an API-capable DNS provider.
If your DNS provider does not support cert-manager solvers directly, delegate `_acme-challenge.donethanks.com` to a supported DNS zone/provider.
