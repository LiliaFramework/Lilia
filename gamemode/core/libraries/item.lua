--[[
    Folder: Libraries
    File: item.md
]]
--[[
    Item

    Comprehensive item registration, instantiation, and management system for the Lilia framework.
]]
--[[
    Overview:
        The item library provides comprehensive functionality for managing items in the Lilia framework. It handles item registration, instantiation, inventory management, and item operations such as dropping, taking, rotating, and transferring items between players. The library operates on both server and client sides, with server-side functions handling database operations, item spawning, and data persistence, while client-side functions manage item interactions and UI operations. It includes automatic weapon and ammunition generation from Garry's Mod weapon lists, inventory type registration, and item entity management. The library ensures proper item lifecycle management from creation to deletion, with support for custom item functions, hooks, and data persistence.
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

            target:requestBinaryQuestion(L("itemGiveRequest", client:Name(), L(item.name)), L("yes"), L("no"), function(choice)
                if choice == 0 then
                    inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    client:setAction(L("givingItemTo", L(item.name), target:Name()), lia.config.get("ItemGiveSpeed", 6))
                    target:setAction(L("givingYouItem", client:Name(), L(item.name)), lia.config.get("ItemGiveSpeed", 6))
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
        Retrieves an item definition (base or regular item) by its unique identifier.

    When Called:
        Called when needing to access item definitions for registration, validation, or manipulation.

    Parameters:
        identifier (string)
            The unique identifier of the item to retrieve.

    Returns:
        table or nil
            The item definition table if found, nil if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local weaponItem = lia.item.get("weapon_pistol")
            if weaponItem then
                print("Found weapon:", weaponItem.name)
            end
        ```
]]
function lia.item.get(identifier)
    return lia.item.base[identifier] or lia.item.list[identifier]
end

--[[
    Purpose:
        Applies weapon override data to an existing item definition.

    When Called:
        Called during item registration to ensure weapon overrides are applied
        after the base item properties are set but before final localization.

    Parameters:
        uniqueID (string)
            The unique ID of the item to apply overrides to.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- This function is typically called internally during item registration
            lia.item.applyWeaponOverride("weapon_pistol")
        ```
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
        Retrieves an instanced item by its ID and determines its current location.

    When Called:
        Called when needing to access specific item instances, typically for manipulation or inspection.

    Parameters:
        itemID (number)
            The unique ID of the instanced item to retrieve.

    Returns:
        table or nil, string
            A table containing the item and its location ("inventory", "world", or "unknown"), or nil and an error message if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local itemData, errorMsg = lia.item.getItemByID(123)
            if itemData then
                print("Item found at:", itemData.location)
                -- Use itemData.item for item operations
            else
                print("Error:", errorMsg)
            end
        ```
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
        Retrieves an instanced item directly by its ID without location information.

    When Called:
        Called when needing to access item instances for direct manipulation without location context.

    Parameters:
        itemID (number)
            The unique ID of the instanced item to retrieve.

    Returns:
        table or nil, string
            The item instance if found, or nil and an error message if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local item, errorMsg = lia.item.getInstancedItemByID(123)
            if item then
                item:setData("customValue", "example")
            else
                print("Error:", errorMsg)
            end
        ```
]]
function lia.item.getInstancedItemByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item
end

--[[
    Purpose:
        Retrieves the data table of an instanced item by its ID.

    When Called:
        Called when needing to access or inspect the custom data stored on an item instance.

    Parameters:
        itemID (number)
            The unique ID of the instanced item to retrieve data from.

    Returns:
        table or nil, string
            The item's data table if found, or nil and an error message if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local data, errorMsg = lia.item.getItemDataByID(123)
            if data then
                print("Item durability:", data.durability or "N/A")
            else
                print("Error:", errorMsg)
            end
        ```
]]
function lia.item.getItemDataByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item.data
end

--[[
    Purpose:
        Loads and registers an item from a file path by extracting the unique ID and registering it.

    When Called:
        Called during item loading process to register items from files in the items directory.

    Parameters:
        path (string)
            The file path of the item to load.
        baseID (string, optional)
            The base item ID to inherit from.
        isBaseItem (boolean, optional)
            Whether this is a base item definition.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Load a regular item
            lia.item.load("lilia/gamemode/items/food_apple.lua")
            -- Load a base item
            lia.item.load("lilia/gamemode/items/base/food.lua", nil, true)
        ```
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
        Checks if an object is a valid Lilia item instance.

    When Called:
        Called to validate that an object is an item before performing item-specific operations.

    Parameters:
        object (any)
            The object to check if it's an item.

    Returns:
        boolean
            True if the object is a valid item, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            local someObject = getSomeObject()
            if lia.item.isItem(someObject) then
                someObject:setData("used", true)
            else
                print("Object is not an item")
            end
        ```
]]
function lia.item.isItem(object)
    return istable(object) and object.isItem
end

--[[
    Purpose:
        Retrieves an inventory instance by its ID.

    When Called:
        Called when needing to access inventory objects for item operations or inspection.

    Parameters:
        invID (number)
            The unique ID of the inventory to retrieve.

    Returns:
        table or nil
            The inventory instance if found, nil if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local inventory = lia.item.getInv(5)
            if inventory then
                print("Inventory size:", inventory:getWidth(), "x", inventory:getHeight())
            end
        ```
]]
function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

--[[
    Purpose:
        Adds a new item rarity tier with an associated color for visual identification.

    When Called:
        Called during item system initialization to define available rarity levels for items.

    Parameters:
        name (string)
            The name of the rarity tier (e.g., "Common", "Rare", "Legendary").
        color (Color)
            The color associated with this rarity tier.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.item.addRarities("Mythical", Color(255, 0, 255))
            lia.item.addRarities("Divine", Color(255, 215, 0))
        ```
]]
function lia.item.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.item.rarities[name] = color
end

--[[
    Purpose:
        Registers an item definition with the Lilia item system, setting up inheritance and default functions.

    When Called:
        Called during item loading to register item definitions, either from files or programmatically generated.

    Parameters:
        uniqueID (string)
            The unique identifier for the item.
        baseID (string, optional)
            The base item ID to inherit from (defaults to lia.meta.item).
        isBaseItem (boolean, optional)
            Whether this is a base item definition.
        path (string, optional)
            The file path for loading the item (used for shared loading).
        luaGenerated (boolean, optional)
            Whether the item is generated programmatically rather than loaded from a file.

    Returns:
        table
            The registered item definition table.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Register a base item
            lia.item.register("base_weapon", nil, true, "path/to/base_weapon.lua")
            -- Register a regular item
            lia.item.register("weapon_pistol", "base_weapon", false, "path/to/weapon_pistol.lua")
        ```
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
        ITEM.desc = "noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "misc"
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
        ITEM.desc = "noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "misc"
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    end

    if not luaGenerated and path then lia.loader.include(path, "shared") end
    for funcName, funcTable in pairs(ITEM.functions) do
        if isstring(funcTable.name) then
            funcTable.name = L(funcTable.name)
        else
            funcTable.name = L(funcName)
        end

        if isstring(funcTable.tip) then funcTable.tip = L(funcTable.tip) end
    end

    if isstring(ITEM.name) then ITEM.name = L(ITEM.name) end
    if isstring(ITEM.desc) then ITEM.desc = L(ITEM.desc) end
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    if not isBaseItem then lia.item.applyWeaponOverride(itemType) end
    if isstring(ITEM.name) then ITEM.name = L(ITEM.name) end
    if isstring(ITEM.desc) then ITEM.desc = L(ITEM.desc) end
    hook.Run("OnItemRegistered", ITEM)
    ITEM = nil
    return targetTable[itemType]
end

--[[
    Purpose:
        Queues an item for deferred registration and returns a placeholder that can access the item once registered.

    When Called:
        Called during item system initialization to register items that will be created later, such as auto-generated weapons or ammunition items.

    Parameters:
        id (string)
            The unique identifier for the item to register.
        base (string, optional)
            The base item ID to inherit from.
        properties (table, optional)
            A table of properties to apply to the item when it is registered.

    Returns:
        table
            A placeholder object that can access the actual item properties once registration is complete.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Queue a weapon item for registration
            local weaponPlaceholder = lia.item.registerItem("weapon_pistol", "base_weapons", {
                name = "Custom Pistol",
                width = 2,
                height = 1
            })
            -- The actual item will be registered when InitializedModules hook runs
        ```
]]
function lia.item.registerItem(id, base, properties)
    assert(isstring(id), L("itemUniqueIDString"))
    assert(istable(properties) or properties == nil, "properties must be a table or nil")
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
        Queues property overrides for an item that will be applied when the item is initialized.

    When Called:
        Called during item system setup to modify item properties before they are finalized.

    Parameters:
        uniqueID (string)
            The unique ID of the item to override.
        overrides (table)
            A table of properties to override on the item.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.item.overrideItem("weapon_pistol", {
                name = "Custom Pistol",
                width = 2,
                height = 1,
                price = 500
            })
        ```
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
        Loads all items from a directory structure, organizing base items and regular items.

    When Called:
        Called during gamemode initialization to load all item definitions from the items directory.

    Parameters:
        directory (string)
            The directory path containing the item files to load.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Load all items from the gamemode's items directory
            lia.item.loadFromDir("lilia/gamemode/items")
        ```
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
        Creates a new item instance from an item definition with a specific ID.

    When Called:
        Called when instantiating items from the database or creating new items programmatically.

    Parameters:
        uniqueID (string)
            The unique ID of the item definition to instantiate.
        id (number)
            The unique instance ID for this item.

    Returns:
        table
            The newly created item instance.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Create a new pistol item instance
            local pistol = lia.item.new("weapon_pistol", 123)
            pistol:setData("durability", 100)
        ```
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
        Registers a new inventory type with specified dimensions.

    When Called:
        Called during inventory system initialization to define different inventory types.

    Parameters:
        invType (string)
            The unique type identifier for this inventory.
        w (number)
            The width of the inventory in grid units.
        h (number)
            The height of the inventory in grid units.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Register a backpack inventory type
            lia.item.registerInv("backpack", 4, 6)
            -- Register a safe inventory type
            lia.item.registerInv("safe", 8, 8)
        ```
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
        Creates a new inventory instance for a character and syncs it with the appropriate player.

    When Called:
        Called when creating new inventories for characters, such as during character creation or item operations.

    Parameters:
        owner (number)
            The character ID that owns this inventory.
        invType (string)
            The type of inventory to create.
        callback (function, optional)
            Function called when the inventory is created and ready.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Create a backpack inventory for character ID 5
            lia.item.newInv(5, "backpack", function(inventory)
                print("Backpack created with ID:", inventory:getID())
            end)
        ```
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
        Creates a new inventory instance with specified dimensions and registers it.

    When Called:
        Called when creating inventories programmatically, such as for containers or special storage.

    Parameters:
        w (number)
            The width of the inventory in grid units.
        h (number)
            The height of the inventory in grid units.
        id (number)
            The unique ID for this inventory instance.

    Returns:
        table
            The created inventory instance.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Create a 4x6 container inventory
            local container = lia.item.createInv(4, 6, 1001)
            print("Container created with ID:", container.id)
        ```
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
        Adds custom override data for weapon items during auto-generation.

    When Called:
        Called during weapon item generation to customize properties of specific weapons.

    Parameters:
        className (string)
            The weapon class name to override.
        data (table)
            The override data containing weapon properties.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.item.addWeaponOverride("weapon_pistol", {
                name = "Custom Pistol",
                width = 2,
                height = 1,
                price = 500,
                model = "models/weapons/custom_pistol.mdl"
            })
        ```
]]
function lia.item.addWeaponOverride(className, data)
    lia.item.WeaponOverrides[className] = data
end

--[[
    Purpose:
        Adds a weapon class to the blacklist to prevent it from being auto-generated as an item.

    When Called:
        Called during weapon generation setup to exclude certain weapons from item creation.

    Parameters:
        className (string)
            The weapon class name to blacklist.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Prevent admin tools from being generated as items
            lia.item.addWeaponToBlacklist("weapon_physgun")
            lia.item.addWeaponToBlacklist("gmod_tool")
        ```
]]
function lia.item.addWeaponToBlacklist(className)
    lia.item.WeaponsBlackList[className] = true
end

if SERVER then
    --[[
    Purpose:
        Sets data on an item instance by its ID and synchronizes the changes.

    When Called:
        Called when needing to modify item data server-side and sync to clients.

    Parameters:
        itemID (number)
            The unique ID of the item instance.
        key (string)
            The data key to set.
        value (any)
            The value to set for the key.
        receivers (table, optional)
            Specific players to sync the data to.
        noSave (boolean, optional)
            Whether to skip saving to database.
        noCheckEntity (boolean, optional)
            Whether to skip entity validation.

    Returns:
        boolean, string
            True if successful, false and error message if failed.

    Realm:
        Server

    Example Usage:
        ```lua
            local success, errorMsg = lia.item.setItemDataByID(123, "durability", 75)
            if success then
                print("Item durability updated")
            else
                print("Error:", errorMsg)
            end
        ```
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
        Creates a new item instance in the database and returns the created item.

    When Called:
        Called when creating new items that need to be persisted to the database.

    Parameters:
        index (number|string)
            The inventory ID or unique ID if first parameter is string.
        uniqueID (string|table)
            The item definition unique ID or item data if index is string.
        itemData (table, optional)
            The item data to set on creation.
        x (number, optional)
            The X position in inventory.
        y (number, optional)
            The Y position in inventory.
        callback (function, optional)
            Function called when item is created.

    Returns:
        table
            A deferred promise that resolves with the created item.

    Realm:
        Server

    Example Usage:
        ```lua
            -- Create a pistol in inventory 5 at position 1,1
            lia.item.instance(5, "weapon_pistol", {}, 1, 1):next(function(item)
                print("Created item with ID:", item:getID())
            end)
        ```
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
        Deletes an item instance by its ID from memory and/or database.

    When Called:
        Called when permanently removing items from the game world.

    Parameters:
        id (number)
            The unique ID of the item to delete.
    Realm:
        Server

    Example Usage:
        ```lua
            -- Delete item with ID 123
            lia.item.deleteByID(123)
        ```
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
        Loads item instances from the database by their IDs and recreates them in memory.

    When Called:
        Called during server startup or when needing to restore items from the database.

    Parameters:
        itemIndex (number|table)
            Single item ID or array of item IDs to load.
    Realm:
        Server

    Example Usage:
        ```lua
            -- Load a single item
            lia.item.loadItemByID(123)
            -- Load multiple items
            lia.item.loadItemByID({123, 456, 789})
        ```
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
        Creates and spawns an item entity in the world at the specified position.

    When Called:
        Called when dropping items or creating item entities in the game world.

    Parameters:
        uniqueID (string)
            The unique ID of the item to spawn.
        position (Vector)
            The position to spawn the item at.
        callback (function, optional)
            Function called when item is spawned.
        angles (Angle, optional)
            The angles to set on the spawned item.
        data (table, optional)
            The item data to set on creation.

    Returns:
        table or nil
            A deferred promise that resolves with the spawned item, or nil if synchronous.

    Realm:
        Server

    Example Usage:
        ```lua
            -- Spawn a pistol at a position
            lia.item.spawn("weapon_pistol", Vector(0, 0, 0), function(item)
                print("Spawned item:", item:getName())
            end)
        ```
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
        Restores an inventory from the database and sets its dimensions.

    When Called:
        Called when loading saved inventories from the database.

    Parameters:
        invID (number)
            The unique ID of the inventory to restore.
        w (number)
            The width of the inventory.
        h (number)
            The height of the inventory.
        callback (function, optional)
            Function called when inventory is restored.
    Realm:
        Server

    Example Usage:
        ```lua
            -- Restore a 4x6 inventory
            lia.item.restoreInv(5, 4, 6, function(inventory)
                print("Restored inventory with", inventory:getItemCount(), "items")
            end)
        ```
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
                itemName = override.name or "[ARC9] " .. ammoType .. " Ammunition"
            elseif isArccwAmmo then
                ammoType = className:gsub("^arccw_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or "[ARCCW] " .. ammoType .. " Ammunition"
            elseif isTfaAmmo then
                ammoType = className:gsub("^tfa_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or "[TFA] " .. ammoType .. " Ammunition"
            else
                itemName = override.name or className
                ammoType = className
            end

            local properties = {
                name = itemName,
                desc = override.desc or "A Box of " .. ammoType .. " Ammunition",
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

            hook.Run("OnItemOverridden", item, overrides)
        else
            lia.error("[Lilia] Cannot override item '" .. tostring(uniqueID) .. "': item not found\n")
        end
    end

    lia.item.pendingOverrides = {}
end)

if SERVER then
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
else
    local function CreateEntry(scroll, className, weaponTable, overrideData)
        local container = scroll:Add("DPanel")
        container:SetTall(50)
        container:Dock(TOP)
        container:DockMargin(5, 0, 0, 3)
        local expanded = false
        local expandedHeight = 320
        container.Paint = function(s, w, h)
            local theme = lia.color.theme
            local base = (theme and theme.panel and theme.panel[1]) or (theme and theme.button) or Color(45, 50, 60)
            local bgColor = ColorAlpha(base, 235)
            lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        end

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
        AddField("Name", "name", weaponTable.PrintName or className, false)
        AddField("Description", "desc", "A weapon", false)
        AddField("Model", "model", weaponTable.WorldModel or "models/props_c17/suitcase_passenger_physics.mdl", false)
        AddField("Width", "width", defWidth, true)
        AddField("Height", "height", defHeight, true)
        AddField("Price", "price", 500, true)
        AddField("Category", "category", "Weapons", false)
    end

    hook.Add("PopulateConfigurationButtons", "liaWeaponItemsConfig", function(pages)
        if hook.Run("CanPlayerModifyConfig", LocalPlayer()) == false then return end
        pages[#pages + 1] = {
            name = "Weapon Items Config",
            drawFunc = function(parent)
                parent:Clear()
                local searchBar = parent:Add("liaEntry")
                searchBar:Dock(TOP)
                searchBar:DockMargin(10, 10, 10, 10)
                searchBar:SetTall(35)
                searchBar:SetPlaceholderText(L("searchWeapons") or "Search Weapons...")
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
