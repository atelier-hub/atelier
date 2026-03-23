{-# OPTIONS_GHC -Wno-orphans #-}

module Atelier.Time
    ( -- * Time units
      TimeUnit
    , Microsecond
    , Millisecond
    , Second
    , Minute
    , Hour

      -- * Conversions
    , nominalDiffTime
    , toMicroseconds
    , convertUnit
    ) where

import Data.Aeson (FromJSON (..))
import Data.Time (NominalDiffTime)
import Data.Time.Units (Hour, Microsecond, Millisecond, Minute, Second, TimeUnit, convertUnit, fromMicroseconds, toMicroseconds)


nominalDiffTime :: (TimeUnit t) => NominalDiffTime -> t
nominalDiffTime = fromMicroseconds . round @Double . (* 1_000_000) . realToFrac


-- Orphan instances for JSON deserialization of time unit types.
-- All time units in Data.Time.Units wrap Integer, so we parse as Integer.

instance FromJSON Microsecond where
    parseJSON = fmap fromInteger . parseJSON


instance FromJSON Millisecond where
    parseJSON = fmap fromInteger . parseJSON


instance FromJSON Second where
    parseJSON = fmap fromInteger . parseJSON


instance FromJSON Minute where
    parseJSON = fmap fromInteger . parseJSON


instance FromJSON Hour where
    parseJSON = fmap fromInteger . parseJSON
