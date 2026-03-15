#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
  set +a
fi

ELASTIC_USERNAME="${ELASTIC_USERNAME:-}"
ELASTIC_PASSWORD="${ELASTIC_PASSWORD:-}"
KIBANA_USERNAME="${KIBANA_USERNAME:-}"
KIBANA_PASSWORD="${KIBANA_PASSWORD:-}"
NAMESPACE="${ELASTIC_NAMESPACE:-elastic}"
SECRET_NAME="${ELASTIC_SECURITY_SECRET_NAME:-elastic-credentials}"

if [[ -z "${ELASTIC_USERNAME}" || -z "${ELASTIC_PASSWORD}" || -z "${KIBANA_USERNAME}" || -z "${KIBANA_PASSWORD}" ]]; then
  cat >&2 <<'EOF'
Missing required variables. Set all of:
  ELASTIC_USERNAME
  ELASTIC_PASSWORD
  KIBANA_USERNAME
  KIBANA_PASSWORD

You can copy .env.example to .env and run this script again.
EOF
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal=elastic-username="${ELASTIC_USERNAME}" \
  --from-literal=elastic-password="${ELASTIC_PASSWORD}" \
  --from-literal=kibana-username="${KIBANA_USERNAME}" \
  --from-literal=kibana-password="${KIBANA_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret ${NAMESPACE}/${SECRET_NAME} applied."
