-- | Authenticate with nickserv
--
{-# LANGUAGE OverloadedStrings #-}
module NumberSix.Handlers.NickServ
    ( handler
    ) where

import Control.Applicative ((<$>))
import Control.Monad.Reader (ask)

import Data.ByteString (ByteString)
import NumberSix.Irc

handler :: Handler ByteString
handler = makeHandler "nickserv" [authHook]

authHook :: Irc ByteString ()
authHook = onCommand "376" $ do
    n <- ircNickServ . ircConfig . ircEnvironment <$> ask
    case n of
        -- No authentication data, whatever
        Nothing -> return ()
        -- Authentication data. Try to authenticate...
        Just (nickServ, authLine) -> writeChannel nickServ authLine
