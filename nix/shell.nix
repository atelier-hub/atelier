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
      nixfmt-rfc-style
      postgresql
      sqitchPg
      sops
      age
    ]);
in
project.shellFor {
  name = "hoard-shell-${compiler-nix-name}";

  # Include your local packages
  packages = ps: [ ps.hoard ];

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

    # PostgreSQL configuration
    export PGHOST="$PWD/postgres-data"
    echo "PostgreSQL socket directory: $PGHOST"
  '';
}
