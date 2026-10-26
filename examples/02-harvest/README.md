# 02 — Harvest: Scheduled Catalog Harvesting

**Design-only — gate 1 target. Not runtime-validated.** This pattern
harvests a remote public catalog on a schedule: a CSW harvester node,
created through the GeoNetwork API, run once on demand, then left on its
daily schedule. Harvesting is read-only against the source — it copies
public metadata records into the local catalog; it never writes back to
the source and never touches a private or authenticated catalog.

## Prerequisites

- GeoNetwork 4.4.12 (Jetty bundle, port 8082) — fleet seed version
- Java 21 runtime
- `curl`
- A public CSW endpoint to harvest (placeholder URL in the config; use a
  genuinely public catalog, never a private one)
- A GeoNetwork account with administrator rights (placeholders only)

## Files

- `harvester.json` — CSW harvester node configuration (placeholder source
  URL, daily schedule)
- `create.sh` — creates the harvester, runs it once, reports its status

## Steps

```bash
bash create.sh
```

`create.sh` posts the harvester node, triggers one run, then polls the
harvester status until it reports completion or failure.

## Expected output

- The harvester is created and listed with status `active` (or the
  4.4.12 equivalent — to confirm at validation).
- The on-demand run completes and reports a harvested-record count
  (zero is a valid count if the source catalog is empty for the query;
  the count must be reported, never assumed).
- On the daily schedule, the harvester re-runs without manual action;
  its last-run timestamp advances.

## Failure behavior

- Unreachable source → the harvester reports an error status and no
  partial records are presented as a successful harvest; the error is
  logged on the harvester, not hidden.
- Malformed source records → the harvester skips them and counts the
  skips; a harvest that silently drops records is a failure of this
  pattern, not an acceptable outcome.
- Duplicate uuids from the source → handled per the harvester's uuid
  policy (to confirm at validation: which policy the fleet uses).
- To confirm at validation: the exact harvester create/run/status
  endpoint spellings on GeoNetwork 4.4.12, and the schedule expression
  format the fleet uses.

## Versions note

GeoNetwork 4.4.12 per the fleet seed. Harvester node JSON shapes are
design-only until a validation run proves them against a live 4.4.12
instance. Harvest only public catalogs; harvesting is passive — no
probing, no account interaction against third parties.
