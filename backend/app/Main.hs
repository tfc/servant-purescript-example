{-# LANGUAGE OverloadedStrings #-}

module Main where

import           ExampleApi
import           Network.Wai.Handler.Warp
import           Servant
import           System.IO

runExampleApi :: IO ()
runExampleApi = do
  let port = 3000
      settings =
        setPort port $
        setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port)) $
        defaultSettings
  runSettings settings =<< mkApp

mkApp :: IO Application
mkApp = return $ serve itemApi server

server :: Server ItemApi
server = getItems
    :<|> getItemById

getItems :: Handler [Item]
getItems = return items

getItemById :: Integer -> Handler Item
getItemById idx = return (items !! (fromIntegral idx))

items :: [Item]
items =
  [ Item "shoe" "an old leather shoe" 3
  , Item "glasses" "shiny new designer glasses" 1
  ]

main :: IO ()
main = runExampleApi
