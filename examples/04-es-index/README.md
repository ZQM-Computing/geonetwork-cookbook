# 04 — ES Index: GeoNetwork's Elasticsearch Indices

**Design-only — gate 1 target. Not runtime-validated.** This pattern
shows the GeoNetwork → Elasticsearch side of the catalog: the three
indices GeoNetwork maintains (`gn-records`, `gn-features`,
`gn-searchlogs`), how to check them from Elasticsearch, and how a record
insert flows into `gn-records` after an index rebuild. The search index
is a derived view of the catalog, not the catalog itself — the metadata
records remain authoritative in GeoNetwork.

## Prerequisites

- GeoNetwork 4.4.12 (Jetty bundle, port 8082) — fleet seed version
- Elasticsearch 8.19.13 (single-node, 1g heap, xpack disabled — dev
  configuration; see elasticsearch-cookbook pattern 01)
- `curl`
- Pattern 01's synthetic record inserted (for the end-to-end check)

## Files

- `check.sh` — lists the `gn-*` indices, counts `gn-records` docs, and
  searches it for the synthetic record's uuid

## Steps

```bash
bash check.sh
```

## Expected output

- `_cat/indices/gn-*` lists three indices: `gn-records`, `gn-features`,
  `gn-searchlogs`, all open (fleet evidence: all three open on Node-3
  and Node-4 after the GeoNetwork + Elasticsearch install).
- `_count` on `gn-records` grows by one after pattern 01's insert plus
  an index rebuild; the count is reported, never assumed.
- A search for the synthetic uuid in `gn-records` returns the document
  (title "Synthetic Test Dataset — DO NOT PUBLISH").
- `gn-searchlogs` gains entries as catalog searches run; it is
  append-only evidence of search traffic, not a record store.

## Failure behavior

- Index missing → `_cat/indices` shows it absent; the fix is a
  GeoNetwork index rebuild from the admin UI/API, not hand-creating the
  index (hand-created mappings diverge from GeoNetwork's).
- Stale count after insert → the index rebuild has not run; counts
  before a rebuild are stale by design, not a data loss.
- Elasticsearch down → GeoNetwork still serves records from its own
  store; search falls back or degrades, it does not take the catalog
  down (to confirm at validation: the fleet's exact fallback behavior).
- **Node-1 scope note (fleet fact): Node-1's GeoNetwork has NO
  Elasticsearch.** This pattern applies to Node-3 and Node-4, where the
  ES pairing is proven. On Node-1, the `gn-*` checks do not apply.

## Versions note

GeoNetwork 4.4.12 + Elasticsearch 8.19.13 per the fleet seed. Index
names are fleet-verified (Node-3/Node-4). Document field spellings inside
`gn-records` are design-only sketches — to confirm at validation: the
exact mapping GeoNetwork 4.4.12 writes for title, uuid, and geometry.
Elasticsearch bind (localhost:9200 default) is to confirm at validation.
