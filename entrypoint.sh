#!/bin/sh
set -eu

if [ -z "${KUBE_CONFIG_DATA:-}" ]; then
  echo "::error::KUBE_CONFIG_DATA is not set. Provide a base64-encoded kubeconfig via env." >&2
  exit 1
fi

umask 077
kubeconfig="$(mktemp)"
trap 'rm -f "$kubeconfig"' EXIT

if ! printf '%s' "$KUBE_CONFIG_DATA" | base64 -d > "$kubeconfig" 2>/dev/null || [ ! -s "$kubeconfig" ]; then
  echo "::error::KUBE_CONFIG_DATA is not valid base64 or decodes to an empty kubeconfig." >&2
  exit 1
fi
export KUBECONFIG="$kubeconfig"

# $1 is intentionally unquoted: the single `args` string is word-split into kubectl arguments.
set +e
# shellcheck disable=SC2086
result="$(kubectl ${1:-})"
status=$?
set -e

echo "$result"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  { echo "result<<EOF_RESULT"; echo "$result"; echo "EOF_RESULT"; } >> "$GITHUB_OUTPUT"
fi

exit "$status"
