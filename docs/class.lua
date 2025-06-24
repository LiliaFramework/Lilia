--[[
    This file documents CLASS functions defined within the codebase.

    Generated automatically.
]]

--[[
        OnCanBe(client)

        Description:
            Determines whether a player is allowed to switch to the class. This is evaluated before the class change occurs.

        Parameters:
            client (Player) – The player attempting to switch to the class.

        Returns:
            bool – true if the player is permitted to switch to the class, false otherwise.

        Example Usage:
            function CLASS:OnCanBe(client)
                return client:isStaff() or client:getChar():hasFlags("Z")
            end
]]
--[[
        OnLeave(client)

        Description:
            Triggered when a player leaves the class. Useful for resetting models or other class-specific attributes.

        Parameters:
            client (Player) – The player who has left the class.

        Realm:
            Server
        Example Usage:
            function CLASS:OnLeave(client)
                local character = client:getChar()
                character:setModel("models/player/alyx.mdl")
            end
]]
--[[
        OnSet(client)

        Description:
            Called when a player successfully joins the class. Initialize class-specific settings here.

        Parameters:
            client (Player) – The player who has joined the class.

        Realm:
            Server
        Example Usage:
            function CLASS:OnSet(client)
                client:setModel("models/police.mdl")
            end
]]
--[[
        OnSpawn(client)

        Description:
            Invoked when a class member spawns. Use this for spawn-specific setup like health or weapons.

        Parameters:
            client (Player) – The player who has just spawned.

        Realm:
            Server
        Example Usage:
            function CLASS:OnSpawn(client)
                client:SetMaxHealth(500)
                client:SetHealth(500)
            end
]]
--[[
        OnTransferred(character)

        Description:
            Executes actions when a character is transferred to the class.

        Parameters:
            character (Character) – The character that was transferred.

        Realm:
            Server
        Example Usage:
            function CLASS:OnTransferred(character)
                local randomModelIndex = math.random(1, #self.models)
                character:setModel(self.models[randomModelIndex])
            end
]]
