#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-elastic}"
SECRET_NAME="${2:-elastic-credentials}"
ELASTIC_POD="${3:-elasticsearch-0}"

ELASTIC_PASS="$(kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.elastic-password}' | base64 -d)"
KIBANA_PASS="$(kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.kibana-password}' | base64 -d)"

# Ensure kibana_system in Elasticsearch matches the Kubernetes secret used by Kibana.
kubectl -n "${NAMESPACE}" exec "${ELASTIC_POD}" -- env ELASTIC_PASS="${ELASTIC_PASS}" KIBANA_PASS="${KIBANA_PASS}" sh -lc '
  set -e
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "kibana_system:${KIBANA_PASS}" http://127.0.0.1:9200/_security/_authenticate)
  if [ "$CODE" != "200" ]; then
    curl -s -o /dev/null -w "set_kibana_http=%{http_code}\n" \
      -u "elastic:${ELASTIC_PASS}" \
      -H "Content-Type: application/json" \
      -X POST \
      http://127.0.0.1:9200/_security/user/kibana_system/_password \
      -d "{\"password\":\"${KIBANA_PASS}\"}"
  fi

  FINAL=$(curl -s -o /dev/null -w "%{http_code}" -u "kibana_system:${KIBANA_PASS}" http://127.0.0.1:9200/_security/_authenticate)
  echo "kibana_auth_final_http=${FINAL}"
'
