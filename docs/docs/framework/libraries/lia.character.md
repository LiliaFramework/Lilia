        ## lia.char.new(data, id, client, steamID)

        **Description:**
            Creates a new character instance with default variables and metatable.

        ---

        ### Parameters

            * **data** *(table)*: Table of character variables.
            * **id** *(number)*: Character ID.
            * **client** *(Player)*: Player entity.
            * **steamID** *(string)*: SteamID64 string if client is not valid.

        ---

        ### Returns

            * **character** *(table)*: New character object.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.hookVar(varName, hookName, func)

        **Description:**
            Registers a hook function for when a character variable changes.

        ---

        ### Parameters

            * **varName** *(string)*: Variable name to hook.
            * **hookName** *(string)*: Unique hook identifier.
            * **func** *(function)*: Function to call on variable change.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.registerVar(key, data)

        **Description:**
            Registers a character variable with metadata and generates accessor methods.

        ---

        ### Parameters

            * **key** *(string)*: Variable key.
            * **data** *(table)*: Variable metadata including default, validation, networking, etc.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.getCharData(charID, key)

        **Description:**
            Retrieves character data JSON from the database as a Lua table.

        ---

        ### Parameters

            * **charID** *(number|string)*: Character ID.
            * **key** *(string)*: Specific data key to return (optional).

        ---

        ### Returns

            * **value** *(any)*: Data value or full table if no key provided.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.getCharDataRaw(charID, key)

        **Description:**
            Retrieves raw character database row or specific column.

        ---

        ### Parameters

            * **charID** *(number|string)*: Character ID.
            * **key** *(string)*: Specific column name to return (optional).

        ---

        ### Returns

            * **row** *(table|any)*: Full row table or column value.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.getOwnerByID(ID)

        **Description:**
            Finds the player entity that owns the character with the given ID.

        ---

        ### Parameters

            * **ID** *(number|string)*: Character ID.

        ---

        ### Returns

            * Player – Player entity or nil if not found.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.getBySteamID(steamID)

        **Description:**
            Retrieves a character object by SteamID or SteamID64.

        ---

        ### Parameters

            * **steamID** *(string)*: SteamID or SteamID64.

        ---

        ### Returns

            * Character – Character object or nil.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.getAll()

        **Description:**
            Returns a table mapping all players to their loaded character objects.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * table – Map of Player to Character.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.GetTeamColor(client)

        **Description:**
            Determines the team color for a client based on their character class or default team.

        ---

        ### Parameters

            * **client** *(Player)*: Player entity.

        ---

        ### Returns

            * Color – Team or class color.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.char.create(data, callback)

        **Description:**
            Inserts a new character into the database and sets up default inventory.

        ---

        ### Parameters

            * **data** *(table)*: Character creation data.
            * **callback** *(function)*: Callback receiving new character ID.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.restore(client, callback, id)

        **Description:**
            Loads characters for a client from the database, optionally filtering by ID.

        ---

        ### Parameters

            * **client** *(Player)*: Player entity.
            * **callback** *(function)*: Callback receiving list of character IDs.
            * **id** *(number)*: Specific character ID to restore (optional).

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.cleanUpForPlayer(client)

        **Description:**
            Cleans up loaded characters and inventories for a player on disconnect.

        ---

        ### Parameters

            * **client** *(Player)*: Player entity.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.delete(id, client)

        **Description:**
            Deletes a character by ID from the database, cleans up and notifies players.

        ---

        ### Parameters

            * **id** *(number)*: Character ID to delete.
            * **client** *(Player)*: Player entity reference.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.setCharData(charID, key, val)

        **Description:**
            Updates a character's JSON data field in the database and loaded object.

        ---

        ### Parameters

            * **charID** *(number|string)*: Character ID.
            * **key** *(string)*: Data key.
            * **val** *(any)*: New value.

        ---

        ### Returns

            * boolean – True on success, false on failure.

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.setCharName(charID, name)

        **Description:**
            Updates the character's name in the database and loaded object.

        ---

        ### Parameters

            * **charID** *(number|string)*: Character ID.
            * **name** *(string)*: New character name.

        ---

        ### Returns

            * boolean – True on success, false on failure.

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.char.setCharModel(charID, model, bg)

        **Description:**
            Updates the character's model and bodygroups in the database and in-game.

        ---

        ### Parameters

            * **charID** *(number|string)*: Character ID.
            * **model** *(string)*: Model path.
            * **bg** *(table)*: Bodygroup table list.

        ---

        ### Returns

            * boolean – True on success, false on failure.

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

