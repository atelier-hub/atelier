module Ghcib.Effects.UnixSocket
    ( -- * Effect
      UnixSocket
    , bindSocket
    , acceptHandle
    , removeSocketFile
    , socketFileExists

      -- * Interpreters
    , runUnixSocketIO
    , runUnixSocketScripted
    , SocketScript (..)
    ) where

import Control.Exception (try)
import Effectful (Effect, IOE)
import Effectful.Dispatch.Dynamic (interpret_, reinterpret)
import Effectful.State.Static.Shared (evalState, get, put)
import Effectful.TH (makeEffect)
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
import System.Directory (doesPathExist, removeFile)

import Network.Socket qualified as Net


data UnixSocket :: Effect where
    -- | Create, bind, and listen on a Unix socket at the given path.
    BindSocket :: FilePath -> UnixSocket m Socket
    -- | Accept the next incoming connection and return a line-buffered 'Handle'.
    AcceptHandle :: Socket -> UnixSocket m Handle
    -- | Remove the socket file, ignoring errors (e.g. file not found).
    RemoveSocketFile :: FilePath -> UnixSocket m ()
    -- | Check whether the socket file exists.
    SocketFileExists :: FilePath -> UnixSocket m Bool


makeEffect ''UnixSocket


-- | Production interpreter backed by real Unix sockets.
runUnixSocketIO :: (IOE :> es) => Eff (UnixSocket : es) a -> Eff es a
runUnixSocketIO = interpret_ \case
    BindSocket path -> liftIO do
        sock <- socket AF_UNIX Stream defaultProtocol
        bind sock (SockAddrUnix path)
        listen sock 5
        pure sock
    AcceptHandle sock -> liftIO do
        (conn, _) <- accept sock
        h <- socketToHandle conn ReadWriteMode
        hSetBuffering h LineBuffering
        pure h
    RemoveSocketFile path ->
        liftIO $ void $ try @SomeException $ removeFile path
    SocketFileExists path ->
        liftIO $ doesPathExist path


-- | Script element for the test interpreter.
data SocketScript
    = -- | Return this 'Handle' for the next 'acceptHandle' call.
      NextAccept Handle
    | -- | Return this 'Bool' for the next 'socketFileExists' call.
      NextFileCheck Bool


-- | Scripted interpreter for testing.
--
-- 'bindSocket' creates a real (unbound) socket so that the returned 'Socket'
-- is a valid value, but does not actually bind to the filesystem.
-- 'acceptHandle' pops the next 'NextAccept' entry from the queue and sets
-- line buffering on it. 'removeSocketFile' is always a no-op.
-- 'socketFileExists' pops the next 'NextFileCheck' entry.
runUnixSocketScripted :: (IOE :> es) => [SocketScript] -> Eff (UnixSocket : es) a -> Eff es a
runUnixSocketScripted script = reinterpret (evalState script) \_ -> \case
    BindSocket _ ->
        liftIO $ Net.socket AF_UNIX Stream defaultProtocol
    AcceptHandle _ ->
        get >>= \case
            NextAccept h : rest -> do
                put rest
                liftIO $ hSetBuffering h LineBuffering
                pure h
            _ -> error "UnixSocketScripted: expected NextAccept but queue was empty or mismatched"
    RemoveSocketFile _ -> pure ()
    SocketFileExists _ ->
        get >>= \case
            NextFileCheck b : rest -> put rest >> pure b
            _ -> error "UnixSocketScripted: expected NextFileCheck but queue was empty or mismatched"
