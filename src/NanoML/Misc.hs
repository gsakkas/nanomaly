module NanoML.Misc where

import Control.Arrow
import Data.Either
import Data.Map (Map)
import qualified Data.Map as Map

import NanoML.Parser
import NanoML.Types

fromRight :: Either a b -> b
fromRight (Right b) = b

knownFuncs :: Map Var Type
knownFuncs = Map.fromList . map (second (fromRight . parseType)) $
  [ ("sumList", "int list -> int")
  , ("digitsOfInt", "int -> int list")
  , ("additivePersistence", "int -> int")
  , ("digitalRoot", "int -> int")
  , ("listReverse", "'a list -> 'a list")
  , ("palindrome", "string -> bool")
  , ("assoc", "'a * 'b * ('b * 'a) list -> 'a")
  , ("removeDuplicates", "'a list -> 'a list")
  , ("wwhile", "('a -> 'a * bool) * 'a -> 'a")
  , ("fixpoint", "('a -> 'a) * 'a -> 'a")
  , ("exprToString", "expr -> string")
  , ("eval", "expr * float * float -> float")
  , ("build", "((int * int -> int) * int) -> expr")
  , ("doRandomGray", "int * int * int -> unit")
  , ("doRandomColor", "int * int * int -> unit")
  , ("sqsum", "int list -> int")
  , ("pipe", "('a -> 'a) list -> ('a -> 'a)")
  , ("sepConcat", "string -> string list -> string")
  , ("stringOfList", "('a -> string) -> 'a list -> string")
  , ("clone", "'a -> int -> 'a list")
  , ("padZero", "int list -> int list -> int list  * int list")
  , ("removeZero", "int list -> int list")
  , ("bigAdd", "int list -> int list -> int list")
  , ("mulByDigit", "int -> int list -> int list")
  , ("bigMul", "int list -> int list -> int list")
  ]

facProg :: String
facProg = unlines [ "let rec fac n ="
                  , "  if n = 0 then"
                  , "    1"
                  , "  else"
                  , "    n * fac (n - 1)"
                  , ";;"
                  ]

badProg :: String
badProg = unlines [ "let f lst ="
                  , "  let rec loop lst acc ="
                  , "    if lst = [] then"
                  , "      acc"
                  , "    else"
                  , "      ()"
                  , "  in"
                  , "  match loop lst [(0.0,0.0)] with"
                  , "    | h :: t -> h"
                  , ";;"
                  ]

ignoredMLs :: [String]
ignoredMLs = [ "prog0012.ml" -- accidental use of ! (deref)
             , "prog0582.ml" -- uses ?
             , "prog0583.ml" -- uses ?
             , "prog0584.ml" -- uses ?
             , "prog1123.ml" -- uses try
             , "prog1261.ml" -- uses n..m range operator
             , "prog1270.ml" -- uses printf
             , "prog2916.ml" -- uses list.rev (record selector)
             , "prog2918.ml" -- uses list.rev (record selector)
             , "prog3003.ml" -- uses sepList.map (record selector)
             , "prog3158.ml" -- accidental type annot (let sumList (1 : int list))
             , "prog3160.ml" -- accidental type annot (let sumList (l : int list))
             , "prog3164.ml" -- array index xs.(0)
             , "prog3165.ml" -- array index xs.(0)
             , "prog3223.ml" -- deref (!)
             , "prog3644.ml" -- deref (!)
             , "prog3645.ml" -- deref (!)
             , "prog3646.ml" -- deref (!)
             , "prog3647.ml" -- deref (!)
             , "prog3648.ml" -- deref (!)
             , "prog3649.ml" -- deref (!)
             , "prog3695.ml" -- record selector
             , "prog3816.ml" -- optional param (~l)
             , "prog4000.ml" -- postfix !
             , "prog4105.ml" -- "or" pattern (1|2)
             , "prog4169.ml" -- deref (!)
             , "prog4170.ml" -- deref (!)
             , "prog4171.ml" -- deref (!)
             , "prog4480.ml" -- uses ?
             , "prog4481.ml" -- uses ?
             , "prog4484.ml" -- uses ?
             , "prog4485.ml" -- uses ?
             , "prog4486.ml" -- uses ?
             , "prog4501.ml" -- uses ?
             , "prog4557.ml" -- uses ?
             , "prog4720.ml" -- uses ?
             , "prog4722.ml" -- uses ?
             ]

testParser :: IO [Prog]
testParser = do
  let dir = "../yunounderstand/data/sp14/prog/unify"
  mls <- filter (`notElem` ignoredMLs) . filter (".ml" `isSuffixOf`)
          <$> getDirectoryContents dir
  forM mls $ \ml -> do
    r <- parseTopForm <$> readFile (dir </> ml)
    case r of
      Right p -> return p
      Left _ -> print ml >> print r >> error "die"