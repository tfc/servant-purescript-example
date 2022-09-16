-- File auto generated by servant-purescript! --
module ExampleApiClient where

import Prelude

import Control.Monad.Aff.Class (class MonadAff)
import Control.Monad.Error.Class (class MonadError)
import Control.Monad.Reader.Class (ask, class MonadAsk)
import Data.Argonaut.Core (stringify)
import Data.Array (catMaybes, null)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import Data.String (joinWith)
import ExampleApi (Item)
import GHC.Num.Integer (Integer)
import Network.HTTP.Affjax (AJAX)
import Prim (Array, String)
import Servant.PureScript.Affjax (AjaxError, affjax, defaultRequest)
import Servant.PureScript.Settings (SPSettingsDecodeJson_(..), SPSettingsEncodeJson_(..), SPSettings_(..), gDefaultToURLPiece)
import Servant.PureScript.Util (encodeHeader, encodeListQuery, encodeQueryItem, encodeURLPiece, getResult)

newtype SPParams_ = SPParams_ { baseURL :: String
                              }

getItem :: forall eff m.
           MonadAsk (SPSettings_ SPParams_) m => MonadError AjaxError m => MonadAff ( ajax :: AJAX | eff) m
           => m (Array Item)
getItem = do
  spOpts_' <- ask
  let spOpts_ = case spOpts_' of SPSettings_ o -> o
  let spParams_ = case spOpts_.params of SPParams_ ps_ -> ps_
  let baseURL = spParams_.baseURL
  let httpMethod = "GET"
  let queryString = ""
  let reqUrl = baseURL <> "item" <> queryString
  let reqHeaders =
        []
  let affReq = defaultRequest
                 { method = httpMethod
                 , url = reqUrl
                 , headers = defaultRequest.headers <> reqHeaders
                 }
  affResp <- affjax affReq
  let decodeJson = case spOpts_.decodeJson of SPSettingsDecodeJson_ d -> d
  getResult affReq decodeJson affResp

getItemByItemId :: forall eff m.
                   MonadAsk (SPSettings_ SPParams_) m => MonadError AjaxError m => MonadAff ( ajax :: AJAX | eff) m
                   => Integer -> m Item
getItemByItemId itemId = do
  spOpts_' <- ask
  let spOpts_ = case spOpts_' of SPSettings_ o -> o
  let spParams_ = case spOpts_.params of SPParams_ ps_ -> ps_
  let baseURL = spParams_.baseURL
  let httpMethod = "GET"
  let queryString = ""
  let reqUrl = baseURL <> "item"
        <> "/" <> encodeURLPiece spOpts_' itemId <> queryString
  let reqHeaders =
        []
  let affReq = defaultRequest
                 { method = httpMethod
                 , url = reqUrl
                 , headers = defaultRequest.headers <> reqHeaders
                 }
  affResp <- affjax affReq
  let decodeJson = case spOpts_.decodeJson of SPSettingsDecodeJson_ d -> d
  getResult affReq decodeJson affResp

