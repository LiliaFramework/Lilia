--[[
    lia.char.new(data, id, client, steamID)

    Description:
        Creates a new character instance with default variables and metatable.

    Parameters:
        data (table) – Table of character variables.
        id (number) – Character ID.
        client (Player) – Player entity.
        steamID (string) – SteamID64 string if client is not valid.

    Realm:
        Shared

    Returns:
        character (table) – New character object.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.new
        local char = lia.char.new({name = "John"}, 1, client)
]]

--[[
    lia.char.hookVar(varName, hookName, func)

    Description:
        Registers a hook function for when a character variable changes.

    Parameters:
        varName (string) – Variable name to hook.
        hookName (string) – Unique hook identifier.
        func (function) – Function to call on variable change.

    Realm:
        Shared

    Returns:
        nil

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.hookVar
        lia.char.hookVar("name", "PrintName", function(old, new) print(new) end)
]]

--[[
    lia.char.registerVar(key, data)

    Description:
        Registers a character variable with metadata and generates accessor methods.

    Parameters:
        key (string) – Variable key.
        data (table) – Variable metadata including default, validation, networking, etc.

    Realm:
        Shared

    Returns:
        nil

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.registerVar
        lia.char.registerVar("age", {field = "_age", default = 20})
]]

--[[
    lia.char.getCharData(charID, key)

    Description:
        Retrieves character data JSON from the database as a Lua table.

    Parameters:
        charID (number|string) – Character ID.
        key (string) – Specific data key to return (optional).

    Realm:
        Shared

    Returns:
        value (any) – Data value or full table if no key provided.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.getCharData
        local age = lia.char.getCharData(1, "age")
]]

--[[
    lia.char.getCharDataRaw(charID, key)

    Description:
        Retrieves raw character database row or specific column.

    Parameters:
        charID (number|string) – Character ID.
        key (string) – Specific column name to return (optional).

    Realm:
        Shared

    Returns:
        row (table|any) – Full row table or column value.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.getCharDataRaw
        local row = lia.char.getCharDataRaw(1)
]]

--[[
    lia.char.getOwnerByID(ID)

    Description:
        Finds the player entity that owns the character with the given ID.

    Parameters:
        ID (number|string) – Character ID.

    Realm:
        Shared

    Returns:
        Player – Player entity or nil if not found.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.getOwnerByID
        local ply = lia.char.getOwnerByID(1)
]]

--[[
    lia.char.getBySteamID(steamID)

    Description:
        Retrieves a character object by SteamID or SteamID64.

    Parameters:
        steamID (string) – SteamID or SteamID64.

    Realm:
        Shared

    Returns:
        Character – Character object or nil.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.getBySteamID
        local char = lia.char.getBySteamID("STEAM_0:0:11101")
]]

--[[
    lia.char.getAll()

    Description:
        Returns a table mapping all players to their loaded character objects.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Map of Player to Character.

    Example Usage:
        -- This snippet demonstrates a common usage of pairs
        for ply, char in pairs(lia.char.getAll()) do print(ply, char:getName()) end
]]

--[[
    lia.char.GetTeamColor(client)

    Description:
        Determines the team color for a client based on their character class or default team.

    Parameters:
        client (Player) – Player entity.

    Realm:
        Shared

    Returns:
        Color – Team or class color.

    Example Usage:
        -- This snippet demonstrates a common usage of lia.char.GetTeamColor
        local color = lia.char.GetTeamColor(client)
]]

    --[[
        lia.char.create(data, callback)

        Description:
            Inserts a new character into the database and sets up default inventory.

        Parameters:
            data (table) – Character creation data.
            callback (function) – Callback receiving new character ID.

        Realm:
            Server

        Returns:
            None

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.create
            lia.char.create({name = "John"}, function(id) print("Created", id) end)
    ]]

    --[[
        lia.char.restore(client, callback, id)

        Description:
            Loads characters for a client from the database, optionally filtering by ID.

        Parameters:
            client (Player) – Player entity.
            callback (function) – Callback receiving list of character IDs.
            id (number) – Specific character ID to restore (optional).

        Realm:
            Server

        Returns:
            None

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.restore
            lia.char.restore(client, print)
    ]]

    --[[
        lia.char.cleanUpForPlayer(client)

        Description:
            Cleans up loaded characters and inventories for a player on disconnect.

        Parameters:
            client (Player) – Player entity.

        Realm:
            Server

        Returns:
            None

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.cleanUpForPlayer
            lia.char.cleanUpForPlayer(client)
    ]]

    --[[
        lia.char.delete(id, client)

        Description:
            Deletes a character by ID from the database, cleans up and notifies players.

        Parameters:
            id (number) – Character ID to delete.
            client (Player) – Player entity reference.

        Realm:
            Server

        Returns:
            None

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.delete
            lia.char.delete(1, client)
    ]]

    --[[
        lia.char.setCharData(charID, key, val)

        Description:
            Updates a character's JSON data field in the database and loaded object.

        Parameters:
            charID (number|string) – Character ID.
            key (string) – Data key.
            val (any) – New value.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.setCharData
            lia.char.setCharData(1, "age", 25)
    ]]

    --[[
        lia.char.setCharName(charID, name)

        Description:
            Updates the character's name in the database and loaded object.

        Parameters:
            charID (number|string) – Character ID.
            name (string) – New character name.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.setCharName
            lia.char.setCharName(1, "NewName")
    ]]

    --[[
        lia.char.setCharModel(charID, model, bg)

        Description:
            Updates the character's model and bodygroups in the database and in-game.

        Parameters:
            charID (number|string) – Character ID.
            model (string) – Model path.
            bg (table) – Bodygroup table list.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.

        Example Usage:
        -- This snippet demonstrates a common usage of lia.char.setCharModel
            lia.char.setCharModel(1, "models/player.mdl", {})
    ]]
