module Arkham.Act.Cards.SearchForTheStrangerV1
  ( SearchForTheStrangerV1(..)
  , searchForTheStrangerV1
  ) where

import Arkham.Prelude

import Arkham.Act.Cards qualified as Cards
import Arkham.Act.Runner
import Arkham.Asset.Cards qualified as Assets
import Arkham.Card.PlayerCard
import Arkham.Classes
import Arkham.Helpers.Modifiers
import Arkham.Helpers.Query
import Arkham.Matcher
import Arkham.Message
import Arkham.Target

newtype SearchForTheStrangerV1 = SearchForTheStrangerV1 ActAttrs
  deriving anyclass (IsAct, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

searchForTheStrangerV1 :: ActCard SearchForTheStrangerV1
searchForTheStrangerV1 =
  act (2, A) SearchForTheStrangerV1 Cards.searchForTheStrangerV1 Nothing

instance HasModifiersFor SearchForTheStrangerV1 where
  getModifiersFor _ (EnemyTarget eid) (SearchForTheStrangerV1 a) = do
    isManInThePallidMask <- eid
      `isMatch` EnemyWithTitle "The Main in the Pallid Mask"
    pure $ toModifiers a [ CannotBeDefeated | isManInThePallidMask ]
  getModifiersFor _ _ _ = pure []

instance RunMessage SearchForTheStrangerV1 where
  runMessage msg a@(SearchForTheStrangerV1 attrs) = case msg of
    AdvanceAct aid _ _ | aid == actId attrs && onSide B attrs -> do
      leadInvestigatorId <- getLeadInvestigatorId
      thePallidMask <- genPlayerCard Assets.thePallidMask
      pure
        [ InvestigatorDrewPlayerCard leadInvestigatorId thePallidMask
        , AdvanceActDeck (actDeckId attrs) (toSource attrs)
        ]
      pure a
    _ -> SearchForTheStrangerV1 <$> runMessage msg attrs
