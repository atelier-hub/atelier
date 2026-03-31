{ system
  , compiler
  , flags
  , pkgs
  , hsPkgs
  , pkgconfPkgs
  , errorHandler
  , config
  , ... }:
  ({
    flags = {};
    package = {
      specVersion = "1.10";
      identifier = { name = "hpke"; version = "0.0.0"; };
      license = "BSD-3-Clause";
      copyright = "";
      maintainer = "kazu@iij.ad.jp";
      author = "Kazu Yamamoto";
      homepage = "";
      url = "";
      synopsis = "Hybrid Public Key Encryption";
      description = "Hybrid Public Key Encryption defined in RFC9180";
      buildType = "Simple";
    };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."base16-bytestring" or (errorHandler.buildDepError "base16-bytestring"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
          (hsPkgs."memory" or (errorHandler.buildDepError "memory"))
        ];
        buildable = true;
      };
      tests = {
        "spec" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."QuickCheck" or (errorHandler.buildDepError "QuickCheck"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."base16-bytestring" or (errorHandler.buildDepError "base16-bytestring"))
            (hsPkgs."hpke" or (errorHandler.buildDepError "hpke"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
          ];
          build-tools = [
            (hsPkgs.pkgsBuildBuild.hspec-discover.components.exes.hspec-discover or (pkgs.pkgsBuildBuild.hspec-discover or (errorHandler.buildToolDepError "hspec-discover:hspec-discover")))
          ];
          buildable = true;
        };
      };
    };
  } // {
    src = pkgs.lib.mkDefault (pkgs.fetchurl {
      url = "http://hackage.haskell.org/package/hpke-0.0.0.tar.gz";
      sha256 = "7b0b7dfb4f7081beab54c4cb0cb3df3f3c03ce05cb11747f190bab22df19b83c";
    });
  }) // {
    package-description-override = "cabal-version:      >=1.10\r\nname:               hpke\r\nversion:            0.0.0\r\nx-revision: 1\r\nlicense:            BSD3\r\nlicense-file:       LICENSE\r\nmaintainer:         kazu@iij.ad.jp\r\nauthor:             Kazu Yamamoto\r\nsynopsis:           Hybrid Public Key Encryption\r\ndescription:\r\n    Hybrid Public Key Encryption defined in RFC9180\r\n\r\ncategory:           Cryptography\r\nbuild-type:         Simple\r\nextra-source-files: ChangeLog.md\r\n\r\nlibrary\r\n    exposed-modules:  Crypto.HPKE\r\n                      Crypto.HPKE.Internal\r\n    other-modules:    Crypto.HPKE.AEAD\r\n                      Crypto.HPKE.Context\r\n                      Crypto.HPKE.ID\r\n                      Crypto.HPKE.KDF\r\n                      Crypto.HPKE.KEM\r\n                      Crypto.HPKE.KeyPair\r\n                      Crypto.HPKE.KeySchedule\r\n                      Crypto.HPKE.PublicKey\r\n                      Crypto.HPKE.Setup\r\n                      Crypto.HPKE.Types\r\n    default-language: Haskell2010\r\n    ghc-options:      -Wall\r\n    build-depends:\r\n        base >=4.7 && <5,\r\n        base16-bytestring,\r\n        bytestring,\r\n        crypton >= 1.0.2 && < 1.1,\r\n        memory\r\n\r\n    default-extensions: Strict StrictData\r\n\r\ntest-suite spec\r\n    type:               exitcode-stdio-1.0\r\n    main-is:            Spec.hs\r\n    build-tool-depends: hspec-discover:hspec-discover\r\n    hs-source-dirs:     test\r\n    other-modules:      A1Spec\r\n                        A2Spec\r\n                        A3Spec\r\n                        A4Spec\r\n                        A5Spec\r\n                        A6Spec\r\n                        Test\r\n\r\n    default-language:   Haskell2010\r\n    default-extensions: Strict StrictData\r\n    ghc-options:        -Wall -threaded -rtsopts\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        QuickCheck,\r\n        bytestring,\r\n        base16-bytestring,\r\n        hpke,\r\n        hspec\r\n";
  }