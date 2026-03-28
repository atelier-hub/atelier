module Ghcib.Socket.Server (component, socketMonitorTrigger) where

import Control.Concurrent.STM (TVar, atomically, readTVar, retry)
import Data.Aeson (ToJSON, encode)
import Data.Aeson.Types (parseMaybe)
import Effectful (IOE)
import Effectful.Exception (finally, throwIO)
import Effectful.Reader.Static (Reader, ask)
import System.IO (hClose, hGetLine, hPutStrLn)
import System.IO.Error (userError)

import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BSL

import Atelier.Component (Component (..), Trigger, defaultComponent)
import Atelier.Effects.Conc (Conc)
import Atelier.Effects.Delay (Delay, wait)
import Atelier.Time (Millisecond)
import Ghcib.BuildState
    ( BuildPhase (..)
    , BuildState (..)
    , BuildStateRef (..)
    )
import Ghcib.Effects.UnixSocket (UnixSocket, acceptHandle, bindSocket, removeSocketFile, socketFileExists)

import Atelier.Effects.Conc qualified as Conc


-- | SocketServer component.
-- Listens on a Unix socket and responds to status/watch queries.
component
    :: ( Conc :> es
       , Delay :> es
       , IOE :> es
       , Reader BuildStateRef :> es
       , UnixSocket :> es
       )
    => FilePath
    -- ^ Unix socket path
    -> Component es
component sockPath =
    defaultComponent
        { name = "SocketServer"
        , setup = removeSocketFile sockPath
        , triggers = do
            stateRef <- ask @BuildStateRef
            pure [acceptTrigger sockPath stateRef, socketMonitorTrigger sockPath]
        }


acceptTrigger
    :: ( Conc :> es
       , IOE :> es
       , UnixSocket :> es
       )
    => FilePath
    -> BuildStateRef
    -> Trigger es
acceptTrigger sockPath stateRef = do
    sock <- bindSocket sockPath
    forever do
        h <- acceptHandle sock
        void $ Conc.forkTry @SomeException $ liftIO (handleConnection h stateRef) `finally` liftIO (hClose h)


-- | Poll for the socket file's existence every 500ms.
-- Throws when the file is removed, causing the component system to shut down.
socketMonitorTrigger :: (Delay :> es, UnixSocket :> es) => FilePath -> Trigger es
socketMonitorTrigger sockPath = forever do
    wait (500 :: Millisecond)
    exists <- socketFileExists sockPath
    unless exists $ throwIO $ userError "socket file removed, shutting down"


handleConnection :: Handle -> BuildStateRef -> IO ()
handleConnection h (BuildStateRef ref) = do
    line <- hGetLine h
    case Aeson.decode (BSL.fromStrict (encodeUtf8 (toText line))) of
        Nothing -> hPutStrLn h "{\"error\":\"invalid request\"}"
        Just req -> dispatch req h ref


dispatch :: Aeson.Value -> Handle -> TVar BuildState -> IO ()
dispatch req h ref =
    case parseMaybe parseQuery req of
        Nothing -> hPutStrLn h "{\"error\":\"unknown query\"}"
        Just ("status", False) -> respondOnce h ref
        Just ("status", True) -> respondWhenDone h ref
        Just ("watch", _) -> watchStream h ref
        Just _ -> hPutStrLn h "{\"error\":\"unknown query\"}"
  where
    parseQuery = Aeson.withObject "request" \o -> do
        q <- o Aeson..: "query"
        w <- o Aeson..:? "wait" Aeson..!= False
        pure (q :: Text, w :: Bool)


respondOnce :: Handle -> TVar BuildState -> IO ()
respondOnce h ref = do
    state <- atomically (readTVar ref)
    sendJson h state


respondWhenDone :: Handle -> TVar BuildState -> IO ()
respondWhenDone h ref = do
    state <- atomically do
        s <- readTVar ref
        case s.phase of
            Building -> retry
            Done _ _ -> pure s
    sendJson h state


-- | Stream a JSON object after each completed build (blocks until handle closes or error).
watchStream :: Handle -> TVar BuildState -> IO ()
watchStream h ref = do
    state0 <- atomically (readTVar ref)
    sendJson h state0
    loop state0.buildId
  where
    loop bid = do
        newState <- atomically do
            s <- readTVar ref
            if s.buildId == bid || isBuilding s then retry else pure s
        sendJson h newState
        loop newState.buildId

    isBuilding s = case s.phase of
        Building -> True
        Done _ _ -> False


sendJson :: (ToJSON a) => Handle -> a -> IO ()
sendJson h val = do
    hPutStrLn h (decodeUtf8 (BSL.toStrict (encode val)))
    hFlush h
