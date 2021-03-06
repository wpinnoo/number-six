-- | Ask our cylon for it's gods
--
{-# LANGUAGE OverloadedStrings #-}
module NumberSix.Handlers.Gods
    ( handler
    ) where

import Data.List (nub)

import qualified Data.ByteString.Char8 as B

import NumberSix.Irc
import NumberSix.Message
import NumberSix.Bang
import NumberSix.Util

handler :: UninitializedHandler
handler = makeHandler "Gods" [godsHook, addGodHook, removeGodHook]

godsHook :: Irc ()
godsHook = onBangCommand "!gods" printGods

addGodHook :: Irc ()
addGodHook = onBangCommand "!addgod" $ do
    password <- getBangCommandText
    prefix <- getPrefix
    modifyGods (add $ God prefix) password
    printGods
  where
    add x = nub . (x :)

removeGodHook :: Irc ()
removeGodHook = onBangCommand "!removegod" $ onGod $ do
    password <- getGodPassword
    pattern <- getBangCommandText
    prefix <- getPrefix
    let keep = if B.null pattern then (/= God prefix) else noMatch pattern
    modifyGods (filter keep) password
    printGods
  where
    noMatch pattern god = not $ pattern `B.isInfixOf` B.pack (show god)

printGods :: Irc ()
printGods = do
    gods <- getGods
    write $ "My gods are " <> prettyList (map (B.pack . show) gods) <> "."
