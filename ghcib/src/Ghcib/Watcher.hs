module Ghcib.Watcher
    ( ReloadRequest (..)
    , runFileWatcher
    , component
    ) where

import Control.Concurrent (threadDelay)
import Effectful (IOE, withEffToIO)
import Effectful.Reader.Static (Reader, ask)
import Effectful.Timeout (Timeout)
import System.FSNotify (Event, eventPath, watchTree, withManager)
import System.FilePath (takeExtension, takeFileName)

import Atelier.Component (Component (..), defaultComponent)
import Atelier.Effects.Chan (Chan, InChan, OutChan)
import Atelier.Effects.Conc (Conc, concStrat)
import Ghcib.Config (Config (..))
import Ghcib.Debounce (debounced)

import Atelier.Effects.Chan qualified as Chan


data ReloadRequest = Reload | Restart
    deriving stock (Eq, Ord, Show)


-- | Watch for filesystem changes and write a trigger to the given channel.
-- Uses @withEffToIO@ to bridge the fsnotify callback (which runs in IO) back
-- into the effect stack without importing Unagi directly.
runFileWatcher
    :: (Chan :> es, IOE :> es)
    => [FilePath]
    -- ^ Directories to watch (recursively)
    -> InChan ()
    -- ^ Trigger channel — receives () on any relevant change
    -> Eff es Void
runFileWatcher dirs triggerIn =
    withEffToIO concStrat \runInIO ->
        withManager \mgr -> do
            for_ dirs \dir ->
                watchTree mgr dir isRelevant \_ ->
                    runInIO $ Chan.writeChan triggerIn ()
            forever $ threadDelay 1_000_000


isRelevant :: Event -> Bool
isRelevant event =
    let path = eventPath event
        ext = takeExtension path
        fname = takeFileName path
    in  ext `elem` [".hs", ".cabal"] || fname == "cabal.project"


-- | Watcher component.
-- Creates its own internal trigger channel and debouncer, then feeds
-- debounced reload requests into the given channel.
component
    :: ( Chan :> es
       , Conc :> es
       , IOE :> es
       , Reader Config :> es
       , Timeout :> es
       )
    => InChan ReloadRequest
    -> Component es
component reloadIn =
    defaultComponent
        { name = "Watcher"
        , triggers = do
            cfg <- ask @Config
            (triggerIn, triggerOut) <- Chan.newChan
            debouncedOut <- debounced cfg.debounceMs triggerOut
            pure
                [ runFileWatcher ["."] triggerIn
                , dispatchReloads debouncedOut
                ]
        }
  where
    dispatchReloads :: (Chan :> es) => OutChan () -> Eff es Void
    dispatchReloads debouncedOut = forever do
        Chan.readChan debouncedOut
        Chan.writeChan reloadIn Reload
