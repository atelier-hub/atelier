# Atelier

Reusable Haskell libraries built on Effectful: `atelier-prelude`, `atelier-core`,
`atelier-db`, `atelier-testing` (in dependency order).

- `.cabal` files are generated from `package.nix` via hpack — edit `package.nix`, not
  the `.cabal` files. Shared hpack metadata lives in `nix/package/`.
- haskell.nix builds are materialized under `nix/materialized/`. Changing
  dependencies, `cabal.project`, `nix/project.nix`, or `flake.lock` requires
  regenerating materialization (see the hint printed by `nix build`).
- Each package builds independently; keep cross-package coupling at the library
  level only (`atelier-db`/`atelier-testing` must not be required to build the others).

See `CONTRIBUTING.md` for project conventions and workflow.
