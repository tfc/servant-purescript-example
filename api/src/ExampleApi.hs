{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module ExampleApi where

import Data.Proxy (Proxy(..))
import           Data.Aeson
import           Data.Text
import           GHC.Generics
import           Servant.API

data Item = Item
    { itemName :: Text
    , itemDescription :: Text
    , itemWeight :: Int
    }
    deriving (Eq, Show, Generic)

instance ToJSON Item
instance FromJSON Item

type ItemApi = "item" :> Get '[JSON] [Item]
          :<|> "item" :> Capture "itemId" Integer :> Get '[JSON] Item

itemApi :: Proxy ItemApi
itemApi = Proxy
