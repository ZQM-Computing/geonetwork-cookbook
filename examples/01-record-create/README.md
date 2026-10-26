# 01 — Record Create: ISO Metadata Records

**Design-only — gate 1 target. Not runtime-validated.** This pattern creates
and validates an ISO 19139 metadata record in GeoNetwork: a synthetic
dataset record, inserted through the API, then read back and validated
against the ISO schema. The record is explicitly synthetic — a fictional
dataset, a bounding box around the null-island area, no real place, no real
data — so it can never be mistaken for a published catalog entry.

## Prerequisites

- GeoNetwork 4.4.12 (Jetty bundle, port 8082) — fleet seed version
- Java 21 runtime
- `curl`, `xmllint` (for the local schema check)
- A GeoNetwork account with editor rights (placeholder credentials only;
  the fleet's default-admin handling is an owner follow-up — never bake
  real credentials into an example)

## Files

- `record.xml` — synthetic ISO 19139 record (uuid
  `00000000-0000-4000-8000-000000000001`, title "Synthetic Test Dataset —
  DO NOT PUBLISH")
- `insert.sh` — inserts the record via the GeoNetwork API, then reads it back

## Steps

```bash
bash insert.sh
```

`insert.sh` posts `record.xml` to
`{base}/srv/api/0.1/records` with `Content-Type: application/xml`, then
GETs the record back by uuid and runs the local schema check.

## Expected output

- The insert returns 201 (or 200 on replace) and the response carries the
  record uuid.
- The read-back GET returns XML whose `gmd:fileIdentifier` matches the
  submitted uuid and whose title reads "Synthetic Test Dataset — DO NOT
  PUBLISH".
- The local schema check passes against the ISO 19139 schema, or reports
  its failures explicitly — never silently skipped.
- The record appears in the catalog search only under its synthetic title;
  it is never presented as a real dataset.

## Failure behavior

- Malformed XML → the API rejects the insert (4xx) and no record is
  created; fix the XML, do not hand-edit the stored record.
- Duplicate uuid → the API reports a conflict (or replaces, per the
  `uuidProcessing` behavior in effect); the script prints the response
  instead of assuming success.
- Schema check failure → the record is still inserted but flagged
  invalid; validation is a separate gate from insertion.
- To confirm at validation: the exact insert endpoint spelling and
  `uuidProcessing` values on GeoNetwork 4.4.12, and the schema URL the
  fleet validates against.

## Versions note

GeoNetwork 4.4.12 per the fleet seed. API paths above are the GeoNetwork
4.x `/srv/api/0.1` surface; endpoint spellings are design-only until a
validation run proves them against a live 4.4.12 instance.
