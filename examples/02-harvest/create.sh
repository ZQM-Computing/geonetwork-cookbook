#!/usr/bin/env bash
# Create a CSW harvester and confirm the API accepts it.
# Endpoint spelling and the follow-up run/status endpoints remain unverified for 4.4.12.
set -euo pipefail

: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
: "${GN_USER:?set GN_USER (administrator account)}"
: "${GN_PASS:?set GN_PASS}"

BASE="${GN_BASE%/}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "-- create harvester --"
curl --fail-with-body --silent --show-error \
  --user "$GN_USER:$GN_PASS" \
  --header "Content-Type: application/json" \
  --data-binary "@$DIR/harvester.json" \
  --output "$TMP_DIR/create-response.json" \
  "$BASE/srv/api/0.1/harvesters"
cat "$TMP_DIR/create-response.json"
echo

echo "-- list harvesters --"
curl --fail-with-body --silent --show-error \
  --user "$GN_USER:$GN_PASS" \
  --output "$TMP_DIR/list-response.json" \
  "$BASE/srv/api/0.1/harvesters"
cat "$TMP_DIR/list-response.json"
echo

echo "Harvester creation/list request completed. This script does not trigger a harvest run:"
echo "the run/status endpoints must first be confirmed against the target GeoNetwork 4.4.12 build."
