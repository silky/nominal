{-|
Module      : Utilities 
Description : Helper functions 
Copyright   : (c) Murdoch J. Gabbay, 2020
License     : GPL-3
Maintainer  : murdoch.gabbay@gmail.com
Stability   : experimental
Portability : POSIX

Helper functions 
-}

{-# LANGUAGE FlexibleInstances     
           , UndecidableInstances    -- needed for Num a => Nameless a
           , InstanceSigs          
           , MultiParamTypeClasses 
           , FlexibleContexts      
           , TupleSections         
           , PartialTypeSignatures 
#-}  

module Language.Nominal.Utilities 
    where

import           Data.Foldable      (Foldable (..)) -- for toList
import           Data.List
import           Data.Maybe
import           Data.List.NonEmpty (NonEmpty (..))
import           GHC.Stack          (HasCallStack)

-- * Utilities

-- | 'mkCong g f x' tries to compute 'f x'; 
-- if this returns 'Nothing' then control passes to 'g', which should be a function of two arguments which descends recursively into its second argument 'x' and applies its first argument 'mkCong g f' to the subparts of 'x'.
mkCong :: ((a -> a) -> a -> a) -> (a -> Maybe a) -> a -> a
mkCong g f x = fromMaybe (g (mkCong g f) x) (f x)

class Cong a where
   congRecurse :: (a -> a) -> a -> a
   cong :: (a -> Maybe a) -> a -> a
   cong = mkCong congRecurse


-- | Apply f repeatedly until we reach a fixedpoint
repeatedly :: Eq a => (a -> a) -> a -> a
repeatedly f x = if f x == x then x else repeatedly f (f x)


-- | Apply a list of functions in succession.
chain :: [a -> a] -> a -> a
chain = foldr (.) id
-- https://hackage.haskell.org/package/speculate-0.4.1/docs/src/Test.Speculate.Utils.List.html#chain

-- | Standard function, returns @Just a@ provided @True@, and @Nothing@ otherwise 
toMaybe :: Bool -> a -> Maybe a
toMaybe True  a = Just a
toMaybe False _ = Nothing

-- | Applies function provided condition holds
providedThat :: (a -> Maybe b) -> (a -> Bool) -> a -> Maybe b 
providedThat f tst a = if tst a then f a else Nothing

 
-- | List subset.  Surely this must be in a library somewhere.
isSubsetOf :: Eq a => [a] -> [a] -> Bool 
isSubsetOf l1 l2 = all (`elem` l2) l1


interleave :: [[a]] -> [a]
interleave = concat . transpose

areAny :: [a] -> (a -> Bool) -> Bool
areAny = flip any

areElem :: Eq a => [a] -> a -> Bool
areElem = flip elem 

safeTail :: [a] -> Maybe [a]
safeTail (_ : xs) = Just xs
safeTail _        = Nothing

safeHead :: [a] -> Maybe a
safeHead (h : _) = Just h 
safeHead _       = Nothing


-- | Finds the unique element in a collection satisfying a predicate. 
-- Results in an error if there is no such element or if there are more than one.
--
-- >>> iota (== 1) [1, 2, 3]
-- 1
--
-- >>> iota (> 1) [1, 2, 3]
-- *** Exception: iota: expected exactly one element to satisfy the predicate, but found at least two
-- ...
--
-- >>> iota (> 3) [1, 2, 3]
-- *** Exception: iota: expected exactly one element to satisfy the predicate, but found none
-- ...
--
iota :: (HasCallStack, Foldable f) => (a -> Bool) -> f a -> a
iota p xs = case filter p $ toList xs of
    [x]     -> x
    []      -> error "iota: expected exactly one element to satisfy the predicate, but found none"
    (_ : _) -> error "iota: expected exactly one element to satisfy the predicate, but found at least two"

-- | point moves the (first) element satisfying the predicate to the head of the list.
-- Error raised if no such element found.
--
-- >>> point even [1,2,3]
-- 2 :| [1,3]
--
-- >>> point even [1,3,5]
-- *** Exception: point: no such element
-- ...
--
point :: Foldable f => (a -> Bool) -> f a -> NonEmpty a
point p = go . toList
  where
    go (x : xs)
        | p x       = x :| xs
        | otherwise = let (y :| ys) = go xs in y :| x : ys
    go []           = error "point: no such element"
