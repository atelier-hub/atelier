packages: {
  default = final: _: {
    inherit (packages.${final.stdenv.system})
      atelier-prelude
      atelier-core
      atelier-db
      atelier-testing
      ;
  };
}
