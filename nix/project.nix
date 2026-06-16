{
  inputs,
  pkgs,
  compiler-nix-name,
}:
let
  nix-hpack = pkgs.callPackage ./package/nix-hpack.nix { };
  # Include the `package.yaml` file for the `haskell-plan-to-nix` step of the
  # build process. When `haskell-plan-to-nix` uses `package.yaml` instead of
  # the raw `.cabal` files, it omits the module paths from the materialized
  # files. By keeping module paths out of our materialized files, we don't have
  # to update materialization for every module we add or remove, only for
  # dependencies.
  src = pkgs.runCommand "src" { } ''
    mkdir -p src
    cp -r ${./..}/* src
    chmod -R +w src
    ls -la src
    (cd src && ${nix-hpack}/bin/nix-hpack --keep)
    mv src $out
  '';
in
pkgs.haskell-nix.cabalProject' {
  inherit src compiler-nix-name;

  # Enable materialization for deterministic builds and better CI caching
  materialized = ./materialized/${pkgs.stdenv.hostPlatform.system}/${compiler-nix-name};
  checkMaterialization = true;

  # Resolve the rel8 source-repository-package against the flake input, so the
  # revision tracks flake.lock and no manual --sha256 is required. rel8 1.7.0.0
  # on Hackage does not build with GHC 9.14 / semialign 1.4; the fork carries
  # the fix pending https://github.com/circuithub/rel8/pull/403.
  inputMap = {
    "https://github.com/cgeorgii/rel8" = inputs.rel8;
  };

  cabalProjectLocal = ''
    source-repository-package
      type: git
      location: https://github.com/jfischoff/tmp-postgres
      tag: ${inputs.tmp-postgres.rev}
      --sha256: 0l1gdx5s8ximgawd3yzfy47pv5pgwqmjqp8hx5rbrq68vr04wkbl

    source-repository-package
      type: git
      location: https://github.com/cgeorgii/rel8
      tag: ${inputs.rel8.rev}
  '';

  # Package-specific configuration
  modules = [
    {
      # Build Haddock (including hyperlinked source) for all packages
      doHaddock = true;

      packages = {
        # Disable tests for tmp-postgres
        tmp-postgres.doCheck = false;

        # Treat warnings as errors in Nix builds (CI), but not in local dev.
        # Applied to every first-party package.
        atelier-prelude.ghcOptions = [ "-Werror" ];
        atelier-core.ghcOptions = [ "-Werror" ];
        atelier-db.ghcOptions = [ "-Werror" ];
        atelier-testing.ghcOptions = [ "-Werror" ];
      };
    }
  ];
}
