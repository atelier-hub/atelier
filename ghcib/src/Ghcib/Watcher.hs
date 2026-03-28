module Ghcib.Watcher
    ( ReloadRequest (..)
    , component
    ) where

import Effectful (IOE)
import Effectful.Reader.Static (Reader, ask)
import Effectful.Timeout (Timeout)
import System.Directory (getCurrentDirectory)

import Atelier.Component (Component (..), defaultComponent)
import Atelier.Effects.Chan (Chan, InChan, OutChan)
import Atelier.Effects.Conc (Conc)
import Atelier.Effects.Publishing (Pub, Sub, listen_, publish)
import Ghcib.Config (Config (..), resolveWatchDirs)
import Ghcib.Debounce (debounced)
import Ghcib.Effects.FileWatcher (FileWatcher, watchDirs)
import Ghcib.Events.FileChanged (FileChanged (..))

import Atelier.Effects.Chan qualified as Chan


data ReloadRequest = Reload | Restart
    deriving stock (Eq, Ord, Show)


-- | Watcher component.
-- Watches relevant source files for changes, debounces bursts, and writes
-- 'Reload' requests to the given channel.
component
    :: ( Chan :> es
       , Conc :> es
       , FileWatcher :> es
       , IOE :> es
       , Pub FileChanged :> es
       , Reader Config :> es
       , Sub FileChanged :> es
       , Timeout :> es
       )
    => InChan ReloadRequest
    -> Component es
component reloadIn =
    defaultComponent
        { name = "Watcher"
        , triggers = do
            cfg <- ask @Config
            projectRoot <- liftIO getCurrentDirectory
            dirs <- liftIO $ resolveWatchDirs cfg.targets projectRoot
            (triggerIn, triggerOut) <- Chan.newChan
            debouncedOut <- debounced cfg.debounceMs triggerOut
            pure
                [ forever $ watchDirs dirs \path -> publish (FileChanged path)
                , listen_ \_ -> Chan.writeChan triggerIn ()
                , dispatchReloads debouncedOut
                ]
        }
  where
    dispatchReloads :: (Chan :> es) => OutChan () -> Eff es Void
    dispatchReloads debouncedOut = forever do
        Chan.readChan debouncedOut
        Chan.writeChan reloadIn Reload
