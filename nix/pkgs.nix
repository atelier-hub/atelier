{ inputs, system }:
import inputs.haskell-nix.inputs.nixpkgs {
  inherit system;
  overlays = [
    inputs.iohk-nix.overlays.crypto
    inputs.iohk-nix.overlays.haskell-nix-crypto
    inputs.haskell-nix.overlay
  ];
  inherit (inputs.haskell-nix) config;
}
