# Pipeline Project

This project isolates the pipeline stack from core lab infrastructure.

## Included Services

- Strimzi operator
- Kafka cluster
- Kafka topics
- Kafka UI
- Elasticsearch + Kibana
- Logstash

## Exposed HTTPS Endpoints

- `https://kibana.donethanks.com` -> `elastic/kibana`
- `https://elastic.donethanks.com` -> `elastic/elasticsearch`
- `https://kafka.donethanks.com` -> `kafka/kafka-ui`

Kafka brokers are not exposed outside the cluster.

## Deploy

```bash
cd /home/jason/dev/lab
kubectl apply -f projects/pipeline/argocd/project.yaml
kubectl apply -f projects/pipeline/argocd/applications/
```

## Prerequisites

Logstash expects a secret named `logstash-elasticsearch-credentials` in namespace `kafka`.

Elastic chart defaults to self-managed credentials. Override values or create secrets before sync if needed.

Worker DNS prerequisite (important for local-path PVC provisioning):

- Each worker node must resolve container registries (for example `registry-1.docker.io`).
- If a node cannot resolve/pull the `rancher/mirrored-library-busybox:1.37.0` helper image, local-path PVC provisioning can fail and Kafka brokers may stay Pending.
- Validate on each worker:

```bash
ssh pi@192.168.1.68 'cat /etc/resolv.conf; getent hosts registry-1.docker.io'
```

For this lab, the fix on `pi` was:

```bash
ssh pi@192.168.1.68 'sudo nmcli connection modify netplan-eth0 ipv4.dns "192.168.1.67" ipv4.ignore-auto-dns yes && sudo nmcli connection up netplan-eth0'
```

## Teardown

```bash
kubectl -n argocd delete application -l homelab.donethanks.com/project=pipeline
kubectl -n argocd delete appproject pipeline
```

## Notes

- `projects/pipeline/charts/kafka-ui/values.yaml` uses NodePort `30082` to avoid conflict with Argo CD server NodePort `30080`.
- Pipeline Traefik routes are managed in:
	- `projects/pipeline/charts/elastic/templates/traefik-routes.yaml`
	- `projects/pipeline/charts/kafka-ui/templates/traefik-route.yaml`
- `pipeline-kafka` uses `prune: false` to avoid accidental Kafka cluster deletion.
- `projects/pipeline/charts/kafka/templates/kafka.yaml` sets `argocd.argoproj.io/compare-options: IgnoreExtraneous` on Strimzi-generated Kafka PVCs so `pipeline-kafka` can remain `Synced` without enabling prune.

## Troubleshooting

### Kafka PVC Stuck Pending

Symptoms:

- `data-strimzi-kafka-default-*` PVC Pending
- local-path helper pod on a worker in `ErrImagePull`

Checks:

```bash
kubectl -n kube-system get pod -o wide | grep helper-pod-create
kubectl -n kafka get pvc,pod
```

Recovery after fixing node DNS:

```bash
kubectl -n kafka delete pod strimzi-kafka-default-1 --ignore-not-found=true --wait=false
kubectl -n kafka delete pvc data-strimzi-kafka-default-1 --ignore-not-found=true
```

### Kibana `kibana_system` Authentication Error

Symptom in Kibana logs:

- `unable to authenticate user [kibana_system]`

Use helper script to sync Kibana password in Elasticsearch to the value in `elastic-credentials` secret:

```bash
cd /home/jason/dev/lab
projects/pipeline/scripts/set-kibana-system-password.sh
```

### Kibana Streams/Alerts Encryption Key Error

If Kibana shows errors similar to:

- `Unable to create alerts client because the Encrypted Saved Objects plugin is missing encryption key`

Ensure `security.kibana.encryptedSavedObjectsKey` is set in [projects/pipeline/charts/elastic/values.yaml](projects/pipeline/charts/elastic/values.yaml) and sync `pipeline-elastic` in Argo CD.
