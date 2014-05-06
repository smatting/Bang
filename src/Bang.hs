{-# LANGUAGE DeriveFunctor, NoMonomorphismRestriction #-}

module Bang(
  play,
  playIO,
  runComposition,
  module Bang.Music,
  module Bang.Music.MDrum,
  module Bang.Interface.MDrum,
  module Bang.Operators
)where

import Control.Monad
import Control.Monad.Free
import Control.Monad.Trans
import Control.Monad.Trans.State
import Control.Concurrent

import qualified System.MacOSX.CoreMIDI as OSX
import System.MIDI
import Bang.Music
import Bang.Music.MDrum
import Bang.Interface.MDrum
import Bang.Operators

-- |`play` a `Composition` over a given `Connection`
play :: Connection -> Composition () -> IO ()
play conn c = do
  start conn
  evalStateT runComposition (conn, c)
  close conn

-- |Run a `Composition` by repeatedly updating the `Connection` and sending events as they come.
runComposition :: StateT (Connection, Composition ()) IO ()
runComposition = do
  (conn, evs) <- get
  t <- lift $ currentTime conn
  case evs of
    Pure _   -> return ()
    Free End -> return ()
    Free x   -> do
      when (fromIntegral (round (dur x)) < t) $ do
        put (conn, nextBeat evs)
        case x of
          Rest d a -> return ()
          m@(MDrum _ _ _) -> do
            let MidiEvent s ev = drumToMidiEvent m
            lift $ print (MidiEvent s ev)
            lift $ send conn ev
      lift $ threadDelay 500
      runComposition

-- |Play a `Composition` over the first system `Destination` for MIDI events
playIO :: Composition () -> IO ()
playIO song = do
  dstlist <- enumerateDestinations
  case dstlist of 
    [] -> fail "No MIDI Devices found."
    (dst:_) -> do
      name    <- getName dst
      putStrLn $ "Using MIDI device: " ++ name
      conn    <- openDestination dst
      play conn song