{ system
  , compiler
  , flags
  , pkgs
  , hsPkgs
  , pkgconfPkgs
  , errorHandler
  , config
  , ... }:
  {
    flags = {};
    package = {
      specVersion = "2.0";
      identifier = { name = "rel8"; version = "1.7.0.0"; };
      license = "BSD-3-Clause";
      copyright = "";
      maintainer = "ollie@ocharles.org.uk";
      author = "Oliver Charles";
      homepage = "https://github.com/circuithub/rel8";
      url = "";
      synopsis = "Hey! Hey! Can u rel8?";
      description = "";
      buildType = "Simple";
      isLocal = true;
      detailLevel = "FullDetails";
      licenseFiles = [ "LICENSE" ];
      dataDir = ".";
      dataFiles = [];
      extraSrcFiles = [];
      extraTmpFiles = [];
      extraDocFiles = [ "README.md" "Changelog.md" ];
    };
    components = {
      "library" = {
        depends = [
          (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
          (hsPkgs."attoparsec" or (errorHandler.buildDepError "attoparsec"))
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."base16" or (errorHandler.buildDepError "base16"))
          (hsPkgs."base-compat" or (errorHandler.buildDepError "base-compat"))
          (hsPkgs."bifunctors" or (errorHandler.buildDepError "bifunctors"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."case-insensitive" or (errorHandler.buildDepError "case-insensitive"))
          (hsPkgs."comonad" or (errorHandler.buildDepError "comonad"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."contravariant" or (errorHandler.buildDepError "contravariant"))
          (hsPkgs."hasql" or (errorHandler.buildDepError "hasql"))
          (hsPkgs."iproute" or (errorHandler.buildDepError "iproute"))
          (hsPkgs."opaleye" or (errorHandler.buildDepError "opaleye"))
          (hsPkgs."postgresql-binary" or (errorHandler.buildDepError "postgresql-binary"))
          (hsPkgs."pretty" or (errorHandler.buildDepError "pretty"))
          (hsPkgs."profunctors" or (errorHandler.buildDepError "profunctors"))
          (hsPkgs."product-profunctors" or (errorHandler.buildDepError "product-profunctors"))
          (hsPkgs."scientific" or (errorHandler.buildDepError "scientific"))
          (hsPkgs."semialign" or (errorHandler.buildDepError "semialign"))
          (hsPkgs."semigroupoids" or (errorHandler.buildDepError "semigroupoids"))
          (hsPkgs."text" or (errorHandler.buildDepError "text"))
          (hsPkgs."these" or (errorHandler.buildDepError "these"))
          (hsPkgs."time" or (errorHandler.buildDepError "time"))
          (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
          (hsPkgs."utf8-string" or (errorHandler.buildDepError "utf8-string"))
          (hsPkgs."uuid" or (errorHandler.buildDepError "uuid"))
          (hsPkgs."vector" or (errorHandler.buildDepError "vector"))
        ];
        buildable = true;
        modules = [
          "Rel8/Aggregate"
          "Rel8/Aggregate/Fold"
          "Rel8/Aggregate/Function"
          "Rel8/Aggregate/Range"
          "Rel8/Column"
          "Rel8/Column/ADT"
          "Rel8/Column/Either"
          "Rel8/Column/Lift"
          "Rel8/Column/List"
          "Rel8/Column/Maybe"
          "Rel8/Column/NonEmpty"
          "Rel8/Column/Null"
          "Rel8/Column/These"
          "Rel8/Data/Range"
          "Rel8/Expr"
          "Rel8/Expr/Aggregate"
          "Rel8/Expr/Array"
          "Rel8/Expr/Bool"
          "Rel8/Expr/Default"
          "Rel8/Expr/Eq"
          "Rel8/Expr/Function"
          "Rel8/Expr/List"
          "Rel8/Expr/NonEmpty"
          "Rel8/Expr/Null"
          "Rel8/Expr/Opaleye"
          "Rel8/Expr/Ord"
          "Rel8/Expr/Order"
          "Rel8/Expr/Range"
          "Rel8/Expr/Read"
          "Rel8/Expr/Sequence"
          "Rel8/Expr/Serialize"
          "Rel8/Expr/Show"
          "Rel8/Expr/Subscript"
          "Rel8/Expr/Window"
          "Rel8/FCF"
          "Rel8/Kind/Algebra"
          "Rel8/Kind/Context"
          "Rel8/Generic/Construction"
          "Rel8/Generic/Construction/ADT"
          "Rel8/Generic/Construction/Record"
          "Rel8/Generic/Map"
          "Rel8/Generic/Record"
          "Rel8/Generic/Rel8able"
          "Rel8/Generic/Table"
          "Rel8/Generic/Table/ADT"
          "Rel8/Generic/Table/Record"
          "Rel8/Order"
          "Rel8/Query"
          "Rel8/Query/Aggregate"
          "Rel8/Query/Distinct"
          "Rel8/Query/Each"
          "Rel8/Query/Either"
          "Rel8/Query/Evaluate"
          "Rel8/Query/Exists"
          "Rel8/Query/Filter"
          "Rel8/Query/Function"
          "Rel8/Query/Indexed"
          "Rel8/Query/Limit"
          "Rel8/Query/List"
          "Rel8/Query/Loop"
          "Rel8/Query/Materialize"
          "Rel8/Query/Maybe"
          "Rel8/Query/Null"
          "Rel8/Query/Opaleye"
          "Rel8/Query/Order"
          "Rel8/Query/Rebind"
          "Rel8/Query/Set"
          "Rel8/Query/SQL"
          "Rel8/Query/These"
          "Rel8/Query/Values"
          "Rel8/Query/Window"
          "Rel8/Schema/Context/Nullify"
          "Rel8/Schema/Dict"
          "Rel8/Schema/Escape"
          "Rel8/Schema/Field"
          "Rel8/Schema/HTable"
          "Rel8/Schema/HTable/Either"
          "Rel8/Schema/HTable/Identity"
          "Rel8/Schema/HTable/Label"
          "Rel8/Schema/HTable/List"
          "Rel8/Schema/HTable/MapTable"
          "Rel8/Schema/HTable/Maybe"
          "Rel8/Schema/HTable/NonEmpty"
          "Rel8/Schema/HTable/Nullify"
          "Rel8/Schema/HTable/Product"
          "Rel8/Schema/HTable/These"
          "Rel8/Schema/HTable/Vectorize"
          "Rel8/Schema/Kind"
          "Rel8/Schema/Name"
          "Rel8/Schema/Null"
          "Rel8/Schema/QualifiedName"
          "Rel8/Schema/Result"
          "Rel8/Schema/Spec"
          "Rel8/Schema/Table"
          "Rel8/Statement"
          "Rel8/Statement/Delete"
          "Rel8/Statement/Insert"
          "Rel8/Statement/OnConflict"
          "Rel8/Statement/Prepared"
          "Rel8/Statement/Returning"
          "Rel8/Statement/Rows"
          "Rel8/Statement/Run"
          "Rel8/Statement/Select"
          "Rel8/Statement/Set"
          "Rel8/Statement/SQL"
          "Rel8/Statement/Update"
          "Rel8/Statement/Using"
          "Rel8/Statement/View"
          "Rel8/Statement/Where"
          "Rel8/Table"
          "Rel8/Table/ADT"
          "Rel8/Table/Aggregate"
          "Rel8/Table/Aggregate/Maybe"
          "Rel8/Table/Alternative"
          "Rel8/Table/Bool"
          "Rel8/Table/Cols"
          "Rel8/Table/Either"
          "Rel8/Table/Eq"
          "Rel8/Table/HKD"
          "Rel8/Table/List"
          "Rel8/Table/Maybe"
          "Rel8/Table/Name"
          "Rel8/Table/NonEmpty"
          "Rel8/Table/Null"
          "Rel8/Table/Nullify"
          "Rel8/Table/Opaleye"
          "Rel8/Table/Ord"
          "Rel8/Table/Order"
          "Rel8/Table/Projection"
          "Rel8/Table/Rel8able"
          "Rel8/Table/Serialize"
          "Rel8/Table/These"
          "Rel8/Table/Transpose"
          "Rel8/Table/Undefined"
          "Rel8/Table/Window"
          "Rel8/Type"
          "Rel8/Type/Array"
          "Rel8/Type/Builder/ByteString"
          "Rel8/Type/Builder/Fold"
          "Rel8/Type/Builder/Time"
          "Rel8/Type/Composite"
          "Rel8/Type/Decimal"
          "Rel8/Type/Decoder"
          "Rel8/Type/Eq"
          "Rel8/Type/Encoder"
          "Rel8/Type/Enum"
          "Rel8/Type/Information"
          "Rel8/Type/JSONEncoded"
          "Rel8/Type/JSONBEncoded"
          "Rel8/Type/Monoid"
          "Rel8/Type/Name"
          "Rel8/Type/Nullable"
          "Rel8/Type/Num"
          "Rel8/Type/Ord"
          "Rel8/Type/Parser"
          "Rel8/Type/Parser/ByteString"
          "Rel8/Type/Parser/Time"
          "Rel8/Type/Range"
          "Rel8/Type/ReadShow"
          "Rel8/Type/Semigroup"
          "Rel8/Type/String"
          "Rel8/Type/Sum"
          "Rel8/Type/Tag"
          "Rel8/Window"
          "Rel8"
          "Rel8/Array"
          "Rel8/Decoder"
          "Rel8/Encoder"
          "Rel8/Expr/Num"
          "Rel8/Expr/Text"
          "Rel8/Expr/Time"
          "Rel8/Range"
          "Rel8/Table/Verify"
          "Rel8/Tabulate"
        ];
        hsSourceDirs = [ "src" ];
      };
      tests = {
        "tests" = {
          depends = [
            (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."case-insensitive" or (errorHandler.buildDepError "case-insensitive"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."hasql" or (errorHandler.buildDepError "hasql"))
            (hsPkgs."hasql-transaction" or (errorHandler.buildDepError "hasql-transaction"))
            (hsPkgs."hedgehog" or (errorHandler.buildDepError "hedgehog"))
            (hsPkgs."mmorph" or (errorHandler.buildDepError "mmorph"))
            (hsPkgs."iproute" or (errorHandler.buildDepError "iproute"))
            (hsPkgs."rel8" or (errorHandler.buildDepError "rel8"))
            (hsPkgs."scientific" or (errorHandler.buildDepError "scientific"))
            (hsPkgs."tasty" or (errorHandler.buildDepError "tasty"))
            (hsPkgs."tasty-hedgehog" or (errorHandler.buildDepError "tasty-hedgehog"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."these" or (errorHandler.buildDepError "these"))
            (hsPkgs."time" or (errorHandler.buildDepError "time"))
            (hsPkgs."tmp-postgres" or (errorHandler.buildDepError "tmp-postgres"))
            (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
            (hsPkgs."uuid" or (errorHandler.buildDepError "uuid"))
            (hsPkgs."vector" or (errorHandler.buildDepError "vector"))
          ];
          buildable = true;
          modules = [ "Rel8/Generic/Rel8able/Test" ];
          hsSourceDirs = [ "tests" ];
          mainPath = [ "Main.hs" ];
        };
      };
    };
  } // {
    src = pkgs.lib.mkDefault (pkgs.fetchgit {
      url = "1";
      rev = "minimal";
      sha256 = "";
    }) // {
      url = "1";
      rev = "minimal";
      sha256 = "";
    };
  }