{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.Easttown where

import Arkham.Import

import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.Trait

newtype Easttown = Easttown Attrs
  deriving newtype (Show, ToJSON, FromJSON)

easttown :: Easttown
easttown = Easttown $ baseAttrs
  "01132"
  "Easttown"
  2
  (PerPlayer 1)
  Moon
  [Circle, Triangle]
  [Arkham]

instance IsInvestigator investigator => HasModifiersFor env investigator Easttown where
  getModifiersFor _ i (Easttown Attrs {..}) =
    pure [ ReduceCostOf [Ally] 2 | getId () i `member` locationInvestigators ]

instance (IsInvestigator investigator) => HasActions env investigator Easttown where
  getActions i window (Easttown attrs) = getActions i window attrs

instance (LocationRunner env) => RunMessage env Easttown where
  runMessage msg (Easttown attrs@Attrs {..}) =
    Easttown <$> runMessage msg attrs

