module Arkham.Location.Cards.WavewornIsland (wavewornIsland, WavewornIsland (..)) where

import Arkham.Ability
import Arkham.Card.CardType
import Arkham.Helpers.Scenario
import Arkham.Location.Cards qualified as Cards
import Arkham.Location.FloodLevel
import Arkham.Location.Grid
import Arkham.Location.Helpers
import Arkham.Location.Import.Lifted
import Arkham.Matcher hiding (RevealLocation)
import Arkham.Matcher qualified as Matcher
import Arkham.Message (Message (RevealLocation))
import Arkham.Scenario.Deck

newtype WavewornIsland = WavewornIsland LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

wavewornIsland :: LocationCard WavewornIsland
wavewornIsland =
  locationWith WavewornIsland Cards.wavewornIsland 4 (Static 0) connectsToAdjacent

instance HasAbilities WavewornIsland where
  getAbilities (WavewornIsland a) =
    extendRevealed1 a $ mkAbility a 1 $ forced $ Matcher.RevealLocation #after Anyone (be a)

instance RunMessage WavewornIsland where
  runMessage msg l@(WavewornIsland attrs) = runQueueT $ case msg of
    UseThisAbility _iid (isSource attrs -> True) 1 -> do
      grid <- getGrid
      tunnels <- take 2 <$> getScenarioDeck TidalTunnelDeck
      unfathomableDepths <- getSetAsideCardsMatching $ CardWithType LocationType

      let
        [p1, p2, p3] = case findInGrid attrs.id grid of
          Just (Pos 0 3) -> [Pos (-1) 3, Pos 1 3, Pos 0 4]
          Just (Pos 4 2) -> [Pos 5 2, Pos 4 1, Pos 4 3]
          Just (Pos 4 (-2)) -> [Pos 5 (-2), Pos 4 (-1), Pos 4 (-3)]
          Just (Pos (-4) 2) -> [Pos (-5) 2, Pos (-4) 1, Pos (-4) 3]
          Just (Pos (-4) (-2)) -> [Pos (-5) (-2), Pos (-4) (-1), Pos (-4) (-3)]
          _ -> error "invalid location"
      zipWithM_ placeLocationInGrid [p1, p2] tunnels

      shuffleM unfathomableDepths >>= \case
        [] -> pure ()
        (x : _) -> placeLocationInGrid_ p3 x
      pure l
    RevealLocation _ lid | lid == attrs.id -> do
      attrs' <- liftRunMessage msg attrs
      pure $ WavewornIsland $ attrs' & floodLevelL ?~ PartiallyFlooded
    _ -> WavewornIsland <$> liftRunMessage msg attrs
