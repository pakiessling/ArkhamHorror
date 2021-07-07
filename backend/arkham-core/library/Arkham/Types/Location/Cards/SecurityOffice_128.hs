module Arkham.Types.Location.Cards.SecurityOffice_128
  ( securityOffice_128
  , SecurityOffice_128(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Location.Cards as Cards (securityOffice_128)
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Helpers
import Arkham.Types.Location.Runner
import Arkham.Types.LocationSymbol
import Arkham.Types.Message
import Arkham.Types.Target
import Arkham.Types.Window

newtype SecurityOffice_128 = SecurityOffice_128 LocationAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

securityOffice_128 :: LocationCard SecurityOffice_128
securityOffice_128 = location
  SecurityOffice_128
  Cards.securityOffice_128
  2
  (PerPlayer 1)
  Diamond
  [Square]

instance HasModifiersFor env SecurityOffice_128 where
  getModifiersFor = noModifiersFor

ability :: LocationAttrs -> Ability
ability attrs =
  (mkAbility (toSource attrs) 1 (ActionAbility Nothing $ ActionCost 2))
    { abilityLimit = PlayerLimit PerTurn 1
    }

instance ActionRunner env => HasActions env SecurityOffice_128 where
  getActions iid NonFast (SecurityOffice_128 attrs) =
    withBaseActions iid NonFast attrs
      $ pure [locationAbility iid (ability attrs)]
  getActions iid window (SecurityOffice_128 attrs) =
    getActions iid window attrs

instance LocationRunner env => RunMessage env SecurityOffice_128 where
  runMessage msg l@(SecurityOffice_128 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> l <$ push
      (SearchTopOfDeck
        iid
        source
        (InvestigatorTarget iid)
        6
        mempty
        (ShuffleBackIn $ DrawFound iid)
      )
    _ -> SecurityOffice_128 <$> runMessage msg attrs
