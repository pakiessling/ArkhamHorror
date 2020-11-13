{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.GuestHall where

import Arkham.Import
import Arkham.Types.Action
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner

newtype GuestHall = GuestHall Attrs
  deriving newtype (Show, ToJSON, FromJSON)

guestHall :: GuestHall
guestHall = GuestHall $ baseAttrs
  "50014"
  "Guest Hall"
  1
  (Static 0)
  T
  [Circle, Heart, Star, Square]
  mempty

instance HasModifiersFor env GuestHall where
  getModifiersFor _ (InvestigatorTarget iid) (GuestHall attrs) = do
    pure [ CannotTakeAction Draw | iid `elem` locationInvestigators attrs ]
  getModifiersFor _ _ _ = pure []

instance ActionRunner env => HasActions env GuestHall where
  getActions i window (GuestHall attrs) = getActions i window attrs

instance (LocationRunner env) => RunMessage env GuestHall where
  runMessage msg (GuestHall attrs) = GuestHall <$> runMessage msg attrs
