module Unit.Atelier.Effects.ConcSpec (spec_Conc) where

import Control.Exception (ErrorCall (..), throwIO)
import Effectful (IOE, runEff)
import Effectful.Concurrent (Concurrent, runConcurrent)
import Effectful.State.Static.Shared (State, evalState)
import Hedgehog (forAll, (===))
import Test.Hspec (Spec, anyException, context, describe, it, shouldBe, shouldSatisfy, shouldThrow)
import Test.Hspec.Hedgehog (hedgehog)

import Data.IORef qualified as IORef
import Hedgehog.Gen qualified as Gen
import Hedgehog.Range qualified as Range

import Atelier.Effects.Conc (Conc, await, awaitAll, fork, forkTry, fork_, runConc, scoped)
import Atelier.Effects.Delay (Delay, Timers)
import Atelier.Time (Millisecond)

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
                                Delay.wait (10 :: Millisecond)
                            -- Let it run a bit
                            Delay.tick (25 :: Millisecond)
                    -- "Connection" ends here, but thread continues...
                    simulateConnection

                    -- Capture count after "connection" ended
                    countAfter <- liftIO $ IORef.readIORef counter

                    -- Progress time to see if thread keeps running (it will - that's the bug)
                    Delay.tick (50 :: Millisecond)

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
                            Delay.wait (10 :: Millisecond)
                        -- Let it run briefly
                        Delay.tick (25 :: Millisecond)
                    -- Inner scope exits here - thread should be KILLED

                    -- Capture count after scope exit
                    countAfter <- liftIO $ IORef.readIORef counter

                    -- Progress time for thread to potentially run more (it shouldn't!)
                    Delay.tick (50 :: Millisecond)

                    -- Count should NOT increase after scope exit
                    finalCount <- liftIO $ IORef.readIORef counter

                    pure (countAfter, finalCount)

                let (countAfter, finalCount) = result
                -- finalCount should EQUAL countAfter (thread was cleaned up)
                finalCount `shouldBe` countAfter

    describe "fork and await" do
        it "returns the result of the forked computation" do
            result <- runTestSimple $ do
                t <- fork $ pure (42 :: Int)
                await t
            result `shouldBe` 42

        it "executes the forked action" do
            result <- runTestSimple $ do
                ref <- liftIO $ IORef.newIORef False
                t <- fork $ liftIO $ IORef.writeIORef ref True
                await t
                liftIO $ IORef.readIORef ref
            result `shouldBe` True

    describe "awaitAll" do
        it "waits for all forked threads to complete" $ hedgehog do
            n <- forAll $ Gen.int (Range.linear 1 20)
            result <- liftIO $ runTestSimple $ do
                ref <- liftIO $ IORef.newIORef (0 :: Int)
                replicateM_ n $ fork $ liftIO $ IORef.atomicModifyIORef' ref (\x -> (x + 1, ()))
                awaitAll
                liftIO $ IORef.readIORef ref
            result === n

    describe "forkTry" do
        it "returns Right for a successful computation" do
            result <- runTestSimple $ do
                t <- forkTry @ErrorCall $ pure (42 :: Int)
                await t
            result `shouldBe` Right 42

        it "returns Left when the forked thread throws" do
            result <- runTestSimple $ do
                t <- forkTry @ErrorCall $ liftIO $ throwIO $ ErrorCall "boom"
                await t
            (result :: Either ErrorCall Int) `shouldSatisfy` isLeft

    describe "exception propagation" do
        it "uncaught exception in forked thread propagates to the scope" do
            let action = runTestSimple $ do
                    _ <- fork $ liftIO $ throwIO $ ErrorCall "boom"
                    awaitAll
            action `shouldThrow` anyException


--------------------------------------------------------------------------------
-- Test Helpers
--------------------------------------------------------------------------------

runTest :: Eff '[Conc, Delay, State Timers, Concurrent, IOE] a -> IO a
runTest = runEff . runConcurrent . evalState Delay.mkTimers . Delay.runDelayWithControls . runConc


runTestSimple :: Eff '[Conc, Concurrent, IOE] a -> IO a
runTestSimple = runEff . runConcurrent . runConc
