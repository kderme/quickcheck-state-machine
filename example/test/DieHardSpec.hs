{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE FlexibleInstances  #-}
{-# LANGUAGE GADTs              #-}
{-# LANGUAGE StandaloneDeriving #-}

module DieHardSpec (spec, prop_bigJug4) where

import           Data.Dynamic                 (cast)
import           Data.List                    (find)
import           Data.Singletons.Prelude      (ConstSym1)
import           Test.Hspec                   (Spec, describe, it, shouldBe)
import           Test.QuickCheck              (Property, label, property)
import           Text.ParserCombinators.ReadP (string)
import           Text.Read                    (choice, lift, parens,
                                               readListPrec,
                                               readListPrecDefault, readPrec)

import           DieHard
import           Test.StateMachine.Types
import           Test.StateMachine.Utils

------------------------------------------------------------------------

validSolutions :: [[Step ('Response ()) (ConstSym1 ())]]
validSolutions =
  [ [ FillBig
    , BigIntoSmall
    , EmptySmall
    , BigIntoSmall
    , FillBig
    , BigIntoSmall
    ]
  , [ FillSmall
    , SmallIntoBig
    , FillSmall
    , SmallIntoBig
    , EmptyBig
    , SmallIntoBig
    , FillSmall
    , SmallIntoBig
    ]
  , [ FillSmall
    , SmallIntoBig
    , FillSmall
    , SmallIntoBig
    , EmptySmall
    , BigIntoSmall
    , EmptySmall
    , BigIntoSmall
    , FillBig
    , BigIntoSmall
    ]
  , [ FillBig
    , BigIntoSmall
    , EmptyBig
    , SmallIntoBig
    , FillSmall
    , SmallIntoBig
    , EmptyBig
    , SmallIntoBig
    , FillSmall
    , SmallIntoBig
    ]
  ]

testValidSolutions :: Bool
testValidSolutions = all ((/= 4) . bigJug . run) validSolutions
  where
  run = foldr (\c s -> transitions s c ()) initState

prop_bigJug4 :: Property
prop_bigJug4 = shrinkPropertyHelper' prop_dieHard $ \output ->
  let counterExample = read $ lines output !! 1 in
  case find (== counterExample) (map (map (flip Untyped' ())) validSolutions) of
    Nothing -> property False
    Just ex -> label (show ex) (property True)

------------------------------------------------------------------------

spec :: Spec
spec = do

  describe "Sequential property" $ do

    it "`testValidSolutions`: `validSolutions` are valid solutions" $
      testValidSolutions `shouldBe` True

    it "`prop_bigJug4`: in most cases, the smallest solution is found"
      prop_bigJug4

------------------------------------------------------------------------

deriving instance Show (Step resp refs)
deriving instance Eq   (Step resp refs)

instance Show (Untyped' Step (ConstSym1 ())) where
  show (Untyped' cmd _) = show cmd

instance Eq (Untyped' Step (ConstSym1 ())) where
  Untyped' c1 _ == Untyped' c2 _ = Just c1 == cast c2

instance Read (Untyped' Step (ConstSym1 ())) where
  readPrec = parens $ choice
    [ Untyped' <$> parens (FillBig      <$ key "FillBig")      <*> readPrec
    , Untyped' <$> parens (FillSmall    <$ key "FillSmall")    <*> readPrec
    , Untyped' <$> parens (EmptyBig     <$ key "EmptyBig")     <*> readPrec
    , Untyped' <$> parens (EmptySmall   <$ key "EmptySmall")   <*> readPrec
    , Untyped' <$> parens (SmallIntoBig <$ key "SmallIntoBig") <*> readPrec
    , Untyped' <$> parens (BigIntoSmall <$ key "BigIntoSmall") <*> readPrec
    ]
    where
    key s = lift (string s)

  readListPrec = readListPrecDefault
