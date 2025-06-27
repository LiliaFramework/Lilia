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
            -- Generate a callsign with a prefix and random digits.
            function FACTION:GetDefaultName(client)
                local digits = string.format("%06d", math.random(0, 999999))
                return "CT-" .. digits
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
            -- Provide a default description referencing the player's Steam name.
            function FACTION:GetDefaultDesc(client)
                return "Officer " .. client:SteamName() .. " serving the city."
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
            -- Give the character a uniform and pistol and record the join time.
            function FACTION:OnCharCreated(client, character)
                local inv = character:getInv()
                inv:add("police_uniform")
                inv:add("pistol")
                character:setData("joinedOn", os.time())
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
            -- Send a radio check and give the player a baton if missing.
            function FACTION:OnSpawn(client)
                client:ChatPrint("All units check in!")
                if not client:HasWeapon("weapon_stunstick") then
                    client:Give("weapon_stunstick")
                end
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
            -- Randomize the player's model and log the switch server-side.
            function FACTION:OnTransferred(client)
                if self.models and #self.models > 0 then
                    local model = self.models[math.random(#self.models)]
                    client:getChar():setModel(model)
                end
                lia.log.add(client, "faction_switch", self.name)
            end
]]
