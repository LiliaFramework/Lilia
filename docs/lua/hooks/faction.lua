--[[
    This file documents FACTION functions defined within the codebase.

    Generated automatically.
]]

--[[
        GetDefaultName(client)

        Description:
            Retrieves the default name for a character upon initial creation within the faction.

        Parameters:
            client (Player) – The client for whom the default name is being retrieved.

        Realm:
            Shared

        Returns:
            string – Default name text.

        Example Usage:
            -- Creates a clone trooper style name for new characters.
            function FACTION:GetDefaultName(client)
                return "CT-" .. math.random(111111, 999999)
            end
]]
--[[
        GetDefaultDesc(client)

        Description:
            Retrieves the default description for a character upon initial creation within the faction.

        Parameters:
            client (Player) – The client for whom the default description is being retrieved.

        Realm:
            Shared

        Returns:
            string – Default description text.

        Example Usage:
            -- Provides a simple police-themed description.
            function FACTION:GetDefaultDesc(client)
                return "A police officer"
            end
]]
--[[
        OnCharCreated(client, character)

        Description:
            Executes actions when a character is created and assigned to the faction. Typically used to initialize character-specific data or inventory.

        Parameters:
            client (Player) – The client that owns the character.
            character (Character) – The character that has been created.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Adds a fancy suit to the character's inventory when created.
            function FACTION:OnCharCreated(client, character)
                local inventory = character:getInv()
                inventory:add("fancy_suit")
            end
]]
--[[
        OnSpawn(client)

        Description:
            Executes actions when a faction member spawns in the game world. Useful for setting up player-specific settings or notifications.

        Parameters:
            client (Player) – The player that has just spawned.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Notify the player in chat after spawning.
            function FACTION:OnSpawn(client)
                client:ChatPrint("You have spawned!")
            end
]]
--[[
        OnTransferred(client)

        Description:
            Executes after a player is moved into this faction.

        Parameters:
            client (Player) – The player that was transferred.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Randomize the player's model when switching to this faction.
            function FACTION:OnTransferred(client)
                local randomModelIndex = math.random(1, #self.models)
                client:getChar():setModel(self.models[randomModelIndex])
            end
]]
