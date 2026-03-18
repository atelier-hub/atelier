module Atelier.Effects.Clock
    ( Clock
    , currentTime
    , runClock
    , runClockConst
    ) where

import Data.Time (UTCTime, getCurrentTime)
import Effectful (Effect, IOE)
import Effectful.Dispatch.Dynamic (interpret_)
import Effectful.TH (makeEffect)


data Clock :: Effect where
    CurrentTime :: Clock m UTCTime


makeEffect ''Clock


runClock :: (IOE :> es) => Eff (Clock : es) a -> Eff es a
runClock = interpret_ $ \(CurrentTime) -> liftIO getCurrentTime


runClockConst :: UTCTime -> Eff (Clock : es) a -> Eff es a
runClockConst time = interpret_ $ \CurrentTime -> pure time
