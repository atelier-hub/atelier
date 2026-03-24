module Ghcib.Socket.Server
    ( component
    , bindSocket
    ) where

import Data.Aeson (ToJSON, encode)
import Data.Aeson.Types (parseMaybe)
import Effectful (IOE)
import Effectful.Concurrent (Concurrent)
import Effectful.Concurrent.STM (TVar, atomically, readTVar, retry)
import Effectful.Exception (finally, try)
import Effectful.Reader.Static (Reader, ask)
import Network.Socket
    ( Family (..)
    , SockAddr (..)
    , Socket
    , SocketType (..)
    , accept
    , bind
    , defaultProtocol
    , listen
    , socket
    , socketToHandle
    )
import System.Directory (removeFile)
import System.IO (hClose, hGetLine, hPutStrLn)

import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BSL

import Atelier.Component (Component (..), Trigger, defaultComponent)
import Atelier.Effects.Conc (Conc)
import Ghcib.BuildState
    ( BuildId (..)
    , BuildPhase (..)
    , BuildState (..)
    , BuildStateRef (..)
    )

import Atelier.Effects.Conc qualified as Conc


-- | SocketServer component.
-- Listens on a Unix socket and responds to status/watch queries.
component
    :: ( Conc :> es
       , Concurrent :> es
       , IOE :> es
       , Reader BuildStateRef :> es
       )
    => FilePath
    -- ^ Unix socket path
    -> Component es
component sockPath =
    defaultComponent
        { name = "SocketServer"
        , setup = void $ try @SomeException $ liftIO (removeFile sockPath)
        , triggers = do
            stateRef <- ask @BuildStateRef
            pure [acceptTrigger sockPath stateRef]
        }


acceptTrigger
    :: ( Conc :> es
       , Concurrent :> es
       , IOE :> es
       )
    => FilePath
    -> BuildStateRef
    -> Trigger es
acceptTrigger sockPath stateRef = do
    sock <- liftIO $ bindSocket sockPath
    forever do
        (conn, _) <- liftIO $ accept sock
        h <- liftIO $ socketToHandle conn ReadWriteMode
        liftIO $ hSetBuffering h LineBuffering
        void $ Conc.fork $ handleConnection h stateRef `finally` liftIO (hClose h)


-- | Create, bind, and listen on a Unix socket at the given path.
bindSocket :: FilePath -> IO Socket
bindSocket sockPath = do
    sock <- socket AF_UNIX Stream defaultProtocol
    bind sock (SockAddrUnix sockPath)
    listen sock 5
    pure sock


handleConnection
    :: ( Concurrent :> es
       , IOE :> es
       )
    => Handle
    -> BuildStateRef
    -> Eff es ()
handleConnection h (BuildStateRef ref) = do
    line <- liftIO $ hGetLine h
    case Aeson.decode (BSL.fromStrict (encodeUtf8 (toText line))) of
        Nothing -> liftIO $ hPutStrLn h "{\"error\":\"invalid request\"}"
        Just req -> dispatch req h ref


dispatch
    :: (Concurrent :> es, IOE :> es)
    => Aeson.Value
    -> Handle
    -> TVar BuildState
    -> Eff es ()
dispatch req h ref =
    case parseMaybe parseQuery req of
        Nothing -> liftIO $ hPutStrLn h "{\"error\":\"unknown query\"}"
        Just ("status", False) -> respondOnce h ref
        Just ("status", True) -> respondWhenDone h ref
        Just ("watch", _) -> watchStream h ref
        Just _ -> liftIO $ hPutStrLn h "{\"error\":\"unknown query\"}"
  where
    parseQuery = Aeson.withObject "request" \o -> do
        q <- o Aeson..: "query"
        wait <- o Aeson..:? "wait" Aeson..!= False
        pure (q :: Text, wait :: Bool)


respondOnce :: (Concurrent :> es, IOE :> es) => Handle -> TVar BuildState -> Eff es ()
respondOnce h ref = do
    state <- atomically (readTVar ref)
    liftIO $ sendJson h state


respondWhenDone :: (Concurrent :> es, IOE :> es) => Handle -> TVar BuildState -> Eff es ()
respondWhenDone h ref = do
    state <- atomically do
        s <- readTVar ref
        case s.phase of
            Building -> retry
            Done {} -> pure s
    liftIO $ sendJson h state


-- | Stream a JSON object after each completed build (blocks until handle closes or error).
watchStream :: (Concurrent :> es, IOE :> es) => Handle -> TVar BuildState -> Eff es ()
watchStream h ref = do
    state0 <- atomically (readTVar ref)
    liftIO $ sendJson h state0
    loop state0.buildId
  where
    loop (BuildId lastId) = do
        newState <- atomically do
            s <- readTVar ref
            let BuildId newId = s.buildId
            if newId == lastId || isBuilding s then retry else pure s
        liftIO $ sendJson h newState
        loop newState.buildId

    isBuilding s = case s.phase of
        Building -> True
        Done {} -> False


sendJson :: (ToJSON a) => Handle -> a -> IO ()
sendJson h val = do
    hPutStrLn h (decodeUtf8 (BSL.toStrict (encode val)))
    hFlush h
