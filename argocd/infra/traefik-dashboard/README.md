# Traefik Dashboard Exposure

This directory exposes the built-in Traefik dashboard permanently via an IngressRoute.

## Resources

- `ingressroute-dashboard.yaml` routes `traefik.donethanks.com` to `api@internal`
- `middleware-ipallowlist.yaml` optional IP allowlist middleware (not currently attached)

## Apply

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-dashboard/
```

## Access

- Root URL redirects to dashboard: `https://traefik.donethanks.com/`
- URL: `http://traefik.donethanks.com/dashboard/`
- Direct node IP URL: `http://192.168.1.67/dashboard/`
- HTTPS URL (uses Traefik default TLS cert when configured): `https://traefik.donethanks.com/dashboard/`

If DNS is not set up yet, test locally with:

```bash
curl --resolve traefik.donethanks.com:80:192.168.1.67 \
  http://traefik.donethanks.com/dashboard/
```
