# World & Environment

This page documents the hooks for world interaction, environmental systems, player mechanics, and game world management in the Lilia framework.

---

## Overview

The world and environment system forms the core of Lilia's gameplay experience, providing comprehensive hooks for managing world interactions, environmental systems, player mechanics, and game world management. These hooks enable developers to create immersive and interactive game worlds that respond dynamically to player actions and environmental conditions.

The world and environment system in Lilia is built around a sophisticated architecture that supports complex world interactions, environmental simulation, and extensive customization capabilities. The system handles everything from basic player interactions to complex environmental systems and world state management, ensuring that all world elements work together to create engaging gameplay experiences.

**Player Interaction and Mechanics** hooks provide comprehensive control over player interactions with the world, including object manipulation, door usage, item handling, and environmental interactions. These hooks enable developers to create complex interaction systems with custom behaviors, restrictions, and feedback mechanisms.

**Environmental Systems and World State** hooks manage environmental conditions, world state changes, and environmental effects that impact gameplay. These hooks enable developers to implement dynamic weather systems, day/night cycles, and environmental hazards that affect player behavior and world conditions.

**Character and Player Management** hooks handle character creation, management, and progression within the world context. These hooks enable complex character systems with custom attributes, progression mechanics, and world-based character development.

**Inventory and Item Systems** hooks manage item interactions, inventory management, and item-based world interactions. These hooks enable sophisticated item systems with custom properties, world interactions, and complex inventory mechanics.

**Door and Property Systems** hooks handle property ownership, door management, and property-related world interactions. These hooks enable complex property systems with ownership mechanics, access control, and property-based gameplay.

**HUD and Interface Systems** hooks provide control over player interfaces, HUD elements, and world-based UI components. These hooks enable developers to create custom interfaces that integrate seamlessly with the world environment.

**Weapon and Combat Systems** hooks manage weapon interactions, combat mechanics, and combat-related world systems. These hooks enable complex combat systems with custom weapon behaviors, combat mechanics, and world-based combat interactions.

**Spawn and Respawn Systems** hooks handle player spawning, respawn mechanics, and spawn point management. These hooks enable sophisticated spawn systems with custom spawn logic, respawn restrictions, and spawn-based gameplay mechanics.

**Voice and Communication Systems** hooks manage voice chat, communication systems, and social interactions within the world. These hooks enable complex communication systems with custom voice mechanics, social interactions, and world-based communication.

**PAC and Character Customization** hooks handle character appearance, PAC integration, and character customization systems. These hooks enable sophisticated character customization with PAC integration, appearance management, and world-based character representation.

**Administrative and Management Systems** hooks provide tools for server administration, player management, and world administration. These hooks enable complex administrative systems with custom management tools, player oversight, and world administration capabilities.

**Performance and Optimization** hooks enable developers to optimize world performance, manage resource usage, and implement efficient world systems. These hooks help maintain optimal performance even with complex world interactions and environmental systems.

**Integration and Compatibility** hooks facilitate integration between world systems and other framework components, ensuring that all world elements work together seamlessly and that the world environment remains consistent and functional.

**Custom World Mechanics** hooks allow developers to implement unique world mechanics, environmental effects, and world-based gameplay systems that go beyond standard functionality.

**Security and Anti-Exploit** hooks provide mechanisms for preventing world-based exploits, validating world interactions, and ensuring world system integrity. These hooks help maintain fair and balanced world gameplay.

---

### ShouldDrawEntityInfo

**Purpose**

Determines if world-space info should be rendered for an entity. Return false to hide the tooltip.

**When Called**

This hook is triggered when:
- An entity is being evaluated for info display
- Before entity information tooltip is shown
- When player looks at an entity
- During entity info rendering checks

**Parameters**

* `entity` (*Entity*): Entity being considered.

**Returns**

- boolean: False to hide info

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control which entities display information panels.
-- Entity info panels show details about objects when players look at them.
-- This hook allows you to hide info panels for specific entity types or conditions.

-- Hide info panels for NPCs
hook.Add("ShouldDrawEntityInfo", "HideNPCs", function(ent)
    if ent:IsNPC() then
        return false
    end
end)
```

---

### DrawEntityInfo

**Purpose**

Allows custom drawing of entity information in the world. Drawn every frame while visible.

**When Called**

This hook is triggered when:
- Entity information is being drawn in the world
- Every frame while entity info is visible
- When custom entity info rendering is needed
- During world-space UI rendering

**Parameters**

* `entity` (*Entity*): Entity to draw info for.

* `alpha` (*number*): Current alpha value.

* `position` (*table*): Screen position table.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the drawing of entity information in the world.
-- Entity info is drawn above entities when players look at them.
-- This hook allows you to create custom visual displays for entity information.

-- Display the entity class name above props
hook.Add("DrawEntityInfo", "LabelProps", function(ent, a, pos)
    draw.SimpleText(ent:GetClass(), "DermaDefault", pos.x, pos.y, Color(255, 255, 255, a))
end)
```

---

### GetInjuredText

**Purpose**

Provides the health status text and color for a player. Return a table with text and color values.

**When Called**

This hook is triggered when:
- A player's health status is being displayed
- When health information is needed for UI
- During player health status evaluation
- Before health text and color are shown

**Parameters**

* `client` (*Player*): Player to check.

**Returns**

- table: {text, color} info

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the health status text and color for players.
-- Health status is displayed above players when they are injured.
-- This hook allows you to create custom health indicators and warning systems.

-- Show a critical warning when health is low
hook.Add("GetInjuredText", "SimpleHealth", function(ply)
    if ply:Health() <= 20 then
        return {"Critical", Color(255, 0, 0)}
    end
end)
```

---

### ShouldDrawPlayerInfo

**Purpose**

Determines if character info should draw above a player. Return false to suppress drawing.

**When Called**

This hook is triggered when:
- Character information is about to be drawn above a player
- Before player nameplate rendering
- When evaluating player info display permissions
- During character info visibility checks

**Parameters**

* `player` (*Player*): Player being rendered.

**Returns**

- boolean: False to hide info

**Realm**

**Client**

**Example Usage**

```lua
-- Hide the info overlay for the local player
hook.Add("ShouldDrawPlayerInfo", "HideLocal", function(ply)
    return ply != LocalPlayer()
end)
```

---

### DrawCharInfo

**Purpose**

Allows custom drawing of character information above players.

**When Called**

This hook is triggered when:
- Character information is being drawn above a player
- During custom character info rendering
- When player nameplate is being displayed
- While character info is visible

**Parameters**

* `character` (*Character*): Character being drawn.
* `alpha` (*number*): Current alpha value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Display custom status above characters
hook.Add("DrawCharInfo", "ShowStatus", function(char, alpha)
    if char:getData("wanted") then
        draw.SimpleText("WANTED", "Trebuchet24", 0, -20, Color(255, 0, 0, alpha), TEXT_ALIGN_CENTER)
    end
end)
```

---

### ItemShowEntityMenu

**Purpose**

Called when an item's entity menu is shown. Allows customization of item entity menus.

**When Called**

This hook is triggered when:
- An item entity's context menu is being displayed
- When player right-clicks on an item entity
- Before item entity menu options are shown
- During item entity interaction menu setup

**Parameters**

* `entity` (*Entity*): Item entity.
* `menu` (*Panel*): Menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Add custom options to item entity menus
hook.Add("ItemShowEntityMenu", "CustomOptions", function(ent, menu)
    menu:AddOption("Custom Action", function()
        -- Custom action logic
    end)
end)
```

---

### PreLiliaLoaded

**Purpose**

Runs before the Lilia framework finishes loading.

**When Called**

This hook is triggered when:
- The Lilia framework is in the process of loading
- Before framework initialization is completed
- During early framework setup phase
- Prior to full system initialization

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Perform initialization before Lilia is fully loaded
hook.Add("PreLiliaLoaded", "PreInit", function()
    print("Lilia is loading...")
end)
```

---

### LiliaLoaded

**Purpose**

Runs after the Lilia framework has finished loading.

**When Called**

This hook is triggered when:
- The Lilia framework has completed loading
- After all framework systems are initialized
- When the framework is ready for use
- Following successful framework setup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Perform post-initialization after Lilia is fully loaded
hook.Add("LiliaLoaded", "PostInit", function()
    print("Lilia has finished loading")
end)
```

---

### getPlayTime

**Purpose**

Override a player's computed playtime. Return seconds to use your value; return `nil` to fall back to default logic.

**When Called**

This hook is triggered when:
- A player's playtime is being calculated
- When playtime statistics are requested
- During playtime display or logging
- Before playtime values are shown or used

**Parameters**

* `client` (*Player*): The player whose playtime is being computed.

**Returns**

* `playTime` (*number* | *nil*): Playtime in seconds, or nil to use default logic.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("getPlayTime", "UseExternalTracker", function(ply)
    return ply:GetNWInt("ExternalPlaySeconds", 0)
end)
```

---

### AdjustStaminaOffset

**Purpose**

Allows modification of stamina regeneration rate.

**When Called**

This hook is triggered when:
- Player stamina is being regenerated
- During stamina system calculations
- When stamina offset is being determined
- While stamina recovery is processed

**Parameters**

* `client` (*Player*): Player whose stamina is being adjusted.
* `offset` (*number*): Current stamina offset.

**Returns**

* `newOffset` (*number*): Modified stamina offset.

**Realm**

**Shared**

**Example Usage**

```lua
-- Boost stamina regeneration for certain classes
hook.Add("AdjustStaminaOffset", "ClassBonus", function(ply, offset)
    if ply:getChar():getClass() == "athlete" then
        return offset * 1.5
    end
end)
```

---

### PostLoadFonts

**Purpose**

Called after custom fonts have been loaded.

**When Called**

This hook is triggered when:
- Custom fonts have finished loading
- After font initialization is completed
- When font system is ready for use
- Following successful font setup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Perform font-dependent initialization
hook.Add("PostLoadFonts", "FontInit", function()
    print("Custom fonts loaded")
end)
```

---

### AddBarField

**Purpose**

Allows adding custom fields to the HUD bars.

**When Called**

This hook is triggered when:
- HUD bar fields are being set up
- During HUD bar initialization
- When custom bar fields can be added
- Before HUD bars are displayed

**Parameters**

* `client` (*Player*): Player whose bars are being set up.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Add a custom hunger bar
hook.Add("AddBarField", "HungerBar", function(ply)
    local char = ply:getChar()
    if char then
        local hunger = char:getData("hunger", 0)
        return {name = "Hunger", value = hunger, max = 100, color = Color(255, 100, 100)}
    end
end)
```

---

### AddSection

**Purpose**

Allows adding custom sections to the F1 menu.

**When Called**

This hook is triggered when:
- F1 menu sections are being set up
- During F1 menu initialization
- When custom menu sections can be added
- Before F1 menu is displayed to players

**Parameters**

* `panel` (*Panel*): F1 menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Add a custom section to the F1 menu
hook.Add("AddSection", "CustomSection", function(panel)
    local section = panel:addSection("Custom")
    section:addButton("Custom Button", function()
        -- Custom button logic
    end)
end)
```

---

### CanItemBeTransfered

**Purpose**

Determines if an item can be transferred between inventories.

**When Called**

This hook is triggered when:
- An item transfer between inventories is being evaluated
- Before item movement is processed
- When transfer permissions are being checked
- During inventory transfer validation

**Parameters**

* `item` (*Item*): Item being transferred.
* `currentInv` (*Inventory*): Current inventory.
* `targetInv` (*Inventory*): Target inventory.

**Returns**

- boolean: False to prevent transfer

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent transfer of locked items
hook.Add("CanItemBeTransfered", "NoLockedTransfer", function(item, currentInv, targetInv)
    if item:getData("locked") then
        return false
    end
end)
```

---

### CanOpenBagPanel

**Purpose**

Checks if a player can open a bag's inventory panel.

**When Called**

This hook is triggered when:
- A player attempts to open a bag inventory
- Before bag panel is displayed
- When bag access permissions are evaluated
- During bag interaction checks

**Parameters**

* `client` (*Player*): Player attempting to open the panel.
* `bag` (*Entity*): Bag entity.

**Returns**

- boolean: False to prevent opening

**Realm**

**Server**

**Example Usage**

```lua
-- Only allow bag owners to open them
hook.Add("CanOpenBagPanel", "OwnerOnly", function(ply, bag)
    return bag:getNetVar("owner") == ply
end)
```

---

### CanOutfitChangeModel

**Purpose**

Determines if a player can change their model using an outfit item.

**When Called**

This hook is triggered when:
- A player attempts to use an outfit item
- Before model change is processed
- When outfit permissions are evaluated
- During outfit item usage validation

**Parameters**

* `client` (*Player*): Player attempting the change.
* `item` (*Item*): Outfit item.

**Returns**

- boolean: False to prevent model change

**Realm**

**Server**

**Example Usage**

```lua
-- Restrict model changes to certain factions
hook.Add("CanOutfitChangeModel", "FactionRestrict", function(ply, item)
    local char = ply:getChar()
    return char:getFaction() == "citizen"
end)
```

---

### CanPlayerHoldObject

**Purpose**

Checks if a player can hold/use an object.

**When Called**

This hook is triggered when:
- A player attempts to hold or use an object
- Before object interaction is processed
- When object usage permissions are evaluated
- During object interaction validation

**Parameters**

* `client` (*Player*): Player attempting to hold the object.
* `entity` (*Entity*): Object entity.

**Returns**

- boolean: False to prevent holding

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent holding objects while handcuffed
hook.Add("CanPlayerHoldObject", "NoCuffedHold", function(ply, ent)
    if ply:isHandcuffed() then
        return false
    end
end)
```

---

### CanPlayerInteractItem

**Purpose**

Determines if a player can interact with an item.

**When Called**

This hook is triggered when:
- A player attempts to interact with an item
- Before item interaction is processed
- When item interaction permissions are evaluated
- During item usage validation

**Parameters**

* `client` (*Player*): Player attempting interaction.
* `item` (*Item*): Item being interacted with.
* `option` (*string*): Interaction option.

**Returns**

- boolean: False to prevent interaction

**Realm**

**Server**

**Example Usage**

```lua
-- Restrict certain item interactions
hook.Add("CanPlayerInteractItem", "RestrictInteraction", function(ply, item, option)
    if option == "admin_only" and not ply:IsAdmin() then
        return false
    end
end)
```

---

### CanPlayerKnock

**Purpose**

Checks if a player can knock on a door.

**When Called**

This hook is triggered when:
- A player attempts to knock on a door
- Before door knocking is processed
- When door interaction permissions are evaluated
- During door knocking validation

**Parameters**

* `client` (*Player*): Player attempting to knock.
* `door` (*Entity*): Door entity.

**Returns**

- boolean: False to prevent knocking

**Realm**

**Server**

**Example Usage**

```lua
-- Disable knocking on certain doors
hook.Add("CanPlayerKnock", "NoKnock", function(ply, door)
    if door:getNetVar("noKnock") then
        return false
    end
end)
```

---

### CanPlayerSpawnStorage

**Purpose**

Determines if a player can spawn storage containers.

**When Called**

This hook is triggered when:
- A player attempts to spawn storage containers
- Before storage spawning is processed
- When storage spawn permissions are evaluated
- During storage container creation validation

**Parameters**

* `client` (*Player*): Player attempting to spawn storage.

**Returns**

- boolean: False to prevent spawning

**Realm**

**Server**

**Example Usage**

```lua
-- Only allow admins to spawn storage
hook.Add("CanPlayerSpawnStorage", "AdminOnly", function(ply)
    return ply:IsAdmin()
end)
```

---

### CanPlayerThrowPunch

**Purpose**

Checks if a player can throw a punch.

**When Called**

This hook is triggered when:
- A player attempts to throw a punch
- Before punch action is processed
- When combat permissions are evaluated
- During melee combat validation

**Parameters**

* `client` (*Player*): Player attempting to punch.

**Returns**

- boolean: False to prevent punching

**Realm**

**Server**

**Example Usage**

```lua
-- Disable punching in safe zones
hook.Add("CanPlayerThrowPunch", "NoSafeZonePunch", function(ply)
    if ply:getNetVar("inSafeZone") then
        return false
    end
end)
```

---

### PlayerThrowPunch

**Purpose**

Called when a player successfully throws a punch.

**When Called**

This hook is triggered when:
- A player completes a punch action
- After damage/ragdoll effects are applied
- During melee combat resolution

**Parameters**

* `attacker` (*Player*): Player who threw the punch.
* `trace` (*TraceResult*): Trace result from the punch.

**Returns**

*None*

**Realm**

**Server**

**Example Usage**

```lua
-- Track punch statistics
hook.Add("PlayerThrowPunch", "PunchStats", function(attacker, trace)
    if trace.Hit and IsValid(trace.Entity) then
        if trace.Entity:IsPlayer() then
            attacker:getChar():setData("punches", attacker:getChar():getData("punches", 0) + 1)
        end
    end
end)
```

---

### GetPlayerPunchRagdollTime

**Purpose**

Determines the ragdoll duration when a punch knocks out a player instead of dealing damage.

**When Called**

This hook is triggered when:
- A punch hits a player
- Punch lethality is disabled
- Before ragdoll is applied

**Parameters**

* `attacker` (*Player*): Player who threw the punch.
* `victim` (*Player*): Player being punched.

**Returns**

* number: Ragdoll duration in seconds (default: 25, configurable via PunchRagdollTime config)

**Realm**

**Server**

**Example Usage**

```lua
-- Increase ragdoll time for admin punches
hook.Add("GetPlayerPunchRagdollTime", "AdminPunchRagdoll", function(attacker, victim)
    if attacker:IsAdmin() then
        return 10
    end
end)
```

---

### CanPlayerViewInventory

**Purpose**

Determines if a player can view another player's inventory.

**When Called**

This hook is triggered when:
- A player attempts to view another player's inventory
- Before inventory viewing is processed
- When inventory access permissions are evaluated
- During inventory viewing validation

**Parameters**

* `viewer` (*Player*): Player attempting to view.
* `target` (*Player*): Target player whose inventory is being viewed.

**Returns**

- boolean: False to prevent viewing

**Realm**

**Server**

**Example Usage**

```lua
-- Allow police to view inventories
hook.Add("CanPlayerViewInventory", "PoliceView", function(viewer, target)
    return viewer:getChar():getFaction() == "police"
end)
```

---

### CanPlayerEarnSalary

**Purpose**

Checks if a player can earn salary.

**Parameters**

* `client` (*Player*): Player attempting to earn salary.

**Returns**

- boolean: False to prevent salary

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent salary for certain classes
hook.Add("CanPlayerEarnSalary", "NoSalary", function(ply)
    if ply:getChar():getClass() == "unemployed" then
        return false
    end
end)
```

---

### CanPlayerJoinClass

**Purpose**

Determines if a player can join a class.

**When Called**

This hook is triggered when:
- A player attempts to join a class
- Before class assignment is processed
- When class joining permissions are evaluated
- During class membership validation

**Parameters**

* `client` (*Player*): Player attempting to join.
* `class` (*string*): Class ID.

**Returns**

- boolean: False to prevent joining

**Realm**

**Server**

**Example Usage**

```lua
-- Restrict class access by faction
hook.Add("CanPlayerJoinClass", "FactionRestrict", function(ply, class)
    local char = ply:getChar()
    if class == "soldier" and char:getFaction() != "military" then
        return false
    end
end)
```

---

### CanPlayerUseCommand

**Purpose**

Checks if a player can use a specific command.

**When Called**

This hook is triggered when:
- A player attempts to use a command
- Before command execution is processed
- When command permissions are evaluated
- During command usage validation

**Parameters**

* `client` (*Player*): Player attempting to use command.
* `command` (*string*): Command name.

**Returns**

- boolean: False to prevent command use

**Realm**

**Server**

**Example Usage**

```lua
-- Restrict admin commands
hook.Add("CanPlayerUseCommand", "AdminOnly", function(ply, command)
    if command:find("admin") and not ply:IsAdmin() then
        return false
    end
end)
```

---

### CanPlayerUseDoor

**Purpose**

Determines if a player can use a door.

**When Called**

This hook is triggered when:
- A player attempts to use a door
- Before door usage is processed
- When door interaction permissions are evaluated
- During door access validation

**Parameters**

* `client` (*Player*): Player attempting to use door.
* `door` (*Entity*): Door entity.

**Returns**

- boolean: False to prevent door use

**Realm**

**Server**

**Example Usage**

```lua
-- Lock doors during events
hook.Add("CanPlayerUseDoor", "EventLock", function(ply, door)
    if game.GetGlobalState("event_active") then
        return false
    end
end)
```

---

### CharCleanUp

**Purpose**

Called when a character's data needs to be cleaned up.

**When Called**

This hook is triggered when:
- A character's data requires cleanup
- During character cleanup procedures
- When character data is being removed or reset
- Before character data is cleared

**Parameters**

* `character` (*Character*): Character being cleaned up.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Clean up character-specific data
hook.Add("CharCleanUp", "CleanupData", function(character)
    -- Cleanup logic
end)
```

---

### CharRestored

**Purpose**

Fires when a character is restored from storage.

**When Called**

This hook is triggered when:
- A character is being restored from storage
- During character restoration procedures
- When character data is loaded from backup
- After character recovery operations

**Parameters**

* `character` (*Character*): Character that was restored.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Handle character restoration
hook.Add("CharRestored", "RestoreLogic", function(character)
    -- Restoration logic
end)
```

---

### CreateDefaultInventory

**Purpose**

Called to create a default inventory for a character.

**When Called**

This hook is triggered when:
- A default inventory needs to be created for a character
- During character initialization
- When setting up initial character inventory
- Before character inventory system is ready

**Parameters**

* `client` (*Player*): Player to create inventory for.

**Returns**

* `inventory` (*Inventory*): Created inventory.

**Realm**

**Server**

**Example Usage**

```lua
-- Create custom default inventory
hook.Add("CreateDefaultInventory", "CustomInventory", function(client)
    return lia.inventory.new("CustomInv")
end)
```

---

### CreateInventoryPanel

**Purpose**

Fires when an inventory panel is created.

**When Called**

This hook is triggered when:
- An inventory panel is being created
- During inventory UI initialization
- When inventory interface needs to be displayed
- Before inventory panel is shown to players

**Parameters**

* `inventory` (*Inventory*): Inventory the panel is for.

**Returns**

* `panel` (*Panel*): Created inventory panel.

**Realm**

**Client**

**Example Usage**

```lua
-- Create custom inventory panel
hook.Add("CreateInventoryPanel", "CustomPanel", function(inventory)
    -- Create and return custom panel
end)
```

---

### DoModuleIncludes

**Purpose**

Called during module inclusion process.

**When Called**

This hook is triggered when:
- Modules are being included and loaded
- During module initialization process
- When module files are being processed
- Before modules become available for use

**Parameters**

* `moduleName` (*string*): Name of the module being included.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("DoModuleIncludes", "LogIncludes", function(moduleName)
    print("Including module:", moduleName)
end)
```

---

### GetDefaultCharDesc

**Purpose**

Returns the default character description.

**When Called**

This hook is triggered when:
- A default character description is needed
- During character creation process
- When character description field needs a default value
- Before character creation form is displayed

**Parameters**

* `client` (*Player*): Player creating character.

**Returns**

* `description` (*string*): Default description.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetDefaultCharDesc", "CustomDesc", function(client)
    return "A mysterious stranger..."
end)
```

---

### GetDefaultCharName

**Purpose**

Returns the default character name.

**When Called**

This hook is triggered when:
- A default character name is needed
- During character creation process
- When character name field needs a default value
- Before character creation form is displayed

**Parameters**

* `client` (*Player*): Player creating character.

**Returns**

* `name` (*string*): Default name.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetDefaultCharName", "CustomName", function(client)
    return "Unknown Citizen"
end)
```

---

### GetSalaryAmount

**Purpose**

Returns the salary amount for a player.

**Parameters**

* `client` (*Player*): Player to get salary for.

**Returns**

* `amount` (*number*): Salary amount.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetSalaryAmount", "CustomSalary", function(client)
    local char = client:getChar()
    return char:getData("salary", 100)
end)
```

---

### GetSalaryLimit

**Purpose**

Returns the salary limit for a player.

**Parameters**

* `client` (*Player*): Player to get salary limit for.

**Returns**

* `limit` (*number*): Salary limit.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetSalaryLimit", "CustomLimit", function(client)
    return 1000
end)
```

---

### InitializedConfig

**Purpose**

Fires when configuration is initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedConfig", "PostConfigInit", function()
    print("Configuration initialized")
end)
```

---

### InitializedItems

**Purpose**

Called when items are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedItems", "PostItemInit", function()
    print("Items initialized")
end)
```

---

### InitializedModules

**Purpose**

Fires when modules are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedModules", "PostModuleInit", function()
    print("Modules initialized")
end)
```

---

### InitializedOptions

**Purpose**

Called when options are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedOptions", "PostOptionInit", function()
    print("Options initialized")
end)
```

---

### InitializedSchema

**Purpose**

Fires when schema is initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedSchema", "PostSchemaInit", function()
    print("Schema initialized")
end)
```

---

### KeyLock

**Purpose**

Called when a key lock is used.

**Parameters**

* `client` (*Player*): Player using the key.
* `entity` (*Entity*): Entity being locked.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("KeyLock", "LockLog", function(client, entity)
    print(client:Nick(), "locked", entity)
end)
```

---

### KeyUnlock

**Purpose**

Called when a key unlock is used.

**Parameters**

* `client` (*Player*): Player using the key.
* `entity` (*Entity*): Entity being unlocked.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("KeyUnlock", "UnlockLog", function(client, entity)
    print(client:Nick(), "unlocked", entity)
end)
```

---

### DoorLockToggled

**Purpose**

Fires when a door's lock state is toggled.

**Parameters**

* `entity` (*Entity*): Door entity.
* `state` (*boolean*): New lock state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorLockToggled", "LockLog", function(entity, state)
    print("Door", entity, state and "locked" or "unlocked")
end)
```

---

### DoorOwnableToggled

**Purpose**

Called when a door's ownership state is toggled.

**Parameters**

* `entity` (*Entity*): Door entity.
* `state` (*boolean*): New ownership state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorOwnableToggled", "OwnableLog", function(entity, state)
    print("Door", entity, state and "made ownable" or "made unownable")
end)
```

---

### DoorEnabledToggled

**Purpose**

Fires when a door's enabled state is toggled.

**Parameters**

* `entity` (*Entity*): Door entity.
* `state` (*boolean*): New enabled state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorEnabledToggled", "EnabledLog", function(entity, state)
    print("Door", entity, state and "enabled" or "disabled")
end)
```

---

### DoorPriceSet

**Purpose**

Called when a door's price is set.

**Parameters**

* `entity` (*Entity*): Door entity.
* `price` (*number*): New price.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorPriceSet", "PriceLog", function(entity, price)
    print("Door", entity, "price set to", price)
end)
```

---

### DoorTitleSet

**Purpose**

Fires when a door's title is set.

**Parameters**

* `entity` (*Entity*): Door entity.
* `title` (*string*): New title.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorTitleSet", "TitleLog", function(entity, title)
    print("Door", entity, "title set to", title)
end)
```

---

### LiliaTablesLoaded

**Purpose**

Fires when all Lilia database tables have been loaded and are ready.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("LiliaTablesLoaded", "InitializeModules", function()
    -- Initialize modules that depend on database tables
end)
```

---

### OnItemRegistered

**Purpose**

Fires when an item is registered in the system.

**Parameters**

* `item` (*table*): Item data that was registered.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnItemRegistered", "LogItemRegistration", function(item)
    print("Item registered:", item.name)
end)
```

---

### OnLoadTables

**Purpose**

Called during the table loading process.

**Parameters**

* `tableName` (*string*): Name of the table being loaded.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnLoadTables", "LogTableLoading", function(tableName)
    print("Loading table:", tableName)
end)
```

---

### OnDatabaseLoaded

**Purpose**

Fires after the database schema and initial data have been loaded.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnDatabaseLoaded", "PostDatabaseInit", function()
    print("Database fully loaded")
end)
```

---

### OnPlayerPurchaseDoor

**Purpose**

Called when a player purchases a door.

**Parameters**

* `client` (*Player*): Player who purchased the door.
* `door` (*Entity*): Door that was purchased.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnPlayerPurchaseDoor", "LogPurchase", function(client, door)
    print(client:Nick(), "purchased door")
end)
```

---

### OnServerLog

**Purpose**

Fires when a server log entry is created.

**Parameters**

* `message` (*string*): Log message.
* `category` (*string*): Log category.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnServerLog", "CustomLogging", function(message, category)
    -- Custom log processing
end)
```

---

### PlayerMessageSend

**Purpose**

Called when a player sends a message.

**Parameters**

* `client` (*Player*): Player who sent the message.
* `chatType` (*string*): Type of chat message.
* `message` (*string*): Message content.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerMessageSend", "LogMessages", function(client, chatType, message)
    print(client:Nick(), "sent", chatType, ":", message)
end)
```

---

### ChatParsed

**Purpose**

Fires when a chat message is parsed.

**Parameters**

* `speaker` (*Player*): Player who sent the message.
* `text` (*string*): Original message text.
* `chatType` (*string*): Type of chat.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("ChatParsed", "ProcessChat", function(speaker, text, chatType)
    -- Process parsed chat message
end)
```

---

### PlayerModelChanged

**Purpose**

Called when a player's model changes.

**Parameters**

* `client` (*Player*): Player whose model changed.
* `oldModel` (*string*): Previous model.
* `newModel` (*string*): New model.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerModelChanged", "ModelLog", function(client, oldModel, newModel)
    print(client:Nick(), "changed model from", oldModel, "to", newModel)
end)
```

---

### SetupPlayerModel

**Purpose**

Allows modification of a player's model setup.

**Parameters**

* `client` (*Player*): Player whose model is being set up.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("SetupPlayerModel", "CustomSetup", function(client)
    -- Custom model setup logic
end)
```

---

### PlayerUseDoor

**Purpose**

Called when a player uses a door.

**Parameters**

* `client` (*Player*): Player using the door.
* `door` (*Entity*): Door being used.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerUseDoor", "UseLog", function(client, door)
    print(client:Nick(), "used door", door)
end)
```

---

### ShouldBarDraw

**Purpose**

Determines if HUD bars should be drawn.

**Parameters**

* `client` (*Player*): Player whose bars are being drawn.

**Returns**

- boolean: False to hide bars

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldBarDraw", "HideBars", function(client)
    return not client:getNetVar("hideBars", false)
end)
```

---

### ShouldDisableThirdperson

**Purpose**

Checks if third-person view should be disabled.

**Parameters**

* `client` (*Player*): Player to check.

**Returns**

- boolean: True to disable third-person

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldDisableThirdperson", "DisableInVehicle", function(client)
    return client:InVehicle()
end)
```

---

### ShouldHideBars

**Purpose**

Determines if HUD bars should be hidden.

**Parameters**

* `client` (*Player*): Player whose bars might be hidden.

**Returns**

- boolean: True to hide bars

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldHideBars", "HideInMenu", function(client)
    return lia.gui.menu and lia.gui.menu:IsVisible()
end)
```

---

### thirdPersonToggled

**Purpose**

Fires when third-person view is toggled.

**Parameters**

* `client` (*Player*): Player who toggled third-person.
* `state` (*boolean*): New third-person state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("thirdPersonToggled", "ToggleLog", function(client, state)
    print("Third-person", state and "enabled" or "disabled")
end)
```

---

### AddTextField

**Purpose**

Allows adding custom text fields to the HUD.

**Parameters**

* `client` (*Player*): Player to add text field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AddTextField", "CustomField", function(client)
    local char = client:getChar()
    if char then
        return {text = "Level: " .. char:getData("level", 1), color = Color(255, 255, 255)}
    end
end)
```

---

### F1OnAddTextField

**Purpose**

Called when adding text fields to the F1 menu.

**Parameters**

* `client` (*Player*): Player to add text field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddTextField", "F1Field", function(client)
    -- Add text field to F1 menu
end)
```

---

### F1OnAddBarField

**Purpose**

Called when adding bar fields to the F1 menu.

**Parameters**

* `client` (*Player*): Player to add bar field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddBarField", "F1Bar", function(client)
    -- Add bar field to F1 menu
end)
```

---

### CreateInformationButtons

**Purpose**

Allows adding custom information buttons to the main menu.

**Parameters**

* `panel` (*Panel*): Main menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CreateInformationButtons", "CustomButton", function(panel)
    panel:addButton("Custom Info", function()
        -- Custom button logic
    end)
end)
```

---

### PopulateConfigurationButtons

**Purpose**

Called to populate configuration buttons.

**Parameters**

* `panel` (*Panel*): Configuration panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("PopulateConfigurationButtons", "ConfigButtons", function(panel)
    -- Add configuration buttons
end)
```

---

### InitializedKeybinds

**Purpose**

Fires when keybinds are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedKeybinds", "PostKeybindInit", function()
    print("Keybinds initialized")
end)
```

---

### getOOCDelay

**Purpose**

Returns the delay between OOC messages.

**Parameters**

* `client` (*Player*): Player to get delay for.

**Returns**

* `delay` (*number*): Delay in seconds.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("getOOCDelay", "CustomDelay", function(client)
    return client:IsAdmin() and 0 or 30
end)
```

---

### OnChatReceived

**Purpose**

Called when a chat message is received.

**Parameters**

* `speaker` (*Player*): Player who sent the message.
* `text` (*string*): Message text.
* `chatType` (*string*): Type of chat.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("OnChatReceived", "ProcessReceived", function(speaker, text, chatType)
    -- Process received chat message
end)
```

---

### getAdjustedPartData

**Purpose**

Allows adjustment of PAC part data.

**Parameters**

* `client` (*Player*): Player whose PAC data is being adjusted.
* `partData` (*table*): Current part data.

**Returns**

* `adjustedData` (*table*): Adjusted part data.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("getAdjustedPartData", "AdjustPAC", function(client, partData)
    -- Adjust PAC part data
    return partData
end)
```

---

### AdjustPACPartData

**Purpose**

Called to adjust PAC part data.

**Parameters**

* `client` (*Player*): Player whose PAC data is being adjusted.
* `partData` (*table*): Current part data.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AdjustPACPartData", "PACAdjust", function(client, partData)
    -- Adjust PAC part data
end)
```

---

### attachPart

**Purpose**

Fires when a PAC part is attached.

**Parameters**

* `client` (*Player*): Player attaching the part.
* `part` (*table*): Part being attached.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("attachPart", "PartAttach", function(client, part)
    print("Part attached:", part.name)
end)
```

---

### removePart

**Purpose**

Called when a PAC part is removed.

**Parameters**

* `client` (*Player*): Player removing the part.
* `part` (*table*): Part being removed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("removePart", "PartRemove", function(client, part)
    print("Part removed:", part.name)
end)
```

---

### OnPAC3PartTransfered

**Purpose**

Fires when a PAC3 part is transferred.

**Parameters**

* `client` (*Player*): Player whose part is being transferred.
* `part` (*table*): Part being transferred.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("OnPAC3PartTransfered", "PartTransfer", function(client, part)
    print("PAC3 part transferred:", part.name)
end)
```

---

### DrawPlayerRagdoll

**Purpose**

Allows custom drawing of player ragdolls.

**Parameters**

* `client` (*Player*): Player whose ragdoll is being drawn.
* `entity` (*Entity*): Ragdoll entity.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("DrawPlayerRagdoll", "CustomRagdoll", function(client, entity)
    -- Custom ragdoll drawing
end)
```

---

### setupPACDataFromItems

**Purpose**

Called to set up PAC data from items.

**Parameters**

* `client` (*Player*): Player to set up PAC data for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("setupPACDataFromItems", "PACFromItems", function(client)
    -- Set up PAC data from items
end)
```

---

### TryViewModel

**Purpose**

Allows modification of viewmodel handling.

**Parameters**

* `client` (*Player*): Player whose viewmodel is being handled.
* `weapon` (*Weapon*): Weapon whose viewmodel is being handled.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("TryViewModel", "CustomViewModel", function(client, weapon)
    -- Custom viewmodel handling
end)
```

---

### WeaponCycleSound

**Purpose**

Called when weapon cycling sound should play.

**Parameters**

* `client` (*Player*): Player cycling weapons.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WeaponCycleSound", "CycleSound", function(client)
    -- Play custom cycle sound
end)
```

---

### WeaponSelectSound

**Purpose**

Fires when weapon selection sound should play.

**Parameters**

* `client` (*Player*): Player selecting weapon.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WeaponSelectSound", "SelectSound", function(client)
    -- Play custom select sound
end)
```

---

### ShouldDrawWepSelect

**Purpose**

Determines if weapon selection should be drawn.

**Parameters**

* `client` (*Player*): Player to check.

**Returns**

- boolean: False to hide weapon selection

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldDrawWepSelect", "HideWepSelect", function(client)
    return not client:getNetVar("hideWepSelect", false)
end)
```

---

### CanPlayerChooseWeapon

**Purpose**

Checks if a player can choose a weapon.

**Parameters**

* `client` (*Player*): Player attempting to choose weapon.
* `weapon` (*string*): Weapon class.

**Returns**

- boolean: False to prevent weapon choice

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerChooseWeapon", "RestrictWeapons", function(client, weapon)
    if weapon == "weapon_rpg" and not client:IsAdmin() then
        return false
    end
end)
```

---

### OverrideSpawnTime

**Purpose**

Allows overriding the spawn time for entities.

**Parameters**

* `entity` (*Entity*): Entity being spawned.

**Returns**

* `spawnTime` (*number*): Custom spawn time.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OverrideSpawnTime", "CustomSpawnTime", function(entity)
    if entity:GetClass() == "npc_headcrab" then
        return 60 -- Custom spawn time
    end
end)
```

---

### ShouldRespawnScreenAppear

**Purpose**

Determines if the respawn screen should appear.

**Parameters**

* `client` (*Player*): Player who died.

**Returns**

- boolean: False to hide respawn screen

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldRespawnScreenAppear", "CustomRespawn", function(client)
    return client:getNetVar("customRespawn", true)
end)
```

---

### PlayerSpawnPointSelected

**Purpose**

Called when a player selects a spawn point.

**Parameters**

* `client` (*Player*): Player selecting spawn point.
* `spawnPoint` (*Entity*): Selected spawn point.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerSpawnPointSelected", "SpawnLog", function(client, spawnPoint)
    print(client:Nick(), "selected spawn point", spawnPoint)
end)
```

---

### VoiceToggled

**Purpose**

Fires when voice chat is toggled.

**Parameters**

* `client` (*Player*): Player who toggled voice.
* `state` (*boolean*): New voice state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("VoiceToggled", "VoiceLog", function(client, state)
    print(client:Nick(), state and "enabled" or "disabled", "voice chat")
end)
```

---

### DermaSkinChanged

**Purpose**

Called when the Derma skin changes.

**Parameters**

* `skin` (*string*): New skin name.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("DermaSkinChanged", "SkinLog", function(skin)
    print("Derma skin changed to:", skin)
end)
```

---

### RefreshFonts

**Purpose**

Fires when fonts need to be refreshed.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("RefreshFonts", "FontRefresh", function()
    -- Refresh custom fonts
end)
```

---

### AdjustCreationData

**Purpose**

Allows adjustment of character creation data.

**Parameters**

* `client` (*Player*): Player creating character.
* `data` (*table*): Creation data.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AdjustCreationData", "AdjustData", function(client, data)
    -- Adjust character creation data
end)
```

---

### CanCharBeTransfered

**Purpose**

Determines if a character can be transferred.

**Parameters**

* `character` (*Character*): Character to transfer.
* `newPlayer` (*Player*): New player to transfer to.

**Returns**

- boolean: False to prevent transfer

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanCharBeTransfered", "TransferRestrict", function(character, newPlayer)
    return newPlayer:IsAdmin()
end)
```

---

### CanInviteToFaction

**Purpose**

Checks if a player can invite others to a faction.

**Parameters**

* `inviter` (*Player*): Player attempting to invite.
* `target` (*Player*): Target player.
* `faction` (*string*): Faction to invite to.

**Returns**

- boolean: False to prevent invitation

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanInviteToFaction", "InviteRestrict", function(inviter, target, faction)
    return inviter:getChar():getFaction() == faction
end)
```

---

### CanInviteToClass

**Purpose**

Determines if a player can invite others to a class.

**Parameters**

* `inviter` (*Player*): Player attempting to invite.
* `target` (*Player*): Target player.
* `class` (*string*): Class to invite to.

**Returns**

- boolean: False to prevent invitation

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanInviteToClass", "ClassInviteRestrict", function(inviter, target, class)
    return inviter:getChar():getClass() == "leader"
end)
```

---

### CanPlayerUseChar

**Purpose**

Checks if a player can use a character.

**Parameters**

* `client` (*Player*): Player attempting to use character.
* `character` (*Character*): Character to use.

**Returns**

- boolean: False to prevent character use

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerUseChar", "CharRestrict", function(client, character)
    return character:getData("banned", false) == false
end)
```

---

### CanPlayerSwitchChar

**Purpose**

Determines if a player can switch characters.

**Parameters**

* `client` (*Player*): Player attempting to switch.

**Returns**

- boolean: False to prevent switching

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerSwitchChar", "SwitchRestrict", function(client)
    return not client:getNetVar("switchCooldown", false)
end)
```

---

### CanPlayerLock

**Purpose**

Checks if a player can lock entities.

**Parameters**

* `client` (*Player*): Player attempting to lock.
* `entity` (*Entity*): Entity to lock.

**Returns**

- boolean: False to prevent locking

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerLock", "LockRestrict", function(client, entity)
    return entity:getNetVar("owner") == client
end)
```

---

### CanPlayerUnlock

**Purpose**

Determines if a player can unlock entities.

**Parameters**

* `client` (*Player*): Player attempting to unlock.
* `entity` (*Entity*): Entity to unlock.

**Returns**

- boolean: False to prevent unlocking

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerUnlock", "UnlockRestrict", function(client, entity)
    return entity:getNetVar("owner") == client
end)
```

---

### GetMaxStartingAttributePoints

**Purpose**

Returns the maximum starting attribute points.

**Parameters**

* `client` (*Player*): Player creating character.

**Returns**

* `points` (*number*): Maximum points.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetMaxStartingAttributePoints", "CustomPoints", function(client)
    return 50
end)
```

---

### GetAttributeStartingMax

**Purpose**

Returns the starting maximum for an attribute.

**Parameters**

* `client` (*Player*): Player creating character.
* `attribute` (*string*): Attribute name.

**Returns**

* `max` (*number*): Starting maximum.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetAttributeStartingMax", "AttributeMax", function(client, attribute)
    return 20
end)
```

---

### GetAttributeMax

**Purpose**

Returns the maximum value for an attribute.

**Parameters**

* `client` (*Player*): Player to check.
* `attribute` (*string*): Attribute name.

**Returns**

* `max` (*number*): Maximum value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("GetAttributeMax", "AttributeLimit", function(client, attribute)
    return 100
end)
```

---

### OnCharAttribBoosted

**Purpose**

Fires when a character's attribute is boosted.

**Parameters**

* `character` (*Character*): Character whose attribute was boosted.
* `attribute` (*string*): Attribute that was boosted.
* `amount` (*number*): Amount boosted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharAttribBoosted", "BoostLog", function(character, attribute, amount)
    print("Attribute", attribute, "boosted by", amount)
end)
```

---

### OnCharAttribUpdated

**Purpose**

Called when a character's attribute is updated.

**Parameters**

* `character` (*Character*): Character whose attribute was updated.
* `attribute` (*string*): Attribute that was updated.
* `oldValue` (*number*): Previous value.
* `newValue` (*number*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnCharAttribUpdated", "UpdateLog", function(character, attribute, oldValue, newValue)
    print("Attribute", attribute, "changed from", oldValue, "to", newValue)
end)
```

---

### CanPlayerModifyConfig

**Purpose**

Determines if a player can modify configuration.

**Parameters**

* `client` (*Player*): Player attempting to modify config.

**Returns**

- boolean: False to prevent modification

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerModifyConfig", "ConfigRestrict", function(client)
    return client:IsAdmin()
end)
```

---

### ConfigChanged

**Purpose**

Fires when configuration is changed.

**Parameters**

* `key` (*string*): Configuration key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("ConfigChanged", "ConfigLog", function(key, oldValue, newValue)
    print("Config", key, "changed from", oldValue, "to", newValue)
end)
```

---

### CharDeleted

**Purpose**

Called when a character is deleted.

**Parameters**

* `character` (*Character*): Character that was deleted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CharDeleted", "DeleteLog", function(character)
    print("Character deleted:", character:getName())
end)
```

---

### CheckFactionLimitReached

**Purpose**

Determines if a faction has reached its member limit.

**Parameters**

* `faction` (*string*): Faction to check.

**Returns**

- boolean: True if limit reached

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CheckFactionLimitReached", "FactionLimit", function(faction)
    local count = lia.faction.getPlayerCount(faction)
    return count >= 10
end)
```

---

### F1OnAddSection

**Purpose**

Called when adding sections to the F1 menu.

**Parameters**

* `panel` (*Panel*): F1 menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddSection", "F1Section", function(panel)
    -- Add custom section to F1 menu
end)
```

---

### GetWeaponName

**Purpose**

Returns the display name for a weapon.

**Parameters**

* `weapon` (*Weapon*): Weapon to get name for.

**Returns**

* `name` (*string*): Display name.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("GetWeaponName", "CustomName", function(weapon)
    return weapon:GetClass():gsub("weapon_", ""):gsub("_", " "):upper()
end)
```

---

### OnCharGetup

**Purpose**

Fires when a character gets up from the ground.

**Parameters**

* `character` (*Character*): Character getting up.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharGetup", "GetupLog", function(character)
    print("Character got up:", character:getName())
end)
```

---

### OnLocalizationLoaded

**Purpose**

Called when localization is loaded.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnLocalizationLoaded", "LocalizationReady", function()
    print("Localization loaded")
end)
```

---

### OnPlayerObserve

**Purpose**

Fires when a player starts observing another player.

**Parameters**

* `observer` (*Player*): Player doing the observing.
* `target` (*Player*): Player being observed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnPlayerObserve", "ObserveLog", function(observer, target)
    print(observer:Nick(), "is observing", target:Nick())
end)
```

---

### PlayerLoadedChar

**Purpose**

Called when a player loads a character.

**Parameters**

* `client` (*Player*): Player who loaded the character.
* `character` (*Character*): Character that was loaded.
* `oldCharacter` (*Character*): Previous character (if any).

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerLoadedChar", "LoadLog", function(client, character, oldCharacter)
    print(client:Nick(), "loaded character:", character:getName())
end)
```

---

### PrePlayerLoadedChar

**Purpose**

Fires before a player loads a character.

**Parameters**

* `client` (*Player*): Player loading the character.
* `character` (*Character*): Character being loaded.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PrePlayerLoadedChar", "PreLoad", function(client, character)
    -- Prepare for character load
end)
```

---

### PostPlayerLoadedChar

**Purpose**

Called after a player loads a character.

**Parameters**

* `client` (*Player*): Player who loaded the character.
* `character` (*Character*): Character that was loaded.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PostPlayerLoadedChar", "PostLoad", function(client, character)
    -- Post-load character setup
end)
```

---

### PopulateAdminStick

**Purpose**

Allows populating the admin stick with custom options.

**Parameters**

* `panel` (*Panel*): Admin stick panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("PopulateAdminStick", "CustomOptions", function(panel)
    -- Add custom admin stick options
end)
```

---

### TicketSystemCreated

**Purpose**

Fires when a ticket is created in the ticket system.

**Parameters**

* `ticket` (*table*): Ticket that was created.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemCreated", "TicketLog", function(ticket)
    print("Ticket created:", ticket.id)
end)
```

---

### TicketSystemClaim

**Purpose**

Called when a ticket is claimed.

**Parameters**

* `ticket` (*table*): Ticket that was claimed.
* `claimer` (*Player*): Player who claimed the ticket.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemClaim", "ClaimLog", function(ticket, claimer)
    print("Ticket", ticket.id, "claimed by", claimer:Nick())
end)
```

---

### TicketSystemClose

**Purpose**

Fires when a ticket is closed.

**Parameters**

* `ticket` (*table*): Ticket that was closed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemClose", "CloseLog", function(ticket)
    print("Ticket", ticket.id, "closed")
end)
```

---

### liaOptionReceived

**Purpose**

Called when an option is received from the server.

**Parameters**

* `key` (*string*): Option key.
* `value` (*any*): Option value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("liaOptionReceived", "OptionLog", function(key, value)
    print("Option received:", key, "=", value)
end)
```

---

### WarningIssued

**Purpose**

Fires when a warning is issued to a player.

**Parameters**

* `target` (*Player*): Player receiving the warning.
* `issuer` (*Player*): Player issuing the warning.
* `reason` (*string*): Warning reason.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("WarningIssued", "WarningLog", function(target, issuer, reason)
    print("Warning issued to", target:Nick(), "by", issuer:Nick(), ":", reason)
end)
```

---

### WarningRemoved

**Purpose**

Called when a warning is removed from a player.

**Parameters**

* `target` (*Player*): Player whose warning was removed.
* `remover` (*Player*): Player removing the warning.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("WarningRemoved", "RemoveLog", function(target, remover)
    print("Warning removed from", target:Nick(), "by", remover:Nick())
end)
```

---

### PlayerGagged

**Purpose**

Fires when a player is gagged.

**Parameters**

* `target` (*Player*): Player who was gagged.
* `gagger` (*Player*): Player who gagged them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerGagged", "GagLog", function(target, gagger)
    print(target:Nick(), "was gagged by", gagger:Nick())
end)
```

---

### PlayerUngagged

**Purpose**

Called when a player is ungagged.

**Parameters**

* `target` (*Player*): Player who was ungagged.
* `ungagger` (*Player*): Player who ungagged them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerUngagged", "UngagLog", function(target, ungagger)
    print(target:Nick(), "was ungagged by", ungagger:Nick())
end)
```

---

### PlayerMuted

**Purpose**

Fires when a player is muted.

**Parameters**

* `target` (*Player*): Player who was muted.
* `muter` (*Player*): Player who muted them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerMuted", "MuteLog", function(target, muter)
    print(target:Nick(), "was muted by", muter:Nick())
end)
```

---

### PlayerUnmuted

**Purpose**

Called when a player is unmuted.

**Parameters**

* `target` (*Player*): Player who was unmuted.
* `unmuter` (*Player*): Player who unmuted them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerUnmuted", "UnmuteLog", function(target, unmuter)
    print(target:Nick(), "was unmuted by", unmuter:Nick())
end)
```

---

### WebImageDownloaded

**Purpose**

Triggered after a remote image finishes downloading to the data folder.

**Parameters**

* `name` (*string*): Saved file name including extension.
* `path` (*string*): Local `data/` path to the image.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WebImageDownloaded", "ImageLog", function(name, path)
    print("Image downloaded:", name, path)
end)
```

---

### WebSoundDownloaded

**Purpose**

Triggered after a remote sound file finishes downloading to the data folder.

**Parameters**

* `name` (*string*): Saved file name including extension.
* `path` (*string*): Local `data/` path to the sound file.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WebSoundDownloaded", "SoundLog", function(name, path)
    print("Sound downloaded:", name, path)
end)
```

---

### PlayerCheatDetected

**Purpose**

Fires when cheat detection is triggered.

**Parameters**

* `client` (*Player*): Player detected cheating.
* `cheatType` (*string*): Type of cheat detected.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerCheatDetected", "CheatLog", function(client, cheatType)
    print("Cheat detected:", client:Nick(), cheatType)
end)
```

---

### OnCheaterCaught

**Purpose**

Called when a cheater is caught.

**Parameters**

* `client` (*Player*): Player caught cheating.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCheaterCaught", "CheaterLog", function(client)
    print("Cheater caught:", client:Nick())
end)
```

---

### FilterCharacterModels

**Purpose**

Allows filtering of available character models.

**Parameters**

* `models` (*table*): Table of available models.

**Returns**

* `filteredModels` (*table*): Filtered models table.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("FilterCharacterModels", "ModelFilter", function(models)
    -- Filter character models
    return models
end)
```

---

### GetModelGender

**Purpose**

Returns the gender associated with a model.

**Parameters**

* `model` (*string*): Model path.

**Returns**

* `gender` (*string*): Model gender.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("GetModelGender", "GenderDetect", function(model)
    if model:find("female") then
        return "female"
    end
    return "male"
end)
```

---

### GetVendorSaleScale

**Purpose**

Returns the sale scale for vendors.

**Parameters**

* `vendor` (*Entity*): Vendor entity.

**Returns**

* `scale` (*number*): Sale scale.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetVendorSaleScale", "CustomScale", function(vendor)
    return vendor:getNetVar("saleScale", 1.0)
end)
```

---

### IsSuitableForTrunk

**Purpose**

Determines if an item is suitable for storage in a vehicle trunk.

**Parameters**

* `item` (*Item*): Item to check.

**Returns**

- boolean: True if suitable for trunk

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("IsSuitableForTrunk", "TrunkCheck", function(item)
    return item.width <= 4 and item.height <= 4
end)
```

---

### ItemDefaultFunctions

**Purpose**

Allows adding default functions to items.

**Parameters**

* `item` (*Item*): Item to add functions to.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("ItemDefaultFunctions", "DefaultFuncs", function(item)
    -- Add default functions to item
end)
```

---

### OnCharFlagsGiven

**Purpose**

Fires when character flags are given.

**Parameters**

* `character` (*Character*): Character receiving flags.
* `flags` (*string*): Flags given.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharFlagsGiven", "FlagLog", function(character, flags)
    print("Flags given:", flags)
end)
```

---

### OnCharFlagsTaken

**Purpose**

Called when character flags are taken.

**Parameters**

* `character` (*Character*): Character losing flags.
* `flags` (*string*): Flags taken.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharFlagsTaken", "FlagRemoveLog", function(character, flags)
    print("Flags taken:", flags)
end)
```

---

### OnCheaterStatusChanged

**Purpose**

Fires when a player's cheater status changes.

**Parameters**

* `client` (*Player*): Player whose status changed.
* `isCheater` (*boolean*): New cheater status.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCheaterStatusChanged", "StatusLog", function(client, isCheater)
    print(client:Nick(), "cheater status:", isCheater)
end)
```

---

### OnConfigUpdated

**Purpose**

Called when configuration is updated.

**Parameters**

* `key` (*string*): Configuration key that was updated.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnConfigUpdated", "ConfigUpdateLog", function(key, oldValue, newValue)
    print("Config updated:", key, "from", oldValue, "to", newValue)
end)
```

---

### OnOOCMessageSent

**Purpose**

Fires when an out-of-character message is sent.

**Parameters**

* `client` (*Player*): Player who sent the message.
* `text` (*string*): Message content.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnOOCMessageSent", "OOCMsgLog", function(client, text)
    print("OOC message from", client:Nick(), ":", text)
end)
```

---

### OnSalaryGive

**Purpose**

Called when salary is given to a player.

**Parameters**

* `client` (*Player*): Player receiving salary.
* `amount` (*number*): Salary amount.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnSalaryGive", "SalaryLog", function(client, amount)
    print(client:Nick(), "received salary:", amount)
end)
```

---

### OnTicketClaimed

**Purpose**

Fires when a ticket is claimed.

**Parameters**

* `ticket` (*table*): Ticket that was claimed.
* `claimer` (*Player*): Player who claimed the ticket.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClaimed", "TicketClaimLog", function(ticket, claimer)
    print("Ticket", ticket.id, "claimed by", claimer:Nick())
end)
```

---

### OnTicketClosed

**Purpose**

Called when a ticket is closed.

**When Called**

This hook is triggered when:
- A ticket is closed by an administrator
- A ticket is resolved and marked as closed
- After ticket closure process is completed
- During ticket system cleanup

**Parameters**

* `ticket` (*table*): Ticket that was closed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClosed", "TicketCloseLog", function(ticket)
    print("Ticket", ticket.id, "closed")
end)
```

---

### OnTicketCreated

**Purpose**

Fires when a ticket is created.

**When Called**

This hook is triggered when:
- A player creates a new support ticket
- A ticket is submitted to the ticket system
- After ticket creation process is completed
- During ticket system initialization

**Parameters**

* `ticket` (*table*): Ticket that was created.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketCreated", "TicketCreateLog", function(ticket)
    print("Ticket", ticket.id, "created")
end)
```

---

### OnVendorEdited

**Purpose**

Called when a vendor is edited.

**When Called**

This hook is triggered when:
- A vendor's settings are modified
- Vendor configuration is updated
- After vendor edit process is completed
- During vendor management operations

**Parameters**

* `vendor` (*Entity*): Vendor that was edited.
* `client` (*Player*): Player who edited the vendor.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnVendorEdited", "VendorEditLog", function(vendor, client)
    print("Vendor edited by", client:Nick())
end)
```

---

### PaintItem

**Purpose**

Allows custom painting of items.

**When Called**

This hook is triggered when:
- An item is being rendered in inventory
- Item display is being drawn
- Before item visual representation is shown
- During item rendering process

**Parameters**

* `item` (*Item*): Item being painted.
* `width` (*number*): Item width.
* `height` (*number*): Item height.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("PaintItem", "CustomPaint", function(item, width, height)
    -- Custom item painting
end)
```

