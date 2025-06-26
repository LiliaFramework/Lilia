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
        Example Usage:
            function FACTION:GetDefaultName(client)
                return "CT-" .. math.random(111111, 999999)
            end
]]
--[[
        GetDefaultDesc(client, faction)

        Description:
            Retrieves the default description for a character upon initial creation within the faction.

        Parameters:
            client (Player) – The client for whom the default description is being retrieved.
            faction (Number) – The faction ID for which the default description is being retrieved.

        Realm:
            Shared
        Example Usage:
            function FACTION:GetDefaultDesc(client, faction)
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
        Example Usage:
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
        Example Usage:
            function FACTION:OnSpawn(client)
                client:ChatPrint("You have spawned!")
            end
]]
--[[
        OnTransferred(character)

        Description:
            Executes actions when a character is transferred to the faction.

        Parameters:
            character (Character) – The character that was transferred.

        Realm:
            Server
        Example Usage:
            function FACTION:OnTransferred(character)
                local randomModelIndex = math.random(1, #self.models)
                character:setModel(self.models[randomModelIndex])
            end
]]
