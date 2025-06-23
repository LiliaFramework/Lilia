---

These hooks are regular hooks that can be used in your schema with SCHEMA:HookName(args), in your module with  
MODULE:HookName(args), or in your addon with hook.Add("HookName", function(args) end).

Below is a comprehensive list of available hooks and their purposes. Internal hooks are meant for internal usage by Lilia; you should only override them if you are absolutely certain you understand the implications.

---

### **CreateDefaultInventory**
**Description:**  
Called when creating a default inventory for a character. Should return a [deferred](https://github.com/Be1zebub/luassert-deferred) (or similar promise) object that resolves with the new inventory.
    
**Realm:** 
`Server`

**Example Usage:**
```lua
hook.Add("CreateDefaultInventory", "InitializeStarterInventory", function(character)
    local d = deferred.new()

    someInventoryCreationFunction(character)
        :next(function(inventory)
            -- Add starter items
            inventory:addItem("health_potion")
            inventory:addItem("basic_sword")
            d:resolve(inventory)
        end, function(err)
            print("Failed to create inventory:", err)
            d:reject(err)
        end)

    return d
end)
```
    
---
### **CharRestored**
**Description:**  
Called after a character has been restored from the database. Useful for post-restoration logic such as awarding default items or setting up data.
    
**Realm:** 
`Server`

**Example Usage:**
```lua
hook.Add("CharRestored", "AwardWelcomePackage", function(character)
    local welcomePackage = {"welcome_pack", "starter_weapon", "basic_armor"}
    for _, itemID in ipairs(welcomePackage) do
        character:getInv():addItem(itemID)
    end
    print("Welcome package awarded to:", character:getName())
end)
```
    
---
### **PreCharDelete**
**Description:**  
Called before a character is deleted. Allows for clean-up tasks or checks before removal from DB.
    
**Realm:** 
`Server`
    
**Parameters:**
- `id` (`number`): The ID of the character to be deleted.

**Example Usage:**
```lua
hook.Add("PreCharDelete", "BackupCharacterData", function(id)
    local character = lia.character.getByID(id)
    if character then
        lia.backup.saveCharacterData(character)
        print("Character data backed up for ID:", id)
    end
end)
```
    
---
### **OnCharDelete**
**Description:**  
Called after a character is deleted. Finalize any remaining actions or remove associated data.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`): The player who triggered the deletion.
- `id` (`number`): The ID of the deleted character.

**Example Usage:**
```lua
hook.Add("OnCharDelete", "NotifyDeletion", function(client, id)
    print(client:Name() .. " has deleted character ID:", id)
    -- Notify other systems or perform cleanup
    lia.notifications.sendAll("Character #" .. id .. " has been deleted by " .. client:Name())
end)
```
    
---
### **OnCharVarChanged**
**Description:**  
Called when a character variable changes (server-side). Useful for responding to data updates.
    
**Realm:** 
`Server`
    
**Parameters:**
- `character` (Character): The character object.
- `key` (`string`): The name of the variable.
- `oldValue` (`any`): The old value.
- `newValue` (`any`): The new value.

**Example Usage:**
```lua
hook.Add("OnCharVarChanged", "LogAttributeChanges", function(character, key, oldValue, newValue)
    print("Character " .. character:getName() .. " had " .. key .. " changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
    -- Additional logic, such as triggering events based on specific changes
    if key == "health" and newValue < 50 then
        lia.events.trigger("LowHealthWarning", character)
    end
end)
```
    
---
### **PlayerModelChanged**
**Description:**  
Called when a player's model changes.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`): The player whose model changed.
- `model` (`string`): The new model path.

**Example Usage:**
```lua
hook.Add("PlayerModelChanged", "UpdatePlayerAppearance", function(client, model)
    print(client:Name() .. " changed their model to " .. model)
    -- Update related appearance settings
    client:setBodygroup(1, 2) -- Example of setting a bodygroup based on the new model
end)
```
    
---
### **GetDefaultCharName**
**Description:**  
Retrieves a default name for a character during creation. Return `(defaultName, overrideBool)`.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`): The player creating the character.
- `faction` (`number`): The faction index.
- `data` (`table`): Additional creation data.
    
**Returns:**
- `string`: The default name.
- `bool`: Whether to override the user-provided name.

**Example Usage:**
```lua
hook.Add("GetDefaultCharName", "PoliceDefaultName", function(client, faction, data)
    if faction == FACTION_POLICE then
        return "Officer " .. data.lastName or "Smith", true
    end
end)
```
    
---
### **GetDefaultCharDesc**
**Description:**  
Retrieves a default description for a character during creation. Return `(defaultDesc, overrideBool)`.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `faction` (`number`)
    
**Returns:**
- `string`: The default description.
- `bool`: Whether to override.

**Example Usage:**
```lua
hook.Add("GetDefaultCharDesc", "CitizenDefaultDesc", function(client, faction)
    if faction == FACTION_CITIZEN then
        return "A hardworking member of society.", true
    end
end)
```
    
---
### **ShouldHideBars**
**Description:**  
Determines whether all HUD bars should be hidden.
    
**Realm:** 
`Client`
    
**Returns:**
- `bool|nil`: `true` to hide, `nil` to allow rendering.

**Example Usage:**
```lua
hook.Add("ShouldHideBars", "HideHUDInCinematic", function()
    if gui.IsInCinematicMode() then
        return true
    end
end)
```
    
---
### **ShouldBarDraw**
**Description:**  
Determines whether a specific HUD bar should be drawn.
    
**Realm:** 
`Client`
    
**Parameters:**
- `barName` (`string`): e.g. `"health"`, `"armor"`.
    
**Returns:**
- `bool|nil`: `false` to hide, `nil` to allow.

**Example Usage:**
```lua
hook.Add("ShouldBarDraw", "HideArmorHUD", function(barName)
    if barName == "armor" then
        return false
    end
end)
```
    
---
### **InitializedChatClasses**
**Description:**  
Called once all chat classes have been initialized.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("InitializedChatClasses", "RegisterGlobalOOC", function()
    lia.chat.register("globalOOC", {
        prefix = {"/gooc"},
        format = "[GLOBAL OOC] %s: \"%s\"",
        onCanHear = function(speaker, listener)
            return listener:isAdmin() -- Only admins can hear global OOC
        end
    })
end)
```
    
---
### **PlayerMessageSend**
**Description:**  
Called before a chat message is sent. Return `false` to cancel, or modify the message if returning a string.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `speaker` (`Player`)
- `chatType` (`string`)
- `message` (`string`)
- `anonymous` (`bool`)
    
**Returns:**
- `bool|nil|modifiedString`: `false` to cancel, or return a modified string to change the message.

**Example Usage:**
```lua
hook.Add("PlayerMessageSend", "FilterProfanity", function(speaker, chatType, message, anonymous)
    local filteredMessage = string.gsub(message, "badword", "****")
    if filteredMessage ~= message then
        return filteredMessage
    end
end)
```
---
### **CanPlayerJoinClass**
**Description:**  
Determines whether a player can join a certain class. Return `false` to block.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `class` (`number`)
- `info` (`table`)
    
**Returns:**  
- `bool|nil`: `false` to block, `nil` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerJoinClass", "RestrictEliteClass", function(client, class, info)
    if class == CLASS_ELITE and not client:hasPermission("join_elite") then
        return false
    end
end)
```
    
---
### **InitializedClasses**
**Description:**  
Called after all classes have been initialized.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("InitializedClasses", "AddCustomClass", function()
    local CLASS = {}
    CLASS.name = "Medic"
    CLASS.faction = FACTION_HEALTHCARE
    CLASS.isDefault = false
    CLASS.index = #lia.class.list + 1
    lia.class.list[CLASS.index] = CLASS
    print("Custom class 'Medic' added.")
end)
```
    
---
### **CanPlayerUseCommand**
**Description:**  
Determines if a player can use a specific command. Return `false` to block usage.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `command` (`string`)
    
**Returns:**  
- `bool|nil`: `false` to block, `nil` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerUseCommand", "BlockSensitiveCommands", function(client, command)
    local blockedCommands = {"shutdown", "restart"}
    if table.HasValue(blockedCommands, command) and not client:isSuperAdmin() then
        return false
    end
end)
```
    
---
### **ShouldDataBeSaved**
**Description:**  
Determines whether data should be saved during server shutdown.
    
**Realm:** 
`Server`
    
**Returns:**  
- `bool`: `true` to save, `false` to skip.

**Example Usage:**
```lua
hook.Add("ShouldDataBeSaved", "ConditionalDataSave", function()
    if not lia.config.enableDataPersistence then
        return false
    end
end)
```
    
---
### **PostLoadData**
**Description:**  
Called after all data has been loaded.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("PostLoadData", "InitializePlayerStats", function()
    for _, ply in player.Iterator() do
        local stats = lia.data.get("player_" .. ply:getChar():getID(), {kills = 0, deaths = 0})
        ply:setKills(stats.kills)
        ply:setDeaths(stats.deaths)
        print("Initialized stats for:", ply:Name())
    end
end)
```
    
---
### **SaveData**
**Description:**  
Saves all relevant data to disk, triggered during map cleanup and shutdown.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("SaveData", "PersistPlayerData", function()
    for _, ply in player.Iterator() do
        local char = ply:getChar()
        if char then
            lia.data.set("player_" .. char:getID(), char:getData(), false, false)
            print("Saved data for:", char:getName())
        end
    end
end)
```
    
---
### **LoadData**
**Description:**  
Loads all relevant data from disk, typically after map cleanup.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("LoadData", "LoadPlayerData", function()
    for key, _ in pairs(lia.data.stored) do
        if string.StartWith(key, "player_") then
            local data = lia.data.get(key, {})
            local playerID = string.sub(key, 8) -- Remove 'player_' prefix
            local ply = player.GetBySteamID(playerID)
            if ply then
                ply:setKills(data.kills or 0)
                ply:setDeaths(data.deaths or 0)
                print("Loaded data for:", ply:Name())
            end
        end
    end
end)
```
    
---
### **OnMySQLOOConnected**
**Description:**  
Called when MySQLOO successfully connects to the database. Use to register prepared statements or init DB logic.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("OnMySQLOOConnected", "PrepareDatabaseStatements", function()
    lia.db.prepare("insertPlayer", "INSERT INTO lia_players (_steamID, _steamName) VALUES (?, ?)", {MYSQLOO_STRING, MYSQLOO_STRING})
    lia.db.prepare("updatePlayerStats", "UPDATE lia_players SET kills = ?, deaths = ? WHERE _steamID = ?", {MYSQLOO_NUMBER, MYSQLOO_NUMBER, MYSQLOO_STRING})
    print("Prepared MySQLOO statements.")
end)
```
    
---
### **LiliaTablesLoaded**
**Description:**  
Called after all essential DB tables have been loaded.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("LiliaTablesLoaded", "InitializeGameState", function()
    lia.gameState = lia.gameState or {}
    lia.gameState.activeEvents = {}
    print("All essential Lilia tables have been loaded. Game state initialized.")
end)
```
    
---
### **OnLoadTables**
**Description:**  
Called before the faction tables are loaded. Good spot for data setup prior to factions being processed.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("OnLoadTables", "SetupFactionDefaults", function()
    lia.factions = lia.factions or {}
    lia.factions.defaultPermissions = {canUseWeapons = true, canAccessBank = false}
    print("Faction defaults have been set up.")
end)
```
    
---
### **PersistenceSave**
**Description:**  
Called to save persistent data (like map entities), often during map cleanup or shutdown.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("PersistenceSave", "SaveMapEntities", function()
    for _, ent in ents.Iterator() do
        if ent:isPersistent() then
            lia.data.set("entity_" .. ent:EntIndex(), ent:getData(), true)
            print("Saved entity data for:", ent:GetClass())
        end
    end
end)
```
    
---
### **RegisterPreparedStatements**
**Description:**  
Called for registering DB prepared statements post-MySQLOO connection.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("RegisterPreparedStatements", "RegisterAllStatements", function()
    lia.db.prepare("deletePlayer", "DELETE FROM lia_players WHERE _steamID = ?", {MYSQLOO_STRING})
    lia.db.prepare("getPlayerData", "SELECT * FROM lia_players WHERE _steamID = ?", {MYSQLOO_STRING})
    print("All prepared statements have been registered.")
end)
```
    
---
### **CharCleanUp**
**Description:**  
Used during character cleanup routines for additional steps when removing or transitioning a character.
    
**Realm:** 
`Server`
    
**Parameters:**
- `character`: The character being cleaned up.

**Example Usage:**
```lua
hook.Add("CharCleanUp", "RemoveTemporaryItems", function(character)
    local inventory = character:getInv()
    for _, item in ipairs(inventory:getItems()) do
        if item:isTemporary() then
            inventory:removeItem(item.id)
            print("Removed temporary item:", item.name)
        end
    end
end)
```
    
---
### **CreateInventoryPanel**
**Description:**  
Client-side call when creating the graphical representation of an inventory.
    
**Realm:** 
`Client`
    
**Parameters:**  
- `inventory`
- `parent` (`Panel`)
    
**Returns:**  
`Panel|nil` — A custom panel or nil for default logic.
    
**Example Usage:**
```lua
hook.Add("CreateInventoryPanel", "CustomInventoryUI", function(inventory, parent)
    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(400, 600)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 200))
    end

    local itemList = vgui.Create("DScrollPanel", panel)
    itemList:Dock(FILL)

    for _, item in ipairs(inventory:getItems()) do
        local itemPanel = vgui.Create("DButton", itemList)
        itemPanel:SetText(item.name)
        itemPanel:Dock(TOP)
        itemPanel:SetTall(40)
        itemPanel.DoClick = function()
            print("Selected item:", item.name)
        end
    end

    return panel
end)
```
    
---
### **OnItemRegistered**
**Description:**  
Called after an item has been registered. Useful for customizing item behavior or adding properties.
    
**Realm:** 
`Shared`
    
**Parameters:**  
- `item` (Item)
    
**Example Usage:**
```lua
hook.Add("OnItemRegistered", "AddItemDurability", function(item)
    if item.uniqueID == "sword_basic" then
        item.durability = 100
        item.onUse = function(self)
            self.durability = self.durability - 10
            if self.durability <= 0 then
                self:destroy()
                print("Your sword has broken!")
            end
        end
        print("Durability added to:", item.name)
    end
end)
```
    
---
### **InitializedItems**
**Description:**  
Called once all item modules have been loaded from a directory.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("InitializedItems", "SetupSpecialItems", function()
    local specialItem = lia.item.create({
        uniqueID = "magic_ring",
        name = "Magic Ring",
        description = "A ring imbued with magical properties.",
        onUse = function(self, player)
            player:grantAbility("invisibility")
            print(player:Name() .. " has activated the Magic Ring!")
        end
    })
    print("Special items have been set up.")
end)
```
    
---
### **OnServerLog**
**Description:**  
Called whenever a new log message is added. Allows for custom logic or modifications to log handling.
    
**Realm:** 
`Server`
    
**Parameters:**  
- `client` (`Player`)
- `logType` (`string`)
- `logString` (`string`)
- `category` (`string`)
- `color` (`Color`)
    
**Example Usage:**
```lua
hook.Add("OnServerLog", "AlertAdminsOnHighSeverity", function(client, logType, logString, category, color)
    if category == "error" then
    for _, admin in player.Iterator() do
            if admin:isAdmin() then
                lia.notifications.send(admin, "Error Log: " .. logString, color)
            end
        end
    end
end)
```
    
---
### **DoModuleIncludes**
**Description:**  
Called when modules include submodules. Useful for advanced module handling or dependency management.
    
**Realm:** 
`Shared`
    
**Parameters:**  
- `path` (`string`)
- `module` (`table`)
    
**Example Usage:**
```lua
hook.Add("DoModuleIncludes", "TrackModuleDependencies", function(path, module)
    print("Including submodule from path:", path)
    module.dependencies = module.dependencies or {}
    table.insert(module.dependencies, "base_module")
end)
```
    
---
### **OnFinishLoad**
**Description:**  
Called after a module finishes loading. Ideal for final logic once all module files are processed.
    
**Realm:** 
`Shared`
    
**Parameters:**  
- `path` (`string`): The file path.
- `firstLoad` (`bool`): Whether this is the first load of the module.
    
**Example Usage:**
```lua
hook.Add("OnFinishLoad", "ModuleLoadNotifier", function(path, firstLoad)
    if firstLoad then
        print("Module loaded for the first time from:", path)
    else
        print("Module reloaded from:", path)
    end
end)
```
    
---
### **InitializedSchema**
**Description:**  
Called after the schema has finished initializing.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("InitializedSchema", "SchemaReadyNotification", function()
    print("Schema has been successfully initialized.")
    lia.notifications.broadcast("Welcome to the server! The schema is now active.")
end)
```
    
---
### **InitializedModules**
**Description:**  
Called after all modules are fully initialized.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
hook.Add("InitializedModules", "FinalizeModuleSetup", function()
    lia.modules.finalizeSetup()
    print("All modules have been fully initialized.")
end)
```
    
---
### **OnPickupMoney**
**Description:**  
Called when a player picks up money from the ground.
    
**Realm:** 
`Server`
    
**Parameters:**  
- `client` (`Player`)
- `moneyEntity` (`Entity`)
    
**Example Usage:**
```lua
function MODULE:OnPickupMoney(client, moneyEntity)
    local amount = moneyEntity:getAmount()
    client:addMoney(amount)
    print(client:Name() .. " picked up $" .. amount)
    moneyEntity:Remove() -- Remove the money entity from the ground
end
```
    
---
### **OnItemSpawned**
**Description:**  
Called whenever an item entity spawns in the world. Use `entity:getItemTable()` to access item data.
    
**Realm:** 
`Server`
    
**Parameters:**
- `entity` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("OnItemSpawned", "LogItemSpawns", function(entity)
    local item = entity:getItemTable()
    if item then
        print("Item spawned:", item.name, "at position", entity:GetPos())
    else
        print("An unknown item has spawned.")
    end
end)
```
    
---
### **LoadFonts**
**Description:**  
Loads custom fonts for the client.
    
**Realm:** 
`Client`
    
**Parameters:**
- `font` (`string`)
- `genericFont` (`string`)
    
**Example Usage:**
```lua
function MODULE:LoadFonts(font, genericFont)
    surface.CreateFont("CustomHUDFont", {
        font = font or "Arial",
        size = 20,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("NotificationFont", {
        font = genericFont or "Tahoma",
        size = 18,
        weight = 500,
        italic = true
    })
    print("Custom fonts loaded.")
end
```

### **LoadLiliaFonts**
    
**Description:**  
Used internally to load core fonts. Override only if you understand the implications.
    
**Realm:** 
`Client`
    
**Parameters:**
- `font` (`string`)
- `genericFont` (`string`)
    
**Example Usage:**
```lua
function MODULE:LoadLiliaFonts(font, genericFont)
    surface.CreateFont("LiliaDefault", {
        font = font or "Verdana",
        size = 16,
        weight = 600
    })
    print("Lilia core fonts have been loaded.")
end
```
    
---
### **InitializedConfig**
**Description:**  
Called when `lia.config` is fully initialized.
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
function MODULE:InitializedConfig()
    if lia.config.enableSpecialFeatures then
        lia.features.enable()
        print("Special features have been enabled.")
    else
        print("Special features are disabled in the config.")
    end
end
```
    
---
### **InitializedOptions**
**Description:**  
Called when `lia.option` is fully initialized.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
function MODULE:InitializedOptions()
   LocalPlayer():ChatPrint("LOADED OPTIONS!")
end
```
    
---

### **ModuleLoaded**
**Description:**  
Called when a module has finished loading (post-load logic).
    
**Realm:** 
`Shared`
    
**Example Usage:**
```lua
function MODULE:ModuleLoaded()
    print("Module '" .. self.name .. "' has been loaded successfully.")
    -- Perform additional setup or initialization if necessary
end
```
    
---
### **DatabaseConnected**
**Description:**  
Indicates successful MySQLOO DB connection. Used internally.
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
-- Internal usage; generally not overridden by modules
function MODULE:DatabaseConnected()
    print("Database connection established.")
    -- Internal initialization tasks
end
```
    
---
### **OnWipeTables**
**Description:**  
Called after wiping tables in the DB, typically after major resets/cleanups.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
hook.Add("OnWipeTables", "ReinitializeDefaults", function()
    lia.db.execute("INSERT INTO lia_factions (name, description) VALUES ('Citizen', 'Regular inhabitants.')")
    lia.db.execute("INSERT INTO lia_classes (name, faction) VALUES ('Warrior', 'Citizen')")
    print("Database tables wiped and defaults reinitialized.")
end)
```
    
---
### **SetupDatabase**
**Description:**  
Used internally by Lilia to set up the database.
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Realm:** 
`Server`
    
**Example Usage:**
```lua
-- Internal usage; generally not overridden by modules
function MODULE:SetupDatabase()
    lia.db.execute("CREATE TABLE IF NOT EXISTS lia_players (id INT AUTO_INCREMENT, _steamID VARCHAR(32), _steamName VARCHAR(64), PRIMARY KEY(id))")
    lia.db.execute("CREATE TABLE IF NOT EXISTS lia_factions (id INT AUTO_INCREMENT, name VARCHAR(32), description TEXT, PRIMARY KEY(id))")
    print("Database tables have been set up.")
end
```
    
---
### **CanPlayerUnequipItem**
**Description:**  
Determines whether a player can unequip a given item.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (`table` or custom item object`)
    
**Returns:**  
- `bool`: `true` if allowed, `false` if blocked.
    
**Example Usage:**
```lua
function MODULE:CanPlayerUnequipItem(client, item)
    if item.uniqueID == "quest_item" then
        return false -- Prevent unequipping quest-related items
    end
    return true
end
```
    
---
### **CanPlayerDropItem**
**Description:**  
Determines if a player is allowed to drop a specific item.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (`int` or `table`)
    
**Returns:**  
- `bool`: `true` to allow, `false` to block.
    
**Example Usage:**
```lua
function MODULE:CanPlayerDropItem(client, item)
    if item.uniqueID == "rare_artifact" and not client:isAdmin() then
        return false -- Only admins can drop rare artifacts
    end
    return true
end
```
    
---
### **CanPlayerTakeItem**
**Description:**  
Determines if a player can pick up an item into their inventory.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (`Entity` or `table`)
    
**Returns:**  
- `bool`: `true` if allowed, `false` otherwise.
    
**Example Usage:**
```lua
function MODULE:CanPlayerTakeItem(client, item)
    if item:isBoundToPlayer() and item:getOwner() ~= client then
        return false -- Prevent picking up items bound to other players
    end
    return true
end
```
    
---
### **CanPlayerEquipItem**
**Description:**  
Determines if a player can equip a given item (e.g., outfits, weapons).
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (`table`)
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
function MODULE:CanPlayerEquipItem(client, item)
    if item.category == "Weapon" and not client:hasLicense("weapon") then
        return false -- Require a license to equip weapons
    end
    return true
end
```
    
---
### **CanPlayerInteractItem**
**Description:**  
Determines if a player can interact with an item (pick up, drop, transfer, etc.). Called after other checks.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `action` (`string`): e.g. `"drop"`, `"pickup"`, `"transfer"`
- `item` (`int` or `table`)
    
**Returns:**  
- `bool`: `true` if allowed, `false` otherwise.
    
**Example Usage:**
```lua
function MODULE:CanPlayerInteractItem(client, action, item)
    if action == "transfer" and item:isBoundToFaction("Police") and not client:isPolice() then
        return false -- Only police can transfer faction-bound items
    end
    return true
end
```
    
---
### **EntityRemoved**
**Description:**  
Called when an entity is removed. Often used for cleaning up net variables.
    
**Realm:** 
`Server`
    
**Parameters:**  
- `entity` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("EntityRemoved", "CleanupEntityData", function(entity)
    if entity:isItem() then
        lia.data.remove("entity_" .. entity:EntIndex())
        print("Cleaned up data for removed entity:", entity:GetClass())
    end
end)
```
    
---
### **PlayerInitialSpawn**
**Description:**  
Called when a player initially spawns on the server. Used to sync net vars or send data to the client.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PlayerInitialSpawn", "SyncPlayerData", function(client)
    local char = client:getChar()
    if char then
        lia.netstream.Start(client, "SyncCharData", char:getData())
        print("Synchronized data for:", client:Name())
    end
end)
```
    
---
### **PostPlayerInitialSpawn**
**Description:**  
Called after a player has fully initialized (post-initial-spawn logic).
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PostPlayerInitialSpawn", "SendWelcomeMessage", function(client)
    client:ChatPrint("Welcome to the server, " .. client:Name() .. "!")
    lia.notifications.send(client, "Welcome to the server!", Color(0, 255, 0))
end)
```
    
---
### **PlayerLiliaDataLoaded**
**Description:**  
Called when Lilia has finished loading all its data for a player (e.g., characters, inventories).
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PlayerLiliaDataLoaded", "InitializePlayerStats", function(client)
    client:SetHealth(client:getChar():getHealth())
    client:SetArmor(client:getChar():getArmor())
    print("Player data loaded for:", client:Name())
end)
```
    
---
### **OnCharDisconnect**
**Description:**  
Called when a player disconnects while having a valid character. Often used for partial saves or cleanups.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("OnCharDisconnect", "SavePartialData", function(client, character)
    lia.data.set("player_" .. character:getID(), character:getPartialData(), true)
    print("Partial data saved for disconnected character:", character:getName())
end)
```
    
---
### **ShouldSpawnClientRagdoll**
**Description:**  
Determines if a client ragdoll should spawn (e.g., on death or fallover).
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**  
- `bool` (`false` to prevent ragdoll)
    
**Example Usage:**
```lua
hook.Add("ShouldSpawnClientRagdoll", "DisableRagdollForVIPs", function(client)
    if client:isVIP() then
        return false -- VIPs do not spawn ragdolls on death
    end
end)
```
    
---
### **PlayerUse**
**Description:**  
Called when a player attempts to use an entity recognized as a door or player.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `entity` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("PlayerUse", "PreventUsingLockedDoors", function(client, entity)
    if entity:isDoor() and not entity:isUnlocked() then
        client:ChatPrint("This door is locked.")
        return false -- Prevent usage
    end
end)
```
    
---
### **ShouldMenuButtonShow**
**Description:**  
Determines if a particular menu button should appear (e.g., character creation).
    
**Realm:** 
`Client`
    
**Parameters:**
- `buttonName` (`string`)
    
**Returns:**  
1. `bool|nil` — Return `false` to hide, or `nil` to allow.  
2. `string|nil` — Optional reason or message.
    
**Example Usage:**
```lua
hook.Add("ShouldMenuButtonShow", "HideAdminMenuButton", function(buttonName)
    if buttonName == "AdminPanel" and not LocalPlayer():isAdmin() then
        return false, "Admin access required."
    end
end)
```
    
---
### **OnItemCreated**
**Description:**  
Called when an item entity is *created* in the world (different from *OnItemSpawned*).
    
**Realm:** 
`Server`
    
**Parameters:**
- `itemTable` (`table`)
- `entity` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("OnItemCreated", "LogNewItemCreation", function(itemTable, entity)
    print("New item created:", itemTable.name, "at position", entity:GetPos())
    -- Apply special properties
    if itemTable.uniqueID == "magic_scroll" then
        entity:setGlow(true)
    end
end)
```
    
---
### **getItemDropModel**
**Description:**  
Returns an alternate model path for a dropped item instead of the default.
    
**Realm:** 
`Server`
    
**Parameters:**
- `itemTable` (`table`)
- `entity` (`Entity`)
    
**Returns:**
- `string|nil`: An alternate path, or `nil` for default.
    
**Example Usage:**
```lua
hook.Add("getItemDropModel", "CustomDropModelForWeapons", function(itemTable, entity)
    if itemTable.category == "Weapon" then
        return "models/weapons/w_rif_ak47.mdl"
    end
end)
```
    
---
### **HandleItemTransferRequest**
**Description:**  
Triggered when the client sends a request to transfer an item from one inventory slot to another.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `itemID` (`number`)
- `x`, `y` (coordinates or nil)
- `invID` (target inventory ID or nil)
    
**Example Usage:**
```lua
hook.Add("HandleItemTransferRequest", "ValidateItemTransfer", function(client, itemID, x, y, invID)
    local item = client:getInv():getItemByID(itemID)
    if item and item:isTransferable() then
        client:getInv():moveItem(itemID, invID, x, y)
        print(client:Name() .. " transferred item ID " .. itemID .. " to inventory " .. invID)
    else
        client:ChatPrint("You cannot transfer this item.")
    end
end)
```
    
---
### **SetupBagInventoryAccessRules**
**Description:**  
Configure or override rules for a *bag* inventory (e.g., restricting categories).
    
**Realm:** 
`Server` or `Shared`
    
**Parameters:**
- `inventory` (Inventory)
    
**Example Usage:**
```lua
hook.Add("SetupBagInventoryAccessRules", "RestrictBagToConsumables", function(inventory)
    inventory:setAllowedCategories({"Consumables"})
    print("Bag inventory restricted to Consumables category.")
end)
```
    
---
### **CanPickupMoney**
**Description:**  
Determines if a player can pick up a money entity from the ground.
    
**Realm:** 
`Server`
    
**Parameters:**
- `activator` (`Player`)
- `entity` (`Entity`)
    
**Returns:**  
- `bool` (`false` to block)
    
**Example Usage:**
```lua
hook.Add("CanPickupMoney", "LimitMoneyPickupInSafeZones", function(activator, entity)
    if activator:isInSafeZone() then
        return false -- Prevent picking up money in safe zones
    end
end)
```
    
---
### **GetMoneyModel**
**Description:**  
Returns a custom model path for a money entity based on its amount.
    
**Realm:** 
`Server`
    
**Parameters:**
- `amount` (`number`)
    
**Returns:**
- `string|nil`
    
**Example Usage:**
```lua
hook.Add("GetMoneyModel", "DynamicMoneyModels", function(amount)
    if amount >= 1000 then
        return "models/props/cs_assault/money_bag_large.mdl"
    elseif amount >= 100 then
        return "models/props/cs_assault/money_bag_medium.mdl"
    else
        return "models/props/cs_assault/money_bag_small.mdl"
    end
end)
```
    
---
### **CanOutfitChangeModel**
**Description:**  
Determines whether an outfit item can change the player’s model.
    
**Realm:** 
`Server`
    
**Parameters:**
- `item` (Item)
    
**Returns:**  
- `bool` (`false` to block)
    
**Example Usage:**
```lua
function MODULE:CanOutfitChangeModel(item)
    if item.uniqueID == "halloween_costume" then
        return false -- Prevent changing model with Halloween costume
    end
    return true
end
```
    
---
### **OnCharPermakilled**
**Description:**  
Called when a character is permanently killed.
    
**Realm:** 
`Server` or `Shared`
    
**Parameters:**
- `character` (Character)
- `time` (`number|nil`)
    
**Example Usage:**
```lua
hook.Add("OnCharPermakilled", "HandleCharacterPermakill", function(character, time)
    print("Character " .. character:getName() .. " has been permanently killed.")
    -- Log the event or notify administrators
    lia.log.write("CharacterPermakill", character:getName() .. " was permakilled.")
end)
```
    
---
### **ItemCombine**
**Description:**  
Called when the system attempts to combine one item with another in an inventory.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (Item)
- `targetItem` (Item)
    
**Returns:**  
- `bool`: `true` if combination is valid and consumed, `false` otherwise.
    
**Example Usage:**
```lua
hook.Add("ItemCombine", "CombineHealthAndHerb", function(client, item, targetItem)
    if item.uniqueID == "health_potion" and targetItem.uniqueID == "herb" then
        local newItem = lia.item.create("super_health_potion")
        client:getInv():addItem(newItem)
        client:getInv():removeItem(item.id)
        client:getInv():removeItem(targetItem.id)
        print(client:Name() .. " combined Health Potion with Herb to create Super Health Potion.")
        return true
    end
    return false
end)
```
    
---
### **OnCharFallover**
**Description:**  
Called when a character ragdolls or “falls over.”
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `unknown` (any)
- `bool` (forced or not)
    
**Example Usage:**
```lua
hook.Add("OnCharFallover", "HandleFallover", function(client, unknown, forced)
    if forced then
        client:ChatPrint("You have been forcibly knocked down!")
    else
        client:ChatPrint("You have fallen over.")
    end
    -- Apply status effects or cooldowns
    client:setStatus("falling", true)
end)
```
    
---
### **AddCreationData**
**Description:**  
Allows modifying or adding extra data steps in the character creation process (server side).
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `data` (`table`)
- `newData` (`table`)
- `originalData` (`table`)
    
**Example Usage:**
```lua
hook.Add("AddCreationData", "IncludeBackgroundStory", function(client, data, newData, originalData)
    newData.background = "A mysterious past awaits."
    print("Background story added to character creation data.")
end)
```
    
---
### **CharListUpdated**
**Description:**  
Called when the character list for a player is updated (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `oldCharList` (`table`)
- `newCharList` (`table`)
    
**Example Usage:**
```lua
hook.Add("CharListUpdated", "UpdateUIOnCharListChange", function(oldCharList, newCharList)
    if #newCharList > #oldCharList then
        print("A new character has been added to the list.")
    elseif #newCharList < #oldCharList then
        print("A character has been removed from the list.")
    else
        print("Character list updated.")
    end
    -- Refresh the character selection UI
    inventoryUI:updateCharacterList(newCharList)
end)
```
    
---
### **ConfigureCharacterCreationSteps**
**Description:**  
Allows schemas/modules to insert or modify steps in the char creation UI (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel` (`Panel`)
    
**Example Usage:**
```lua
hook.Add("ConfigureCharacterCreationSteps", "AddAppearanceStep", function(panel)
    local appearanceStep = vgui.Create("DPanel", panel)
    appearanceStep:Dock(TOP)
    appearanceStep:SetTall(100)
    appearanceStep.Paint = function(self, w, h)
        draw.SimpleText("Customize Your Appearance", "Default", 10, 10, Color(255,255,255))
    end
    panel:addStep("Appearance", appearanceStep)
    print("Appearance step added to character creation.")
end)
```
    
---
### **CanDeleteChar**
**Description:**  
Checks if a character can be deleted before the UI or server attempts it.
    
**Realm:** 
`Client` or `Shared`
    
**Parameters:**
- `charID` (`number`)
    
**Returns:**  
- `bool`: `false` to block
- `string|nil`: Optional reason
    
**Example Usage:**
```lua
hook.Add("CanDeleteChar", "PreventDeletionOfMainChar", function(charID)
    local character = lia.character.getByID(charID)
    if character and character:isMainCharacter() then
        return false, "You cannot delete your main character."
    end
end)
```
    
---
### **KickedFromChar**
**Description:**  
Called when a player is forcibly kicked from their current character.
    
**Realm:** 
`Client`
    
**Parameters:**
- `id` (`number`): The character ID
- `isCurrentChar` (`bool`)
    
**Example Usage:**
```lua
hook.Add("KickedFromChar", "NotifyPlayerOfKick", function(id, isCurrentChar)
    if isCurrentChar then
        chat.AddText(Color(255,0,0), "You have been kicked from your current character (ID: " .. id .. ").")
    else
        print("You have been kicked from character ID:", id)
    end
end)
```
    
---
### **LiliaLoaded**
**Description:**  
Called when Lilia’s client-side scripts have fully loaded.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("LiliaLoaded", "InitializeClientFeatures", function()
    lia.clientFeatures.initialize()
    print("Lilia client-side scripts have been loaded.")
end)
```

---
### **VendorClassUpdated**
**Description:**  
Called when a vendor’s allowed classes are updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `id` (`string`): Class ID
- `allowed` (`bool`)
    
**Example Usage:**
```lua
hook.Add("VendorClassUpdated", "UpdateVendorUIForClasses", function(vendor, id, allowed)
    local vendorPanel = lia.ui.getVendorPanel(vendor)
    if vendorPanel then
        vendorPanel:updateClassAccess(id, allowed)
        print("Vendor class access updated for class ID:", id)
    end
end)
```
    
---
### **VendorFactionUpdated**
**Description:**  
Called when a vendor’s allowed factions are updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `id` (`string`)
- `allowed` (`bool`)
    
**Example Usage:**
```lua
hook.Add("VendorFactionUpdated", "RefreshVendorFactionDisplay", function(vendor, id, allowed)
    local vendorUI = lia.ui.getVendorUI(vendor)
    if vendorUI then
        vendorUI:updateFactionAccess(id, allowed)
        print("Vendor faction access updated for faction ID:", id)
    end
end)
```
    
---
### **VendorItemMaxStockUpdated**
**Description:**  
Called when a vendor’s item max stock is updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `itemType` (`string`)
- `value` (`int`)
    
**Example Usage:**
```lua
hook.Add("VendorItemMaxStockUpdated", "UpdateVendorStockLimits", function(vendor, itemType, value)
    local vendorPanel = lia.ui.getVendorPanel(vendor)
    if vendorPanel then
        vendorPanel:setItemMaxStock(itemType, value)
        print("Vendor stock limit updated for item:", itemType, "New limit:", value)
    end
end)
```
    
---
### **VendorItemStockUpdated**
**Description:**  
Called when a vendor’s item stock is updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `itemType` (`string`)
- `value` (`int`)
    
**Example Usage:**
```lua
hook.Add("VendorItemStockUpdated", "RefreshVendorItemStock", function(vendor, itemType, value)
    local vendorUI = lia.ui.getVendorUI(vendor)
    if vendorUI then
        vendorUI:updateItemStock(itemType, value)
        print("Vendor item stock updated for", itemType, "New stock:", value)
    end
end)
```
    
---
### **VendorItemModeUpdated**
**Description:**  
Called when a vendor’s item mode is updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `itemType` (`string`)
- `value` (`int`)
    
**Example Usage:**
```lua
hook.Add("VendorItemModeUpdated", "ChangeVendorItemMode", function(vendor, itemType, value)
    local vendorUI = lia.ui.getVendorUI(vendor)
    if vendorUI then
        vendorUI:setItemMode(itemType, value)
        print("Vendor item mode updated for", itemType, "Mode:", value)
    end
end)
```
    
---
### **VendorItemPriceUpdated**
**Description:**  
Called when a vendor’s item price is updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `itemType` (`string`)
- `value` (`int`)
    
**Example Usage:**
```lua
hook.Add("VendorItemPriceUpdated", "UpdateVendorItemPrices", function(vendor, itemType, value)
    local vendorPanel = lia.ui.getVendorPanel(vendor)
    if vendorPanel then
        vendorPanel:updateItemPrice(itemType, value)
        print("Vendor item price updated for", itemType, "New price:", value)
    end
end)
```
    
---
### **VendorMoneyUpdated**
**Description:**  
Called when a vendor’s money is updated.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `money` (`int`)
- `oldMoney` (`int`)
    
**Example Usage:**
```lua
hook.Add("VendorMoneyUpdated", "RefreshVendorFunds", function(vendor, money, oldMoney)
    local vendorUI = lia.ui.getVendorUI(vendor)
    if vendorUI then
        vendorUI:updateFunds(money)
        print("Vendor funds updated from $" .. oldMoney .. " to $" .. money)
    end
end)
```
    
---
### **VendorEdited**
**Description:**  
Called after a delay when a vendor’s data is edited.
    
**Realm:** 
`Client`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `vendor` (`Entity`)
- `key` (`string`)
    
**Example Usage:**
```lua
hook.Add("VendorEdited", "NotifyVendorEdit", function(vendor, key)
    lia.notifications.sendAdmins("Vendor " .. vendor:GetClass() .. " has been edited. Key changed: " .. key)
    print("Vendor edited. Key:", key)
end)
```
    
---
### **VendorTradeEvent**
**Description:**  
Called when a player attempts to trade with a vendor.
    
**Realm:** 
`Server`
    
**Internal:**  
This function is intended for internal use and should not be called directly.
    
**Parameters:**  
- `client` (`Player`)
- `entity` (`Entity`): The vendor
- `uniqueID` (`string`): The item ID
- `isSellingToVendor` (`bool`)
    
**Example Usage:**
```lua
hook.Add("VendorTradeEvent", "LogVendorTrades", function(client, entity, uniqueID, isSellingToVendor)
    local action = isSellingToVendor and "sold" or "bought"
    print(client:Name() .. " " .. action .. " item " .. uniqueID .. " with vendor " .. entity:GetClass())
    -- Log the trade or apply additional logic
    lia.log.write("VendorTrade", client:Name() .. " " .. action .. " " .. uniqueID .. " with " .. entity:GetClass())
end)
```
    
---
### **VendorSynchronized**
**Description:**  
Called when vendor synchronization data is received.
    
**Realm:** 
`Client`
    
**Parameters:**
- `vendor` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("VendorSynchronized", "UpdateVendorUIAfterSync", function(vendor)
    local vendorUI = lia.ui.getVendorUI(vendor)
    if vendorUI then
        vendorUI:refreshItems()
        print("Vendor UI refreshed after synchronization for:", vendor:GetClass())
    end
end)
```
    
---
### **CanPlayerAccessVendor**
**Description:**  
Determines whether a player can access a vendor.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `entity` (`Entity`): The vendor
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerAccessVendor", "RestrictVendorAccess", function(client, entity)
    if entity.requiresLevel and client:getLevel() < entity.requiredLevel then
        client:ChatPrint("You need to be level " .. entity.requiredLevel .. " to access this vendor.")
        return false
    end
    return true
end)
```

---
### **OnCharTradeVendor**
**Description:**  
Called when a character trades with a vendor.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `vendor` (`Entity`)
- `item` (`Entity` or item table)
- `isSellingToVendor` (`bool`)
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("OnCharTradeVendor", "ApplyTradeBonuses", function(client, vendor, item, isSellingToVendor, character)
    if isSellingToVendor and item.category == "Weapon" then
        character:addReputation(10)
        print("Reputation increased by 10 for selling a weapon.")
    elseif not isSellingToVendor and item.category == "Potion" then
        character:addReputation(5)
        print("Reputation increased by 5 for buying a potion.")
    end
end)
```

---
### **VendorExited**
**Description:**  
Called when a player exits from interacting with a vendor.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("VendorExited", "CloseVendorUI", function()
    local vendorUI = lia.ui.getActiveVendorUI()
    if vendorUI then
        vendorUI:remove()
        print("Vendor UI has been closed.")
    end
end)
```
    
---
### **VendorOpened**
**Description:**  
Called when a vendor is opened (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `vendor` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("VendorOpened", "InitializeVendorInterface", function(vendor)
    local vendorPanel = lia.ui.createVendorPanel(vendor)
    vendorPanel:open()
    print("Vendor interface opened for:", vendor:GetClass())
end)
```
    
---
### **OnOpenVendorMenu**
**Description:**  
Called when the vendor menu is opened.
    
**Realm:** 
`Client`
    
**Parameters:**
- `self` (`Entity`): The vendor
    
**Example Usage:**
```lua
hook.Add("OnOpenVendorMenu", "CustomizeVendorMenu", function(vendor)
    local menu = lia.ui.getVendorMenu(vendor)
    menu:addOption("Donate", function()
        lia.netstream.Start("DonateToVendor", vendor, 100)
    end)
    print("Customized vendor menu for:", vendor:GetClass())
end)
```
    
---
### **FactionOnLoadout**
**Description:**  
Called after `PlayerLoadout` is executed, specifically for faction loadout.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("FactionOnLoadout", "EquipFactionWeapons", function(client)
    local faction = client:getFaction()
    if faction == FACTION_POLICE then
        client:giveWeapon("weapon_pistol")
        client:giveWeapon("weapon_stunstick")
        print(client:Name() .. " has been equipped with police weapons.")
    end
end)
```
    
---
### **ClassOnLoadout**
**Description:**  
Called after `FactionOnLoadout` is executed, specifically for class loadout.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("ClassOnLoadout", "EquipClassSpecificGear", function(client)
    local class = client:getClass()
    if class == CLASS_MEDIC then
        client:giveItem("medical_kit")
        print(client:Name() .. " has received a Medical Kit.")
    elseif class == CLASS_ENGINEER then
        client:giveItem("toolkit")
        print(client:Name() .. " has received a Toolkit.")
    end
end)
```
    
---
### **FactionPostLoadout**
**Description:**  
Called after `ClassOnLoadout`, for extra faction loadout logic.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("FactionPostLoadout", "AssignFactionRole", function(client)
    local faction = client:getFaction()
    if faction == FACTION_HEAVY then
        client:setRole("Heavy Infantry")
        print(client:Name() .. " assigned role: Heavy Infantry.")
    end
end)
```
    
---
### **ClassPostLoadout**
**Description:**  
Called after `FactionPostLoadout`, for extra class loadout logic.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("ClassPostLoadout", "ApplyClassModifiers", function(client)
    local class = client:getClass()
    if class == CLASS_SNIPER then
        client:setAccuracy(90)
        print(client:Name() .. " accuracy set to 90 for Sniper class.")
    end
end)
```
    
---
### **PostPlayerLoadout**
**Description:**  
Called after all player loadout hooks (PlayerLoadout, FactionOnLoadout, ClassOnLoadout) have finished.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PostPlayerLoadout", "FinalizePlayerStats", function(client)
    client:updateStats()
    lia.notifications.send(client, "Loadout complete. Good luck!")
    print("Player loadout finalized for:", client:Name())
end)
```
    
---
### **ChatTextChanged**
**Description:**  
Called when the text in the chat input box changes.
    
**Realm:** 
`Client`
    
**Parameters:**
- `text` (`string`)
    
**Example Usage:**
```lua
hook.Add("ChatTextChanged", "MonitorChatInput", function(text)
    if string.len(text) > 100 then
        chat.AddText(Color(255,0,0), "Warning: Chat message is too long!")
    end
end)
```
    
---
### **FinishChat**
**Description:**  
Called when the chat input box is closed.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("FinishChat", "ClearChatInput", function()
    print("Chat input has been closed.")
    -- Perform actions like saving chat history or resetting variables
end)
```
    
---
### **ChatAddText**
**Description:**  
Called to add text to the chat. Allows formatting or modifying text before display.
    
**Realm:** 
`Client`
    
**Parameters:**
- `text` (`string`) — the markup
- `...` additional text arguments
    
**Returns:**  
- `string` modified text markup
    
**Example Usage:**
```lua
hook.Add("ChatAddText", "FormatChatMessages", function(text, ...)
    local formattedText = "<font=DefaultBold>" .. text .. "</font>"
    return formattedText, ...
end)
```
    
---
### **StartChat**
**Description:**  
Called when the chat input box is opened.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("StartChat", "PrepareChatInput", function()
    print("Chat input has been opened.")
    -- Initialize chat input state or variables
end)
```
    
---
### **PostPlayerSay**
**Description:**  
Called after a player sends a chat message.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `message` (`string`)
- `chatType` (`string`)
- `anonymous` (`bool`)
    
**Example Usage:**
```lua
hook.Add("PostPlayerSay", "LogPlayerChats", function(client, message, chatType, anonymous)
    lia.log.write("PlayerChat", client:Name() .. " [" .. chatType .. "]: " .. message)
    print("Logged chat from:", client:Name())
end)
```
    
---
### **OnChatReceived**
**Description:**  
Called after a player sends a chat message.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `message` (`string`)
- `chatType` (`string`)
- `anonymous` (`bool`)
    
**Example Usage:**
```lua
hook.Add("OnChatReceived", "HandleSpecialCommands", function(client, message, chatType, anonymous)
    if string.sub(message, 1, 1) == "!" then
        local command = string.lower(string.sub(message, 2))
        if command == "help" then
            client:ChatPrint("Available commands: !help, !stats, !rules")
            return false -- Prevent message from being broadcasted
        end
    end
end)
```
    
---
### **CanDisplayCharInfo**
**Description:**  
Determines whether certain information can be displayed in the character info panel of the F1 menu.
    
**Realm:** 
`Client`
    
**Parameters:**
- `suppress` (table)  
  - Example keys: `name`, `desc`, `faction`, `money`, `class`
    
**Example Usage:**
```lua
function MODULE:CanDisplayCharInfo(suppress)
    if LocalPlayer():hasFlag("hide_faction") then
        suppress.faction = true
    end
    if LocalPlayer():hasFlag("hide_money") then
        suppress.money = true
    end
end
```
---
### **CanPlayerViewInventory**
*(Alias for F1 menu usage.)*  
Determines if a player is allowed to open/view their inventory from F1 menu.
    
**Realm:** 
`Client`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerViewInventory", "RestrictInventoryAccess", function()
    if LocalPlayer():isInCombat() then
        return false -- Prevent accessing inventory during combat
    end
    return true
end)
```
    
---
### **BuildHelpMenu**
**Description:**  
Called when the help menu is being built.
    
**Realm:** 
`Client`
    
**Parameters:**
- `tabs` (table): Contains help menu tabs.
    
**Example Usage:**
```lua
hook.Add("BuildHelpMenu", "AddCustomHelpTab", function(tabs)
    local customTab = {}
    customTab.name = "Custom Help"
    customTab.content = "This is custom help content."
    table.insert(tabs, customTab)
    print("Custom help tab added.")
end)
```
    
---
### **CreateMenuButtons**
**Description:**  
Creates menu buttons for the F1 menu.
    
**Realm:** 
`Client`
    
**Parameters:**
- `tabs` (table)
    
**Example Usage:**
```lua
hook.Add("CreateMenuButtons", "AddSettingsButton", function(tabs)
    table.insert(tabs, {
        name = "Settings",
        icon = "icon16/cog.png",
        callback = function()
            lia.ui.openSettings()
        end
    })
    print("Settings button added to F1 menu.")
end)
```

---
### **ShouldDrawAmmoHUD**
**Description:**  
Whether or not the ammo HUD should be drawn.
    
**Realm:** 
`Client`
    
**Parameters:**
- `weapon` (Entity or table)
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawAmmoHUD", "HideAmmoHUDForSnipers", function(weapon)
    if weapon:GetClass() == "weapon_sniper" then
        return false -- Hide ammo HUD for sniper rifles
    end
end)
```
---
### **ShouldDrawCharInfo**
**Description:**  
Determines whether character info should be drawn for the given entity/character.
    
**Realm:** 
`Client`
    
**Parameters:**
- `entity` (`Entity`)
- `character` (Character)
- `charInfo` (table)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawCharInfo", "HideSensitiveInfo", function(entity, character, charInfo)
    if character:hasFlag("private") then
        return false -- Do not draw character info for private characters
    end
    return true
end)
```
    
---
### **ShouldDrawEntityInfo**
**Description:**  
Determines whether entity info should be drawn for the given entity.
    
**Realm:** 
`Client`
    
**Parameters:**
- `entity` (`Entity`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawEntityInfo", "HideInfoForProtectedEntities", function(entity)
    if entity:isProtected() then
        return false -- Do not draw info for protected entities
    end
    return true
end)
```
    
---
### **DrawEntityInfo**
**Description:**  
Draws information about the given entity.
    
**Realm:** 
`Client`
    
**Parameters:**
- `entity` (`Entity`)
- `alpha` (`float`)
    
**Example Usage:**
```lua
hook.Add("DrawEntityInfo", "DisplayEntityHealth", function(entity, alpha)
    if entity:isNPC() then
        local health = entity:getHealth()
        draw.SimpleText("Health: " .. health, "Default", entity:GetPos():ToScreen().x, entity:GetPos():ToScreen().y - 20, Color(255,0,0,alpha))
    end
end)
```
    
---
### **DrawCrosshair (Alias 1)**
**Description:**  
Draws the crosshair (if `ShouldDrawCrosshair` is `true`).
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("DrawCrosshair", "CustomCrosshair", function()
    surface.SetDrawColor(255, 255, 255, 255)
    local x, y = ScrW() / 2, ScrH() / 2
    surface.DrawLine(x - 10, y, x + 10, y)
    surface.DrawLine(x, y - 10, x, y + 10)
    print("Custom crosshair drawn.")
end)
```
    
---
### **ShouldDrawVignette**
**Description:**  
Determines whether the vignette effect should be drawn.
    
**Realm:** 
`Client`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawVignette", "ConditionalVignette", function()
    if LocalPlayer():isInDarkArea() then
        return true -- Enable vignette in dark areas
    end
    return false
end)
```
    
---
### **DrawVignette**
**Description:**  
Draws the vignette effect.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("DrawVignette", "CustomVignetteEffect", function()
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    print("Vignette effect drawn.")
end)
```
    
---
### **ShouldDrawBranchWarning**
**Description:**  
Determines whether a branching path warning should be drawn.
    
**Realm:** 
`Client`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawBranchWarning", "ShowWarningForNewPlayers", function()
    if LocalPlayer():getLevel() < 5 then
        return true -- Show warning to new players
    end
    return false
end)
```
    
---
### **DrawBranchWarning**
**Description:**  
Draws a branching path warning.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("DrawBranchWarning", "RenderBranchWarning", function()
    draw.SimpleText("Warning: You are on a risky path. Proceed with caution!", "DermaLarge", ScrW()/2, ScrH()/2, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    print("Branch warning rendered.")
end)
```
    
---
### **ShouldDrawBlur**
**Description:**  
Determines whether the blur effect should be drawn.
    
**Realm:** 
`Client`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawBlur", "EnableBlurInMenus", function()
    if gui.IsMenuVisible() then
        return true -- Enable blur when menus are open
    end
    return false
end)
```
    
---
### **DrawBlur**
**Description:**  
Draws the blur effect.
    
**Realm:** 
`Client`
    
**Example Usage:**
```lua
hook.Add("DrawBlur", "RenderBlurEffect", function()
    local blur = Material("pp/blurscreen")
    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    print("Blur effect rendered.")
end)
```
    
---
### **ShouldDrawPlayerInfo**
**Description:**  
Determines whether player information should be drawn.
    
**Realm:** 
`Client`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDrawPlayerInfo", "ShowInfoOnlyForAdmins", function()
    if LocalPlayer():isAdmin() then
        return true -- Only admins see player info
    end
    return false
end)
```
    
---
### **TooltipInitialize**
**Description:**  
Initializes the tooltip before it is displayed.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel` (tooltip panel)
- `targetPanel` (the panel for which the tooltip is displayed)
    
**Example Usage:**
```lua
hook.Add("TooltipInitialize", "CustomizeTooltip", function(panel, targetPanel)
    panel:SetSkin("DarkSkin")
    panel:SetFont("TooltipFont")
    print("Tooltip initialized for:", targetPanel:GetName())
end)
```
    
---
### **TooltipPaint**
**Description:**  
Handles painting of the tooltip.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel`
- `w`, `h` (width, height)
    
**Example Usage:**
```lua
hook.Add("TooltipPaint", "CustomTooltipAppearance", function(panel, w, h)
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText(panel:GetTooltipText(), "TooltipFont", 10, 10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    print("Custom tooltip painted.")
end)
```
    
---
### **TooltipLayout**
**Description:**  
Handles layout of the tooltip.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel`
    
**Example Usage:**
```lua
hook.Add("TooltipLayout", "ArrangeTooltipElements", function(panel)
    local text = panel:GetChild("TooltipText")
    text:SetPos(10, 10)
    text:SetSize(panel:GetWide() - 20, panel:GetTall() - 20)
    print("Tooltip elements arranged.")
end)
```
    
---
### **AdjustBlurAmount**
**Description:**  
Adjusts the amount of blur applied to the screen.
    
**Realm:** 
`Client`
    
**Parameters:**
- `blurGoal` (`int`)
    
**Returns:**  
- `number`: The adjusted blur amount.
    
**Example Usage:**
```lua
hook.Add("AdjustBlurAmount", "IncreaseBlurInRain", function(blurGoal)
    if weather.isRaining then
        return blurGoal + 5 -- Increase blur during rain
    end
    return blurGoal
end)
```
    
---
### **SetupQuickMenu**
**Description:**  
Sets up the quick menu by adding buttons, sliders, etc. Called during the panel’s initialization.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel` (the quick menu panel)
    
**Example Usage:**
```lua
hook.Add("SetupQuickMenu", "AddQuickSettingsButton", function(panel)
    local settingsButton = vgui.Create("DButton", panel)
    settingsButton:SetText("Settings")
    settingsButton:SetSize(100, 30)
    settingsButton:SetPos(10, 10)
    settingsButton.DoClick = function()
        lia.ui.openSettings()
    end
    print("Quick menu settings button added.")
end)
```
    
---
### **DrawLiliaModelView**
**Description:**  
Called to draw additional content within a model view panel.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel`
- `entity`
    
**Example Usage:**
```lua
hook.Add("DrawLiliaModelView", "EnhanceModelView", function(panel, entity)
    cam.Start3D2D(entity:GetPos() + Vector(0,0,50), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
        draw.SimpleText("Item: " .. entity:getItemTable().name, "Default", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    cam.End3D2D()
    print("Additional content drawn in model view for:", entity:getItemTable().name)
end)
```
    
---
### **ShouldShowPlayerOnScoreboard**
**Description:**  
Determines if a player should be shown on the scoreboard.
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldShowPlayerOnScoreboard", "HideSpectators", function(client)
    if client:isSpectator() then
        return false -- Hide spectators from the scoreboard
    end
    return true
end)
```
    
---
### **ShowPlayerOptions**
**Description:**  
Provides options for the player context menu on the scoreboard.
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
- `options` (table)  
  Each option is a table `{icon, callback}`.
    
**Example Usage:**
```lua
hook.Add("ShowPlayerOptions", "AddReportOption", function(targetPlayer, options)
    table.insert(options, {
        icon = "icon16/report.png",
        callback = function()
            lia.ui.openReportMenu(targetPlayer)
        end
    })
    print("Report option added to player context menu.")
end)
```
    
---
### **ShouldAllowScoreboardOverride**
**Description:**  
Determines whether a scoreboard value should be overridden (e.g., name, desc).
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
- `var` (`string`)
    
**Returns:**
- `bool` (true if override)
    
**Example Usage:**
```lua
hook.Add("ShouldAllowScoreboardOverride", "CustomNameDisplay", function(client, var)
    if var == "name" and client:hasRole("Admin") then
        return true -- Allow overriding the name for admins
    end
end)
```
    
---
### **CanPlayerAccessDoor**
**Description:**  
Called when a player tries to use abilities on the door (locking, etc.).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `door` (`Entity`)
- `access` (`int`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerAccessDoor", "RestrictDoorAccess", function(client, door, access)
    if access == DOOR_LOCK and not client:hasPermission("lock_doors") then
        return false -- Only players with lock permissions can lock doors
    end
    return true
end)
```
    
---
### **OnPlayerPurchaseDoor**
**Description:**  
Called when a player purchases or sells a door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `entity` (`Entity`): The door
- `buying` (`bool`): True if buying, false if selling
- `CallOnDoorChild` (function)
    
**Example Usage:**
```lua
hook.Add("OnPlayerPurchaseDoor", "HandleDoorPurchase", function(client, entity, buying, CallOnDoorChild)
    if buying then
        client:deductMoney(entity:getPrice())
        lia.log.write("DoorPurchase", client:Name() .. " purchased door ID: " .. entity:EntIndex())
        print(client:Name() .. " purchased a door.")
    else
        client:addMoney(entity:getSellPrice())
        lia.log.write("DoorSale", client:Name() .. " sold door ID: " .. entity:EntIndex())
        print(client:Name() .. " sold a door.")
    end
    CallOnDoorChild(entity)
end)
```    
---
### **PlayerUseDoor**
**Description:**  
Called when a player attempts to use a door entity.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `entity` (`Entity`)
    
**Returns:**
- `bool|nil`: `false` to disallow, `true` to allow, or `nil` to let other hooks decide.
    
**Example Usage:**
```lua
hook.Add("PlayerUseDoor", "LogDoorUsage", function(client, entity)
    print(client:Name() .. " is attempting to use door ID:", entity:EntIndex())
    -- Allow or disallow based on custom conditions
    if client:isBanned() then
        return false -- Disallow use if the player is banned
    end
end)
```
    
---
### **KeyLock**
**Description:**  
Called when a player attempts to lock a door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `owner` (`Player`)
- `entity` (`Entity`)
- `time` (`float`)
    
**Example Usage:**
```lua
hook.Add("KeyLock", "LogDoorLock", function(owner, entity, time)
    entity:setLocked(true)
    lia.log.write("DoorLock", owner:Name() .. " locked door ID: " .. entity:EntIndex() .. " for " .. time .. " seconds.")
    print(owner:Name() .. " locked door ID:", entity:EntIndex(), "for", time, "seconds.")
end)
```
    
---
### **KeyUnlock**
**Description:**  
Called when a player attempts to unlock a door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `owner` (`Player`)
- `entity` (`Entity`)
- `time` (`float`)
    
**Example Usage:**
```lua
hook.Add("KeyUnlock", "LogDoorUnlock", function(owner, entity, time)
    entity:setLocked(false)
    lia.log.write("DoorUnlock", owner:Name() .. " unlocked door ID: " .. entity:EntIndex() .. " after " .. time .. " seconds.")
    print(owner:Name() .. " unlocked door ID:", entity:EntIndex(), "after", time, "seconds.")
end)
```
    
---
### **ToggleLock**
**Description:**  
Toggles the lock state of a door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `door` (`Entity`)
- `state` (`bool`): `true`=locked, `false`=unlocked
    
**Example Usage:**
```lua
hook.Add("ToggleLock", "HandleDoorLockToggle", function(client, door, state)
    door:setLocked(state)
    local action = state and "locked" or "unlocked"
    lia.log.write("DoorToggle", client:Name() .. " " .. action .. " door ID: " .. door:EntIndex())
    print(client:Name() .. " has " .. action .. " door ID:", door:EntIndex())
end)
```
    
---
### **callOnDoorChildren**
**Description:**  
Calls a function on all child entities of a door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `entity` (`Entity`)
- `callback` (function)
    
**Example Usage:**
```lua
hook.Add("callOnDoorChildren", "UpdateChildEntities", function(entity, callback)
    for _, child in ipairs(entity:GetChildren()) do
        callback(child)
        print("Callback executed on child entity ID:", child:EntIndex())
    end
end)
```
    
---
### **copyParentDoor**
**Description:**  
Copies the parent door's properties to a child door.
    
**Realm:** 
`Server`
    
**Parameters:**
- `child` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("copyParentDoor", "SyncChildDoorProperties", function(child)
    local parent = child:getParentDoor()
    if parent then
        child:setLocked(parent:isLocked())
        child:setOwner(parent:getOwner())
        print("Copied properties from parent door ID:", parent:EntIndex(), "to child door ID:", child:EntIndex())
    end
end)
```
    
---
### **ShouldDeleteSavedItems**
**Description:**  
Determines if saved items should be deleted on server restart.
    
**Realm:** 
`Server`
    
**Returns:**  
- `bool`
    
**Example Usage:**
```lua
hook.Add("ShouldDeleteSavedItems", "ConditionalItemDeletion", function()
    if lia.config.resetItemsOnRestart then
        return true -- Delete saved items on restart
    end
    return false
end)
```
    
---
### **OnSavedItemLoaded**
**Description:**  
Called after saved items are loaded from the database.
    
**Realm:** 
`Server`
    
**Parameters:**
- `loadedItems` (table): Contains loaded item entities.
    
**Example Usage:**
```lua
hook.Add("OnSavedItemLoaded", "InitializeLoadedItems", function(loadedItems)
    for _, item in ipairs(loadedItems) do
        item:initialize()
        print("Loaded and initialized item:", item:getName())
    end
end)
```
   
---
    
### **ShouldDisableThirdperson**
**Description:**  
Checks if third-person view is allowed or disabled.
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `bool` (true if 3rd-person should be disabled)
    
**Example Usage:**
```lua
hook.Add("ShouldDisableThirdperson", "DisableForInvisibles", function(client)
    if client:isInvisible() then
        return true -- Disable third-person view when invisible
    end
end)
```
    
---
### **OnCharAttribBoosted**
**Description:**  
Called when a character’s attribute is updated.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
- `key` (`string`)
- `value` (`int`)
    
**Example Usage:**
```lua
hook.Add("OnCharAttribBoosted", "NotifyAttributeBoost", function(client, character, key, value)
    chat.AddText(Color(0,255,0), "Your " .. key .. " attribute has been increased by " .. value .. "!")
    lia.log.write("AttributeBoost", character:getName() .. "'s " .. key .. " increased by " .. value)
    print("Attribute " .. key .. " boosted by " .. value .. " for character:", character:getName())
end)
```
    
---
### **PlayerStaminaGained**
**Description:**  
Called when a player gains stamina.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PlayerStaminaGained", "NotifyStaminaGain", function(client)
    client:ChatPrint("You have regained stamina!")
    print(client:Name() .. " has gained stamina.")
end)
```
    
---
### **PlayerStaminaLost**
**Description:**  
Called when a player loses stamina.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("PlayerStaminaLost", "WarnStaminaLow", function(client)
    if client:getStamina() < 20 then
        client:ChatPrint("Warning: Your stamina is low!")
        print(client:Name() .. " has low stamina.")
    end
end)
```
    
---
### **CanPlayerThrowPunch**
**Description:**  
Determines if a player can throw a punch.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerThrowPunch", "RestrictPunchDuringStealth", function(client)
    if client:isStealthed() then
        return false -- Prevent punching while in stealth mode
    end
    return true
end)
```
    
---
### **AdjustStaminaOffsetRunning**
**Description:**  
Adjusts stamina offset when a player is running.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `offset` (`float`)
    
**Returns:**
- `number`: The modified offset
    
**Example Usage:**
```lua
hook.Add("AdjustStaminaOffsetRunning", "IncreaseStaminaDrainForHeavyGear", function(client, offset)
    if client:hasHeavyGear() then
        return offset + 5 -- Increase stamina drain by 5 when running with heavy gear
    end
    return offset
end)
```
    
---
### **AdjustStaminaRegeneration**
**Description:**  
Adjusts the rate at which a player regenerates stamina.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `offset` (`float`)
    
**Returns:**
- `number`
    
**Example Usage:**
```lua
hook.Add("AdjustStaminaRegeneration", "BoostRegenerationForMedics", function(client, offset)
    if client:getClass() == CLASS_MEDIC then
        return offset + 2 -- Medics regenerate stamina faster
    end
    return offset
end)
```
    
---
### **AdjustStaminaOffset**
**Description:**  
Adjusts the stamina offset otherwise (generic hook).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `offset` (`float`)
    
**Returns:**
- `number`
    
**Example Usage:**
```lua
hook.Add("AdjustStaminaOffset", "ModifyStaminaForNightMode", function(client, offset)
    if lia.time.isNight() then
        return offset - 3 -- Decrease stamina during night
    end
    return offset
end)
```
    
---
### **CalcStaminaChange**
**Description:**  
Calculates the change in a player’s stamina (positive or negative).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `number` (the stamina change)
    
**Example Usage:**
```lua
hook.Add("CalcStaminaChange", "StaminaChangeBasedOnSpeed", function(client)
    local speed = client:getVelocity():Length()
    if speed > 200 then
        return -10 -- Decrease stamina quickly when moving fast
    elseif speed > 100 then
        return -5 -- Moderate stamina decrease
    else
        return 2 -- Regenerate stamina slowly
    end
end)
```
    
---
### **CanPlayerViewAttributes**
**Description:**  
Checks if a player is allowed to view their attributes.
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerViewAttributes", "RestrictAttributeViewForLockedCharacters", function(client)
    if client:getChar():isLocked() then
        return false -- Prevent viewing attributes if character is locked
    end
    return true
end)
```
    
---
### **GetStartAttribPoints**
**Description:**  
Retrieves the initial number of attribute points a player starts with.
    
**Realm:** 
`Client`
    
**Parameters:**
- `client` (`Player`)
- `context` (table)
    
**Returns:**
- `number`: The starting attribute points
    
**Example Usage:**
```lua
hook.Add("GetStartAttribPoints", "BonusPointsForVeterans", function(client, context)
    if client:isVeteran() then
        return 10 -- Give veterans 10 extra attribute points
    end
    return 5 -- Default starting points
end)
```
    
---
### **PlayerCanPickupItem (Attributes)**
**Description:**  
Determines if a player can pick up an item with their hands.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `item` (Item)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("PlayerCanPickupItem", "PreventPickupOfCursedItems", function(client, item)
    if item:isCursed() and not client:isBlessed() then
        return false -- Prevent pickup of cursed items unless player is blessed
    end
    return true
end)
```
    
---
### **getCharMaxStamina**
**Description:**  
Determines the maximum stamina for a character.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `character` (Character)
    
**Returns:**
- `number`: The maximum stamina
    
**Example Usage:**
```lua
hook.Add("getCharMaxStamina", "SetMaxStaminaBasedOnClass", function(character)
    local class = character:getClass()
    if class == CLASS_WARRIOR then
        return 150
    elseif class == CLASS_ROGUE then
        return 100
    else
        return 120
    end
end)
```

---
### **PostDrawInventory (Inventory)**
**Description:**  
Called after the player's inventory is drawn.
    
**Realm:** 
`Client`
    
**Parameters:**
- `panel` (inventory panel)
    
**Example Usage:**
```lua
hook.Add("PostDrawInventory", "AddInventoryFooter", function(panel)
    draw.SimpleText("End of Inventory", "Default", panel:GetWide() / 2, panel:GetTall() - 20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    print("Inventory footer added.")
end)
```
    
---
### **InterceptClickItemIcon**
**Description:**  
Called when a player clicks on an item icon.
    
**Realm:** 
`Client`
    
**Parameters:**
- `self` (panel)
- `itemIcon` (panel)
- `keyCode` (int)
    
**Example Usage:**
```lua
hook.Add("InterceptClickItemIcon", "HandleItemDoubleClick", function(self, itemIcon, keyCode)
    if keyCode == KEY_MOUSE2 then -- Right-click
        local item = itemIcon:getItem()
        lia.ui.openItemContextMenu(item, itemIcon:GetPos())
        print("Item context menu opened for:", item.name)
    end
end)
```
    
---
### **OnRequestItemTransfer**
**Description:**  
Called when an item transfer is requested (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `self` (panel)
- `itemID` (int)
- `inventoryID` (int)
- `x` (int)
- `y` (int)
    
**Example Usage:**
```lua
hook.Add("OnRequestItemTransfer", "SendTransferRequest", function(self, itemID, inventoryID, x, y)
    lia.netstream.Start("TransferItem", {itemID = itemID, inventoryID = inventoryID, x = x, y = y})
    print("Transfer request sent for item ID:", itemID)
end)
```
    
---
### **ItemPaintOver**
**Description:**  
Called when an item is being painted over in the inventory.
    
**Realm:** 
`Client`
    
**Parameters:**
- `self` (panel)
- `itemTable` (table)
- `w` (int)
- `h` (int)
    
**Example Usage:**
```lua
hook.Add("ItemPaintOver", "DisplayItemRarity", function(self, itemTable, w, h)
    if itemTable.rarity == "rare" then
        surface.SetDrawColor(255, 215, 0, 150) -- Gold color
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("Rare", "DefaultSmall", w - 30, h - 15, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
```
    
---
### **OnCreateItemInteractionMenu**
**Description:**  
Called when an item interaction menu is created (e.g., right-click menu).
    
**Realm:** 
`Client`
    
**Parameters:**
- `self` (panel)
- `menu` (panel)
- `itemTable` (table)
    
**Example Usage:**
```lua
hook.Add("OnCreateItemInteractionMenu", "AddCustomActions", function(self, menu, itemTable)
    if itemTable.uniqueID == "magic_scroll" then
        menu:AddOption("Cast Spell", function()
            lia.netstream.Start("CastSpell", itemTable.id)
        end)
    end
    print("Custom actions added to interaction menu for:", itemTable.name)
end)
```
    
---
### **CanRunItemAction**
**Description:**  
Determines if a specific action can be run on an item.
    
**Realm:** 
`Client`
    
**Parameters:**
- `itemTable` (table)
- `action` (string)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanRunItemAction", "RestrictActionForCursedItems", function(itemTable, action)
    if itemTable.isCursed and action == "use" then
        return false -- Prevent using cursed items
    end
    return true
end)
```
    
---
### **CanItemBeTransfered**
**Description:**  
Determines whether an item can be transferred between inventories.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `item` (Item)
- `currentInv` (Inventory)
- `oldInv` (Inventory)
    
**Returns:**
- `bool|string`: `true` to allow, or `false`/string for disallowed & reason.
    
**Example Usage:**
```lua
hook.Add("CanItemBeTransfered", "PreventTransferOfBoundItems", function(item, currentInv, oldInv)
    if item:isBound() and not currentInv:isBoundToOwner(item.owner) then
        return false, "This item is bound to another player and cannot be transferred."
    end
    return true
end)
```
    
---
### **ItemDraggedOutOfInventory**
**Description:**  
Called when an item is dragged out of an inventory.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `item` (Item)
    
**Example Usage:**
```lua
hook.Add("ItemDraggedOutOfInventory", "LogItemDrag", function(client, item)
    lia.log.write("ItemDrag", client:Name() .. " dragged item ID " .. item.id .. " out of inventory.")
    print(client:Name() .. " has dragged out item:", item.name)
end)
```
    
---
### **ItemTransfered**
**Description:**  
Called when an item is transferred between inventories.
    
**Realm:** 
`Server`
    
**Parameters:**
- `context` (table)
    
**Example Usage:**
```lua
hook.Add("ItemTransfered", "TrackItemTransfers", function(context)
    local client = context.client
    local item = context.item
    local fromInv = context.fromInv
    local toInv = context.toInv
    lia.log.write("ItemTransfer", client:Name() .. " transferred item " .. item.name .. " from " .. fromInv:getName() .. " to " .. toInv:getName())
    print(client:Name() .. " transferred item:", item.name, "from", fromInv:getName(), "to", toInv:getName())
end)
```
    
---
### **OnPlayerLostStackItem**
**Description:**  
Called when a player drops a stackable item.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `itemTypeOrItem`
    
**Example Usage:**
```lua
hook.Add("OnPlayerLostStackItem", "HandleStackItemDrop", function(itemTypeOrItem)
    local itemName = type(itemTypeOrItem) == "table" and itemTypeOrItem.name or "Unknown Item"
    lia.log.write("StackItemDrop", "A stackable item was dropped: " .. itemName)
    print("Player dropped a stackable item:", itemName)
end)
```
    
---
### **CanPlayerSpawnStorage**
**Description:**  
Whether a player is allowed to spawn a container entity.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `entity` (`Entity`)
- `data` (table)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerSpawnStorage", "RestrictStorageSpawn", function(client, entity, data)
    if client:getLevel() < 10 then
        client:ChatPrint("You need to be at least level 10 to spawn storage containers.")
        return false
    end
    return true
end)
```
    
---
### **isSuitableForTrunk**
**Description:**  
Determines whether an entity is suitable for use as storage (e.g., a trunk).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `entity` (`Entity`)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("isSuitableForTrunk", "AllowOnlyCars", function(entity)
    return entity:IsVehicle() -- Only vehicles are suitable for trunks
end)
```
    
---
### **OnCreateStoragePanel**
**Description:**  
Called when a storage panel is created (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `localInvPanel` (panel)
- `storageInvPanel` (panel)
- `storage` (entity)
    
**Example Usage:**
```lua
hook.Add("OnCreateStoragePanel", "CustomizeStorageUI", function(localInvPanel, storageInvPanel, storage)
    storageInvPanel:SetBackgroundColor(Color(50, 50, 50, 200))
    storageInvPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 150))
        draw.SimpleText("Storage Contents", "DermaLarge", w / 2, 10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    print("Storage panel customized for entity:", storage:GetClass())
end)
```
    
---
### **CanSaveData**
**Description:**  
Determines whether data associated with a storage entity should be saved.
    
**Realm:** 
`Server`
    
**Parameters:**
- `entity` (`Entity`)
- `inventory` (Inventory)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanSaveData", "ExcludeTemporaryStorages", function(entity, inventory)
    if entity:isTemporary() then
        return false -- Do not save data for temporary storage entities
    end
    return true
end)
```
    
---
### **StorageRestored**
**Description:**  
Called when a storage entity is restored.
    
**Realm:** 
`Server`
    
**Parameters:**
- `storage` (`Entity`)
- `inventory` (Inventory)
    
**Example Usage:**
```lua
hook.Add("StorageRestored", "ReinitializeStorage", function(storage, inventory)
    storage:setOwner(inventory:getOwner())
    print("Storage entity restored and owner set for:", storage:GetClass())
end)
```
    
---
### **StorageOpen**
**Description:**  
Called when a storage is opened (car trunk or other).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `entity` (`Entity`)
- `isCar` (`bool`)
    
**Example Usage:**
```lua
hook.Add("StorageOpen", "LogStorageAccess", function(entity, isCar)
    if isCar then
        print("Car trunk opened:", entity:GetModel())
    else
        print("Storage container opened:", entity:GetClass())
    end
    -- Apply access rules or permissions
end)
```
    
---
### **StorageUnlockPrompt**
**Description:**  
Called when a prompt to unlock storage is displayed (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `entity` (`Entity`)
    
**Example Usage:**
```lua
hook.Add("StorageUnlockPrompt", "CustomizeUnlockPrompt", function(entity)
    local prompt = vgui.Create("DFrame")
    prompt:SetTitle("Unlock Storage")
    prompt:SetSize(300, 150)
    prompt:Center()
    prompt:MakePopup()

    local passwordBox = vgui.Create("DTextEntry", prompt)
    passwordBox:SetPos(50, 50)
    passwordBox:SetSize(200, 30)
    passwordBox:SetText("Enter Password")

    local unlockButton = vgui.Create("DButton", prompt)
    unlockButton:SetText("Unlock")
    unlockButton:SetPos(100, 100)
    unlockButton:SetSize(100, 30)
    unlockButton.DoClick = function()
        local password = passwordBox:GetValue()
        lia.netstream.Start("AttemptStorageUnlock", entity, password)
        prompt:Close()
    end

    print("Storage unlock prompt displayed for entity:", entity:GetClass())
end)
```
    
---
### **StorageCanTransferItem**
**Description:**  
Determines whether a player can transfer an item into storage.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `storage` (`Entity`)
- `item` (Item)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("StorageCanTransferItem", "RestrictItemTypesInStorage", function(client, storage, item)
    if item.category == "Weapon" and not client:hasPermission("store_weapons") then
        return false -- Prevent storing weapons unless player has permission
    end
    return true
end)
```
    
---
### **StorageEntityRemoved**
**Description:**  
Called when a storage entity is removed.
    
**Realm:** 
`Server`
    
**Parameters:**
- `entity` (`Entity`)
- `inventory` (Inventory)
    
**Example Usage:**
```lua
hook.Add("StorageEntityRemoved", "HandleStorageRemoval", function(entity, inventory)
    lia.data.remove("storage_" .. entity:EntIndex())
    print("Storage entity removed and data cleaned for:", entity:GetClass())
end)
```
    
---
### **StorageInventorySet**
**Description:**  
Called when the inventory of a storage entity is set.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `entity` (`Entity`)
- `inventory` (Inventory)
- `isInitial` (`bool`)
    
**Example Usage:**
```lua
hook.Add("StorageInventorySet", "InitializeStorageInventory", function(entity, inventory, isInitial)
    if isInitial then
        inventory:setOwner(entity:getOwner())
        lia.log.write("StorageInventorySet", "Initial inventory set for storage ID: " .. entity:EntIndex())
        print("Initial inventory set for storage:", entity:GetClass())
    else
        lia.log.write("StorageInventorySet", "Inventory updated for storage ID: " .. entity:EntIndex())
        print("Inventory updated for storage:", entity:GetClass())
    end
end)
```
    
---
### **isCharRecognized**
**Description:**  
Checks if a character is recognized.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `character` (Character)
- `id` (int)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("isCharRecognized", "ValidateCharacterRecognition", function(character, id)
    if character:getID() == id and character:isActive() then
        return true
    end
    return false
end)
```
    
---
### **isCharFakeRecognized**
**Description:**  
Checks if a character is *fake* recognized.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `character` (Character)
- `id` (int)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("isCharFakeRecognized", "DetectFakeCharacters", function(character, id)
    if character:isSuspicious() then
        return true -- Character is fake
    end
    return false
end)
```
    
---
### **isFakeNameExistant**
**Description:**  
Checks if a fake name exists in a given name list.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `name` (string)
- `nameList` (table)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("isFakeNameExistant", "PreventDuplicateFakeNames", function(name, nameList)
    for _, existingName in ipairs(nameList) do
        if string.lower(existingName) == string.lower(name) then
            return true
        end
    end
    return false
end)
```
    
---
### **OnCharRecognized**
**Description:**  
Called when a character is recognized.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `id` (int)
    
**Example Usage:**
```lua
hook.Add("OnCharRecognized", "WelcomeRecognizedCharacter", function(client, id)
    local character = lia.character.getByID(id)
    if character then
        client:ChatPrint("Welcome back, " .. character:getName() .. "!")
        lia.notifications.send(client, "Character recognized: " .. character:getName(), Color(0,255,0))
        print("Character recognized for client:", client:Name())
    end
end)
```
    
---
### **CharRecognize**
**Description:**  
Initiates a character recognition process (client side).
    
**Realm:** 
`Client`
    
**Parameters:**
- `level` (int)
- `name` (string)
    
**Example Usage:**
```lua
hook.Add("CharRecognize", "StartRecognitionProcess", function(level, name)
    local recognitionPanel = lia.ui.createRecognitionPanel(level, name)
    recognitionPanel:open()
    print("Recognition process started for:", name, "at level:", level)
end)
```
    
---
### **GetDisplayedDescription**
**Description:**  
Retrieves the displayed description of an entity (HUD or otherwise).
    
**Realm:** 
`Shared`
    
**Parameters:**
- `entity` (`Entity`)
- `isHUD` (`bool`)
    
**Returns:**
- `string`
    
**Example Usage:**
```lua
hook.Add("GetDisplayedDescription", "CustomEntityDescription", function(entity, isHUD)
    if entity:GetClass() == "npc_boss" then
        return "The formidable boss of the region. Handle with care."
    end
end)
```
    
---
### **GetDisplayedName (Recognition)**
*(Separate from the chat-based version.)*  
**Description:**  
Retrieves a displayed name for a client/character in a recognition context.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `chatType` (`string`) or other context param
    
**Returns:**
- `string`
    
**Example Usage:**
```lua
hook.Add("GetDisplayedName", "RecognitionNameTag", function(client, chatType)
    if chatType == "recognition" and client:isRecognized() then
        return "[Recognized] " .. client:Name()
    end
end)
```
    
---
### **isRecognizedChatType**
**Description:**  
Determines if a chat type is recognized by the recognition system.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `chatType` (string)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("isRecognizedChatType", "ValidateRecognitionChat", function(chatType)
    local recognizedTypes = {"admin", "system", "recognition"}
    return table.HasValue(recognizedTypes, chatType)
end)
```
    
---
### **GetSalaryLimit**
**Description:**  
Retrieves the salary limit for a player.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `faction` (table)
- `class` (table)
    
**Returns:**
- `any`: The salary limit
    
**Example Usage:**
```lua
hook.Add("GetSalaryLimit", "SetSalaryLimitsBasedOnRole", function(client, faction, class)
    if faction.name == "Police" then
        return 5000 -- Police have a higher salary limit
    elseif faction.name == "Citizen" then
        return 2000
    end
end)
```
    
---
### **GetSalaryAmount**
**Description:**  
Retrieves the amount of salary a player should receive.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `faction` (table)
- `class` (table)
    
**Returns:**
- `any`: The salary amount
    
**Example Usage:**
```lua
hook.Add("GetSalaryAmount", "CalculateDynamicSalary", function(client, faction, class)
    local baseSalary = faction.baseSalary or 1000
    local classBonus = class.salaryBonus or 0
    return baseSalary + classBonus
end)
```
    
---
### **CanPlayerEarnSalary**
**Description:**  
Determines if a player is allowed to earn salary.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `faction` (table)
- `class` (table)
    
**Returns:**
- `bool`
    
**Example Usage:**
```lua
hook.Add("CanPlayerEarnSalary", "RestrictSalaryToActivePlayers", function(client, faction, class)
    if not client:isActive() then
        return false -- Inactive players do not earn salary
    end
    return true
end)
```
    
---
### **CreateSalaryTimer**
**Description:**  
Creates a timer to manage player salary.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
    
**Example Usage:**
```lua
hook.Add("CreateSalaryTimer", "SetupSalaryTimer", function(client)
    timer.Create("SalaryTimer_" .. client:SteamID(), 60, 0, function()
        if IsValid(client) and MODULE:CanPlayerEarnSalary(client, client:getFaction(), client:getClass()) then
            local salary = MODULE:GetSalaryAmount(client, client:getFaction(), client:getClass())
            client:addMoney(salary)
            client:ChatPrint("You have received your salary of $" .. salary)
            print("Salary of $" .. salary .. " awarded to:", client:Name())
        end
    end)
    print("Salary timer created for:", client:Name())
end)
```

---
### **CanPlayerUseChar**
**Description:**  
Checks if a player is allowed to use a specific character.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
    
**Returns:**
- `bool`
- `string|nil` (Reason if disallowed)
    
**Example Usage:**
```lua
hook.Add("CanPlayerUseChar", "RestrictCharacterUsage", function(client, character)
    if character:isBanned() then
        return false, "This character is banned from use."
    end
    return true
end)
```
    
---
### **CanPlayerCreateChar**
**Description:**  
Whether a player can create a new character.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `bool` (`false` to disallow)
- `string` (Lang phrase or reason)
- `...` (Args for the phrase)
    
**Example Usage:**
```lua
hook.Add("CanPlayerCreateChar", "LimitCharacterCreation", function(client)
    if client:getCharacterCount() >= MODULE:GetMaxPlayerChar(client) then
        return false, "You have reached the maximum number of characters."
    end
    return true
end)
```
    
---
### **PostCharDelete**
**Description:**  
Called after a character is deleted.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("PostCharDelete", "NotifyCharacterDeletion", function(client, character)
    lia.notifications.broadcast(client:Name() .. " has deleted their character: " .. character:getName())
    print("Character deleted:", character:getName(), "by", client:Name())
end)
```
    
---
### **GetMaxPlayerChar**
**Description:**  
Retrieves the max number of characters a player can have.
    
**Realm:** 
`Shared`
    
**Parameters:**
- `client` (`Player`)
    
**Returns:**
- `int`
    
**Example Usage:**
```lua
hook.Add("GetMaxPlayerChar", "SetMaxCharacters", function(client)
    if client:isPremium() then
        return 5 -- Premium players can have up to 5 characters
    else
        return 3 -- Regular players can have up to 3 characters
    end
end)
```
    
---
### **CharDeleted**
*(Synonym to OnCharDelete or PostCharDelete in some code.)*  
**Description:**  
Called after a character is deleted.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("CharDeleted", "LogCharacterDeletion", function(client, character)
    lia.log.write("CharDeleted", "Character " .. character:getName() .. " deleted by " .. client:Name())
    print("Character deleted:", character:getName(), "by", client:Name())
end)
```
    
---
### **PrePlayerLoadedChar**
**Description:**  
Called before a player's character is loaded.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
- `currentChar` (Character)
    
**Example Usage:**
```lua
hook.Add("PrePlayerLoadedChar", "PrepareForCharacterLoad", function(client, character, currentChar)
    if currentChar then
        client:saveCurrentCharacter()
        print("Saved current character before loading new one for:", client:Name())
    end
end)
```
    
---
### **PlayerLoadedChar**
**Description:**  
Called when a player's character is loaded.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
- `currentChar` (Character)
    
**Example Usage:**
```lua
hook.Add("PlayerLoadedChar", "InitializeNewCharacter", function(client, character, currentChar)
    client:SetHealth(character:getHealth())
    client:SetArmor(character:getArmor())
    print("Loaded character:", character:getName(), "for player:", client:Name())
end)
```
    
---
### **PostPlayerLoadedChar**
**Description:**  
Called after a player's character is loaded.
    
**Realm:** 
`Server`
    
**Parameters:**
- `client` (`Player`)
- `character` (Character)
- `currentChar` (Character)
    
**Example Usage:**
```lua
hook.Add("PostPlayerLoadedChar", "WelcomeCharacter", function(client, character, currentChar)
    client:ChatPrint("Welcome back, " .. character:getName() .. "!")
    lia.notifications.send(client, "Character " .. character:getName() .. " loaded successfully.", Color(0, 255, 0))
    print("Post-load welcome sent to:", client:Name())
end)
```
    
---
### **CharLoaded**
**Description:**  
Called after a character has been successfully loaded (sometimes shared realm usage).
    
**Realm:** 
`Shared` or `Server`
    
**Parameters:**
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("CharLoaded", "InitializeCharacterSkills", function(character)
    character:initSkills()
    print("Skills initialized for character:", character:getName())
end)
```
    
---
### **CharPostSave**
**Description:**  
Called after a character is saved.
    
**Realm:** 
`Server`
    
**Parameters:**
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("CharPostSave", "NotifyCharacterSaved", function(character)
    lia.notifications.sendAdmins("Character " .. character:getName() .. " has been saved.")
    print("Character saved:", character:getName())
end)
```
    
---
### **CharPreSave**
**Description:**  
Called before a character is saved.
    
**Realm:** 
`Shared` (or `Server`, depending on the usage)
    
**Parameters:**
- `character` (Character)
    
**Example Usage:**
```lua
hook.Add("CharPreSave", "ValidateCharacterBeforeSave", function(character)
    if not character:isValid() then
        return false, "Character is invalid and cannot be saved."
    end
    -- Perform additional validations or modifications
    character:calculateDerivedStats()
    print("Character validated and modified before save:", character:getName())
end)
```
    











    
---

### **F1OnAddSection**
**Description:**  
Called when adding a new section to the F1 menu. Allows customization of sections within the help or character menu.

**Realm:** 
`Client`

**Parameters:**
- `sectionName` (`string`): The name identifier of the section.
- `color` (`Color`): The color associated with the section.
- `priority` (`number`): The priority/order of the section in the menu.

**Example Usage:**
```lua
hook.Add("F1OnAddSection", "AddSettingsSection", function(sectionName, color, priority)
    if sectionName == "settings" then
        color = Color(0, 128, 255)
        priority = 5
        print("Settings section customized.")
    end
end)
```

---
    
### **F1OnAddTextField**
**Description:**  
Called when adding a text field to a section in the F1 menu. Allows adding customizable input fields to the menu.

**Realm:** 
`Client`

**Parameters:**
- `sectionName` (`string`): The name identifier of the section to add the text field to.
- `fieldName` (`string`): The unique identifier for the text field.
- `labelText` (`string`): The label displayed for the text field.
- `valueFunc` (`function`): A function that returns the current value of the text field.

**Returns:**
- `nil` or custom behavior.

**Example Usage:**
```lua
hook.Add("F1OnAddTextField", "AddNicknameField", function(sectionName, fieldName, labelText, valueFunc)
    if sectionName == "character" then
        fieldName = "nickname"
        labelText = "Nickname"
        valueFunc = function()
            return LocalPlayer():getChar():getNickname()
        end
        print("Nickname text field added to character section.")
    end
end)
```

---
    
### **F1OnAddBarField**
**Description:**  
Called when adding a bar field (e.g., progress bar) to a section in the F1 menu. Allows adding customizable visual bars to represent data like health, stamina, etc.

**Realm:** 
`Client`

**Parameters:**
- `sectionName` (`string`): The name identifier of the section to add the bar field to.
- `fieldName` (`string`): The unique identifier for the bar field.
- `labelText` (`string`): The label displayed for the bar field.
- `minFunc` (`function`): A function that returns the minimum value of the bar.
- `maxFunc` (`function`): A function that returns the maximum value of the bar.
- `valueFunc` (`function`): A function that returns the current value of the bar.

**Returns:**
- `nil` or custom behavior.

**Example Usage:**
```lua
hook.Add("F1OnAddBarField", "AddHealthBar", function(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    if sectionName == "stats" then
        fieldName = "health"
        labelText = "Health"
        minFunc = function()
            return 0
        end
        maxFunc = function()
            return 100
        end
        valueFunc = function()
            return LocalPlayer():getChar():getHealth()
        end
        print("Health bar added to stats section.")
    end
end)
```

---
    
### **CanPlayerViewCommands**
**Description:**  
Determines if a player is allowed to view the list of available commands. Return `false` to hide the commands.

**Realm:** 
`Client`

**Returns:**
- `bool`: `false` to block, `nil` or `true` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerViewCommands", "HideCommandsForRegularPlayers", function()
    if not LocalPlayer():isAdmin() then
        return false -- Hide commands for non-admin players
    end
end)
```

---
    
### **CharListLoaded**
**Description:**  
Called when the character list has been fully loaded for a player. Useful for performing actions after all characters are available.

**Realm:** 
`Server`

**Parameters:**
- `newCharList` (`table`): The updated list of characters for the player.

**Example Usage:**
```lua
hook.Add("CharListLoaded", "InitializeCharacterUI", function(newCharList)
    lia.ui.initializeCharacterSelection(newCharList)
    print("Character list loaded and UI initialized.")
end)
```

---
    
### **CanPlayerSwitchChar**
**Description:**  
Determines if a player can switch from their current character to another character. Return `false` to prevent the switch.

**Realm:** 
`Shared`

**Parameters:**
- `client` (`Player`): The player attempting to switch characters.
- `currentChar` (`Character`): The player's current character.
- `character` (`Character`): The character the player is attempting to switch to.

**Returns:**
- `bool|nil`: `false` to block, `nil` or `true` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerSwitchChar", "PreventSwitchDuringCombat", function(client, currentChar, character)
    if client:isInCombat() then
        client:ChatPrint("You cannot switch characters while in combat.")
        return false
    end
end)
```

---
    
### **OnCharCreated**
**Description:**  
Called after a new character has been successfully created. Allows for additional setup or initialization of the new character.

**Realm:** 
`Server`

**Parameters:**
- `client` (`Player`): The player who created the character.
- `character` (`Character`): The newly created character.
- `originalData` (`table`): The data provided during character creation.

**Example Usage:**
```lua
hook.Add("OnCharCreated", "SetupInitialInventory", function(client, character, originalData)
    local inventory = character:getInv()
    inventory:addItem("starter_pack")
    inventory:addItem("basic_weapon")
    print("Initial inventory setup for new character:", character:getName())
end)
```

---
    
### **AdjustCreationData**
**Description:**  
Allows modifying or adding extra data steps in the character creation process on the server side. Can be used to inject custom data into character creation.

**Realm:** 
`Server`

**Parameters:**
- `client` (`Player`): The player creating the character.
- `data` (`table`): The original data being used for character creation.
- `newData` (`table`): The new data that can be modified.
- `originalData` (`table`): The unmodified original data.

**Example Usage:**
```lua
hook.Add("AdjustCreationData", "IncludeSkillPoints", function(client, data, newData, originalData)
    newData.skillPoints = 10
    print("Skill points added to character creation data.")
end)
```

---
    
### **DrawCharInfo**
**Description:**  
Called to draw information about a character, such as stats or status effects, within the UI.

**Realm:** 
`Client`

**Parameters:**
- `entity` (`Entity`): The entity associated with the character.
- `character` (`Character`): The character whose info is being drawn.
- `charInfo` (`table`): A table containing character information to be displayed.

**Example Usage:**
```lua
hook.Add("DrawCharInfo", "DisplayCharacterStats", function(entity, character, charInfo)
    draw.SimpleText("Strength: " .. character:getAttribute("strength"), "Default", 10, 10, Color(255,255,255))
    draw.SimpleText("Agility: " .. character:getAttribute("agility"), "Default", 10, 30, Color(255,255,255))
    print("Character stats drawn for:", character:getName())
end)
```

---
    
### **GetInjuredText**
**Description:**  
Called to retrieve the text displayed when a player is injured. Allows customization of injury messages.

**Realm:** 
`Shared`

**Parameters:**
- `client` (`Player`): The player who is injured.
- `isSevere` (`bool`): Whether the injury is severe.

**Returns:**
- `string`: The injury message to display.

**Example Usage:**
```lua
hook.Add("GetInjuredText", "CustomInjuryMessage", function(client)
    if isSevere then
        return "You are critically injured! Seek medical attention immediately."
    else
        return "You are hurt but can continue."
    end
end)
```

---
    
### **GetWeaponName**
**Description:**  
Called to retrieve the display name for a weapon. Allows customization of weapon names in the UI.

**Realm:** 
`Shared`

**Parameters:**
- `weapon` (`Entity` or `table`): The weapon entity or table for which the name is being retrieved.

**Returns:**
- `string|nil`: A custom weapon name, or `nil` to use the default.

**Example Usage:**
```lua
hook.Add("GetWeaponName", "RenameAK47", function(weapon)
    if weapon:GetClass() == "weapon_ak47" then
        return "Assault Rifle AK-47"
    end
end)
```

---
    
### **WeaponCycleSound**
**Description:**  
Called when a player cycles through their weapons, allowing custom sounds to be played.

**Realm:** 
`Shared`

**Parameters:**
- None directly, but could include context in some implementations.

**Returns:**
- `bool|nil`: Can be used to prevent default sound if handled.

**Example Usage:**
```lua
hook.Add("WeaponCycleSound", "PlayCustomCycleSound", function()
    print("Custom weapon cycle sound played.")
    return "custom/sounds/weapon_cycle.wav"
end)
```

---
    
### **CanPlayerChooseWeapon**
**Description:**  
Determines if a player is allowed to choose a specific weapon. Return `false` to block weapon selection.

**Realm:** 
`Shared`

**Parameters:**
- `weapon` (`Entity` or `table`): The weapon being selected.

**Returns:**
- `bool`: `false` to block, `nil` or `true` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerChooseWeapon", "RestrictWeaponChoiceForNovices", function()
    if LocalPlayer():getLevel() < 5 then
        return false -- Prevent weapon choice for players below level 5
    end
end)
```

---
    
### **WeaponSelectSound**
**Description:**  
Called when a weapon is selected, allowing custom sounds to be played.

**Realm:** 
`Shared`

**Parameters:**
- `weapon` (`Entity` or `table`): The weapon being selected.

**Returns:**
- `bool|nil`: `false` to block default sound, or `nil` to allow.

**Example Usage:**
```lua
hook.Add("WeaponSelectSound", "CustomSelectSound", function(weapon)
    surface.PlaySound("custom/sounds/weapon_select.wav")
    print("Custom weapon select sound played.")
    return true -- Prevent default sound
end)
```

---

### **CanPlayerUseDoor**
**Description:**  
Determines if a player is allowed to use a door entity, such as opening, locking, or unlocking. Return `false` to prevent the action.

**Realm:** 
`Server`

**Parameters:**
- `client` (`Player`): The player attempting to use the door.
- `door` (`Entity`): The door entity being used.
- `access` (`int`): The type of access attempted (e.g., `DOOR_LOCK`).

**Returns:**
- `bool`: `false` to block, `nil` or `true` to allow.

**Example Usage:**
```lua
hook.Add("CanPlayerUseDoor", "AllowOnlyOwners", function(client, door, access)
    if access == DOOR_LOCK and door:getOwner() ~= client then
        return false -- Only the owner can lock the door
    end
    return true
end)
```
---
    
### **PlayerAccessVendor**
**Description:**  
Called when a player accesses a vendor. Useful for tracking access or applying additional logic upon access.

**Realm:** 
`Server`

**Parameters:**
- `activator` (`Player`): The player accessing the vendor.
- `self` (`Entity`): The vendor entity being accessed.

**Example Usage:**
```lua
hook.Add("PlayerAccessVendor", "TrackVendorAccess", function(activator, vendor)
    lia.log.write("VendorAccess", activator:Name() .. " accessed vendor " .. vendor:GetClass())
    lia.stats.increment(activator, "vendor_accesses")
    print(activator:Name() .. " has accessed vendor:", vendor:GetClass())
end)
```

---
    
### **getPriceOverride**
**Description:**  
Gets the price override for an item in a vendor's inventory. Allows dynamic pricing based on item, vendor, or other conditions.

**Realm:** 
`Shared`

**Parameters:**
- `vendor` (`Entity`): The vendor entity.
- `uniqueID` (`string`): The unique identifier of the item.
- `price` (`int`): The base price of the item.
- `isSellingToVendor` (`bool`): `true` if the player is selling to the vendor, `false` if buying from the vendor.

**Returns:**
- `int|nil`: The overridden price, or `nil` to use the default.

**Example Usage:**
```lua
hook.Add("getPriceOverride", "DynamicPricing", function(vendor, uniqueID, price, isSellingToVendor)
    if uniqueID == "rare_item" then
        if isSellingToVendor then
            return price * 0.75 -- Vendor buys at 75% of base price
        else
            return price * 1.25 -- Vendor sells at 125% of base price
        end
    end
end)
```    

---
    
### **thirdPersonToggled**
**Description:**  
Called when third-person mode is toggled on or off. Allows for custom handling of third-person mode changes.

**Realm:** 
`Client`

**Parameters:**
- `state` (`bool`): `true` if third-person is enabled, `false` if disabled.

**Example Usage:**
```lua
hook.Add("thirdPersonToggled", "NotifyThirdPersonChange", function(state)
    if state then
        chat.AddText(Color(0,255,0), "Third-person view enabled.")
    else
        chat.AddText(Color(255,0,0), "Third-person view disabled.")
    end
    print("Third-person mode toggled to:", state)
end)
```
---

