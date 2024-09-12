{-# OPTIONS_GHC -Wno-orphans #-}

module Arkham.Investigator.Projection (
  module X,
) where

import Arkham.Card
import {-# SOURCE #-} Arkham.Game ()
import Arkham.GameT
import Arkham.Id
import Arkham.Investigator.Types as X (Field (..))
import Arkham.Matcher
import Arkham.Message
import Arkham.Prelude
import Arkham.Projection
import Arkham.Queue
import Arkham.Slot
import GHC.Records

instance HasField "hand" InvestigatorId (QueueT Message GameT [Card]) where
  getField = field InvestigatorHand

instance HasField "slots" InvestigatorId (SlotType -> QueueT Message GameT [Slot]) where
  getField iid sType = fieldMap InvestigatorSlots (findWithDefault [] sType) iid

instance HasField "filter" (QueueT Message GameT [Card]) (CardMatcher -> QueueT Message GameT [Card]) where
  getField x f = filterCards f <$> x
