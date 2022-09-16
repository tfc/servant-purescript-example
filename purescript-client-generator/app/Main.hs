{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeOperators         #-}

module Main where

import           Data.Proxy
import           ExampleApi
import           Language.PureScript.Bridge
import           Language.PureScript.Bridge.PSTypes
import           Servant.PureScript

    {-

-- | We have been lazy and defined our types in the WebAPI module,
--   we use this opportunity to show how to create a custom bridge moving those
--   types to Counter.ServerTypes.
fixTypesModule :: BridgePart
fixTypesModule = do
  typeModule ^== "ExampleApi"
  t <- view haskType
  TypeInfo (_typePackage t) "ExampleApi" (_typeName t) <$> psTypeParameters

-}

myBridge :: BridgePart
myBridge = defaultBridge -- <|> fixTypesModule

data MyBridge

myBridgeProxy :: Proxy MyBridge
myBridgeProxy = Proxy

instance HasBridge MyBridge where
  languageBridge _ = buildBridge myBridge


myTypes :: [SumType 'Haskell]
myTypes =
  [ mkSumType (Proxy :: Proxy Item)
  ]

mySettings :: Settings
mySettings = defaultSettings { _apiModuleName = "ExampleApiClient" }


main :: IO ()
main = do
  let frontEndRoot = "frontend/src"
  writeAPIModuleWithSettings mySettings frontEndRoot myBridgeProxy itemApi
  writePSTypes frontEndRoot (buildBridge myBridge) myTypes
