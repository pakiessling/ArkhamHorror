module Api.Handler.Arkham.Decks
  ( getApiV1ArkhamDecksR
  , postApiV1ArkhamDecksR
  , deleteApiV1ArkhamDeckR
  , putApiV1ArkhamGameDecksR
  ) where

import Import hiding (delete, on, (==.))

import Api.Arkham.Helpers
import Arkham.Game
import Arkham.PlayerCard
import Arkham.Types.Card.CardCode
import Arkham.Types.Game
import Arkham.Types.Helpers
import Arkham.Types.Id
import Arkham.Types.Message
import Control.Monad.Random (mkStdGen)
import Control.Monad.Validate (dispute, runValidate)
import Data.Coerce
import Database.Esqueleto.Experimental hiding (isNothing)
import Json
import Network.HTTP.Conduit (simpleHttp)
import Safe (fromJustNote)

getApiV1ArkhamDecksR :: Handler [Entity ArkhamDeck]
getApiV1ArkhamDecksR = do
  userId <- fromJustNote "Not authenticated" <$> getRequestUserId
  runDB $ select $ do
    decks <- from $ table @ArkhamDeck
    where_ (decks ^. ArkhamDeckUserId ==. val userId)
    pure decks

data CreateDeckPost = CreateDeckPost
  { deckId :: Text
  , deckName :: Text
  , deckUrl :: Text
  }
  deriving stock (Show, Generic)
  deriving anyclass FromJSON

newtype UpgradeDeckPost = UpgradeDeckPost
  { udpDeckUrl :: Maybe Text
  }
  deriving stock (Show, Generic)

instance FromJSON UpgradeDeckPost where
  parseJSON = genericParseJSON $ aesonOptions $ Just "udp"

newtype DeckError = UnimplementedCard CardCode
  deriving stock (Show, Eq, Generic)

instance ToJSON DeckError where
  toJSON = genericToJSON $ defaultOptions { tagSingleConstructors = True }

validateDeck :: ArkhamDeck -> Either [DeckError] ArkhamDeck
validateDeck deck = runValidate $ do
  for_ cardCodes $ \cardCode -> when
    (isNothing $ lookup cardCode allPlayerCards)
    (dispute [UnimplementedCard cardCode])
  pure deck
 where
  decklist = arkhamDeckList deck
  cardCodes = keys $ slots decklist

postApiV1ArkhamDecksR :: Handler (Entity ArkhamDeck)
postApiV1ArkhamDecksR = do
  userId <- fromJustNote "Not authenticated" <$> getRequestUserId
  postData <- requireCheckJsonBody
  edeck <- fromPostData userId postData
  case edeck of
    Left err -> error err
    Right deck -> do
      case validateDeck deck of
        Left err -> sendStatusJSON status400 err
        Right deck' -> runDB $ insertEntity deck'

putApiV1ArkhamGameDecksR :: ArkhamGameId -> Handler ()
putApiV1ArkhamGameDecksR gameId = do
  userId <- fromJustNote "Not authenticated" <$> getRequestUserId
  ArkhamGame {..} <- runDB $ get404 gameId
  ArkhamPlayer {..} <- runDB $ entityVal <$> getBy404
    (UniquePlayer userId gameId)
  postData <- requireCheckJsonBody
  let
    Game {..} = arkhamGameCurrentData
    investigatorId = coerce arkhamPlayerInvestigatorId
  msg <- case udpDeckUrl postData of
    Nothing -> pure $ Done "done"
    Just deckUrl -> do
      edecklist <- getDeckList deckUrl
      case edecklist of
        Left err -> error $ show err
        Right decklist -> do
          cards <- liftIO $ loadDecklistCards decklist
          pure $ UpgradeDeck investigatorId (Deck cards)

  let currentQueue = maybe [] choiceMessages $ headMay arkhamGameChoices

  gameRef <- newIORef arkhamGameCurrentData
  queueRef <- newIORef (msg : currentQueue)
  genRef <- newIORef (mkStdGen gameSeed)
  runGameApp
    (GameApp gameRef queueRef genRef $ pure . const ())
    (runMessages Nothing)
  ge <- readIORef gameRef

  let
    diffUp = diff arkhamGameCurrentData ge
    diffDown = diff ge arkhamGameCurrentData
  updatedQueue <- readIORef queueRef
  let updatedMessages = []
  writeChannel <- getChannel gameId
  liftIO $ atomically $ writeTChan
    writeChannel
    (encode $ GameUpdate $ PublicGame gameId arkhamGameName updatedMessages ge)
  runDB $ replace
    gameId
    (ArkhamGame
      arkhamGameName
      ge
      (Choice diffUp diffDown updatedQueue : arkhamGameChoices)
      updatedMessages
      arkhamGameMultiplayerVariant
    )

fromPostData
  :: (MonadIO m) => UserId -> CreateDeckPost -> m (Either String ArkhamDeck)
fromPostData userId CreateDeckPost {..} = do
  edecklist <- getDeckList deckUrl
  pure $ do
    decklist <- edecklist
    pure $ ArkhamDeck
      { arkhamDeckUserId = userId
      , arkhamDeckInvestigatorName = tshow $ investigator_name decklist
      , arkhamDeckName = deckName
      , arkhamDeckList = decklist
      }

getDeckList :: MonadIO m => Text -> m (Either String ArkhamDBDecklist)
getDeckList url = liftIO $ eitherDecode <$> simpleHttp (unpack url)

deleteApiV1ArkhamDeckR :: ArkhamDeckId -> Handler ()
deleteApiV1ArkhamDeckR deckId = do
  userId <- fromJustNote "Not authenticated" <$> getRequestUserId
  runDB $ delete $ do
    decks <- from $ table @ArkhamDeck
    where_ $ decks ^. persistIdField ==. val deckId
    where_ $ decks ^. ArkhamDeckUserId ==. val userId
