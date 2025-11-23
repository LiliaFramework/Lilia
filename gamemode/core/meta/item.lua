--[[
    Item Meta

    Item management system for the Lilia framework.
]]
--[[
    Overview:
        The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.
]]
local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "invalidName"
ITEM.desc = ITEM.desc or "invalidDescription"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
ITEM.scale = 1
--[[
    Purpose:
        Checks if the item is currently rotated in the inventory grid

    When Called:
        When determining item dimensions or display orientation

    Parameters:
        None

    Returns:
        Boolean indicating if the item is rotated

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        if item:isRotated() then
            print("Item is rotated")
        end
        ```

    Medium Complexity:
        ```lua
        local width = item:isRotated() and item:getHeight() or item:getWidth()
        local height = item:isRotated() and item:getWidth() or item:getHeight()
        ```

    High Complexity:
        ```lua
        local function getItemDisplaySize(item)
            if item:isRotated() then
                return item:getHeight(), item:getWidth()
            else
                return item:getWidth(), item:getHeight()
            end
        end
        local displayW, displayH = getItemDisplaySize(myItem)
        ```
]]
function ITEM:isRotated()
    return self:getData("rotated", false)
end

--[[
    Purpose:
        Gets the current width of the item considering rotation

    When Called:
        When determining item grid space requirements or display size

    Parameters:
        None

    Returns:
        Number representing the item's width in grid units

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local width = item:getWidth()
        ```

    Medium Complexity:
        ```lua
        if item:getWidth() > maxWidth then
            print("Item too wide for slot")
        end
        ```

    High Complexity:
        ```lua
        local function canPlaceItem(inventory, item, x, y)
            local width = item:getWidth()
            local height = item:getHeight()
            return inventory:canPlaceAt(x, y, width, height)
        end
        if canPlaceItem(myInventory, myItem, 1, 1) then
            inventory:placeItem(myItem, 1, 1)
        end
        ```
]]
function ITEM:getWidth()
    return self:isRotated() and (self.height or 1) or self.width or 1
end

--[[
    Purpose:
        Gets the current height of the item considering rotation

    When Called:
        When determining item grid space requirements or display size

    Parameters:
        None

    Returns:
        Number representing the item's height in grid units

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local height = item:getHeight()
        ```

    Medium Complexity:
        ```lua
        local totalSpace = item:getWidth() * item:getHeight()
        ```

    High Complexity:
        ```lua
        local function calculateInventorySpace(items)
            local totalWidth = 0
            local totalHeight = 0
            for _, item in ipairs(items) do
                totalWidth = math.max(totalWidth, item:getWidth())
                totalHeight = totalHeight + item:getHeight()
            end
            return totalWidth, totalHeight
        end
        local neededW, neededH = calculateInventorySpace(selectedItems)
        ```
]]
function ITEM:getHeight()
    return self:isRotated() and (self.width or 1) or self.height or 1
end

--[[
    Purpose:
        Gets the current quantity of the item

    When Called:
        When checking how many of this item exist, for display or validation

    Parameters:
        None

    Returns:
        Number representing the item's current quantity

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local count = item:getQuantity()
        ```

    Medium Complexity:
        ```lua
        if item:getQuantity() >= requiredAmount then
            useItem(item)
        end
        ```

    High Complexity:
        ```lua
        local function calculateTotalValue(items)
            local total = 0
            for _, item in ipairs(items) do
                local quantity = item:getQuantity()
                local value = item:getPrice() or 0
                total = total + (quantity * value)
            end
            return total
        end
        local inventoryValue = calculateTotalValue(playerInventory:getItems())
        ```
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    Purpose:
        Creates a string representation of the item for debugging/logging

    When Called:
        For logging, debugging, or console output

    Parameters:
        None

    Returns:
        String representation of the item

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        print(item:tostring())
        ```

    Medium Complexity:
        ```lua
        lia.information("Processing " .. item:tostring())
        ```

    High Complexity:
        ```lua
        local function logItemTransaction(item, action, player)
            local logEntry = string.format("[%s] %s performed %s on %s",
                os.date("%H:%M:%S"),
                player:GetName(),
                action,
                item:tostring()
            )
            file.Append("item_transactions.txt", logEntry .. "\n")
        end
        logItemTransaction(myItem, "used", player)
        ```
]]
function ITEM:tostring()
    return L("item") .. "[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    Purpose:
        Gets the unique instance ID of this item

    When Called:
        When you need to reference this specific item instance

    Parameters:
        None

    Returns:
        Number representing the item's unique ID

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local itemID = item:getID()
        ```

    Medium Complexity:
        ```lua
        if item:getID() == targetID then
            selectItem(item)
        end
        ```

    High Complexity:
        ```lua
        local function findItemByID(inventory, targetID)
            for _, item in pairs(inventory:getItems()) do
                if item:getID() == targetID then
                    return item
                end
            end
            return nil
        end
        local foundItem = findItemByID(playerInventory, 12345)
        ```
]]
function ITEM:getID()
    return self.id
end

--[[
    Purpose:
        Gets the model path for the item

    When Called:
        When displaying the item or creating item entities

    Parameters:
        None

    Returns:
        String representing the item's model path

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local model = item:getModel()
        ```

    Medium Complexity:
        ```lua
        if item:getModel() then
            entity:SetModel(item:getModel())
        end
        ```

    High Complexity:
        ```lua
        local function createItemEntity(item, position)
            local ent = ents.Create("prop_physics")
            ent:SetModel(item:getModel() or "models/error.mdl")
            ent:SetPos(position)
            ent:Spawn()
            if item:getSkin() then
                ent:SetSkin(item:getSkin())
            end
            return ent
        end
        local itemEntity = createItemEntity(myItem, Vector(0, 0, 0))
        ```
]]
function ITEM:getModel()
    return self.model
end

--[[
    Purpose:
        Gets the skin index for the item's model

    When Called:
        When setting up item display or entity appearance

    Parameters:
        None

    Returns:
        Number representing the skin index, or nil if none set

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local skin = item:getSkin()
        ```

    Medium Complexity:
        ```lua
        if item:getSkin() then
            entity:SetSkin(item:getSkin())
        end
        ```

    High Complexity:
        ```lua
        local function applyItemAppearance(entity, item)
            entity:SetModel(item:getModel())
            entity:SetSkin(item:getSkin() or 0)
            for k, v in pairs(item:getBodygroups()) do
                entity:SetBodygroup(k, v)
            end
            entity:SetColor(item:getData("color", Color(255, 255, 255)))
        end
        applyItemAppearance(myEntity, myItem)
        ```
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    Purpose:
        Gets the bodygroup settings for the item's model

    When Called:
        When setting up item display or entity appearance

    Parameters:
        None

    Returns:
        Table of bodygroup settings, empty table if none set

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local bodygroups = item:getBodygroups()
        ```

    Medium Complexity:
        ```lua
        for id, value in pairs(item:getBodygroups()) do
            entity:SetBodygroup(id, value)
        end
        ```

    High Complexity:
        ```lua
        local function applyBodygroups(entity, bodygroups)
            for bodygroupID, bodygroupValue in pairs(bodygroups) do
                if isstring(bodygroupID) then
                    -- Handle named bodygroups
                    local id = entity:FindBodygroupByName(bodygroupID)
                    if id ~= -1 then
                        entity:SetBodygroup(id, bodygroupValue)
                    end
                else
                    entity:SetBodygroup(bodygroupID, bodygroupValue)
                end
            end
        end
        applyBodygroups(myEntity, item:getBodygroups())
        ```
]]
function ITEM:getBodygroups()
    return self.bodygroups or {}
end

--[[
    Purpose:
        Gets the current price of the item, potentially calculated dynamically

    When Called:
        When selling, trading, or displaying item value

    Parameters:
        None

    Returns:
        Number representing the item's price

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local price = item:getPrice()
        ```

    Medium Complexity:
        ```lua
        if player:getMoney() >= item:getPrice() then
            player:buyItem(item)
        end
        ```

    High Complexity:
        ```lua
        local function calculateTotalCost(items)
            local total = 0
            for _, item in ipairs(items) do
                local price = item:getPrice()
                local quantity = item:getQuantity()
                total = total + (price * quantity)
            end
            -- Apply bulk discount
            if #items > 5 then
                total = total * 0.9
            end
            return total
        end
        local cost = calculateTotalCost(selectedItems)
        ```
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    Purpose:
        Calls an item method with specified player and entity context

    When Called:
        When executing item functions that need player/entity context

    Parameters:
        method (string)
            String name of the method to call
        client (Player)
            Player entity to set as context
        entity (Entity)
            Entity to set as context
        ... (any)
            Additional arguments to pass to the method

    Returns:
        The return values from the called method

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        item:call("use", player)
        ```

    Medium Complexity:
        ```lua
        local success = item:call("canUse", player, entity)
        if success then
            item:call("onUse", player, entity)
        end
        ```

    High Complexity:
        ```lua
        local function executeItemAction(item, action, player, entity, ...)
            local canRun, reason = item:call("can" .. action, player, entity, ...)
            if canRun then
                local result = {item:call("on" .. action, player, entity, ...)}
                hook.Run("OnItem" .. action, item, player, entity, unpack(result))
                return true, unpack(result)
            else
                player:notifyError(reason or "Cannot perform action")
                return false
            end
        end
        local success, data = executeItemAction(myItem, "Use", player, nil, target)
        ```
]]
function ITEM:call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity
    if isfunction(self[method]) then
        local results = {self[method](self, ...)}
        self.player = oldPlayer
        self.entity = oldEntity
        hook.Run("ItemFunctionCalled", self, method, client, entity, results)
        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

--[[
    Purpose:
        Gets the player who owns this item

    When Called:
        When you need to determine item ownership or permissions

    Parameters:
        None

    Returns:
        Player entity who owns the item, or nil if not found

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local owner = item:getOwner()
        ```

    Medium Complexity:
        ```lua
        if item:getOwner() == player then
            allowModification = true
        end
        ```

    High Complexity:
        ```lua
        local function canPlayerAccessItem(player, item)
            local owner = item:getOwner()
            if not owner then return false end

            -- Check if player is the owner
            if owner == player then return true end

            -- Check if player has admin permissions
            if player:isAdmin() then return true end

            -- Check if item is in shared inventory
            local inventory = lia.inventory.instances[item.invID]
            if inventory and inventory:getData("shared") then
                return inventory:canAccess("view", {client = player})
            end

            return false
        end
        if canPlayerAccessItem(client, myItem) then
            -- Allow access
        end
        ```
]]
function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

--[[
    Purpose:
        Retrieves data from the item's data table with fallback to entity data

    When Called:
        When accessing item-specific data or configuration

    Parameters:
        key (string)
            The data key to retrieve
        default (any)
            Optional default value if key doesn't exist

    Returns:
        The data value or default value if key doesn't exist

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local durability = item:getData("durability", 100)
        ```

    Medium Complexity:
        ```lua
        local color = item:getData("color", Color(255, 255, 255))
        entity:SetColor(color)
        ```

    High Complexity:
        ```lua
        local function applyItemModifiers(entity, item)
            -- Apply durability-based modifications
            local durability = item:getData("durability", 100)
            local maxDurability = item:getData("maxDurability", 100)
            local durabilityPercent = durability / maxDurability

            -- Reduce effectiveness based on durability
            if item.damage then
                entity:SetHealth(entity:GetMaxHealth() * durabilityPercent)
            end

            -- Apply custom modifiers
            local modifiers = item:getData("modifiers", {})
            for modifierType, modifierValue in pairs(modifiers) do
                applyModifier(entity, modifierType, modifierValue * durabilityPercent)
            end
        end
        applyItemModifiers(myEntity, myItem)
        ```
]]
function ITEM:getData(key, default)
    self.data = self.data or {}
    local value = self.data[key]
    if value ~= nil then return value end
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        value = data[key]
        if value ~= nil then return value end
    end
    return default
end

--[[
    Purpose:
        Gets all data associated with the item from both item and entity

    When Called:
        When you need a complete view of all item data

    Parameters:
        None

    Returns:
        Table containing all item data

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local allData = item:getAllData()
        ```

    Medium Complexity:
        ```lua
        local data = item:getAllData()
        for key, value in pairs(data) do
            print(key .. ": " .. tostring(value))
        end
        ```

    High Complexity:
        ```lua
        local function serializeItemForSave(item)
            local data = item:getAllData()
            -- Remove runtime-only data
            data.entity = nil
            data.player = nil
            -- Add metadata
            data.savedAt = os.time()
            data.version = "1.0"
            return util.TableToJSON(data)
        end
        local serializedData = serializeItemForSave(myItem)
        file.Write("item_backup.txt", serializedData)
        ```
]]
function ITEM:getAllData()
    self.data = self.data or {}
    local fullData = table.Copy(self.data)
    if IsValid(self.entity) then
        local entityData = self.entity:getNetVar("data", {})
        for key, value in pairs(entityData) do
            fullData[key] = value
        end
    end
    return fullData
end

--[[
    Purpose:
        Registers a hook function to be called before item actions

    When Called:
        During item configuration to add custom behavior

    Parameters:
        name (string)
            String name of the hook (e.g., "use", "drop")
        func (function)
            Function to call when the hook is triggered

    Returns:
        Nothing

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        item:hook("use", function(item)
            print("Item used!")
        end)
        ```

    Medium Complexity:
        ```lua
        item:hook("drop", function(item)
            if item:getData("soulbound") then
                return false -- Prevent dropping
            end
        end)
        ```

    High Complexity:
        ```lua
        item:hook("use", function(item)
            -- Check cooldown
            local lastUsed = item:getData("lastUsed", 0)
            local cooldown = item:getData("cooldown", 60)
            if CurTime() - lastUsed < cooldown then
                item.player:notifyError("Item is on cooldown")
                return false
            end
            -- Update last used time
            item:setData("lastUsed", CurTime())
            -- Apply custom effects
            applyItemEffect(item.player, item.uniqueID)
        end)
        ```
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    Purpose:
        Registers a post-hook function to be called after item actions

    When Called:
        During item configuration to add cleanup or follow-up behavior

    Parameters:
        name (string)
            String name of the hook (e.g., "use", "drop")
        func (function)
            Function to call after the hook is triggered

    Returns:
        Nothing

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        item:postHook("use", function(item)
            print("Item use completed")
        end)
        ```

    Medium Complexity:
        ```lua
        item:postHook("drop", function(item)
            lia.log.add(item.player, "item_dropped", item:getName())
        end)
        ```

    High Complexity:
        ```lua
        item:postHook("use", function(item, result)
            -- Log usage statistics
            local stats = lia.data.get("item_usage_stats", {})
            stats[item.uniqueID] = (stats[item.uniqueID] or 0) + 1
            lia.data.set("item_usage_stats", stats)

            -- Apply post-use effects
            if result == true and item:getData("consumable") then
                item:addQuantity(-1)
            end

            -- Trigger achievements
            if stats[item.uniqueID] >= 100 then
                item.player:unlockAchievement("frequent_user")
            end
        end)
        ```
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    Purpose:
        Called when the item is registered with the system

    When Called:
        Automatically during item registration

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        function ITEM:onRegistered()
            print("Item registered: " .. self.uniqueID)
        end
        ```

    Medium Complexity:
        ```lua
        function ITEM:onRegistered()
            if self.model then
                util.PrecacheModel(self.model)
            end
        end
        ```

    High Complexity:
        ```lua
        function ITEM:onRegistered()
            -- Precache model
            if self.model then
                util.PrecacheModel(self.model)
            end

            -- Register with item categories
            if self.category then
                local categories = lia.data.get("item_categories", {})
                categories[self.category] = categories[self.category] or {}
                table.insert(categories[self.category], self.uniqueID)
                lia.data.set("item_categories", categories)
            end

            -- Set up default data
            self.defaultData = self.defaultData or {}
            for key, value in pairs(self.defaultData) do
                if self:getData(key) == nil then
                    self:setData(key, value)
                end
            end
        end
        ```
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    Purpose:
        Prints basic item information to the server console

    When Called:
        For debugging or logging item state

    Parameters:
        detail (boolean)
            Optional boolean to show detailed information

    Returns:
        Nothing

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        item:print()
        ```

    Medium Complexity:
        ```lua
        item:print(true) -- Show detailed info
        ```

    High Complexity:
        ```lua
        local function debugInventory(inventory)
            for _, item in pairs(inventory:getItems()) do
                item:print(true)
                print("---")
            end
        end
        debugInventory(player:getInventory())
        ```
]]
function ITEM:print(detail)
    if detail then
        lia.information(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        lia.information(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--[[
    Purpose:
        Prints all item data to the server console

    When Called:
        For detailed debugging of item data

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        item:printData()
        ```

    Medium Complexity:
        ```lua
        if item:getData("debug") then
            item:printData()
        end
        ```

    High Complexity:
        ```lua
        local function auditItemData(item)
            item:printData()
            -- Check for invalid data
            local data = item:getAllData()
            for key, value in pairs(data) do
                if istable(value) and table.Count(value) > 100 then
                    lia.log.add(nil, "large_data_warning", item:getID(), key, table.Count(value))
                end
            end
        end
        auditItemData(suspiciousItem)
        ```
]]
function ITEM:printData()
    self:print(true)
    lia.information(L("itemData") .. ":")
    for k, v in pairs(self.data) do
        lia.information(L("itemDataEntry", k, v))
    end
end

--[[
    Purpose:
        Gets the display name of the item

    When Called:
        When displaying item names in UI or chat

    Parameters:
        None

    Returns:
        String representing the item's name

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local name = item:getName()
        ```

    Medium Complexity:
        ```lua
        chat.AddText(Color(255, 255, 255), "You received: ", item:getName())
        ```

    High Complexity:
        ```lua
        local function formatItemName(item)
            local name = item:getName()
            local quality = item:getData("quality")
            if quality then
                local colors = {
                    common     = Color(255, 255, 255),
                    rare        = Color(0, 255, 255),
                    epic        = Color(255, 0, 255),
                    legendary   = Color(255, 165, 0)
                }
                return colors[quality], name
            end
            return Color(255, 255, 255), name
        end
        local color, displayName = formatItemName(myItem)
        ```
]]
function ITEM:getName()
    return self.name
end

--[[
    Purpose:
        Gets the description of the item

    When Called:
        When displaying item details or tooltips

    Parameters:
        None

    Returns:
        String representing the item's description

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local desc = item:getDesc()
        ```

    Medium Complexity:
        ```lua
        print("Item description: " .. item:getDesc())
        ```

    High Complexity:
        ```lua
        local function getFormattedDescription(item)
            local desc = item:getDesc()
            -- Add dynamic information
            if item:getData("durability") then
                local durability = item:getData("durability", 100)
                local maxDurability = item:getData("maxDurability", 100)
                desc = desc .. string.format("\nDurability: %d/%d", durability, maxDurability)
            end

            if item:getData("level") then
                desc = desc .. string.format("\nRequired Level: %d", item:getData("level"))
            end

            return desc
        end
        local fullDesc = getFormattedDescription(myItem)
        ```
]]
function ITEM:getDesc()
    return self.desc
end

if SERVER then
    --[[
        Purpose:
            Removes the item from its current inventory without deleting it

        When Called:
            When transferring items between inventories or temporarily removing them

        Parameters:
            preserveItem (boolean)
                Optional boolean to preserve item data in database

        Returns:
            Deferred object that resolves when removal is complete

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:removeFromInventory()
            ```

        Medium Complexity:
            ```lua
            item:removeFromInventory(true):next(function()
                print("Item removed but preserved")
            end)
            ```

        High Complexity:
            ```lua
            local function transferItem(item, fromInv, toInv)
                return item:removeFromInventory(true):next(function()
                    return toInv:add(item)
                end):next(function()
                    lia.log.add(nil, "item_transferred",
                        item:getID(), fromInv:getID(), toInv:getID())
                end)
            end
            transferItem(myItem, playerInv, bankInv)
            ```
    ]]
    function ITEM:removeFromInventory(preserveItem)
        local inventory = lia.inventory.instances[self.invID]
        self.invID = 0
        if inventory then return inventory:removeItem(self:getID(), preserveItem) end
        local d = deferred.new()
        d:resolve()
        return d
    end

    --[[
        Purpose:
            Permanently deletes the item from the database and system

        When Called:
            When completely removing an item from the game world

        Parameters:
            None

        Returns:
            Deferred object that resolves when deletion is complete

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:delete()
            ```

        Medium Complexity:
            ```lua
            item:delete():next(function()
                print("Item permanently deleted")
            end)
            ```

        High Complexity:
            ```lua
            local function safelyDeleteExpiredItems()
                local expiredItems = lia.db.select("*", "items", "expiry_date < " .. os.time())
                expiredItems:next(function(results)
                    for _, row in ipairs(results.results or {}) do
                        local item = lia.item.instances[tonumber(row.itemID)]
                        if item then
                            -- Log deletion reason
                            lia.log.add(nil, "expired_item_deleted", row.itemID, row.uniqueID)
                            -- Delete the item
                            item:delete()
                        end
                    end
                end)
            end
            safelyDeleteExpiredItems()
            ```
    ]]
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --[[
        Purpose:
            Completely removes the item from the world, inventory, and database

        When Called:
            When an item is used up, destroyed, or needs to be completely eliminated

        Parameters:
            None

        Returns:
            Deferred object that resolves when removal is complete

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:remove()
            ```

        Medium Complexity:
            ```lua
            item:remove():next(function()
                player:notify("Item consumed")
            end)
            ```

        High Complexity:
            ```lua
            local function consumeItemWithEffects(item, player)
                -- Apply item effects before removal
                if item.onConsume then
                    item:call("onConsume", player)
                end

                -- Remove the item
                return item:remove():next(function()
                    -- Post-consumption effects
                    if item:getData("reusable") then
                        -- Create a new instance if reusable
                        local newItem = lia.item.new(item.uniqueID, 1)
                        player:getInventory():add(newItem)
                    end

                    -- Trigger achievements
                    local consumedCount = player:getData("items_consumed", 0) + 1
                    player:setData("items_consumed", consumedCount)
                    if consumedCount >= 100 then
                        player:unlockAchievement("consumptive")
                    end
                end)
            end
            consumeItemWithEffects(myItem, player)
            ```
    ]]
    function ITEM:remove()
        local d = deferred.new()
        if IsValid(self.entity) then SafeRemoveEntity(self.entity) end
        self:removeFromInventory():next(function()
            d:resolve()
            return self:delete()
        end)
        return d
    end

    --[[
        Purpose:
            Destroys the item instance and notifies all clients to remove it

        When Called:
            When an item needs to be removed from the game world immediately

        Parameters:
            None

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:destroy()
            ```

        Medium Complexity:
            ```lua
            if item:getData("temporary") then
                item:destroy()
            end
            ```

        High Complexity:
            ```lua
            local function destroyItemsInRadius(position, radius)
                local items = ents.FindInSphere(position, radius)
                local destroyedCount = 0

                for _, ent in ipairs(items) do
                    if ent:GetClass() == "lia_item" and ent.liaItemID then
                        local item = lia.item.instances[ent.liaItemID]
                        if item then
                            -- Log destruction
                            lia.log.add(nil, "area_destruction", item:getID(), item:getName())
                            item:destroy()
                            destroyedCount = destroyedCount + 1
                        end
                    end
                end

                lia.chat.send(nil, "Destroyed " .. destroyedCount .. " items in area")
                return destroyedCount
            end
            destroyItemsInRadius(explosionPos, 500)
            ```
    ]]
    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    --[[
        Purpose:
            Called when the item is disposed/destroyed

        When Called:
            Automatically when destroy() is called

        Parameters:
            None

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            function ITEM:onDisposed()
                -- Cleanup code here
            end
            ```

        Medium Complexity:
            ```lua
            function ITEM:onDisposed()
                -- Clean up associated entities
                if self.associatedEntity then
                    SafeRemoveEntity(self.associatedEntity)
                end
            end
            ```

        High Complexity:
            ```lua
            function ITEM:onDisposed()
                -- Comprehensive cleanup
                if self.temporaryEntities then
                    for _, ent in ipairs(self.temporaryEntities) do
                        SafeRemoveEntity(ent)
                    end
                    self.temporaryEntities = nil
                end

                -- Remove from global item lists
                if self.category then
                    local categoryItems = lia.data.get("category_items_" .. self.category, {})
                    categoryItems[self:getID()] = nil
                    lia.data.set("category_items_" .. self.category, categoryItems)
                end

                -- Log disposal
                lia.log.add(nil, "item_disposed", self:getID(), self.uniqueID)

                -- Trigger disposal hooks
                hook.Run("OnItemDisposed", self)
            end
            ```
    ]]
    function ITEM:onDisposed()
    end

    --[[
        Purpose:
            Gets the world entity associated with this item instance

        When Called:
            When you need to manipulate the physical item entity in the world

        Parameters:
            None

        Returns:
            Entity object if found, nil otherwise

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            local entity = item:getEntity()
            ```

        Medium Complexity:
            ```lua
            local entity = item:getEntity()
            if entity then
                entity:SetPos(newPosition)
            end
            ```

        High Complexity:
            ```lua
            local function teleportItemToPlayer(item, player)
                local entity = item:getEntity()
                if entity then
                    -- Remove from inventory first
                    item:removeFromInventory(true):next(function()
                        -- Teleport entity to player
                        entity:SetPos(player:GetPos() + Vector(0, 0, 50))
                        entity:SetVelocity(Vector(0, 0, 0))
                        -- Log the action
                        lia.log.add(player, "item_teleported", item:getID(), item:getName())
                    end)
                else
                    player:notifyError("Item has no physical entity")
                end
            end
            teleportItemToPlayer(myItem, player)
            ```
    ]]
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --[[
        Purpose:
            Creates a physical entity for the item in the world

        When Called:
            When dropping items or spawning them in the world

        Parameters:
            position (Vector|table|Player)
                Position to spawn the item (Vector, table, or Player entity)
            angles (Angle)
                Optional angles for the spawned item

        Returns:
            The created entity

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:spawn(Vector(0, 0, 0))
            ```

        Medium Complexity:
            ```lua
            item:spawn(player:GetPos() + Vector(0, 0, 50), Angle(0, 0, 0))
            ```

        High Complexity:
            ```lua
            local function dropItemWithPhysics(item, player, force)
                -- Remove from inventory
                item:removeFromInventory(true):next(function()
                    -- Spawn with physics
                    local entity = item:spawn(player:GetPos() + Vector(0, 50, 0))

                    if entity and IsValid(entity:GetPhysicsObject()) then
                        -- Apply throw force
                        local phys = entity:GetPhysicsObject()
                        phys:ApplyForceCenter(player:GetAimVector() * force)

                        -- Add some spin
                        phys:AddAngleVelocity(VectorRand() * 100)

                        -- Log the drop
                        lia.log.add(player, "item_dropped", item:getID(), item:getName())
                    end
                end)
            end
            dropItemWithPhysics(myItem, player, 1000)
            ```
    ]]
    function ITEM:spawn(position, angles)
        local instance = lia.item.instances[self.id]
        if instance then
            if IsValid(instance.entity) then
                instance.entity.liaIsSafe = true
                SafeRemoveEntity(instance.entity)
            end

            local client
            if isentity(position) and position:IsPlayer() then
                client = position
                position = position:getItemDropPos()
            end

            position = lia.data.decode(position)
            if not isvector(position) and istable(position) then
                local x = tonumber(position.x or position[1])
                local y = tonumber(position.y or position[2])
                local z = tonumber(position.z or position[3])
                if x and y and z then position = Vector(x, y, z) end
            end

            if angles then
                angles = lia.data.decode(angles)
                if not isangle(angles) then
                    if isvector(angles) then
                        angles = Angle(angles.x, angles.y, angles.z)
                    elseif istable(angles) then
                        local p = tonumber(angles.p or angles[1])
                        local yaw = tonumber(angles.y or angles[2])
                        local r = tonumber(angles.r or angles[3])
                        if p and yaw and r then angles = Angle(p, yaw, r) end
                    end
                end
            end

            local entity = ents.Create("lia_item")
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or angle_zero)
            entity:setItem(self.id)
            instance.entity = entity
            if self.scale and self.scale ~= 1 then entity:SetModelScale(self.scale) end
            if IsValid(client) then
                entity.SteamID = client:SteamID()
                if client:getChar() then
                    entity.liaCharID = client:getChar():getID()
                else
                    entity.liaCharID = 0
                end

                entity:SetCreator(client)
            end
            return entity
        end
    end

    --[[
        Purpose:
            Transfers the item from its current inventory to a new inventory

        When Called:
            When moving items between inventories (trading, storing, etc.)

        Parameters:
            newInventory (Inventory)
                The inventory to transfer the item to
            bBypass (boolean)
                Optional boolean to bypass access control checks

        Returns:
            Boolean indicating if transfer was successful

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:transfer(otherInventory)
            ```

        Medium Complexity:
            ```lua
            if item:transfer(bankInventory) then
                player:notify("Item stored in bank")
            end
            ```

        High Complexity:
            ```lua
            local function tradeItems(player1, player2, itemID, payment)
                local item = player1:getInventory():getItems()[itemID]
                if not item then return false, "Item not found" end

                -- Check if player2 has enough money
                if player2:getMoney() < payment then
                    return false, "Insufficient funds"
                end

                -- Transfer item
                if item:transfer(player2:getInventory()) then
                    -- Handle payment
                    player2:addMoney(-payment)
                    player1:addMoney(payment)

                    -- Log the trade
                    lia.log.add(nil, "item_trade",
                        item:getID(), player1:GetName(), player2:GetName(), payment)

                    return true
                else
                    return false, "Transfer failed"
                end
            end
            local success, reason = tradeItems(seller, buyer, itemID, 500)
            ```
    ]]
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --[[
        Purpose:
            Called when the item instance is first created

        When Called:
            Automatically when item instances are created

        Parameters:
            None

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            function ITEM:onInstanced()
                print("New item instance created")
            end
            ```

        Medium Complexity:
            ```lua
            function ITEM:onInstanced()
                -- Set default data for new instances
                if not self:getData("created") then
                    self:setData("created", os.time())
                end
            end
            ```

        High Complexity:
            ```lua
            function ITEM:onInstanced()
                -- Initialize complex item state
                self:setData("durability", self:getData("maxDurability", 100))
                self:setData("serialNumber", string.format("SN-%06d-%04d-%03d", math.random(100000, 999999), math.random(1000, 9999), math.random(100, 999)))

                -- Register with item tracking system
                local trackingData = lia.data.get("item_tracking", {})
                trackingData[self:getID()] = {
                    uniqueID = self.uniqueID,
                    created  = os.time(),
                    owner    = self:getOwner() and self:getOwner():GetName() or "unknown"
                }
                lia.data.set("item_tracking", trackingData)

                -- Apply category-specific initialization
                if self.category == "weapons" then
                    self:setData("ammo", self:getData("maxAmmo", 30))
                elseif self.category == "armor" then
                    self:setData("protection", self:getData("maxProtection", 50))
                end
            end
            ```
    ]]
    function ITEM:onInstanced()
    end

    --[[
        Purpose:
            Called when the item is synchronized to clients

        When Called:
            Automatically when item data is sent to clients

        Parameters:
            recipient (Player)
                Optional specific client to sync to

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            function ITEM:onSync(recipient)
                -- Custom sync logic
            end
            ```

        Medium Complexity:
            ```lua
            function ITEM:onSync(recipient)
                -- Send additional data to specific client
                if recipient then
                    net.Start("CustomItemData")
                    net.WriteType(self:getID())
                    net.WriteTable(self:getAllData())
                    net.Send(recipient)
                end
            end
            ```

        High Complexity:
            ```lua
            function ITEM:onSync(recipient)
                -- Advanced sync with filtering
                local dataToSend = {}

                -- Only send sensitive data to item owner
                if recipient == self:getOwner() then
                    dataToSend = self:getAllData()
                else
                    -- Filter out sensitive data for other players
                    for key, value in pairs(self:getAllData()) do
                        if not self.sensitiveDataKeys[key] then
                            dataToSend[key] = value
                        end
                    end
                end

                -- Send filtered data
                net.Start("FilteredItemData")
                net.WriteType(self:getID())
                net.WriteTable(dataToSend)
                net.Send(recipient)
            end
            ```
    ]]
    function ITEM:onSync()
    end

    --[[
        Purpose:
            Called when the item is permanently removed from the system

        When Called:
            Automatically when delete() completes

        Parameters:
            None

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            function ITEM:onRemoved()
                print("Item permanently removed")
            end
            ```

        Medium Complexity:
            ```lua
            function ITEM:onRemoved()
                -- Clean up references
                lia.data.delete("item_" .. self:getID())
            end
            ```

        High Complexity:
            ```lua
            function ITEM:onRemoved()
                -- Comprehensive cleanup
                local itemID = self:getID()

                -- Remove from tracking systems
                local trackingData = lia.data.get("item_tracking", {})
                trackingData[itemID] = nil
                lia.data.set("item_tracking", trackingData)

                -- Remove from category lists
                if self.category then
                    local categoryItems = lia.data.get("category_items_" .. self.category, {})
                    categoryItems[itemID] = nil
                    lia.data.set("category_items_" .. self.category, categoryItems)
                end

                -- Log permanent removal
                lia.log.add(nil, "item_permanently_removed", itemID, self.uniqueID)

                -- Notify administrators of rare item removal
                if self:getData("rarity") == "legendary" then
                    lia.chat.send(lia.util.getAdmins(), "Legendary item permanently removed: " .. self:getName())
                end
            end
            ```
    ]]
    function ITEM:onRemoved()
    end

    --[[
        Purpose:
            Called when the item is loaded from the database

        When Called:
            Automatically when item data is restored from storage

        Parameters:
            inventory (Inventory)
                The inventory this item belongs to

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            function ITEM:onRestored(inventory)
                print("Item restored from database")
            end
            ```

        Medium Complexity:
            ```lua
            function ITEM:onRestored(inventory)
                -- Validate restored data
                if self:getData("durability") and self:getData("durability") < 0 then
                    self:setData("durability", 0)
                end
            end
            ```

        High Complexity:
            ```lua
            function ITEM:onRestored(inventory)
                -- Comprehensive restoration logic
                local itemID = self:getID()

                -- Restore complex relationships
                self:restoreOwnershipLinks()
                self:restoreEnchantments()
                self:validateDataIntegrity()

                -- Update tracking systems
                local trackingData = lia.data.get("item_tracking", {})
                trackingData[itemID].restored = os.time()
                trackingData[itemID].inventory = inventory:getID()
                lia.data.set("item_tracking", trackingData)

                -- Apply restoration effects
                if self:getData("temporary") then
                    local expiryTime = self:getData("expiryTime")
                    if expiryTime and expiryTime < os.time() then
                        -- Item has expired, schedule removal
                        timer.Simple(0, function()
                            if IsValid(self) then
                                self:remove()
                                lia.log.add(nil, "expired_item_removed_on_restore", itemID)
                            end
                        end)
                    end
                end

                -- Trigger restoration hooks
                hook.Run("OnItemRestored", self, inventory)
            end
            ```
    ]]
    function ITEM:onRestored()
    end

    --[[
        Purpose:
            Synchronizes item instance data to clients

        When Called:
            When item data needs to be sent to clients

        Parameters:
            recipient (Player)
                Optional specific client to sync to, broadcasts if nil

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:sync()
            ```

        Medium Complexity:
            ```lua
            item:sync(specificPlayer)
            ```

        High Complexity:
            ```lua
            local function syncItemToGroup(item, players)
                -- Send different data based on player permissions
                for _, player in ipairs(players) do
                    if player:canAccessItem(item) then
                        item:sync(player)
                    else
                        -- Send limited data
                        net.Start("liaItemLimited")
                        net.WriteUInt(item:getID(), 32)
                        net.WriteString(item:getName())
                        net.Send(player)
                    end
                end
            end
            syncItemToGroup(myItem, nearbyPlayers)
            ```
    ]]
    function ITEM:sync(recipient)
        net.Start("liaItemInstance")
        net.WriteUInt(self:getID(), 32)
        net.WriteString(self.uniqueID)
        net.WriteTable(self.data)
        net.WriteType(self.invID)
        net.WriteUInt(self.quantity, 32)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end

        self:onSync(recipient)
    end

    --[[
        Purpose:
            Sets item data and synchronizes changes to clients and database

        When Called:
            When item data needs to be updated and persisted

        Parameters:
            key (string)
                The data key to set
            value (any)
                The value to set
            receivers (table)
                Optional specific clients to notify
            noSave (boolean)
                Optional boolean to skip database saving
            noCheckEntity (boolean)
                Optional boolean to skip entity data sync

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:setData("durability", 50)
            ```

        Medium Complexity:
            ```lua
            item:setData("owner", player:GetName())
            item:setData("acquired", os.time())
            ```

        High Complexity:
            ```lua
            local function applyDamageToItem(item, damage)
                local currentDurability = item:getData("durability", 100)
                local newDurability = math.max(0, currentDurability - damage)

                -- Set durability and sync to all players
                item:setData("durability", newDurability)

                -- If item is broken, apply broken effects
                if newDurability == 0 then
                    item:setData("broken", true)
                    item:setData("repairCost", item:getData("baseRepairCost", 100) * 2)

                    -- Notify owner
                    local owner = item:getOwner()
                    if owner then
                        owner:notify("Your " .. item:getName() .. " has broken!")
                    end
                end

                -- Log damage
                lia.log.add(nil, "item_damaged", item:getID(), damage, newDurability)
            end
            applyDamageToItem(myItem, 25)
            ```
    ]]
    function ITEM:setData(key, value, receivers, noSave, noCheckEntity)
        self.data = self.data or {}
        self.data[key] = value
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("data", self.data) end
        end

        if receivers or self:getOwner() then
            net.Start("liaInvData")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(value)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        if key == "x" or key == "y" then
            value = tonumber(value)
            lia.db.updateTable({
                [key] = value
            }, nil, "items", "itemID = " .. self:getID())
            return
        end

        local x, y = self.data.x, self.data.y
        self.data.x, self.data.y = nil, nil
        lia.db.updateTable({
            data = self.data
        }, nil, "items", "itemID = " .. self:getID())

        self.data.x, self.data.y = x, y
    end

    --[[
        Purpose:
            Adds to the item's quantity and synchronizes the change

        When Called:
            When increasing item stack size

        Parameters:
            quantity (number)
                Amount to add to the quantity
            receivers (table)
                Optional specific clients to notify
            noCheckEntity (boolean)
                Optional boolean to skip entity sync

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:addQuantity(5)
            ```

        Medium Complexity:
            ```lua
            item:addQuantity(1, player) -- Notify specific player
            ```

        High Complexity:
            ```lua
            local function combineStacks(item1, item2)
                if item1.uniqueID == item2.uniqueID then
                    local combinedQuantity = item1:getQuantity() + item2:getQuantity()
                    local maxStack = item1.maxQuantity or 1

                    if combinedQuantity <= maxStack then
                        -- Combine into one stack
                        item1:setQuantity(combinedQuantity)
                        item2:remove()
                        return true, "Items combined successfully"
                    else
                        -- Fill first stack and adjust second
                        local overflow = combinedQuantity - maxStack
                        item1:setQuantity(maxStack)
                        item2:setQuantity(overflow)
                        return true, "Items partially combined"
                    end
                end
                return false, "Items cannot be combined"
            end
            local success, message = combineStacks(stack1, stack2)
            ```
    ]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
        Purpose:
            Sets the item's quantity and synchronizes the change

        When Called:
            When changing item stack size or count

        Parameters:
            quantity (number)
                New quantity value
            receivers (table)
                Optional specific clients to notify
            noCheckEntity (boolean)
                Optional boolean to skip entity sync

        Returns:
            Nothing

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:setQuantity(10)
            ```

        Medium Complexity:
            ```lua
            item:setQuantity(0) -- Remove all items from stack
            ```

        High Complexity:
            ```lua
            local function splitStack(item, splitAmount)
                local currentQuantity = item:getQuantity()
                if splitAmount >= currentQuantity then
                    return false, "Cannot split more than available"
                end

                -- Create new item instance
                local newItem = lia.item.new(item.uniqueID, 1)
                newItem:setQuantity(splitAmount)
                newItem:setData("splitFrom", item:getID())

                -- Reduce original stack
                item:setQuantity(currentQuantity - splitAmount)

                -- Add new stack to same inventory
                local inventory = lia.inventory.instances[item.invID]
                if inventory then
                    inventory:add(newItem)
                    return true, newItem
                end

                return false, "Failed to add split item to inventory"
            end
            local success, newStack = splitStack(myItem, 5)
            ```
    ]]
    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then
            net.Start("liaInvQuantity")
            net.WriteUInt(self:getID(), 32)
            net.WriteUInt(self.quantity, 32)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        lia.db.updateTable({
            quantity = self.quantity
        }, nil, "items", "itemID = " .. self:getID())
    end

    --[[
        Purpose:
            Handles player interaction with items (use, drop, etc.)

        When Called:
            When a player attempts to interact with an item

        Parameters:
            action (string)
                The interaction action (e.g., "use", "drop")
            client (Player)
                The player performing the action
            entity (Entity)
                Optional entity involved in the interaction
            data (any)
                Optional additional data for the interaction

        Returns:
            Boolean indicating if the interaction was successful

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            item:interact("use", player)
            ```

        Medium Complexity:
            ```lua
            item:interact("drop", player, nil, {position = dropPos})
            ```

        High Complexity:
            ```lua
            local function handleComplexInteraction(item, action, player, entity, data)
                -- Pre-interaction validation
                if action == "use" and item:getData("cooldown") then
                    local lastUsed = item:getData("lastUsed", 0)
                    if CurTime() - lastUsed < item:getData("cooldown") then
                        player:notifyError("Item is on cooldown")
                        return false
                    end
                end

                -- Perform interaction
                local success = item:interact(action, player, entity, data)

                if success then
                    -- Post-interaction effects
                    if action == "use" then
                        item:setData("lastUsed", CurTime())
                        item:setData("uses", item:getData("uses", 0) + 1)

                        -- Check for breakage
                        if item:getData("uses") >= item:getData("maxUses", 100) then
                            player:notify("Your " .. item:getName() .. " has broken!")
                            item:setData("broken", true)
                        end
                    end

                    -- Log the interaction
                    lia.log.add(player, "item_interaction", action, item:getID(), item:getName())
                end

                return success
            end
            local success = handleComplexInteraction(myItem, "use", player)
            ```
    ]]
    function ITEM:interact(action, client, entity, data)
        assert(client:IsPlayer() and IsValid(client), L("itemActionNoPlayer"))
        local canInteract, reason = hook.Run("CanPlayerInteractItem", client, action, self, data)
        if canInteract == false then
            if reason then client:notifyErrorLocalized(reason) end
            return false
        end

        local oldPlayer, oldEntity = self.player, self.entity
        self.player = client
        self.entity = entity
        local callback = self.functions[action]
        if not callback then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        if isfunction(callback.onCanRun) then
            canInteract = callback.onCanRun(self, data)
        else
            canInteract = true
        end

        if not canInteract then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        hook.Run("PrePlayerInteractItem", client, action, self)
        local result
        if isfunction(self.hooks[action]) then result = self.hooks[action](self, data) end
        if result == nil then
            local isMulti = callback.isMulti or callback.multiOptions and istable(callback.multiOptions)
            if isMulti and isstring(data) and callback.multiOptions then
                local optionFunc = callback.multiOptions[data]
                if optionFunc then
                    if isfunction(optionFunc) then
                        result = optionFunc(self)
                    elseif istable(optionFunc) then
                        local runFunc = optionFunc[1] or optionFunc.onRun
                        if isfunction(runFunc) then result = runFunc(self) end
                    end
                end
            elseif isfunction(callback.onRun) then
                result = callback.onRun(self, data)
            end
        end

        if self.postHooks[action] then self.postHooks[action](self, result, data) end
        hook.Run("OnPlayerInteractItem", client, action, self, result, data)
        if result ~= false and not deferred.isPromise(result) then
            if IsValid(entity) then
                SafeRemoveEntity(entity)
            else
                self:remove()
            end
        end

        self.player = oldPlayer
        self.entity = oldEntity
        return true
    end
end

--[[
    Purpose:
        Gets the localized category name for the item

    When Called:
        When displaying or organizing items by category

    Parameters:
        None

    Returns:
        String representing the localized category name

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        local category = item:getCategory()
        ```

    Medium Complexity:
        ```lua
        if item:getCategory() == "weapons" then
            -- Handle weapon-specific logic
        end
        ```

    High Complexity:
        ```lua
        local function organizeItemsByCategory(items)
            local categories = {}
            for _, item in ipairs(items) do
                local category = item:getCategory()
                categories[category] = categories[category] or {}
                table.insert(categories[category], item)
            end
            -- Sort categories alphabetically
            local sortedCategories = {}
            for categoryName, categoryItems in pairs(categories) do
                table.insert(sortedCategories, {
                    name  = categoryName,
                    items = categoryItems,
                    count = #categoryItems
                })
            end
            table.sort(sortedCategories, function(a, b) return a.name < b.name end)
            return sortedCategories
        end
        local organizedItems = organizeItemsByCategory(playerInventory:getItems())
        ```
]]
function ITEM:getCategory()
    return self.category and L(self.category) or L("misc")
end

lia.meta.item = ITEM
