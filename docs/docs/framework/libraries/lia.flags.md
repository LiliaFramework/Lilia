        ## lia.flag.add

        **Description:**
            Registers a new flag by adding it to the flag list.
Each flag has a description and an optional callback that is executed when the flag is applied to a player.

        ---

        ### Parameters

            * **flag** *(string)*: The unique flag identifier.
            * **desc** *(string)*: A description of what the flag does.
            * **callback** *(function)*: An optional callback function executed when the flag is applied to a player.

        ---

        ### Returns

            * nil

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            lia.flag.add("C", "Spawn vehicles.")
            ```

        ## lia.flag.onSpawn

        **Description:**
            Called when a player spawns. This function checks the player's character flags and triggers
the associated callbacks for each flag that the character possesses.

        ---

        ### Parameters

            * **client** *(Player)*: The player who spawned.

        ---

        ### Returns

            * nil

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            lia.flag.onSpawn(player)
            ```

