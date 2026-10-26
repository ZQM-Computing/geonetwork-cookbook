#!/usr/bin/env bash
# Insert the synthetic ISO record, verify the HTTP response, then read it back.
# Placeholders only: set GN_BASE, GN_USER, GN_PASS in the environment.
# Endpoint spellings remain design-only until validated against GeoNetwork 4.4.12.
set -euo pipefail

: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
: "${GN_USER:?set GN_USER (editor account)}"
: "${GN_PASS:?set GN_PASS}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UUID="00000000-0000-4000-8000-000000000001"
TITLE="Synthetic Test Dataset — DO NOT PUBLISH"
BASE="${GN_BASE%/}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSERT_BODY="$TMP/insert-response.txt"
READBACK="$TMP/readback.xml"

request_status() {
  local method="$1"
  local url="$2"
  local output="$3"
  shift 3
  curl --silent --show-error --user "$GN_USER:$GN_PASS" \
    --request "$method" --output "$output" --write-out '%{http_code}' \
    "$@" "$url"
}

echo "-- insert synthetic record --"
status="$(request_status POST "$BASE/srv/api/0.1/records" "$INSERT_BODY" \
  --header 'Content-Type: application/xml' \
  --data-binary "@$DIR/record.xml")"
case "$status" in
  200|201) ;;
  *)
    printf 'GeoNetwork insert returned HTTP %s\n' "$status" >&2
    cat "$INSERT_BODY" >&2
    exit 1
    ;;
esac
printf 'insert HTTP %s\n' "$status"

echo "-- read back by UUID --"
status="$(request_status GET \
  "$BASE/srv/api/0.1/records/$UUID/formatters/xml" "$READBACK")"
if [[ "$status" != 200 ]]; then
  printf 'GeoNetwork read-back returned HTTP %s\n' "$status" >&2
  cat "$READBACK" >&2
  exit 1
fi

if ! command -v xmllint >/dev/null 2>&1; then
  echo "xmllint is required for XML identity assertions" >&2
  exit 2
fi
actual_uuid="$(xmllint --xpath \
  "string(//*[local-name()='fileIdentifier']/*[local-name()='CharacterString'])" \
  "$READBACK")"
actual_title="$(xmllint --xpath \
  "string(//*[local-name()='identificationInfo']//*[local-name()='title']/*[local-name()='CharacterString'])" \
  "$READBACK")"
[[ "$actual_uuid" == "$UUID" ]] || {
  printf 'UUID mismatch: expected %s, got %s\n' "$UUID" "$actual_uuid" >&2
  exit 1
}
[[ "$actual_title" == "$TITLE" ]] || {
  printf 'Title mismatch: expected %s, got %s\n' "$TITLE" "$actual_title" >&2
  exit 1
}
echo "read-back identity verified: $actual_uuid"
echo "title verified: $actual_title"

if [[ -n "${GN_ISO19139_XSD:-}" ]]; then
  [[ -f "$GN_ISO19139_XSD" ]] || {
    echo "GN_ISO19139_XSD does not point to a readable local schema file" >&2
    exit 2
  }
  echo "-- validate read-back XML against supplied local schema --"
  xmllint --noout --schema "$GN_ISO19139_XSD" "$READBACK"
else
  echo "Schema validation not run: set GN_ISO19139_XSD to a local ISO 19139 XSD."
fi
