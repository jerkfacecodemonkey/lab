#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
  set +a
fi

ELASTIC_PASSWORD="${ELASTIC_PASSWORD:-}"
NAMESPACE="${LOGSTASH_NAMESPACE:-kafka}"
SECRET_NAME="${LOGSTASH_ELASTIC_SECRET_NAME:-logstash-elasticsearch-credentials}"
SECRET_KEY="${LOGSTASH_ELASTIC_SECRET_KEY:-password}"

if [[ -z "${ELASTIC_PASSWORD}" ]]; then
  cat >&2 <<'EOF'
Missing required variable:
  ELASTIC_PASSWORD

Set it in .env (or pass an env file path as arg 1), then run this script again.
EOF
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal="${SECRET_KEY}=${ELASTIC_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret ${NAMESPACE}/${SECRET_NAME} applied."
