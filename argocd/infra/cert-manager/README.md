# cert-manager Wildcard TLS Renewal

This runbook configures automatic Let's Encrypt wildcard renewal for `donethanks.com` using cert-manager and Cloudflare DNS-01.

## Goal

- Keep `kube-system/donethanks-wildcard-tls` renewed automatically.
- Continue using that secret as Traefik's default TLS certificate.

## Resources in this folder

- `clusterissuer-cloudflare-example.yaml`
  - `ClusterIssuer` named `letsencrypt-wildcard`
  - Uses Cloudflare DNS-01 solver
- `certificate-wildcard-donethanks.yaml`
  - `Certificate` named `donethanks-wildcard`
  - Writes cert/key to `kube-system/donethanks-wildcard-tls`
- `cloudflare-api-token-secret.yaml`
  - Template only (do not commit real token values)

## Prerequisites

- cert-manager installed and healthy
- `donethanks.com` authoritative DNS hosted in Cloudflare
- Cloudflare API token with at least `Zone DNS Edit` permission for the target zone

## Step 1: Create Cloudflare API Token Secret

Use this command to create or update the secret used by the issuer:

```bash
kubectl -n cert-manager create secret generic cloudflare-api-token \
  --from-literal=api-token='YOUR_CLOUDFLARE_API_TOKEN' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Verify the secret key exists:

```bash
kubectl -n cert-manager get secret cloudflare-api-token \
  -o jsonpath='{.data.api-token}' | base64 -d; echo
```

## Step 2: Apply Issuer and Certificate

1. Set your ACME email in `clusterissuer-cloudflare-example.yaml`.
2. Apply resources:

```bash
kubectl apply -f argocd/infra/cert-manager/clusterissuer-cloudflare-example.yaml
kubectl apply -f argocd/infra/cert-manager/certificate-wildcard-donethanks.yaml
```

## Step 3: Verify Issuance

Check readiness:

```bash
kubectl get clusterissuer letsencrypt-wildcard
kubectl -n kube-system get certificate donethanks-wildcard
kubectl -n kube-system get secret donethanks-wildcard-tls
```

Inspect full status/events:

```bash
kubectl -n kube-system describe certificate donethanks-wildcard
kubectl -n kube-system get certificaterequest,order,challenge
kubectl -n cert-manager logs deploy/cert-manager --tail=200
```

## Renewal Behavior

- cert-manager renews before expiration (as configured by `renewBefore` in the `Certificate`).
- Renewed cert is written to the same secret: `kube-system/donethanks-wildcard-tls`.
- Traefik picks up the updated secret automatically.

## Troubleshooting

- `Invalid format for Authorization header`
  - Cause: invalid token string, wrong secret key, or old credential.
  - Fix: recreate `cert-manager/cloudflare-api-token` with a valid Cloudflare API token.

- `ACME client for issuer not initialised/available`
  - Usually transient while issuer/account key is being created.
  - Recheck after 15-30 seconds.

- Certificate stuck `Issuing` with `IncorrectIssuer`
  - Happens when existing TLS secret was created outside cert-manager.
  - cert-manager should re-issue and take ownership after creating a new `CertificateRequest`.

## Security Notes

- Use Cloudflare API token, not Global API key.
- Do not commit real token values to git.
- Rotate/revoke token immediately if exposed.
