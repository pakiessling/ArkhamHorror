{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Asset.Cards.OldBookOfLore where

import Arkham.Json
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.AssetId
import Arkham.Types.Classes
import Arkham.Types.LocationId
import Arkham.Types.Message
import Arkham.Types.Slot
import Arkham.Types.Source
import ClassyPrelude
import qualified Data.HashSet as HashSet
import Lens.Micro

newtype OldBookOfLoreI = OldBookOfLoreI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

oldBookOfLore :: AssetId -> OldBookOfLoreI
oldBookOfLore uuid = OldBookOfLoreI $ (baseAttrs uuid "01031")
  { assetSlots = [HandSlot]
  , assetAbilities =
    [(AssetSource uuid, Nothing, 1, ActionAbility 1 Nothing, NoLimit)]
  }

instance (AssetRunner env) => RunMessage env OldBookOfLoreI where
  runMessage msg (OldBookOfLoreI attrs@Attrs {..}) = case msg of
    UseCardAbility iid (AssetSource aid, _, 1, _, _) | aid == assetId -> do
      locationId <- asks (getId @LocationId iid)
      investigatorIds <- HashSet.toList <$> asks (getSet locationId)
      unshiftMessage
        (Ask
        $ ChooseOne
            [ SearchTopOfDeck iid' 3 [] ShuffleBackIn
            | iid' <- investigatorIds
            ]
        )
      pure $ OldBookOfLoreI $ attrs & exhausted .~ True
    _ -> OldBookOfLoreI <$> runMessage msg attrs
