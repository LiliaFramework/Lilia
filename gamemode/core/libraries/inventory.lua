lia.inventory = lia.inventory or {}
lia.inventory.types = lia.inventory.types or {}
lia.inventory.instances = lia.inventory.instances or {}
local function serverOnly(value)
    return SERVER and value or nil
end

local InvTypeStructType = {
    __index = "table",
    add = serverOnly("function"),
    remove = serverOnly("function"),
    sync = serverOnly("function"),
    typeID = "string",
    className = "string"
}

local function checkType(typeID, struct, expected, prefix)
    prefix = prefix or ""
    for key, expectedType in pairs(expected) do
        local actualValue = struct[key]
        local expectedTypeString = isstring(expectedType) and expectedType or type(expectedType)
        assert(type(actualValue) == expectedTypeString, "expected type of " .. prefix .. key .. " to be " .. expectedTypeString .. " for inventory type " .. typeID .. ", got " .. type(actualValue))
        if istable(expectedType) then checkType(typeID, actualValue, expectedType, prefix .. key .. ".") end
    end
end

--[[
    lia.inventory.newType(typeID, invTypeStruct)

   Description:
      Registers a new inventory type.

   Parameters:
      typeID (string) — unique identifier
      invTypeStruct (table) — definition matching InvTypeStructType

    Returns:
        nil
]]
function lia.inventory.newType(typeID, invTypeStruct)
    assert(not lia.inventory.types[typeID], "duplicate inventory type " .. typeID)
    assert(istable(invTypeStruct), "expected table for argument #2")
    checkType(typeID, invTypeStruct, InvTypeStructType)
    debug.getregistry()[invTypeStruct.className] = invTypeStruct
    lia.inventory.types[typeID] = invTypeStruct
end

--[[
    lia.inventory.new(typeID)

   Description:
      Instantiates a new inventory instance.

   Parameters:
      typeID (string)

    Returns:
        table
]]
function lia.inventory.new(typeID)
    local class = lia.inventory.types[typeID]
    assert(class ~= nil, "bad inventory type " .. typeID)
    return setmetatable({
        items = {},
        config = table.Copy(class.config)
    }, class)
end

if SERVER then
    local INV_FIELDS = {"_invID", "_invType", "_charID"}
    local INV_TABLE = "inventories"
    local DATA_FIELDS = {"_key", "_value"}
    local DATA_TABLE = "invdata"
    local ITEMS_TABLE = "items"
    --[[
      lia.inventory.loadByID(id, noCache)

      Description:
         Loads an inventory by ID (cached or via custom loader).

      Parameters:
         id (number), noCache? (boolean)

      Returns:
          deferred
   ]]
    function lia.inventory.loadByID(id, noCache)
        local instance = lia.inventory.instances[id]
        if instance and not noCache then
            local d = deferred.new()
            d:resolve(instance)
            return d
        end

        for _, invType in pairs(lia.inventory.types) do
            local loadFunction = rawget(invType, "loadFromStorage")
            if loadFunction then
                local d = loadFunction(invType, id)
                if d then return d end
            end
        end

        assert(isnumber(id) and id >= 0, "No inventories implement loadFromStorage for ID " .. tostring(id))
        return lia.inventory.loadFromDefaultStorage(id, noCache)
    end

    --[[
      lia.inventory.loadFromDefaultStorage(id, noCache)

      Description:
         Default database loader.

      Parameters:
         id (number), noCache? (boolean)

      Returns:
          deferred
   ]]
    function lia.inventory.loadFromDefaultStorage(id, noCache)
        return deferred.all({lia.db.select(INV_FIELDS, INV_TABLE, "_invID = " .. id, 1), lia.db.select(DATA_FIELDS, DATA_TABLE, "_invID = " .. id)}):next(function(res)
            if lia.inventory.instances[id] and not noCache then return lia.inventory.instances[id] end
            local results = res[1].results and res[1].results[1] or nil
            if not results then return end
            local typeID = results._invType
            local invType = lia.inventory.types[typeID]
            if not invType then
                ErrorNoHalt("Inventory " .. id .. " has invalid type " .. typeID .. "\n")
                return
            end

            local instance = invType:new()
            instance.id = id
            instance.data = {}
            for _, row in ipairs(res[2].results or {}) do
                local decoded = util.JSONToTable(row._value)
                instance.data[row._key] = decoded and decoded[1] or nil
            end

            instance.data.char = tonumber(results._charID) or instance.data.char
            lia.inventory.instances[id] = instance
            instance:onLoaded()
            return instance:loadItems():next(function() return instance end)
        end, function(err)
            LiliaInformation("Failed to load inventory " .. tostring(id))
            LiliaInformation(err)
        end)
    end

    --[[
      lia.inventory.instance(typeID, initialData)

      Description:
         Creates & persists a new inventory instance.

      Parameters:
         typeID (string), initialData? (table)

      Returns:
          deferred
   ]]
    function lia.inventory.instance(typeID, initialData)
        local invType = lia.inventory.types[typeID]
        assert(istable(invType), "invalid inventory type " .. tostring(typeID))
        assert(initialData == nil or istable(initialData), "initialData must be a table for lia.inventory.instance")
        initialData = initialData or {}
        return invType:initializeStorage(initialData):next(function(id)
            local instance = invType:new()
            instance.id = id
            instance.data = initialData
            lia.inventory.instances[id] = instance
            instance:onInstanced()
            return instance
        end)
    end

    --[[
      lia.inventory.loadAllFromCharID(charID)

      Description:
         Loads all inventories for a character.

      Parameters:
         charID (number)

      Returns:
          deferred
   ]]
    function lia.inventory.loadAllFromCharID(charID)
        assert(isnumber(charID), "charID must be a number")
        return lia.db.select({"_invID"}, INV_TABLE, "_charID = " .. charID):next(function(res) return deferred.map(res.results or {}, function(result) return lia.inventory.loadByID(tonumber(result._invID)) end) end)
    end

    --[[
      lia.inventory.deleteByID(id)

      Description:
         Deletes an inventory and its data.

      Parameters:
         id (number)

      Returns:
          nil
   ]]
    function lia.inventory.deleteByID(id)
        lia.db.delete(DATA_TABLE, "_invID = " .. id)
        lia.db.delete(INV_TABLE, "_invID = " .. id)
        lia.db.delete(ITEMS_TABLE, "_invID = " .. id)
        local instance = lia.inventory.instances[id]
        if instance then instance:destroy() end
    end

    --[[
      lia.inventory.cleanUpForCharacter(character)

      Description:
         Destroys all inventories for a character.

      Parameters:
         character

      Returns:
          nil
   ]]
    function lia.inventory.cleanUpForCharacter(character)
        for _, inventory in pairs(character:getInv(true)) do
            inventory:destroy()
        end
    end
else
    --[[
      lia.inventory.show(inventory, parent)

      Description:
         Displays inventory UI client‑side.

      Parameters:
         inventory, parent

      Returns:
          Panel
   ]]
    function lia.inventory.show(inventory, parent)
        local globalName = "inv" .. inventory.id
        if IsValid(lia.gui[globalName]) then lia.gui[globalName]:Remove() end
        local panel = hook.Run("CreateInventoryPanel", inventory, parent)
        lia.gui[globalName] = panel
        return panel
    end
end