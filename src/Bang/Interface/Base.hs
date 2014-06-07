module Bang.Interface.Base where

import Bang.Music.Class
import Data.Monoid

showMusic :: (Show a, Show b) => Music a b -> String
showMusic = go ""
  where go spcs (Prim m)     = spcs <> show m
        go spcs (a :+: b)    = mconcat [go (' ': spcs) a, "\n", spcs, ":+:", "\n", go (' ': spcs) b]
        go spcs (a :=: b)    = mconcat [go (' ': spcs) a, "\n", spcs, ":=:", "\n", go (' ': spcs) b]
        go spcs (Modify c a) = spcs <> show c <> "\n" <> go spcs a

printMusic :: (Show a, Show b) => Music a b -> IO ()
printMusic = putStrLn . showMusic

rest :: Dur -> Music Dur a
rest d = Prim (Rest d)

note :: Dur -> a -> Music Dur a
note d x = Prim (Note d x)

bpm :: Integer -> Music a b -> Music a b
bpm n = Modify (BPM n)

tempo :: Rational -> Music a b -> Music a b
tempo n = Modify (Tempo (1/n))

m4 a b c d = mconcat [a, b, c, d]

quad      = tempo 4
double    = tempo 2
quarter   = tempo 1 -- default
half      = tempo (1/2)
whole     = tempo (1/4)

tuplets n   = tempo (n/4)
triplets    = tuplets 3
quintuplets = tuplets 5

sr, er, qr, hr, wr :: Music Dur a
sr = rest (1/16)
er = rest (1/8)
qr = rest (1/4)
hr = rest (1/2)
wr = rest 1