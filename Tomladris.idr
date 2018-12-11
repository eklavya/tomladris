module Tomladris

import public Data.String
import public Data.SortedMap
import public Lightyear
import public Lightyear.Char
import public Lightyear.Strings

export
data TomlValue =   TComment String
                 | TString String
                 | TInteger Integer
                 | TDouble Double
                 | TBoolean Bool
                 | TArray (List TomlValue)
                 | TTableKV TomlValue TomlValue


private
parseComment : Parser TomlValue
parseComment = TComment . pack <$> (char '#' *> many (noneOf "\n"))


parseNumber : Parser TomlValue
parseNumber = (parseNum . pack) <$> many (oneOf "1234567890.eE+-")
  where
    parseNum : String -> TomlValue
    parseNum s = case parseInteger s of
                 (Just x) => TInteger x
                 Nothing => case parseDouble s of
                            (Just x) => TDouble x
                            Nothing => TDouble 0.0


parseTBoolean : Parser TomlValue
parseTBoolean = toBool <$> (string "true" <|> string "false")
  where
    toBool s = case s of
                 "true" => TBoolean True
                 "false" => TBoolean False


parseTString : Parser TomlValue
parseTString = (TString) <$> (quoted '\'' <|> quoted '\"')


--lazying  '[' ']' match very very important
--else we get infinite loop
mutual
  parseTArray : Parser TomlValue
  parseTArray = TArray <$> (spaces *> (char '[') *>| parsePrimitives <*| (char ']'))

  parsePrimitives : Parser (List TomlValue)
  parsePrimitives = spaces *> (sepBy1 parseNumber (char ',')) <|>|
                    (sepBy1 parseTBoolean (char ',')) <|>|
                    (sepBy1 parseTString (char ',')) <|>|
                    (sepBy1 parseTArray (char ','))


parseTableName : Parser TomlValue
parseTableName = (TString .pack) <$> ((many endOfLine) *> spaces *> (char '[') *>| (many (noneOf "]"))  <*| (char ']'))


parseTKeyVal : Parser TomlValue
parseTKeyVal = (TTableKV) <$>
               (parseTString <|> parseString) <*>
               (char '=' *>
               spaces *> (parseTString <|>
                             parseTArray <|>
                             parseTBoolean <|>
                             parseNumber))
  where
    parseString = (TString . pack) <$>
                  (((many endOfLine) *> spaces *> many (noneOf " [=")) <|>
                  (spaces *> many (noneOf " [=")))


keyMap : (List TomlValue) -> SortedMap String TomlValue
keyMap [] = empty
keyMap (x::xs) = keyMapAux x xs empty
  where
    keyMapAux : TomlValue -> (List TomlValue) -> SortedMap String TomlValue -> SortedMap String TomlValue
    keyMapAux root [] m = m
    keyMapAux root@(TString r) ((TTableKV (TString key) value)::xs) m = keyMapAux root xs (insert (r ++ "." ++ key) value m)


addKeyVal : String -> String -> TomlValue -> SortedMap String TomlValue -> SortedMap String TomlValue
addKeyVal root key value m = if (length root == 0)
                             then insert key value m
                             else insert (root ++ "." ++ key) value m


foldOver : String -> (List TomlValue) -> SortedMap String TomlValue -> SortedMap String TomlValue
foldOver root [] m = m
foldOver root ((TString table)::xs) m = foldOver table xs m
foldOver root ((TTableKV (TString key) value)::xs) m = foldOver root xs (addKeyVal root key value m)


export
parseToml : String -> SortedMap String TomlValue
parseToml s = case parse (many (parseTableName <|> parseTKeyVal)) s of
              (Right lstToml) => foldOver "" lstToml empty
              (Left _) => empty
