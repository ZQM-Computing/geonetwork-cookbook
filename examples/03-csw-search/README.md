# 03 — CSW Search: Querying the Catalog as a Client

**Design-only — gate 1 target. Not runtime-validated.** This pattern
queries GeoNetwork as a CSW client: GetCapabilities to learn the service,
then a GetRecords request filtering on the synthetic record's title, then
an empty-result query proving that "no matches" is a normal outcome, not
an error. CSW is the catalog's machine interface — the same one
harvesters and desktop clients use.

## Prerequisites

- GeoNetwork 4.4.12 (Jetty bundle, port 8082) — fleet seed version
- `curl`
- Pattern 01's synthetic record inserted (or any known record to match
  against); the empty-result query needs no records at all

## Files

- `getrecords.xml` — GetRecords request filtering Title Like
  "Synthetic Test Dataset%"
- `search.sh` — GetCapabilities, the title query, and the empty-result query

## Steps

```bash
bash search.sh
```

## Expected output

- GetCapabilities returns a valid capabilities document naming the
  GetRecords operation.
- The title query returns a `SearchResults` element with
  `numberOfRecordsMatched` >= 1 and the synthetic record's uuid among the
  results (when pattern 01's record is present).
- The empty-result query (a title that matches nothing) returns
  `numberOfRecordsMatched="0"` with zero records — a successful empty
  response, not an error.
- Paging: `startPosition` / `maxRecords` behave as the capabilities
  document states (to confirm at validation: the fleet's paging defaults).

## Failure behavior

- Malformed filter → the service returns an exception report
  (`ows:ExceptionReport`), not a partial result set; the client must
  surface it.
- Unknown output schema → exception report; the client falls back to a
  schema the capabilities document advertises.
- To confirm at validation: the exact CSW endpoint path on GeoNetwork
  4.4.12 (standard surface: `{base}/srv/eng/csw`), and the paging
  defaults.

## Versions note

GeoNetwork 4.4.12 per the fleet seed. CSW request shapes above are the
CSW 2.0.2 standard surface; endpoint path and paging defaults are
design-only until a validation run proves them against a live 4.4.12
instance.
