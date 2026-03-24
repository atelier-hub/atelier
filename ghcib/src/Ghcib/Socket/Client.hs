module Ghcib.Socket.Client
    ( queryStatus
    , queryStatusWait
    , queryWatch
    , socketPath
    , isDaemonRunning
    ) where

import Control.Exception (finally, try)
import Network.Socket
    ( Family (..)
    , SockAddr (..)
    , SocketType (..)
    , connect
    , defaultProtocol
    , socket
    , socketToHandle
    )
import Numeric (showHex)
import System.Directory (canonicalizePath, createDirectoryIfMissing)
import System.FilePath ((</>))
import System.IO (hClose, hGetLine, hPutStrLn)

import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BSL

import Ghcib.BuildState (BuildState)


-- | Query the current build status (non-blocking).
queryStatus :: FilePath -> IO (Either Text BuildState)
queryStatus sockPath = withConnection sockPath \h -> do
    hPutStrLn h "{\"query\":\"status\"}"
    receiveState h


-- | Query the build status, blocking until the current build cycle completes.
queryStatusWait :: FilePath -> IO (Either Text BuildState)
queryStatusWait sockPath = withConnection sockPath \h -> do
    hPutStrLn h "{\"query\":\"status\",\"wait\":true}"
    receiveState h


-- | Connect and stream build updates, calling the handler after each completed build.
queryWatch :: FilePath -> (BuildState -> IO ()) -> IO ()
queryWatch sockPath handler = withConnection sockPath \h -> do
    hPutStrLn h "{\"query\":\"watch\"}"
    loop h
  where
    loop h = do
        line <- hGetLine h
        case Aeson.decode (BSL.fromStrict (encodeUtf8 (toText line))) of
            Nothing -> pure ()
            Just state -> handler state >> loop h


-- | Compute the Unix socket path for the given project root.
socketPath :: FilePath -> IO FilePath
socketPath rawRoot = do
    root <- canonicalizePath rawRoot
    runtimeDir <- fromMaybe "/tmp" <$> lookupEnv "XDG_RUNTIME_DIR"
    let dir = runtimeDir </> "ghcib"
    createDirectoryIfMissing True dir
    pure $ dir </> hashPath root <> ".sock"


-- | Check whether the daemon is running by attempting a socket connection.
isDaemonRunning :: FilePath -> IO Bool
isDaemonRunning sockPath = do
    result <- try @SomeException $ withConnection sockPath \_ -> pure ()
    pure $ isRight result


-- internals

withConnection :: FilePath -> (Handle -> IO a) -> IO a
withConnection sockPath action = do
    sock <- socket AF_UNIX Stream defaultProtocol
    connect sock (SockAddrUnix sockPath)
    h <- socketToHandle sock ReadWriteMode
    hSetBuffering h LineBuffering
    action h `finally` hClose h


receiveState :: Handle -> IO (Either Text BuildState)
receiveState h = do
    line <- hGetLine h
    case Aeson.decode (BSL.fromStrict (encodeUtf8 (toText line))) of
        Nothing -> pure $ Left "failed to parse response"
        Just state -> pure $ Right state


-- | Polynomial hash of a file path, returned as a hex string.
hashPath :: FilePath -> String
hashPath path =
    let n = foldl' (\acc c -> acc * 31 + toInteger (ord c)) (0 :: Integer) path
    in  showHex (abs n `mod` (16 ^ (16 :: Integer))) ""
