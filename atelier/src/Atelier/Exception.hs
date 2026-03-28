module Atelier.Exception
    ( isGracefulShutdown
    ) where

import Effectful.Exception (SomeAsyncException)


-- | Determine if an exception represents a graceful shutdown (any async exception).
--
-- Async exceptions indicate intentional cancellation (e.g., Ki's ScopeClosing,
-- or UserInterrupt from SIGINT), as opposed to real errors that warrant logging
-- or retry logic.
isGracefulShutdown :: SomeException -> Bool
isGracefulShutdown = isJust . fromException @SomeAsyncException
