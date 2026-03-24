module Ghcib.Debounce (debounced) where

import Data.Time.Units (TimeUnit, toMicroseconds)
import Effectful.Timeout (Timeout, timeout)

import Atelier.Effects.Chan (Chan, InChan, OutChan)
import Atelier.Effects.Conc (Conc)

import Atelier.Effects.Chan qualified as Chan
import Atelier.Effects.Conc qualified as Conc


-- | Creates a debounced output channel from an input channel.
--
-- After receiving the first trigger, waits for the settling window before emitting
-- a single signal on the output. All intermediate triggers during the settling window
-- are absorbed. Implemented as: block on first trigger, then drain with timeout until
-- quiet, then fire once.
debounced
    :: forall t es
     . ( Chan :> es
       , Conc :> es
       , TimeUnit t
       , Timeout :> es
       )
    => t
    -- ^ Settling window — how long to wait for silence before firing
    -> OutChan ()
    -- ^ Input: receives raw (potentially noisy) triggers
    -> Eff es (OutChan ())
    -- ^ Output: fires once after each settled burst
debounced settleTime triggerOut = do
    (firedIn, firedOut) <- Chan.newChan
    Conc.fork_ $ drainLoop firedIn
    pure firedOut
  where
    settleUs = fromIntegral (toMicroseconds settleTime)

    drainLoop :: InChan () -> Eff es Void
    drainLoop firedIn = forever do
        Chan.readChan triggerOut -- block until first trigger arrives
        drain firedIn -- absorb remaining triggers until quiet
    drain :: InChan () -> Eff es ()
    drain firedIn = do
        more <- timeout settleUs (Chan.readChan triggerOut)
        case more of
            Nothing -> Chan.writeChan firedIn () -- settled: emit once
            Just _ -> drain firedIn -- more triggers: keep waiting
