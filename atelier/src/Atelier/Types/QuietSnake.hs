{-# LANGUAGE UndecidableInstances #-}

module Atelier.Types.QuietSnake
    ( QuietSnake (..)
    ) where

import Data.Aeson (FromJSON (..), GFromJSON, Zero, genericParseJSON)
import Data.Aeson.Types (defaultOptions, fieldLabelModifier)
import GHC.Generics (Rep)
import Text.Casing (quietSnake)


-- | Newtype wrapper for deriving FromJSON with quiet_snake_case field names
newtype QuietSnake a = QuietSnake a


instance (GFromJSON Zero (Rep a), Generic a) => FromJSON (QuietSnake a) where
    parseJSON = fmap QuietSnake . genericParseJSON opts
      where
        opts = defaultOptions {fieldLabelModifier = quietSnake}
