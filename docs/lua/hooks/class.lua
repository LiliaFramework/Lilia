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
            -- Only allow players with the "Z" flag and at least 10 kills to join
            -- unless they are staff members.
            function CLASS:OnCanBe(client)
                if client:isStaff() then return true end

                local char = client:getChar()
                return char and char:hasFlags("Z") and char:getData("kills", 0) >= 10
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
            -- Reset the player's model and movement speed after leaving
            -- this class to clear any custom bonuses.
            function CLASS:OnLeave(client)
                local character = client:getChar()
                character:setModel("models/player/alyx.mdl")
                client.liaClassSpeed = nil
                client:SetRunSpeed(200)
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
            -- Give the player class-specific equipment and adjust run speed
            -- when they join this class.
            function CLASS:OnSet(client)
                client:setModel("models/police.mdl")
                client:Give("weapon_stunstick")
                client.liaClassSpeed = 250
                client:SetRunSpeed(client.liaClassSpeed)
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
            -- Spawn the player with bonus health and ensure they start with
            -- an SMG every time they spawn while in this class.
            function CLASS:OnSpawn(client)
                client:SetMaxHealth(500)
                client:SetHealth(500)
                if not client:HasWeapon("weapon_smg1") then
                    client:Give("weapon_smg1")
                end
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
            -- Announce the class change and record it in the server log.
            function CLASS:OnTransferred(client, oldClass)
                print(client:Name(), "switched from class", oldClass, "to", self.index)
                lia.log.write("class_transfer", client:Name() .. " -> " .. self.name)
            end
]]
