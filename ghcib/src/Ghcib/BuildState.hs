module Ghcib.BuildState
    ( BuildId (..)
    , BuildState (..)
    , BuildPhase (..)
    , Message (..)
    , Severity (..)
    , BuildStateRef (..)
    , runBuildStateRef
    , initialBuildState
    , updateBuildState
    , stateLabel
    ) where

import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, withText, (.!=), (.:), (.:?), (.=))
import Data.Aeson.Types (Parser)
import Data.Time.Units (fromMicroseconds, toMicroseconds)
import Effectful.Concurrent (Concurrent)
import Effectful.Concurrent.STM (TVar, atomically, newTVar, writeTVar)
import Effectful.Reader.Static (Reader, runReader)

import Atelier.Time (Millisecond)


newtype BuildId = BuildId Int
    deriving stock (Eq, Show)
    deriving newtype (ToJSON)


data BuildState = BuildState
    { buildId :: BuildId
    , phase :: BuildPhase
    }
    deriving stock (Eq, Show)


data BuildPhase
    = Building
    | Done Millisecond [Message]
    deriving stock (Eq, Show)


data Message = Message
    { severity :: Severity
    , file :: FilePath
    , line :: Int
    , col :: Int
    , endLine :: Int
    , endCol :: Int
    , text :: Text
    }
    deriving stock (Eq, Show)


data Severity = SError | SWarning
    deriving stock (Eq, Show)


instance FromJSON Severity where
    parseJSON = withText "Severity" \case
        "error" -> pure SError
        "warning" -> pure SWarning
        other -> fail $ "unknown severity: " <> toString other


instance ToJSON Severity where
    toJSON SError = "error"
    toJSON SWarning = "warning"


instance FromJSON Message where
    parseJSON = withObject "Message" \o ->
        Message
            <$> o .: "severity"
            <*> o .: "file"
            <*> o .: "line"
            <*> o .: "col"
            <*> o .: "endLine"
            <*> o .: "endCol"
            <*> o .: "text"


instance ToJSON Message where
    toJSON m =
        object
            [ "severity" .= m.severity
            , "file" .= m.file
            , "line" .= m.line
            , "col" .= m.col
            , "endLine" .= m.endLine
            , "endCol" .= m.endCol
            , "text" .= m.text
            ]


stateLabel :: BuildPhase -> Text
stateLabel Building = "building"
stateLabel (Done _ msgs)
    | any (\m -> m.severity == SError) msgs = "error"
    | any (\m -> m.severity == SWarning) msgs = "warning"
    | otherwise = "ok"


instance ToJSON BuildState where
    toJSON bs =
        let bid = bs.buildId
        in  case bs.phase of
                Building ->
                    object
                        [ "state" .= ("building" :: Text)
                        , "buildId" .= bid
                        ]
                Done dur msgs ->
                    object
                        [ "state" .= stateLabel (Done dur msgs)
                        , "buildId" .= bid
                        , "durationMs" .= (fromIntegral (toMicroseconds dur `div` 1000) :: Int)
                        , "messages" .= msgs
                        ]


instance FromJSON BuildState where
    parseJSON = withObject "BuildState" \o -> do
        bid <- BuildId <$> o .: "buildId"
        state <- (o .: "state") :: Parser Text
        phase <- case state of
            "building" -> pure Building
            _ -> do
                durMs <- o .: "durationMs"
                msgs <- o .:? "messages" .!= []
                pure $ Done (fromMicroseconds (durMs * 1000 :: Integer)) msgs
        pure $ BuildState bid phase


newtype BuildStateRef = BuildStateRef (TVar BuildState)


runBuildStateRef
    :: (Concurrent :> es)
    => Eff (Reader BuildStateRef : es) a
    -> Eff es a
runBuildStateRef eff = do
    ref <- atomically $ newTVar initialBuildState
    runReader (BuildStateRef ref) eff


updateBuildState
    :: (Concurrent :> es)
    => BuildStateRef
    -> BuildState
    -> Eff es ()
updateBuildState (BuildStateRef ref) state =
    atomically $ writeTVar ref state


initialBuildState :: BuildState
initialBuildState =
    BuildState
        { buildId = BuildId 0
        , phase = Building
        }
