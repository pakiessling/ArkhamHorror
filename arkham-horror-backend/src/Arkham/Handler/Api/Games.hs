{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
module Arkham.Handler.Api.Games where

import Import
import Json

newtype ArkhamCardFront = ArkhamCardFront { frontUrl :: Text }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "front") ArkhamCardFront

newtype ArkhamCardBack = ArkhamCardBack { backUrl :: Text }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "back") ArkhamCardBack

data ArkhamCard = ArkhamCard
  { cardFront :: ArkhamCardFront
  , cardBack :: ArkhamCardBack
  }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "card") ArkhamCard

newtype Agenda = Agenda { agendaCurrentCard :: ArkhamCard }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "agenda") Agenda

newtype Act = Act { actCurrentCard :: ArkhamCard }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "act") Act

data Stack = StackAgenda Agenda | StackAct Act
  deriving stock (Generic)
  deriving (ToJSON) via TaggedJson Stack

newtype ArkhamHorrorCycle = ArkhamHorrorCycle
  { cycleName :: Text
  }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "cycle") ArkhamHorrorCycle

data ArkhamHorrorScenario = ArkhamHorrorScenario
  { scenarioName :: Text
  , scenarioStacks :: [Stack]
  }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "scenario") ArkhamHorrorScenario

data GameJson = GameJson
  { gameCycle :: Maybe ArkhamHorrorCycle
  , gameScenario :: ArkhamHorrorScenario
  }
  deriving stock (Generic)
  deriving (ToJSON) via Codec (Drop "game") GameJson

getApiV1ArkhamGameR :: ArkhamHorrorGameId -> Handler GameJson
getApiV1ArkhamGameR _ = pure $ GameJson (Just cycle) scenario
  where
    cycle = ArkhamHorrorCycle "Night of the Zealot"
    scenario = ArkhamHorrorScenario "The Gathering"
      [ StackAgenda $ Agenda $ ArkhamCard (ArkhamCardFront "https://arkhamdb.com/bundles/cards/01105.jpg") (ArkhamCardBack "https://arkhamdb.com/bundles/cards/01105b.jpg")
      ]
