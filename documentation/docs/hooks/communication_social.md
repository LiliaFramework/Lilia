# Communication & Social Hooks

This page documents the hooks related to communication, social interaction, and user interface functionality in the Lilia framework.

---

## Overview

The communication and social hooks form the foundation of Lilia's user interaction system, providing comprehensive control over chat systems, voice communication, user interfaces, character management, and social features. These hooks enable developers to create rich, interactive experiences and customize every aspect of player communication and social interaction.

The communication system in Lilia is built around a multi-layered architecture that supports various forms of interaction, from text-based chat to voice communication and complex UI systems. The hooks cover several key areas:

**Chat System Management**: Hooks like `ChatAddText`, `StartChat`, `FinishChat`, and `PostPlayerSay` provide complete control over the chat system, allowing for custom message formatting, filtering, and processing. The system supports multiple chat types including in-character, out-of-character, and custom channels.

**Voice Communication**: Voice-related hooks such as `PlayerEndVoice`, `VoiceToggled`, and voice panel management enable sophisticated voice chat systems with custom notifications, restrictions, and visual feedback.

**User Interface Customization**: A comprehensive set of hooks including `ScoreboardOpened`, `F1MenuOpened`, `InventoryOpened`, and various panel creation hooks allow for complete customization of the user interface, enabling developers to create unique and immersive UI experiences.

**Character Management Interface**: Hooks like `CharacterMenuOpened`, `ModifyCharacterModel`, `CanPlayerCreateChar`, and character creation flow management provide extensive control over character selection, creation, and customization interfaces.

**Social Features and Moderation**: The system includes hooks for player moderation (`PlayerMuted`, `PlayerGagged`, `WarningIssued`), ticket systems, and social interaction features that enable comprehensive community management.

**Menu and Panel Lifecycle**: Hooks for various menu states (`F1MenuOpened`, `InventoryOpened`, `InteractionMenuOpened`) provide fine-grained control over UI lifecycle management, allowing for custom animations, effects, and behaviors.

**Tooltip and Display Customization**: Advanced UI customization through `TooltipLayout`, `TooltipPaint`, `GetDisplayedName`, and `GetDisplayedDescription` hooks enable sophisticated display systems with custom formatting and visual effects.

---

### PlayerEndVoice

**Purpose**

Fired when the voice panel for a player is removed from the HUD.

**Parameters**

* `client` (*Player*): Player whose panel ended.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when a player stops using voice chat.
-- The PlayerEndVoice hook is called when a player's voice panel is removed from the HUD.
-- This hook is useful for notifications, logging, and updating UI elements.

-- Notify all players when someone stops talking
hook.Add("PlayerEndVoice", "NotifyVoiceStop", function(ply)
    chat.AddText(Color(200, 200, 255), ply:Nick() .. " stopped talking")
    surface.PlaySound("buttons/button19.wav")
end)

-- Log voice activity for debugging purposes
hook.Add("PlayerEndVoice", "LogVoiceActivity", function(ply)
    print(ply:Nick() .. " stopped using voice chat")
end)

-- Update the player's voice status for UI elements
hook.Add("PlayerEndVoice", "UpdateVoiceStatus", function(ply)
    if IsValid(ply) then
        ply:SetNWBool("isTalking", false)
    end
end)
```

---

### ShouldShowPlayerOnScoreboard

**Purpose**

Return false to omit players from the scoreboard. Determines if a player should appear on the scoreboard.

**Parameters**

* `player` (*Player*): Player to test.

**Returns**

* `boolean` (*boolean*): False to hide the player, true or nil to show them.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control which players appear on the scoreboard.
-- The scoreboard displays a list of all players currently on the server.
-- This hook allows you to hide certain players based on various conditions.

-- Hide bot players from the scoreboard
hook.Add("ShouldShowPlayerOnScoreboard", "HideBots", function(ply)
    if ply:IsBot() then
        return false
    end
end)

-- Hide dead players from the scoreboard
hook.Add("ShouldShowPlayerOnScoreboard", "HideSpectators", function(ply)
    if not ply:Alive() then
        return false
    end
end)

-- Hide players with invisible status from the scoreboard
hook.Add("ShouldShowPlayerOnScoreboard", "HideInvisiblePlayers", function(ply)
    if ply:GetNWBool("isInvisible", false) then
        return false
    end
end)
```

---

### CanPlayerOpenScoreboard

**Purpose**

Checks if the local player may open the scoreboard. Return false to prevent it from showing.

**Parameters**

* `player` (*Player*): Local player.

**Returns**

* `boolean` (*boolean*): False to disallow opening, true or nil to allow.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control when players can open the scoreboard.
-- The scoreboard is typically opened by pressing the Tab key or similar input.
-- This hook allows you to implement custom restrictions based on player state or permissions.

-- Only allow living players to open the scoreboard
hook.Add("CanPlayerOpenScoreboard", "AliveOnly", function(ply)
    if not ply:Alive() then
        return false
    end
end)

-- Restrict scoreboard access to admins only
hook.Add("CanPlayerOpenScoreboard", "AdminOnly", function(ply)
    if not ply:IsAdmin() then
        return false
    end
end)

-- Prevent scoreboard access during combat
hook.Add("CanPlayerOpenScoreboard", "RestrictInCombat", function(ply)
    if ply:GetNWBool("inCombat", false) then
        return false
    end
end)
```

---

### ShowPlayerOptions

**Purpose**

Populate the scoreboard context menu with extra options. Allows modules to add scoreboard options for a player.

**Parameters**

* `player` (*Player*): Target player.
* `options` (*table*): Options table to populate.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to add custom options to the scoreboard context menu.
-- The context menu appears when right-clicking on a player's name in the scoreboard.
-- This hook allows you to add custom actions that players can perform on other players.

-- Add a wave option to the scoreboard context menu
hook.Add("ShowPlayerOptions", "WaveOption", function(ply, options)
    options[#options + 1] = {
        name = "Wave",
        func = function()
            RunConsoleCommand("say", "/me waves to " .. ply:Nick())
            LocalPlayer():ConCommand("act wave")
        end,
    }
end)

-- Add friend option for other players
hook.Add("ShowPlayerOptions", "AddFriendOption", function(ply, options)
    if ply ~= LocalPlayer() then
        options[#options + 1] = {
            name = "Add Friend",
            func = function()
                RunConsoleCommand("say", "/addfriend " .. ply:SteamID())
            end,
        }
    end
end)

-- Add admin options for administrators
hook.Add("ShowPlayerOptions", "AdminOptions", function(ply, options)
    if LocalPlayer():IsAdmin() and ply ~= LocalPlayer() then
        options[#options + 1] = {
            name = "Kick Player",
            func = function()
                RunConsoleCommand("say", "!kick " .. ply:Nick())
            end,
        }
    end
end)
```

---

### GetDisplayedName

**Purpose**

Returns the name text to display for a player in UI panels.

**Parameters**

* `client` (*Player*): Player to query.

**Returns**

* `string` (*string* | *nil*): Name text to display, or nil to use default.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize how player names are displayed in UI panels.
-- Player names appear in various places throughout the game interface.
-- This hook allows you to add prefixes, suffixes, or completely override player names.

-- Add admin prefix to player names
hook.Add("GetDisplayedName", "AdminPrefix", function(ply)
    if ply:IsAdmin() then
        return "[ADMIN] " .. ply:Nick()
    end
end)

-- Add VIP prefix to player names
hook.Add("GetDisplayedName", "VIPPrefix", function(ply)
    if ply:GetNWBool("isVIP", false) then
        return "[VIP] " .. ply:Nick()
    end
end)

-- Use custom name if available
hook.Add("GetDisplayedName", "CustomName", function(ply)
    local customName = ply:GetNWString("customName", "")
    if customName ~= "" then
        return customName
    end
end)
```

---

### GetDisplayedDescription

**Purpose**

Supplies the description text shown on the scoreboard. Returns the description text to display for a player.

**Parameters**

* `player` (*Player*): Target player.
* `isHUD` (*boolean*): True when drawing overhead text rather than in menus.

**Returns**

* `string` (*string*): Description text to display.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize player descriptions shown on the scoreboard.
-- Player descriptions provide additional information about players in the UI.
-- This hook allows you to display custom information based on player data or context.

-- Show OOC description in scoreboard (not in HUD)
hook.Add("GetDisplayedDescription", "OOCDesc", function(ply, isHUD)
    if not isHUD then
        return ply:GetNWString("oocDesc", "")
    end
end)

-- Display player's faction information
hook.Add("GetDisplayedDescription", "FactionDesc", function(ply, isHUD)
    local faction = ply:GetNWString("faction", "Citizen")
    return "Faction: " .. faction
end)

-- Use custom description if available
hook.Add("GetDisplayedDescription", "CustomDesc", function(ply, isHUD)
    local customDesc = ply:GetNWString("customDescription", "")
    if customDesc ~= "" then
        return customDesc
    end
end)
```

---

### ScoreboardOpened

**Purpose**

Triggered when the scoreboard becomes visible on the client.

**Parameters**

* `panel` (*Panel*): Scoreboard panel instance.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the scoreboard becomes visible.
-- The scoreboard is typically opened by pressing the Tab key or similar input.
-- This hook is useful for playing sounds, animations, and logging scoreboard usage.

-- Play sound when scoreboard opens
hook.Add("ScoreboardOpened", "PlaySound", function(pnl)
    surface.PlaySound("buttons/button15.wav")
end)

-- Animate scoreboard with fade-in effect
hook.Add("ScoreboardOpened", "AnimateScoreboard", function(pnl)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.3, 0)
end)

-- Log when scoreboard is opened for debugging
hook.Add("ScoreboardOpened", "LogOpen", function(pnl)
    print("Scoreboard opened")
end)
```

---

### ScoreboardClosed

**Purpose**

Called after the scoreboard is hidden or removed.

**Parameters**

* `panel` (*Panel*): Scoreboard panel instance.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the scoreboard is hidden or removed.
-- The scoreboard is typically closed by releasing the Tab key or similar input.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

-- Log when scoreboard is closed
hook.Add("ScoreboardClosed", "LogClose", function(pnl)
    print("Closed scoreboard")
end)

-- Clean up any effects or timers when scoreboard closes
hook.Add("ScoreboardClosed", "CleanupEffects", function(pnl)
    -- Clean up any effects or timers
end)

-- Play sound when scoreboard closes
hook.Add("ScoreboardClosed", "PlayCloseSound", function(pnl)
    surface.PlaySound("buttons/button14.wav")
end)
```

---

### ScoreboardRowCreated

**Purpose**

Runs after a player's row panel is added to the scoreboard. Use this to customize the panel or add additional elements.

**Parameters**

* `panel` (*Panel*): Row panel created for the player.
* `player` (*Player*): Player associated with the row.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize scoreboard rows after they are created.
-- Each player gets their own row in the scoreboard with their information.
-- This hook allows you to modify the appearance and add custom elements to each row.

-- Add glow effect to scoreboard rows
hook.Add("ScoreboardRowCreated", "AddGlow", function(pnl, ply)
    pnl:SetAlpha(200)
end)

-- Apply custom styling based on player status
hook.Add("ScoreboardRowCreated", "CustomStyling", function(pnl, ply)
    if ply:IsAdmin() then
        pnl:SetBackgroundColor(Color(255, 255, 0, 50))
    end
end)

-- Add additional player information to scoreboard rows
hook.Add("ScoreboardRowCreated", "AddPlayerInfo", function(pnl, ply)
    local label = vgui.Create("DLabel", pnl)
    label:SetText("Ping: " .. ply:Ping())
    label:SetPos(10, 10)
end)
```

---

### ScoreboardRowRemoved

**Purpose**

Runs after a player's row panel is removed from the scoreboard.

**Parameters**

* `panel` (*Panel*): Row panel being removed.
* `player` (*Player*): Player associated with the row.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when a scoreboard row is removed.
-- Scoreboard rows are removed when players disconnect or leave the server.
-- This hook is useful for cleanup operations and logging when players leave.

-- Clean up any effects or timers when scoreboard row is removed
hook.Add("ScoreboardRowRemoved", "CleanupEffects", function(pnl, ply)
    -- Clean up any effects or timers associated with this row
end)

-- Log when a scoreboard row is removed
hook.Add("ScoreboardRowRemoved", "LogRemoval", function(pnl, ply)
    print("Removed scoreboard row for", ply:Nick())
end)

-- Clean up custom data associated with the row
hook.Add("ScoreboardRowRemoved", "CleanupData", function(pnl, ply)
    if IsValid(pnl.customData) then
        pnl.customData:Remove()
    end
end)
```

---

### SpawnlistContentChanged

**Purpose**

Triggered when a spawn icon is removed from the extended spawn menu. Fired when content is removed from the spawn menu.

**Parameters**

* `icon` (*Panel*): Icon affected.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when spawnlist content is removed.
-- The spawnlist contains items that can be spawned in the game world.
-- This hook is useful for notifications, logging, and updating UI elements when items are removed.

-- Notify when spawnlist content is removed
hook.Add("SpawnlistContentChanged", "IconRemovedNotify", function(icon)
    surface.PlaySound("buttons/button9.wav")
    local name = icon:GetSpawnName() or icon:GetModelName() or tostring(icon)
    print("Removed spawn icon", name)
end)

-- Log all spawnlist content changes
hook.Add("SpawnlistContentChanged", "LogSpawnlistChanges", function(icon)
    print("Spawnlist content changed")
end)

-- Update spawnlist item count display
hook.Add("SpawnlistContentChanged", "UpdateSpawnlistCount", function(icon)
    -- Update spawnlist item count display
end)
```

---

### ModifyScoreboardModel

**Purpose**

Allows modules to customize the model entity displayed for scoreboard entries. This can be used to attach props or tweak bodygroups.

**Parameters**

* `entity` (*Entity*): Model entity being shown.
* `player` (*Player*): Player this entry represents.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the model entity displayed for scoreboard entries.
-- Each player gets a 3D model representation in the scoreboard.
-- This hook allows you to attach props, modify skins, or add accessories to these models.

-- Add a cone hat to all players on the scoreboard
hook.Add("ModifyScoreboardModel", "ConeHat", function(ent, ply)
    local hat = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
    hat:SetParent(ent)
    hat:AddEffects(EF_BONEMERGE)
end)

-- Add a crown for admin players on the scoreboard
hook.Add("ModifyScoreboardModel", "AdminCrown", function(ent, ply)
    if ply:IsAdmin() then
        local crown = ClientsideModel("models/props_c17/can01.mdl")
        crown:SetParent(ent)
        crown:AddEffects(EF_BONEMERGE)
        crown:SetPos(ent:GetPos() + Vector(0, 0, 20))
    end
end)

-- Apply custom skin to scoreboard models
hook.Add("ModifyScoreboardModel", "CustomSkin", function(ent, ply)
    ent:SetSkin(ply:GetNWInt("customSkin", 0))
end)
```

---

### ShouldAllowScoreboardOverride

**Purpose**

Checks if a scoreboard value may be overridden by other hooks so modules can replace the displayed name, model or description for a player.

**Parameters**

* `client` (*Player*): Player being displayed.
* `var` (*string*): Field identifier such as "name", "model" or "desc".

**Returns**

* `boolean` (*boolean*): Return true to allow override, false to prevent.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control which scoreboard values can be overridden by other hooks.
-- Scoreboard overrides allow modules to replace displayed names, models, or descriptions.
-- This hook provides fine-grained control over what can be customized for each player.

-- Allow name overrides for all players
hook.Add("ShouldAllowScoreboardOverride", "OverrideNames", function(ply, var)
    if var == "name" then
        return true
    end
end)

-- Allow all overrides for all players
hook.Add("ShouldAllowScoreboardOverride", "AllowAllOverrides", function(ply, var)
    return true
end)

-- Restrict model overrides to admins only
hook.Add("ShouldAllowScoreboardOverride", "RestrictModelOverrides", function(ply, var)
    if var == "model" and not ply:IsAdmin() then
        return false
    end
    return true
end)
```

---

### F1MenuOpened

**Purpose**

Runs when the F1 main menu panel initializes.

**Parameters**

* `panel` (*Panel*): Menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the F1 main menu panel initializes.
-- The F1 menu is the main interface that players use to access various game features.
-- This hook is useful for playing sounds, animations, and logging menu usage.

-- Log when F1 menu is opened
hook.Add("F1MenuOpened", "Notify", function(menu)
    print("F1 menu opened")
end)

-- Play sound when F1 menu opens
hook.Add("F1MenuOpened", "PlayMenuSound", function(menu)
    surface.PlaySound("ui/buttonclickrelease.wav")
end)

-- Animate F1 menu with fade-in effect
hook.Add("F1MenuOpened", "AnimateMenu", function(menu)
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.5, 0)
end)
```

---

### F1MenuClosed

**Purpose**

Fires when the F1 main menu panel is removed.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the F1 main menu panel is removed.
-- The F1 menu is closed when players press F1 again or use other means to close it.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

hook.Add("F1MenuClosed", "MenuGone", function()
    print("F1 menu closed")
end)

hook.Add("F1MenuClosed", "PlayCloseSound", function()
    surface.PlaySound("ui/buttonclick.wav")
end)

hook.Add("F1MenuClosed", "CleanupMenuData", function()
    -- Clean up any menu-related data
end)
```

---

### CharacterMenuOpened

**Purpose**

Called when the character selection menu is created.

**Parameters**

* `panel` (*Panel*): Character menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the character selection menu is created.
-- The character menu allows players to select, create, and manage their characters.
-- This hook is useful for playing music, animations, and logging menu usage.

-- Play background music when character menu opens
hook.Add("CharacterMenuOpened", "PlayMusic", function(panel)
    surface.PlaySound("music/hl2_song17.mp3")
end)

-- Animate character menu with fade-in effect
hook.Add("CharacterMenuOpened", "AnimateCharacterMenu", function(panel)
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.3, 0)
end)

-- Log when character menu is opened
hook.Add("CharacterMenuOpened", "LogCharacterMenu", function(panel)
    print("Character menu opened")
end)
```

---

### CharacterMenuClosed

**Purpose**

Fired when the character menu panel is removed.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the character menu panel is removed.
-- The character menu is closed when players finish selecting or creating a character.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

-- Log when character menu is closed
hook.Add("CharacterMenuClosed", "StopMusic", function()
    print("Character menu closed")
end)

-- Clean up character data when menu closes
hook.Add("CharacterMenuClosed", "CleanupCharacterData", function()
    -- Clean up character selection data
end)

-- Play sound when character menu closes
hook.Add("CharacterMenuClosed", "PlayCloseSound", function()
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### ItemPanelOpened

**Purpose**

Triggered when an item detail panel is created.

**Parameters**

* `panel` (*Panel*): Item panel instance.
* `entity` (*Entity*): Item entity represented.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when an item detail panel is created.
-- Item panels display detailed information about items when players inspect them.
-- This hook is useful for animations, sounds, and logging item inspections.

-- Log when item panel is opened
hook.Add("ItemPanelOpened", "Inspect", function(pnl, ent)
    print("Viewing item", ent)
end)

-- Animate item panel with fade-in effect
hook.Add("ItemPanelOpened", "AnimateItemPanel", function(pnl, ent)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.2, 0)
end)

-- Play sound when item panel opens
hook.Add("ItemPanelOpened", "PlayItemSound", function(pnl, ent)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### ItemPanelClosed

**Purpose**

Runs after an item panel is removed.

**Parameters**

* `panel` (*Panel*): Item panel instance.
* `entity` (*Entity*): Item entity represented.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when an item panel is removed.
-- Item panels are closed when players finish inspecting items or close the interface.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

-- Log when item panel is closed
hook.Add("ItemPanelClosed", "LogClose", function(pnl, ent)
    print("Closed item panel for", ent)
end)

-- Clean up item-specific data when panel closes
hook.Add("ItemPanelClosed", "CleanupItemData", function(pnl, ent)
    -- Clean up item-specific data
end)

-- Play sound when item panel closes
hook.Add("ItemPanelClosed", "PlayCloseSound", function(pnl, ent)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### InventoryOpened

**Purpose**

Called when an inventory panel is created.

**Parameters**

* `panel` (*Panel*): Inventory panel.
* `inventory` (*table*): Inventory shown.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when an inventory panel is created.
-- Inventory panels display the contents of player inventories or containers.
-- This hook is useful for animations, sounds, and logging inventory access.

-- Log when inventory is opened
hook.Add("InventoryOpened", "Flash", function(pnl, inv)
    print("Opened inventory", inv:getID())
end)

-- Animate inventory panel with fade-in effect
hook.Add("InventoryOpened", "AnimateInventory", function(pnl, inv)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.3, 0)
end)

-- Play sound when inventory opens
hook.Add("InventoryOpened", "PlayInventorySound", function(pnl, inv)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### InventoryClosed

**Purpose**

Fired when an inventory panel is removed.

**Parameters**

* `panel` (*Panel*): Inventory panel.
* `inventory` (*table*): Inventory shown.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when an inventory panel is removed.
-- Inventory panels are closed when players finish managing their inventory or close the interface.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

-- Log when inventory is closed
hook.Add("InventoryClosed", "StopFlash", function(pnl, inv)
    print("Closed inventory", inv:getID())
end)

-- Clean up inventory data when panel closes
hook.Add("InventoryClosed", "CleanupInventoryData", function(pnl, inv)
    -- Clean up inventory-specific data
end)

-- Play sound when inventory closes
hook.Add("InventoryClosed", "PlayCloseSound", function(pnl, inv)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### InteractionMenuOpened

**Purpose**

Called when the interaction menu pops up.

**Parameters**

* `frame` (*Panel*): Interaction menu frame.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the interaction menu pops up.
-- The interaction menu appears when players right-click on objects or use interaction keys.
-- This hook is useful for animations, sounds, and logging interaction menu usage.

-- Log when interaction menu is opened
hook.Add("InteractionMenuOpened", "Notify", function(frame)
    print("Opened interaction menu")
end)

-- Animate interaction menu with fade-in effect
hook.Add("InteractionMenuOpened", "AnimateMenu", function(frame)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.2, 0)
end)

-- Play sound when interaction menu opens
hook.Add("InteractionMenuOpened", "PlayMenuSound", function(frame)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### InteractionMenuClosed

**Purpose**

Runs when the interaction menu frame is removed.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the interaction menu frame is removed.
-- The interaction menu is closed when players select an option or click elsewhere.
-- This hook is useful for cleanup operations, logging, and playing closing sounds.

-- Log when interaction menu is closed
hook.Add("InteractionMenuClosed", "Notify", function()
    print("Interaction menu closed")
end)

-- Clean up menu data when interaction menu closes
hook.Add("InteractionMenuClosed", "CleanupMenuData", function()
    -- Clean up interaction menu data
end)

-- Play sound when interaction menu closes
hook.Add("InteractionMenuClosed", "PlayCloseSound", function()
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### FinishChat

**Purpose**

Fires when the chat box closes. Fired when the chat box is closed.

**Parameters**

* `chatType` (*string*): The chat command being checked.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the chat box closes.
-- The chat box is used for players to send messages to other players.
-- This hook is useful for animations, cleanup operations, and playing closing sounds.

-- Fade out chat box when it closes
hook.Add("FinishChat", "ChatClosed", function()
    if IsValid(lia.gui.chat) then
        lia.gui.chat:AlphaTo(0, 0.2, 0, function()
            lia.gui.chat:Remove()
        end)
    end
end)

-- Log when chat box is closed
hook.Add("FinishChat", "LogChatClose", function()
    print("Chat box closed")
end)

-- Play sound when chat box closes
hook.Add("FinishChat", "PlayCloseSound", function()
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### StartChat

**Purpose**

Fires when the chat box opens. Fired when the chat box is opened.

**Parameters**

* `chatType` (*string*): The chat command being checked.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when the chat box opens.
-- The chat box is opened when players press the chat key (usually Enter).
-- This hook is useful for playing sounds, focusing the chat, and animations.

-- Play sound and focus chat when it opens
hook.Add("StartChat", "ChatOpened", function()
    surface.PlaySound("buttons/lightswitch2.wav")
    if IsValid(lia.gui.chat) then
        lia.gui.chat:MakePopup()
    end
end)

-- Log when chat box is opened
hook.Add("StartChat", "LogChatOpen", function()
    print("Chat box opened")
end)

-- Animate chat box with fade-in effect
hook.Add("StartChat", "AnimateChat", function()
    if IsValid(lia.gui.chat) then
        lia.gui.chat:SetAlpha(0)
        lia.gui.chat:AlphaTo(255, 0.2, 0)
    end
end)
```

---

### ChatAddText

**Purpose**

Allows modification of the markup before chat messages are printed. Allows modification of markup before chat text is shown.

**Parameters**

* `text` (*string*): Base markup text.
* `...` (*any*): Additional segments.

**Returns**

* `string` (*string*): Modified markup text.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to modify chat messages before they are displayed.
-- The chat system processes messages and displays them to players.
-- This hook allows you to change colors, add timestamps, or modify message content.

-- Turn chat messages green and add timestamp
hook.Add("ChatAddText", "GreenSystem", function(text, ...)
    local stamp = os.date("[%H:%M] ")
    return Color(0, 255, 0), stamp .. text, ...
end)

-- Add detailed timestamp to all chat messages
hook.Add("ChatAddText", "AddTimestamp", function(text, ...)
    local stamp = os.date("[%H:%M:%S] ")
    return Color(255, 255, 255), stamp, text, ...
end)

-- Apply custom colors to chat messages
hook.Add("ChatAddText", "CustomColors", function(text, ...)
    return Color(100, 200, 255), text, ...
end)
```

---

### ChatboxPanelCreated

**Purpose**

Called when the chatbox panel is instantiated.

**Parameters**

* `panel` (*Panel*): Newly created chat panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the chatbox panel when it is created.
-- The chatbox panel displays chat messages and handles input.
-- This hook allows you to apply custom styling, fonts, and animations to the chat interface.

-- Apply custom font to chat panel
hook.Add("ChatboxPanelCreated", "StyleChat", function(pnl)
    pnl:SetFontInternal("liaChatFont")
end)

-- Apply custom styling to chat panel
hook.Add("ChatboxPanelCreated", "CustomChatStyling", function(pnl)
    pnl:SetBackgroundColor(Color(0, 0, 0, 150))
    pnl:SetTextColor(Color(255, 255, 255))
end)

-- Animate chat panel with fade-in effect
hook.Add("ChatboxPanelCreated", "AnimateChatbox", function(pnl)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, 0.3, 0)
end)
```

---

### ChatboxTextAdded

**Purpose**

Runs whenever chat.AddText successfully outputs text.

**Parameters**

* `...` (*any*): Arguments passed to `chat.AddText`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to respond when chat text is successfully added to the display.
-- The chat system processes messages and adds them to the chat display.
-- This hook is useful for logging, notifications, and playing sounds when messages are added.

-- Log when chat text is added
hook.Add("ChatboxTextAdded", "Notify", function(...)
    print("A chat message was added")
end)

-- Log chat messages with full content
hook.Add("ChatboxTextAdded", "LogChatMessages", function(...)
    local args = {...}
    local message = table.concat(args, " ")
    print("Chat message:", message)
end)

-- Play sound when chat text is added
hook.Add("ChatboxTextAdded", "PlayChatSound", function(...)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### GetMainMenuPosition

**Purpose**

Returns the camera position and angle for the main menu character preview. Provides the camera position and angle for the main menu model.

**Parameters**

* `character` (*Character*): Character being viewed.

**Returns**

* `Vector, Angle` (*Vector, Angle*): Position and angle values.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the camera position for the main menu character preview.
-- The main menu displays a 3D character model that players can view and customize.
-- This hook allows you to set custom camera positions and angles for the character preview.

-- Set custom camera position for main menu character view
hook.Add("GetMainMenuPosition", "OffsetCharView", function(character)
    return Vector(30, 10, 60), Angle(0, 30, 0)
end)

-- Set different camera positions based on character faction
hook.Add("GetMainMenuPosition", "DynamicCamera", function(character)
    if character:getFaction() == "police" then
        return Vector(40, 20, 70), Angle(0, 45, 0)
    end
    return Vector(30, 10, 60), Angle(0, 30, 0)
end)

-- Set close-up camera view for character preview
hook.Add("GetMainMenuPosition", "CloseUpView", function(character)
    return Vector(20, 5, 50), Angle(0, 20, 0)
end)
```

---

### CanDeleteChar

**Purpose**

Return false here to prevent character deletion. Determines if a character can be deleted.

**Parameters**

* `characterID` (*number*): Identifier of the character.

**Returns**

* `boolean` (*boolean*): False to disallow deletion, true or nil to allow.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control character deletion permissions.
-- Characters can be deleted by players through the character selection interface.
-- This hook allows you to implement custom restrictions based on character data or player permissions.

-- Protect the first character slot from deletion
hook.Add("CanDeleteChar", "ProtectSlot1", function(id)
    if id == 1 then
        return false
    end
end)

-- Restrict character deletion to admins only
hook.Add("CanDeleteChar", "AdminOnlyDeletion", function(id)
    if not LocalPlayer():IsAdmin() then
        return false
    end
end)

-- Protect high-level characters from deletion
hook.Add("CanDeleteChar", "ProtectHighLevelChars", function(id)
    local char = lia.char.getByID(id)
    if char and char:getLevel() > 50 then
        return false
    end
end)
```

---

### LoadMainMenuInformation

**Purpose**

Lets modules insert additional information on the main menu info panel. Allows modules to populate extra information on the main menu panel.

**Parameters**

* `info` (*table*): Table to receive information.
* `character` (*Character*): Selected character.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to add custom information to the main menu info panel.
-- The main menu displays character information and statistics.
-- This hook allows you to populate additional information about the selected character.

-- Add faction information to main menu
hook.Add("LoadMainMenuInformation", "AddFactionInfo", function(info, character)
    local fac = lia.faction.indices[character:getFaction()]
    local facName = fac and fac.name or "Citizen"
    info[#info + 1] = "Faction" .. ": " .. facName
end)

-- Add character level information to main menu
hook.Add("LoadMainMenuInformation", "AddLevelInfo", function(info, character)
    info[#info + 1] = "Level: " .. (character:getLevel() or 1)
end)

-- Add play time information to main menu
hook.Add("LoadMainMenuInformation", "AddPlayTimeInfo", function(info, character)
    local playTime = character:getData("playTime", 0)
    local hours = math.floor(playTime / 3600)
    info[#info + 1] = "Play Time: " .. hours .. " hours"
end)
```

---

### CanPlayerCreateChar

**Purpose**

Checks if a player may start creating a character. Determines if the player may create a new character.

**Parameters**

* `player` (*Player*): The player attempting to create a character.
* `data` (*table* | *nil*): Optional character data being created. Only supplied on the server.

**Returns**

* `boolean` (*boolean*): False to disallow creation, true or nil to allow.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to control character creation permissions.
-- Characters are created through the character selection interface.
-- This hook allows you to implement custom restrictions based on player data or permissions.

-- Restrict character creation to admins only
hook.Add("CanPlayerCreateChar", "AdminsOnly", function(ply)
    if not ply:IsAdmin() then
        return false
    end
end)

-- Limit character count per player
hook.Add("CanPlayerCreateChar", "LimitCharacterCount", function(ply)
    local charCount = #lia.char.getCharacters(ply)
    if charCount >= 3 then
        return false
    end
end)

-- Require minimum play time before character creation
hook.Add("CanPlayerCreateChar", "CheckPlayTime", function(ply)
    local playTime = ply:GetNWInt("totalPlayTime", 0)
    if playTime < 3600 then -- Less than 1 hour
        return false
    end
end)
```

---

### ModifyCharacterModel

**Purpose**

Lets you edit the clientside model used in the main menu. Allows adjustments to the character model in menus.

**Parameters**

* `entity` (*Entity*): Model entity.
* `character` (*Character* | *nil*): Character data if available.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the character model displayed in menus.
-- Character models are shown in various UI elements like the main menu and character selection.
-- This hook allows you to modify the model's appearance, add accessories, or change skins.

-- Apply bodygroup and skin modifications to character model
hook.Add("ModifyCharacterModel", "ApplyBodygroup", function(ent, character)
    ent:SetBodygroup(2, 1)
    if character then
        ent:SetSkin(character:getData("skin", 0))
    end
end)

-- Apply custom skin to character model
hook.Add("ModifyCharacterModel", "ApplyCustomSkin", function(ent, character)
    if character then
        local customSkin = character:getData("customSkin", 0)
        ent:SetSkin(customSkin)
    end
end)

-- Add accessories to character model
hook.Add("ModifyCharacterModel", "AddAccessories", function(ent, character)
    if character then
        local hat = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
        hat:SetParent(ent)
        hat:AddEffects(EF_BONEMERGE)
    end
end)
```

---

### ConfigureCharacterCreationSteps

**Purpose**

Add or reorder steps in the character creation flow. Lets modules alter the character creation step layout.

**Parameters**

* `panel` (*Panel*): Creation panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the character creation flow by adding or reordering steps.
-- Character creation involves multiple steps like appearance, background, and customization.
-- This hook allows you to add custom steps or reorder existing ones in the creation process.

-- Add a background step to character creation
hook.Add("ConfigureCharacterCreationSteps", "InsertBackground", function(panel)
    local step = vgui.Create("liaCharacterBackground")
    panel:addStep(step, 99)
end)

-- Add a custom step to character creation
hook.Add("ConfigureCharacterCreationSteps", "AddCustomStep", function(panel)
    local step = vgui.Create("liaCharacterCustom")
    panel:addStep(step, 50)
end)

-- Reorder existing character creation steps
hook.Add("ConfigureCharacterCreationSteps", "ReorderSteps", function(panel)
    -- Reorder existing steps
    panel:reorderStep("appearance", 1)
    panel:reorderStep("background", 2)
end)
```

---

### GetMaxPlayerChar

**Purpose**

Override to change how many characters a player can have. Returns the maximum number of characters a player can have.

**Parameters**

* `player` (*Player*): The player attempting to create a character.
* `data` (*table* | *nil*): Optional character data being created. Only supplied on the server.

**Returns**

* `number` (*number*): Maximum character count.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to control the maximum number of characters a player can have.
-- Character slots determine how many characters each player can create and maintain.
-- This hook allows you to implement dynamic character limits based on player data or permissions.

-- Give admins more character slots
hook.Add("GetMaxPlayerChar", "AdminSlots", function(ply)
    return ply:IsAdmin() and 10 or 5
end)

-- Give VIP players extra character slots
hook.Add("GetMaxPlayerChar", "VIPSlots", function(ply)
    if ply:GetNWBool("isVIP", false) then
        return 8
    end
    return 3
end)

-- Give character slots based on play time
hook.Add("GetMaxPlayerChar", "DynamicSlots", function(ply)
    local playTime = ply:GetNWInt("totalPlayTime", 0)
    local hours = playTime / 3600
    return math.min(10, math.floor(hours / 100) + 1)
end)
```

---

### ShouldMenuButtonShow

**Purpose**

Return false and a reason to hide buttons on the main menu. Determines if a button should be visible on the main menu.

**Parameters**

* `name` (*string*): Button identifier.

**Returns**

* `boolean, string` (*boolean, string*): False and reason to hide, true or nil to show.

**Realm**

**Client**

**Example Usage**

```lua
-- Hide delete button when feature is locked
hook.Add("ShouldMenuButtonShow", "HideDelete", function(name)
    if name == "delete" then
        return false, "Locked"
    end
end)

-- Hide admin buttons for non-admin players
hook.Add("ShouldMenuButtonShow", "AdminOnlyButtons", function(name)
    if name == "admin" and not LocalPlayer():IsAdmin() then
        return false, "Admin only"
    end
end)

-- Hide VIP buttons for non-VIP players
hook.Add("ShouldMenuButtonShow", "VIPOnlyButtons", function(name)
    if name == "vip" and not LocalPlayer():GetNWBool("isVIP", false) then
        return false, "VIP only"
    end
end)
```

---

### ResetCharacterPanel

**Purpose**

Called when the character creation panel should reset. Called to reset the character creation panel.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Log when character creation panel is reset
hook.Add("ResetCharacterPanel", "ClearFields", function()
    print("Character creator reset")
end)

-- Play sound when character panel is reset
hook.Add("ResetCharacterPanel", "PlayResetSound", function()
    surface.PlaySound("ui/buttonclick.wav")
end)

-- Animate the reset process
hook.Add("ResetCharacterPanel", "AnimateReset", function()
    -- Animate the reset process
end)
```

---

### TooltipLayout

**Purpose**

Customize tooltip sizing and layout before it appears.

**Parameters**

* `panel` (*Panel*): Tooltip panel being laid out.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Set fixed width for tooltips
hook.Add("TooltipLayout", "FixedWidth", function(panel)
    panel:SetWide(200)
end)

-- Set dynamic width based on text length
hook.Add("TooltipLayout", "DynamicSizing", function(panel)
    local text = panel:GetText()
    local width = math.min(300, text:len() * 8 + 20)
    panel:SetWide(width)
end)

-- Set custom height for tooltips
hook.Add("TooltipLayout", "CustomHeight", function(panel)
    panel:SetTall(100)
end)
```

---

### TooltipPaint

**Purpose**

Draw custom visuals on the tooltip, returning true skips default painting.

**Parameters**

* `panel` (*Panel*): Tooltip panel.
* `width` (*number*): Panel width.
* `height` (*number*): Panel height.

**Returns**

* `boolean` (*boolean*): Return true to skip default painting.

**Realm**

**Client**

**Example Usage**

```lua
-- Add dark background and skip default painting
hook.Add("TooltipPaint", "BlurBackground", function(panel, w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
    return true
end)

-- Add custom border to tooltips
hook.Add("TooltipPaint", "CustomBorder", function(panel, w, h)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawOutlinedRect(0, 0, w, h)
    return false
end)

-- Add gradient background to tooltips
hook.Add("TooltipPaint", "GradientBackground", function(panel, w, h)
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(100, 100, 100, 100)
    surface.DrawRect(0, 0, w, h/2)
    return true
end)
```

---

### TooltipInitialize

**Purpose**

Runs when a tooltip is opened for a panel.

**Parameters**

* `panel` (*Panel*): Tooltip panel.
* `target` (*Panel*): Target panel that opened the tooltip.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Fade in tooltips when they are created
hook.Add("TooltipInitialize", "SetupFade", function(panel, target)
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.2, 0)
end)

-- Set custom positioning for tooltips
hook.Add("TooltipInitialize", "CustomPositioning", function(panel, target)
    local x, y = target:GetPos()
    panel:SetPos(x + target:GetWide() + 10, y)
end)

-- Play sound when tooltip is created
hook.Add("TooltipInitialize", "PlayTooltipSound", function(panel, target)
    surface.PlaySound("ui/buttonclick.wav")
end)
```

---

### PostPlayerSay

**Purpose**

Runs after chat messages are processed. Allows reacting to player chat.

**Parameters**

* `client` (*Player*): Speaking player.
* `message` (*string*): Chat text.
* `chatType` (*string*): Chat channel.
* `anonymous` (*boolean*): Whether the message was anonymous.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log all OOC chat messages
hook.Add("PostPlayerSay", "LogOOC", function(ply, msg, chatType)
    if chatType == "ooc" then
        print("[OOC]", ply:Nick(), msg)
    end
end)

-- Log all chat messages with type
hook.Add("PostPlayerSay", "LogAllChat", function(ply, msg, chatType)
    print("[CHAT]", ply:Nick(), "(" .. chatType .. "):", msg)
end)

-- Update player's last chat time
hook.Add("PostPlayerSay", "UpdatePlayerActivity", function(ply, msg, chatType)
    ply:SetNWInt("lastChatTime", CurTime())
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
-- Process parsed chat message
hook.Add("ChatParsed", "ProcessChat", function(speaker, text, chatType)
    -- Process parsed chat message
end)

-- Log parsed chat messages
hook.Add("ChatParsed", "LogParsedChat", function(speaker, text, chatType)
    print("Parsed chat:", speaker:Nick(), "(" .. chatType .. "):", text)
end)

-- Filter profanity in chat messages
hook.Add("ChatParsed", "FilterProfanity", function(speaker, text, chatType)
    -- Filter profanity in chat
    local filteredText = text:gsub("badword", "****")
    if filteredText ~= text then
        speaker:ChatPrint("Your message was filtered.")
    end
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
-- Log all player messages
hook.Add("PlayerMessageSend", "LogMessages", function(client, chatType, message)
    print(client:Nick(), "sent", chatType, ":", message)
end)

-- Rate limit chat messages
hook.Add("PlayerMessageSend", "RateLimitChat", function(client, chatType, message)
    local lastMessage = client:GetNWFloat("lastMessageTime", 0)
    if CurTime() - lastMessage < 1 then
        client:ChatPrint("Please wait before sending another message.")
        return false
    end
    client:SetNWFloat("lastMessageTime", CurTime())
end)

-- Check message length
hook.Add("PlayerMessageSend", "CheckMessageLength", function(client, chatType, message)
    if #message > 200 then
        client:ChatPrint("Message too long. Maximum 200 characters.")
        return false
    end
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
-- Process received chat message
hook.Add("OnChatReceived", "ProcessReceived", function(speaker, text, chatType)
    -- Process received chat message
end)

-- Log received chat messages
hook.Add("OnChatReceived", "LogReceivedChat", function(speaker, text, chatType)
    print("Received chat from", speaker:Nick(), "(" .. chatType .. "):", text)
end)

-- Play sound for specific chat types
hook.Add("OnChatReceived", "PlayChatSound", function(speaker, text, chatType)
    if chatType == "ooc" then
        surface.PlaySound("ui/buttonclick.wav")
    end
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
-- Give admins no OOC delay, others 30 seconds
hook.Add("getOOCDelay", "CustomDelay", function(client)
    return client:IsAdmin() and 0 or 30
end)

-- Give VIP players shorter OOC delay
hook.Add("getOOCDelay", "VIPDelay", function(client)
    if client:GetNWBool("isVIP", false) then
        return 5
    end
    return 15
end)

-- Reduce OOC delay based on play time
hook.Add("getOOCDelay", "DynamicDelay", function(client)
    local playTime = client:GetNWInt("totalPlayTime", 0)
    local hours = playTime / 3600
    return math.max(5, 30 - hours)
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
-- Log OOC messages to console
hook.Add("OnOOCMessageSent", "OOCMsgLog", function(client, text)
    print("OOC message from", client:Nick(), ":", text)
end)

-- Log OOC messages to file
hook.Add("OnOOCMessageSent", "LogOOCToFile", function(client, text)
    local logFile = "ooc_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. client:Nick() .. ": " .. text .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify admins of OOC messages
hook.Add("OnOOCMessageSent", "NotifyAdmins", function(client, text)
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("[OOC] " .. client:Nick() .. ": " .. text)
        end
    end
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
-- Log voice chat state changes
hook.Add("VoiceToggled", "VoiceLog", function(client, state)
    print(client:Nick(), state and "enabled" or "disabled", "voice chat")
end)

-- Notify player of voice chat state change
hook.Add("VoiceToggled", "NotifyVoiceChange", function(client, state)
    if state then
        client:ChatPrint("Voice chat enabled")
    else
        client:ChatPrint("Voice chat disabled")
    end
end)

-- Update player's voice status for UI elements
hook.Add("VoiceToggled", "UpdateVoiceStatus", function(client, state)
    client:SetNWBool("isVoiceEnabled", state)
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
-- Log warnings to console
hook.Add("WarningIssued", "WarningLog", function(target, issuer, reason)
    print("Warning issued to", target:Nick(), "by", issuer:Nick(), ":", reason)
end)

-- Log warnings to file
hook.Add("WarningIssued", "LogWarningToFile", function(target, issuer, reason)
    local logFile = "warnings_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. target:Nick() .. " warned by " .. issuer:Nick() .. ": " .. reason .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify all admins of warnings
hook.Add("WarningIssued", "NotifyAdmins", function(target, issuer, reason)
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("[WARNING] " .. target:Nick() .. " warned by " .. issuer:Nick() .. ": " .. reason)
        end
    end
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
-- Log warning removals to console
hook.Add("WarningRemoved", "RemoveLog", function(target, remover)
    print("Warning removed from", target:Nick(), "by", remover:Nick())
end)

-- Log warning removals to file
hook.Add("WarningRemoved", "LogRemovalToFile", function(target, remover)
    local logFile = "warnings_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " Warning removed from " .. target:Nick() .. " by " .. remover:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify target player of warning removal
hook.Add("WarningRemoved", "NotifyTarget", function(target, remover)
    target:ChatPrint("Your warning has been removed by " .. remover:Nick())
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
-- Log gags to console
hook.Add("PlayerGagged", "GagLog", function(target, gagger)
    print(target:Nick(), "was gagged by", gagger:Nick())
end)

-- Log gags to file
hook.Add("PlayerGagged", "LogGagToFile", function(target, gagger)
    local logFile = "gags_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. target:Nick() .. " gagged by " .. gagger:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify target player of gag
hook.Add("PlayerGagged", "NotifyTarget", function(target, gagger)
    target:ChatPrint("You have been gagged by " .. gagger:Nick())
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
-- Log ungags to console
hook.Add("PlayerUngagged", "UngagLog", function(target, ungagger)
    print(target:Nick(), "was ungagged by", ungagger:Nick())
end)

-- Log ungags to file
hook.Add("PlayerUngagged", "LogUngagToFile", function(target, ungagger)
    local logFile = "gags_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. target:Nick() .. " ungagged by " .. ungagger:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify target player of ungag
hook.Add("PlayerUngagged", "NotifyTarget", function(target, ungagger)
    target:ChatPrint("You have been ungagged by " .. ungagger:Nick())
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
-- Log mutes to console
hook.Add("PlayerMuted", "MuteLog", function(target, muter)
    print(target:Nick(), "was muted by", muter:Nick())
end)

-- Log mutes to file
hook.Add("PlayerMuted", "LogMuteToFile", function(target, muter)
    local logFile = "mutes_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. target:Nick() .. " muted by " .. muter:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify target player of mute
hook.Add("PlayerMuted", "NotifyTarget", function(target, muter)
    target:ChatPrint("You have been muted by " .. muter:Nick())
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
-- Log unmutes to console
hook.Add("PlayerUnmuted", "UnmuteLog", function(target, unmuter)
    print(target:Nick(), "was unmuted by", unmuter:Nick())
end)

-- Log unmutes to file
hook.Add("PlayerUnmuted", "LogUnmuteToFile", function(target, unmuter)
    local logFile = "mutes_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. target:Nick() .. " unmuted by " .. unmuter:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify target player of unmute
hook.Add("PlayerUnmuted", "NotifyTarget", function(target, unmuter)
    target:ChatPrint("You have been unmuted by " .. unmuter:Nick())
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
-- Log ticket creation to console
hook.Add("TicketSystemCreated", "TicketLog", function(ticket)
    print("Ticket created:", ticket.id)
end)

-- Log ticket creation to file
hook.Add("TicketSystemCreated", "LogTicketToFile", function(ticket)
    local logFile = "tickets_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " Ticket #" .. ticket.id .. " created by " .. ticket.creator .. ": " .. ticket.message .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify admins of new tickets
hook.Add("TicketSystemCreated", "NotifyAdmins", function(ticket)
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("[TICKET] New ticket #" .. ticket.id .. " from " .. ticket.creator)
        end
    end
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
-- Log ticket claims to console
hook.Add("TicketSystemClaim", "ClaimLog", function(ticket, claimer)
    print("Ticket", ticket.id, "claimed by", claimer:Nick())
end)

-- Log ticket claims to file
hook.Add("TicketSystemClaim", "LogClaimToFile", function(ticket, claimer)
    local logFile = "tickets_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " Ticket #" .. ticket.id .. " claimed by " .. claimer:Nick() .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify ticket creator of claim
hook.Add("TicketSystemClaim", "NotifyCreator", function(ticket, claimer)
    local creator = player.GetBySteamID(ticket.creator)
    if IsValid(creator) then
        creator:ChatPrint("Your ticket #" .. ticket.id .. " has been claimed by " .. claimer:Nick())
    end
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
-- Log ticket closures to console
hook.Add("TicketSystemClose", "CloseLog", function(ticket)
    print("Ticket", ticket.id, "closed")
end)

-- Log ticket closures to file
hook.Add("TicketSystemClose", "LogCloseToFile", function(ticket)
    local logFile = "tickets_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " Ticket #" .. ticket.id .. " closed by " .. (ticket.closer or "System") .. "\n"
    file.Append(logFile, logEntry)
end)

-- Notify ticket creator of closure
hook.Add("TicketSystemClose", "NotifyCreator", function(ticket)
    local creator = player.GetBySteamID(ticket.creator)
    if IsValid(creator) then
        creator:ChatPrint("Your ticket #" .. ticket.id .. " has been closed")
    end
end)
```

---

### liaCommandAdded

**Purpose**

Fires when a new command is registered.

**Parameters**

* `command` (*table*): The command that was added.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log command additions to console
hook.Add("liaCommandAdded", "CommandLog", function(command)
    print("Command added:", command.name)
end)

-- Log command additions to file
hook.Add("liaCommandAdded", "LogCommandToFile", function(command)
    local logFile = "commands_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " Command added: " .. command.name .. "\n"
    file.Append(logFile, logEntry)
end)

-- Validate command data
hook.Add("liaCommandAdded", "ValidateCommand", function(command)
    if not command.name or command.name == "" then
        print("Warning: Command added without a name")
    end
end)
```

---

### liaCommandRan

**Purpose**

Called when a command is executed.

**Parameters**

* `client` (*Player*): Player who ran the command.
* `command` (*table*): Command that was run.
* `arguments` (*table*): Arguments passed to the command.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log command usage to console
hook.Add("liaCommandRan", "CommandUsageLog", function(client, command, arguments)
    print(client:Nick(), "ran command:", command.name)
end)

-- Log command usage to file
hook.Add("liaCommandRan", "LogCommandUsageToFile", function(client, command, arguments)
    local logFile = "command_usage_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " " .. client:Nick() .. " ran command: " .. command.name .. " with args: " .. table.concat(arguments, " ") .. "\n"
    file.Append(logFile, logEntry)
end)

-- Track command usage statistics
hook.Add("liaCommandRan", "TrackCommandStats", function(client, command, arguments)
    local stats = client:GetNWTable("commandStats", {})
    stats[command.name] = (stats[command.name] or 0) + 1
    client:SetNWTable("commandStats", stats)
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
-- Process server logs with custom logic
hook.Add("OnServerLog", "CustomLogging", function(message, category)
    -- Custom log processing
end)

-- Log server messages to file
hook.Add("OnServerLog", "LogToFile", function(message, category)
    local logFile = "server_log.txt"
    local logEntry = os.date("[%Y-%m-%d %H:%M:%S]") .. " [" .. category .. "] " .. message .. "\n"
    file.Append(logFile, logEntry)
end)

-- Filter logs based on category and settings
hook.Add("OnServerLog", "FilterLogs", function(message, category)
    if category == "debug" and not GetConVar("developer"):GetBool() then
        return -- Skip debug logs in non-developer mode
    end
end)
```

