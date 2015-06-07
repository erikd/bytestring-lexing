{-# OPTIONS_GHC -Wall -fwarn-tabs #-}
----------------------------------------------------------------
--                                                    2015.06.07
-- |
-- Module      :  test/Integral
-- Copyright   :  Copyright (c) 2010--2015 wren gayle romano
-- License     :  BSD2
-- Maintainer  :  wren@community.haskell.org
-- Stability   :  test framework
-- Portability :  Haskell98
--
-- Correctness testing for "Data.ByteString.Lex.Integral".
----------------------------------------------------------------
module Integral (main) where

import qualified Data.ByteString              as BS
import qualified Data.ByteString.Char8        as BS8
import           Data.ByteString.Lex.Integral
import           Data.Int
import           Control.Monad                ((<=<))
import qualified Test.QuickCheck              as QC
import qualified Test.SmallCheck              as SC

----------------------------------------------------------------
----------------------------------------------------------------
----- QuickCheck\/SmallCheck properties

-- | Converting a non-negative number to a string using 'show' and
-- then reading it back using 'readDecimal' returns the original
-- number.
prop_readDecimal_show :: (Show a, Integral a) => a -> Bool
prop_readDecimal_show x =
    let px = abs x
    in  Just (px, BS.empty) == (readDecimal . BS8.pack . show) px


-- | Converting a number to a string using 'show' and then reading
-- it back using @'readSigned' 'readDecimal'@ returns the original
-- number.
prop_readSignedDecimal_show :: (Show a, Integral a) => a -> Bool
prop_readSignedDecimal_show x =
    Just (x, BS.empty) == (readSigned readDecimal . BS8.pack . show) x


-- | Converting a non-negative number to a string using 'show' and
-- then reading it back using 'readDecimal_' returns the original
-- number.
prop_readDecimalzu_show :: (Show a, Integral a) => a -> Bool
prop_readDecimalzu_show x =
    let px = abs x
    in  px == (readDecimal_ . BS8.pack . show) px


-- | Converting a non-negative number to a bytestring using
-- 'packDecimal' and then reading it back using 'read' returns the
-- original number.
prop_read_packDecimal :: (Read a, Integral a) => a -> Bool
prop_read_packDecimal x =
    let px = abs x
    in  px == (read . maybe "" BS8.unpack . packDecimal) px


-- | Converting a non-negative number to a string using 'packDecimal'
-- and then reading it back using 'readDecimal' returns the original
-- number.
prop_readDecimal_packDecimal :: (Show a, Integral a) => a -> Bool
prop_readDecimal_packDecimal x =
    let px = abs x
    in  Just (px, BS.empty) == (readDecimal <=< packDecimal) px
-- TODO: how can we check the other composition with QC/SC?

----------------------------------------------------------------
-- | Converting a non-negative number to a string using 'packHexadecimal'
-- and then reading it back using 'readHexadecimal' returns the
-- original number.
prop_readHexadecimal_packHexadecimal :: (Show a, Integral a) => a -> Bool
prop_readHexadecimal_packHexadecimal x =
    let px = abs x
    in  Just (px, BS.empty) == (readHexadecimal <=< packHexadecimal) px

-- TODO: how can we check the other composition with QC/SC?

----------------------------------------------------------------
-- | Converting a non-negative number to a string using 'packOctal'
-- and then reading it back using 'readOctal' returns the original
-- number.
prop_readOctal_packOctal :: (Show a, Integral a) => a -> Bool
prop_readOctal_packOctal x =
    let px = abs x
    in  Just (px, BS.empty) == (readOctal <=< packOctal) px

-- TODO: how can we check the other composition with QC/SC?

----------------------------------------------------------------
{-
-- | A more obviously correct but much slower implementation than
-- the public one.
packDecimal :: (Integral a) => a -> Maybe ByteString
packDecimal = start
    where
    start n0
        | n0 < 0    = Nothing
        | otherwise = Just $ loop n0 BS.empty

    loop n xs
        | n `seq` xs `seq` False = undefined -- for strictness analysis
        | n <= 9    = BS.cons (0x30 + fromIntegral n) xs
        | otherwise =
            let (q,r) = n `quotRem` 10
            in loop q (BS.cons (0x30 + fromIntegral r) xs)
-}

----------------------------------------------------------------
----------------------------------------------------------------
main :: IO ()
main = do
    putStrLn "* Integral tests."
    runQuickCheckTests
    runSmallCheckTests


atInt :: (Int -> a) -> Int -> a
atInt = id

atInt32 :: (Int32 -> a) -> Int32 -> a
atInt32 = id

atInt64 :: (Int64 -> a) -> Int64 -> a
atInt64 = id

atInteger :: (Integer -> a) -> Integer -> a
atInteger = id

-- | Test 'Integers' around the 'Int' boundary. This combinator is
-- for smallcheck.
intBoundary :: (Integer -> a) -> Integer -> a
intBoundary f x = f (x + fromIntegral (maxBound - 8 :: Int))


runQuickCheckTests :: IO ()
runQuickCheckTests = do
    putStrLn "** QuickCheck tests."
    putStrLn "*** Checking prop_readDecimal_show..."
    QC.quickCheck $ atInt     prop_readDecimal_show
    QC.quickCheck $ atInt32   prop_readDecimal_show
    QC.quickCheck $ atInt64   prop_readDecimal_show
    QC.quickCheck $ atInteger prop_readDecimal_show
    --
    putStrLn "*** Checking prop_readDecimalzu_show..."
    QC.quickCheck $ atInt     prop_readDecimalzu_show
    QC.quickCheck $ atInt32   prop_readDecimalzu_show
    QC.quickCheck $ atInt64   prop_readDecimalzu_show
    QC.quickCheck $ atInteger prop_readDecimalzu_show
    --
    putStrLn "*** Checking prop_readSignedDecimal_show..."
    QC.quickCheck $ atInt     prop_readSignedDecimal_show
    QC.quickCheck $ atInt32   prop_readSignedDecimal_show
    QC.quickCheck $ atInt64   prop_readSignedDecimal_show
    QC.quickCheck $ atInteger prop_readSignedDecimal_show
    --
    putStrLn "*** Checking prop_read_packDecimal..."
    QC.quickCheck $ atInt     prop_read_packDecimal
    QC.quickCheck $ atInt32   prop_read_packDecimal
    QC.quickCheck $ atInt64   prop_read_packDecimal
    QC.quickCheck $ atInteger prop_read_packDecimal
    --
    putStrLn "*** Checking prop_readDecimal_packDecimal..."
    QC.quickCheck $ atInt     prop_readDecimal_packDecimal
    QC.quickCheck $ atInt32   prop_readDecimal_packDecimal
    QC.quickCheck $ atInt64   prop_readDecimal_packDecimal
    QC.quickCheck $ atInteger prop_readDecimal_packDecimal
    --
    putStrLn "*** Checking prop_readHexadecimal_packHexadecimal..."
    QC.quickCheck $ atInt     prop_readHexadecimal_packHexadecimal
    QC.quickCheck $ atInt32   prop_readHexadecimal_packHexadecimal
    QC.quickCheck $ atInt64   prop_readHexadecimal_packHexadecimal
    QC.quickCheck $ atInteger prop_readHexadecimal_packHexadecimal
    --
    putStrLn "*** Checking prop_readOctal_packOctal..."
    QC.quickCheck $ atInt     prop_readOctal_packOctal
    QC.quickCheck $ atInt32   prop_readOctal_packOctal
    QC.quickCheck $ atInt64   prop_readOctal_packOctal
    QC.quickCheck $ atInteger prop_readOctal_packOctal


runSmallCheckTests :: IO ()
runSmallCheckTests = do
    putStrLn "** SmallCheck tests."
    let d = 2 ^ (8 :: Int) :: Int
    putStrLn "*** Checking prop_readDecimal_show..."
    SC.smallCheck d $ atInt       prop_readDecimal_show
    SC.smallCheck d $ intBoundary prop_readDecimal_show
    --
    putStrLn "*** Checking prop_readDecimalzu_show..."
    SC.smallCheck d $ atInt       prop_readDecimalzu_show
    SC.smallCheck d $ intBoundary prop_readDecimalzu_show
    --
    putStrLn "*** Checking prop_readSignedDecimal_show..."
    SC.smallCheck d $ atInt       prop_readSignedDecimal_show
    SC.smallCheck d $ intBoundary prop_readSignedDecimal_show
    --
    putStrLn "*** Checking prop_read_packDecimal..."
    SC.smallCheck d $ atInt       prop_read_packDecimal
    SC.smallCheck d $ intBoundary prop_read_packDecimal
    --
    putStrLn "*** Checking prop_readDecimal_packDecimal..."
    SC.smallCheck d $ atInt       prop_readDecimal_packDecimal
    SC.smallCheck d $ intBoundary prop_readDecimal_packDecimal
    --
    putStrLn "*** Checking prop_readHexadecimal_packHexadecimal..."
    SC.smallCheck d $ atInt       prop_readHexadecimal_packHexadecimal
    SC.smallCheck d $ intBoundary prop_readHexadecimal_packHexadecimal
    --
    putStrLn "*** Checking prop_readOctal_packOctal..."
    SC.smallCheck d $ atInt       prop_readOctal_packOctal
    SC.smallCheck d $ intBoundary prop_readOctal_packOctal

----------------------------------------------------------------
----------------------------------------------------------- fin.