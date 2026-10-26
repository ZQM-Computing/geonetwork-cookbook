#!/usr/bin/env bash
# Inspect GeoNetwork's Elasticsearch indices and search for the synthetic record.
# Design-only: confirm the ES bind and index mappings on the target host.
set -euo pipefail

: "${ES_BASE:=http://localhost:9200}"
BASE="${ES_BASE%/}"
UUID="00000000-0000-4000-8000-000000000001"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "-- gn-* indices --"
curl --fail-with-body --silent --show-error "$BASE/_cat/indices/gn-*?v"
echo
echo "-- gn-records count --"
curl --fail-with-body --silent --show-error "$BASE/gn-records/_count"
echo
echo "-- search gn-records for the synthetic uuid --"
curl --fail-with-body --silent --show-error \
  --header "Content-Type: application/json" \
  --data-binary "{\"query\":{\"term\":{\"uuid\":\"$UUID\"}}}" \
  "$BASE/gn-records/_search"
echo
echo "Expected: gn-records, gn-features, and gn-searchlogs indices are open;"
echo "the synthetic UUID appears after insert and index refresh/rebuild."
echo "Node-1 scope: Node-1 GeoNetwork has NO Elasticsearch; this pattern"
echo "applies to Node-3 and Node-4 only."
