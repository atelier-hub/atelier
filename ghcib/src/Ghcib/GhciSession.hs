module Ghcib.GhciSession (component) where

import Control.Concurrent (threadDelay)
import Control.Exception (try)
import Data.Time (diffUTCTime)
import Effectful (IOE)
import Effectful.Concurrent (Concurrent)
import Effectful.Reader.Static (Reader, ask)
import Language.Haskell.Ghcid
    ( GhciError (..)
    , Load (..)
    , reload
    , startGhci
    , stopGhci
    )
import System.Directory (getCurrentDirectory)

import Language.Haskell.Ghcid qualified as Ghcid

import Atelier.Component (Component (..), Listener, defaultComponent)
import Atelier.Effects.Chan (Chan, OutChan)
import Atelier.Effects.Clock (Clock)
import Atelier.Effects.Log (Log)
import Atelier.Time (Millisecond, nominalDiffTime)
import Ghcib.BuildState
    ( BuildId (..)
    , BuildPhase (..)
    , BuildState (..)
    , BuildStateRef (..)
    , Message
    , Severity (..)
    , updateBuildState
    )
import Ghcib.Config (Config (..), resolveCommand)
import Ghcib.Watcher (ReloadRequest (..))

import Atelier.Effects.Chan qualified as Chan
import Atelier.Effects.Clock qualified as Clock
import Atelier.Effects.Log qualified as Log
import Ghcib.BuildState qualified as BuildState


-- | GhciSession component.
-- Starts a GHCi session, performs an initial load, then listens for reload
-- requests from the watcher. Catches UnexpectedExit and restarts the session
-- rather than propagating (the fix for ghcid's file-removal crash).
component
    :: ( Chan :> es
       , Clock :> es
       , Concurrent :> es
       , IOE :> es
       , Log :> es
       , Reader BuildStateRef :> es
       , Reader Config :> es
       )
    => OutChan ReloadRequest
    -> Component es
component reloadOut =
    defaultComponent
        { name = "GhciSession"
        , listeners = do
            cfg <- ask @Config
            stateRef <- ask @BuildStateRef
            projectRoot <- liftIO getCurrentDirectory
            cmd <- liftIO $ resolveCommand cfg projectRoot
            pure [sessionListener cmd projectRoot stateRef reloadOut]
        }


sessionListener
    :: ( Chan :> es
       , Clock :> es
       , Concurrent :> es
       , IOE :> es
       , Log :> es
       )
    => Text
    -> FilePath
    -> BuildStateRef
    -> OutChan ReloadRequest
    -> Listener es
sessionListener cmd projectRoot stateRef reloadOut = startSession (BuildId 1)
  where
    startSession (BuildId n) = do
        Log.info $ "Starting GHCi: " <> cmd
        result <-
            liftIO
                $ try @SomeException
                $ startGhci (toString cmd) (Just projectRoot) (\_ _ -> pure ())
        case result of
            Left ex -> do
                Log.err $ "Failed to start GHCi: " <> show ex
                -- Brief pause before retry to avoid tight restart loop
                liftIO $ threadDelay 2_000_000
                startSession (BuildId n)
            Right (ghci, initialLoads) -> do
                t0 <- Clock.currentTime
                let dur = nominalDiffTime @Millisecond (diffUTCTime t0 t0)
                    msgs = toMessages initialLoads
                updateBuildState stateRef $ BuildState (BuildId n) (Done dur msgs)
                listenLoop ghci (BuildId (n + 1))

    listenLoop ghci (BuildId n) = do
        request <- Chan.readChan reloadOut
        let nextId = BuildId (n + 1)
        Log.debug $ "Reload requested: " <> show request
        updateBuildState stateRef $ BuildState (BuildId n) Building
        t0 <- Clock.currentTime
        result <- liftIO $ try @GhciError $ case request of
            Reload -> reload ghci
            Restart -> stopGhci ghci >> pure []
        case result of
            Left _ -> do
                Log.warn "GHCi session died; restarting"
                liftIO $ try @SomeException (stopGhci ghci) >> pure ()
                startSession nextId
            Right loads -> do
                t1 <- Clock.currentTime
                let dur = nominalDiffTime (diffUTCTime t1 t0)
                    msgs = toMessages loads
                updateBuildState stateRef $ BuildState (BuildId n) (Done dur msgs)
                if request == Restart then
                    startSession nextId
                else
                    listenLoop ghci nextId


toMessages :: [Load] -> [Message]
toMessages = mapMaybe toMsg
  where
    toMsg (Ghcid.Message sev file (l, c) (el, ec) msgLines) =
        Just
            BuildState.Message
                { severity = case sev of
                    Ghcid.Warning -> SWarning
                    Ghcid.Error -> SError
                , file = file
                , line = l
                , col = c
                , endLine = el
                , endCol = ec
                , text = unlines (map toText msgLines)
                }
    toMsg _ = Nothing
