# Atelier

A small toolkit of reusable Haskell libraries built on
[Effectful](https://hackage.haskell.org/package/effectful), extracted from the
[tricorder](https://github.com/atelier-hub/tricorder) project.

## Packages

| Package | Description |
|---|---|
| [`atelier-prelude`](atelier-prelude) | Custom [relude](https://hackage.haskell.org/package/relude)-based prelude, adapted for Effectful conventions. |
| [`atelier-core`](atelier-core) | Foundational Effectful-based effects and utilities (logging, observability, configuration, …). |
| [`atelier-db`](atelier-db) | Relational database access via [Hasql](https://hackage.haskell.org/package/hasql) and [Rel8](https://hackage.haskell.org/package/rel8), exposed as an Effectful effect. |
| [`atelier-testing`](atelier-testing) | Database-backed test utilities using [tmp-postgres](https://github.com/jfischoff/tmp-postgres). |

Dependency order: `atelier-prelude` → `atelier-core` → `atelier-db` → `atelier-testing`.

## Development

This is a [haskell.nix](https://github.com/input-output-hk/haskell.nix) flake.

```sh
nix develop            # dev shell with cabal, HLS, ghcid, postgres, git hooks
cabal build all
cabal test all

nix build .#atelier-core     # build a single library (closure only)
nix flake check              # build all libraries, tests, haddock, git hooks
```

Individual packages can be built independently — building `atelier-core` does not
require `atelier-db` or `atelier-testing` to build.

### Observability

A local observability stack (Prometheus, Grafana, Tempo, Loki, Node Exporter) is
available for exercising `atelier-core`'s metrics/tracing:

```sh
nix run .#observability      # start the full stack (config: config/atelier.yaml)
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for project conventions.
