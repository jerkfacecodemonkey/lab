# External Secrets Helm Chart

This chart installs External Secrets Operator via the official chart.

## Install

```bash
cd charts/external-secrets
helm dependency update
helm upgrade --install external-secrets . \
  --namespace external-secrets \
  --create-namespace
```
