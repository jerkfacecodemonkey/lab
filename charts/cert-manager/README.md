# cert-manager Helm Chart

This chart installs cert-manager via the official Jetstack chart.

## Install

```bash
cd charts/cert-manager
helm dependency update
helm upgrade --install cert-manager . \
  --namespace cert-manager \
  --create-namespace
```

## Notes for Wildcard Certificates

- Wildcard certs (`*.example.com`) require ACME `dns-01` challenges.
- DNS provider must support automated TXT record updates via API.
