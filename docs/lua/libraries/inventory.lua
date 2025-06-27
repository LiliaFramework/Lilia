--[[
    lia.inventory.newType(typeID, invTypeStruct)

   Description:
      Registers a new inventory type.

  Parameters:
      typeID (string) — unique identifier
      invTypeStruct (table) — definition matching InvTypeStructType

    Realm:
        Shared

    Returns:
        nil

    Example Usage:
        -- [[ Example of how to use this function ]]
        lia.inventory.newType("bag", {className = "liaBag"})
]]

--[[
    lia.inventory.new(typeID)

   Description:
      Instantiates a new inventory instance.

   Parameters:
      typeID (string)

    Realm:
        Shared

    Returns:
        table

    Example Usage:
        -- [[ Example of how to use this function ]]
        local inv = lia.inventory.new("bag")
]]

    --[[
      lia.inventory.loadByID(id, noCache)

      Description:
         Loads an inventory by ID (cached or via custom loader).

      Parameters:
         id (number), noCache? (boolean)

      Realm:
          Server

      Returns:
          deferred

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.loadByID(1):next(function(inv) print(inv) end)
   ]]

    --[[
      lia.inventory.loadFromDefaultStorage(id, noCache)

      Description:
         Default database loader.

      Parameters:
         id (number), noCache? (boolean)

      Realm:
          Server

      Returns:
          deferred

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.loadFromDefaultStorage(1)
   ]]

    --[[
      lia.inventory.instance(typeID, initialData)

      Description:
         Creates & persists a new inventory instance.

      Parameters:
         typeID (string), initialData? (table)

      Realm:
          Server

      Returns:
          deferred

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.instance("bag", {charID = 1})
   ]]

    --[[
      lia.inventory.loadAllFromCharID(charID)

      Description:
         Loads all inventories for a character.

      Parameters:
         charID (number)

      Realm:
          Server

      Returns:
          deferred

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.loadAllFromCharID(client:getChar():getID())
   ]]

    --[[
      lia.inventory.deleteByID(id)

      Description:
         Deletes an inventory and its data.

      Parameters:
         id (number)

      Realm:
          Server

      Returns:
          nil

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.deleteByID(1)
   ]]

    --[[
      lia.inventory.cleanUpForCharacter(character)

      Description:
         Destroys all inventories for a character.

      Parameters:
         character

      Realm:
          Server

      Returns:
          nil

      Example Usage:
        -- [[ Example of how to use this function ]]
          lia.inventory.cleanUpForCharacter(client:getChar())
   ]]

    --[[
      lia.inventory.show(inventory, parent)

      Description:
         Displays inventory UI client‑side.

      Parameters:
         inventory, parent

      Realm:
          Client

      Returns:
          Panel

      Example Usage:
        -- [[ Example of how to use this function ]]
          local panel = lia.inventory.show(inv)
   ]]
