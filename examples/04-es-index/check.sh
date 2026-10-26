#!/usr/bin/env bash
# Check GeoNetwork's Elasticsearch indices and find the synthetic record.
# Design-only: ES bind to confirm at validation (localhost:9200 default).
set -euo pipefail
: "${ES_BASE:=http://localhost:9200}"
UUID="00000000-0000-4000-8000-000000000001"

echo "-- gn-* indices --"
curl -sS "$ES_BASE/_cat/indices/gn-*?v"
echo
echo "-- gn-records count --"
curl -sS "$ES_BASE/gn-records/_count"
echo
echo "-- search gn-records for the synthetic uuid --"
curl -sS -H "Content-Type: application/json" -d "{\"query\":{\"term\":{\"uuid\":\"$UUID\"}}}" \
  "$ES_BASE/gn-records/_search"
echo
echo "Expected: gn-records, gn-features, gn-searchlogs all open;"
echo "the synthetic uuid is found after insert + index rebuild."
echo "Node-1 scope: Node-1 GeoNetwork has NO Elasticsearch — this pattern"
echo "applies to Node-3 and Node-4 only."
