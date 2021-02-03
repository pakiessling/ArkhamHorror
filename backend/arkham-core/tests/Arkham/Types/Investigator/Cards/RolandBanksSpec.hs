module Arkham.Types.Investigator.Cards.RolandBanksSpec
  ( spec
  )
where

import TestImport

import Arkham.Types.Enemy.Attrs (EnemyAttrs(..))
import Arkham.Types.Location.Attrs (LocationAttrs(..))

spec :: Spec
spec = describe "Roland Banks" $ do
  context "ability" $ do
    it
        "after defeating an enemy, allows you to discover a clue at your location"
      $ do
          let rolandBanks = lookupInvestigator "01001"
          enemy <- testEnemy
            $ \attrs -> attrs { enemyFight = 4, enemyHealth = Static 1 }
          location <- testLocation "00000"
            $ \attrs -> attrs { locationClues = 1 }
          game <-
            runGameTest
              rolandBanks
              [ SetTokens [Zero]
              , enemySpawn location enemy
              , moveTo rolandBanks location
              , fightEnemy rolandBanks enemy
              ]
              ((enemiesL %~ insertEntity enemy)
              . (locationsL %~ insertEntity location)
              )
            >>= runGameTestOnlyOption "start skill test"
            >>= runGameTestOnlyOption "apply results"
            >>= runGameTestOptionMatching
                  "use ability"
                  (\case
                    Run{} -> True
                    _ -> False
                  )
          getCount (updated game rolandBanks) () `shouldBe` ClueCount 1
  context "elder sign" $ do
    it "gives +1 for each clue on your location" $ do
      let rolandBanks = lookupInvestigator "01001"
      location <- testLocation "00000"
        $ \attrs -> attrs { locationClues = 1, locationShroud = 4 }
      game <-
        runGameTest
          rolandBanks
          [ SetTokens [ElderSign]
          , moveTo rolandBanks location
          , investigate rolandBanks location
          ]
          (locationsL %~ insertEntity location)
        >>= runGameTestOnlyOption "start skill test"
        >>= runGameTestOnlyOption "apply results"
      getCount (updated game rolandBanks) () `shouldBe` ClueCount 1
