module Main
    ( main
    ) where

import Test.DocTest (doctest)

main :: IO ()
main = do
    doctest [ "src/Language/Nominal/Name.hs"
            ]
    doctest [ "src/Language/Nominal/Examples/IdealisedEUTxO.hs"
            ]
    doctest [ "src/Language/Nominal/Examples/Tutorial.hs"
            , "src/Language/Nominal/Properties/NameSpec.hs"
            , "src/Language/Nominal/Unify.hs"
            , "src/Language/Nominal/Utilities.hs"
            ]
