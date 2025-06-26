        ## GetDefaultName

        **Realm:** Shared

        **Description:**
            Retrieves the default name for a character upon initial creation within the faction.
            

        ---

        ### Parameters

            * **client** *(Player)*: The client for whom the default name is being retrieved.

        ---

        ### Example

            ```lua
            function FACTION:GetDefaultName(client)
            return "CT-" .. math.random(111111, 999999)
            end
            ```

        ## GetDefaultDesc

        **Realm:** Shared

        **Description:**
            Retrieves the default description for a character upon initial creation within the faction.
            

        ---

        ### Parameters

            * **client** *(Player)*: The client for whom the default description is being retrieved.
            * **faction** *(Number)*: The faction ID for which the default description is being retrieved.

        ---

        ### Example

            ```lua
            function FACTION:GetDefaultDesc(client, faction)
            return "A police officer"
            end
            ```

        ## OnCharCreated

        **Realm:** Server

        **Description:**
            Executes actions when a character is created and assigned to the faction. Typically used to initialize character-specific data or inventory.
            

        ---

        ### Parameters

            * **client** *(Player)*: The client that owns the character.
            * **character** *(Character)*: The character that has been created.

        ---

        ### Example

            ```lua
            function FACTION:OnCharCreated(client, character)
            local inventory = character:getInv()
            inventory:add("fancy_suit")
            end
            ```

        ## OnSpawn

        **Realm:** Server

        **Description:**
            Executes actions when a faction member spawns in the game world. Useful for setting up player-specific settings or notifications.
            

        ---

        ### Parameters

            * **client** *(Player)*: The player that has just spawned.

        ---

        ### Example

            ```lua
            function FACTION:OnSpawn(client)
            client:ChatPrint("You have spawned!")
            end
            ```

        ## OnTransferred

        **Realm:** Server

        **Description:**
            Executes actions when a character is transferred to the faction.
            

        ---

        ### Parameters

            * **character** *(Character)*: The character that was transferred.

        ---

        ### Example

            ```lua
            function FACTION:OnTransferred(character)
            local randomModelIndex = math.random(1, #self.models)
            character:setModel(self.models[randomModelIndex])
            end
            ```

