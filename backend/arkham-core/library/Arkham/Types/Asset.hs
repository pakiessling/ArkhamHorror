{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Asset
  ( lookupAsset
  , allAssets
  , isDamageable
  , Asset
  )
where

import Arkham.Json
import Arkham.Types.Ability
import qualified Arkham.Types.Action as Action
import Arkham.Types.Asset.Uses (Uses(..))
import qualified Arkham.Types.Asset.Uses as Resource
import Arkham.Types.AssetId
import Arkham.Types.Card
import Arkham.Types.Card.Id
import Arkham.Types.Classes
import qualified Arkham.Types.FastWindow as Fast
import Arkham.Types.Helpers
import Arkham.Types.InvestigatorId
import Arkham.Types.LocationId
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Query
import Arkham.Types.SkillType
import Arkham.Types.Slot
import Arkham.Types.Source
import Arkham.Types.Target
import qualified Arkham.Types.Token as Token
import Arkham.Types.Trait
import ClassyPrelude
import Data.Coerce
import qualified Data.HashMap.Strict as HashMap
import qualified Data.HashSet as HashSet
import Lens.Micro
import Lens.Micro.Extras
import Safe (fromJustNote)

lookupAsset :: CardCode -> (AssetId -> Asset)
lookupAsset = fromJustNote "Unkown asset" . flip HashMap.lookup allAssets

allAssets :: HashMap CardCode (AssetId -> Asset)
allAssets = HashMap.fromList
  [ ("01006", rolands38Special)
  , ("01008", daisysToteBag)
  , ("01016", fortyFiveAutomatic)
  , ("01017", physicalTraining)
  , ("01020", machete)
  , ("01021", guardDog)
  , ("01030", magnifyingGlass)
  , ("01031", oldBookOfLore)
  , ("01032", researchLibrarian)
  , ("01059", holyRosary)
  , ("01060", shrivelling)
  , ("01086", knife)
  , ("01087", flashlight)
  , ("01117", litaChantler)
  ]

instance HasCardCode Asset where
  getCardCode = assetCardCode . assetAttrs

instance HasAbilities Asset where
  getAbilities a =
    let attrs = assetAttrs a
    in if assetExhausted attrs then [] else assetAbilities attrs

instance HasTraits Asset where
  getTraits = assetTraits . assetAttrs

instance HasId (Maybe OwnerId) () Asset where
  getId _ = (OwnerId <$>) . assetInvestigator . assetAttrs

data Attrs = Attrs
  { assetName :: Text
  , assetId :: AssetId
  , assetCardCode :: CardCode
  , assetCost :: Int
  , assetInvestigator :: Maybe InvestigatorId
  , assetActions :: [Message]
  , assetSlots :: [Slot]
  , assetHealth :: Maybe Int
  , assetSanity :: Maybe Int
  , assetHealthDamage :: Int
  , assetSanityDamage :: Int
  , assetTraits :: HashSet Trait
  , assetAbilities :: [Ability]
  , assetUses :: Uses
  , assetExhausted :: Bool
  }
  deriving stock (Show, Generic)

instance ToJSON Attrs where
  toJSON = genericToJSON $ aesonOptions $ Just "asset"
  toEncoding = genericToEncoding $ aesonOptions $ Just "asset"

instance FromJSON Attrs where
  parseJSON = genericParseJSON $ aesonOptions $ Just "asset"

defeated :: Attrs -> Bool
defeated Attrs {..} =
  maybe False (assetHealthDamage >=) assetHealth
    || maybe False (assetSanityDamage >=) assetSanity

data Asset
  = Rolands38Special Rolands38SpecialI
  | DaisysToteBag DaisysToteBagI
  | FortyFiveAutomatic FortyFiveAutomaticI
  | PhysicalTraining PhysicalTrainingI
  | Machete MacheteI
  | GuardDog GuardDogI
  | MagnifyingGlass MagnifyingGlassI
  | OldBookOfLore OldBookOfLoreI
  | ResearchLibrarian ResearchLibrarianI
  | HolyRosary HolyRosaryI
  | Shrivelling ShrivellingI
  | Knife KnifeI
  | Flashlight FlashlightI
  | LitaChantler LitaChantlerI
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

assetAttrs :: Asset -> Attrs
assetAttrs = \case
  Rolands38Special attrs -> coerce attrs
  DaisysToteBag attrs -> coerce attrs
  FortyFiveAutomatic attrs -> coerce attrs
  PhysicalTraining attrs -> coerce attrs
  Machete attrs -> coerce attrs
  GuardDog attrs -> coerce attrs
  MagnifyingGlass attrs -> coerce attrs
  OldBookOfLore attrs -> coerce attrs
  ResearchLibrarian attrs -> coerce attrs
  HolyRosary attrs -> coerce attrs
  Shrivelling (ShrivellingI (attrs `With` _)) -> attrs
  Knife attrs -> coerce attrs
  Flashlight attrs -> coerce attrs
  LitaChantler attrs -> coerce attrs

isDamageable :: Asset -> Bool
isDamageable a =
  (isJust . assetHealth . assetAttrs $ a)
    || (isJust . assetHealth . assetAttrs $ a)

baseAttrs :: AssetId -> CardCode -> Attrs
baseAttrs aid cardCode =
  let
    MkPlayerCard {..} =
      fromJustNote
          "missing player card"
          (HashMap.lookup cardCode allPlayerCards)
        $ CardId (unAssetId aid)
  in
    Attrs
      { assetName = pcName
      , assetId = aid
      , assetCardCode = cardCode
      , assetCost = pcCost
      , assetInvestigator = Nothing
      , assetActions = mempty
      , assetSlots = mempty
      , assetHealth = Nothing
      , assetSanity = Nothing
      , assetHealthDamage = 0
      , assetSanityDamage = 0
      , assetTraits = HashSet.fromList pcTraits
      , assetAbilities = mempty
      , assetUses = NoUses
      , assetExhausted = False
      }

exhausted :: Lens' Attrs Bool
exhausted = lens assetExhausted $ \m x -> m { assetExhausted = x }

uses :: Lens' Attrs Uses
uses = lens assetUses $ \m x -> m { assetUses = x }

investigator :: Lens' Attrs (Maybe InvestigatorId)
investigator = lens assetInvestigator $ \m x -> m { assetInvestigator = x }

getInvestigator :: Attrs -> InvestigatorId
getInvestigator = fromJustNote "asset must be owned" . view investigator

healthDamage :: Lens' Attrs Int
healthDamage = lens assetHealthDamage $ \m x -> m { assetHealthDamage = x }

sanityDamage :: Lens' Attrs Int
sanityDamage = lens assetSanityDamage $ \m x -> m { assetSanityDamage = x }

abilities :: Lens' Attrs [Ability]
abilities = lens assetAbilities $ \m x -> m { assetAbilities = x }

newtype Rolands38SpecialI = Rolands38SpecialI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

rolands38Special :: AssetId -> Asset
rolands38Special uuid =
  Rolands38Special $ Rolands38SpecialI $ (baseAttrs uuid "01006")
    { assetSlots = [HandSlot]
    }

newtype DaisysToteBagI = DaisysToteBagI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

daisysToteBag :: AssetId -> Asset
daisysToteBag uuid = DaisysToteBag $ DaisysToteBagI $ baseAttrs uuid "01008"

newtype FortyFiveAutomaticI = FortyFiveAutomaticI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

fortyFiveAutomatic :: AssetId -> Asset
fortyFiveAutomatic uuid =
  FortyFiveAutomatic $ FortyFiveAutomaticI $ (baseAttrs uuid "01016")
    { assetSlots = [HandSlot]
    }

newtype PhysicalTrainingI = PhysicalTrainingI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

physicalTraining :: AssetId -> Asset
physicalTraining uuid = PhysicalTraining $ PhysicalTrainingI $ (baseAttrs
                                                                 uuid
                                                                 "01017"
                                                               )
  { assetAbilities =
    [ ( AssetSource uuid
      , 1
      , FreeAbility (SkillTestWindow SkillWillpower)
      , NoLimit
      )
    , (AssetSource uuid, 2, FreeAbility (SkillTestWindow SkillCombat), NoLimit)
    ]
  }

newtype MacheteI = MacheteI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

machete :: AssetId -> Asset
machete uuid = Machete $ MacheteI $ (baseAttrs uuid "01020")
  { assetSlots = [HandSlot]
  , assetAbilities =
    [(AssetSource uuid, 1, ActionAbility 1 (Just Action.Fight), NoLimit)]
  }

newtype GuardDogI = GuardDogI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

guardDog :: AssetId -> Asset
guardDog uuid = GuardDog $ GuardDogI $ (baseAttrs uuid "01021")
  { assetSlots = [AllySlot]
  , assetHealth = Just 3
  , assetSanity = Just 1
  }

newtype MagnifyingGlassI = MagnifyingGlassI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

magnifyingGlass :: AssetId -> Asset
magnifyingGlass uuid =
  MagnifyingGlass $ MagnifyingGlassI $ (baseAttrs uuid "01030")
    { assetSlots = [HandSlot]
    }

newtype OldBookOfLoreI = OldBookOfLoreI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

oldBookOfLore :: AssetId -> Asset
oldBookOfLore uuid = OldBookOfLore $ OldBookOfLoreI $ (baseAttrs uuid "01031")
  { assetSlots = [HandSlot]
  , assetAbilities = [(AssetSource uuid, 1, ActionAbility 1 Nothing, NoLimit)]
  }

newtype ResearchLibrarianI = ResearchLibrarianI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

researchLibrarian :: AssetId -> Asset
researchLibrarian uuid =
  ResearchLibrarian $ ResearchLibrarianI $ (baseAttrs uuid "01032")
    { assetSlots = [AllySlot]
    , assetHealth = Just 1
    , assetSanity = Just 1
    }

newtype HolyRosaryI = HolyRosaryI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

holyRosary :: AssetId -> Asset
holyRosary uuid = HolyRosary $ HolyRosaryI $ (baseAttrs uuid "01059")
  { assetSlots = [AccessorySlot]
  , assetSanity = Just 2
  }

newtype ShrivellingMetadata = ShrivellingMetadata { inUse :: Bool }
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON) -- must parse to object

newtype ShrivellingI = ShrivellingI (Attrs `With` ShrivellingMetadata)
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

shrivelling :: AssetId -> Asset
shrivelling uuid =
  Shrivelling
    $ ShrivellingI
    $ ((baseAttrs uuid "01060") { assetSlots = [ArcaneSlot] })
    `with` ShrivellingMetadata False

newtype KnifeI = KnifeI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

knife :: AssetId -> Asset
knife uuid =
  Knife $ KnifeI $ (baseAttrs uuid "01086") { assetSlots = [HandSlot] }

newtype FlashlightI = FlashlightI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

flashlight :: AssetId -> Asset
flashlight uuid = Flashlight $ FlashlightI $ (baseAttrs uuid "01087")
  { assetSlots = [HandSlot]
  }

newtype LitaChantlerI = LitaChantlerI Attrs
  deriving newtype (Show, ToJSON, FromJSON)

litaChantler :: AssetId -> Asset
litaChantler uuid = LitaChantler $ LitaChantlerI $ (baseAttrs uuid "01117")
  { assetSlots = [AllySlot]
  , assetHealth = Just 3
  , assetSanity = Just 3
  }

type AssetRunner env
  = ( HasQueue env
    , HasSet InvestigatorId () env
    , HasSet InvestigatorId LocationId env
    , HasId LocationId InvestigatorId env
    , HasCount EnemyCount InvestigatorId env
    , HasCount ClueCount LocationId env
    , HasCount ResourceCount InvestigatorId env
    , HasList DeckCard (InvestigatorId, Trait) env
    )

instance (AssetRunner env) => RunMessage env Asset where
  runMessage msg = \case
    Rolands38Special x -> Rolands38Special <$> runMessage msg x
    DaisysToteBag x -> DaisysToteBag <$> runMessage msg x
    FortyFiveAutomatic x -> FortyFiveAutomatic <$> runMessage msg x
    PhysicalTraining x -> PhysicalTraining <$> runMessage msg x
    Machete x -> Machete <$> runMessage msg x
    GuardDog x -> GuardDog <$> runMessage msg x
    MagnifyingGlass x -> MagnifyingGlass <$> runMessage msg x
    OldBookOfLore x -> OldBookOfLore <$> runMessage msg x
    ResearchLibrarian x -> ResearchLibrarian <$> runMessage msg x
    HolyRosary x -> HolyRosary <$> runMessage msg x
    Shrivelling x -> Shrivelling <$> runMessage msg x
    Knife x -> Knife <$> runMessage msg x
    Flashlight x -> Flashlight <$> runMessage msg x
    LitaChantler x -> LitaChantler <$> runMessage msg x

instance (AssetRunner env) => RunMessage env Rolands38SpecialI where
  runMessage msg a@(Rolands38SpecialI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset _ aid | aid == assetId -> do
      let
        attrs' =
          attrs
            & (uses .~ Uses Resource.Ammo 4)
            & (abilities
              .~ [ ( AssetSource aid
                   , 1
                   , ActionAbility 1 (Just Action.Fight)
                   , NoLimit
                   )
                 ]
              )
      Rolands38SpecialI <$> runMessage msg attrs'
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId ->
      case assetUses of
        Uses Resource.Ammo n -> do
          when
            (n == 1)
            (unshiftMessage (RemoveAbilitiesFrom (AssetSource assetId)))
          locationId <- asks (getId @LocationId iid)
          clueCount <- unClueCount <$> asks (getCount locationId)
          let skillModifier = if clueCount == 0 then 1 else 3
          unshiftMessage
            (ChooseFightEnemy
              iid
              SkillCombat
              [ DamageDealt 1 (AssetSource aid)
              , SkillModifier SkillCombat skillModifier (AssetSource aid)
              ]
              True
            )
          pure $ Rolands38SpecialI $ attrs & uses .~ Uses Resource.Ammo (n - 1)
        _ -> pure a
    _ -> Rolands38SpecialI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env DaisysToteBagI where
  runMessage msg (DaisysToteBagI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset iid aid | aid == assetId -> do
      unshiftMessages
        [ AddModifier
          (InvestigatorTarget iid)
          (AddSlot TomeSlot (AssetSource aid))
        , AddModifier
          (InvestigatorTarget iid)
          (AddSlot TomeSlot (AssetSource aid))
        ]
      DaisysToteBagI <$> runMessage msg attrs
    _ -> DaisysToteBagI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env FortyFiveAutomaticI where
  runMessage msg a@(FortyFiveAutomaticI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset _ aid | aid == assetId ->
      pure
        $ FortyFiveAutomaticI
        $ attrs
        & (uses .~ Uses Resource.Ammo 4)
        & (abilities
          .~ [ ( AssetSource aid
               , 1
               , ActionAbility 1 (Just Action.Fight)
               , NoLimit
               )
             ]
          )
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId ->
      case assetUses of
        Uses Resource.Ammo n -> do
          when
            (n == 1)
            (unshiftMessage (RemoveAbilitiesFrom (AssetSource assetId)))
          unshiftMessage
            (ChooseFightEnemy
              iid
              SkillCombat
              [ DamageDealt 1 (AssetSource aid)
              , SkillModifier SkillCombat 1 (AssetSource aid)
              ]
              True
            )
          pure $ FortyFiveAutomaticI $ attrs & uses .~ Uses
            Resource.Ammo
            (n - 1)
        _ -> pure a
    _ -> FortyFiveAutomaticI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env PhysicalTrainingI where
  runMessage msg a@(PhysicalTrainingI attrs@Attrs {..}) = case msg of
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId -> do
      resources <- unResourceCount <$> asks (getCount iid)
      when (resources > 0) $ unshiftMessages
        [ SpendResources iid 1
        , AddModifier
          SkillTestTarget
          (SkillModifier SkillWillpower 1 (AssetSource aid))
        ]
      pure a
    UseCardAbility iid ((AssetSource aid), 2, _, _) | aid == assetId -> do
      resources <- unResourceCount <$> asks (getCount iid)
      when (resources > 0) $ unshiftMessages
        [ SpendResources iid 1
        , AddModifier
          SkillTestTarget
          (SkillModifier SkillCombat 1 (AssetSource aid))
        ]
      pure a
    _ -> PhysicalTrainingI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env GuardDogI where
  runMessage msg (GuardDogI attrs@Attrs {..}) = case msg of
    AssetDamage aid eid _ _ | aid == assetId -> do
      -- we must unshift the asset destroyed first before unshifting the question
      -- this is necessary to keep the asset as a valid investigator source of damage
      -- for any additional effects, such as triggering Roland's ability.
      result <- runMessage msg attrs
      unshiftMessage
        (Ask $ ChooseTo
          (EnemyDamage eid (getInvestigator attrs) (AssetSource aid) 1)
        )
      pure $ GuardDogI result
    _ -> GuardDogI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env OldBookOfLoreI where
  runMessage msg (OldBookOfLoreI attrs@Attrs {..}) = case msg of
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId -> do
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

instance (AssetRunner env) => RunMessage env MagnifyingGlassI where
  runMessage msg (MagnifyingGlassI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset iid aid | aid == assetId -> do
      unshiftMessage
        (AddModifier
          (InvestigatorTarget iid)
          (ActionSkillModifier
            Action.Investigate
            SkillIntellect
            1
            (AssetSource aid)
          )
        )
      MagnifyingGlassI <$> runMessage msg attrs
    _ -> MagnifyingGlassI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env ResearchLibrarianI where
  runMessage msg a@(ResearchLibrarianI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset iid aid | aid == assetId -> do
      unshiftMessage
        (Ask $ ChooseOne
          [ UseCardAbility
            iid
            (AssetSource assetId, 1, ReactionAbility Fast.Now, NoLimit)
          , Continue "Do not use ability"
          ]
        )
      ResearchLibrarianI <$> runMessage msg attrs
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId -> do
      tomes <- map unDeckCard <$> asks (getList (iid, Tome))
      a <$ unshiftMessage
        (Ask $ ChooseOneFromSource $ MkChooseOneFromSource
          { chooseOneSource = DeckSource
          , chooseOneChoices = map
            (\tome -> label
              (unCardCode $ pcCardCode tome)
              (AddToHandFromDeck iid (pcId tome))
            )
            tomes
          }
        )
    _ -> ResearchLibrarianI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env HolyRosaryI where
  runMessage msg (HolyRosaryI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset iid aid | aid == assetId -> do
      unshiftMessage
        (AddModifier
          (InvestigatorTarget iid)
          (SkillModifier SkillWillpower 1 (AssetSource aid))
        )
      HolyRosaryI <$> runMessage msg attrs
    _ -> HolyRosaryI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env MacheteI where
  runMessage msg a@(MacheteI attrs@Attrs {..}) = case msg of
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId -> do
      engagedEnemiesCount <- unEnemyCount <$> asks (getCount iid)
      let
        damageDealtModifiers = if engagedEnemiesCount == 1
          then [DamageDealt 1 (AssetSource aid)]
          else []
      unshiftMessage
        (ChooseFightEnemy
          iid
          SkillCombat
          (damageDealtModifiers
          <> [SkillModifier SkillCombat 1 (AssetSource aid)]
          )
          True
        )
      pure a
    _ -> MacheteI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env ShrivellingI where
  runMessage msg a@(ShrivellingI (attrs@Attrs {..} `With` metadata@ShrivellingMetadata {..}))
    = case msg of
      InvestigatorPlayAsset _ aid | aid == assetId -> do
        let
          attrs' =
            attrs
              & (uses .~ Uses Resource.Charge 4)
              & (abilities
                .~ [ ( AssetSource aid
                     , 1
                     , ActionAbility 1 (Just Action.Fight)
                     , NoLimit
                     )
                   ]
                )
        ShrivellingI . (`with` metadata) <$> runMessage msg attrs'
      SkillTestEnded _ tokens | inUse -> do
        when
            (any
              (`elem` [ Token.Skull
                      , Token.Cultist
                      , Token.Tablet
                      , Token.ElderThing
                      , Token.AutoFail
                      ]
              )
              tokens
            )
          $ unshiftMessage
              (InvestigatorDamage
                (getInvestigator attrs)
                (AssetSource assetId)
                0
                1
              )
        pure $ ShrivellingI (attrs `with` ShrivellingMetadata False)
      UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId ->
        case assetUses of
          Uses Resource.Charge n -> do
            when
              (n == 1)
              (unshiftMessage (RemoveAbilitiesFrom (AssetSource assetId)))
            unshiftMessage
              (ChooseFightEnemy
                iid
                SkillWillpower
                [DamageDealt 1 (AssetSource aid)]
                True
              )
            pure
              $ ShrivellingI
              . (`with` ShrivellingMetadata True)
              $ attrs
              & uses
              .~ Uses Resource.Charge (n - 1)
          _ -> pure a
      _ -> ShrivellingI . (`with` metadata) <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env KnifeI where
  runMessage msg a@(KnifeI attrs@Attrs {..}) = case msg of
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId -> do
      unshiftMessage
        (ChooseFightEnemy
          iid
          SkillCombat
          [SkillModifier SkillCombat 1 (AssetSource aid)]
          True
        )
      pure a
    UseCardAbility iid ((AssetSource aid), 2, _, _) | aid == assetId -> do
      unshiftMessages
        [ DiscardAsset aid
        , ChooseFightEnemy
          iid
          SkillCombat
          [ SkillModifier SkillCombat 2 (AssetSource aid)
          , DamageDealt 1 (AssetSource aid)
          ]
          True
        ]
      pure a
    _ -> KnifeI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env FlashlightI where
  runMessage msg a@(FlashlightI attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset _ aid | aid == assetId ->
      pure
        $ FlashlightI
        $ attrs
        & (uses .~ Uses Resource.Supply 3)
        & (abilities
          .~ [ ( AssetSource aid
               , 1
               , ActionAbility 1 (Just Action.Investigate)
               , NoLimit
               )
             ]
          )
    UseCardAbility iid ((AssetSource aid), 1, _, _) | aid == assetId ->
      case assetUses of
        Uses Resource.Supply n -> do
          when
            (n == 1)
            (unshiftMessage (RemoveAbilitiesFrom (AssetSource assetId)))
          lid <- asks (getId iid)
          unshiftMessages
            [ AddModifier
              (LocationTarget lid)
              (ShroudModifier (-2) (AssetSource aid))
            , Investigate iid lid SkillIntellect False
            , RemoveAllModifiersOnTargetFrom
              (LocationTarget lid)
              (AssetSource aid)
            ]
          pure $ FlashlightI $ attrs & uses .~ Uses Resource.Supply (n - 1)
        _ -> pure a
    _ -> FlashlightI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env LitaChantlerI where
  runMessage msg a@(LitaChantlerI attrs@Attrs {..}) = case msg of
    WhenAttackEnemy iid eid -> case assetInvestigator of
      Just ownerId -> do
        locationId <- asks (getId @LocationId ownerId)
        locationInvestigatorIds <- HashSet.toList <$> asks (getSet locationId)
        if iid `elem` locationInvestigatorIds
          then a <$ unshiftMessage
            (Ask
            $ ChooseTo
                (AddModifier
                  (EnemyTarget eid)
                  (DamageTaken 1 (AssetSource assetId))
                )
            )
          else pure a
      _ -> pure a
    AfterAttackEnemy _ eid -> a <$ unshiftMessage
      (RemoveAllModifiersOnTargetFrom (EnemyTarget eid) (AssetSource assetId))
    PostPlayerWindow -> do
      allInvestigatorIds <- HashSet.toList <$> asks (getSet ())
      case assetInvestigator of
        Just ownerId -> do
          locationId <- asks (getId @LocationId ownerId)
          locationInvestigatorIds <- HashSet.toList <$> asks (getSet locationId)
          unshiftMessages $ map
            (flip
                AddModifier
                (SkillModifier SkillCombat 1 (AssetSource assetId))
            . InvestigatorTarget
            )
            locationInvestigatorIds
        _ -> pure ()
      unshiftMessages $ map
        (\iid -> RemoveAllModifiersOnTargetFrom
          (InvestigatorTarget iid)
          (AssetSource assetId)
        )
        allInvestigatorIds
      pure a
    _ -> LitaChantlerI <$> runMessage msg attrs

instance (AssetRunner env) => RunMessage env Attrs where
  runMessage msg a@Attrs {..} = case msg of
    ReadyExhausted -> pure $ a & exhausted .~ False
    AddAbility (AssetSource aid) ability | aid == assetId ->
      pure $ a & abilities %~ (<> [ability])
    RemoveAbilitiesFrom source -> do
      let
        abilities' =
          filter (\(source', _, _, _) -> source /= source') assetAbilities
      pure $ a & abilities .~ abilities'
    AssetDamage aid _ health sanity | aid == assetId -> do
      let a' = a & healthDamage +~ health & sanityDamage +~ sanity
      when (defeated a') (unshiftMessage (AssetDefeated aid))
      pure a'
    AssetDiscarded aid _ | aid == assetId -> case assetInvestigator of
      Nothing -> pure a
      Just iid -> a <$ unshiftMessage
        (RemoveAllModifiersOnTargetFrom
          (InvestigatorTarget iid)
          (AssetSource aid)
        )
    InvestigatorPlayAsset iid aid | aid == assetId ->
      pure $ a & investigator ?~ iid
    TakeControlOfAsset iid aid | aid == assetId ->
      pure $ a & investigator ?~ iid
    _ -> pure a
