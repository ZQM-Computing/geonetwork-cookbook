#!/usr/bin/env bash
# Create the CSW harvester, run it once, report its status.
# Placeholders only: set GN_BASE, GN_USER, GN_PASS in the environment.
# Design-only: endpoint spellings to confirm at validation on GeoNetwork 4.4.12.
set -euo pipefail
: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
: "${GN_USER:?set GN_USER (administrator account)}"
: "${GN_PASS:?set GN_PASS}"

echo "-- create harvester --"
curl -sS -u "$GN_USER:$GN_PASS" -H "Content-Type: application/json" \
  --data-binary @harvester.json "$GN_BASE/srv/api/0.1/harvesters"
echo
echo "-- list harvesters (confirm the new node appears) --"
curl -sS -u "$GN_USER:$GN_PASS" "$GN_BASE/srv/api/0.1/harvesters"
echo
echo "-- run once + status (endpoint spellings to confirm at validation) --"
echo "Expected: one run completes and reports a harvested-record count;"
echo "an unreachable source must surface as an error status, not a silent zero."
