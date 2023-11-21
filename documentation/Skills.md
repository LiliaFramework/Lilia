# Stamina
## AdjustStaminaOffset(client, offset)
Adjusts a player's current stamina offset amount. This is called when the player's stamina is about to be changed; every `0.25` seconds on the server, and every frame on the client.

### Parameters
**client** - The client player whose stamina is changing.

**offset** - The amount by which stamina is changing.

### Functionality 
Amount the stamina is changing by. This can be a positive or negative number depending if they are exhausting or regaining stamina

### EXAMPLE USAGE
```lua
function MODULE:AdjustStaminaOffset(client, offset)
    return offset * 2 -- Double the stamina changes for a faster drain/regain.
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/libs/sh_stamina.lua#L14)

## AdjustStaminaOffsetRunning(client, offset)
Adjusts a running player's stamina offset amount. This is called when the player's stamina is about to be changed and he is running; every `0.25` seconds on the server, and every frame on the client.

### Parameters
**client** - The client player whose stamina is changing.

**offset** - The amount by which stamina is changing.
### Functionality 
Amount the stamina is changing by. This can be a positive or negative number depending if they are exhausting or regaining stamina

### EXAMPLE USAGE
```lua
function MODULE:AdjustStaminaOffsetRunning(client, offset)
    return offset * 2  -- Double the stamina changes for a faster drain/regain.
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/libs/sh_stamina.lua#L9)
## AdjustStaminaRegeneration(client, offset)
Adjusts a running player's stamina offset amount. This is called when the player's stamina is about to be changed and he is running; every `0.25` seconds on the server, and every frame on the client.

### Parameters
**client** - The client player whose stamina is changing.

**offset** - The amount by which stamina is changing.
### Functionality 
Amount the stamina is changing by. This can be a positive or negative number depending if they are exhausting or regaining stamina

### EXAMPLE USAGE
```lua
function MODULE:AdjustStaminaRegeneration(client, offset)
    return offset * 5  -- Regain stamina five times as fast when running.
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/libs/sh_stamina.lua#L11)

## CharGetMaxStamina(character)
Adds the ability to override lia.config.DefaultStamina.

### Parameters
**character** - player character to be checked.

### Returns 
**Number** 

### Functionality 
Returns the overriden Max Stamina.
 
### EXAMPLE USAGE
```lua
function MODULE:CharGetMaxStamina(character)
    if character:getFaction() == FACTION_STAFF then
        return 100000 -- If you are staff, you get 100000 max stamina, compared to the remaining players getting lia.config.DefaultStamina
    end
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/meta/sh_meta.lua#L4)

## PlayerStaminaGained(character)
Called on Stamina Gained.

### Parameters
**character** - player character to be checked.

### Functionality 
This hook is called when a player's stamina is gained. You can use it to perform actions or checks when a player's stamina increases.
 
### EXAMPLE USAGE
```lua
function MODULE:PlayerStaminaGained(character)
    if character:getFaction() == FACTION_STAFF then
        character:getPlayer():ChatPrint("Just Gained Stamina!") -- Chat Prints That Stamina was Gained.
    end
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/libs/sh_stamina.lua#L28)

## PlayerStaminaLost(character)
Called on Stamina Lost.

### Parameters
**character** - player character to be checked.

### Functionality 
This hook is called when a player's stamina is lost. You can use it to perform actions or checks when a player's stamina decreases.

### EXAMPLE USAGE
```lua
function MODULE:PlayerStaminaLost(character)
    if character:getFaction() == FACTION_STAFF then
        character:getPlayer():ChatPrint("Just Lost Stamina!") -- Chat Prints That Stamina was Lost.
    end
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/roleplay/modules/skills/libs/sh_stamina.lua#L25)
