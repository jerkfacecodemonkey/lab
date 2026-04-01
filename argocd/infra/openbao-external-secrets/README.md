# OpenBao + External Secrets

This directory contains OpenBao provider resources for External Secrets Operator:

- `SecretStore/openbao` in namespace `openbao`
- `ExternalSecret/openbao-demo` example syncing `secret/lab/demo` from OpenBao KV v2

## One-time secret setup (not committed to Git)

Create/update the token secret used by `SecretStore/openbao`:

```bash
kubectl -n openbao create secret generic openbao-eso-token \
  --from-literal=token='YOUR_OPENBAO_TOKEN' \
  --dry-run=client -o yaml | kubectl apply -f -
```
