module TicketDispenserSpec (spec) where

import           Test.Hspec
                   (Spec, describe, it)
import           Test.Hspec.QuickCheck
                   (modifyMaxSuccess)

import           HspecInstance
                   ()
import           TicketDispenser

------------------------------------------------------------------------

spec :: Spec
spec = do

  describe "Sequential property" $
    it "`prop_ticketDispenser`: the model is sequentially sound"
      prop_ticketDispenser

  describe "Parallel property" $ do

    modifyMaxSuccess (const 5) $

      it "`prop_ticketDispenserParallelOK`: works with exclusive file locks"
        prop_ticketDispenserParallelOK

    modifyMaxSuccess (const 5) $

      it "`prop_ticketDispenserParallelBad`: counterexample is found when file locks are shared"
        prop_ticketDispenserParallelBad
