        ## Entity:getParts()

        **Description:**
            Retrieves the PAC3 parts currently equipped on this player.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * **parts** *(table)*: Table of equipped part IDs.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## Entity:syncParts()

        **Description:**
            Sends the player's equipped PAC3 parts to the client.

        ---

        ### Parameters

            * None

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

        ## Entity:addPart(partID)

        **Description:**
            Adds a PAC3 part to the player and broadcasts the change.

        ---

        ### Parameters

            * **partID** *(string)*: Identifier of the part to add.

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

        ## Entity:removePart(partID)

        **Description:**
            Removes a PAC3 part from the player and broadcasts the change.

        ---

        ### Parameters

            * **partID** *(string)*: Identifier of the part to remove.

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

        ## Entity:resetParts()

        **Description:**
            Clears all PAC3 parts from the player and notifies clients.

        ---

        ### Parameters

            * None

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

