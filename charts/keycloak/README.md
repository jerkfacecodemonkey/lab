# Keycloak Helm Chart

This chart deploys the Keycloak operator and a Keycloak instance for SSO in the homelab.

## Components

- Keycloak Operator (manages Keycloak instances)
- Keycloak CRDs (Keycloak, KeycloakRealmImport)
- Keycloak instance (dev mode with H2 database by default)

## Install

```bash
cd charts/keycloak
helm upgrade --install keycloak . \
  --namespace keycloak \
  --create-namespace
```

## Access

With the Traefik app routes in this repo, Keycloak is available at:

- `https://keycloak.donethanks.com`

Default admin credentials are stored in the secret `keycloak-initial-admin`:

```bash
kubectl -n keycloak get secret keycloak-initial-admin -o jsonpath='{.data.username}' | base64 -d && echo
kubectl -n keycloak get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 -d && echo
```

## Configuration

### Development Mode (Default)

Uses H2 embedded database - suitable for testing and development:

```yaml
keycloak:
  startMode: start-dev
```

### Production Mode

For production, configure an external PostgreSQL database:

```yaml
keycloak:
  startMode: start
  db:
    host: postgres.database.svc
    database: keycloak
    usernameSecret:
      name: keycloak-db-credentials
      key: username
    passwordSecret:
      name: keycloak-db-credentials
      key: password
```

Create the database credentials secret:

```bash
kubectl -n keycloak create secret generic keycloak-db-credentials \
  --from-literal=username=keycloak \
  --from-literal=password=YOUR_DB_PASSWORD
```

## Argo CD

Application manifest:

- `argocd/applications/keycloak.yaml`

### Declarative Client Sync

The chart includes an Argo PostSync hook Job that upserts the `kibana-oauth` client in realm `master`.

Why this exists:

- `KeycloakRealmImport` skips updating existing realms (`master`), so changes in `realm-import-master.yaml` are not always applied after first bootstrap.

Configuration:

- `keycloak.clientSync.enabled` (default: `true`)
- `keycloak.clientSync.adminSecretName`
- `keycloak.clientSync.adminUsernameKey`
- `keycloak.clientSync.adminPasswordKey`

The admin secret must contain valid credentials for Keycloak admin API access.

Recommended:

- Use a dedicated secret for the sync hook, e.g. `keycloak-client-sync-admin`.
- Ensure the username/password are for an existing master realm user with admin permissions.

Example:

```bash
kubectl -n keycloak create secret generic keycloak-client-sync-admin \
  --from-literal=username=YOUR_ADMIN_USER \
  --from-literal=password=YOUR_ADMIN_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -
```

The chart now manages this bootstrap/admin secret when `keycloak.adminSecret.create` is `true`, using:

- `keycloak.adminSecret.name`
- `keycloak.adminSecret.username`
- `keycloak.adminSecret.password`

## References

- [Keycloak Operator Documentation](https://www.keycloak.org/operator/installation)
- [Keycloak Server Configuration](https://www.keycloak.org/server/all-config)
