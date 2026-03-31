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
    flags = { devel = false; };
    package = {
      specVersion = "1.10";
      identifier = { name = "tls"; version = "2.2.2"; };
      license = "BSD-3-Clause";
      copyright = "Vincent Hanquez <vincent@snarc.org>";
      maintainer = "Kazu Yamamoto <kazu@iij.ad.jp>";
      author = "Vincent Hanquez <vincent@snarc.org>";
      homepage = "https://github.com/haskell-tls/hs-tls";
      url = "";
      synopsis = "TLS protocol native implementation";
      description = "Native Haskell TLS 1.2/1.3 protocol implementation for servers and clients.";
      buildType = "Simple";
    };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."base16-bytestring" or (errorHandler.buildDepError "base16-bytestring"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."cereal" or (errorHandler.buildDepError "cereal"))
          (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
          (hsPkgs."crypton-asn1-encoding" or (errorHandler.buildDepError "crypton-asn1-encoding"))
          (hsPkgs."crypton-asn1-types" or (errorHandler.buildDepError "crypton-asn1-types"))
          (hsPkgs."crypton-x509" or (errorHandler.buildDepError "crypton-x509"))
          (hsPkgs."crypton-x509-store" or (errorHandler.buildDepError "crypton-x509-store"))
          (hsPkgs."crypton-x509-validation" or (errorHandler.buildDepError "crypton-x509-validation"))
          (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
          (hsPkgs."ech-config" or (errorHandler.buildDepError "ech-config"))
          (hsPkgs."hpke" or (errorHandler.buildDepError "hpke"))
          (hsPkgs."memory" or (errorHandler.buildDepError "memory"))
          (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
          (hsPkgs."network" or (errorHandler.buildDepError "network"))
          (hsPkgs."random" or (errorHandler.buildDepError "random"))
          (hsPkgs."serialise" or (errorHandler.buildDepError "serialise"))
          (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
          (hsPkgs."unix-time" or (errorHandler.buildDepError "unix-time"))
          (hsPkgs."zlib" or (errorHandler.buildDepError "zlib"))
        ];
        buildable = true;
      };
      exes = {
        "tls-server" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."base16-bytestring" or (errorHandler.buildDepError "base16-bytestring"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
            (hsPkgs."crypton-x509-store" or (errorHandler.buildDepError "crypton-x509-store"))
            (hsPkgs."crypton-x509-system" or (errorHandler.buildDepError "crypton-x509-system"))
            (hsPkgs."ech-config" or (errorHandler.buildDepError "ech-config"))
            (hsPkgs."network" or (errorHandler.buildDepError "network"))
            (hsPkgs."network-run" or (errorHandler.buildDepError "network-run"))
            (hsPkgs."tls" or (errorHandler.buildDepError "tls"))
          ];
          buildable = if flags.devel then true else false;
        };
        "tls-client" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."base16-bytestring" or (errorHandler.buildDepError "base16-bytestring"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
            (hsPkgs."crypton-x509-store" or (errorHandler.buildDepError "crypton-x509-store"))
            (hsPkgs."crypton-x509-system" or (errorHandler.buildDepError "crypton-x509-system"))
            (hsPkgs."ech-config" or (errorHandler.buildDepError "ech-config"))
            (hsPkgs."network" or (errorHandler.buildDepError "network"))
            (hsPkgs."network-run" or (errorHandler.buildDepError "network-run"))
            (hsPkgs."tls" or (errorHandler.buildDepError "tls"))
          ];
          buildable = if flags.devel then true else false;
        };
      };
      tests = {
        "spec" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."QuickCheck" or (errorHandler.buildDepError "QuickCheck"))
            (hsPkgs."async" or (errorHandler.buildDepError "async"))
            (hsPkgs."base64-bytestring" or (errorHandler.buildDepError "base64-bytestring"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
            (hsPkgs."crypton-asn1-types" or (errorHandler.buildDepError "crypton-asn1-types"))
            (hsPkgs."crypton-x509" or (errorHandler.buildDepError "crypton-x509"))
            (hsPkgs."crypton-x509-validation" or (errorHandler.buildDepError "crypton-x509-validation"))
            (hsPkgs."ech-config" or (errorHandler.buildDepError "ech-config"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."serialise" or (errorHandler.buildDepError "serialise"))
            (hsPkgs."time-hourglass" or (errorHandler.buildDepError "time-hourglass"))
            (hsPkgs."tls" or (errorHandler.buildDepError "tls"))
          ];
          build-tools = [
            (hsPkgs.pkgsBuildBuild.hspec-discover.components.exes.hspec-discover or (pkgs.pkgsBuildBuild.hspec-discover or (errorHandler.buildToolDepError "hspec-discover:hspec-discover")))
          ];
          buildable = true;
        };
      };
      benchmarks = {
        "tls-bench" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."QuickCheck" or (errorHandler.buildDepError "QuickCheck"))
            (hsPkgs."async" or (errorHandler.buildDepError "async"))
            (hsPkgs."base64-bytestring" or (errorHandler.buildDepError "base64-bytestring"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."crypton" or (errorHandler.buildDepError "crypton"))
            (hsPkgs."crypton-asn1-types" or (errorHandler.buildDepError "crypton-asn1-types"))
            (hsPkgs."crypton-x509" or (errorHandler.buildDepError "crypton-x509"))
            (hsPkgs."crypton-x509-store" or (errorHandler.buildDepError "crypton-x509-store"))
            (hsPkgs."crypton-x509-validation" or (errorHandler.buildDepError "crypton-x509-validation"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."ech-config" or (errorHandler.buildDepError "ech-config"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."network" or (errorHandler.buildDepError "network"))
            (hsPkgs."network-run" or (errorHandler.buildDepError "network-run"))
            (hsPkgs."serialise" or (errorHandler.buildDepError "serialise"))
            (hsPkgs."tasty-bench" or (errorHandler.buildDepError "tasty-bench"))
            (hsPkgs."time-hourglass" or (errorHandler.buildDepError "time-hourglass"))
            (hsPkgs."tls" or (errorHandler.buildDepError "tls"))
          ];
          buildable = true;
        };
      };
    };
  } // {
    src = pkgs.lib.mkDefault (pkgs.fetchurl {
      url = "http://hackage.haskell.org/package/tls-2.2.2.tar.gz";
      sha256 = "d9536a25925fdd6872c80fa550691636167efda482cd1085e3ab81c91cd332e1";
    });
  }) // {
    package-description-override = "cabal-version:      >=1.10\r\nname:               tls\r\nversion:            2.2.2\r\nx-revision: 1\r\nlicense:            BSD3\r\nlicense-file:       LICENSE\r\ncopyright:          Vincent Hanquez <vincent@snarc.org>\r\nmaintainer:         Kazu Yamamoto <kazu@iij.ad.jp>\r\nauthor:             Vincent Hanquez <vincent@snarc.org>\r\nhomepage:           https://github.com/haskell-tls/hs-tls\r\nsynopsis:           TLS protocol native implementation\r\ndescription:\r\n    Native Haskell TLS 1.2/1.3 protocol implementation for servers and clients.\r\n\r\ncategory:           Network\r\nbuild-type:         Simple\r\nextra-source-files:\r\n    test/*.hs\r\n    CHANGELOG.md\r\n\r\nsource-repository head\r\n    type:     git\r\n    location: https://github.com/haskell-tls/hs-tls\r\n    subdir:   tls\r\n\r\nflag devel\r\n    description: Development commands\r\n    default:     False\r\n\r\nlibrary\r\n    exposed-modules:\r\n        Network.TLS\r\n        Network.TLS.Cipher\r\n        Network.TLS.Compression\r\n        Network.TLS.Internal\r\n        Network.TLS.Extra\r\n        Network.TLS.Extra.Cipher\r\n        Network.TLS.Extra.FFDHE\r\n        Network.TLS.QUIC\r\n\r\n    other-modules:\r\n        Network.TLS.Struct\r\n        Network.TLS.Struct13\r\n        Network.TLS.Core\r\n        Network.TLS.Context\r\n        Network.TLS.Context.Internal\r\n        Network.TLS.Credentials\r\n        Network.TLS.Backend\r\n        Network.TLS.Crypto\r\n        Network.TLS.Crypto.DH\r\n        Network.TLS.Crypto.IES\r\n        Network.TLS.Crypto.Types\r\n        Network.TLS.ErrT\r\n        Network.TLS.Error\r\n        Network.TLS.Extension\r\n        Network.TLS.Handshake\r\n        Network.TLS.Handshake.Certificate\r\n        Network.TLS.Handshake.Client\r\n        Network.TLS.Handshake.Client.ClientHello\r\n        Network.TLS.Handshake.Client.Common\r\n        Network.TLS.Handshake.Client.ServerHello\r\n        Network.TLS.Handshake.Client.TLS12\r\n        Network.TLS.Handshake.Client.TLS13\r\n        Network.TLS.Handshake.Common\r\n        Network.TLS.Handshake.Common13\r\n        Network.TLS.Handshake.Control\r\n        Network.TLS.Handshake.Key\r\n        Network.TLS.Handshake.Random\r\n        Network.TLS.Handshake.Server\r\n        Network.TLS.Handshake.Server.ClientHello\r\n        Network.TLS.Handshake.Server.ClientHello12\r\n        Network.TLS.Handshake.Server.ClientHello13\r\n        Network.TLS.Handshake.Server.Common\r\n        Network.TLS.Handshake.Server.ServerHello12\r\n        Network.TLS.Handshake.Server.ServerHello13\r\n        Network.TLS.Handshake.Server.TLS12\r\n        Network.TLS.Handshake.Server.TLS13\r\n        Network.TLS.Handshake.Signature\r\n        Network.TLS.Handshake.State\r\n        Network.TLS.Handshake.State13\r\n        Network.TLS.Handshake.TranscriptHash\r\n        Network.TLS.HashAndSignature\r\n        Network.TLS.Hooks\r\n        Network.TLS.IO\r\n        Network.TLS.IO.Decode\r\n        Network.TLS.IO.Encode\r\n        Network.TLS.Imports\r\n        Network.TLS.KeySchedule\r\n        Network.TLS.MAC\r\n        Network.TLS.Measurement\r\n        Network.TLS.Packet\r\n        Network.TLS.Packet13\r\n        Network.TLS.Parameters\r\n        Network.TLS.PostHandshake\r\n        Network.TLS.RNG\r\n        Network.TLS.Record\r\n        Network.TLS.Record.Decrypt\r\n        Network.TLS.Record.Encrypt\r\n        Network.TLS.Record.Layer\r\n        Network.TLS.Record.Recv\r\n        Network.TLS.Record.Send\r\n        Network.TLS.Record.State\r\n        Network.TLS.Record.Types\r\n        Network.TLS.Session\r\n        Network.TLS.State\r\n        Network.TLS.Types\r\n        Network.TLS.Types.Cipher\r\n        Network.TLS.Types.Secret\r\n        Network.TLS.Types.Session\r\n        Network.TLS.Types.Version\r\n        Network.TLS.Util\r\n        Network.TLS.Util.ASN1\r\n        Network.TLS.Util.Serialization\r\n        Network.TLS.Wire\r\n        Network.TLS.X509\r\n\r\n    default-language:   Haskell2010\r\n    default-extensions: Strict StrictData\r\n    ghc-options:        -Wall\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        base16-bytestring,\r\n        bytestring >=0.10 && <0.13,\r\n        cereal >=0.5.3 && <0.6,\r\n        crypton >=0.34 && <1.1,\r\n        crypton-asn1-encoding >= 0.10.0 && < 0.11,\r\n        crypton-asn1-types >= 0.4.1 && < 0.5,\r\n        crypton-x509 >=1.8 && <1.9,\r\n        crypton-x509-store >=1.8 && <1.9,\r\n        crypton-x509-validation >=1.8 && <1.9,\r\n        data-default,\r\n        ech-config,\r\n        hpke >= 0.0.0 && < 0.1,\r\n        memory >=0.18 && <0.19,\r\n        mtl >=2.2 && <2.4,\r\n        network >=3.1,\r\n        random >=1.2 && <1.4,\r\n        serialise >=0.2 && <0.3,\r\n        transformers >=0.5 && <0.7,\r\n        unix-time >=0.4.11 && <0.5,\r\n        zlib >=0.7 && <0.8\r\n\r\nexecutable tls-server\r\n    main-is:            tls-server.hs\r\n    hs-source-dirs:     util\r\n    other-modules:\r\n        Common\r\n        Server\r\n        Imports\r\n\r\n    default-language:   Haskell2010\r\n    default-extensions: Strict StrictData\r\n    ghc-options:        -Wall -threaded -rtsopts\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        base16-bytestring,\r\n        bytestring,\r\n        containers,\r\n        crypton,\r\n        crypton-x509-store,\r\n        crypton-x509-system,\r\n        ech-config,\r\n        network,\r\n        network-run,\r\n        tls\r\n\r\n    if flag(devel)\r\n\r\n    else\r\n        buildable: False\r\n\r\nexecutable tls-client\r\n    main-is:            tls-client.hs\r\n    hs-source-dirs:     util\r\n    other-modules:\r\n        Client\r\n        Common\r\n        Imports\r\n\r\n    default-language:   Haskell2010\r\n    default-extensions: Strict StrictData\r\n    ghc-options:        -Wall -threaded -rtsopts\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        base16-bytestring,\r\n        bytestring,\r\n        crypton,\r\n        crypton-x509-store,\r\n        crypton-x509-system,\r\n        ech-config,\r\n        network,\r\n        network-run >=0.5,\r\n        tls\r\n\r\n    if flag(devel)\r\n\r\n    else\r\n        buildable: False\r\n\r\ntest-suite spec\r\n    type:               exitcode-stdio-1.0\r\n    main-is:            Spec.hs\r\n    build-tool-depends: hspec-discover:hspec-discover\r\n    hs-source-dirs:     test\r\n    other-modules:\r\n        API\r\n        Arbitrary\r\n        Certificate\r\n        CiphersSpec\r\n        ECHSpec\r\n        EncodeSpec\r\n        HandshakeSpec\r\n        PipeChan\r\n        PubKey\r\n        Run\r\n        Session\r\n        ThreadSpec\r\n\r\n    default-language:   Haskell2010\r\n    default-extensions: Strict StrictData\r\n    ghc-options:        -Wall -threaded -rtsopts\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        QuickCheck,\r\n        async,\r\n        base64-bytestring,\r\n        bytestring,\r\n        crypton,\r\n        crypton-asn1-types,\r\n        crypton-x509,\r\n        crypton-x509-validation,\r\n        ech-config,\r\n        hspec,\r\n        serialise,\r\n        time-hourglass,\r\n        tls\r\n\r\nbenchmark tls-bench\r\n    type:             exitcode-stdio-1.0\r\n    main-is:          Benchmarks.hs\r\n    hs-source-dirs:   Benchmarks test\r\n    other-modules:\r\n        API\r\n        Arbitrary\r\n        Certificate\r\n        CiphersSpec\r\n        ECHSpec\r\n        EncodeSpec\r\n        HandshakeSpec\r\n        PipeChan\r\n        PubKey\r\n        Run\r\n        Session\r\n        ThreadSpec\r\n\r\n    default-language: Haskell2010\r\n    ghc-options:      -Wall\r\n    build-depends:\r\n        base >=4.9 && <5,\r\n        QuickCheck,\r\n        async,\r\n        base64-bytestring,\r\n        bytestring,\r\n        containers,\r\n        crypton,\r\n        crypton-asn1-types,\r\n        crypton-x509,\r\n        crypton-x509-store,\r\n        crypton-x509-validation,\r\n        data-default,\r\n        ech-config,\r\n        hspec,\r\n        network,\r\n        network-run,\r\n        serialise,\r\n        tasty-bench,\r\n        time-hourglass,\r\n        tls\r\n";
  }