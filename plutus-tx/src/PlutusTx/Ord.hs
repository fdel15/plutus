{-# OPTIONS_GHC -fno-omit-interface-pragmas #-}
module PlutusTx.Ord (Ord(..), Ordering(..)) where

import qualified PlutusTx.Builtins as Builtins
import           PlutusTx.Eq

import           Prelude           hiding (Eq (..), Ord (..))

{- HLINT ignore -}

infix 4 <, <=, >, >=

-- Copied from the GHC definition
-- | The 'Ord' class is used for totally ordered datatypes.
--
-- Minimal complete definition: either 'compare' or '<='.
-- Using 'compare' can be more efficient for complex types.
--
class Eq a => Ord a where
    compare              :: a -> a -> Ordering
    (<), (<=), (>), (>=) :: a -> a -> Bool
    max, min             :: a -> a -> a

    {-# INLINABLE compare #-}
    compare x y = if x == y then EQ
                  -- NB: must be '<=' not '<' to validate the
                  -- above claim about the minimal things that
                  -- can be defined for an instance of Ord:
                  else if x <= y then LT
                  else GT

    {-# INLINABLE (<) #-}
    x <  y = case compare x y of { LT -> True;  _ -> False }
    {-# INLINABLE (<=) #-}
    x <= y = case compare x y of { GT -> False; _ -> True }
    {-# INLINABLE (>) #-}
    x >  y = case compare x y of { GT -> True;  _ -> False }
    {-# INLINABLE (>=) #-}
    x >= y = case compare x y of { LT -> False; _ -> True }

    -- These two default methods use '<=' rather than 'compare'
    -- because the latter is often more expensive
    {-# INLINABLE max #-}
    max x y = if x <= y then y else x
    {-# INLINABLE min #-}
    min x y = if x <= y then x else y

instance Ord Integer where
    {-# INLINABLE (<) #-}
    (<) = Builtins.lessThanInteger
    {-# INLINABLE (<=) #-}
    (<=) = Builtins.lessThanEqInteger
    {-# INLINABLE (>) #-}
    (>) = Builtins.greaterThanInteger
    {-# INLINABLE (>=) #-}
    (>=) = Builtins.greaterThanEqInteger

instance Ord Builtins.BuiltinByteString where
    {-# INLINABLE compare #-}
    compare l r = if Builtins.lessThanByteString l r then LT else if Builtins.equalsByteString l r then EQ else GT

instance Ord a => Ord [a] where
    {-# INLINABLE compare #-}
    compare []     []     = EQ
    compare []     (_:_)  = LT
    compare (_:_)  []     = GT
    compare (x:xs) (y:ys) = compare x y <> compare xs ys

instance Ord Bool where
    {-# INLINABLE compare #-}
    compare b1 b2 = case b1 of
        False -> case b2 of
            False -> EQ
            True  -> LT
        True -> case b2 of
            False -> GT
            True  -> EQ

instance Ord a => Ord (Maybe a) where
    {-# INLINABLE compare #-}
    compare (Just a1) (Just a2) = compare a1 a2
    compare Nothing (Just _)    = LT
    compare (Just _) Nothing    = GT
    compare Nothing Nothing     = EQ

instance (Ord a, Ord b) => Ord (Either a b) where
    {-# INLINABLE compare #-}
    compare (Left a1) (Left a2)   = compare a1 a2
    compare (Left _) (Right _)    = LT
    compare (Right _) (Left _)    = GT
    compare (Right b1) (Right b2) = compare b1 b2

instance Ord () where
    {-# INLINABLE compare #-}
    compare _ _ = EQ

instance (Ord a, Ord b) => Ord (a, b) where
    {-# INLINABLE compare #-}
    compare (a, b) (a', b') = compare a a' <> compare b b'
