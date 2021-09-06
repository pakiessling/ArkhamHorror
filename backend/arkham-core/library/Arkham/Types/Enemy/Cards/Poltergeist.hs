module Arkham.Types.Enemy.Cards.Poltergeist
  ( poltergeist
  , Poltergeist(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Ability
import qualified Arkham.Types.Action as Action
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Helpers
import Arkham.Types.Enemy.Runner
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import Arkham.Types.Trait

newtype Poltergeist = Poltergeist EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

poltergeist :: EnemyCard Poltergeist
poltergeist = enemy Poltergeist Cards.poltergeist (3, Static 2, 4) (0, 2)

instance HasAbilities Poltergeist where
  getAbilities (Poltergeist a) = withBaseAbilities
    a
    [ restrictedAbility a 1 OnSameLocation
      $ ActionAbility (Just Action.Parley)
      $ ActionCost 1
    ]

instance HasModifiersFor env Poltergeist where
  getModifiersFor _ (EnemyTarget eid) (Poltergeist a) | toId a == eid =
    pure $ toModifiers
      a
      [ CannotBeDamagedByPlayerSourcesExcept $ SourceMatchesAny $ map
          SourceWithTrait
          [Spell, Relic]
      ]
  getModifiersFor _ _ _ = pure []

instance EnemyRunner env => RunMessage env Poltergeist where
  runMessage msg e@(Poltergeist attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> e <$ push
      (BeginSkillTest
        iid
        source
        (toTarget attrs)
        (Just Action.Parley)
        SkillIntellect
        3
      )
    PassedSkillTest iid _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> e
      <$ push (EnemyDamage (toId attrs) iid source 1)
    EnemyDamage eid _ source _ | eid == toId attrs -> do
      let matches = any (`elem` [Spell, Relic])
      damaged <- case source of
        AssetSource asset -> matches <$> getSet asset
        EventSource event -> matches <$> getSet event
        SkillSource skill -> matches <$> getSet skill
        InvestigatorSource investigator -> matches <$> getSet investigator
        _ -> pure True
      if damaged then Poltergeist <$> runMessage msg attrs else pure e
    _ -> Poltergeist <$> runMessage msg attrs
