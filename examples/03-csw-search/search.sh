#!/usr/bin/env bash
# CSW client: capabilities, title query, and empty-result query.
# Design-only: confirm the endpoint path and response schema on GeoNetwork 4.4.12.
set -euo pipefail

: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
BASE="${GN_BASE%/}"
CSW="$BASE/srv/eng/csw"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

request() {
  local label="$1"
  local output="$2"
  shift 2
  echo "-- $label --"
  curl --fail-with-body --silent --show-error --output "$output" "$@"
}

request "GetCapabilities" "$TMP_DIR/capabilities.xml" \
  "$CSW?service=CSW&version=2.0.2&request=GetCapabilities"
head -c 1500 "$TMP_DIR/capabilities.xml"
echo

request "GetRecords: synthetic title" "$TMP_DIR/matched.xml" \
  --header 'Content-Type: application/xml' \
  --data-binary "@$DIR/getrecords.xml" "$CSW"
head -c 2000 "$TMP_DIR/matched.xml"
echo

sed 's/Synthetic Test Dataset%/No Such Dataset Anywhere%/' \
  "$DIR/getrecords.xml" > "$TMP_DIR/empty-query.xml"
request "GetRecords: empty result" "$TMP_DIR/empty.xml" \
  --header 'Content-Type: application/xml' \
  --data-binary "@$TMP_DIR/empty-query.xml" "$CSW"
head -c 1000 "$TMP_DIR/empty.xml"
echo

matched_count="$(python - "$TMP_DIR/matched.xml" <<'PY'
import sys
from xml.etree import ElementTree

root = ElementTree.parse(sys.argv[1]).getroot()
results = next((node for node in root.iter() if node.tag.rsplit("}", 1)[-1] == "SearchResults"), None)
if results is None or "numberOfRecordsMatched" not in results.attrib:
    raise SystemExit("CSW response lacks SearchResults/@numberOfRecordsMatched")
print(results.attrib["numberOfRecordsMatched"])
PY
)"
empty_count="$(python - "$TMP_DIR/empty.xml" <<'PY'
import sys
from xml.etree import ElementTree

root = ElementTree.parse(sys.argv[1]).getroot()
results = next((node for node in root.iter() if node.tag.rsplit("}", 1)[-1] == "SearchResults"), None)
if results is None or "numberOfRecordsMatched" not in results.attrib:
    raise SystemExit("CSW response lacks SearchResults/@numberOfRecordsMatched")
print(results.attrib["numberOfRecordsMatched"])
PY
)"
[[ "$matched_count" =~ ^[0-9]+$ ]] && (( matched_count >= 1 )) || {
  echo "Expected at least one record for the synthetic title; got '$matched_count'" >&2
  exit 1
}
[[ "$empty_count" == "0" ]] || {
  echo "Expected zero records for the empty query; got '$empty_count'" >&2
  exit 1
}
printf 'CSW assertions passed: matched=%s empty=%s\n' "$matched_count" "$empty_count"
