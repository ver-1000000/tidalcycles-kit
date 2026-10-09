:set -XMultiParamTypeClasses -XOverloadedStrings -Wno-orphans
:set prompt ""
import Sound.Tidal.Boot
import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)
default (Rational, Integer, Double, Pattern String)
kitDirtHost <- fmap (fromMaybe "127.0.0.1") (lookupEnv "TIDAL_DIRT_HOST")
kitControlHost <- fmap (fromMaybe "127.0.0.1") (lookupEnv "TIDAL_CONTROL_HOST")
kitControlPort <- fmap (maybe (6010 :: Int) read) (lookupEnv "TIDAL_CONTROL_PORT")
tidalInst <- mkTidalWith [(superdirtTarget {oAddress = kitDirtHost}, [superdirtShape])] (defaultConfig {cCtrlAddr = kitControlHost, cCtrlPort = kitControlPort})
instance Tidally where tidal = tidalInst
:set prompt "tidal> "
:set prompt-cont ""
