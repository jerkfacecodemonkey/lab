# Pipeline Project

This project isolates the pipeline stack from core lab infrastructure.

## Included Services

- Strimzi operator
- Kafka cluster
- Kafka topics
- Kafka UI
- Elasticsearch + Kibana
- Logstash

## Deploy

```bash
cd /home/jason/dev/lab
kubectl apply -f projects/pipeline/argocd/project.yaml
kubectl apply -f projects/pipeline/argocd/applications/
```

## Prerequisites

Logstash expects a secret named `logstash-elasticsearch-credentials` in namespace `kafka`.

Elastic chart defaults to self-managed credentials. Override values or create secrets before sync if needed.

## Teardown

```bash
kubectl -n argocd delete application -l homelab.donethanks.com/project=pipeline
kubectl -n argocd delete appproject pipeline
```

## Notes

- `projects/pipeline/charts/kafka-ui/values.yaml` uses NodePort `30082` to avoid conflict with Argo CD server NodePort `30080`.
- `pipeline-kafka` uses `prune: false` to avoid accidental Kafka cluster deletion.
