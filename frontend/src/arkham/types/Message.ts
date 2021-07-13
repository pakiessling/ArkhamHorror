import { JsonDecoder } from 'ts.data.json';

export enum MessageType {
  TARGET_LABEL = 'TargetLabel',
  ASK = 'Ask',
  RUN = 'Run',
  READY = 'Ready',
  REMOVE_DOOM = 'RemoveDoom',
  REVEAL_CARD = 'RevealInHand',
  FLAVOR_TEXT = 'FlavorText',
  RESOLUTION = 'Resolution',
  MULLIGAN_CARD = 'MulliganCard',
  CHOOSE_PLAYER_ORDER = 'ChoosePlayerOrder',
  CHOOSE_PLAYER = 'ChoosePlayer',
  TAKE_RESOURCES = 'TakeResources',
  DRAW_CARDS = 'DrawCards',
  PLAY_CARD = 'InitiatePlayCard',
  PLAY_DYNAMIC_CARD = 'InitiatePlayDynamicCard',
  PLAY_FAST_EVENT = 'PlayFastEvent',
  HEAL_DAMAGE = 'HealDamage',
  LEGACY_PLAY_CARD = 'PlayCard',
  INVESTIGATE = 'Investigate',
  END_TURN = 'ChooseEndTurn',
  START_SKILL_TEST = 'StartSkillTest',
  COMMIT_CARD = 'SkillTestCommitCard',
  UNCOMMIT_CARD = 'SkillTestUncommitCard',
  AFTER_DISCOVER_CLUES = 'AfterDiscoverClues',
  NEXT_ACT = 'NextAct',
  ADVANCE_ACT = 'AdvanceAct',
  ADVANCE_AGENDA = 'AdvanceAgenda',
  MOVE = 'MoveAction',
  MOVE_UNTIL = 'MoveUntil',
  MOVE_TO = 'MoveTo',
  CREATE_ENEMY_AT = 'CreateEnemyAt',
  FIGHT_ENEMY = 'FightEnemy',
  EVADE_ENEMY = 'EvadeEnemy',
  ENEMY_EVADED = 'EnemyEvaded',
  ENEMY_DAMAGE = 'EnemyDamage',
  ENEMY_SPAWN = 'EnemySpawn',
  ENEMY_MOVE = 'EnemyMove',
  CONTINUE = 'Continue',
  INVESTIGATOR_DAMAGE = 'InvestigatorDamage',
  INVESTIGATOR_ASSIGN_DAMAGE = 'InvestigatorAssignDamage',
  INVESTIGATOR_SPEND_CLUES = 'InvestigatorSpendClues',
  INVESTIGATOR_PLACE_CLUES_ON_LOCATION = 'InvestigatorPlaceCluesOnLocation',
  ASSET_DAMAGE = 'AssetDamage',
  ENEMY_ATTACK = 'EnemyAttack',
  ENEMY_ENGAGE_INVESTIGATOR = 'EnemyEngageInvestigator',
  ACTIVATE_ABILITY = 'UseAbility',
  ACTIVATE_DYNAMIC_ABILITY='ActivateCardAbilityActionWithDynamicCost',
  USE_CARD_ABILITY = 'UseCardAbility',
  SKILL_TEST_RESULTS = 'SkillTestApplyResults',
  DISCARD = 'Discard',
  DISCARD_CARD = 'DiscardCard',
  CHOOSE_AND_DISCARD_CARD = 'ChooseAndDiscardCard',
  ADD_TO_HAND_FROM_DECK = 'AddToHandFromDeck',
  BEGIN_SKILL_TEST_AFTER_FAST = 'BeginSkillTestAfterFast',
  BEGIN_SKILL_TEST = 'BeginSkillTest',
  SEARCH_TOP_OF_DECK = 'SearchTopOfDeck',
  SEARCH_TOP_OF_DECK_FOUND = 'SearchTopOfDeckFound',
  ADD_FOCUSED_TO_HAND = 'AddFocusedToHand',
  ADD_FOCUSED_TO_TOP_OF_DECK = 'AddFocusedToTopOfDeck',
  ENGAGE_ENEMY = 'EngageEnemy',
  INVESTIGATOR_DRAW_ENCOUNTER_CARD = 'InvestigatorDrawEncounterCard',
  SURGE = 'Surge',
  ATTACH_TREACHERY = 'AttachTreachery',
  PLACE_DOOM = 'PlaceDoom',
  FOUND_AND_DREW_ENCOUNTER_CARD = 'FoundAndDrewEncounterCard',
  FOUND_ENCOUNTER_CARD_FROM = 'FoundEncounterCardFrom',
  FOUND_ENEMY_IN_VOID = 'FoundEnemyInVoid',
  LABEL = 'Label',
  ADD_USES = 'AddUses',
}

export interface Message {
  tag: MessageType;
  label: string | null;
  contents: any; // eslint-disable-line
}

export const messageTypeDecoder = JsonDecoder.oneOf<MessageType>(
  [
    JsonDecoder.isExactly('TargetLabel').then(() => JsonDecoder.constant(MessageType.TARGET_LABEL)),
    JsonDecoder.isExactly('Ask').then(() => JsonDecoder.constant(MessageType.ASK)),
    JsonDecoder.isExactly('Run').then(() => JsonDecoder.constant(MessageType.RUN)),
    JsonDecoder.isExactly('Label').then(() => JsonDecoder.constant(MessageType.LABEL)),
    JsonDecoder.isExactly('RemoveDoom').then(() => JsonDecoder.constant(MessageType.REMOVE_DOOM)),
    JsonDecoder.isExactly('RevealInHand').then(() => JsonDecoder.constant(MessageType.REVEAL_CARD)),
    JsonDecoder.isExactly('FlavorText').then(() => JsonDecoder.constant(MessageType.FLAVOR_TEXT)),
    JsonDecoder.isExactly('Resolution').then(() => JsonDecoder.constant(MessageType.RESOLUTION)),
    JsonDecoder.isExactly('MulliganCard').then(() => JsonDecoder.constant(MessageType.MULLIGAN_CARD)),
    JsonDecoder.isExactly('ChoosePlayer').then(() => JsonDecoder.constant(MessageType.CHOOSE_PLAYER)),
    JsonDecoder.isExactly('ChoosePlayerOrder').then(() => JsonDecoder.constant(MessageType.CHOOSE_PLAYER_ORDER)),
    JsonDecoder.isExactly('TakeResources').then(() => JsonDecoder.constant(MessageType.TAKE_RESOURCES)),
    JsonDecoder.isExactly('DrawCards').then(() => JsonDecoder.constant(MessageType.DRAW_CARDS)),
    JsonDecoder.isExactly('InitiatePlayCard').then(() => JsonDecoder.constant(MessageType.PLAY_CARD)),
    JsonDecoder.isExactly('InitiatePlayDynamicCard').then(() => JsonDecoder.constant(MessageType.PLAY_DYNAMIC_CARD)),
    JsonDecoder.isExactly('PlayFastEvent').then(() => JsonDecoder.constant(MessageType.PLAY_FAST_EVENT)),
    JsonDecoder.isExactly('HealDamage').then(() => JsonDecoder.constant(MessageType.HEAL_DAMAGE)),
    JsonDecoder.isExactly('PlayCard').then(() => JsonDecoder.constant(MessageType.LEGACY_PLAY_CARD)),
    JsonDecoder.isExactly('Investigate').then(() => JsonDecoder.constant(MessageType.INVESTIGATE)),
    JsonDecoder.isExactly('ChooseEndTurn').then(() => JsonDecoder.constant(MessageType.END_TURN)),
    JsonDecoder.isExactly('StartSkillTest').then(() => JsonDecoder.constant(MessageType.START_SKILL_TEST)),
    JsonDecoder.isExactly('SkillTestCommitCard').then(() => JsonDecoder.constant(MessageType.COMMIT_CARD)),
    JsonDecoder.isExactly('SkillTestUncommitCard').then(() => JsonDecoder.constant(MessageType.UNCOMMIT_CARD)),
    JsonDecoder.isExactly('AfterDiscoverClues').then(() => JsonDecoder.constant(MessageType.AFTER_DISCOVER_CLUES)),
    JsonDecoder.isExactly('NextAct').then(() => JsonDecoder.constant(MessageType.NEXT_ACT)),
    JsonDecoder.isExactly('AdvanceAct').then(() => JsonDecoder.constant(MessageType.ADVANCE_ACT)),
    JsonDecoder.isExactly('AdvanceAgenda').then(() => JsonDecoder.constant(MessageType.ADVANCE_AGENDA)),
    JsonDecoder.isExactly('MoveAction').then(() => JsonDecoder.constant(MessageType.MOVE)),
    JsonDecoder.isExactly('MoveUntil').then(() => JsonDecoder.constant(MessageType.MOVE_UNTIL)),
    JsonDecoder.isExactly('MoveTo').then(() => JsonDecoder.constant(MessageType.MOVE_TO)),
    JsonDecoder.isExactly('CreateEnemyAt').then(() => JsonDecoder.constant(MessageType.CREATE_ENEMY_AT)),
    JsonDecoder.isExactly('FightEnemy').then(() => JsonDecoder.constant(MessageType.FIGHT_ENEMY)),
    JsonDecoder.isExactly('EvadeEnemy').then(() => JsonDecoder.constant(MessageType.EVADE_ENEMY)),
    JsonDecoder.isExactly('EnemyEvaded').then(() => JsonDecoder.constant(MessageType.ENEMY_EVADED)),
    JsonDecoder.isExactly('EnemyDamage').then(() => JsonDecoder.constant(MessageType.ENEMY_DAMAGE)),
    JsonDecoder.isExactly('EnemyMove').then(() => JsonDecoder.constant(MessageType.ENEMY_MOVE)),
    JsonDecoder.isExactly('EnemySpawn').then(() => JsonDecoder.constant(MessageType.ENEMY_SPAWN)),
    JsonDecoder.isExactly('Continue').then(() => JsonDecoder.constant(MessageType.CONTINUE)),
    JsonDecoder.isExactly('InvestigatorDamage').then(() => JsonDecoder.constant(MessageType.INVESTIGATOR_DAMAGE)),
    JsonDecoder.isExactly('InvestigatorAssignDamage').then(() => JsonDecoder.constant(MessageType.INVESTIGATOR_ASSIGN_DAMAGE)),
    JsonDecoder.isExactly('InvestigatorSpendClues').then(() => JsonDecoder.constant(MessageType.INVESTIGATOR_SPEND_CLUES)),
    JsonDecoder.isExactly('InvestigatorPlaceCluesOnLocation').then(() => JsonDecoder.constant(MessageType.INVESTIGATOR_PLACE_CLUES_ON_LOCATION)),
    JsonDecoder.isExactly('AssetDamage').then(() => JsonDecoder.constant(MessageType.ASSET_DAMAGE)),
    JsonDecoder.isExactly('EnemyAttack').then(() => JsonDecoder.constant(MessageType.ENEMY_ATTACK)),
    JsonDecoder.isExactly('EnemyEngageInvestigator').then(() => JsonDecoder.constant(MessageType.ENEMY_ENGAGE_INVESTIGATOR)),
    JsonDecoder.isExactly('UseAbility').then(() => JsonDecoder.constant(MessageType.ACTIVATE_ABILITY)),
    JsonDecoder.isExactly('ActivateCardAbilityActionWithDynamicCost').then(() => JsonDecoder.constant(MessageType.ACTIVATE_DYNAMIC_ABILITY)),
    JsonDecoder.isExactly('UseCardAbility').then(() => JsonDecoder.constant(MessageType.USE_CARD_ABILITY)),
    JsonDecoder.isExactly('SkillTestApplyResults').then(() => JsonDecoder.constant(MessageType.SKILL_TEST_RESULTS)),
    JsonDecoder.isExactly('Discard').then(() => JsonDecoder.constant(MessageType.DISCARD)),
    JsonDecoder.isExactly('DiscardCard').then(() => JsonDecoder.constant(MessageType.DISCARD_CARD)),
    JsonDecoder.isExactly('ChooseAndDiscardCard').then(() => JsonDecoder.constant(MessageType.CHOOSE_AND_DISCARD_CARD)),
    JsonDecoder.isExactly('AddToHandFromDeck').then(() => JsonDecoder.constant(MessageType.ADD_TO_HAND_FROM_DECK)),
    JsonDecoder.isExactly('BeginSkillTestAfterFast').then(() => JsonDecoder.constant(MessageType.BEGIN_SKILL_TEST_AFTER_FAST)),
    JsonDecoder.isExactly('BeginSkillTest').then(() => JsonDecoder.constant(MessageType.BEGIN_SKILL_TEST)),
    JsonDecoder.isExactly('SearchTopOfDeck').then(() => JsonDecoder.constant(MessageType.SEARCH_TOP_OF_DECK)),
    JsonDecoder.isExactly('SearchTopOfDeckFound').then(() => JsonDecoder.constant(MessageType.SEARCH_TOP_OF_DECK_FOUND)),
    JsonDecoder.isExactly('AddFocusedToHand').then(() => JsonDecoder.constant(MessageType.ADD_FOCUSED_TO_HAND)),
    JsonDecoder.isExactly('AddFocusedToTopOfDeck').then(() => JsonDecoder.constant(MessageType.ADD_FOCUSED_TO_TOP_OF_DECK)),
    JsonDecoder.isExactly('EngageEnemy').then(() => JsonDecoder.constant(MessageType.ENGAGE_ENEMY)),
    JsonDecoder.isExactly('AttachTreachery').then(() => JsonDecoder.constant(MessageType.ATTACH_TREACHERY)),
    JsonDecoder.isExactly('InvestigatorDrawEncounterCard').then(() => JsonDecoder.constant(MessageType.INVESTIGATOR_DRAW_ENCOUNTER_CARD)),
    JsonDecoder.isExactly('Surge').then(() => JsonDecoder.constant(MessageType.SURGE)),
    JsonDecoder.isExactly('FoundAndDrewEncounterCard').then(() => JsonDecoder.constant(MessageType.FOUND_AND_DREW_ENCOUNTER_CARD)),
    JsonDecoder.isExactly('FoundEncounterCardFrom').then(() => JsonDecoder.constant(MessageType.FOUND_ENCOUNTER_CARD_FROM)),
    JsonDecoder.isExactly('FoundEnemyInVoid').then(() => JsonDecoder.constant(MessageType.FOUND_ENEMY_IN_VOID)),
    JsonDecoder.isExactly('PlaceDoom').then(() => JsonDecoder.constant(MessageType.PLACE_DOOM)),
    JsonDecoder.isExactly('Ready').then(() => JsonDecoder.constant(MessageType.READY)),
    JsonDecoder.isExactly('AddUses').then(() => JsonDecoder.constant(MessageType.ADD_USES)),
  ],
  'MessageType',
);

export const messageDecoder = JsonDecoder.object<Message>(
  {
    tag: messageTypeDecoder,
    label: JsonDecoder.constant(''),
    contents: JsonDecoder.succeed,
  },
  'Message',
);
