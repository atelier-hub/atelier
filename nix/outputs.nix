{ inputs, system }:
let
  # Initialize package set with haskell.nix
  pkgs = import ./pkgs.nix { inherit inputs system; };

  # Configure haskell.nix project
  project = import ./project.nix { inherit inputs pkgs; };

  # Get the project flake for packages
  projectFlake = project.flake { };

  # Git hooks check (defined once, used in both checks and shell)
  gitHooks = inputs.git-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      hlint.enable = true;
      hlint.package = pkgs.haskellPackages.hlint;
      hpack.enable = true;
      nixfmt-rfc-style.enable = true;
      nixfmt-rfc-style.package = pkgs.nixfmt-rfc-style;
      fourmolu.enable = true;
      fourmolu.package = pkgs.haskellPackages.fourmolu;
    };
  };

  # Import custom app modules
  secretsApps = import ./secrets.nix { inherit pkgs; };
in
{
  # Expose packages built by haskell.nix
  packages = projectFlake.packages // {
    default = projectFlake.packages."hoard:exe:hoard-exe";
  };

  # Development shell
  devShells.default = import ./shell.nix {
    inherit
      inputs
      pkgs
      project
      system
      gitHooks
      ;
  };

  # Custom apps
  apps = {
    # Weeder: detects unused code
    weeder = {
      type = "app";
      program = "${pkgs.writeShellScript "weeder-app" ''
        echo "Building project with HIE files..."
        ${pkgs.cabal-install}/bin/cabal build --ghc-options=-fwrite-ide-info
        echo "Running weeder to detect unused code..."
        ${pkgs.haskellPackages.weeder}/bin/weeder
      ''}";
    };

    # HLint auto-fix
    hlint-fix = {
      type = "app";
      program = "${pkgs.writeShellScript "hlint-fix-app" ''
        echo "Running hlint --refactor on all Haskell files..."
        find src app test -name "*.hs" -exec ${pkgs.haskellPackages.hlint}/bin/hlint --refactor {} \;
        echo "Hlint refactoring complete!"
      ''}";
    };
  }
  # Merge in secrets management apps
  // secretsApps
  # Import postgres app from separate module
  // (import ./postgres.nix { inherit pkgs; });

  # Checks
  checks = projectFlake.checks // {
    git-hooks = gitHooks;
  };
}
