## FACTION:onGetDefaultName(client)
Called when the default name for a character needs to be retrieved (i.e upon initial character creation).

### Parameters
**client** - Client to get the default name for

### Returns 
**String** 

### Functionality 
Defines the default name for the newly created character

### EXAMPLE USAGE
```lua
function FACTION:onGetDefaultName(client)
    return "CT-" .. math.random(111111, 999999) -- This will set their name as CT-XXXXXX where as those 6 numerals are random generated 
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/core/hooks/sh_hooks.lua#L302)
***

## FACTION:OnCharCreated(client, character)
Called when a character has been initally created and assigned to this faction.

### Parameters
**client** - Client that owns the character

**character** - Character that has been created

### Functionality 
Mostly used to add items/set values on character creation. 

### EXAMPLE USAGE
```lua
function FACTION:OnCharCreated(client, character)
	local inventory = character:getInv()
	inventory:add("fancy_suit") -- Adds a Fancy Suit Item
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/modules/core/modules/mainmenu/netcalls/sv_netcalls.lua#L104)
***

## FACTION:onSpawn(client)
Called when a character in this faction has (re)spawned in the world.

### Parameters
**client** - Client that has just spawned

### Functionality 
To run certain functions on spawn. 

### EXAMPLE USAGE
```lua
FACTION.Health = 500 -- Defines that Faction HP
FACTION.Armor = 50 -- Defines that Faction Armor
function FACTION:onSpawn(client)
    client:SetMaxHealth(self.Health) -- Sets Faction Max HP to client
    client:SetHealth(self.Health) -- Sets Faction HP to client
    client:SetArmor(self.Armor) -- Sets Armor Max HP to client
    client:SetMaxArmor(self.Armor)  -- Sets Armor HP to client
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/core/sv_spawns.lua#L95)
***


## FACTION:onTransfered(character)
Called when a player's character has been transferred to this faction.

### Parameters
**character** - Character that was transferred

### Functionality 
Allows you to run functions on faction transfer 

### EXAMPLE USAGE
```lua
function FACTION:onTransfered(character)
    character:setModel(table.Random(FACTION.models)) -- Sets your model as your FACTION.Model
end
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/commands/sv_character.lua#L90)
***
