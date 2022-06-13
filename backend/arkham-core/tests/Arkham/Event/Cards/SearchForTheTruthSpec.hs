module Arkham.Event.Cards.SearchForTheTruthSpec
  ( spec
  ) where

import TestImport

import Arkham.Investigator.Attrs qualified as Investigator
import Arkham.Investigator.Attrs (Field (..))

spec :: Spec
spec = describe "Search for the Truth" $ do
  it "allows you to draw cards equal to the number of clues" $ do
    investigator <- testInvestigator (Investigator.cluesL .~ 3)
    playerCards <- testPlayerCards 3
    searchForTheTruth <- buildEvent "02008" investigator
    gameTest
        investigator
        [ loadDeck investigator playerCards
        , playEvent investigator searchForTheTruth
        ]
        (entitiesL . eventsL %~ insertEntity searchForTheTruth)
      $ do
          runMessages
          fieldAssert InvestigatorHand (== map PlayerCard playerCards) investigator

  it "has a maximum of 5 cards" $ do
    investigator <- testInvestigator (Investigator.cluesL .~ 6)
    playerCards <- testPlayerCards 6
    searchForTheTruth <- buildEvent "02008" investigator
    gameTest
        investigator
        [ loadDeck investigator playerCards
        , playEvent investigator searchForTheTruth
        ]
        (entitiesL . eventsL %~ insertEntity searchForTheTruth)
      $ do
          runMessages
          fieldAssert InvestigatorHand ((== 5) . length) investigator
