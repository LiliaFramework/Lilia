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

        Realm:
            Server

        Returns:
            boolean – true if the player is permitted to switch to the class, false otherwise.

        Example Usage:
            -- Only allow staff members or players with the "Z" flag to use this class.
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

        Returns:
            None

        Example Usage:
            -- Reset the player's model to Alyx when leaving this class.
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

        Returns:
            None

        Example Usage:
            -- Set the player's model to the police model upon joining this class.
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

        Returns:
            None

        Example Usage:
            -- Spawn the player with increased health when they join this class.
            function CLASS:OnSpawn(client)
                client:SetMaxHealth(500)
                client:SetHealth(500)
            end
]]
--[[
        OnTransferred(client, oldClass)

        Description:
            Executes after a player joins this class from another.
            Use this to react to class changes.

        Parameters:
            client (Player) – The player that joined this class.
            oldClass (number) – Index of the previous class.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Output the player's name and previous class after switching.
            function CLASS:OnTransferred(client, oldClass)
                print(client:Name(), "switched from class", oldClass)
            end
]]
