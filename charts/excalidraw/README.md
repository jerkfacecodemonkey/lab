# Excalidraw Helm Chart

This chart deploys Excalidraw for web access in the homelab.

## Install

```bash
cd charts/excalidraw
helm upgrade --install excalidraw . \
  --namespace excalidraw \
  --create-namespace
```

## Access

With the Traefik app routes in this repo, Excalidraw is available at:

- `https://excalidraw.donethanks.com`

## Argo CD

Application manifest:

- `argocd/applications/excalidraw.yaml`
