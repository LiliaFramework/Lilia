## CLASS:onCanBe(client)
Whether or not a player can switch to this class.

### Parameters
**client** - Client that wants to switch to this class

### Returns 
**Bool** 

### Functionality 
Return true if the player is allowed to switch to this class

### EXAMPLE USAGE
```lua
function CLASS:onCanBe(client)
    return client:IsAdmin() or client:getChar():hasFlags("Z") -- Only admins or people with the Z flag are allowed in this class!
end
```
[View source »](https://github.com/bleonheart/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/libs/sh_class.lua#L37)
***
## CLASS:onSpawn(client)
Called when a character has spawned in this class.

### Parameters
**client** - Player who has spawned in this class.

### Functionality 
Allows you to run certain events on Spawn.

### EXAMPLE USAGE
```lua
function CLASS:onSpawn(client)
    client:SetMaxHealth(500) -- Sets your Max Health to 500
    client:SetHealth(500) -- Subsequently sets your Health to 500
end
```
[View source »](https://github.com/bleonheart/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/core/sv_spawns.lua#L158)
***

## CLASS:onSet(client)
Called when a character has joined this class.

### Parameters
**client** - Player who has joined this class.

### Functionality 
Allows you to run certain events on Class Join.

### EXAMPLE USAGE
```lua
function CLASS:onSet(client)
    client:SetModel("models/police.mdl") -- Sets Model to "models/police.mdl" whenever the client joins the class
end
```
[View source »](https://github.com/bleonheart/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/core/hooks/sh_hooks.lua#L373)
***

## CLASS:onLeave(client)
Called when a character has left this class and has joined a different one.

### Parameters
**client** - Player who has left the class.

### Functionality 
Allows you to run certain events on Class Leave.

### EXAMPLE USAGE
```lua
function CLASS:onLeave(client)
    client:SetWalkSpeed(lia.config.WalkSpeed) -- Resets your WalkedSpeed to Lilia Default
    client:SetRunSpeed(lia.config.RunSpeed) -- Resets your RunSpeed to Lilia Default
    hook.Run("PlayerLoadout", client) -- Runs the PlayerLoadout Hook
end
```
[View source »](https://github.com/bleonheart/Lilia/blob/b06ee3ea18174334b78c14c26c9c1dd64d91b700/lilia/gamemode/backend/core/hooks/sh_hooks.lua#L377)
***
