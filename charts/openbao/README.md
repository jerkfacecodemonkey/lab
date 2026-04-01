# OpenBao Helm Chart

This chart installs OpenBao via the official OpenBao chart.

## Install

```bash
cd charts/openbao
helm dependency update
helm upgrade --install openbao . \
  --namespace openbao \
  --create-namespace
```

## Notes

- This wrapper defaults to standalone server mode with persistent storage.
- Agent injector and CSI provider are disabled by default for a lean lab install.
