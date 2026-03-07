# Traefik Default TLS Certificate

This sets a cluster-wide default TLS certificate for Traefik.

## Goal

Serve your wildcard certificate for `*.donethanks.com` by default.

## 1) Create TLS Secret

Create/update the secret Traefik will use:

```bash
kubectl -n kube-system create secret tls donethanks-wildcard-tls \
  --cert=/path/to/fullchain.pem \
  --key=/path/to/privkey.pem \
  --dry-run=client -o yaml | kubectl apply -f -
```

Typical Let's Encrypt paths are often similar to:

- `/etc/letsencrypt/live/donethanks.com/fullchain.pem`
- `/etc/letsencrypt/live/donethanks.com/privkey.pem`

## 2) Apply TLSStore

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/infra/traefik-tls-default/
```

## 3) Use TLS on Routes

For `IngressRoute`, set `entryPoints: [websecure]` and include `tls: {}`.

Traefik will use the default certificate from `TLSStore/default` when no route-specific secret is set.
