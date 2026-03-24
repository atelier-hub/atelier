module Ghcib.Watch (watchDisplay) where

import System.Console.ANSI
    ( Color (..)
    , ColorIntensity (..)
    , ConsoleLayer (..)
    , SGR (..)
    , clearScreen
    , setCursorPosition
    , setSGR
    )

import Ghcib.BuildState
    ( BuildPhase (..)
    , BuildState (..)
    , Message (..)
    , Severity (..)
    )
import Ghcib.Socket.Client (queryWatch)


-- | Connect to the daemon and render a live-updating build status display.
watchDisplay :: FilePath -> IO ()
watchDisplay sockPath = do
    clearScreen
    setCursorPosition 0 0
    putStrLn "Waiting for build..."
    queryWatch sockPath renderState


renderState :: BuildState -> IO ()
renderState bs = do
    clearScreen
    setCursorPosition 0 0
    case bs.phase of
        Building ->
            withColor Yellow $ putStrLn "Building..."
        Done _ [] -> do
            withColor Green $ putStrLn "All good."
        Done _ msgs -> do
            let errCount = length $ filter (\m -> m.severity == SError) msgs
                warnCount = length $ filter (\m -> m.severity == SWarning) msgs
            if errCount > 0 then
                withColor Red $ putStrLn $ show errCount <> " error(s), " <> show warnCount <> " warning(s)"
            else
                withColor Yellow $ putStrLn $ show warnCount <> " warning(s)"
            putStrLn ""
            mapM_ renderMessage msgs


renderMessage :: Message -> IO ()
renderMessage m = do
    let loc = m.file <> ":" <> show m.line <> ":" <> show m.col
    case m.severity of
        SError -> withColor Red $ putStr "error: "
        SWarning -> withColor Yellow $ putStr "warning: "
    putStrLn loc
    putStrLn (toString m.text)
    putStrLn ""


withColor :: Color -> IO () -> IO ()
withColor color action = do
    setSGR [SetColor Foreground Vivid color]
    action
    setSGR [Reset]
