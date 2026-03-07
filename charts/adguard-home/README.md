# AdGuard Home Helm Chart

This chart deploys AdGuard Home for homelab use with DNS exposed on node port `53` (via `hostPort`) and fixed `NodePort` values for the web interfaces.

## Defaults

- DNS TCP/UDP: `53` via `hostPort`
- Web UI: `30080`
- Setup UI: `30300`

## Install

```bash
cd charts/adguard-home
helm upgrade --install adguard-home . \
  --namespace adguard-home \
  --create-namespace
```

## LAN Access

Using server `192.168.1.67` from this homelab:

- Configure client DNS to: `192.168.1.67`
- Open setup UI: `http://192.168.1.67:30300`
- Open web UI: `http://192.168.1.67:30080`

## DNS Exposure Modes

- Default: `dns.hostPort.enabled=true` exposes DNS on `<node-ip>:53`.
- Optional: `dns.hostNetwork.enabled=true` enables host networking.
- When host networking is enabled, `hostPort` entries are not rendered.
- DNS is not exposed via `NodePort` by default.
- Optional in-cluster DNS service: set `dns.service.enabled=true`.

Example to enable host networking:

```bash
helm upgrade --install adguard-home . \
  --namespace adguard-home \
  --create-namespace \
  --set dns.hostNetwork.enabled=true
```

## Customize values

Edit `values.yaml` and re-run `helm upgrade --install`.

If you do not want persistence, set:

```yaml
persistence:
  enabled: false
```

## Argo CD

Example Argo CD `Application` manifests are provided at:

- `argocd/applications/adguard-home.yaml`
- `argocd/applications/argocd.yaml`

## Deploy To Argo CD

1. Update `repoURL` in both files to your real Git SSH/HTTPS URL:

- `argocd/applications/argocd.yaml`
- `argocd/applications/adguard-home.yaml`
2. Apply the Application manifest:

```bash
cd /home/jason/dev/lab
kubectl apply -f argocd/applications/adguard-home.yaml
```

To also have Argo CD self-manage its own chart:

```bash
kubectl apply -f argocd/applications/argocd.yaml
```

3. Open Argo CD UI and verify the `adguard-home` app appears.
4. Sync the app in UI if automatic sync is disabled.
