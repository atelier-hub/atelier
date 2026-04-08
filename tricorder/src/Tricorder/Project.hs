module Tricorder.Project
    ( ProjectRoot (..)
    , runProjectRoot
    ) where

import Effectful.Reader.Static (Reader, runReader)

import Atelier.Effects.FileSystem (FileSystem, getCurrentDirectory)


newtype ProjectRoot = ProjectRoot {getProjectRoot :: FilePath}


runProjectRoot
    :: (FileSystem :> es, HasCallStack)
    => Eff (Reader ProjectRoot : es) a -> Eff es a
runProjectRoot act = do
    projectRoot <- getCurrentDirectory
    runReader (ProjectRoot projectRoot) act
