module Atelier.Effects.Clock
    ( Clock
    , currentTime
    , currentTimeZone
    , runClock
    , runClockConst
    , runClockState
    ) where

import Data.Time (UTCTime, getCurrentTime)
import Data.Time.LocalTime (TimeZone, getCurrentTimeZone, utc)
import Effectful (Effect, IOE)
import Effectful.Dispatch.Dynamic (interpret_)
import Effectful.State.Static.Shared (State, get)
import Effectful.TH (makeEffect)


data Clock :: Effect where
    CurrentTime :: Clock m UTCTime
    CurrentTimeZone :: Clock m TimeZone


makeEffect ''Clock


runClock :: (IOE :> es) => Eff (Clock : es) a -> Eff es a
runClock = interpret_ $ \case
    CurrentTime -> liftIO getCurrentTime
    CurrentTimeZone -> liftIO getCurrentTimeZone


runClockConst :: UTCTime -> Eff (Clock : es) a -> Eff es a
runClockConst time = interpret_ $ \case
    CurrentTime -> pure time
    CurrentTimeZone -> pure utc


runClockState :: (State UTCTime :> es) => Eff (Clock : es) a -> Eff es a
runClockState = interpret_ $ \case
    CurrentTime -> get
    CurrentTimeZone -> pure utc
