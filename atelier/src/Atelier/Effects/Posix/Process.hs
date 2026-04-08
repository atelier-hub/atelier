{-# OPTIONS_GHC -Wno-redundant-constraints #-}

module Atelier.Effects.Posix.Process
    ( Process
    , createSession
    , forkProcess
    , runProcess
    ) where

import Effectful (Dispatch (..), DispatchOf, Effect, IOE)
import Effectful.Dispatch.Static
    ( SideEffects (..)
    , StaticRep
    , evalStaticRep
    , unsafeEff_
    , unsafeSeqUnliftIO
    )
import System.Posix (ProcessGroupID, ProcessID)

import System.Posix.Process qualified as Posix


-- | Process and forking operations.
data Process :: Effect


type instance DispatchOf Process = Static WithSideEffects
data instance StaticRep Process = Process


-- | Run `Process` effect.
runProcess :: (HasCallStack, IOE :> es) => Eff (Process : es) a -> Eff es a
runProcess = evalStaticRep Process


-- | Lifted `System.Posix.Process.createSession`.
createSession :: (HasCallStack, Process :> es) => Eff es ProcessGroupID
createSession = unsafeEff_ Posix.createSession


-- | Lifted `System.Posix.Process.forkProcess`.
forkProcess :: (HasCallStack, Process :> es) => Eff es () -> Eff es ProcessID
forkProcess f = unsafeSeqUnliftIO \unlift -> Posix.forkProcess $ unlift f
