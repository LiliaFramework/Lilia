--[[
    Folder: Developer - Libraries
    File: lia.item.md
]]
--[[
    Item

    Item definition, registration, instancing, inventory helper, rarity, and generated weapon/ammunition item utilities for Lilia.
]]
--[[
    Overview:
        The item library manages registered item definitions and base items under `lia.item`, creates and restores item instances, creates inventory helpers, registers deferred item definitions and overrides, supports generated weapon and ammunition item definitions, and applies persistent weapon override data.
]]
--[[
    Hooks:
        OnPlayerDroppedItem(Player client, Entity itemEntity)

    Purpose:
        Runs after a player uses the default drop action and the item has been spawned into the world.

    Parameters:
        client (Player)
            The player who dropped the item.
        itemEntity (Entity)
            The spawned world entity for the dropped item.

    Realm:
        Server
]]
--[[
    Hooks:
        OnPlayerTakeItem(Player client, Item item)

    Purpose:
        Runs after a player successfully takes a world item into their inventory.

    Parameters:
        client (Player)
            The player who took the item.
        item (Item)
            The item instance that was added to the inventory.

    Realm:
        Server
]]
--[[
    Hooks:
        OnPlayerRotateItem(Player client, Item item, boolean rotated)

    Purpose:
        Runs after a player rotates an inventory item using the default rotate action.

    Parameters:
        client (Player)
            The player who rotated the item.
        item (Item)
            The item instance that was rotated.
        rotated (boolean)
            The new rotated state stored on the item.

    Realm:
        Server
]]
--[[
    Hooks:
        HandleItemTransferRequest(Player client, number itemID, number|nil x, number|nil y, number targetInvID)

    Purpose:
        Handles the actual transfer when a player gives an item forward to another player.

    Parameters:
        client (Player)
            The player initiating the transfer.
        itemID (number)
            The database ID of the item being transferred.
        x (number|nil)
            The destination inventory X position, if one is specified.
        y (number|nil)
            The destination inventory Y position, if one is specified.
        targetInvID (number)
            The inventory ID receiving the item.

    Returns:
        deferred|nil
            Return a deferred transfer result to continue the give-forward flow, or nil to stop handling.

    Realm:
        Server
]]
--[[
    Hooks:
        ItemDefaultFunctions(table functions)

    Purpose:
        Allows modules to inspect or modify the default item action table during item registration.

    Parameters:
        functions (table)
            The mutable table of item action definitions.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnItemRegistered(Item itemDef)

    Purpose:
        Runs after an item definition or base item has been registered and localized.

    Parameters:
        itemDef (Item)
            The registered item definition table.

    Realm:
        Shared
]]
--[[
    Hooks:
        InitializedItems()

    Purpose:
        Runs after item files have been loaded from the item directory.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnItemCreated(Item item)

    Purpose:
        Runs after an item instance table is created from a registered item definition.

    Parameters:
        item (Item)
            The newly created item instance.

    Realm:
        Shared
]]
--[[
    Hooks:
        GetWeaponName(table weaponTable)

    Purpose:
        Allows modules to provide a display name for automatically generated weapon items.

    Parameters:
        weaponTable (table)
            The weapon table being converted into an item definition.

    Returns:
        string|nil
            Return a string to override the generated item name, or nil to use the default name source.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnItemOverridden(Item itemDef, table overrides)

    Purpose:
        Runs after pending overrides have been applied to an item definition.

    Parameters:
        itemDef (Item)
            The item definition that received overrides.
        overrides (table)
            The override table that was applied.

    Realm:
        Shared
]]
--[[
    Hooks:
        CanPlayerModifyConfig(Player client)

    Purpose:
        Controls whether the local player can see the generated weapon item configuration page.

    Parameters:
        client (Player)
            The player opening the configuration interface.

    Returns:
        boolean|nil
            Return false to hide the configuration page. Return nil or true to allow it.

    Realm:
        Client
]]
lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.list = lia.item.list or {}
lia.item.rarities = lia.item.rarities or {}
lia.item.instances = lia.item.instances or {}
lia.item.itemEntities = lia.item.itemEntities or {}
lia.item.inventories = lia.inventory.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
lia.item.WeaponOverrides = lia.item.WeaponOverrides or {}
lia.item.WeaponRuntimeOverrides = lia.item.WeaponRuntimeOverrides or {}
lia.item.pendingOverrides = lia.item.pendingOverrides or {}
lia.item.pendingRegistrations = lia.item.pendingRegistrations or {}
lia.item.WeaponsBlackList = lia.item.WeaponsBlackList or {
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    lia_adminstick = true,
    lia_hands = true,
    lia_keys = true
}

local DefaultFunctions = {
    drop = {
        tip = "dropTip",
        icon = "icon16/world.png",
        onRun = function(item)
            local client = item.player
            item:removeFromInventory(true):next(function()
                local spawnedItem = item:spawn(client)
                hook.Run("OnPlayerDroppedItem", client, spawnedItem)
            end)
            return false
        end,
        onCanRun = function(item) return not IsValid(item.entity) and not IsValid(item.entity) and not item.noDrop end
    },
    take = {
        tip = "takeTip",
        icon = "icon16/box.png",
        onRun = function(item)
            local client = item.player
            local inventory = client:getChar():getInv()
            local entity = item.entity
            if client.itemTakeTransaction and client.itemTakeTransactionTimeout > RealTime() then return false end
            client.itemTakeTransaction = true
            client.itemTakeTransactionTimeout = RealTime()
            if not inventory then return false end
            local d = deferred.new()
            inventory:add(item):next(function()
                client.itemTakeTransaction = nil
                if IsValid(entity) then
                    entity.liaIsSafe = true
                    entity:Remove()
                end

                hook.Run("OnPlayerTakeItem", client, item)
                if not IsValid(client) then return end
                d:resolve()
            end):catch(function(err)
                if err == "noFit" then
                    client:notifyErrorLocalized("itemNoFit", item:getWidth(), item:getHeight())
                else
                    client:notifyErrorLocalized(err)
                end

                client.itemTakeTransaction = nil
                d:reject()
            end)
            return d
        end,
        onCanRun = function(item) return IsValid(item.entity) end
    },
    rotate = {
        tip = "rotateTip",
        icon = "icon16/arrow_rotate_clockwise.png",
        onRun = function(item)
            local inv = lia.item.getInv(item.invID)
            local x, y = item:getData("x"), item:getData("y")
            local newRot = not item:getData("rotated", false)
            if inv and x and y then
                local w = newRot and (item.height or 1) or item.width or 1
                local h = newRot and (item.width or 1) or item.height or 1
                local invW, invH = inv:getSize()
                if x < 1 or y < 1 or x + w - 1 > invW or y + h - 1 > invH then
                    item.player:notifyErrorLocalized("itemNoFit", w, h)
                    return false
                end

                for _, v in pairs(inv:getItems(true)) do
                    if v ~= item then
                        local ix, iy = v:getData("x"), v:getData("y")
                        if ix and iy then
                            local ix2 = ix + v:getWidth() - 1
                            local iy2 = iy + v:getHeight() - 1
                            local x2 = x + w - 1
                            local y2 = y + h - 1
                            if x <= ix2 and ix <= x2 and y <= iy2 and iy <= y2 then
                                item.player:notifyErrorLocalized("itemNoFit", w, h)
                                return false
                            end
                        end
                    end
                end
            end

            item:setData("rotated", newRot)
            if IsValid(item.player) then hook.Run("OnPlayerRotateItem", item.player, item, newRot) end
            return false
        end,
        onCanRun = function(item) return not IsValid(item.entity) and item.width ~= item.height and not item:getData("equip", false) end
    },
    giveForward = {
        tip = "giveForwardTip",
        icon = "icon16/arrow_up.png",
        onRun = function(item)
            local function canTransferItemsFromInventoryUsingGiveForward(_, action)
                if action == "transfer" then return true end
            end

            local client = item.player
            local inv = client:getChar():getInv()
            local target = client:getTracedEntity()
            if not (target and target:IsValid() and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500) then return false end
            local targetInv = target:getChar():getInv()
            if not target or not targetInv then return false end
            if not targetInv:doesFitInventory(item) then
                client:notifyLocalized("noFit")
                return false
            end

            target:requestBinaryQuestion(L("itemGiveRequest", client:Name(), item.name), "@yes", "@no", function(choice)
                if choice == 0 then
                    inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    client:setAction(L("givingItemTo", item.name, target:Name()), lia.config.get("ItemGiveSpeed", 6))
                    target:setAction(L("givingYouItem", client:Name(), item.name), lia.config.get("ItemGiveSpeed", 6))
                    client:doStaredAction(target, function()
                        local res = hook.Run("HandleItemTransferRequest", client, item:getID(), nil, nil, targetInv:getID())
                        if not res then return end
                        res:next(function()
                            if not IsValid(client) then return end
                            if istable(res) and isstring(res.error) then return client:notifyErrorLocalized(res.error) end
                            client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
                            client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
                        end)
                    end, lia.config.get("ItemGiveSpeed", 6), function() client:setAction() end, 100)
                else
                    client:notifyLocalized("itemGiveDeclined", target:Name())
                    target:notifyLocalized("itemGiveDeclinedSelf", client:Name())
                end
            end)
            return false
        end,
        onCanRun = function(item)
            local client = item.player
            local target = client:getTracedEntity()
            return not IsValid(item.entity) and lia.config.get("ItemGiveEnabled") and not IsValid(item.entity) and not item.noDrop and target and IsValid(target) and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500
        end
    },
}

lia.meta.item.width = 1
lia.meta.item.height = 1
--[[
    Purpose:
        Returns a registered base item or normal item definition by identifier.

    Parameters:
        identifier (string)
            The unique ID of the item or base item to retrieve.

    Returns:
        Item|nil
            The matching item definition, or nil if no registered item or base item exists for the identifier.

    Example Usage:
        ```lua
        local itemDef = lia.item.get("water_bottle")
        if itemDef then print(itemDef.name) end
        ```

    Realm:
        Shared
]]
function lia.item.get(identifier)
    return lia.item.base[identifier] or lia.item.list[identifier]
end

--[[
    Purpose:
        Applies stored weapon override values to an already registered item definition.

    Parameters:
        uniqueID (string)
            The unique ID or weapon class name of the generated weapon item to update.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.addWeaponOverride("weapon_pistol", {name = "Sidearm"})
        lia.item.applyWeaponOverride("weapon_pistol")
        ```

    Realm:
        Shared
]]
function lia.item.applyWeaponOverride(uniqueID)
    local data = lia.item.WeaponOverrides and lia.item.WeaponOverrides[uniqueID]
    if not istable(data) then return end
    local itemDef = lia.item.list and lia.item.list[uniqueID]
    if not itemDef then return end
    for k, v in pairs(data) do
        itemDef[k] = v
    end
end

--[[
    Purpose:
        Finds an instantiated item by database ID and reports where the item currently exists.

    Parameters:
        itemID (number)
            The database ID of the item instance to retrieve.

    Returns:
        table|nil
            A table containing `item` and `location` when found, or nil when the item does not exist.
        string|nil
            An error message when the item cannot be found.

    Example Usage:
        ```lua
        local result, err = lia.item.getItemByID(15)
        if result then print(result.location) end
        ```

    Realm:
        Shared
]]
function lia.item.getItemByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    local location = "unknown"
    if item.invID then
        local inventory = lia.item.getInv(item.invID)
        if inventory then location = "inventory" end
    elseif item.entity and IsValid(item.entity) then
        location = "world"
    end
    return {
        item = item,
        location = location
    }
end

--[[
    Purpose:
        Returns an instantiated item directly from the item instance cache.

    Parameters:
        itemID (number)
            The database ID of the item instance to retrieve.

    Returns:
        Item|nil
            The item instance when it exists, or nil when it cannot be found.
        string|nil
            An error message when the item cannot be found.

    Example Usage:
        ```lua
        local item, err = lia.item.getInstancedItemByID(15)
        if item then print(item.uniqueID) end
        ```

    Realm:
        Shared
]]
function lia.item.getInstancedItemByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item
end

--[[
    Purpose:
        Returns the data table stored on an instantiated item.

    Parameters:
        itemID (number)
            The database ID of the item instance whose data should be returned.

    Returns:
        table|nil
            The item data table when the item exists, or nil when it cannot be found.
        string|nil
            An error message when the item cannot be found.

    Example Usage:
        ```lua
        local data = lia.item.getItemDataByID(15)
        if data then print(data.x, data.y) end
        ```

    Realm:
        Shared
]]
function lia.item.getItemDataByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item.data
end

--[[
    Purpose:
        Loads an item file path by deriving its unique ID and registering it as an item or base item.

    Parameters:
        path (string)
            The Lua file path to load.
        baseID (string|nil)
            The base item unique ID to inherit from, if any.
        isBaseItem (boolean|nil)
            Whether the file should be registered as a base item.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.load("lilia/gamemode/items/sh_example.lua")
        lia.item.load("lilia/gamemode/items/base/sh_weapons.lua", nil, true)
        ```

    Realm:
        Shared
]]
function lia.item.load(path, baseID, isBaseItem)
    local uniqueID = path:match("sh_([_%w]+)%.lua") or path:match("([_%w]+)%.lua")
    if uniqueID then
        uniqueID = (isBaseItem and "base_" or "") .. uniqueID
        lia.item.register(uniqueID, baseID, isBaseItem, path)
    elseif path:find("%.txt$") then
        local formatted = path:gsub("\\", "/"):lower()
        if not formatted:find("^lilia/") then lia.error("[Lilia] " .. L("textFileLuaRequired", path) .. "\n") end
    else
        lia.error("[Lilia] " .. L("invalidItemNaming", path) .. "\n")
    end
end

--[[
    Purpose:
        Checks whether a value is an item table.

    Parameters:
        object (any)
            The value to inspect.

    Returns:
        boolean
            True when the value is a table marked as an item, otherwise false.

    Example Usage:
        ```lua
        if lia.item.isItem(item) then print(item:getID()) end
        ```

    Realm:
        Shared
]]
function lia.item.isItem(object)
    return istable(object) and object.isItem
end

--[[
    Purpose:
        Returns a registered inventory instance by inventory ID.

    Parameters:
        invID (number)
            The inventory ID to retrieve.

    Returns:
        Inventory|nil
            The inventory instance, or nil if no inventory is loaded for the ID.

    Example Usage:
        ```lua
        local inventory = lia.item.getInv(item.invID)
        if inventory then print(inventory:getID()) end
        ```

    Realm:
        Shared
]]
function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

--[[
    Purpose:
        Registers an item rarity color under a rarity name.

    Parameters:
        name (string)
            The rarity name to register.
        color (Color)
            The color associated with the rarity.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.addRarities("Legendary", Color(255, 170, 0))
        ```

    Realm:
        Shared
]]
function lia.item.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.item.rarities[name] = color
end

--[[
    Purpose:
        Registers an item definition or base item and prepares inherited hooks, functions, localization, and overrides.

    Parameters:
        uniqueID (string)
            The unique ID to register.
        baseID (string|nil)
            The base item unique ID to inherit from.
        isBaseItem (boolean|nil)
            Whether the registration target is a base item.
        path (string|nil)
            The Lua file path to include for the item definition.
        luaGenerated (boolean|nil)
            Whether the item is being generated from Lua data instead of loaded from a file.

    Returns:
        Item
            The registered item definition.

    Example Usage:
        ```lua
        local itemDef = lia.item.register("example", "base_entities", false, nil, true)
        itemDef.name = "Example Item"
        ```

    Realm:
        Shared
]]
function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
    assert(isstring(uniqueID), L("itemUniqueIDString"))
    local baseTable = lia.item.base[baseID] or lia.meta.item
    if baseID then assert(baseTable, L("itemBaseNotFound", uniqueID, baseID)) end
    local targetTable = isBaseItem and lia.item.base or lia.item.list
    if luaGenerated then
        ITEM = setmetatable({
            hooks = table.Copy(baseTable.hooks or {}),
            postHooks = table.Copy(baseTable.postHooks or {}),
            BaseClass = baseTable,
            __tostring = baseTable.__tostring,
        }, {
            __eq = baseTable.__eq,
            __tostring = baseTable.__tostring,
            __index = baseTable
        })

        ITEM.__tostring = baseTable.__tostring
        ITEM.desc = "@noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "@misc"
        ITEM.functions = table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    else
        ITEM = targetTable[uniqueID] or setmetatable({
            hooks = table.Copy(baseTable.hooks or {}),
            postHooks = table.Copy(baseTable.postHooks or {}),
            BaseClass = baseTable,
            __tostring = baseTable.__tostring,
        }, {
            __eq = baseTable.__eq,
            __tostring = baseTable.__tostring,
            __index = baseTable
        })

        ITEM.__tostring = baseTable.__tostring
        ITEM.desc = "@noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "@misc"
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    end

    if not luaGenerated and path then lia.loader.include(path, "shared") end
    lia.item.localizeDefinition(ITEM)
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    if not isBaseItem then lia.item.applyWeaponOverride(itemType) end
    lia.item.localizeDefinition(targetTable[itemType])
    hook.Run("OnItemRegistered", ITEM)
    ITEM = nil
    return targetTable[itemType]
end

--[[
    Purpose:
        Resolves localization tokens on an item definition and its item function names or tips.

    Parameters:
        itemDef (Item|table)
            The item definition to localize.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        local itemDef = lia.item.get("water_bottle")
        lia.item.localizeDefinition(itemDef)
        ```

    Realm:
        Shared
]]
function lia.item.localizeDefinition(itemDef)
    if not istable(itemDef) then return end
    for funcName, funcTable in pairs(itemDef.functions or {}) do
        if isstring(funcTable.name) then
            funcTable.name = lia.lang.resolveToken(funcTable.name)
        else
            funcTable.name = lia.lang.resolveToken("@" .. funcName)
        end

        if isstring(funcTable.tip) then funcTable.tip = lia.lang.resolveToken(funcTable.tip) end
    end

    if isstring(itemDef.name) then itemDef.name = lia.lang.resolveToken(itemDef.name) end
    if isstring(itemDef.desc) then itemDef.desc = lia.lang.resolveToken(itemDef.desc) end
    if isstring(itemDef.category) then itemDef.category = lia.lang.resolveToken(itemDef.category) end
end

--[[
    Purpose:
        Queues a Lua-generated item registration to be finalized after modules initialize.

    Parameters:
        id (string)
            The unique ID of the item to register.
        base (string|nil)
            The base item unique ID to inherit from.
        properties (table|nil)
            Properties to copy onto the registered item definition.

    Returns:
        table
            A placeholder item table that proxies to the actual registered item once it exists.

    Example Usage:
        ```lua
        lia.item.registerItem("example_entity", "base_entities", {
            name = "Example Entity",
            entityid = "example_entity"
        })
        ```

    Realm:
        Shared
]]
function lia.item.registerItem(id, base, properties)
    assert(isstring(id), L("itemUniqueIDString"))
    if properties ~= nil and not istable(properties) then
        local errorMsg = string.format("properties must be a table or nil, got %s (type: %s)", tostring(properties), type(properties))
        lia.error(string.format("[Lilia] registerItem called with invalid properties for item '%s': %s\n", id, errorMsg))
        properties = {}
    end

    table.insert(lia.item.pendingRegistrations, {
        id = id,
        base = base,
        properties = properties
    })

    local placeholder = {
        uniqueID = id,
        base = base,
        _isPlaceholder = true
    }

    setmetatable(placeholder, {
        __index = function(self, key)
            if self._isPlaceholder then
                local actualItem = lia.item.get(id)
                if actualItem then return actualItem[key] end
            end
            return nil
        end
    })
    return placeholder
end

--[[
    Purpose:
        Queues overrides for an item definition to be applied after modules initialize.

    Parameters:
        uniqueID (string)
            The unique ID of the item to override.
        overrides (table)
            The fields, functions, hooks, or post hooks to merge into the item definition.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.overrideItem("water_bottle", {
            name = "Clean Water"
        })
        ```

    Realm:
        Shared
]]
function lia.item.overrideItem(uniqueID, overrides)
    assert(isstring(uniqueID), L("itemUniqueIDString"))
    assert(istable(overrides), "overrides must be a table")
    if not lia.item.pendingOverrides[uniqueID] then lia.item.pendingOverrides[uniqueID] = {} end
    for key, value in pairs(overrides) do
        lia.item.pendingOverrides[uniqueID][key] = value
    end
end

--[[
    Purpose:
        Loads base item files, category item files, and direct item files from an item directory.

    Parameters:
        directory (string)
            The Lua directory containing item files and optional base subdirectory.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.loadFromDir("lilia/gamemode/items")
        ```

    Realm:
        Shared
]]
function lia.item.loadFromDir(directory)
    local files, folders
    files = file.Find(directory .. "/base/*.lua", "LUA")
    for _, v in ipairs(files) do
        lia.item.load(directory .. "/base/" .. v, nil, true)
    end

    files, folders = file.Find(directory .. "/*", "LUA")
    for _, v in ipairs(folders) do
        if v == "base" then continue end
        for _, v2 in ipairs(file.Find(directory .. "/" .. v .. "/*.lua", "LUA")) do
            lia.item.load(directory .. "/" .. v .. "/" .. v2, "base_" .. v, nil)
        end
    end

    for _, v in ipairs(files) do
        lia.item.load(directory .. "/" .. v)
    end

    hook.Run("InitializedItems")
end

--[[
    Purpose:
        Creates or returns an item instance for a registered item definition and database ID.

    Parameters:
        uniqueID (string)
            The unique ID of the registered item definition.
        id (number|string)
            The item database ID, converted to a number when possible.

    Returns:
        Item
            The item instance for the provided unique ID and ID.

    Example Usage:
        ```lua
        local item = lia.item.new("water_bottle", 15)
        print(item:getID())
        ```

    Realm:
        Shared
]]
function lia.item.new(uniqueID, id)
    id = id and tonumber(id) or id
    assert(isnumber(id), L("itemNonNumberID"))
    if lia.item.instances[id] and lia.item.instances[id].uniqueID == uniqueID then return lia.item.instances[id] end
    local stockItem = lia.item.list[uniqueID]
    if stockItem then
        local item = setmetatable({
            id = id,
            data = {}
        }, {
            __eq = stockItem.__eq,
            __tostring = stockItem.__tostring,
            __index = stockItem
        })

        lia.item.instances[id] = item
        hook.Run("OnItemCreated", item)
        return item
    else
        error("[Lilia] " .. L("unknownItem", tostring(uniqueID)) .. "\n")
    end
end

--[[
    Purpose:
        Registers a grid inventory type with fixed width and height accessors.

    Parameters:
        invType (string)
            The inventory type name to register.
        w (number)
            The inventory width.
        h (number)
            The inventory height.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.registerInv("small_bag", 4, 4)
        ```

    Realm:
        Shared
]]
function lia.item.registerInv(invType, w, h)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, L("gridInvNotFound"))
    local inventory = GridInv:extend("GridInv" .. invType)
    inventory.invType = invType
    function inventory:getWidth()
        return w
    end

    function inventory:getHeight()
        return h
    end

    inventory:register(invType)
end

--[[
    Purpose:
        Creates a new inventory instance for a character owner and optionally syncs it to the owning player.

    Parameters:
        owner (number|nil)
            The character ID that owns the inventory.
        invType (string)
            The inventory type to instantiate.
        callback (function|nil)
            Called with the created inventory after it is available.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.newInv(charID, "grid", function(inventory)
            print(inventory:getID())
        end)
        ```

    Realm:
        Shared
]]
function lia.item.newInv(owner, invType, callback)
    lia.inventory.instance(invType, {
        char = owner
    }):next(function(inventory)
        inventory.invType = invType
        if owner and owner > 0 then
            for _, v in player.Iterator() do
                if v:getChar() and v:getChar():getID() == owner then
                    inventory:sync(v)
                    break
                end
            end
        end

        if callback then callback(inventory) end
    end)
end

--[[
    Purpose:
        Creates a grid inventory instance immediately using the provided dimensions and ID.

    Parameters:
        w (number)
            The inventory width.
        h (number)
            The inventory height.
        id (number)
            The inventory ID to assign to the new instance.

    Returns:
        Inventory
            The created grid inventory instance.

    Example Usage:
        ```lua
        local inventory = lia.item.createInv(4, 4, 1001)
        ```

    Realm:
        Shared
]]
function lia.item.createInv(w, h, id)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, L("gridInvNotFound"))
    local instance = GridInv:new()
    instance.id = id
    instance.data = {
        w = w,
        h = h
    }

    lia.inventory.instances[id] = instance
    return instance
end

lia.item.holdTypeSizeMapping = {
    grenade = {
        width = 1,
        height = 1
    },
    pistol = {
        width = 1,
        height = 1
    },
    smg = {
        width = 2,
        height = 1
    },
    ar2 = {
        width = 2,
        height = 2
    },
    rpg = {
        width = 1,
        height = 2
    },
    shotgun = {
        width = 2,
        height = 1
    },
    crossbow = {
        width = 1,
        height = 2
    },
    normal = {
        width = 2,
        height = 1
    },
    melee = {
        width = 1,
        height = 1
    },
    melee2 = {
        width = 1,
        height = 1
    },
    fist = {
        width = 1,
        height = 1
    },
    knife = {
        width = 1,
        height = 1
    },
    physgun = {
        width = 2,
        height = 1
    },
    slam = {
        width = 1,
        height = 2
    },
    passive = {
        width = 1,
        height = 1
    }
}

--[[
    Purpose:
        Stores item definition override data for a generated weapon item class.

    Parameters:
        className (string)
            The weapon class or generated item unique ID to override.
        data (table)
            The override fields to apply to the generated item definition.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.addWeaponOverride("weapon_pistol", {
            width = 1,
            height = 1
        })
        ```

    Realm:
        Shared
]]
function lia.item.addWeaponOverride(className, data)
    lia.item.WeaponOverrides[className] = data
end

--[[
    Purpose:
        Prevents a weapon class from being converted into an automatically generated item.

    Parameters:
        className (string)
            The weapon class name to blacklist.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.item.addWeaponToBlacklist("weapon_example_base")
        ```

    Realm:
        Shared
]]
function lia.item.addWeaponToBlacklist(className)
    lia.item.WeaponsBlackList[className] = true
end

--[[
    Purpose:
        Applies a value to a nested field on a weapon table using a dot-separated path.

    Parameters:
        wepTable (table)
            The weapon table to modify.
        dotPath (string)
            The dot-separated nested field path to write.
        value (any)
            The value to assign at the destination path.

    Returns:
        boolean
            True when the value was applied, otherwise false.

    Example Usage:
        ```lua
        local ok = lia.item.applyRuntimeOverridePath(SWEP, "Primary.Damage", 35)
        ```

    Realm:
        Shared
]]
function lia.item.applyRuntimeOverridePath(wepTable, dotPath, value)
    if not istable(wepTable) then return false end
    local parts = string.Explode(".", dotPath)
    if #parts < 2 then return false end
    local cur = wepTable
    for i = 1, #parts - 1 do
        local seg = parts[i]
        if not istable(cur[seg]) then return false end
        cur = cur[seg]
    end

    cur[parts[#parts]] = value
    return true
end

--[[
    Purpose:
        Reads a nested value from a weapon table using a dot-separated path.

    Parameters:
        wepTable (table)
            The weapon table to read from.
        dotPath (string)
            The dot-separated nested field path to read.

    Returns:
        any|nil
            The nested value when the path exists, or nil when it cannot be resolved.

    Example Usage:
        ```lua
        local damage = lia.item.getRuntimeValue(SWEP, "Primary.Damage")
        ```

    Realm:
        Shared
]]
function lia.item.getRuntimeValue(wepTable, dotPath)
    if not istable(wepTable) then return nil end
    local parts = string.Explode(".", dotPath)
    local cur = wepTable
    for _, seg in ipairs(parts) do
        if not istable(cur) then return nil end
        cur = cur[seg]
    end
    return cur
end

if SERVER then
    --[[
        Purpose:
            Sets a data key on an instantiated item by database ID.

        Parameters:
            itemID (number)
                The database ID of the item instance to update.
            key (string)
                The data key to set.
            value (any)
                The value to store.
            receivers (Player|table|nil)
                Optional networking recipients for the data update.
            noSave (boolean|nil)
                Whether to skip saving the data change.
            noCheckEntity (boolean|nil)
                Whether to skip entity validity checks during the update.

        Returns:
            boolean
                True when the data was set, or false when the item was not found.
            string|nil
                An error message when the item cannot be found.

        Example Usage:
            ```lua
            local ok, err = lia.item.setItemDataByID(15, "uses", 2)
            ```

        Realm:
            Server
    ]]
    function lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)
        assert(isnumber(itemID), L("itemIDNumberRequired"))
        assert(isstring(key), L("itemKeyString"))
        local item = lia.item.instances[itemID]
        if not item then return false, L("itemNotFound") end
        item:setData(key, value, receivers, noSave, noCheckEntity)
        return true
    end

    --[[
        Purpose:
            Creates a persistent item database record and item instance.

        Parameters:
            index (number|string|nil)
                The inventory ID for the new item, or the unique ID when using the shorthand overload.
            uniqueID (string|table|nil)
                The item unique ID, or item data when using the shorthand overload.
            itemData (table|nil)
                Initial data to store on the item.
            x (number|nil)
                The item inventory X position.
            y (number|nil)
                The item inventory Y position.
            callback (function|nil)
                Called with the created item after the database insert completes.

        Returns:
            deferred
                A deferred object that resolves with the created item or rejects with an error message.

        Example Usage:
            ```lua
            lia.item.instance(invID, "water_bottle", {}, 1, 1, function(item)
                print(item:getID())
            end)
            ```

        Realm:
            Server
    ]]
    function lia.item.instance(index, uniqueID, itemData, x, y, callback)
        if isstring(index) and (istable(uniqueID) or itemData == nil and x == nil) then
            itemData = uniqueID
            uniqueID = index
        end

        local d = deferred.new()
        local itemTable = lia.item.list[uniqueID]
        if not itemTable then
            d:reject(L("invalidItemInstantiate", tostring(uniqueID)))
            return d
        end

        if not istable(itemData) then itemData = {} end
        if isnumber(itemData.x) then
            x = itemData.x
            itemData.x = nil
        end

        if isnumber(itemData.y) then
            y = itemData.y
            itemData.y = nil
        end

        local function onItemCreated(_, itemID)
            local item = lia.item.new(uniqueID, itemID)
            if item then
                item.data = itemData
                item.invID = index
                item.data.x = x
                item.data.y = y
                item.quantity = itemTable.maxQuantity
                if callback then callback(item) end
                d:resolve(item)
                item:onInstanced(index, x, y, item)
            end
        end

        if not isnumber(index) then index = NULL end
        lia.db.insertTable({
            invID = index,
            uniqueID = uniqueID,
            data = itemData,
            x = x,
            y = y,
            quantity = itemTable.maxQuantity or 1
        }, onItemCreated, "items")
        return d
    end

    --[[
        Purpose:
            Deletes an item by database ID, using the loaded instance when available or a direct database delete otherwise.

        Parameters:
            id (number)
                The item database ID to delete.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.item.deleteByID(15)
            ```

        Realm:
            Server
    ]]
    function lia.item.deleteByID(id)
        if lia.item.instances[id] then
            lia.item.instances[id]:delete()
        else
            lia.db.delete("items", "itemID = " .. id)
        end
    end

    --[[
        Purpose:
            Loads one or more items from the database into the item instance cache.

        Parameters:
            itemIndex (number|table)
                A single item ID or a table of item IDs to restore.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.item.loadItemByID(15)
            lia.item.loadItemByID({15, 16, 17})
            ```

        Realm:
            Server
    ]]
    function lia.item.loadItemByID(itemIndex)
        local range
        if istable(itemIndex) then
            range = "(" .. table.concat(itemIndex, ", ") .. ")"
        elseif isnumber(itemIndex) then
            range = "(" .. itemIndex .. ")"
        else
            return
        end

        lia.db.query("SELECT itemID, uniqueID, data, x, y, quantity FROM lia_items WHERE itemID IN " .. range, function(results)
            if not results then return end
            for _, row in ipairs(results) do
                local id = tonumber(row.itemID)
                local itemDef = lia.item.list[row.uniqueID]
                if id and itemDef then
                    local item = lia.item.new(row.uniqueID, id)
                    local itemData = util.JSONToTable(row.data or "[]") or {}
                    item.invID = 0
                    item.data = itemData
                    item.data.x = tonumber(row.x)
                    item.data.y = tonumber(row.y)
                    item.quantity = tonumber(row.quantity)
                    item:onRestored()
                end
            end
        end)
    end

    --[[
        Purpose:
            Creates an item instance and spawns it into the world.

        Parameters:
            uniqueID (string)
                The unique ID of the item definition to spawn.
            position (Vector)
                The world position where the item should be spawned.
            callback (function|Angle|nil)
                Called with the spawned item, or used as angles when no callback is provided.
            angles (Angle|table|nil)
                The spawn angles, or item data when passed through the angle overload.
            data (table|nil)
                Initial data to store on the spawned item.

        Returns:
            deferred|nil
                A deferred object when no callback function is supplied, otherwise nil.

        Example Usage:
            ```lua
            lia.item.spawn("water_bottle", client:GetPos(), function(item)
                if item then print(item:getID()) end
            end)
            ```

        Realm:
            Server
    ]]
    function lia.item.spawn(uniqueID, position, callback, angles, data)
        local d
        if not isfunction(callback) then
            if isangle(callback) or istable(angles) then
                angles = callback
                data = angles
            end

            d = deferred.new()
            callback = function(item) d:resolve(item) end
        end

        local promise = lia.item.instance(0, uniqueID, data or {}, 1, 1, function(item)
            item:spawn(position, angles)
            if callback then callback(item) end
        end)

        promise:next(function() end, function(reason)
            if reason and reason:find("An inventory has a missing item") then
                lia.error(reason)
            else
                lia.error(L("failedToSpawnItem", tostring(reason or L("unknownError"))))
            end

            if callback then callback(nil) end
        end)
        return d
    end

    --[[
        Purpose:
            Loads an inventory by ID, restores its dimensions, and optionally passes it to a callback.

        Parameters:
            invID (number)
                The inventory ID to load.
            w (number)
                The restored inventory width.
            h (number)
                The restored inventory height.
            callback (function|nil)
                Called with the restored inventory when it is available.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.item.restoreInv(invID, 6, 4, function(inventory)
                inventory:sync(client)
            end)
            ```

        Realm:
            Server
    ]]
    function lia.item.restoreInv(invID, w, h, callback)
        lia.inventory.loadByID(invID):next(function(inventory)
            if not inventory then return end
            inventory:setData("w", w)
            inventory:setData("h", h)
            if callback then callback(inventory) end
        end)
    end
end

lia.item.loadFromDir("lilia/gamemode/items")
hook.Add("InitializedModules", "liaItems", function()
    for _, registration in ipairs(lia.item.pendingRegistrations) do
        local item = lia.item.register(registration.id, registration.base, false, nil, true)
        if registration.properties then
            for key, value in pairs(registration.properties) do
                item[key] = value
            end

            lia.item.localizeDefinition(item)
        end
    end

    lia.item.pendingRegistrations = {}
    if lia.config.get("AutoWeaponItemGeneration", true) then
        for _, wep in ipairs(weapons.GetList()) do
            local className = wep.ClassName
            if not className or className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
            local override = lia.item.WeaponOverrides[className] or {}
            local holdType = wep.HoldType or "normal"
            local isGrenade = holdType == "grenade"
            local baseType = isGrenade and "base_grenade" or "base_weapons"
            local size = lia.item.holdTypeSizeMapping[holdType] or {
                width = 2,
                height = 1
            }

            local properties = {
                name = hook.Run("GetWeaponName", wep) or override.name or className,
                desc = override.desc or L("weaponsDesc"),
                category = override.category or isGrenade and L("itemCatGrenades") or L("weapons"),
                model = override.model or wep.WorldModel or wep.WM or "models/props_c17/suitcase_passenger_physics.mdl",
                class = override.class or className,
                width = override.width or size.width,
                height = override.height or size.height
            }

            if override.weaponCategory then properties.weaponCategory = override.weaponCategory end
            local item = lia.item.register(className, baseType, false, nil, true)
            for key, value in pairs(properties) do
                item[key] = value
            end

            lia.item.localizeDefinition(item)
        end
    end

    if lia.config.get("AutoAmmoItemGeneration", true) then
        local entityList = {}
        local scriptedEntities = scripted_ents.GetList()
        for className, _ in pairs(scriptedEntities) do
            if isstring(className) and className then entityList[className] = true end
        end

        for className, _ in pairs(entityList) do
            if not className or not isstring(className) then continue end
            local isArc9Ammo = className:find("^arc9_ammo_")
            local isArccwAmmo = className:find("^arccw_ammo_")
            local isTfaAmmo = className:find("^tfa_ammo_")
            if not (isArc9Ammo or isArccwAmmo or isTfaAmmo) then continue end
            if className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
            local override = lia.item.WeaponOverrides[className] or {}
            local baseType = "base_entities"
            local entityID = className
            local ammoType
            local itemName
            if isArc9Ammo then
                ammoType = className:gsub("^arc9_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or L("generatedArc9AmmoName", ammoType)
            elseif isArccwAmmo then
                ammoType = className:gsub("^arccw_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or L("generatedArccwAmmoName", ammoType)
            elseif isTfaAmmo then
                ammoType = className:gsub("^tfa_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or L("generatedTfaAmmoName", ammoType)
            else
                itemName = override.name or className
                ammoType = className
            end

            local properties = {
                name = itemName,
                desc = override.desc or L("generatedAmmoBoxDesc", ammoType),
                category = override.category or L("itemCatAmmunition"),
                model = override.model or "models/items/boxsrounds.mdl",
                entityid = override.entityid or entityID,
                width = override.width or 1,
                height = override.height or 1
            }

            lia.item.registerItem(className, baseType, properties)
        end
    end

    lia.item.itemEntities = {}
    for _, item in pairs(lia.item.list) do
        if item.base == "base_entities" then lia.item.itemEntities[item.uniqueID] = {item.entityid, item.data} end
    end

    if lia.config.get("ItemsCanBeDestroyed", true) then
        for _, item in pairs(lia.item.list) do
            item.CanBeDestroyed = true
        end
    end

    for uniqueID, overrides in pairs(lia.item.pendingOverrides) do
        local item = lia.item.get(uniqueID)
        if item then
            for key, value in pairs(overrides) do
                if isfunction(value) then
                    item[key] = value
                elseif istable(value) then
                    if key == "functions" then
                        item.functions = item.functions or {}
                        for funcName, funcData in pairs(value) do
                            item.functions[funcName] = funcData
                        end
                    elseif key == "hooks" then
                        item.hooks = item.hooks or {}
                        for hookName, hookFunc in pairs(value) do
                            item.hooks[hookName] = hookFunc
                        end
                    elseif key == "postHooks" then
                        item.postHooks = item.postHooks or {}
                        for hookName, hookFunc in pairs(value) do
                            item.postHooks[hookName] = hookFunc
                        end
                    else
                        item[key] = value
                    end
                else
                    item[key] = value
                end
            end

            lia.item.localizeDefinition(item)
            hook.Run("OnItemOverridden", item, overrides)
        else
            lia.error("[Lilia] Cannot override item '" .. tostring(uniqueID) .. "': item not found\n")
        end
    end

    lia.item.pendingOverrides = {}
end)

if SERVER then
    --[[
        Purpose:
            Loads saved generated weapon item override data and applies it to registered item definitions.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.item.loadWeaponOverrides()
            ```

        Realm:
            Server
    ]]
    function lia.item.loadWeaponOverrides()
        local stored = lia.data.get("weaponOverrides") or {}
        lia.item.WeaponOverrides = stored
        for className, data in pairs(lia.item.WeaponOverrides) do
            local itemDef = lia.item.list[className]
            if itemDef and istable(data) then
                for k, v in pairs(data) do
                    itemDef[k] = v
                end
            end
        end
    end

    --[[
        Purpose:
            Loads saved runtime weapon stat overrides and applies them to stored weapon tables.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.item.loadWeaponRuntimeOverrides()
            ```

        Realm:
            Server
    ]]
    function lia.item.loadWeaponRuntimeOverrides()
        local stored = lia.data.get("weaponRuntimeOverrides") or {}
        lia.item.WeaponRuntimeOverrides = stored
        for className, paths in pairs(stored) do
            local wep = weapons.GetStored(className)
            if wep then
                for dotPath, value in pairs(paths) do
                    lia.item.applyRuntimeOverridePath(wep, dotPath, value)
                end
            end
        end
    end
else
    local function CreateEntry(scroll, className, weaponTable, overrideData)
        local container = scroll:Add("DPanel")
        container:SetTall(50)
        container:Dock(TOP)
        container:DockMargin(5, 0, 0, 3)
        local expanded = false
        local expandedHeight = 660
        local header = container:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(50)
        header.Paint = function(s, w, h)
            local theme = lia.color.theme
            local accent = theme.accent or theme.theme or Color(116, 185, 255)
            local headerBase = (theme and theme.button_hovered) or (theme and theme.button) or Color(60, 70, 85)
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(headerBase, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, h - 2, w, 2):Color(ColorAlpha(accent, 150)):Draw()
            if s:IsHovered() then lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(255, 255, 255, 10)):Draw() end
        end

        header:SetCursor("hand")
        local nameLabel = header:Add("DLabel")
        nameLabel:Dock(LEFT)
        nameLabel:DockMargin(15, 0, 0, 0)
        nameLabel:SetFont("LiliaFont.25")
        nameLabel:SetText(L(weaponTable.PrintName or className))
        nameLabel:SizeToContents()
        nameLabel:SetTextColor(lia.color.theme.text)
        local expandBtn = header:Add("DLabel")
        expandBtn:Dock(RIGHT)
        expandBtn:DockMargin(0, 0, 15, 0)
        expandBtn:SetFont("LiliaFont.25")
        expandBtn:SetText("+")
        expandBtn:SizeToContents()
        expandBtn:SetTextColor(lia.color.theme.text)
        local content = container:Add("DPanel")
        content:Dock(FILL)
        content:DockMargin(10, 5, 10, 5)
        content:SetVisible(false)
        content.Paint = function() end
        header.OnMousePressed = function()
            expanded = not expanded
            container:SetTall(expanded and expandedHeight or 50)
            content:SetVisible(expanded)
            expandBtn:SetText(expanded and "-" or "+")
            scroll:InvalidateLayout(true)
        end

        local function AddField(label, key, default, isNum)
            local p = content:Add("DPanel")
            p:Dock(TOP)
            p:SetTall(35)
            p:DockMargin(0, 3, 0, 0)
            p.Paint = function() end
            local l = p:Add("DLabel")
            l:Dock(LEFT)
            l:SetWidth(100)
            l:SetText(label)
            l:SetFont("LiliaFont.18")
            l:SetTextColor(lia.color.theme.text)
            local entry = p:Add("liaEntry")
            entry:Dock(FILL)
            local val = overrideData[key] or default
            if val then entry:SetValue(tostring(val)) end
            entry.textEntry.OnEnter = function(s)
                local newValue = s:GetValue()
                if isNum then newValue = tonumber(newValue) end
                net.Start("liaWeaponOverrideUpdate")
                net.WriteString(className)
                net.WriteString(key)
                net.WriteType(newValue)
                net.SendToServer()
                overrideData[key] = newValue
            end
        end

        local defWidth = 2
        local defHeight = 1
        AddField(L("name"), "name", weaponTable.PrintName or className, false)
        AddField(L("desc"), "desc", L("weaponsDesc"), false)
        AddField(L("model"), "model", weaponTable.WorldModel or "models/props_c17/BriefCase001a.mdl", false)
        AddField(L("weaponItemWidth"), "width", defWidth, true)
        AddField(L("weaponItemHeight"), "height", defHeight, true)
        AddField(L("price"), "price", 500, true)
        AddField(L("Category"), "category", L("weapons"), false)
        local runtimeFields = {{"Primary.Damage", "Pri.Damage", true}, {"Primary.NumShots", "Pri.Shots", true}, {"Primary.Recoil", "Pri.Recoil", true}, {"Primary.Cone", "Pri.Cone", true}, {"Primary.Delay", "Pri.Delay", true}, {"Secondary.Damage", "Sec.Damage", true},}
        local sepPanel = content:Add("DPanel")
        sepPanel:Dock(TOP)
        sepPanel:SetTall(26)
        sepPanel:DockMargin(0, 8, 0, 4)
        sepPanel.Paint = function(s, w, h)
            draw.SimpleText("Runtime SWEP Stats", "LiliaFont.18b", 0, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local accent = lia.color.theme.accent or lia.color.theme.theme or Color(116, 185, 255)
            surface.SetDrawColor(accent)
            surface.DrawLine(0, h - 1, w, h - 1)
        end

        local livewep = weapons.Get(className)
        local runtimeOverrides = lia.item.WeaponRuntimeOverrides[className] or {}
        local function AddRuntimeField(dotPath, label)
            local default = livewep and lia.item.getRuntimeValue(livewep, dotPath)
            local current = runtimeOverrides[dotPath] ~= nil and runtimeOverrides[dotPath] or default
            local p = content:Add("DPanel")
            p:Dock(TOP)
            p:SetTall(35)
            p:DockMargin(0, 3, 0, 0)
            p.Paint = function() end
            local l = p:Add("DLabel")
            l:Dock(LEFT)
            l:SetWidth(100)
            l:SetText(label)
            l:SetFont("LiliaFont.18")
            l:SetTextColor(lia.color.theme.text)
            local entry = p:Add("liaEntry")
            entry:Dock(FILL)
            if current ~= nil then entry:SetValue(tostring(current)) end
            entry.textEntry.OnEnter = function(s)
                local raw = s:GetValue()
                net.Start("liaWeaponRuntimeOverrideUpdate")
                net.WriteString(className)
                net.WriteString(dotPath)
                net.WriteString(raw)
                net.SendToServer()
                lia.item.WeaponRuntimeOverrides[className] = lia.item.WeaponRuntimeOverrides[className] or {}
                lia.item.WeaponRuntimeOverrides[className][dotPath] = raw
            end
        end

        for _, rf in ipairs(runtimeFields) do
            AddRuntimeField(rf[1], rf[2])
        end

        local resetBtn = content:Add("DButton")
        resetBtn:Dock(TOP)
        resetBtn:SetTall(30)
        resetBtn:DockMargin(0, 8, 0, 0)
        resetBtn:SetText("Reset Runtime Overrides")
        resetBtn:SetFont("LiliaFont.18")
        resetBtn.DoClick = function()
            net.Start("liaWeaponRuntimeOverrideReset")
            net.WriteString(className)
            net.SendToServer()
            lia.item.WeaponRuntimeOverrides[className] = nil
        end
    end

    hook.Add("PopulateConfigurationButtons", "liaWeaponItemsConfig", function(pages)
        pages[#pages + 1] = {
            name = L("weaponItemsConfig"),
            shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
            drawFunc = function(parent)
                parent:Clear()
                local searchBar = parent:Add("liaEntry")
                searchBar:Dock(TOP)
                searchBar:DockMargin(10, 10, 10, 10)
                searchBar:SetTall(35)
                searchBar:SetPlaceholderText(L("searchWeapons"))
                local scroll = parent:Add("liaScrollPanel")
                scroll:Dock(FILL)
                local function Populate(filter)
                    scroll:Clear()
                    filter = filter and filter:lower() or ""
                    local weaponsList = weapons.GetList()
                    table.sort(weaponsList, function(a, b) return (a.PrintName or a.ClassName) < (b.PrintName or b.ClassName) end)
                    for _, wep in ipairs(weaponsList) do
                        local className = wep.ClassName
                        if not className or className:find("_base") or (lia.item.WeaponsBlackList and lia.item.WeaponsBlackList[className]) then continue end
                        local name = wep.PrintName or className
                        if filter ~= "" and not name:lower():find(filter, 1, true) and not className:lower():find(filter, 1, true) then continue end
                        local overrides = lia.item.WeaponOverrides[className] or {}
                        CreateEntry(scroll, className, wep, overrides)
                    end
                end

                searchBar.OnTextChanged = function(s) Populate(s:GetValue()) end
                Populate()
            end
        }
    end)
end

lia.item.registerItem("lia_ammobox", "base_entities", {
    name = "@liaAmmoBoxItemName",
    desc = "@liaAmmoBoxItemDesc",
    model = "models/items/boxsrounds.mdl",
    category = "entities",
    width = 1,
    height = 1,
    entityid = "lia_ammobox"
})

local RUNTIME_SNAPSHOT_PATHS = {"Primary.Damage", "Primary.NumShots", "Primary.Recoil", "Primary.Cone", "Primary.Delay", "Primary.ClipSize", "Secondary.Damage", "Secondary.NumShots", "Secondary.Recoil", "Secondary.Cone", "Secondary.Delay",}
hook.Add("InitPostEntity", "liaWeaponRuntimeDefaults", function()
    lia.item.defaultRuntimeValues = {}
    for _, wep in ipairs(weapons.GetList()) do
        local cls = wep.ClassName
        if not cls then continue end
        lia.item.defaultRuntimeValues[cls] = {}
        for _, path in ipairs(RUNTIME_SNAPSHOT_PATHS) do
            local val = lia.item.getRuntimeValue(wep, path)
            if val ~= nil then lia.item.defaultRuntimeValues[cls][path] = val end
        end
    end
end)