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

    # PostgreSQL: local dev database
    postgres = {
      type = "app";
      program = "${pkgs.writeShellScript "postgres-app" ''
        set -e
        PGDATA="$PWD/postgres-data"
        PGHOST="$PWD/postgres-data"

        # Initialize database if it doesn't exist
        if [ ! -d "$PGDATA" ]; then
          echo "Initializing PostgreSQL database in $PGDATA..."
          ${pkgs.postgresql}/bin/initdb -D "$PGDATA" --no-locale --encoding=UTF8

          # Configure for local socket-only access
          cat >> "$PGDATA/postgresql.conf" <<EOF
        unix_socket_directories = '$PGHOST'
        listen_addresses = '''
        port = 5432
        EOF

          echo "Database initialized!"

          # Start postgres temporarily to create roles and databases
          ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" -o "-k $PGHOST" -w start

          # Create postgres role (superuser for dev convenience)
          ${pkgs.postgresql}/bin/createuser -h "$PGHOST" -s postgres

          # Create hoard_dev database
          ${pkgs.postgresql}/bin/createdb -h "$PGHOST" -U postgres hoard_dev

          # Stop postgres
          ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" stop

          echo "Created postgres role and hoard_dev database!"
        fi

        echo "Starting PostgreSQL..."
        echo "Connection info:"
        echo "  Socket: $PGHOST/.s.PGSQL.5432"
        echo "  Database: hoard_dev"
        echo "  User: postgres (no password needed)"
        echo ""
        echo "To connect: psql -h $PGHOST -U postgres hoard_dev"
        echo "Press Ctrl+C to stop"
        echo ""

        # Start postgres
        ${pkgs.postgresql}/bin/postgres -D "$PGDATA" -k "$PGHOST"
      ''}";
    };
  };

  # Checks
  checks = projectFlake.checks // {
    git-hooks = gitHooks;
  };
}
