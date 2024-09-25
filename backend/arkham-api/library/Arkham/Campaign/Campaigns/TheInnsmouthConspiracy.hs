module Arkham.Campaign.Campaigns.TheInnsmouthConspiracy (
  TheInnsmouthConspiracy (..),
  theInnsmouthConspiracy,
) where

import Arkham.Asset.Cards qualified as Assets
import Arkham.Campaign.Import.Lifted
import Arkham.CampaignLogKey
import Arkham.Campaigns.TheInnsmouthConspiracy.Import
import Arkham.Helpers.Log
import Arkham.Helpers.Query
import Arkham.I18n
import Arkham.Matcher
import Arkham.Source

newtype TheInnsmouthConspiracy = TheInnsmouthConspiracy CampaignAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasModifiersFor)

theInnsmouthConspiracy :: Difficulty -> TheInnsmouthConspiracy
theInnsmouthConspiracy difficulty =
  campaign
    TheInnsmouthConspiracy
    (CampaignId "07")
    "The Innsmouth Conspiracy"
    difficulty
    (chaosBagContents difficulty)
 where

instance IsCampaign TheInnsmouthConspiracy where
  nextStep a = case campaignStep (toAttrs a) of
    PrologueStep -> Just ThePitOfDespair
    ThePitOfDespair -> Just (InterludeStep 1 Nothing)
    InterludeStep 1 _ -> Just TheVanishingOfElinaHarper
    TheVanishingOfElinaHarper -> Just (InterludeStep 2 Nothing)
    InterludeStep 2 _ -> Just (UpgradeDeckStep InTooDeep)
    EpilogueStep -> Nothing
    UpgradeDeckStep nextStep' -> Just nextStep'
    _ -> Nothing

instance RunMessage TheInnsmouthConspiracy where
  runMessage msg c@(TheInnsmouthConspiracy _attrs) = runQueueT $ withI18n $ scope "theInnsmouthConspiracy" $ case msg of
    CampaignStep PrologueStep -> do
      nextCampaignStep
      pure c
    CampaignStep (InterludeStep 1 _) -> scope "interlude1" do
      story $ i18nWithTitle "part1"
      memoriesRecovered <- getRecordSet MemoriesRecovered
      when (recorded AMeetingWithThomasDawson `elem` memoriesRecovered) $ do
        story $ i18nWithTitle "aMeetingWithThomasDawson"
        selectEach Anyone $ \iid -> gainXp iid CampaignSource (ikey "xp.aMeetingWithThomasDawson") 1
      when (null memoriesRecovered) $ do
        story $ i18nWithTitle "noMemoriesRecovered"
      when (recorded ABattleWithAHorrifyingDevil `elem` memoriesRecovered) $ do
        story $ i18nWithTitle "aBattleWithAHorrifyingDevil"
        selectEach Anyone $ \iid -> gainXp iid CampaignSource (ikey "xp.aBattleWithAHorrifyingDevil") 1
      when (recorded ADecisionToStickTogether `elem` memoriesRecovered) $ do
        story $ i18nWithTitle "aDecisionToStickTogether"
        selectEach Anyone $ \iid -> gainXp iid CampaignSource (ikey "xp.aDecisionToStickTogether") 1
      when (recorded AnEncounterWithASecretCult `elem` memoriesRecovered) $ do
        story $ i18nWithTitle "anEncounterWithASecretCult"
        selectEach Anyone $ \iid -> gainXp iid CampaignSource (ikey "xp.anEncounterWithASecretCult") 1
      story $ i18nWithTitle "part2"
      nextCampaignStep
      pure c
    CampaignStep (InterludeStep 2 _) -> scope "interlude2" do
      story $ i18nWithTitle "theSyzygy1"
      whenHasRecord TheMissionFailed $ story $ i18nWithTitle "theSyzygy2"
      whenHasRecord TheMissionWasSuccessful do
        story $ i18nWithTitle "theSyzygy3"
        investigators <- allInvestigators
        addCampaignCardToDeckChoice investigators Assets.elinaHarperKnowsTooMuch
      story $ i18nWithTitle "theSyzygy4"
      pure c
    _ -> lift $ defaultCampaignRunner msg c
