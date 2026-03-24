{-# OPTIONS_GHC -Wno-orphans #-}

module Ghcib.Config
    ( Config (..)
    , loadConfig
    , resolveCommand
    ) where

import Data.Aeson (FromJSON)
import Data.Default (Default (..))
import System.Directory (doesFileExist, listDirectory)
import System.FilePath (takeExtension, (</>))
import TOML (DecodeTOML (..), decode, getFieldOpt, getFieldOr)

import Atelier.Time (Millisecond)
import Atelier.Types.QuietSnake (QuietSnake (..))


data Config = Config
    { command :: Maybe Text
    , debounceMs :: Millisecond
    , outputFile :: Maybe FilePath
    , logFile :: Maybe FilePath
    }
    deriving stock (Eq, Generic, Show)
    deriving (FromJSON) via QuietSnake Config


instance Default Config where
    def =
        Config
            { command = Nothing
            , debounceMs = 100
            , outputFile = Just "build.json"
            , logFile = Nothing
            }


-- Orphan instance — lives here since Millisecond is not in ghcib's dependency tree
instance DecodeTOML Millisecond where
    tomlDecoder = fromInteger <$> tomlDecoder


instance DecodeTOML Config where
    tomlDecoder = do
        command <- getFieldOpt "command"
        debounceMs <- getFieldOr 100 "debounce_ms"
        outputFile <- getFieldOr (Just "build.json") "output_file"
        logFile <- getFieldOpt "log_file"
        pure
            Config
                { command = command
                , debounceMs = debounceMs
                , outputFile = outputFile
                , logFile = logFile
                }


-- | Load config from .ghcib.toml in the project root, falling back to defaults.
-- CLI flags should be merged on top by the caller.
loadConfig :: FilePath -> IO Config
loadConfig projectRoot = do
    let tomlPath = projectRoot </> ".ghcib.toml"
    exists <- doesFileExist tomlPath
    if exists then do
        content <- readFileBS tomlPath
        case decode (decodeUtf8 content) of
            Left _ -> pure def
            Right cfg -> pure cfg
    else
        pure def


-- | Resolve the GHCi command, using config if set or autodetecting otherwise.
resolveCommand :: Config -> FilePath -> IO Text
resolveCommand cfg projectRoot =
    case cfg.command of
        Just cmd -> pure cmd
        Nothing -> detectCommand projectRoot


detectCommand :: FilePath -> IO Text
detectCommand projectRoot = do
    hasCabalProject <- doesFileExist (projectRoot </> "cabal.project")
    cabalFiles <- filter (\f -> takeExtension f == ".cabal") <$> listDirectory projectRoot
    hasStack <- doesFileExist (projectRoot </> "stack.yaml")
    pure
        $ if
            | hasCabalProject -> "cabal repl --enable-multi-repl all"
            | not (null cabalFiles) -> "cabal repl --enable-multi-repl all"
            | hasStack -> "stack ghci"
            | otherwise -> "cabal repl"
