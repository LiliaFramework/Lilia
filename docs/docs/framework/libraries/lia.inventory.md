        ## lia.inventory.newType(typeID, invTypeStruct)

        **Description:**
            Registers a new inventory type.

        ---

        ### Parameters

            * typeID (string) — unique identifier
            * invTypeStruct (table) — definition matching InvTypeStructType

        ---

        ### Returns

            * nil

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.new(typeID)

        **Description:**
            Instantiates a new inventory instance.

        ---

        ### Parameters

            * typeID (string)

        ---

        ### Returns

            * table

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.loadByID(id, noCache)

        **Description:**
            Loads an inventory by ID (cached or via custom loader).

        ---

        ### Parameters

            * id (number), noCache? (boolean)

        ---

        ### Returns

            * deferred

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.loadFromDefaultStorage(id, noCache)

        **Description:**
            Default database loader.

        ---

        ### Parameters

            * id (number), noCache? (boolean)

        ---

        ### Returns

            * deferred

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.instance(typeID, initialData)

        **Description:**
            Creates & persists a new inventory instance.

        ---

        ### Parameters

            * typeID (string), initialData? (table)

        ---

        ### Returns

            * deferred

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.loadAllFromCharID(charID)

        **Description:**
            Loads all inventories for a character.

        ---

        ### Parameters

            * charID (number)

        ---

        ### Returns

            * deferred

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.deleteByID(id)

        **Description:**
            Deletes an inventory and its data.

        ---

        ### Parameters

            * id (number)

        ---

        ### Returns

            * nil

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.cleanUpForCharacter(character)

        **Description:**
            Destroys all inventories for a character.

        ---

        ### Parameters

            * character

        ---

        ### Returns

            * nil

        ---

        ### Example

            ```lua
            ```

        ## lia.inventory.show(inventory, parent)

        **Description:**
            Displays inventory UI client‑side.

        ---

        ### Parameters

            * inventory, parent

        ---

        ### Returns

            * Panel

        ---

        ### Example

            ```lua
            ```

