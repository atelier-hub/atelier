module Unit.Atelier.Effects.ConcSpec (spec_Conc) where

import Effectful (IOE, runEff)
import Effectful.Concurrent (Concurrent, runConcurrent)
import Effectful.State.Static.Shared (State, evalState)
import Test.Hspec (Spec, context, describe, it, shouldBe, shouldSatisfy)

import Data.IORef qualified as IORef

import Atelier.Effects.Conc (Conc, fork_, runConc, scoped)
import Atelier.Effects.Delay (Delay, Timers)

import Atelier.Effects.Delay qualified as Delay


spec_Conc :: Spec
spec_Conc = do
    describe "Thread cleanup" do
        context "without scoped" do
            it "demonstrates thread leak" do
                -- This test shows we CANNOT currently create a nested scope that cleans up
                -- When we try to simulate a connection lifecycle, threads leak
                result <- runTest $ do
                    counter <- liftIO $ IORef.newIORef (0 :: Int)

                    -- Simulate connection lifecycle - we want this to be a scope that exits
                    -- But we have no way to create a nested Ki scope currently!
                    -- So the thread we fork here will live until the root scope exits
                    let simulateConnection = do
                            fork_ $ forever $ do
                                liftIO $ IORef.atomicModifyIORef' counter (\n -> (n + 1, ()))
                                Delay.wait $ Delay.micros @Int 10000 -- 10ms
                                -- Let it run a bit
                            Delay.tick $ Delay.micros @Int 25000 -- 25ms
                            -- "Connection" ends here, but thread continues...
                    simulateConnection

                    -- Capture count after "connection" ended
                    countAfter <- liftIO $ IORef.readIORef counter

                    -- Progress time to see if thread keeps running (it will - that's the bug)
                    Delay.tick $ Delay.micros @Int 50000

                    -- Count increased even after connection scope "ended"
                    finalCount <- liftIO $ IORef.readIORef counter

                    pure (countAfter, finalCount)

                let (countAfter, finalCount) = result
                -- finalCount should be GREATER than countAfter (thread leaked)
                finalCount `shouldSatisfy` (> countAfter)

        context "with scoped" do
            it "kills nested threads when scope exits" do
                result <- runTest $ do
                    counter <- liftIO $ IORef.newIORef (0 :: Int)

                    -- Create nested scope that will clean up its threads
                    scoped $ do
                        fork_ $ forever $ do
                            liftIO $ IORef.atomicModifyIORef' counter (\n -> (n + 1, ()))
                            Delay.wait $ Delay.micros @Int 10000
                        -- Let it run briefly
                        Delay.tick $ Delay.micros @Int 25000
                    -- Inner scope exits here - thread should be KILLED

                    -- Capture count after scope exit
                    countAfter <- liftIO $ IORef.readIORef counter

                    -- Progress time for thread to potentially run more (it shouldn't!)
                    Delay.tick $ Delay.micros @Int 50000

                    -- Count should NOT increase after scope exit
                    finalCount <- liftIO $ IORef.readIORef counter

                    pure (countAfter, finalCount)

                let (countAfter, finalCount) = result
                -- finalCount should EQUAL countAfter (thread was cleaned up)
                finalCount `shouldBe` countAfter


--------------------------------------------------------------------------------
-- Test Helpers
--------------------------------------------------------------------------------

runTest :: Eff '[Conc, Delay, State Timers, Concurrent, IOE] a -> IO a
runTest = runEff . runConcurrent . evalState Delay.mkTimers . Delay.runDelayWithControls . runConc
