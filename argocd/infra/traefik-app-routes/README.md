# Traefik App Routes (TLS)

This directory configures HTTPS routes for:

- `argo.donethanks.com` -> `argocd/argocd-server`
- `adguard.donethanks.com` -> `adguard-home/adguard-home`
- `excalidraw.donethanks.com` -> `excalidraw/excalidraw`
- `keycloak.donethanks.com` -> `keycloak/keycloak-service`

Both routes use:

- `websecure` + `tls: {}` so Traefik uses the default wildcard cert from `TLSStore/default`
- `web` entrypoint redirect to HTTPS

## Apply

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-app-routes/
```
