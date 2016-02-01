# tomladris
TOML parser for Idris

OMG that's poor, poor choice for a project name!!

Yeah. I pronounce it 'to'-'m'-'la'-'dris'.

## State
Incomplete and buggy. Your help and contribution are much needed :)

## Usage
```idris
parseToml : String  -> SortedMap String TomlValue
```
Give it a toml string and it will give back a map of all keys with their values.

### Types
```idris
data TomlValue =   TComment String
                 | TString String
                 | TInteger Integer
                 | TDouble Double
                 | TBoolean Bool
                 | TArray (List TomlValue)
                 | TTableKV TomlValue TomlValue
```

### Example
```toml
title="TOML Example"
[owner]
name="Tom Preston-Werner"
[database]
server="192.168.1.1"
ports=[8001,8001,8002]
connection_max=5000
enabled=true
testing=0.23
[servers.alpha]
ip="10.0.0.1"
dc="eqdc10"
[servers.beta]
ip="10.0.0.2"
dc="eqdc10"

```

In this toml snippet,
```idris

let tomlMap = parseToml tomlString

-- title
lookup "title" tomlMap
-- Just (TString "TOML Example")

-- database.ports
lookup "database.ports" tomlMap
-- Just (TArray [TInteger 8001, TInteger 8001, TInteger 8002])

-- servers.beta.ip
lookup "servers.beta.ip" tomlMap
-- Just (TString "10.0.0.2")
```
