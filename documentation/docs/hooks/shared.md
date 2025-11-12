# Shared Hooks

Shared hook system for the Lilia framework.

---

Overview

Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.

---

### AdjustStaminaOffset

#### 📋 Purpose
Allows modification of stamina regeneration/drain offset for a player

#### ⏰ When Called
During stamina calculation, allowing custom stamina modifiers

#### ↩️ Returns
* number - The modified stamina offset, or nil to use original offset

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Increase stamina regeneration
    hook.Add("AdjustStaminaOffset", "MyAddon", function(client, offset)
        if offset > 0 then -- Only modify regeneration, not drain
            return offset * 1.5 -- 50% faster regeneration
        end
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Modify stamina based on character attributes
    hook.Add("AdjustStaminaOffset", "AttributeStamina", function(client, offset)
        local char = client:getChar()
        if not char then return end
        local con = char:getAttrib("con", 0) -- Constitution attribute
        if offset > 0 then -- Regeneration
            return offset * (1 + con * 0.1) -- 10% bonus per constitution point
        else -- Drain
            return offset * (1 - con * 0.05) -- 5% less drain per constitution point
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex stamina system with multiple factors
    hook.Add("AdjustStaminaOffset", "AdvancedStamina", function(client, offset)
        local char = client:getChar()
        if not char then return end
        local modifiers = {
            regeneration = 1.0,
            drain       = 1.0
        }
        -- Constitution bonus
        local con = char:getAttrib("con", 0)
        modifiers.regeneration = modifiers.regeneration + (con * 0.1)
        modifiers.drain = modifiers.drain - (con * 0.05)
        -- Faction bonuses
        local faction = char:getFaction()
        if faction == "athlete" then
            modifiers.regeneration = modifiers.regeneration + 0.3
            modifiers.drain = modifiers.drain - 0.2
        elseif faction == "elderly" then
            modifiers.regeneration = modifiers.regeneration - 0.2
            modifiers.drain = modifiers.drain + 0.3
        end
        -- Equipment bonuses
        local items = char:getInv()
        for _, item in pairs(items) do
            if item.uniqueID == "stamina_boost" then
                modifiers.regeneration = modifiers.regeneration + 0.5
            elseif item.uniqueID == "heavy_armor" then
                modifiers.drain = modifiers.drain + 0.3
            end
        end
        -- Apply modifiers
        if offset > 0 then
            return offset * modifiers.regeneration
        else
            return offset * modifiers.drain
        end
    end)

```

---

### CanOutfitChangeModel

#### 📋 Purpose
Called to check if an outfit can change model

#### ⏰ When Called
When attempting to change a player's model via outfit

#### ↩️ Returns
* boolean - True to allow, false to deny

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Always allow
    hook.Add("CanOutfitChangeModel", "MyAddon", function(self)
        return true
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check faction restrictions
    hook.Add("CanOutfitChangeModel", "OutfitModelCheck", function(self)
        local client = self.player
        if not client then return false end
        local char = client:getChar()
        if not char then return false end
        local allowedFactions = self.allowedFactions
        if allowedFactions and not table.HasValue(allowedFactions, char:getFaction()) then
            return false
        end
        return true
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex outfit model system
    hook.Add("CanOutfitChangeModel", "AdvancedOutfitModel", function(self)
        local client = self.player
        if not client then return false end
        local char = client:getChar()
        if not char then return false end
        -- Check faction restrictions
        local allowedFactions = self.allowedFactions
        if allowedFactions and not table.HasValue(allowedFactions, char:getFaction()) then
            if SERVER then
                client:ChatPrint("Your faction cannot wear this outfit")
            end
            return false
        end
        -- Check level requirements
        local requiredLevel = self.requiredLevel or 0
        local charLevel = char:getData("level", 1)
        if charLevel < requiredLevel then
            if SERVER then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to wear this outfit")
            end
            return false
        end
        return true
    end)

```

---

### CommandAdded

#### 📋 Purpose
Called when a command is added

#### ⏰ When Called
When a new command is registered to the framework

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log command additions
    hook.Add("CommandAdded", "MyAddon", function(command, data)
        print("Command added: " .. command)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track registered commands
    hook.Add("CommandAdded", "CommandTracking", function(command, data)
        lia.commandList = lia.commandList or {}
        table.insert(lia.commandList, command)
        print("Command " .. command .. " registered")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex command registration tracking
    hook.Add("CommandAdded", "AdvancedCommandTracking", function(command, data)
        -- Track command registration
        lia.commandList = lia.commandList or {}
        table.insert(lia.commandList, {
            name = command,
            data = data,
            registeredAt = os.time()
        })
        -- Log command details
        print(string.format("Command registered: %s (Admin: %s, Syntax: %s)",
            command,
            tostring(data.adminOnly or false),
            data.syntax or "N/A"))
    end)

```

---

### DoModuleIncludes

#### 📋 Purpose
Called when doing module includes

#### ⏰ When Called
When a module is being loaded and files are being included

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log module includes
    hook.Add("DoModuleIncludes", "MyAddon", function(path, MODULE)
        print("Including: " .. path)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track module load times
    hook.Add("DoModuleIncludes", "ModuleLoadTime", function(path, MODULE)
        local startTime = SysTime()
        timer.Simple(0, function()
            local loadTime = SysTime() - startTime
            print("Loaded " .. path .. " in " .. loadTime .. "s")
        end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex module loading system
    hook.Add("DoModuleIncludes", "AdvancedModuleLoading", function(path, MODULE)
        local startTime = SysTime()
        -- Log module loading
        print("Loading module: " .. (MODULE.name or "Unknown") .. " from " .. path)
        -- Track dependencies
        local dependencies = MODULE.dependencies or {}
        for _, dep in ipairs(dependencies) do
            print("  Dependency: " .. dep)
        end
        -- Measure load time
        timer.Simple(0, function()
            local loadTime = SysTime() - startTime
            print("Loaded " .. (MODULE.name or "Unknown") .. " in " .. loadTime .. "s")
            -- Store load statistics
            lia.moduleLoadTimes = lia.moduleLoadTimes or {}
            lia.moduleLoadTimes[MODULE.name or path] = loadTime
        end)
    end)

```

---

### GetDisplayedDescription

#### 📋 Purpose
Called to get displayed description

#### ⏰ When Called
When showing a player's description

#### ↩️ Returns
* string - The modified description

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return unchanged
    hook.Add("GetDisplayedDescription", "MyAddon", function(ply, description)
        return description
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add faction prefix
    hook.Add("GetDisplayedDescription", "FactionDescPrefix", function(ply, description)
        local char = ply:getChar()
        if char then
            local faction = char:getFaction()
            return "[" .. faction .. "] " .. description
        end
        return description
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex description formatting
    hook.Add("GetDisplayedDescription", "AdvancedDescDisplay", function(ply, description)
        local char = ply:getChar()
        if not char then return description end
        -- Add faction and rank
        local faction = char:getFaction()
        local rank = char:getData("rank", 0)
        local rankName = char:getData("rankName", "Recruit")
        local prefix = string.format("[%s - %s] ", faction, rankName)
        -- Add status indicators
        if char:getData("injured", false) then
            prefix = prefix .. "[INJURED] "
        end
        if char:getData("wanted", false) then
            prefix = prefix .. "[WANTED] "
        end
        return prefix .. description
    end)

```

---

### GetDisplayedName

#### 📋 Purpose
Called to get displayed name in chat

#### ⏰ When Called
When showing a player's name in chat

#### ↩️ Returns
* string - The displayed name

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return character name
    hook.Add("GetDisplayedName", "MyAddon", function(speaker, chatType)
        local char = speaker:getChar()
        return char and char:getName() or speaker:Name()
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Chat type-specific names
    hook.Add("GetDisplayedName", "ChatTypeNames", function(speaker, chatType)
        local char = speaker:getChar()
        if not char then return speaker:Name() end
        if chatType == "ooc" then
            return speaker:Name()
        else
            return char:getName()
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex name display system
    hook.Add("GetDisplayedName", "AdvancedNameDisplay", function(speaker, chatType)
        local char = speaker:getChar()
        if not char then return speaker:Name() end
        -- OOC shows Steam name
        if chatType == "ooc" then
            return speaker:Name()
        end
        -- IC shows character name with title
        local name = char:getName()
        local faction = char:getFaction()
        -- Add faction title
        if faction == "police" then
            local rank = char:getData("rankName", "Officer")
            name = rank .. " " .. name
        elseif faction == "medic" then
            name = "Dr. " .. name
        end
        -- Add status indicators
        if speaker:IsAdmin() then
            name = "[ADMIN] " .. name
        end
        return name
    end)

```

---

### GetDoorInfo

#### 📋 Purpose
Called to get door information

#### ⏰ When Called
When retrieving door data

#### ↩️ Returns
* table - The modified door info

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return unchanged
    hook.Add("GetDoorInfo", "MyAddon", function(entity, doorData, doorInfo)
        return doorInfo
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add custom door info
    hook.Add("GetDoorInfo", "CustomDoorInfo", function(entity, doorData, doorInfo)
        doorInfo.customField = "Custom Value"
        doorInfo.price = entity:getNetVar("price", 0)
        return doorInfo
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex door info system
    hook.Add("GetDoorInfo", "AdvancedDoorInfo", function(entity, doorData, doorInfo)
        -- Add basic info
        doorInfo.price = entity:getNetVar("price", 0)
        doorInfo.title = entity:getNetVar("title", "Door")
        doorInfo.owner = entity:getNetVar("owner")
        doorInfo.locked = entity:getNetVar("locked", false)
        -- Add owner name
        if doorInfo.owner then
            local ownerChar = lia.char.loaded[doorInfo.owner]
            if ownerChar then
                doorInfo.ownerName = ownerChar:getName()
            end
        end
        -- Add faction restrictions
        local allowedFactions = entity:getNetVar("allowedFactions", {})
        if #allowedFactions > 0 then
            doorInfo.factionRestricted = true
            doorInfo.allowedFactions = allowedFactions
        end
        return doorInfo
    end)

```

---

### GetModelGender

#### 📋 Purpose
Called to get model gender

#### ⏰ When Called
When determining a model's gender

#### ↩️ Returns
* string - "male" or "female"

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return default gender
    hook.Add("GetModelGender", "MyAddon", function(model)
        return "male"
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check model path
    hook.Add("GetModelGender", "ModelGenderCheck", function(model)
        if string.find(model, "female") then
            return "female"
        end
        return "male"
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex gender detection
    hook.Add("GetModelGender", "AdvancedGenderDetection", function(model)
        -- Check for female keywords
        local femaleKeywords = {"female", "woman", "girl", "alyx" }
        for _, keyword in ipairs(femaleKeywords) do
            if string.find(string.lower(model), keyword) then
                return "female"
            end
        end
        -- Check specific models
        local femaleModels = {
            ["models/player/alyx.mdl"]    = true,
            ["models/player/mossman.mdl"]  = true
        }
        if femaleModels[model] then
            return "female"
        end
        return "male"
    end)

```

---

### InitializedConfig

#### 📋 Purpose
Called when configuration is initialized

#### ⏰ When Called
When the configuration system has finished loading

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log config initialization
    hook.Add("InitializedConfig", "MyAddon", function()
        print("Configuration initialized")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set up custom config values
    hook.Add("InitializedConfig", "CustomConfig", function()
        lia.config.add("myAddonEnabled", true, "Enable My Addon")
        lia.config.add("myAddonValue", 100, "My Addon Value")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex configuration initialization
    hook.Add("InitializedConfig", "AdvancedConfigInit", function()
        -- Add custom configuration options
        local configOptions = {
            {key = "myAddonEnabled", default = true,              description = "Enable My Addon", type = "boolean"},
            {key = "myAddonValue",   default = 100,               description = "My Addon Value",  type = "number" },
            {key = "myAddonString",  default = "default",         description = "My Addon String", type = "string" },
            {key = "myAddonColor",   default = Color(255, 255, 255), description = "My Addon Color", type = "color" }
        }
        for _, option in ipairs(configOptions) do
            lia.config.add(option.key, option.default, option.description)
        end
        -- Load saved configuration
        local savedConfig = lia.data.get("myAddonConfig", {})
        for key, value in pairs(savedConfig) do
            lia.config.set(key, value)
        end
        -- Set up configuration callbacks
        lia.config.addCallback("myAddonEnabled", function(value)
            print("My Addon enabled: " .. tostring(value))
        end)
        print("Configuration system initialized with " .. #configOptions .. " options")
    end)

```

---

### InitializedItems

#### 📋 Purpose
Called when items are initialized

#### ⏰ When Called
When the item system has finished loading

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log item initialization
    hook.Add("InitializedItems", "MyAddon", function()
        print("Items initialized")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register custom items
    hook.Add("InitializedItems", "CustomItems", function()
        lia.item.register("my_custom_item", {
            name = "My Custom Item",
            model = "models/props_junk/cardboard_box004a.mdl",
            description = "A custom item"
        })
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex item initialization system
    hook.Add("InitializedItems", "AdvancedItemInit", function()
        -- Register custom item categories
        local categories = {
            "weapons",
            "medical",
            "food",
            "tools",
            "misc"
        }
        for _, category in ipairs(categories) do
            lia.item.addCategory(category)
        end
        -- Register custom items
        local customItems = {
            {
                uniqueID  = "my_weapon",
                name      = "My Weapon",
                model     = "models/weapons/w_pistol.mdl",
                description = "A custom weapon",
                category  = "weapons",
                weight    = 2,
                price     = 100
            },
            {
                uniqueID  = "my_medkit",
                name      = "My Medkit",
                model     = "models/items/medkit.mdl",
                description = "A custom medkit",
                category  = "medical",
                weight    = 1,
                price     = 50
            }
        }
        for _, itemData in ipairs(customItems) do
            lia.item.register(itemData.uniqueID, itemData)
        end
        -- Set up item callbacks
        lia.item.addCallback("my_weapon", "onUse", function(item, client)
            client:ChatPrint("Used custom weapon!")
        end)
        print("Item system initialized with " .. #customItems .. " custom items")
    end)

```

---

### InitializedModules

#### 📋 Purpose
Called when modules are initialized

#### ⏰ When Called
When the module system has finished loading

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log module initialization
    hook.Add("InitializedModules", "MyAddon", function()
        print("Modules initialized")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register custom modules
    hook.Add("InitializedModules", "CustomModules", function()
        lia.module.register("my_module", {
            name = "My Module",
            description = "A custom module",
            author = "Me",
            version = "1.0.0"
        })
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex module initialization system
    hook.Add("InitializedModules", "AdvancedModuleInit", function()
        -- Register custom modules
        local modules = {
            {
                uniqueID    = "my_module",
                name        = "My Module",
                description = "A custom module",
                author      = "Me",
                version     = "1.0.0",
                dependencies = {"base"}
            },
            {
                uniqueID    = "my_other_module",
                name        = "My Other Module",
                description = "Another custom module",
                author      = "Me",
                version     = "1.0.0",
                dependencies = {"my_module"}
            }
        }
        for _, moduleData in ipairs(modules) do
            lia.module.register(moduleData.uniqueID, moduleData)
        end
        -- Set up module callbacks
        lia.module.addCallback("my_module", "onLoad", function()
            print("My module loaded!")
        end)
        lia.module.addCallback("my_module", "onUnload", function()
            print("My module unloaded!")
        end)
        -- Load module configurations
        local moduleConfigs = lia.data.get("moduleConfigs", {})
        for moduleID, config in pairs(moduleConfigs) do
            lia.module.setConfig(moduleID, config)
        end
        print("Module system initialized with " .. #modules .. " custom modules")
    end)

```

---

### InitializedSchema

#### 📋 Purpose
Called when schema is initialized

#### ⏰ When Called
When the schema system has finished loading

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log schema initialization
    hook.Add("InitializedSchema", "MyAddon", function()
        print("Schema initialized")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set up custom schema data
    hook.Add("InitializedSchema", "CustomSchema", function()
        lia.schema.set("myAddonVersion", "1.0.0")
        lia.schema.set("myAddonEnabled", true)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex schema initialization system
    hook.Add("InitializedSchema", "AdvancedSchemaInit", function()
        -- Set up custom schema data
        local schemaData = {
            version     = "1.0.0",
            name        = "My Custom Schema",
            description = "A custom schema for my addon",
            author      = "Me",
            enabled     = true,
            settings    = {
                maxPlayers  = 32,
                respawnTime = 5,
                roundTime   = 600
            }
        }
        for key, value in pairs(schemaData) do
            lia.schema.set(key, value)
        end
        -- Set up schema callbacks
        lia.schema.addCallback("onLoad", function()
            print("Schema loaded!")
        end)
        lia.schema.addCallback("onUnload", function()
            print("Schema unloaded!")
        end)
        -- Load saved schema settings
        local savedSettings = lia.data.get("schemaSettings", {})
        for key, value in pairs(savedSettings) do
            lia.schema.set(key, value)
        end
        print("Schema system initialized with custom data")
    end)

```

---

### InventoryDataChanged

#### 📋 Purpose
Called when inventory data changes

#### ⏰ When Called
When an inventory's data is modified

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log data changes
    hook.Add("InventoryDataChanged", "MyAddon", function(instance, key, oldValue, value)
        print("Inventory data changed: " .. key .. " = " .. tostring(value))
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track specific data changes
    hook.Add("InventoryDataChanged", "TrackInventoryChanges", function(instance, key, oldValue, value)
        if key == "weight" then
            print("Inventory weight changed from " .. oldValue .. " to " .. value)
        elseif key == "maxWeight" then
            print("Max weight changed from " .. oldValue .. " to " .. value)
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex inventory data tracking
    hook.Add("InventoryDataChanged", "AdvancedInventoryTracking", function(instance, key, oldValue, value)
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO inventory_logs (timestamp, invid, key, oldvalue, newvalue) VALUES (?, ?, ?, ?, ?)",
                os.time(), instance:getID(), key, tostring(oldValue), tostring(value))
        end
        -- Track weight changes
        if key == "weight" then
            local maxWeight = instance:getData("maxWeight", 100)
            local weightPercent = (value / maxWeight) * 100
            if weightPercent >= 90 then
                if CLIENT then
                    LocalPlayer():ChatPrint("Warning: Inventory is almost full!")
                end
            end
        end
        -- Notify owner of changes
        if SERVER then
            local owner = instance:getOwner()
            if IsValid(owner) then
                owner:ChatPrint("Inventory " .. key .. " changed to " .. tostring(value))
            end
        end
    end)

```

---

### InventoryInitialized

#### 📋 Purpose
Called when an inventory is initialized

#### ⏰ When Called
When an inventory is first created and set up

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log inventory initialization
    hook.Add("InventoryInitialized", "MyAddon", function(instance)
        print("Inventory initialized: " .. instance:getID())
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set default inventory data
    hook.Add("InventoryInitialized", "SetDefaultInventoryData", function(instance)
        instance:setData("weight", 0)
        instance:setData("maxWeight", 100)
        instance:setData("created", os.time())
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex inventory initialization
    hook.Add("InventoryInitialized", "AdvancedInventoryInit", function(instance)
        -- Set default data
        instance:setData("weight", 0)
        instance:setData("maxWeight", 100)
        instance:setData("created", os.time())
        instance:setData("lastAccessed", os.time())
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO inventory_logs (timestamp, invid, action) VALUES (?, ?, ?)",
                os.time(), instance:getID(), "initialized")
            -- Set up owner-specific settings
            local owner = instance:getOwner()
            if IsValid(owner) then
                local char = owner:getChar()
                if char then
                    -- Adjust max weight based on faction
                    local faction = char:getFaction()
                    if faction == "police" then
                        instance:setData("maxWeight", 150)
                    elseif faction == "medic" then
                        instance:setData("maxWeight", 120)
                    end
                    -- Add starting items
                    if instance:getData("isNew", true) then
                        local startingItems = {"item_bandage", "item_water"}
                        for _, itemID in ipairs(startingItems) do
                            local item = lia.item.instance(itemID)
                            if item then
                                instance:add(item)
                            end
                        end
                        instance:setData("isNew", false)
                    end
                end
            end
        end
    end)

```

---

### InventoryItemDataChanged

#### 📋 Purpose
Called when an item's data changes in an inventory

#### ⏰ When Called
When an item's data is modified while in an inventory

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log item data changes
    hook.Add("InventoryItemDataChanged", "MyAddon", function(item, key, oldValue, newValue, inventory)
        print("Item data changed: " .. key .. " = " .. tostring(newValue))
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track durability changes
    hook.Add("InventoryItemDataChanged", "TrackDurability", function(item, key, oldValue, newValue, inventory)
        if key == "durability" then
            if newValue <= 0 then
                print("Item " .. item.name .. " is broken!")
            elseif newValue <= 20 then
                print("Item " .. item.name .. " is almost broken!")
            end
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex item data tracking
    hook.Add("InventoryItemDataChanged", "AdvancedItemDataTracking", function(item, key, oldValue, newValue, inventory)
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO item_data_logs (timestamp, itemid, key, oldvalue, newvalue) VALUES (?, ?, ?, ?, ?)",
                os.time(), item:getID(), key, tostring(oldValue), tostring(newValue))
            -- Handle durability changes
            if key == "durability" then
                if newValue <= 0 then
                    -- Item is broken
                    local owner = inventory:getOwner()
                    if IsValid(owner) then
                        owner:ChatPrint(item.name .. " is broken!")
                    end
                    -- Remove item if it's broken
                    timer.Simple(1, function()
                        if IsValid(item) then
                            item:remove()
                        end
                    end)
                elseif newValue <= 20 then
                    -- Item is almost broken
                    local owner = inventory:getOwner()
                    if IsValid(owner) then
                        owner:ChatPrint("Warning: " .. item.name .. " is almost broken!")
                    end
                end
            end
            -- Handle quality changes
            if key == "quality" then
                local owner = inventory:getOwner()
                if IsValid(owner) then
                    owner:ChatPrint(item.name .. " quality changed to " .. newValue)
                end
            end
        end
    end)

```

---

### IsCharFakeRecognized

#### 📋 Purpose
Called to check if a character is fake recognized

#### ⏰ When Called
When checking if a character appears recognized but isn't truly

#### ↩️ Returns
* boolean - True if fake recognized, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Always return false
    hook.Add("IsCharFakeRecognized", "MyAddon", function(self, id)
        return false
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check fake recognition list
    hook.Add("IsCharFakeRecognized", "FakeRecognitionCheck", function(self, id)
        local fakeRecognized = self:getData("fakeRecognized", {})
        return table.HasValue(fakeRecognized, id)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex fake recognition system
    hook.Add("IsCharFakeRecognized", "AdvancedFakeRecognition", function(self, id)
        local fakeRecognized = self:getData("fakeRecognized", {})
        -- Check if in fake recognition list
        if table.HasValue(fakeRecognized, id) then
            -- Check if fake recognition has expired
            local fakeRecognitionTime = self:getData("fakeRecognitionTime_" .. id, 0)
            if os.time() - fakeRecognitionTime < 3600 then -- 1 hour
                return true
            else
                -- Remove expired fake recognition
                table.RemoveByValue(fakeRecognized, id)
                self:setData("fakeRecognized", fakeRecognized)
            end
        end
        return false
    end)

```

---

### IsCharRecognized

#### 📋 Purpose
Called to check if a character is recognized

#### ⏰ When Called
When checking if one character recognizes another

#### ↩️ Returns
* boolean - True if recognized, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check recognition list
    hook.Add("IsCharRecognized", "MyAddon", function(self, id)
        local recognized = self:getData("recognized", {})
        return table.HasValue(recognized, id)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check recognition with faction bonus
    hook.Add("IsCharRecognized", "FactionRecognition", function(self, id)
        local recognized = self:getData("recognized", {})
        if table.HasValue(recognized, id) then
            return true
        end
        -- Same faction members recognize each other
        local targetChar = lia.char.loaded[id]
        if targetChar and targetChar:getFaction() == self:getFaction() then
            return true
        end
        return false
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex recognition system
    hook.Add("IsCharRecognized", "AdvancedRecognition", function(self, id)
        local recognized = self:getData("recognized", {})
        if table.HasValue(recognized, id) then
            return true
        end
        local targetChar = lia.char.loaded[id]
        if not targetChar then return false end
        -- Same faction members recognize each other
        if targetChar:getFaction() == self:getFaction() then
            return true
        end
        -- Check if in same group/party
        local myGroup = self:getData("group")
        local targetGroup = targetChar:getData("group")
        if myGroup and targetGroup and myGroup == targetGroup then
            return true
        end
        -- Check proximity-based recognition
        local myPlayer = self:getPlayer()
        local targetPlayer = targetChar:getPlayer()
        if IsValid(myPlayer) and IsValid(targetPlayer) then
            local distance = myPlayer:GetPos():Distance(targetPlayer:GetPos())
            if distance < 100 then -- Very close range
                return true
            end
        end
        return false
    end)

```

---

### IsRecognizedChatType

#### 📋 Purpose
Called to check if a chat type requires recognition

#### ⏰ When Called
When determining if players need to be recognized to see names in chat

#### ↩️ Returns
* boolean - True if recognition is required, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Only IC chat requires recognition
    hook.Add("IsRecognizedChatType", "MyAddon", function(chatType)
        return chatType == "ic"
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Multiple chat types require recognition
    hook.Add("IsRecognizedChatType", "RecognizedChatTypes", function(chatType)
        local recognizedTypes = {"ic", "w", "y" }
        return table.HasValue(recognizedTypes, chatType)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex recognition requirements
    hook.Add("IsRecognizedChatType", "AdvancedChatRecognition", function(chatType)
        -- OOC and admin chats never require recognition
        local noRecognitionTypes = {"ooc", "looc", "admin" }
        if table.HasValue(noRecognitionTypes, chatType) then
            return false
        end
        -- IC and whisper chats require recognition
        local recognitionTypes = {"ic", "w", "y", "me", "it" }
        if table.HasValue(recognitionTypes, chatType) then
            return true
        end
        -- Radio and faction chats don't require recognition
        if chatType == "radio" or chatType == "faction" then
            return false
        end
        -- Default to requiring recognition
        return true
    end)

```

---

### IsValid

#### 📋 Purpose
Called to validate an entity

#### ⏰ When Called
When checking if an entity reference is valid

#### ↩️ Returns
* boolean - True if valid, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Basic validation
    hook.Add("IsValid", "MyAddon", function()
        return true
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check entity state
    hook.Add("IsValid", "EntityStateCheck", function()
        -- This hook is typically not used directly
        -- IsValid() is a built-in GMod function
        return true
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex validation
    hook.Add("IsValid", "AdvancedValidation", function()
        -- This hook is typically not used directly
        -- IsValid() is a built-in GMod function
        -- Custom validation logic would go here
        return true
    end)

```

---

### ItemDataChanged

#### 📋 Purpose
Called when an item's data changes

#### ⏰ When Called
When an item's data is modified

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log item data changes
    hook.Add("ItemDataChanged", "MyAddon", function(item, key, oldValue, newValue)
        print("Item data changed: " .. key .. " = " .. tostring(newValue))
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track durability changes
    hook.Add("ItemDataChanged", "TrackItemDurability", function(item, key, oldValue, newValue)
        if key == "durability" then
            if newValue <= 0 then
                print("Item " .. item.name .. " is broken!")
            elseif newValue <= 20 then
                print("Item " .. item.name .. " is almost broken!")
            end
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex item data tracking
    hook.Add("ItemDataChanged", "AdvancedItemDataTracking", function(item, key, oldValue, newValue)
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO item_data_logs (timestamp, itemid, key, oldvalue, newvalue) VALUES (?, ?, ?, ?, ?)",
                os.time(), item:getID(), key, tostring(oldValue), tostring(newValue))
            -- Handle durability changes
            if key == "durability" then
                if newValue <= 0 then
                    -- Item is broken
                    local owner = item:getOwner()
                    if IsValid(owner) then
                        owner:ChatPrint(item.name .. " is broken!")
                    end
                    -- Remove item
                    timer.Simple(1, function()
                        if IsValid(item) then
                            item:remove()
                        end
                    end)
                elseif newValue <= 20 then
                    -- Item is almost broken
                    local owner = item:getOwner()
                    if IsValid(owner) then
                        owner:ChatPrint("Warning: " .. item.name .. " is almost broken!")
                    end
                end
            end
            -- Handle quality changes
            if key == "quality" then
                local owner = item:getOwner()
                if IsValid(owner) then
                    owner:ChatPrint(item.name .. " quality changed to " .. newValue)
                end
            end
            -- Handle quantity changes
            if key == "quantity" then
                if newValue <= 0 then
                    item:remove()
                end
            end
        end
    end)

```

---

### ItemDefaultFunctions

#### 📋 Purpose
Called to get default functions for an item

#### ⏰ When Called
When building the default interaction functions for an item

#### ↩️ Returns
* table - Table of default functions

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return basic functions
    hook.Add("ItemDefaultFunctions", "MyAddon", function(item)
        return {
            use  = {name = "Use",  icon = "icon16/accept.png"},
            drop = {name = "Drop", icon = "icon16/bin.png" }
        }
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Conditional functions
    hook.Add("ItemDefaultFunctions", "ConditionalItemFunctions", function(item)
        local functions = {
            use  = {name = "Use",  icon = "icon16/accept.png"},
            drop = {name = "Drop", icon = "icon16/bin.png" }
        }
        if not item:getData("equipped", false) then
            functions.equip = {name = "Equip", icon = "icon16/add.png"}
        else
            functions.unequip = {name = "Unequip", icon = "icon16/delete.png"}
        end
        return functions
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex function system
    hook.Add("ItemDefaultFunctions", "AdvancedItemFunctions", function(item)
        local functions = {}
        -- Always add use function
        functions.use = {name = "Use", icon = "icon16/accept.png"}
        -- Add drop if not equipped
        if not item:getData("equipped", false) then
            functions.drop = {name = "Drop", icon = "icon16/bin.png"}
        end
        -- Add equip/unequip
        if item.equipable then
            if item:getData("equipped", false) then
                functions.unequip = {name = "Unequip", icon = "icon16/delete.png"}
            else
                functions.equip = {name = "Equip", icon = "icon16/add.png"}
            end
        end
        -- Add examine
        functions.examine = {name = "Examine", icon = "icon16/magnifier.png"}
        -- Add repair if damaged
        local durability = item:getData("durability")
        if durability and durability < 100 then
            functions.repair = {name = "Repair", icon = "icon16/wrench.png"}
        end
        return functions
    end)

```

---

### ItemInitialized

#### 📋 Purpose
Called when an item is initialized

#### ⏰ When Called
When an item is first created and set up

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log item initialization
    hook.Add("ItemInitialized", "MyAddon", function(item)
        print("Item initialized: " .. item.name)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set default item data
    hook.Add("ItemInitialized", "SetDefaultItemData", function(item)
        if not item:getData("durability") then
            item:setData("durability", 100)
        end
        if not item:getData("quality") then
            item:setData("quality", "common")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex item initialization
    hook.Add("ItemInitialized", "AdvancedItemInit", function(item)
        -- Set default data
        if not item:getData("durability") then
            item:setData("durability", 100)
        end
        if not item:getData("quality") then
            item:setData("quality", "common")
        end
        if not item:getData("created") then
            item:setData("created", os.time())
        end
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO item_logs (timestamp, itemid, action) VALUES (?, ?, ?)",
                os.time(), item:getID(), "initialized")
            -- Set up item-specific data
            if item.category == "weapon" then
                item:setData("ammo", item.maxAmmo or 30)
            elseif item.category == "armor" then
                item:setData("defense", item.baseDefense or 10)
            end
            -- Add to item registry
            lia.itemRegistry = lia.itemRegistry or {}
            lia.itemRegistry[item:getID()] = item
        end
    end)

```

---

### ItemQuantityChanged

#### 📋 Purpose
Called when an item's quantity changes

#### ⏰ When Called
When the stack size of an item is modified

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log quantity changes
    hook.Add("ItemQuantityChanged", "MyAddon", function(item, oldValue, quantity)
        print(item.name .. " quantity changed from " .. oldValue .. " to " .. quantity)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Remove item if quantity is zero
    hook.Add("ItemQuantityChanged", "RemoveEmptyItems", function(item, oldValue, quantity)
        if quantity <= 0 then
            item:remove()
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex quantity management
    hook.Add("ItemQuantityChanged", "AdvancedQuantityManagement", function(item, oldValue, quantity)
        if SERVER then
            -- Log to database
            lia.db.query("INSERT INTO item_quantity_logs (timestamp, itemid, oldquantity, newquantity) VALUES (?, ?, ?, ?)",
                os.time(), item:getID(), oldValue, quantity)
            -- Remove item if quantity is zero or negative
            if quantity <= 0 then
                local owner = item:getOwner()
                if IsValid(owner) then
                    owner:ChatPrint(item.name .. " has been depleted")
                end
                item:remove()
                return
            end
            -- Notify owner of quantity change
            local owner = item:getOwner()
            if IsValid(owner) then
                local change = quantity - oldValue
                if change > 0 then
                    owner:ChatPrint("+" .. change .. " " .. item.name)
                else
                    owner:ChatPrint(change .. " " .. item.name)
                end
            end
            -- Check for achievements
            if quantity >= 100 then
                local owner = item:getOwner()
                if IsValid(owner) then
                    local char = owner:getChar()
                    if char and not char:getData("achievement_hoarder_" .. item.uniqueID, false) then
                        char:setData("achievement_hoarder_" .. item.uniqueID, true)
                        owner:ChatPrint("Achievement unlocked: Hoarder of " .. item.name)
                    end
                end
            end
        end
    end)

```

---

### LiliaLoaded

#### 📋 Purpose
Called when Lilia framework is fully loaded

#### ⏰ When Called
After all Lilia systems are initialized

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log framework load
    hook.Add("LiliaLoaded", "MyAddon", function()
        print("Lilia framework loaded")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Initialize addon systems
    hook.Add("LiliaLoaded", "InitializeAddon", function()
        MyAddon.Initialize()
        print("MyAddon initialized")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex framework initialization
    hook.Add("LiliaLoaded", "AdvancedFrameworkInit", function()
        -- Initialize custom systems
        MyAddon.Initialize()
        -- Register custom chat commands
        lia.command.add("mycmd", {
            description = "My custom command",
            onRun       = function(client, arguments)
                client:ChatPrint("Command executed!")
            end
        })
        -- Register custom items
        lia.item.register("my_item", {
            name = "My Item",
            desc = "A custom item",
            model = "models/props_lab/box01a.mdl"
        })
        print("MyAddon fully initialized with Lilia")
    end)

```

---

### NetVarChanged

#### 📋 Purpose
Called when a network variable changes

#### ⏰ When Called
When an entity's netvar is modified

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log netvar changes
    hook.Add("NetVarChanged", "MyAddon", function(entity, key, oldValue, value)
        print("NetVar changed: " .. key .. " = " .. tostring(value))
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track specific netvars
    hook.Add("NetVarChanged", "TrackNetvars", function(entity, key, oldValue, value)
        if key == "health" then
            print("Health changed from " .. oldValue .. " to " .. value)
        elseif key == "armor" then
            print("Armor changed from " .. oldValue .. " to " .. value)
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex netvar tracking system
    hook.Add("NetVarChanged", "AdvancedNetvarTracking", function(entity, key, oldValue, value)
        if not IsValid(entity) then return end
        -- Log to console
        print(string.format("NetVar changed on %s: %s = %s (was %s)",
            tostring(entity), key, tostring(value), tostring(oldValue)))
        -- Handle specific netvars
        if key == "health" and entity:IsPlayer() then
            if value < oldValue then
                -- Player took damage
                local damage = oldValue - value
                print(entity:Name() .. " took " .. damage .. " damage")
            elseif value > oldValue then
                -- Player healed
                local healing = value - oldValue
                print(entity:Name() .. " healed " .. healing .. " HP")
            end
        end
        -- Trigger custom events
        hook.Run("CustomNetVarChanged_" .. key, entity, oldValue, value)
    end)

```

---

### OnItemRegistered

#### 📋 Purpose
Called when an item is registered

#### ⏰ When Called
When a new item is added to the item system

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log item registration
    hook.Add("OnItemRegistered", "MyAddon", function(ITEM)
        print("Item registered: " .. ITEM.name)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track registered items
    hook.Add("OnItemRegistered", "TrackItems", function(ITEM)
        MyAddon.registeredItems = MyAddon.registeredItems or {}
        MyAddon.registeredItems[ITEM.uniqueID] = {
            name       = ITEM.name,
            model      = ITEM.model,
            registered = os.time()
        }
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex item registration handling
    hook.Add("OnItemRegistered", "AdvancedItemRegistration", function(ITEM)
        -- Log item registration
        lia.log.write("item_registered", {
            uniqueID  = ITEM.uniqueID,
            name      = ITEM.name,
            model     = ITEM.model,
            timestamp = os.time()
        })
        -- Validate item data
        if not ITEM.uniqueID or not ITEM.name then
            print("Warning: Invalid item data for " .. tostring(ITEM.uniqueID))
        end
        -- Add custom properties
        ITEM.customProperty = "MyAddonValue"
        -- Register item in custom system
        MyAddon.itemSystem:RegisterItem(ITEM)
        -- Notify clients if server
        if SERVER then
            net.Start("liaItemRegistered")
            net.WriteString(ITEM.uniqueID)
            net.Broadcast()
        end
    end)

```

---

### OnLoaded

#### 📋 Purpose
Called when the framework has finished loading

#### ⏰ When Called
After all framework components have been initialized

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log framework loaded
    hook.Add("OnLoaded", "MyAddon", function()
        print("Lilia framework has finished loading")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Initialize addon after framework loads
    hook.Add("OnLoaded", "InitMyAddon", function()
        if SERVER then
            -- Server-side initialization
            print("Server addon initialized")
        else
            -- Client-side initialization
            print("Client addon initialized")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex post-load initialization
    hook.Add("OnLoaded", "AdvancedInit", function()
        if SERVER then
            -- Load saved data
            lia.data.get("addonData", {}, function(data)
                MyAddon.data = data
                print("Addon data loaded")
            end)
            -- Register custom network strings
            util.AddNetworkString("MyAddonSync")
        else
            -- Setup client UI
            hook.Add("HUDPaint", "MyAddonHUD", function()
                -- Draw custom HUD elements
            end)
        end
    end)

```

---

### OnPrivilegeRegistered

#### 📋 Purpose
Called when a new privilege is registered

#### ⏰ When Called
When a privilege is added to the system

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log privilege registration
    hook.Add("OnPrivilegeRegistered", "MyAddon", function(privilege, name, access, category)
        print("Privilege registered: " .. name)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track privileges
    hook.Add("OnPrivilegeRegistered", "TrackPrivileges", function(privilege, name, access, category)
        MyAddon.privileges = MyAddon.privileges or {}
        MyAddon.privileges[privilege] = {
            name     = name,
            access   = access,
            category = category
        }
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex privilege management
    hook.Add("OnPrivilegeRegistered", "AdvancedPrivilegeManagement", function(privilege, name, access, category)
        -- Store privilege data
        if SERVER then
            lia.data.get("privileges", {}, function(data)
                data[privilege] = {
                    name       = name,
                    access     = access,
                    category   = category,
                    registered = os.time()
                }
                lia.data.set("privileges", data)
            end)
        end
        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("New privilege registered: " .. name)
            end
        end
    end)

```

---

### OnPrivilegeUnregistered

#### 📋 Purpose
Called when a privilege is unregistered

#### ⏰ When Called
When a privilege is removed from the system

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log privilege removal
    hook.Add("OnPrivilegeUnregistered", "MyAddon", function(privilege, name)
        print("Privilege unregistered: " .. name)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clean up privilege data
    hook.Add("OnPrivilegeUnregistered", "CleanupPrivilege", function(privilege, name)
        if MyAddon.privileges and MyAddon.privileges[privilege] then
            MyAddon.privileges[privilege] = nil
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex privilege cleanup
    hook.Add("OnPrivilegeUnregistered", "AdvancedPrivilegeCleanup", function(privilege, name)
        -- Remove privilege data
        if SERVER then
            lia.data.get("privileges", {}, function(data)
                data[privilege] = nil
                lia.data.set("privileges", data)
            end)
        end
        -- Revoke privilege from all players
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char and char:hasPrivilege(privilege) then
                char:revokePrivilege(privilege)
            end
        end
    end)

```

---

### OptionAdded

#### 📋 Purpose
Called when an option is added to the options system

#### ⏰ When Called
When a new option is registered

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log when options are added
    hook.Add("OptionAdded", "MyAddon", function(key, option)
        print("Option " .. key .. " was added")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track added options
    hook.Add("OptionAdded", "TrackOptions", function(key, option)
        MyAddon.addedOptions = MyAddon.addedOptions or {}
        MyAddon.addedOptions[key] = option
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Advanced option handling
    hook.Add("OptionAdded", "AdvancedOptionHandler", function(key, option)
        -- Log option addition
        lia.log.write("option_added", {
            key       = key,
            type      = option.type,
            default   = option.default,
            timestamp = os.time()
        })
        -- Handle special option types
        if option.type == "boolean" then
            -- Initialize boolean option handling
            MyAddon.booleanOptions = MyAddon.booleanOptions or {}
            MyAddon.booleanOptions[key] = option.default or false
        elseif option.type == "number" then
            -- Initialize number option handling
            MyAddon.numberOptions = MyAddon.numberOptions or {}
            MyAddon.numberOptions[key] = {
                value = option.default or 0,
                min   = option.min or 0,
                max   = option.max or 100
            }
        end
        -- Notify clients if needed
        if SERVER and option.shouldNetwork then
            net.Start("liaOptionAdded")
            net.WriteString(key)
            net.WriteTable(option)
            net.Broadcast()
        end
    end)

```

---

### OptionChanged

#### 📋 Purpose
Called when a configuration option is changed

#### ⏰ When Called
When a configuration value is modified

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log option changes
    hook.Add("OptionChanged", "MyAddon", function(key, old, value)
        print("Option " .. key .. " changed from " .. tostring(old) .. " to " .. tostring(value))
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track option changes
    hook.Add("OptionChanged", "TrackOptions", function(key, old, value)
        MyAddon.optionHistory = MyAddon.optionHistory or {}
        table.insert(MyAddon.optionHistory, {
            key  = key,
            old  = old,
            new  = value,
            time = os.time()
        })
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex option change handling
    hook.Add("OptionChanged", "AdvancedOptionChange", function(key, old, value)
        -- Log option change
        lia.log.write("option_changed", {
            key       = key,
            old       = tostring(old),
            new       = tostring(value),
            timestamp = os.time()
        })
        -- Handle specific option changes
        if key == "serverName" then
            SetHostName(value)
        elseif key == "maxPlayers" then
            game.SetMaxPlayers(value)
        end
        -- Notify clients of important changes
        if SERVER then
            net.Start("liaOptionChanged")
            net.WriteString(key)
            net.WriteType(value)
            net.Broadcast()
        end
    end)

```

---

### OverrideFactionDesc

#### 📋 Purpose
Called to override a faction's description

#### ⏰ When Called
When a faction description needs to be modified

#### ↩️ Returns
* string - The overridden description (or nil to use default)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add prefix to description
    hook.Add("OverrideFactionDesc", "MyAddon", function(uniqueID, description)
        return "[FACTION] " .. description
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Customize specific faction descriptions
    hook.Add("OverrideFactionDesc", "CustomFactionDesc", function(uniqueID, description)
        if uniqueID == "citizen" then
            return "Citizens are the backbone of society."
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic faction description
    hook.Add("OverrideFactionDesc", "DynamicFactionDesc", function(uniqueID, description)
        local faction = lia.faction.indices[uniqueID]
        if not faction then return end
        -- Add player count to description
        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char and char:getFaction() == faction.index then
                count = count + 1
            end
        end
        return description .. "\n\nCurrent Members: " .. count
    end)

```

---

### OverrideFactionModels

#### 📋 Purpose
Called to override a faction's models

#### ⏰ When Called
When a faction's available models need to be modified

#### ↩️ Returns
* table - The overridden models table (or nil to use default)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a model to faction
    hook.Add("OverrideFactionModels", "MyAddon", function(uniqueID, models)
        if uniqueID == "citizen" then
            table.insert(models, "models/player/group01/male_01.mdl")
            return models
        end
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Replace faction models
    hook.Add("OverrideFactionModels", "ReplaceFactionModels", function(uniqueID, models)
        if uniqueID == "police" then
            return {
                "models/player/police.mdl",
                "models/player/police_fem.mdl"
            }
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic faction models based on rank
    hook.Add("OverrideFactionModels", "DynamicFactionModels", function(uniqueID, models)
        local faction = lia.faction.indices[uniqueID]
        if not faction then return end
        -- Load models from configuration
        local customModels = lia.config.get("faction_models_" .. uniqueID, {})
        if table.Count(customModels) > 0 then
            return customModels
        end
        -- Filter models based on gender setting
        if lia.config.get("faction_gender_filter", false) then
            local filtered = {}
            for _, model in ipairs(models) do
                if not string.find(model, "_fem") then
                    table.insert(filtered, model)
                end
            end
            return filtered
        end
    end)

```

---

### OverrideFactionName

#### 📋 Purpose
Called to override a faction's name

#### ⏰ When Called
When a faction name needs to be modified

#### ↩️ Returns
* string - The overridden name (or nil to use default)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add prefix to name
    hook.Add("OverrideFactionName", "MyAddon", function(uniqueID, name)
        return "[" .. uniqueID:upper() .. "] " .. name
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Localize faction names
    hook.Add("OverrideFactionName", "LocalizeFactionNames", function(uniqueID, name)
        local localizedNames = {
            citizen = "Citoyen",
            police  = "Police",
            medic   = "Médecin"
        }
        return localizedNames[uniqueID] or name
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic faction naming
    hook.Add("OverrideFactionName", "DynamicFactionName", function(uniqueID, name)
        local faction = lia.faction.indices[uniqueID]
        if not faction then return end
        -- Add member count to name
        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char and char:getFaction() == faction.index then
                count = count + 1
            end
        end
        -- Add status indicator
        local status = ""
        if lia.config.get("faction_recruiting_" .. uniqueID, false) then
            status = " [RECRUITING]"
        end
        return name .. " (" .. count .. ")" .. status
    end)

```

---

### PlayerStaminaGained

#### 📋 Purpose
Called when player gains stamina

#### ⏰ When Called
When a player's stamina increases

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log stamina gain
    hook.Add("PlayerStaminaGained", "MyAddon", function(self)
        print(self:Name() .. " gained stamina")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track stamina gains
    hook.Add("PlayerStaminaGained", "TrackStaminaGains", function(self)
        if SERVER then
            local char = self:getChar()
            if char then
                local staminaGains = char:getData("staminaGains", 0)
                char:setData("staminaGains", staminaGains + 1)
            end
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex stamina gain tracking
    hook.Add("PlayerStaminaGained", "AdvancedStaminaGain", function(self)
        if SERVER then
            local char = self:getChar()
            if not char then return end
            -- Track stamina gains
            local staminaGains = char:getData("staminaGains", 0)
            char:setData("staminaGains", staminaGains + 1)
            -- Check for achievements
            if staminaGains + 1 >= 1000 then
                if not char:getData("achievement_marathonRunner", false) then
                    char:setData("achievement_marathonRunner", true)
                    self:ChatPrint("Achievement unlocked: Marathon Runner!")
                end
            end
        end
    end)

```

---

### PlayerStaminaLost

#### 📋 Purpose
Called when player loses stamina

#### ⏰ When Called
When a player's stamina decreases

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log stamina loss
    hook.Add("PlayerStaminaLost", "MyAddon", function(self)
        print(self:Name() .. " lost stamina")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Track stamina loss
    hook.Add("PlayerStaminaLost", "TrackStaminaLoss", function(self)
        if SERVER then
            local char = self:getChar()
            if char then
                local staminaLoss = char:getData("staminaLoss", 0)
                char:setData("staminaLoss", staminaLoss + 1)
            end
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex stamina loss tracking
    hook.Add("PlayerStaminaLost", "AdvancedStaminaLoss", function(self)
        if SERVER then
            local char = self:getChar()
            if not char then return end
            -- Track stamina loss
            local staminaLoss = char:getData("staminaLoss", 0)
            char:setData("staminaLoss", staminaLoss + 1)
            -- Check if stamina is critically low
            local stamina = self:getNetVar("stamina", 100)
            if stamina <= 10 then
                self:ChatPrint("Warning: Stamina is critically low!")
            end
        end
    end)

```

---

### PreLiliaLoaded

#### 📋 Purpose
Called before Lilia framework is loaded

#### ⏰ When Called
Before Lilia systems are initialized

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log pre-load
    hook.Add("PreLiliaLoaded", "MyAddon", function()
        print("Lilia is about to load")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Initialize addon systems
    hook.Add("PreLiliaLoaded", "InitializeAddon", function()
        MyAddon.PreInitialize()
        print("Addon pre-initialized")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex pre-load initialization
    hook.Add("PreLiliaLoaded", "AdvancedPreLoadInit", function()
        -- Initialize custom systems
        MyAddon.PreInitialize()
        -- Set up configuration
        MyAddon.config = MyAddon.config or {}
        MyAddon.config.enabled = true
        MyAddon.config.debug  = false
        -- Register custom hooks
        hook.Add("PlayerInitialSpawn", "MyAddonSpawn", MyAddon.OnPlayerSpawn)
        print("Advanced pre-load initialization completed")
    end)

```

---

### calcStaminaChange

#### 📋 Purpose
Called to calculate stamina change

#### ⏰ When Called
When calculating how much stamina should change

#### ↩️ Returns
* number - The stamina change amount

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Return default stamina change
    hook.Add("calcStaminaChange", "MyAddon", function(client)
        return 1
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Calculate based on character attributes
    hook.Add("calcStaminaChange", "AttributeStamina", function(client)
        local char = client:getChar()
        if not char then return 1 end
        local endurance = char:getAttrib("end", 0)
        return 1 + (endurance * 0.1)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex stamina calculation system
    hook.Add("calcStaminaChange", "AdvancedStaminaCalc", function(client)
        local char = client:getChar()
        if not char then return 1 end
        -- Base stamina change
        local baseChange = 1
        -- Attribute bonus
        local endurance = char:getAttrib("end", 0)
        local strength = char:getAttrib("str", 0)
        local attrBonus = (endurance * 0.1) + (strength * 0.05)
        -- Faction bonus
        local faction = char:getFaction()
        local factionBonuses = {
            ["athlete"] = 0.5,
            ["soldier"] = 0.3,
            ["citizen"] = 0.0
        }
        local factionBonus = factionBonuses[faction] or 0.0
        -- Item bonuses
        local itemBonus = 0
        local inv = char:getInv()
        if inv then
            for _, item in pairs(inv:getItems()) do
                if item:getData("equipped", false) then
                    itemBonus = itemBonus + (item.staminaBonus or 0)
                end
            end
        end
        -- Status effects
        local statusPenalty = 0
        if char:getData("injured", false) then
            statusPenalty = statusPenalty - 0.5
        end
        if char:getData("exhausted", false) then
            statusPenalty = statusPenalty - 0.3
        end
        -- Calculate final change
        local finalChange = baseChange + attrBonus + factionBonus + itemBonus + statusPenalty
        return math.max(0.1, finalChange)
    end)

```

---

### getData

#### 📋 Purpose
Called to get persistent data

#### ⏰ When Called
When retrieving stored data

#### ↩️ Returns
* any - The retrieved data or default value

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get data with default
    hook.Add("getData", "MyAddon", function(default)
        return default
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get data with validation
    hook.Add("getData", "ValidateData", function(default)
        local data = lia.data.get("someKey", default)
        if type(data) ~= type(default) then
            return default
        end
        return data
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex data retrieval system
    hook.Add("getData", "AdvancedDataGet", function(default)
        -- Try to get from cache first
        local cache = lia.data.cache or {}
        local key = "someKey"
        if cache[key] and cache[key].expiry > CurTime() then
            return cache[key].value
        end
        -- Get from storage
        local data = lia.data.get(key, default)
        -- Validate data type
        if type(data) ~= type(default) then
            print("Warning: Data type mismatch, using default")
            data = default
        end
        -- Cache the result
        cache[key] = {
            value  = data,
            expiry = CurTime() + 60
        }
        lia.data.cache = cache
        return data
    end)

```

---

### print

#### 📋 Purpose
Called when localization system has finished loading all language files

#### ⏰ When Called
After all language files have been loaded and the localization system is ready

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log when localization is loaded
    hook.Add("OnLocalizationLoaded", "MyAddon", function()
        print("Localization system loaded")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Initialize addon with localization
    hook.Add("OnLocalizationLoaded", "InitWithLocalization", function()
        -- Now safe to use L() function
        print(L("addonLoaded", "MyAddon"))
        -- Register custom language strings
        lia.lang.Add("english", "myCustomString", "My Custom String")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex localization initialization
    hook.Add("OnLocalizationLoaded", "AdvancedLocalizationInit", function()
        -- Load custom language files
        lia.lang.loadFromDir("myaddon/languages")
        -- Register dynamic language strings
        local customStrings = {
            {key = "myAddonWelcome", english = "Welcome to My Addon"},
            {key = "myAddonGoodbye", english = "Goodbye from My Addon"}
        }
        for _, str in ipairs(customStrings) do
            lia.lang.Add("english", str.key, str.english)
        end
        -- Initialize addon systems that depend on localization
        MyAddon.Initialize()
        print(L("addonInitialized", "MyAddon"))
    end)

```

---

### OnLocalizationLoaded

#### 📋 Purpose
Called when localization system has finished loading all language files

#### ⏰ When Called
After all language files have been loaded and the localization system is ready

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log when localization is loaded
    hook.Add("OnLocalizationLoaded", "MyAddon", function()
        print("Localization system loaded")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Initialize addon with localization
    hook.Add("OnLocalizationLoaded", "InitWithLocalization", function()
        -- Now safe to use L() function
        print(L("addonLoaded", "MyAddon"))
        -- Register custom language strings
        lia.lang.Add("english", "myCustomString", "My Custom String")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex localization initialization
    hook.Add("OnLocalizationLoaded", "AdvancedLocalizationInit", function()
        -- Load custom language files
        lia.lang.loadFromDir("myaddon/languages")
        -- Register dynamic language strings
        local customStrings = {
            {key = "myAddonWelcome", english = "Welcome to My Addon"},
            {key = "myAddonGoodbye", english = "Goodbye from My Addon"}
        }
        for _, str in ipairs(customStrings) do
            lia.lang.Add("english", str.key, str.english)
        end
        -- Initialize addon systems that depend on localization
        MyAddon.Initialize()
        print(L("addonInitialized", "MyAddon"))
    end)

```

---

### ShouldShowCharVarInCreation

#### 📋 Purpose
Called to determine if a character variable should be shown in character creation

#### ⏰ When Called
When building the character creation UI to check if a specific character variable field should be displayed

#### ↩️ Returns
* boolean or nil - Return false to hide the variable from character creation, true or nil to show it

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Hide description field from character creation
    hook.Add("ShouldShowCharVarInCreation", "HideDesc", function(varName)
        if varName == "desc" then
            return false
        end
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Hide multiple fields based on configuration
    hook.Add("ShouldShowCharVarInCreation", "HideFields", function(varName)
        local hiddenFields = lia.config.get("HiddenCharCreationFields", {})
        if table.HasValue(hiddenFields, varName) then
            return false
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Complex field visibility system
    hook.Add("ShouldShowCharVarInCreation", "AdvancedFieldVisibility", function(varName)
        local client = LocalPlayer()
        if not IsValid(client) then return end
        -- Hide desc for certain factions
        if varName == "desc" then
            local context = lia.gui.charCreate and lia.gui.charCreate.context or {}
            local faction = context.faction
            if faction then
                local hiddenFactions = {"staff", "admin"}
                local factionData = lia.faction.indices[faction]
                if factionData and table.HasValue(hiddenFactions, factionData.uniqueID) then
                    return false
                end
            end
        end
        -- Hide fields based on player permissions
        if varName == "customField" and not client:IsAdmin() then
            return false
        end
        -- Check module configuration
        local module = lia.module.get("myModule")
        if module and module.config and module.config.hideFields then
            if table.HasValue(module.config.hideFields, varName) then
                return false
            end
        end
        return true
    end)

```

---

