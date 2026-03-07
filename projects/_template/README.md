# Project Template

Use this template to create isolated workload projects that can be deployed or torn down without affecting core platform services.

## Layout

- `argocd/project.yaml`: Argo AppProject for the workload.
- `argocd/applications/*.yaml`: Argo Applications for services in the workload.
- `charts/*` or `manifests/*`: deployable resources.

## Recommended Bootstrap

1. Copy this folder to `projects/<project-name>`.
2. Update names, repo URL, and allowed namespaces in `argocd/project.yaml`.
3. Add service applications under `argocd/applications/`.
4. Apply:

```bash
kubectl apply -f projects/<project-name>/argocd/project.yaml
kubectl apply -f projects/<project-name>/argocd/applications/
```

## Teardown

Delete workload Applications first, then the AppProject:

```bash
kubectl -n argocd delete application -l homelab.donethanks.com/project=<project-name>
kubectl -n argocd delete appproject <project-name>
```
