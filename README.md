# GeoNetwork Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **GeoNetwork cookbook** for spatial metadata catalogs, harvesting, and CSW search. Patterns are drawn from the ZQM fleet's GeoNetwork 4.4.12 installs (Jetty bundle, port 8082) on all three Windows nodes, including its Elasticsearch index pairing on Node-3 and Node-4. It is intended for Data managers and catalog builders who publish discoverable metadata for geospatial assets. Validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — four design-stage examples with shell/fixture contracts. CI validates syntax, fixture structure, and HTTP failure handling; GeoNetwork/Elasticsearch endpoint behavior remains unverified on the fleet.

**What this repository is:** GeoNetwork patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Data managers and catalog builders who publish discoverable metadata for geospatial assets.

## Prerequisites

- GeoNetwork 4.4.12 (Jetty bundle)
- Java 21 runtime
- Elasticsearch for the index pass (see elasticsearch-cookbook)

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------|----------------------|
| 01 | [01-record-create](examples/01-record-create/README.md) | Written; API validation pending | Creating and validating ISO metadata records |
| 02 | [02-harvest](examples/02-harvest/README.md) | Setup/list only; run/status pending | Harvesting remote catalogs on a schedule |
| 03 | [03-csw-search](examples/03-csw-search/README.md) | Written; endpoint validation pending | CSW search patterns for clients |
| 04 | [04-es-index](examples/04-es-index/README.md) | Written; mapping validation pending | The GeoNetwork → Elasticsearch indices: gn-records, gn-features, gn-searchlogs |

## Repository layout

```text
geonetwork-cookbook/
├── examples/          # four design-stage patterns with explicit runtime gates
├── tests/             # fixture and HTTP safety contracts
└── .github/workflows/ # shell/XML/JSON/contract CI
├── README.md
└── LICENSE
```

## Roadmap

- Validate record create/read-back and CSW query response schemas against GeoNetwork 4.4.12.
- Confirm harvester run/status endpoint spellings before adding automated run commands.
- Verify Elasticsearch mappings and the Node-3/Node-4 index scope before asserting index-level behavior.

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [elasticsearch-cookbook](https://github.com/ZQM-Computing/elasticsearch-cookbook) — Single-node search indices, mappings, and queries
- [stac-cookbook](https://github.com/ZQM-Computing/stac-cookbook) — STAC catalog creation, item validation, search API, bulk ops
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
