#!/usr/bin/env bash
# CSW client: capabilities, title query, empty-result query.
# Design-only: endpoint path to confirm at validation on GeoNetwork 4.4.12.
set -euo pipefail
: "${GN_BASE:?set GN_BASE, e.g. http://localhost:8082/geonetwork}"
CSW="$GN_BASE/srv/eng/csw"

echo "-- GetCapabilities --"
curl -sS "$CSW?service=CSW&version=2.0.2&request=GetCapabilities" | head -c 1500
echo
echo "-- GetRecords: synthetic title --"
curl -sS -H "Content-Type: application/xml" --data-binary @getrecords.xml "$CSW" | head -c 2000
echo
echo "-- GetRecords: empty result (title that matches nothing) --"
sed 's/Synthetic Test Dataset%/No Such Dataset Anywhere%/' getrecords.xml > /tmp/gn-empty.xml
curl -sS -H "Content-Type: application/xml" --data-binary @/tmp/gn-empty.xml "$CSW" | head -c 1000
echo
echo "Expected: numberOfRecordsMatched >= 1 for the title query,"
echo "numberOfRecordsMatched=\"0\" (not an error) for the empty query."
