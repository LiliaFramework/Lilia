lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.list = lia.item.list or {}
lia.item.instances = lia.item.instances or {}
lia.item.inventories = lia.inventory.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
local DefaultFunctions = {
    drop = {
        tip = "dropTip",
        icon = "icon16/world.png",
        onRun = function(item)
            local client = item.player
            item:removeFromInventory(true):next(function() item:spawn(client) end)
            return false
        end,
        onCanRun = function(item) return item.entity == nil and not IsValid(item.entity) and not item.noDrop end
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

                if not IsValid(client) then return end
                d:resolve()
            end):catch(function(err)
                if err == "noFit" then
                    client:notifyLocalized("itemNoFit", item.width, item.height)
                else
                    client:notifyLocalized(err)
                end

                client.itemTakeTransaction = nil
                d:reject()
            end)
            return d
        end,
        onCanRun = function(item) return IsValid(item.entity) end
    },
    giveForward = {
        tip = "giveForwardTip",
        icon = "icon16/arrow_up.png",
        onRun = function(item)
            local function canTransferItemsFromInventoryUsingGiveForward(_, action, _)
                if action == "transfer" then return true end
            end

            local client = item.player
            local inv = client:getChar():getInv()
            local target = client:GetEyeTraceNoCursor().Entity
            if not (target and target:IsValid() and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500) then return false end
            local targetInv = target:getChar():getInv()
            if not target or not targetInv then return false end
            inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
            targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
            client:setAction("Giving " .. item.name .. " to " .. target:Name(), lia.config.get("ItemGiveSpeed", 6))
            target:setAction(client:Name() .. " is giving you a " .. item.name, lia.config.get("ItemGiveSpeed", 6))
            client:doStaredAction(target, function()
                local res = hook.Run("HandleItemTransferRequest", client, item:getID(), nil, nil, targetInv:getID())
                if not res then return end
                res:next(function()
                    if not IsValid(client) then return end
                    if istable(res) and isstring(res.error) then return client:notifyLocalized(res.error) end
                    client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
                end)
            end, lia.config.get("ItemGiveSpeed", 6), function() client:setAction() end, 100)
            return false
        end,
        onCanRun = function(item)
            local client = item.player
            local target = client:GetEyeTraceNoCursor().Entity
            return item.entity == nil and lia.config.get("ItemGiveEnabled") and not IsValid(item.entity) and not item.noDrop and target and IsValid(target) and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500
        end
    }
}

lia.meta.item.width = 1
lia.meta.item.height = 1
--[[
   lia.item.get

   Description:
      Retrieves an item definition by its identifier, checking both lia.item.base and lia.item.list.

   Parameters:
      identifier (string) - The unique identifier of the item.

   Returns:
      The item table if found, otherwise nil.

   Realm:
      Shared

   Example Usage:
      local itemDef = lia.item.get("testItem")
]]
function lia.item.get(identifier)
    return lia.item.base[identifier] or lia.item.list[identifier]
end

--[[
   lia.item.getItemByID

   Description:
      Retrieves an item instance by its numeric item ID. Also determines whether it's in an inventory
      or in the world.

   Parameters:
      itemID (number) - The numeric item ID.

   Returns:
      A table containing 'item' (the item object) and 'location' (the string location) if found,
      otherwise nil and an error message.

   Realm:
      Shared

   Example Usage:
      local result = lia.item.getItemByID(42)
      if result then
          print("Item location: " .. result.location)
      end
]]
function lia.item.getItemByID(itemID)
    assert(isnumber(itemID), "itemID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
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
   lia.item.getInstancedItemByID

   Description:
      Retrieves the item instance table itself by its numeric ID without additional location info.

   Parameters:
      itemID (number) - The numeric item ID.

   Returns:
      The item instance table if found, otherwise nil and an error message.

   Realm:
      Shared

   Example Usage:
      local itemInstance = lia.item.getInstancedItemByID(42)
      if itemInstance then
          print("Got item: " .. itemInstance.name)
      end
]]
function lia.item.getInstancedItemByID(itemID)
    assert(isnumber(itemID), "itemID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
    return item
end

--[[
   lia.item.getItemDataByID

   Description:
      Retrieves the 'data' table of an item instance by its numeric item ID.

   Parameters:
      itemID (number) - The numeric item ID.

   Returns:
      The data table if found, otherwise nil and an error message.

   Realm:
      Shared

   Example Usage:
      local data = lia.item.getItemDataByID(42)
      if data then
          print("Item data found.")
      end
]]
function lia.item.getItemDataByID(itemID)
    assert(isnumber(itemID), "itemID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
    return item.data
end

--[[
   lia.item.load

   Description:
      Processes the item file path to generate a uniqueID, and calls lia.item.register
      to register the item. Used for loading items from directory structures.

   Parameters:
      path (string) - The path to the Lua file for the item.
      baseID (string) - The base item's uniqueID to inherit from.
      isBaseItem (boolean) - Whether this item is a base item.

   Returns:
      None

   Realm:
      Shared

   Example Usage:
      lia.item.load("items/base/sh_item_base.lua", nil, true)
]]
function lia.item.load(path, baseID, isBaseItem)
    local uniqueID = path:match("sh_([_%w]+)%.lua") or path:match("([_%w]+)%.lua")
    if uniqueID then
        uniqueID = (isBaseItem and "base_" or "") .. uniqueID
        lia.item.register(uniqueID, baseID, isBaseItem, path)
    elseif not path:find(".txt") then
        ErrorNoHalt("[Lilia] Item at '" .. path .. "' follows an invalid naming convention!\n")
    end
end

--[[
   lia.item.isItem

   Description:
      Checks if the given object is recognized as an item (via isItem flag).

   Parameters:
      object (any) - The object to check.

   Returns:
      true if the object is an item, false otherwise.

   Realm:
      Shared

   Example Usage:
      local result = lia.item.isItem(myObject)
      if result then
          print("It's an item!")
      end
]]
function lia.item.isItem(object)
    return istable(object) and object.isItem
end

--[[
   lia.item.getInv

   Description:
      Retrieves an inventory table by its ID from lia.item.inventories.

   Parameters:
      id (number) - The ID of the inventory to retrieve.

   Returns:
      The inventory table if found, otherwise nil.

   Realm:
      Shared

   Example Usage:
      local inv = lia.item.getInv(5)
      if inv then
          print("Got inventory with ID 5")
      end
]]
function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

--[[
   lia.item.register

   Description:
      Registers a new item or base item with a unique ID. This sets up the meta table
      and merges data from the specified base. Optionally includes the file if provided.

   Parameters:
      uniqueID (string) - The unique identifier for the item.
      baseID (string) - The unique identifier of the base item.
      isBaseItem (boolean) - Whether this should be registered as a base item.
      path (string) - The optional path to the item file for inclusion.
      luaGenerated (boolean) - True if the item is generated in code without file.

   Returns:
      The registered item table.

   Realm:
      Shared

   Example Usage:
      lia.item.register("special_item", "base_item", false, "path/to/item.lua")
]]
function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
    assert(isstring(uniqueID), "uniqueID must be a string")
    local baseTable = lia.item.base[baseID] or lia.meta.item
    if baseID then assert(baseTable, "Item " .. uniqueID .. " has a non-existent base " .. baseID) end
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
        ITEM.category = ITEM.category or "Miscellaneous"
        ITEM.functions = table.Copy(baseTable.functions or DefaultFunctions)
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
        ITEM.category = ITEM.category or "Miscellaneous"
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or DefaultFunctions)
    end

    if not luaGenerated and path then lia.include(path, "shared") end
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    hook.Run("OnItemRegistered", ITEM)
    ITEM = nil
    return targetTable[itemType]
end

--[[
   lia.item.loadFromDir

   Description:
      Loads item Lua files from a specified directory. Base items are loaded first,
      then any folders (with base_ prefix usage), and finally any loose Lua files.

   Parameters:
      directory (string) - The path to the directory containing item files.

   Returns:
      None

   Realm:
      Shared

   Example Usage:
      lia.item.loadFromDir("lilia/gamemode/items")
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
   lia.item.new

   Description:
      Creates an item instance (not in the database) from a registered item definition.
      The new item is stored in lia.item.instances using the provided item ID.

   Parameters:
      uniqueID (string) - The unique identifier of the item definition.
      id (number) - The numeric ID for this new item instance.

   Returns:
      The newly created item instance.

   Realm:
      Shared

   Example Usage:
      local newItem = lia.item.new("testItem", 101)
      print(newItem.id) -- 101
]]
function lia.item.new(uniqueID, id)
    id = id and tonumber(id) or id
    assert(isnumber(id), "non-number ID given to lia.item.new")
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
        return item
    else
        error("[Lilia] Attempt to create an unknown item '" .. tostring(uniqueID) .. "'\n")
    end
end

--[[
   lia.item.registerInv

   Description:
      Registers an inventory type with a given width and height. The inventory type
      becomes accessible for creation or usage in the system.

   Parameters:
      invType (string) - The inventory type name (identifier).
      w (number) - The width of this inventory type.
      h (number) - The height of this inventory type.

   Returns:
      None

   Realm:
      Shared

   Example Usage:
      lia.item.registerInv("smallInv", 4, 4)
]]
function lia.item.registerInv(invType, w, h)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, "GridInv not found")
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
   lia.item.newInv

   Description:
      Asynchronously creates a new inventory (with a specific invType) and associates it
      with the given character owner. Once created, it syncs the inventory to the owner if online.

   Parameters:
      owner (number) - The character ID who owns this inventory.
      invType (string) - The inventory type (must be registered first).
      callback (function) - Optional callback function receiving the new inventory.

   Returns:
      None (asynchronous, uses a deferred internally).

   Realm:
      Shared

   Example Usage:
      lia.item.newInv(10, "smallInv", function(inventory)
          print("New inventory created:", inventory.id)
      end)
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
   lia.item.createInv

   Description:
      Creates a new GridInv instance with a specified width, height, and ID,
      then caches it in lia.inventory.instances.

   Parameters:
      w (number) - The width of the inventory.
      h (number) - The height of the inventory.
      id (number) - The numeric ID to assign to this inventory.

   Returns:
      The newly created GridInv instance.

   Realm:
      Shared

   Example Usage:
      local inv = lia.item.createInv(6, 6, 200)
      print("Created inventory with ID:", inv.id)
]]
function lia.item.createInv(w, h, id)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, "GridInv not found")
    local instance = GridInv:new()
    instance.id = id
    instance.data = {
        w = w,
        h = h
    }

    lia.inventory.instances[id] = instance
    return instance
end

if SERVER then
    --[[
       lia.item.setItemDataByID

       Description:
          Sets a specific key-value in the data table of an item instance by its numeric ID.
          Optionally notifies receivers about the change.

       Parameters:
          itemID (number) - The numeric item ID.
          key (string) - The data key to set.
          value (any) - The value to set for the specified key.
          receivers (table) - Optional table of players to receive the update.
          noSave (boolean) - If true, won't save the data to the database immediately.
          noCheckEntity (boolean) - If true, won't check if the item entity is valid.

       Returns:
          true if successful, false and error message if item not found.

       Realm:
          Server

       Example Usage:
          local success, err = lia.item.setItemDataByID(50, "durability", 90)
          if not success then
              print("Error:", err)
          end
    ]]
    function lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)
        assert(isnumber(itemID), "itemID must be a number")
        assert(isstring(key), "key must be a string")
        local item = lia.item.instances[itemID]
        if not item then return false, "Item not found" end
        item:setData(key, value, receivers, noSave, noCheckEntity)
        return true
    end

    --[[
       lia.item.instance

       Description:
          Asynchronously creates a new item in the database, optionally assigned to an inventory.
          Once the item is created, a new item object is constructed and returned via a deferred.

       Parameters:
          index (number) - The inventory ID to place the item into (or 0/NULL if none).
          uniqueID (string) - The item definition's unique ID.
          itemData (table) - The data table to store on the item.
          x (number) - Optional grid X position (for grid inventories).
          y (number) - Optional grid Y position.
          callback (function) - Optional callback with the newly created item.

       Returns:
          A deferred object that resolves to the new item.

       Realm:
          Server

       Example Usage:
          lia.item.instance(1, "testItem", {someKey = "someValue"}):next(function(item)
              print("Item created with ID:", item.id)
          end)
    ]]
    function lia.item.instance(index, uniqueID, itemData, x, y, callback)
        if isstring(index) and (istable(uniqueID) or itemData == nil and x == nil) then
            itemData = uniqueID
            uniqueID = index
        end

        local d = deferred.new()
        local itemTable = lia.item.list[uniqueID]
        if not itemTable then
            d:reject("Attempt to instantiate invalid item " .. tostring(uniqueID))
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
        if MYSQLOO_PREPARED and isnumber(index) then
            lia.db.preparedCall("itemInstance", onItemCreated, index, uniqueID, itemData, x, y, itemTable.maxQuantity or 1)
        else
            lia.db.insertTable({
                _invID = index,
                _uniqueID = uniqueID,
                _data = itemData,
                _x = x,
                _y = y,
                _quantity = itemTable.maxQuantity or 1
            }, onItemCreated, "items")
        end
        return d
    end

    --[[
       lia.item.deleteByID

       Description:
          Deletes an item from the system (database and memory) by its numeric ID.

       Parameters:
          id (number) - The numeric item ID to delete.

       Returns:
          None

       Realm:
          Server

       Example Usage:
          lia.item.deleteByID(42)
    ]]
    function lia.item.deleteByID(id)
        if lia.item.instances[id] then
            lia.item.instances[id]:delete()
        else
            lia.db.delete("items", "_itemID = " .. id)
        end
    end

    --[[
       lia.item.loadItemByID

       Description:
          Loads items from the database by a given ID or set of IDs, creating the corresponding
          item instances in memory. This is commonly used during inventory or character loading.

       Parameters:
          itemIndex (number or table) - Either a single numeric item ID or a table of numeric item IDs.

       Returns:
          None (asynchronous query).

       Realm:
          Server

       Example Usage:
          lia.item.loadItemByID(42)
          -- or
          lia.item.loadItemByID({10, 11, 12})
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

        lia.db.query("SELECT _itemID, _uniqueID, _data, _x, _y, _quantity FROM lia_items WHERE _itemID IN " .. range, function(data)
            if data then
                for _, v in ipairs(data) do
                    local itemID = tonumber(v._itemID)
                    local data = util.JSONToTable(v._data or "[]")
                    local uniqueID = v._uniqueID
                    local itemTable = lia.item.list[uniqueID]
                    if itemTable and itemID then
                        local item = lia.item.new(uniqueID, itemID)
                        item.invID = 0
                        item.data = data or {}
                        item.data.x = tonumber(v._x)
                        item.data.y = tonumber(v._y)
                        item.quantity = tonumber(v._quantity)
                        item:onRestored()
                    end
                end
            end
        end)
    end

    --[[
       lia.item.spawn

       Description:
          Creates a new item instance (not in an inventory) and spawns a corresponding
          entity in the world at the specified position/angles.

       Parameters:
          uniqueID (string) - The unique ID of the item definition.
          position (Vector) - The spawn position in the world.
          callback (function) - Optional callback when the item and entity are created.
          angles (Angle) - Optional spawn angles.
          data (table) - Additional data to set on the item.

       Returns:
          A deferred object if callback is not given, otherwise none.

       Realm:
          Server

       Example Usage:
          lia.item.spawn("testItem", Vector(0,0,0)):next(function(item)
              print("Spawned item entity with ID:", item.id)
          end)
    ]]
    function lia.item.spawn(uniqueID, position, callback, angles, data)
        local d
        if not isfunction(callback) then
            if isangle(callback) == "Angle" or istable(angles) then
                angles = callback
                data = angles
            end

            d = deferred.new()
            callback = function(item) d:resolve(item) end
        end

        lia.item.instance(0, uniqueID, data or {}, 1, 1, function(item)
            item:spawn(position, angles)
            if callback then callback(item) end
        end)
        return d
    end

    --[[
       lia.item.restoreInv

       Description:
          Restores an existing inventory by loading it through lia.inventory.loadByID,
          then sets its width/height data, optionally providing a callback once loaded.

       Parameters:
          invID (number) - The inventory ID to restore.
          w (number) - Width to set for the inventory.
          h (number) - Height to set for the inventory.
          callback (function) - Optional function to call once the inventory is restored.

       Returns:
          None (asynchronous call).

       Realm:
          Server

       Example Usage:
          lia.item.restoreInv(101, 5, 5, function(inv)
              print("Restored inventory with ID 101.")
          end)
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
