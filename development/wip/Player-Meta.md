# Shared
## playerMeta:Name()
Used to return a player's name

### Returns 
**String** 

### Functionality 
Returns the player's name

### Alias
**playerMeta:Nick()**

**playerMeta:GetName()**

### EXAMPLE USAGE
```lua
function MODULE:PlayerSpawn(client)
    client:Say("Hello, I am " .. client:Name() .. "!")  -- Says Your Name On Spawn
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/2.0/lilia/gamemode/backend/libs/character/sh_character.lua#L457)

## playerMeta:getChar()
Used to return a player's character

### Returns 
**ID** 

### Functionality 
Returns the player's character

### EXAMPLE USAGE
```lua
function MODULE:PlayerSpawn(client)
    if client:getChar() then
        client:Say("I spawned with a character!") -- If you have a character, it announces you spawned with a character
    end
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/2.0/lilia/gamemode/backend/libs/character/sh_character.lua#L453)

# Server

# Client


