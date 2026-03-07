# cert-manager Wildcard TLS Renewal

## Important: Squarespace DNS Limitation

Wildcard renewal with Let's Encrypt requires `dns-01` challenge automation.

Squarespace DNS is not supported by cert-manager's built-in DNS solvers, so cert-manager cannot directly auto-renew `*.donethanks.com` while authoritative DNS stays on Squarespace.

## Your Options

1. Move authoritative DNS for `donethanks.com` to a provider with API support (Cloudflare, Route53, etc.), then use a cert-manager DNS solver.
2. Keep Squarespace authoritative DNS but delegate `_acme-challenge.donethanks.com` to a DNS provider that cert-manager can update via API.

## Resources in this folder

- `certificate-wildcard-donethanks.yaml`
  - Uses `ClusterIssuer` `letsencrypt-wildcard`
  - Writes renewed cert to existing secret `kube-system/donethanks-wildcard-tls`
- `clusterissuer-cloudflare-example.yaml`
  - Example issuer for Cloudflare (edit before use)

## Apply order (after cert-manager is installed)

```bash
# 1) create your real ClusterIssuer (provider-specific)
kubectl apply -f argocd/infra/cert-manager/clusterissuer-cloudflare-example.yaml

# 2) create Certificate that keeps donethanks-wildcard-tls renewed
kubectl apply -f argocd/infra/cert-manager/certificate-wildcard-donethanks.yaml
```
