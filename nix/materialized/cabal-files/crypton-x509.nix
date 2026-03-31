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
      identifier = { name = "crypton-x509"; version = "1.8.0"; };
      license = "BSD-3-Clause";
      copyright = "Vincent Hanquez <vincent@snarc.org>";
      maintainer = "Kazu Yamamoto <kazu@iij.ad.jp>";
      author = "Vincent Hanquez <vincent@snarc.org>";
      homepage = "https://github.com/kazu-yamamoto/crypton-certificate";
      url = "";
      synopsis = "X509 reader and writer";
      description = "X509 reader and writer. please see README";
      buildType = "Simple";
    };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
          (hsPkgs."crypton-asn1-encoding" or (errorHandler.buildDepError "crypton-asn1-encoding"))
          (hsPkgs."crypton-asn1-parse" or (errorHandler.buildDepError "crypton-asn1-parse"))
          (hsPkgs."crypton-asn1-types" or (errorHandler.buildDepError "crypton-asn1-types"))
          (hsPkgs."crypton-pem" or (errorHandler.buildDepError "crypton-pem"))
          (hsPkgs."memory" or (errorHandler.buildDepError "memory"))
          (hsPkgs."time-hourglass" or (errorHandler.buildDepError "time-hourglass"))
          (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
        ];
        buildable = true;
      };
      tests = {
        "test-x509" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
            (hsPkgs."crypton-x509" or (errorHandler.buildDepError "crypton-x509"))
            (hsPkgs."crypton-asn1-types" or (errorHandler.buildDepError "crypton-asn1-types"))
            (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
            (hsPkgs."tasty" or (errorHandler.buildDepError "tasty"))
            (hsPkgs."tasty-quickcheck" or (errorHandler.buildDepError "tasty-quickcheck"))
            (hsPkgs."time-hourglass" or (errorHandler.buildDepError "time-hourglass"))
          ];
          buildable = true;
        };
      };
    };
  } // {
    src = pkgs.lib.mkDefault (pkgs.fetchurl {
      url = "http://hackage.haskell.org/package/crypton-x509-1.8.0.tar.gz";
      sha256 = "7ce8c6d12c1dea1096895ca02d0b27dd8f6e0389de2956e9fe11cc22a8f1c2cd";
    });
  }) // {
    package-description-override = "cabal-version:      >=1.10\r\nname:               crypton-x509\r\nversion:            1.8.0\r\nx-revision: 1\r\nlicense:            BSD3\r\nlicense-file:       LICENSE\r\ncopyright:          Vincent Hanquez <vincent@snarc.org>\r\nmaintainer:         Kazu Yamamoto <kazu@iij.ad.jp>\r\nauthor:             Vincent Hanquez <vincent@snarc.org>\r\nstability:          experimental\r\nhomepage:           https://github.com/kazu-yamamoto/crypton-certificate\r\nsynopsis:           X509 reader and writer\r\ndescription:        X509 reader and writer. please see README\r\ncategory:           Data\r\nbuild-type:         Simple\r\nextra-source-files: ChangeLog.md\r\n\r\nsource-repository head\r\n    type:     git\r\n    location: https://github.com/kazu-yamamoto/crypton-certificate\r\n    subdir:   x509\r\n\r\nlibrary\r\n    exposed-modules:\r\n        Data.X509\r\n        Data.X509.EC\r\n\r\n    other-modules:\r\n        Data.X509.Internal\r\n        Data.X509.CertificateChain\r\n        Data.X509.AlgorithmIdentifier\r\n        Data.X509.DistinguishedName\r\n        Data.X509.Cert\r\n        Data.X509.PublicKey\r\n        Data.X509.PrivateKey\r\n        Data.X509.Ext\r\n        Data.X509.ExtensionRaw\r\n        Data.X509.CRL\r\n        Data.X509.OID\r\n        Data.X509.Signed\r\n\r\n    default-language: Haskell2010\r\n    ghc-options:      -Wall\r\n    build-depends:\r\n        base >=4.7 && <5,\r\n        bytestring,\r\n        containers,\r\n        crypton >=0.24 && <1.1,\r\n        crypton-asn1-encoding >=0.10.0 && <0.11,\r\n        crypton-asn1-parse >=0.10.0 && <0.11,\r\n        crypton-asn1-types >=0.4.1 && <0.5,\r\n        crypton-pem >=0.2.4 && <0.4,\r\n        memory,\r\n        time-hourglass,\r\n        transformers >=0.4\r\n\r\ntest-suite test-x509\r\n    type:             exitcode-stdio-1.0\r\n    main-is:          Tests.hs\r\n    hs-source-dirs:   Tests\r\n    default-language: Haskell2010\r\n    ghc-options:      -Wall -fno-warn-orphans -fno-warn-missing-signatures\r\n    build-depends:\r\n        base >=3 && <5,\r\n        bytestring,\r\n        crypton,\r\n        crypton-x509,\r\n        crypton-asn1-types,\r\n        mtl,\r\n        tasty,\r\n        tasty-quickcheck,\r\n        time-hourglass\r\n";
  }