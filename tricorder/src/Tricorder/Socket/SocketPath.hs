module Tricorder.Socket.SocketPath
    ( SocketPath (..)
    , socketPath
    , runSocketPath
    , runSocketPathConst
    ) where

import Effectful.Reader.Static (Reader, asks, runReader)
import Numeric (showHex)
import System.FilePath ((</>))

import Atelier.Effects.FileSystem
    ( FileSystem
    , canonicalizePath
    , createDirectoryIfMissing
    , getXdgRuntimeDir
    )
import Tricorder.Project (ProjectRoot (..))


-- | Compute the Unix socket path for the given project root.
socketPath :: (FileSystem :> es) => FilePath -> Eff es FilePath
socketPath rawRoot = do
    root <- canonicalizePath rawRoot
    runtimeDir <- getXdgRuntimeDir
    let dir = runtimeDir </> "tricorder"
    createDirectoryIfMissing True dir
    pure $ dir </> hashPath root <> ".sock"


newtype SocketPath = SocketPath {getSocketPath :: FilePath}


runSocketPath
    :: ( FileSystem :> es
       , Reader ProjectRoot :> es
       )
    => Eff (Reader SocketPath : es) a
    -> Eff es a
runSocketPath act = do
    root <- asks coerce
    sock <- socketPath root
    runReader (SocketPath sock) act


runSocketPathConst :: FilePath -> Eff (Reader SocketPath : es) a -> Eff es a
runSocketPathConst = runReader . SocketPath


-- | Polynomial hash of a file path, returned as a hex string.
hashPath :: FilePath -> String
hashPath path =
    let n = foldl' (\acc c -> acc * 31 + toInteger (ord c)) (0 :: Integer) path
    in  showHex (abs n `mod` (16 ^ (16 :: Integer))) ""
