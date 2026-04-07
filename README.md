# Atelier

A Haskell library providing foundational infrastructure for effect-based applications.

## Libraries

### `atelier`

Core effects and utilities built on [Effectful](https://github.com/haskell-effectful/effectful):

| Module | Purpose |
|---|---|
| `Atelier.Component` | Structured component lifecycle (`setup → listeners → start`) |
| `Atelier.Config` | Configuration with environment variable overrides |
| `Atelier.Effects.Log` | Structured logging with hierarchical namespaces |
| `Atelier.Effects.Conc` | Thread management via Ki (structured concurrency) |
| `Atelier.Effects.DB` | Relational database access via Rel8/Hasql |
| `Atelier.Effects.Cache` | Caching with singleflight deduplication |
| `Atelier.Effects.Publishing` | Event publishing |
| `Atelier.Effects.Monitoring.*` | OpenTelemetry tracing and Prometheus metrics |

### `atelier-prelude`

Custom prelude based on [relude](https://github.com/kowainik/relude), enforcing Effectful conventions.

### `atelier-testing`

Test utilities for database-backed tests using [tmp-postgres](https://github.com/jfischoff/tmp-postgres).

### `ghcib`

A GHCi-based incremental build daemon. Watches source files, triggers reloads, and exposes build state over a Unix socket. See `ghcib/` for details.

## Development

Enter the dev shell:

```bash
nix develop
```

Build and run tests:

```bash
cabal build all
cabal test all
```

Run the ghcib daemon:

```bash
cabal run ghcib-exe -- start
```
