{
  pkgs,
  project,
  gitHooks,
  tools,
}:
let
  inherit (project.args) compiler-nix-name;

  # System tools not tied to GHC version
  systemTools =
    builtins.attrValues tools
    ++ (with pkgs; [
      nixfmt
      postgresql
      pre-commit
    ]);
in
project.shellFor {
  name = "atelier-shell-${compiler-nix-name}";

  # Include local packages. All first-party packages must be listed so the
  # shell prebuilds the union of their dependency closures into the package db,
  # so `cabal build all` doesn't recompile deps unique to atelier-db (rel8,
  # tmp-postgres) and atelier-testing (hedgehog, hspec-hedgehog) from source.
  packages = ps: [
    ps.atelier-prelude
    ps.atelier-core
    ps.atelier-db
    ps.atelier-testing
  ];

  # Enable Hoogle documentation
  withHoogle = true;

  buildInputs = systemTools;

  tools = {
    cabal = "latest";
    haskell-language-server = "latest";
    ghcid = "latest";
    tasty-discover = "latest";
    weeder = "latest";
  };

  shellHook = ''
    # Git hooks integration
    ${gitHooks.shellHook}
  '';
}
