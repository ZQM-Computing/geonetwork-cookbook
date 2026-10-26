#!/usr/bin/env bash
# Insert the synthetic ISO record into GeoNetwork, then read it back.
# Placeholders only: set GN_BASE, GN_USER, GN_PASS in the environment.
# Design-only: endpoint spellings to confirm at validation on GeoNetwork 4.4.12.
set -euo pipefail
: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
: "${GN_USER:?set GN_USER (editor account)}"
: "${GN_PASS:?set GN_PASS}"
UUID="00000000-0000-4000-8000-000000000001"

echo "-- insert --"
curl -sS -u "$GN_USER:$GN_PASS" -H "Content-Type: application/xml" \
  --data-binary @record.xml "$GN_BASE/srv/api/0.1/records"
echo
echo "-- read back --"
curl -sS -u "$GN_USER:$GN_PASS" \
  "$GN_BASE/srv/api/0.1/records/$UUID/formatters/xml" | head -c 2000
echo
echo "-- local schema check (requires the ISO 19139 schema locally) --"
echo "Run: xmllint --noout --schema <path-to-iso-19139-schema> record.xml"
echo "Expected: record.xml validates (or failures are listed explicitly)."
