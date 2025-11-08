--[[
    Server-Side Hooks

    Server-side hook system for the Lilia framework.
    These hooks run on the server and are used for server-side logic, data management, and game state handling.
]]
--[[
    Overview:
        Server-side hooks in the Lilia framework handle server-side logic, data persistence, permissions, character management, and other server-specific functionality. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
]]
--[[
    Purpose:
        Handles adding warnings to characters.

    When Called:
        When a warning is issued to a character.

    Parameters:
        charID (number)
            The character ID being warned.
        warned (Player)
            The player being warned.
        warnedSteamID (string)
            The SteamID of the warned player.
        timestamp (number)
            The timestamp of the warning.
        message (string)
            The warning message.
        warner (Player)
            The admin issuing the warning.
        warnerSteamID (string)
            The SteamID of the warning admin.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic warning storage
        function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
            print("Warning issued to " .. warned .. " by " .. warner .. ": " .. message)
            -- Default database insertion would happen here
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Log warning and notify admins
        function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
            -- Log the warning
            lia.log.add(warner .. " warned " .. warned .. " (SteamID: " .. warnedSteamID .. ") for: " .. message, FLAG_WARNING)

            -- Store in database (default behavior)
            lia.db.insertTable({
                charID = charID,
                warned = warned,
                warnedSteamID = warnedSteamID,
                timestamp = timestamp,
                message = message,
                warner = warner,
                warnerSteamID = warnerSteamID
            }, nil, "warnings")

            -- Notify online admins
            for _, admin in player.Iterator() do
                if admin:hasPrivilege("Staff Permissions") then
                    admin:notify(warner .. " issued a warning to " .. warned)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced warning system with automatic actions
        function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
            -- Store warning in database
            lia.db.insertTable({
                charID = charID,
                warned = warned,
                warnedSteamID = warnedSteamID,
                timestamp = timestamp,
                message = message,
                warner = warner,
                warnerSteamID = warnerSteamID
            }, nil, "warnings")

            -- Get warning count for this character
            self:GetWarnings(charID):next(function(warnings)
                local warningCount = #warnings

                -- Log with severity
                local severity = warningCount >= 5 and "CRITICAL" or warningCount >= 3 and "HIGH" or "NORMAL"
                lia.log.add("[" .. severity .. "] " .. warner .. " warned " .. warned .. " (" .. warningCount .. " total warnings): " .. message, FLAG_WARNING)

                -- Check for automatic actions based on warning count
                if warningCount >= 5 then
                    -- Find the player and kick them
                    for _, ply in player.Iterator() do
                        if ply:SteamID() == warnedSteamID then
                            ply:Kick("Accumulated too many warnings - please review server rules")
                            lia.log.add("Auto-kicked " .. warned .. " for reaching 5 warnings", FLAG_WARNING)
                            break
                        end
                    end
                elseif warningCount >= 3 then
                    -- Send warning notification to player
                    for _, ply in player.Iterator() do
                        if ply:SteamID() == warnedSteamID then
                            ply:notify("You have received " .. warningCount .. " warnings. Further violations may result in a kick or ban.")
                            break
                        end
                    end
                end

                -- Discord webhook notification for high-severity warnings
                if warningCount >= 3 then
                    local embed = {
                        title = "Player Warning Issued",
                        description = string.format("**Admin:** %s\n**Player:** %s\n**Reason:** %s\n**Total Warnings:** %d", warner, warned, message, warningCount),
                        color = warningCount >= 5 and 0xFF0000 or 0xFFA500,
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", timestamp)
                    }
                    hook.Run("DiscordRelaySend", embed)
                end
            end)
        end
        ```
]]
function AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
end

--[[
    Purpose:
        Determines if a character can be transferred between factions.

    When Called:
        When attempting to transfer a character to a different faction.

    Parameters:
        character (Character)
            The character being transferred.
        faction (Faction)
            The target faction.
        currentValue (boolean)
            The current transfer permission.

    Returns:
        boolean
            Whether the character can be transferred.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow character transfers
        function MODULE:CanCharBeTransfered(character, faction, currentValue)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check basic faction restrictions
        function MODULE:CanCharBeTransfered(character, faction, currentValue)
            -- Don't allow transfer if character has restricted flags
            if character:hasFlags("P") then -- Permanent character flag
                return false, "This character cannot be transferred."
            end

            -- Check if faction allows transfers
            local factionData = lia.faction.get(faction)
            if factionData and factionData.noTransfer then
                return false, "This faction does not allow character transfers."
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer validation with history and restrictions
        function MODULE:CanCharBeTransfered(character, faction, currentValue)
            local client = character:getPlayer()

            -- Check transfer cooldown
            local lastTransfer = character:getData("lastFactionTransfer", 0)
            local cooldown = 24 * 60 * 60 -- 24 hours
            if os.time() - lastTransfer < cooldown then
                local remaining = math.ceil((cooldown - (os.time() - lastTransfer)) / 3600)
                return false, "You must wait " .. remaining .. " hours before transferring again."
            end

            -- Check transfer history
            local transferHistory = character:getData("transferHistory", {})
            local maxTransfers = 3
            if #transferHistory >= maxTransfers then
                return false, "This character has reached the maximum number of transfers."
            end

            -- Check faction requirements
            local factionData = lia.faction.get(faction)
            if factionData then
                -- Check level requirements
                if factionData.minLevel and character:getAttrib("level", 0) < factionData.minLevel then
                    return false, "Your character does not meet the level requirements for this faction."
                end

                -- Check reputation requirements
                if factionData.minReputation and character:getData("reputation", 0) < factionData.minReputation then
                    return false, "Your character does not have enough reputation for this faction."
                end

                -- Check whitelist restrictions
                if factionData.whitelistOnly and not character:getData("whitelisted_" .. faction, false) then
                    return false, "Your character is not whitelisted for this faction."
                end
            end

            -- Check for ongoing quests or missions that would prevent transfer
            if character:getData("activeQuest", false) then
                return false, "You cannot transfer while on an active quest."
            end

            return true
        end
        ```
]]
function CanCharBeTransfered(character, faction, currentValue)
end

--[[
    Purpose:
        Determines if a character can be deleted.

    When Called:
        When attempting to delete a character.

    Parameters:
        client (Player)
            The player attempting deletion.
        character (Character)
            The character being deleted.

    Returns:
        boolean
            Whether the character can be deleted.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow character deletion
        function MODULE:CanDeleteChar(client, character)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check basic restrictions
        function MODULE:CanDeleteChar(client, character)
            -- Don't allow deletion of characters with admin flags
            if character:hasFlags("a") then
                return false, "Admin characters cannot be deleted."
            end

            -- Don't allow deletion of characters that are currently selected
            if client:getChar() == character then
                return false, "You cannot delete your currently selected character."
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced deletion validation with protections and logging
        function MODULE:CanDeleteChar(client, character)
            -- Check user permissions
            if not client:hasPrivilege("Delete Characters") and character:getPlayer() ~= client then
                return false, "You don't have permission to delete this character."
            end

            -- Check character age protection
            local created = character:getData("created", os.time())
            local minAge = 7 * 24 * 60 * 60 -- 7 days
            if os.time() - created < minAge then
                local remaining = math.ceil((minAge - (os.time() - created)) / 86400)
                return false, "This character is too new. You must wait " .. remaining .. " more days."
            end

            -- Check if character has valuable items
            local inventory = character:getInv()
            if inventory then
                local valuableItems = 0
                for _, item in pairs(inventory:getItems()) do
                    if item:getData("valuable", false) then
                        valuableItems = valuableItems + 1
                    end
                end
                if valuableItems > 0 then
                    return false, "This character has valuable items that must be removed first."
                end
            end

            -- Check if character is involved in active quests or missions
            if character:getData("activeQuest", false) then
                return false, "This character is involved in an active quest and cannot be deleted."
            end

            -- Check character level/rank restrictions
            local level = character:getAttrib("level", 1)
            if level >= 10 then
                -- High-level characters require admin approval
                if not client:hasPrivilege("Delete High Level Characters") then
                    return false, "High-level characters require admin approval for deletion."
                end
            end

            -- Log the deletion attempt
            lia.log.add(client:Name() .. " (" .. client:SteamID() .. ") attempted to delete character: " .. character:getName(), FLAG_WARNING)

            return true
        end
        ```
]]
function CanDeleteChar(client, character)
end

--[[
    Purpose:
        Determines if a player can invite others to a class.

    When Called:
        When attempting to invite a player to a class.

    Parameters:
        client (Player)
            The player sending the invitation.
        target (Player)
            The player being invited.

    Returns:
        boolean
            Whether the invitation can be sent.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow class invitations
        function MODULE:CanInviteToClass(client, target)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if inviter has permission and target meets basic requirements
        function MODULE:CanInviteToClass(client, target)
            local character = client:getChar()

            -- Only allow players with certain flags to invite
            if not character:hasFlags("C") then -- Class invitation permission flag
                return false
            end

            -- Check if target is already in a class
            if target:getChar():getClass() then
                return false
            end

            -- Check if target is in the same faction
            if character:getFaction() ~= target:getChar():getFaction() then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced invitation system with limits, cooldowns, and hierarchy checks
        function MODULE:CanInviteToClass(client, target)
            local character = client:getChar()
            local targetChar = target:getChar()

            -- Check permission flags
            if not character:hasFlags("C") then
                return false, "You don't have permission to invite players to classes."
            end

            -- Check if target already has a class
            if targetChar:getClass() then
                return false, "Target player is already in a class."
            end

            -- Check faction compatibility
            if character:getFaction() ~= targetChar:getFaction() then
                return false, "Target player must be in the same faction."
            end

            -- Check invitation limits
            local currentTime = os.time()
            local invitationData = character:getData("classInvitations", {})
            local dailyLimit = 5
            local cooldownTime = 60 * 60 * 24 -- 24 hours

            -- Clean up old invitations
            for steamID, timestamp in pairs(invitationData) do
                if currentTime - timestamp > cooldownTime then
                    invitationData[steamID] = nil
                end
            end

            -- Count active invitations
            local activeInvitations = table.Count(invitationData)
            if activeInvitations >= dailyLimit then
                return false, "You have reached your daily invitation limit."
            end

            -- Check class hierarchy (can't invite to higher tier classes)
            local inviterClass = lia.class.list[character:getClass()]
            local targetClass = lia.class.list[targetChar:getClass()]

            if inviterClass and targetClass then
                if inviterClass.tier and targetClass.tier then
                    if targetClass.tier > inviterClass.tier + 1 then
                        return false, "You cannot invite players to classes above your authority level."
                    end
                end
            end

            -- Check reputation requirements
            local requiredReputation = 50
            if character:getReputation() < requiredReputation then
                return false, "You need at least " .. requiredReputation .. " reputation to invite players."
            end

            -- Check if target has been recently invited (cooldown)
            local targetSteamID = target:SteamID()
            if invitationData[targetSteamID] then
                local timeSinceLastInvite = currentTime - invitationData[targetSteamID]
                if timeSinceLastInvite < (60 * 60) then -- 1 hour cooldown per target
                    return false, "You recently invited this player. Please wait before inviting again."
                end
            end

            return true
        end
        ```
]]
function CanInviteToClass(client, target)
end

--[[
    Purpose:
        Determines if a player can invite others to a faction.

    When Called:
        When attempting to invite a player to a faction.

    Parameters:
        client (Player)
            The player sending the invitation.
        target (Player)
            The player being invited.

    Returns:
        boolean
            Whether the invitation can be sent.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow faction invitations
        function MODULE:CanInviteToFaction(client, target)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if inviter has leadership permissions and target meets basic requirements
        function MODULE:CanInviteToFaction(client, target)
            local character = client:getChar()

            -- Only allow faction leaders to invite
            if not character:isFactionLeader() then
                return false
            end

            -- Check if target is already in a faction
            if target:getChar():getFaction() then
                return false
            end

            -- Check if target meets faction requirements (e.g., level, reputation)
            local targetChar = target:getChar()
            local minLevel = 5
            local minReputation = 25

            if targetChar:getLevel() < minLevel then
                return false
            end

            if targetChar:getReputation() < minReputation then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced invitation system with whitelist, blacklist, and faction politics
        function MODULE:CanInviteToFaction(client, target)
            local character = client:getChar()
            local targetChar = target:getChar()
            local factionID = character:getFaction()
            local faction = lia.faction.list[factionID]

            -- Check if inviter has invitation permissions
            if not character:hasFlags("F") and not character:isFactionLeader() then
                return false, "You don't have permission to invite players to factions."
            end

            -- Check if target is already in a faction
            if targetChar:getFaction() then
                return false, "Target player is already in a faction."
            end

            -- Check faction requirements
            local requirements = faction.requirements or {}
            if requirements.level and targetChar:getLevel() < requirements.level then
                return false, "Target player doesn't meet the level requirement."
            end

            if requirements.reputation and targetChar:getReputation() < requirements.reputation then
                return false, "Target player doesn't meet the reputation requirement."
            end

            -- Check whitelist/blacklist system
            local whitelist = faction:getData("invitationWhitelist", {})
            local blacklist = faction:getData("invitationBlacklist", {})

            local targetSteamID = target:SteamID()

            -- If whitelist exists, target must be on it
            if table.Count(whitelist) > 0 and not whitelist[targetSteamID] then
                return false, "Target player is not on the faction invitation whitelist."
            end

            -- Check if target is blacklisted
            if blacklist[targetSteamID] then
                local banExpiry = blacklist[targetSteamID]
                if banExpiry == 0 or os.time() < banExpiry then
                    return false, "Target player is banned from joining this faction."
                else
                    -- Ban has expired, remove from blacklist
                    blacklist[targetSteamID] = nil
                    faction:setData("invitationBlacklist", blacklist)
                end
            end

            -- Check faction politics (alliances, rivalries)
            local targetFaction = targetChar:getFaction()
            if targetFaction then
                local politics = faction:getData("factionPolitics", {})

                -- Check if target faction is an enemy
                if politics[targetFaction] == "enemy" then
                    return false, "Cannot invite players from enemy factions."
                end

                -- Check if target faction has a treaty
                if politics[targetFaction] == "treaty" then
                    -- Allow but with restrictions
                    local treatyRestrictions = faction:getData("treatyRestrictions", {})
                    if treatyRestrictions.invitationCooldown then
                        local lastInvite = character:getData("lastTreatyInvite", 0)
                        if os.time() - lastInvite < treatyRestrictions.invitationCooldown then
                            return false, "Treaty restrictions prevent inviting from allied factions too frequently."
                        end
                    end
                end
            end

            -- Check invitation limits and cooldowns
            local invitationData = character:getData("factionInvitations", {})
            local currentTime = os.time()
            local dailyLimit = faction.invitationLimit or 3
            local cooldownTime = 60 * 60 * 24 -- 24 hours

            -- Clean up old invitations
            for steamID, timestamp in pairs(invitationData) do
                if currentTime - timestamp > cooldownTime then
                    invitationData[steamID] = nil
                end
            end

            -- Count active invitations
            local activeInvitations = table.Count(invitationData)
            if activeInvitations >= dailyLimit then
                return false, "You have reached your daily invitation limit for this faction."
            end

            -- Check if target has been recently invited
            if invitationData[targetSteamID] then
                local timeSinceLastInvite = currentTime - invitationData[targetSteamID]
                if timeSinceLastInvite < (60 * 60 * 2) then -- 2 hour cooldown per target
                    return false, "You recently invited this player. Please wait before inviting again."
                end
            end

            -- Check faction stability (can't invite during crises)
            local factionStability = faction:getData("stability", 100)
            if factionStability < 50 then
                return false, "Faction is currently unstable and cannot accept new members."
            end

            return true
        end
        ```
]]
function CanInviteToFaction(client, target)
end

--[[
    Purpose:
        Determines if an item can be transferred between inventories.

    When Called:
        When attempting to transfer an item.

    Parameters:
        item (Item)
            The item being transferred.
        oldInventory (Inventory)
            The source inventory.
        newInventory (Inventory)
            The destination inventory.
        client (Player)
            The player performing the transfer.

    Returns:
        boolean
            Whether the item can be transferred.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic transfer check
        function MODULE:CanItemBeTransfered(item, oldInventory, newInventory, client)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            return char ~= nil -- Allow transfer if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Item type restrictions
        function MODULE:CanItemBeTransfered(item, oldInventory, newInventory, client)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if item is soulbound
            if item:getData("soulbound", false) then
                client:notify("This item is soulbound and cannot be transferred!")
                return false
            end

            -- Check if item requires certain flags
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                client:notify("You don't have permission to transfer this item!")
                return false
            end

            -- Check inventory ownership
            if oldInventory:getID() ~= char:getID() then
                -- Transferring from someone else's inventory
                if not client:hasPrivilege("Staff Permissions") then
                    return false
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer system with multiple validations
        function MODULE:CanItemBeTransfered(item, oldInventory, newInventory, client)
            if not IsValid(client) or not item or not oldInventory or not newInventory then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                client:notify("You cannot transfer items while dead!")
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) and item.uniqueID == "weapon" then
                client:notify("Wanted criminals cannot transfer weapons!")
                return false
            end

            -- Check item soulbinding
            if item:getData("soulbound", false) then
                client:notify("This item is soulbound to you and cannot be transferred!")
                return false
            end

            -- Check item level requirements
            if item.levelRequired then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < item.levelRequired then
                    client:notify("You are not high enough level to transfer this item!")
                    return false
                end
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                client:notify("This item belongs to a different faction!")
                return false
            end

            -- Check class restrictions
            local itemClass = item:getData("class")
            if itemClass and itemClass ~= char:getClass() then
                client:notify("This item is restricted to a different class!")
                return false
            end

            -- Check flag requirements
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                client:notify("You don't have the required permissions for this item!")
                return false
            end

            -- Check inventory ownership and permissions
            local oldOwner = oldInventory:getOwner()
            if oldOwner and oldOwner ~= char then
                -- Transferring from someone else's inventory
                if not client:hasPrivilege("Staff Permissions") then
                    -- Check if it's a trade scenario
                    if newInventory:getOwner() ~= char then
                        client:notify("You can only transfer items from your own inventory!")
                        return false
                    end
                end
            end

            -- Check new inventory space and restrictions
            local newOwner = newInventory:getOwner()
            if newOwner and newOwner ~= char then
                -- Check if target inventory accepts this item type
                if newInventory.itemRestriction and not table.HasValue(newInventory.itemRestriction, item.uniqueID) then
                    client:notify("The target inventory doesn't accept this type of item!")
                    return false
                end

                -- Check if target inventory has space
                if not newInventory:canAdd(item) then
                    client:notify("The target inventory is full!")
                    return false
                end
            end

            -- Check item transfer cooldown
            local lastTransfer = item:getData("lastTransfer", 0)
            local cooldown = lia.config.get("itemTransferCooldown", 0)
            if cooldown > 0 and (CurTime() - lastTransfer) < cooldown then
                client:notify("This item is on transfer cooldown!")
                return false
            end

            -- Check distance restrictions for player-to-player transfers
            if oldOwner and newOwner and oldOwner ~= newOwner then
                local oldPlayer = oldOwner.player
                local newPlayer = newOwner.player

                if IsValid(oldPlayer) and IsValid(newPlayer) then
                    local maxDistance = lia.config.get("maxTransferDistance", 200)
                    if oldPlayer:GetPos():Distance(newPlayer:GetPos()) > maxDistance then
                        client:notify("Players are too far apart for item transfer!")
                        return false
                    end
                end
            end

            -- Update transfer timestamp
            item:setData("lastTransfer", CurTime())

            -- Log item transfer
            lia.log.add(client:Name() .. " transferred " .. item.name ..
                " from inventory " .. oldInventory:getID() ..
                " to inventory " .. newInventory:getID(), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanItemBeTransfered(item, oldInventory, newInventory, client)
end

--[[
    Purpose:
        Determines if a player can change their outfit model.

    When Called:
        When attempting to change outfit appearance.

    Parameters:
        outfitItem (Item)
            The outfit item.

    Returns:
        boolean
            Whether the model can be changed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic outfit model change check
        function MODULE:CanOutfitChangeModel(outfitItem)
            if not outfitItem then return false end

            local client = outfitItem:getOwner()
            if not IsValid(client) then return false end

            local char = client:getChar()
            return char ~= nil -- Allow change if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Outfit restrictions based on faction/class
        function MODULE:CanOutfitChangeModel(outfitItem)
            if not outfitItem then return false end

            local client = outfitItem:getOwner()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check faction restrictions
            local outfitFaction = outfitItem:getData("faction")
            if outfitFaction and outfitFaction ~= char:getFaction() then
                return false
            end

            -- Check class restrictions
            local outfitClass = outfitItem:getData("class")
            if outfitClass and outfitClass ~= char:getClass() then
                return false
            end

            -- Check flag requirements
            local requiredFlags = outfitItem:getData("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) do
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced outfit system with multiple validations
        function MODULE:CanOutfitChangeModel(outfitItem)
            if not outfitItem then return false end

            local client = outfitItem:getOwner()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                client:notify("You cannot change outfits while dead!")
                return false
            end

            -- Check outfit ownership
            if outfitItem:getOwner() ~= client then
                return false -- Can't change someone else's outfit
            end

            -- Check if outfit is equipped
            if not outfitItem:getData("equip", false) then
                client:notify("You must equip the outfit first!")
                return false
            end

            -- Check faction restrictions
            local outfitFaction = outfitItem:getData("faction")
            if outfitFaction and outfitFaction ~= char:getFaction() then
                client:notify("This outfit is restricted to a different faction!")
                return false
            end

            -- Check class restrictions
            local outfitClass = outfitItem:getData("class")
            if outfitClass and outfitClass ~= char:getClass() then
                client:notify("This outfit is restricted to a different class!")
                return false
            end

            -- Check flag requirements
            local requiredFlags = outfitItem:getData("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) do
                    if not char:hasFlags(flag) then
                        client:notify("You don't have the required permissions for this outfit!")
                        return false
                    end
                end
            end

            -- Check level requirements
            local levelReq = outfitItem:getData("levelRequired", 0)
            if levelReq > 0 then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < levelReq then
                    client:notify("You are not high enough level for this outfit!")
                    return false
                end
            end

            -- Check reputation requirements
            local repReq = outfitItem:getData("reputationRequired", 0)
            if repReq > 0 then
                local playerRep = char:getData("reputation", 0)
                if playerRep < repReq then
                    client:notify("You don't have enough reputation for this outfit!")
                    return false
                end
            end

            -- Check wanted status
            if char:getData("wanted", false) and outfitItem:getData("noWanted", false) then
                client:notify("Wanted criminals cannot use this outfit!")
                return false
            end

            -- Check outfit durability
            local durability = outfitItem:getData("durability", 100)
            if durability <= 0 then
                client:notify("This outfit is too damaged to use!")
                return false
            end

            -- Check cooldown between outfit changes
            local lastChange = outfitItem:getData("lastModelChange", 0)
            local cooldown = outfitItem:getData("changeCooldown", 0)
            if cooldown > 0 and (CurTime() - lastChange) < cooldown then
                client:notify("You must wait before changing this outfit again!")
                return false
            end

            -- Check if outfit allows model changes
            if not outfitItem:getData("allowModelChange", true) then
                client:notify("This outfit doesn't allow model changes!")
                return false
            end

            -- Check gender restrictions
            local outfitGender = outfitItem:getData("gender")
            local playerGender = char:getData("gender", "male")
            if outfitGender and outfitGender ~= playerGender then
                client:notify("This outfit is restricted by gender!")
                return false
            end

            -- Check seasonal restrictions
            local currentDate = os.date("*t")
            local seasonal = outfitItem:getData("seasonal")
            if seasonal and seasonal ~= currentDate.month then
                client:notify("This outfit is not available during this season!")
                return false
            end

            -- Update cooldown timestamp
            outfitItem:setData("lastModelChange", CurTime())

            -- Log outfit change
            lia.log.add(client:Name() .. " changed outfit model: " .. outfitItem.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanOutfitChangeModel(outfitItem)
end

--[[
    Purpose:
        Determines if a player can edit vendor settings.

    When Called:
        When attempting to edit a vendor.

    Parameters:
        client (Player)
            The player attempting to edit.
        vendor (Entity)
            The vendor entity.

    Returns:
        boolean
            Whether the vendor can be edited.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic vendor edit check
        function MODULE:CanPerformVendorEdit(client, vendor)
            if not IsValid(client) or not IsValid(vendor) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Allow if player owns the vendor
            return vendor:getNetVar("owner") == client
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Faction-based vendor editing permissions
        function MODULE:CanPerformVendorEdit(client, vendor)
            if not IsValid(client) or not IsValid(vendor) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership
            if vendor:getNetVar("owner") == client then
                return true
            end

            -- Check faction permissions
            local vendorFaction = vendor:getNetVar("faction")
            if vendorFaction and char:getFaction() == vendorFaction then
                -- Check if player has management permissions in faction
                return char:hasFlags("m") -- Management flag
            end

            -- Check admin permissions
            return client:hasPrivilege("Manage Vendors")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced vendor editing with multiple permission levels
        function MODULE:CanPerformVendorEdit(client, vendor)
            if not IsValid(client) or not IsValid(vendor) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check admin permissions first (admins can edit everything)
            if client:hasPrivilege("Manage Vendors") then
                return true
            end

            -- Check vendor ownership
            local vendorOwner = vendor:getNetVar("owner")
            if vendorOwner == client then
                return true -- Owner can always edit their vendor
            end

            -- Check faction permissions
            local vendorFaction = vendor:getNetVar("faction")
            if vendorFaction then
                if char:getFaction() == vendorFaction then
                    -- Check faction rank/permissions
                    local factionRank = char:getData("factionRank", 0)
                    local requiredRank = vendor:getNetVar("editRankRequired", 3)
                    if factionRank >= requiredRank then
                        return true
                    end

                    -- Check specific faction flags
                    if char:hasFlags("V") then -- Vendor management flag
                        return true
                    end
                end

                -- Check allied faction permissions
                local playerFaction = lia.faction.get(char:getFaction())
                if playerFaction and playerFaction.allies then
                    for _, allyFaction in ipairs(playerFaction.allies) do
                        if allyFaction == vendorFaction then
                            -- Allied factions have limited editing permissions
                            local editType = vendor:getNetVar("allyEditPermissions", "none")
                            if editType == "full" then
                                return true
                            elseif editType == "limited" then
                                -- Only allow certain edits (would need additional context)
                                return true
                            end
                        end
                    end
                end
            end

            -- Check class permissions
            local vendorClass = vendor:getNetVar("classRestriction")
            if vendorClass and char:getClass() == vendorClass then
                -- Class leaders can edit class vendors
                if char:hasFlags("C") then -- Class leader flag
                    return true
                end
            end

            -- Check reputation-based permissions
            local minRep = vendor:getNetVar("editReputationRequired", 0)
            if minRep > 0 then
                local playerRep = char:getData("reputation", 0)
                if playerRep >= minRep then
                    return true
                end
            end

            -- Check time restrictions for editing
            local editHours = vendor:getNetVar("editHours")
            if editHours then
                local currentTime = os.date("*t")
                local currentHour = currentTime.hour
                if currentHour < editHours.start or currentHour > editHours.end then
                    client:notify("This vendor can only be edited during business hours!")
                    return false
                end
            end

            -- Check vendor status
            if vendor:getNetVar("locked", false) then
                client:notify("This vendor is locked and cannot be edited!")
                return false
            end

            -- Check distance restrictions
            local maxEditDistance = vendor:getNetVar("maxEditDistance", 200)
            if client:GetPos():Distance(vendor:GetPos()) > maxEditDistance then
                client:notify("You are too far away to edit this vendor!")
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                client:notify("Wanted criminals cannot edit vendors!")
                return false
            end

            -- Check cooldown between edits
            local lastEdit = vendor:getNetVar("lastEdit", 0)
            local editCooldown = vendor:getNetVar("editCooldown", 0)
            if editCooldown > 0 and (CurTime() - lastEdit) < editCooldown then
                client:notify("Please wait before editing this vendor again!")
                return false
            end

            -- Log vendor edit attempt
            lia.log.add(client:Name() .. " attempted to edit vendor: " ..
                (vendor:getNetVar("name") or "Unknown"), FLAG_NORMAL)

            return false -- Deny by default if no permissions match
        end
        ```
]]
function CanPerformVendorEdit(client, vendor)
end

--[[
    Purpose:
        Determines if an entity can be persisted in the database.

    When Called:
        When attempting to save entity data.

    Parameters:
        entity (Entity)
            The entity to persist.
        inventory (Inventory)
            The entity's inventory.

    Returns:
        boolean
            Whether the entity can be persisted.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic entity persistence check
        function MODULE:CanPersistEntity(entity, inventory)
            if not IsValid(entity) then return false end

            -- Only persist certain entity types
            local allowedClasses = {
                "lia_vendor",
                "lia_container",
                "lia_storage"
            }

            return table.HasValue(allowedClasses, entity:GetClass())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Persistence based on entity ownership
        function MODULE:CanPersistEntity(entity, inventory)
            if not IsValid(entity) then return false end

            -- Check entity ownership
            local owner = entity:getNetVar("owner")
            if not IsValid(owner) then
                return false -- Don't persist unowned entities
            end

            -- Check if owner has persistence permissions
            local char = owner:getChar()
            if not char then return false end

            -- Check persistence limit
            local maxPersistent = char:getData("maxPersistentEntities", 5)
            local currentPersistent = char:getData("persistentEntityCount", 0)

            if currentPersistent >= maxPersistent then
                return false -- Owner has reached persistence limit
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced persistence system with multiple conditions
        function MODULE:CanPersistEntity(entity, inventory)
            if not IsValid(entity) then return false end

            -- Check entity type restrictions
            local entityClass = entity:GetClass()
            local allowedClasses = lia.config.get("persistentEntityClasses", {
                "lia_vendor",
                "lia_container",
                "lia_storage",
                "lia_door"
            })

            if not table.HasValue(allowedClasses, entityClass) then
                return false
            end

            -- Check entity ownership
            local owner = entity:getNetVar("owner")
            if not IsValid(owner) then
                -- Allow persistence of certain public entities
                if entity:getNetVar("public", false) then
                    return true
                end
                return false
            end

            local char = owner:getChar()
            if not char then return false end

            -- Check ownership permissions
            if entityClass == "lia_vendor" then
                -- Special checks for vendors
                if not char:hasFlags("V") and owner ~= entity:getNetVar("owner") then
                    return false -- Need vendor flag to persist others' vendors
                end
            end

            -- Check persistence limits
            local maxPersistent = lia.config.get("maxPersistentEntities", {})[char:getUserGroup()] or
                                char:getData("maxPersistentEntities", 5)

            -- Count current persistent entities for this player
            local currentPersistent = 0
            for _, ent in ipairs(ents.GetAll()) do
                if ent:getNetVar("owner") == owner and ent:getNetVar("persistent", false) then
                    currentPersistent = currentPersistent + 1
                end
            end

            if currentPersistent >= maxPersistent then
                return false
            end

            -- Check faction restrictions
            local entityFaction = entity:getNetVar("faction")
            if entityFaction and entityFaction ~= char:getFaction() then
                return false -- Can't persist entities from other factions
            end

            -- Check entity health/durability
            local health = entity:Health()
            local maxHealth = entity:GetMaxHealth()
            if health <= 0 or (maxHealth > 0 and health/maxHealth < 0.1) then
                return false -- Don't persist destroyed entities
            end

            -- Check location restrictions
            local pos = entity:GetPos()
            if lia.config.get("restrictPersistenceZones") then
                -- Check if entity is in a no-persistence zone
                local zones = lia.config.get("noPersistenceZones", {})
                for _, zone in ipairs(zones) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        return false
                    end
                end
            end

            -- Check time-based restrictions
            if entity:getNetVar("tempEntity", false) then
                -- Temporary entities can't be persisted
                return false
            end

            -- Check inventory contents for valuable items
            if inventory then
                local totalValue = 0
                for _, item in pairs(inventory:getItems()) do
                    if item.price then
                        totalValue = totalValue + (item.price * item:getQuantity())
                    end
                end

                local maxInventoryValue = lia.config.get("maxPersistentInventoryValue", 10000)
                if totalValue > maxInventoryValue then
                    return false -- Inventory too valuable to persist
                end
            end

            -- Check server performance (don't persist too many entities)
            local totalPersistent = 0
            for _, ent in ipairs(ents.GetAll()) do
                if ent:getNetVar("persistent", false) then
                    totalPersistent = totalPersistent + 1
                end
            end

            local maxServerPersistent = lia.config.get("maxServerPersistentEntities", 100)
            if totalPersistent >= maxServerPersistent then
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted players can't persist entities
            end

            -- Log persistence
            lia.log.add(owner:Name() .. " persisted entity: " .. entityClass ..
                " at " .. tostring(pos), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPersistEntity(entity, inventory)
end

--[[
    Purpose:
        Determines if a player can access a door.

    When Called:
        When attempting to access a door.

    Parameters:
        client (Player)
            The player attempting access.
        door (Entity)
            The door entity.
        access (string)
            The type of access requested.

    Returns:
        boolean
            Whether the player can access the door.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ownership check
        function MODULE:CanPlayerAccessDoor(client, door, access)
            if door:getNetVar("owner") == client then
                return true -- Owner can always access
            end
            return false
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Faction-based access control
        function MODULE:CanPlayerAccessDoor(client, door, access)
            local char = client:getChar()
            if not char then return false end

            local doorFaction = door:getNetVar("faction")
            if doorFaction then
                -- Check if player's faction matches door's faction
                if char:getFaction() == doorFaction then
                    return true
                end

                -- Check for allied factions
                local playerFaction = lia.faction.get(char:getFaction())
                if playerFaction and playerFaction.allies then
                    for _, allyFaction in ipairs(playerFaction.allies) do
                        if allyFaction == doorFaction then
                            return true
                        end
                    end
                end
            end

            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced access control with multiple permission systems
        function MODULE:CanPlayerAccessDoor(client, door, access)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership first
            if door:getNetVar("owner") == client then
                return true
            end

            -- Check character permissions
            local doorData = door:getNetVar("doorData", {})
            if doorData.allowedChars and table.HasValue(doorData.allowedChars, char:getID()) then
                return true
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction then
                if char:getFaction() == doorFaction then
                    return true
                end

                -- Check allied factions
                local playerFaction = lia.faction.get(char:getFaction())
                if playerFaction and playerFaction.allies then
                    for _, allyFaction in ipairs(playerFaction.allies) do
                        if allyFaction == doorFaction then
                            return true
                        end
                    end
                end
            end

            -- Check class permissions
            local doorClass = door:getNetVar("class")
            if doorClass and char:getClass() == doorClass then
                return true
            end

            -- Check flag permissions
            local requiredFlags = door:getNetVar("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) do
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
                return true -- Has all required flags
            end

            -- Check access level system
            local accessLevel = door:getNetVar("accessLevel", 0)
            local playerLevel = char:getData("accessLevel", 0)
            if playerLevel >= accessLevel then
                return true
            end

            -- Check time-based restrictions
            local timeRestriction = door:getNetVar("timeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false
                end
            end

            -- Check special conditions (events, holidays, etc.)
            if self:IsHolidayPeriod() and door:getNetVar("holidayAccess") then
                return true
            end

            -- Log access attempts for security
            if access == "lockpick" then
                lia.log.add(client:Name() .. " attempted to lockpick door (ID: " .. (door:EntIndex() or "unknown") .. ")", FLAG_WARNING)
            end

            return false
        end
        ```
]]
function CanPlayerAccessDoor(client, door, access)
end

--[[
    Purpose:
        Determines if a player can choose a weapon.

    When Called:
        When attempting to select a weapon.

    Parameters:
        weapon (string)
            The weapon class name.

    Returns:
        boolean
            Whether the weapon can be chosen.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Blacklist specific weapons
        function MODULE:CanPlayerChooseWeapon(weapon)
            local blacklisted = {
                "weapon_rpg",
                "weapon_crossbow"
            }

            return not table.HasValue(blacklisted, weapon)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Class-based weapon restrictions
        function MODULE:CanPlayerChooseWeapon(client, weapon)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            local classID = char:getClass()
            if not classID then return false end

            local class = lia.class.get(classID)
            if not class then return false end

            -- Check if weapon is allowed for this class
            if class.allowedWeapons then
                return table.HasValue(class.allowedWeapons, weapon)
            end

            -- Check if weapon is restricted for this class
            if class.restrictedWeapons then
                return not table.HasValue(class.restrictedWeapons, weapon)
            end

            return true -- Allow by default if no restrictions
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced weapon selection system with multiple restrictions
        function MODULE:CanPlayerChooseWeapon(client, weapon)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check global weapon blacklist
            local globalBlacklist = lia.config.get("weaponBlacklist", {})
            if table.HasValue(globalBlacklist, weapon) then
                return false
            end

            -- Check faction restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction then
                if faction.allowedWeapons and not table.HasValue(faction.allowedWeapons, weapon) then
                    return false
                end

                if faction.restrictedWeapons and table.HasValue(faction.restrictedWeapons, weapon) then
                    return false
                end
            end

            -- Check class restrictions
            local classID = char:getClass()
            if classID then
                local class = lia.class.get(classID)
                if class then
                    if class.allowedWeapons and not table.HasValue(class.allowedWeapons, weapon) then
                        return false
                    end

                    if class.restrictedWeapons and table.HasValue(class.restrictedWeapons, weapon) then
                        return false
                    end

                    -- Check skill requirements
                    if class.weaponSkills then
                        for requiredSkill, minLevel in pairs(class.weaponSkills) do
                            if char:getAttrib(requiredSkill, 0) < minLevel then
                                return false
                            end
                        end
                    end
                end
            end

            -- Check flag requirements
            local weaponFlags = lia.config.get("weaponFlags", {})[weapon]
            if weaponFlags then
                for _, flag in ipairs(weaponFlags) do
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
            end

            -- Check level requirements
            local weaponLevelReq = lia.config.get("weaponLevelRequirements", {})[weapon]
            if weaponLevelReq then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < weaponLevelReq then
                    return false
                end
            end

            -- Check reputation requirements
            local weaponRepReq = lia.config.get("weaponReputationRequirements", {})[weapon]
            if weaponRepReq then
                local playerRep = char:getData("reputation", 0)
                if playerRep < weaponRepReq then
                    return false
                end
            end

            -- Check time-based restrictions (holidays, events)
            local currentDate = os.date("*t")
            if currentDate.month == 12 and currentDate.day <= 25 then
                -- Allow special holiday weapons
                local holidayWeapons = {"weapon_snowball_launcher", "weapon_gift_launcher"}
                if table.HasValue(holidayWeapons, weapon) then
                    return true
                end
            end

            -- Check weapon ownership/permits
            if lia.config.get("requireWeaponPermits") then
                local hasPermit = char:getData("weaponPermits", {})
                if not hasPermit[weapon] then
                    return false
                end
            end

            -- Log weapon selection for monitoring
            lia.log.add(client:Name() .. " selected weapon: " .. weapon, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerChooseWeapon(weapon)
end

--[[
    Purpose:
        Determines if a player can create a character.

    When Called:
        During character creation validation.

    Parameters:
        client (Player)
            The player creating the character.
        data (table)
            The character creation data.

    Returns:
        boolean
            Whether the character can be created.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic character creation check
        function MODULE:CanPlayerCreateChar(client, data)
            if not IsValid(client) then return false end

            -- Check character limit
            local maxChars = lia.config.get("maxCharacters", 5)
            if #client.liaCharList >= maxChars then
                return false
            end

            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Character creation with restrictions
        function MODULE:CanPlayerCreateChar(client, data)
            if not IsValid(client) then return false end

            -- Check character limit
            local maxChars = lia.config.get("maxCharacters", 5)
            if #client.liaCharList >= maxChars then
                client:notify("You have reached the maximum number of characters!")
                return false
            end

            -- Check faction limits
            if data.faction then
                local faction = lia.faction.get(data.faction)
                if faction and faction.limit then
                    local count = 0
                    for _, charID in ipairs(client.liaCharList) do
                        lia.char.getCharacter(client, charID, function(character)
                            if character and character:getFaction() == data.faction then
                                count = count + 1
                            end
                        end)
                    end

                    if count >= faction.limit then
                        client:notify("You have reached the limit for this faction!")
                        return false
                    end
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character creation system
        function MODULE:CanPlayerCreateChar(client, data)
            if not IsValid(client) then return false end

            -- Check if player is banned from character creation
            if client:getNetVar("charCreationBanned", false) then
                client:notify("You are banned from creating characters!")
                return false
            end

            -- Check character limit (with VIP bonuses)
            local baseMaxChars = lia.config.get("maxCharacters", 5)
            local vipBonus = client:hasPrivilege("VIP") and 2 or 0
            local maxChars = baseMaxChars + vipBonus

            if #client.liaCharList >= maxChars then
                client:notify("You have reached the maximum number of characters (" .. maxChars .. ")!")
                return false
            end

            -- Check faction restrictions
            if data.faction then
                local faction = lia.faction.get(data.faction)
                if not faction then
                    client:notify("Invalid faction selected!")
                    return false
                end

                -- Check faction whitelist
                if faction.whitelist and not client:hasPrivilege("Bypass Faction Restrictions") then
                    if not table.HasValue(faction.whitelist, client:SteamID()) then
                        client:notify("You are not whitelisted for this faction!")
                        return false
                    end
                end

                -- Check faction limits
                if faction.limit then
                    local factionCount = 0
                    for _, charID in ipairs(client.liaCharList) do
                        lia.char.getCharacter(client, charID, function(character)
                            if character and character:getFaction() == data.faction then
                                factionCount = factionCount + 1
                            end
                        end)
                    end

                    if factionCount >= faction.limit then
                        client:notify("You have reached the limit for this faction!")
                        return false
                    end
                end

                -- Check faction requirements
                if faction.requiresFlag and not client:hasPrivilege("Bypass Faction Restrictions") then
                    local hasRequired = false
                    for _, charID in ipairs(client.liaCharList) do
                        lia.char.getCharacter(client, charID, function(character)
                            if character and character:hasFlags(faction.requiresFlag) then
                                hasRequired = true
                            end
                        end)
                    end

                    if not hasRequired then
                        client:notify("You need a character with the required flag to create this faction!")
                        return false
                    end
                end
            end

            -- Check name restrictions
            if data.name then
                -- Check name length
                if #data.name < 2 or #data.name > 32 then
                    client:notify("Character name must be between 2 and 32 characters!")
                    return false
                end

                -- Check for blocked words
                local blockedWords = lia.config.get("blockedNameWords", {"admin", "mod", "server"})
                local lowerName = data.name:lower()
                for _, word in ipairs(blockedWords) do
                    if lowerName:find(word) then
                        client:notify("Character name contains blocked words!")
                        return false
                    end
                end

                -- Check for duplicate names
                local result = lia.db.select({"id"}, "lia_characters", "_name = " .. lia.db.convertDataType(data.name)):next()
                if result then
                    client:notify("A character with this name already exists!")
                    return false
                end
            end

            -- Check creation cooldown
            local lastCreation = client:getData("lastCharCreation", 0)
            local cooldown = lia.config.get("charCreationCooldown", 300) -- 5 minutes default

            if (os.time() - lastCreation) < cooldown then
                local remaining = cooldown - (os.time() - lastCreation)
                client:notify("You must wait " .. math.ceil(remaining / 60) .. " minutes before creating another character!")
                return false
            end

            -- Check server population limits
            local totalChars = lia.db.select({"COUNT(*)"}, "lia_characters"):next()
            local maxServerChars = lia.config.get("maxServerCharacters", 1000)

            if totalChars and totalChars[1] >= maxServerChars then
                client:notify("Server character limit reached!")
                return false
            end

            -- Check wanted status
            if client:getNetVar("wanted", false) then
                client:notify("Wanted players cannot create characters!")
                return false
            end

            -- Update last creation time
            client:setData("lastCharCreation", os.time())

            -- Log character creation attempt
            lia.log.add(client:Name() .. " (" .. client:SteamID() .. ") attempted to create character: " ..
                (data.name or "Unknown"), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerCreateChar(client, data)
end

--[[
    Purpose:
        Determines if a player can drop an item.

    When Called:
        When attempting to drop an item.

    Parameters:
        client (Player)
            The player attempting to drop.
        item (Item)
            The item being dropped.

    Returns:
        boolean
            Whether the item can be dropped.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic item drop check
        function MODULE:CanPlayerDropItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            return char ~= nil -- Allow drop if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Item-specific drop restrictions
        function MODULE:CanPlayerDropItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if item is soulbound
            if item:getData("soulbound", false) then
                client:notify("This item is soulbound and cannot be dropped!")
                return false
            end

            -- Check if item requires certain flags
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                client:notify("You don't have permission to drop this item!")
                return false
            end

            -- Check if item is equipped
            if item:getData("equip", false) then
                client:notify("You must unequip this item first!")
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item dropping with multiple restrictions
        function MODULE:CanPlayerDropItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                client:notify("You cannot drop items while dead!")
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                client:notify("Wanted criminals cannot drop items!")
                return false
            end

            -- Check item soulbinding
            if item:getData("soulbound", false) then
                client:notify("This item is soulbound to you and cannot be dropped!")
                return false
            end

            -- Check equipped items
            if item:getData("equip", false) then
                client:notify("You must unequip this item first!")
                return false
            end

            -- Check item flags and permissions
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                client:notify("You don't have permission to drop this item!")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                client:notify("This item belongs to a different faction!")
                return false
            end

            -- Check class restrictions
            local itemClass = item:getData("class")
            if itemClass and itemClass ~= char:getClass() then
                client:notify("This item is restricted to a different class!")
                return false
            end

            -- Check item level requirements (can't drop items below certain level)
            if item.levelRequired and char:getLevel and char:getLevel() < item.levelRequired then
                client:notify("You are not high enough level to drop this item safely!")
                return false
            end

            -- Check valuable items (require confirmation or special permission)
            if item.price and item.price > 1000 then
                if not client:getData("confirmedDrop", false) then
                    client:notify("This is a valuable item! Use /confirmdrop to drop it.")
                    return false
                end
                client:setData("confirmedDrop", false) -- Reset confirmation
            end

            -- Check location restrictions (no dropping in certain areas)
            local pos = client:GetPos()
            if lia.config.get("noDropZones") then
                for _, zone in ipairs(lia.config.get("noDropZones")) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        client:notify("You cannot drop items in this area!")
                        return false
                    end
                end
            end

            -- Check item drop cooldown
            local lastDrop = item:getData("lastDropped", 0)
            local cooldown = item:getData("dropCooldown", 0)
            if cooldown > 0 and (CurTime() - lastDrop) < cooldown then
                client:notify("You must wait before dropping this item again!")
                return false
            end

            -- Check inventory space (ensure player has space after dropping)
            local inventory = char:getInv()
            if inventory and inventory:getMaxSlots() then
                -- Some systems might require space management
                local currentSlots = inventory:getSlots()
                if currentSlots >= inventory:getMaxSlots() then
                    client:notify("Your inventory is too full to drop items!")
                    return false
                end
            end

            -- Check server drop limits
            local dropCount = client:getData("dropCount", 0)
            local maxDrops = lia.config.get("maxDropsPerMinute", 10)

            if dropCount >= maxDrops then
                client:notify("You are dropping items too quickly!")
                return false
            end

            -- Update drop tracking
            item:setData("lastDropped", CurTime())
            client:setData("dropCount", dropCount + 1)

            -- Reset drop count after a minute
            timer.Create("ResetDropCount_" .. client:SteamID(), 60, 1, function()
                if IsValid(client) then
                    client:setData("dropCount", 0)
                end
            end)

            -- Log item drop
            lia.log.add(client:Name() .. " dropped item: " .. item.name ..
                " (ID: " .. item.id .. ")", FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerDropItem(client, item)
end

--[[
    Purpose:
        Determines if a player can earn salary.

    When Called:
        When calculating salary payments.

    Parameters:
        client (Player)
            The player earning salary.

    Returns:
        boolean
            Whether salary can be earned.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic salary check
        function MODULE:CanPlayerEarnSalary(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            return char ~= nil -- Allow salary if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Job and faction-based salary restrictions
        function MODULE:CanPlayerEarnSalary(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player has a job/class that earns salary
            local classID = char:getClass()
            if not classID then return false end

            local class = lia.class.get(classID)
            if not class or not class.salary then
                return false -- Class doesn't earn salary
            end

            -- Check faction salary permissions
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.noSalary then
                return false -- Faction doesn't allow salary
            end

            -- Check if player is employed
            if char:getData("unemployed", false) then
                return false -- Player is unemployed
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary system with multiple conditions
        function MODULE:CanPlayerEarnSalary(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals don't earn salary
            end

            -- Check employment status
            if char:getData("unemployed", false) then
                return false -- Unemployed players don't earn salary
            end

            -- Check probation period
            local probationEnd = char:getData("probationEnd", 0)
            if os.time() < probationEnd then
                return false -- Still on probation
            end

            -- Check class/job salary permissions
            local classID = char:getClass()
            if not classID then return false end

            local class = lia.class.get(classID)
            if not class then return false end

            -- Check if class earns salary
            if not class.salary or class.salary <= 0 then
                return false
            end

            -- Check class-specific salary conditions
            if class.salaryCondition and not class:salaryCondition(client) then
                return false
            end

            -- Check faction salary restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction then
                if faction.noSalary then
                    return false -- Faction blocks salary
                end

                -- Check faction salary conditions
                if faction.salaryCondition and not faction:salaryCondition(client) then
                    return false
                end
            end

            -- Check performance requirements
            local performanceScore = char:getData("performanceScore", 100)
            if performanceScore < 50 then
                return false -- Poor performance, no salary
            end

            -- Check attendance requirements
            local lastActive = char:getData("lastActive", os.time())
            local daysInactive = (os.time() - lastActive) / 86400
            if daysInactive > 7 then
                return false -- Too long inactive
            end

            -- Check disciplinary actions
            local warnings = char:getData("warnings", 0)
            if warnings >= 3 then
                return false -- Too many warnings, salary suspended
            end

            -- Check company/department status
            local department = char:getData("department")
            if department then
                local deptData = lia.config.get("departments", {})[department]
                if deptData and deptData.salarySuspended then
                    return false -- Department salary suspended
                end
            end

            -- Check work hours requirements
            local workHours = char:getData("workHours", 0)
            local requiredHours = lia.config.get("requiredWorkHours", 40)
            if workHours < requiredHours then
                return false -- Haven't worked enough hours
            end

            -- Check payday restrictions (certain times/days)
            local currentTime = os.date("*t")
            if currentTime.wday == 1 then
                return false -- No salary on Mondays (example)
            end

            -- Check tax/payment status
            if char:getData("taxesOwed", false) then
                return false -- Outstanding taxes, salary withheld
            end

            -- Check company policy violations
            local violations = char:getData("policyViolations", 0)
            if violations > 0 then
                return false -- Policy violations, salary suspended
            end

            -- Check union status (if applicable)
            if lia.config.get("unionRequired", false) then
                if not char:getData("unionMember", false) then
                    return false -- Must be union member
                end
            end

            -- Reset work hours for next pay period
            char:setData("workHours", 0)

            -- Log salary payment
            lia.log.add(client:Name() .. " earned salary: $" ..
                (class.salary or 0), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerEarnSalary(client)
end

--[[
    Purpose:
        Determines if a player can equip an item.

    When Called:
        When attempting to equip an item.

    Parameters:
        client (Player)
            The player attempting to equip.
        item (Item)
            The item being equipped.

    Returns:
        boolean
            Whether the item can be equipped.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic equip check
        function MODULE:CanPlayerEquipItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            return char ~= nil -- Allow equip if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Item type and class restrictions
        function MODULE:CanPlayerEquipItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if item is equippable
            if not item.isEquipable then
                return false
            end

            -- Check class restrictions
            if item.classRequired then
                local playerClass = char:getClass()
                if playerClass ~= item.classRequired then
                    return false
                end
            end

            -- Check faction restrictions
            if item.factionRequired then
                if char:getFaction() ~= item.factionRequired then
                    return false
                end
            end

            -- Check flag requirements
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced equipment system with multiple validations
        function MODULE:CanPlayerEquipItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                client:notify("You cannot equip items while dead!")
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                client:notify("Wanted criminals cannot equip items!")
                return false
            end

            -- Check if item is equippable
            if not item.isEquipable then
                return false
            end

            -- Check item durability
            local durability = item:getData("durability", 100)
            if durability <= 0 then
                client:notify("This item is too damaged to equip!")
                return false
            end

            -- Check faction restrictions
            if item.factionRequired then
                if char:getFaction() ~= item.factionRequired then
                    client:notify("This item is restricted to a different faction!")
                    return false
                end
            end

            -- Check class restrictions
            if item.classRequired then
                local playerClass = char:getClass()
                if playerClass ~= item.classRequired then
                    client:notify("This item is restricted to a different class!")
                    return false
                end
            end

            -- Check flag requirements
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                client:notify("You don't have the required permissions for this item!")
                return false
            end

            -- Check level requirements
            if item.levelRequired then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < item.levelRequired then
                    client:notify("You are not high enough level for this item!")
                    return false
                end
            end

            -- Check skill requirements
            if item.skillRequired then
                for skill, minLevel in pairs(item.skillRequired) do
                    local skillLevel = char:getAttrib(skill, 0)
                    if skillLevel < minLevel then
                        client:notify("You don't have the required skill for this item!")
                        return false
                    end
                end
            end

            -- Check reputation requirements
            if item.reputationRequired then
                local playerRep = char:getData("reputation", 0)
                if playerRep < item.reputationRequired then
                    client:notify("You don't have enough reputation for this item!")
                    return false
                end
            end

            -- Check equipment slots
            if item.slot then
                -- Check if slot is already occupied
                local inventory = char:getInv()
                if inventory then
                    for _, invItem in pairs(inventory:getItems()) do
                        if invItem:getData("equip", false) and invItem.slot == item.slot then
                            client:notify("You already have an item equipped in that slot!")
                            return false
                        end
                    end
                end

                -- Check slot compatibility with player race/class
                if item.slotRestricted then
                    local restrictions = item.slotRestricted
                    if restrictions.classes and not table.HasValue(restrictions.classes, char:getClass()) then
                        client:notify("Your class cannot equip items in this slot!")
                        return false
                    end
                end
            end

            -- Check weight restrictions
            if item.weight then
                local currentWeight = self:GetEquippedWeight(client)
                local maxWeight = char:getMaxEquipWeight and char:getMaxEquipWeight() or 50

                if currentWeight + item.weight > maxWeight then
                    client:notify("This item would make you too encumbered!")
                    return false
                end
            end

            -- Check armor class restrictions (light/medium/heavy armor)
            if item.armorClass then
                local playerArmorSkill = char:getAttrib("armorSkill", 0)
                local requiredSkill = {light = 0, medium = 25, heavy = 50}

                if playerArmorSkill < requiredSkill[item.armorClass] then
                    client:notify("You don't have the armor skill to equip this!")
                    return false
                end
            end

            -- Check magical attunement
            if item.requiresAttunement then
                if not char:getData("attunedItems", {})[item.uniqueID] then
                    client:notify("This item requires attunement!")
                    return false
                end
            end

            -- Check curse status
            if item:getData("cursed", false) then
                if not char:getData("curseImmunity", false) then
                    client:notify("This item is cursed! You cannot equip it safely.")
                    return false
                end
            end

            -- Check time-based restrictions
            local currentTime = os.date("*t")
            if item.seasonal and item.seasonal ~= currentTime.month then
                client:notify("This item is not available during this season!")
                return false
            end

            -- Check equip cooldown
            local lastEquip = item:getData("lastEquipped", 0)
            local cooldown = item:getData("equipCooldown", 0)
            if cooldown > 0 and (CurTime() - lastEquip) < cooldown then
                client:notify("You must wait before equipping this item again!")
                return false
            end

            -- Update equip timestamp
            item:setData("lastEquipped", CurTime())

            -- Log equipment
            lia.log.add(client:Name() .. " equipped item: " .. item.name, FLAG_NORMAL)

            return true
        end

        -- Helper function to calculate equipped weight
        function MODULE:GetEquippedWeight(client)
            local char = client:getChar()
            if not char then return 0 end

            local inventory = char:getInv()
            if not inventory then return 0 end

            local totalWeight = 0
            for _, item in pairs(inventory:getItems()) do
                if item:getData("equip", false) and item.weight then
                    totalWeight = totalWeight + item.weight
                end
            end

            return totalWeight
        end
        ```
]]
function CanPlayerEquipItem(client, item)
end

--[[
    Purpose:
        Determines if a player can hold an object.

    When Called:
        When attempting to pick up an object.

    Parameters:
        client (Player)
            The player attempting to hold.
        entity (Entity)
            The entity being held.

    Returns:
        boolean
            Whether the object can be held.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic object holding check
        function MODULE:CanPlayerHoldObject(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            return char ~= nil -- Allow holding if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Weight and ownership restrictions
        function MODULE:CanPlayerHoldObject(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check entity ownership
            if entity:getNetVar("owner") and entity:getNetVar("owner") ~= client then
                return false -- Can't hold someone else's object
            end

            -- Check entity weight
            local entPhys = entity:GetPhysicsObject()
            if IsValid(entPhys) then
                local weight = entPhys:GetMass()
                local maxWeight = char:getData("maxHoldWeight", 50)

                if weight > maxWeight then
                    return false -- Too heavy
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced object holding with multiple restrictions
        function MODULE:CanPlayerHoldObject(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't hold objects
            end

            -- Check entity type restrictions
            local class = entity:GetClass()
            if lia.config.get("restrictedHoldClasses", {})[class] then
                return false -- Certain entity types can't be held
            end

            -- Check entity ownership and permissions
            local owner = entity:getNetVar("owner")
            if owner then
                if owner ~= client then
                    -- Check if player can hold others' objects
                    if not client:hasPrivilege("Staff Permissions") then
                        return false
                    end
                end
            else
                -- Unowned objects may have restrictions
                if entity:getNetVar("noPickup", false) then
                    return false
                end
            end

            -- Check physics properties
            local entPhys = entity:GetPhysicsObject()
            if IsValid(entPhys) then
                -- Check weight limits
                local weight = entPhys:GetMass()
                local maxWeight = char:getData("maxHoldWeight", 50) +
                                 (char:getAttrib("strength", 0) * 2) -- Strength bonus

                if weight > maxWeight then
                    return false
                end

                -- Check size limits
                local size = entPhys:GetVolume and entPhys:GetVolume() or 1000
                local maxSize = char:getData("maxHoldSize", 10000)

                if size > maxSize then
                    return false
                end

                -- Check if entity is too far
                local distance = client:GetPos():Distance(entity:GetPos())
                if distance > 150 then
                    return false
                end
            end

            -- Check faction restrictions
            local entFaction = entity:getNetVar("faction")
            if entFaction and entFaction ~= char:getFaction() then
                -- Check if factions are hostile
                if self:IsFactionHostile(char:getFaction(), entFaction) then
                    return false -- Can't hold enemy faction objects
                end
            end

            -- Check class restrictions
            local entClass = entity:getNetVar("classRestriction")
            if entClass and entClass ~= char:getClass() then
                return false
            end

            -- Check flag requirements
            local requiredFlags = entity:getNetVar("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) do
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
            end

            -- Check if player already holds too many objects
            local heldObjects = client:getNetVar("heldObjects", 0)
            local maxHeld = char:getData("maxHeldObjects", 3)

            if heldObjects >= maxHeld then
                return false
            end

            -- Check skill requirements
            if entity:getNetVar("skillRequired") then
                local skillReq = entity:getNetVar("skillRequired")
                for skill, level in pairs(skillReq) do
                    if char:getAttrib(skill, 0) < level then
                        return false
                    end
                end
            end

            -- Check time-based restrictions
            if entity:getNetVar("timeRestricted") then
                local currentTime = os.date("*t")
                local restrictions = entity:getNetVar("timeRestricted")

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Check durability/condition
            local durability = entity:getNetVar("durability", 100)
            if durability <= 0 then
                return false -- Object is broken
            end

            -- Check if object is cursed or trapped
            if entity:getNetVar("cursed", false) then
                if not char:getData("curseImmunity", false) then
                    return false -- Can't safely hold cursed objects
                end
            end

            if entity:getNetVar("trapped", false) then
                if not char:getData("trapImmunity", false) then
                    return false -- Can't safely hold trapped objects
                end
            end

            -- Check location restrictions (no holding in certain areas)
            local pos = entity:GetPos()
            if lia.config.get("noHoldZones") then
                for _, zone in ipairs(lia.config.get("noHoldZones")) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        return false
                    end
                end
            end

            -- Update held objects count
            client:setNetVar("heldObjects", heldObjects + 1)

            -- Log object holding
            lia.log.add(client:Name() .. " picked up object: " .. class, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerHoldObject(client, entity)
end

--[[
    Purpose:
        Determines if a player can interact with an item.

    When Called:
        When a player attempts to interact with an item.

    Parameters:
        client (Player)
            The player attempting interaction.
        action (string)
            The type of interaction.
        item (Item)
            The item being interacted with.
        data (table)
            Additional interaction data.

    Returns:
        boolean
            Whether the interaction is allowed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic item interaction check
        function MODULE:CanPlayerInteractItem(client, action, item, data)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            return char ~= nil -- Allow interaction if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Action-specific and ownership restrictions
        function MODULE:CanPlayerInteractItem(client, action, item, data)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership for certain actions
            if action == "take" or action == "drop" then
                if item:getOwner() and item:getOwner() ~= client then
                    return false -- Can't take/drop others' items
                end
            end

            -- Check item durability for usage actions
            if action == "use" then
                local durability = item:getData("durability", 100)
                if durability <= 0 then
                    return false -- Item is broken
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced interaction system with multiple validations
        function MODULE:CanPlayerInteractItem(client, action, item, data)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() and action ~= "examine" then
                return false -- Dead players can only examine items
            end

            -- Check wanted status
            if char:getData("wanted", false) and action ~= "examine" then
                return false -- Wanted players can only examine items
            end

            -- Check distance restrictions
            if item:getEntity() and IsValid(item:getEntity()) then
                local distance = client:GetPos():Distance(item:getEntity():GetPos())
                local maxDistance = lia.config.get("maxInteractDistance", 100)

                if distance > maxDistance then
                    return false
                end
            end

            -- Action-specific validations
            if action == "take" then
                -- Check inventory space
                local inventory = char:getInv()
                if inventory and not inventory:add(item, true) then
                    return false -- No space in inventory
                end

                -- Check item ownership
                if item:getOwner() and item:getOwner() ~= client then
                    if not client:hasPrivilege("Staff Permissions") then
                        return false -- Can't take others' items
                    end
                end

            elseif action == "drop" then
                -- Check if item is equipped
                if item:getData("equip", false) then
                    return false -- Must unequip first
                end

                -- Check if item is soulbound
                if item:getData("soulbound", false) then
                    return false -- Soulbound items can't be dropped
                end

            elseif action == "use" then
                -- Check item durability
                local durability = item:getData("durability", 100)
                if durability <= 0 then
                    return false
                end

                -- Check cooldown
                local lastUse = item:getData("lastUse", 0)
                local cooldown = item:getData("useCooldown", 0)
                if cooldown > 0 and (CurTime() - lastUse) < cooldown then
                    return false
                end

                -- Check level requirements
                if item.levelRequired and char:getLevel and char:getLevel() < item.levelRequired then
                    return false
                end

            elseif action == "examine" then
                -- Examination is always allowed (within distance)
                return true

            elseif action == "combine" then
                -- Check if player has required items for combination
                if data and data.targetItem then
                    local targetItem = data.targetItem
                    if not targetItem:getOwner() or targetItem:getOwner() ~= client then
                        return false -- Can't combine with others' items
                    end
                end

            elseif action == "custom" then
                -- Custom actions have their own validation
                if item.customActionCheck then
                    return item:customActionCheck(client, data)
                end
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                return false -- Can't interact with other faction items
            end

            -- Check flag requirements
            if item.flagRequired and not char:hasFlags(item.flagRequired) then
                return false
            end

            -- Check time restrictions
            if item.timeRestricted then
                local currentTime = os.date("*t")
                local restrictions = item.timeRestricted

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Check curse status
            if item:getData("cursed", false) and not char:getData("curseImmunity", false) then
                if action == "use" or action == "equip" then
                    return false -- Can't safely use/equip cursed items
                end
            end

            -- Log interaction for security
            lia.log.add(client:Name() .. " " .. action .. " item: " .. item.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerInteractItem(client, action, item, data)
end

--[[
    Purpose:
        Determines if a player can join a class.

    When Called:
        When a player attempts to join a class.

    Parameters:
        client (Player)
            The player attempting to join.
        class (table)
            The class data.
        info (table)
            Additional class information.

    Returns:
        boolean
            Whether the player can join the class.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic class joining check
        function MODULE:CanPlayerJoinClass(client, class, info)
            if not IsValid(client) or not class then return false end

            local char = client:getChar()
            return char ~= nil -- Allow joining if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Faction and class restrictions
        function MODULE:CanPlayerJoinClass(client, class, info)
            if not IsValid(client) or not class then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if class is restricted to certain factions
            if class.factions and not table.HasValue(class.factions, char:getFaction()) then
                return false
            end

            -- Check if player already has this class
            if char:getClass() == class.uniqueID then
                return false -- Already in this class
            end

            -- Check level requirements
            if class.levelRequired and char:getLevel and char:getLevel() < class.levelRequired then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced class system with multiple restrictions
        function MODULE:CanPlayerJoinClass(client, class, info)
            if not IsValid(client) or not class then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't change classes
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't change classes
            end

            -- Check if player already has this class
            if char:getClass() == class.uniqueID then
                return false -- Already in this class
            end

            -- Check faction compatibility
            local charFaction = char:getFaction()
            local factionData = lia.faction.get(charFaction)

            if class.factions then
                if not table.HasValue(class.factions, charFaction) then
                    return false -- Class not available to this faction
                end
            elseif class.factionExclusive and class.factionExclusive ~= charFaction then
                return false -- Class exclusive to another faction
            end

            -- Check level requirements
            if class.levelRequired then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < class.levelRequired then
                    return false
                end
            end

            -- Check attribute requirements
            if class.attributeRequirements then
                for attr, minValue in pairs(class.attributeRequirements) do
                    local attrValue = char:getAttrib(attr, 0)
                    if attrValue < minValue then
                        return false
                    end
                end
            end

            -- Check skill requirements
            if class.skillRequirements then
                for skill, minLevel in pairs(class.skillRequirements) do
                    local skillLevel = char:getAttrib(skill, 0)
                    if skillLevel < minLevel then
                        return false
                    end
                end
            end

            -- Check reputation requirements
            if class.reputationRequired then
                local playerRep = char:getData("reputation", 0)
                if playerRep < class.reputationRequired then
                    return false
                end
            end

            -- Check flag requirements
            if class.flagRequired and not char:hasFlags(class.flagRequired) then
                return false
            end

            -- Check class limits per faction
            if class.limitPerFaction then
                local factionMembers = 0
                for _, ply in player.Iterator() do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == charFaction and plyChar:getClass() == class.uniqueID then
                        factionMembers = factionMembers + 1
                    end
                end

                if factionMembers >= class.limitPerFaction then
                    return false -- Faction class limit reached
                end
            end

            -- Check whitelist/blacklist
            if class.whitelist and not table.HasValue(class.whitelist, client:SteamID()) then
                return false -- Not whitelisted
            end

            if class.blacklist and table.HasValue(class.blacklist, client:SteamID()) then
                return false -- Blacklisted
            end

            -- Check prerequisites (must have been in other classes)
            if class.prerequisites then
                local hasPrereqs = false
                for _, prereqClass in ipairs(class.prerequisites) do
                    if char:getData("previousClasses", {})[prereqClass] then
                        hasPrereqs = true
                        break
                    end
                end

                if not hasPrereqs then
                    return false -- Missing prerequisites
                end
            end

            -- Check class change cooldown
            local lastClassChange = char:getData("lastClassChange", 0)
            local cooldown = lia.config.get("classChangeCooldown", 3600) -- 1 hour default

            if (os.time() - lastClassChange) < cooldown then
                return false -- Class change on cooldown
            end

            -- Check if class has limited slots
            if class.maxPlayers then
                local currentPlayers = 0
                for _, ply in player.Iterator() do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getClass() == class.uniqueID then
                        currentPlayers = currentPlayers + 1
                    end
                end

                if currentPlayers >= class.maxPlayers then
                    return false -- Class is full
                end
            end

            -- Check time restrictions
            if class.timeRestricted then
                local currentTime = os.date("*t")
                local restrictions = class.timeRestricted

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Check special conditions (events, promotions, etc.)
            if class.requiresPromotion and not char:getData("promoted", false) then
                return false -- Requires promotion
            end

            -- Update class change timestamp
            char:setData("lastClassChange", os.time())

            -- Log class change
            lia.log.add(client:Name() .. " joined class: " .. class.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerJoinClass(client, class, info)
end

--[[
    Purpose:
        Determines if a player can knock on an entity.

    When Called:
        When a player attempts to knock on a door or entity.

    Parameters:
        client (Player)
            The player attempting to knock.
        entity (Entity)
            The entity being knocked on.

    Returns:
        boolean
            Whether the knock is allowed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic knock check
        function MODULE:CanPlayerKnock(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            return char ~= nil -- Allow knocking if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Distance and ownership restrictions
        function MODULE:CanPlayerKnock(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check distance
            local maxDistance = 150
            if client:GetPos():Distance(entity:GetPos()) > maxDistance then
                return false -- Too far to knock
            end

            -- Check if player owns the door
            if entity:getNetVar("owner") == client then
                return false -- Don't need to knock on your own door
            end

            -- Check if door is already unlocked
            if not entity:getNetVar("locked", false) then
                return false -- No need to knock if unlocked
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced knocking system with permissions and restrictions
        function MODULE:CanPlayerKnock(client, entity)
            if not IsValid(client) or not IsValid(entity) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't knock
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't knock (too suspicious)
            end

            -- Check distance with line of sight
            local distance = client:GetPos():Distance(entity:GetPos())
            local maxDistance = lia.config.get("maxKnockDistance", 150)

            if distance > maxDistance then
                return false
            end

            -- Check line of sight for realistic knocking
            local trace = util.TraceLine({
                start = client:EyePos(),
                endpos = entity:GetPos() + Vector(0, 0, 50),
                filter = {client, entity}
            })

            if trace.Hit then
                return false -- No line of sight to knock
            end

            -- Check entity type (only allow knocking on doors/containers)
            local class = entity:GetClass()
            if not (class:find("door") or class:find("prop_door") or entity.isDoor) then
                if not lia.config.get("allowKnockOnAllEntities", false) then
                    return false -- Only doors by default
                end
            end

            -- Check ownership
            local owner = entity:getNetVar("owner")
            if owner == client then
                return false -- Don't knock on your own property
            end

            -- Check if door is locked (no point knocking if unlocked)
            if not entity:getNetVar("locked", false) then
                return false
            end

            -- Check faction permissions
            local doorFaction = entity:getNetVar("faction")
            if doorFaction then
                if char:getFaction() == doorFaction then
                    return false -- Don't need to knock on faction doors
                end

                -- Check if factions are hostile
                if self:IsFactionHostile(char:getFaction(), doorFaction) then
                    return false -- Hostile factions can't knock politely
                end
            end

            -- Check time restrictions (quiet hours)
            local currentTime = os.date("*t")
            local quietHours = lia.config.get("quietHours", {start = 22, end_ = 6})

            if (currentTime.hour >= quietHours.start or currentTime.hour <= quietHours.end_) then
                if not client:hasPrivilege("Staff Permissions") then
                    return false -- No knocking during quiet hours
                end
            end

            -- Check knock cooldown
            local lastKnock = client:getData("lastKnock", 0)
            local cooldown = lia.config.get("knockCooldown", 5)

            if (CurTime() - lastKnock) < cooldown then
                return false -- Knocking too frequently
            end

            -- Check if anyone is already knocking
            if entity:getNetVar("beingKnocked", false) then
                return false -- Someone else is already knocking
            end

            -- Update knock timestamp
            client:setData("lastKnock", CurTime())

            -- Mark entity as being knocked on
            entity:setNetVar("beingKnocked", true)

            -- Reset knock status after delay
            timer.Simple(10, function()
                if IsValid(entity) then
                    entity:setNetVar("beingKnocked", false)
                end
            end)

            -- Log knocking for security
            lia.log.add(client:Name() .. " knocked on entity: " .. class ..
                " at " .. tostring(entity:GetPos()), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerKnock(client, entity)
end

--[[
    Purpose:
        Determines if a player can lock a door.

    When Called:
        When a player attempts to lock a door.

    Parameters:
        client (Player)
            The player attempting to lock.
        door (Entity)
            The door being locked.

    Returns:
        boolean
            Whether the door can be locked.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic lock check
        function MODULE:CanPlayerLock(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Allow if player owns the door
            return door:getNetVar("owner") == client
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Ownership and faction permissions
        function MODULE:CanPlayerLock(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership
            if door:getNetVar("owner") == client then
                return true
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction and char:getFaction() == doorFaction then
                -- Check if player has lock permissions in faction
                return char:hasFlags("L") -- Lock permission flag
            end

            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door locking system with multiple permissions
        function MODULE:CanPlayerLock(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't lock doors
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't lock doors
            end

            -- Check distance
            local maxDistance = lia.config.get("maxLockDistance", 100)
            if client:GetPos():Distance(door:GetPos()) > maxDistance then
                return false
            end

            -- Check line of sight
            local trace = util.TraceLine({
                start = client:EyePos(),
                endpos = door:GetPos() + Vector(0, 0, 50),
                filter = {client, door}
            })

            if trace.Hit then
                return false -- No line of sight
            end

            -- Check ownership first
            local owner = door:getNetVar("owner")
            if owner == client then
                return true -- Owner can always lock
            end

            -- Check if door is already locked
            if door:getNetVar("locked", false) then
                return false -- Already locked
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction then
                if char:getFaction() == doorFaction then
                    -- Check faction rank/permissions
                    local factionRank = char:getData("factionRank", 0)
                    local requiredRank = door:getNetVar("lockRankRequired", 1)

                    if factionRank >= requiredRank then
                        return true
                    end

                    -- Check specific faction flags
                    if char:hasFlags("L") then -- Lock permission flag
                        return true
                    end
                end

                -- Check allied faction permissions
                local playerFaction = lia.faction.get(char:getFaction())
                if playerFaction and playerFaction.allies then
                    for _, allyFaction in ipairs(playerFaction.allies) do
                        if allyFaction == doorFaction then
                            local allyPermissions = door:getNetVar("allyLockPermissions", false)
                            if allyPermissions then
                                return true
                            end
                        end
                    end
                end
            end

            -- Check class permissions
            local doorClass = door:getNetVar("classRestriction")
            if doorClass and char:getClass() == doorClass then
                -- Class leaders can lock class doors
                if char:hasFlags("C") then -- Class leader flag
                    return true
                end
            end

            -- Check shared access permissions
            local sharedUsers = door:getNetVar("sharedUsers", {})
            if table.HasValue(sharedUsers, char:getID()) then
                local sharedPermissions = door:getNetVar("sharedLockPermissions", false)
                if sharedPermissions then
                    return true
                end
            end

            -- Check key ownership
            if door:getNetVar("requiresKey", false) then
                local hasKey = char:getData("doorKeys", {})[door:EntIndex()]
                if not hasKey then
                    return false
                end
            end

            -- Check time restrictions
            local timeRestriction = door:getNetVar("lockTimeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false
                end
            end

            -- Check lock cooldown
            local lastLock = door:getNetVar("lastLockTime", 0)
            local cooldown = door:getNetVar("lockCooldown", 0)

            if cooldown > 0 and (CurTime() - lastLock) < cooldown then
                return false -- Lock on cooldown
            end

            -- Update lock timestamp
            door:setNetVar("lastLockTime", CurTime())

            -- Log door locking
            lia.log.add(client:Name() .. " locked door: " .. (door:EntIndex() or "unknown"), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerLock(client, door)
end

--[[
    Purpose:
        Determines if a player can modify configuration settings.

    When Called:
        When a player attempts to modify config values.

    Parameters:
        client (Player)
            The player attempting modification.
        key (string)
            The configuration key.

    Returns:
        boolean
            Whether the config can be modified.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Admin-only config modification
        function MODULE:CanPlayerModifyConfig(client, key)
            if not IsValid(client) then return false end

            -- Only allow super admins to modify config
            return client:IsSuperAdmin()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Role-based config permissions
        function MODULE:CanPlayerModifyConfig(client, key)
            if not IsValid(client) then return false end

            -- Allow admins to modify non-critical settings
            if client:IsAdmin() then
                local restrictedKeys = {
                    "databasePassword",
                    "serverIP",
                    "adminPassword"
                }

                return not table.HasValue(restrictedKeys, key)
            end

            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced config modification permissions
        function MODULE:CanPlayerModifyConfig(client, key)
            if not IsValid(client) then return false end

            -- Super admins can modify everything
            if client:IsSuperAdmin() then
                return true
            end

            -- Check user group permissions
            local userGroup = client:GetUserGroup()
            local allowedGroups = lia.config.get("configModifyGroups", {"superadmin", "admin", "moderator"})

            if not table.HasValue(allowedGroups, userGroup) then
                return false
            end

            -- Define config key permissions by user group
            local keyPermissions = {
                superadmin = {"*"}, -- Can modify all
                admin = {
                    "maxPlayers", "serverName", "gamemode", "map",
                    "voice", "props", "effects", "npcs", "vehicles",
                    "economy", "chat", "logging"
                },
                moderator = {
                    "chat", "logging", "voice"
                }
            }

            local allowedKeys = keyPermissions[userGroup]
            if not allowedKeys then return false end

            -- Check if key is in allowed list or wildcard allows all
            if table.HasValue(allowedKeys, "*") then
                return true
            end

            return table.HasValue(allowedKeys, key)
        end
        ```
]]
function CanPlayerModifyConfig(client, key)
end

--[[
    Purpose:
        Determines if a player can rotate an item.

    When Called:
        When a player attempts to rotate an item in inventory.

    Parameters:
        client (Player)
            The player attempting rotation.
        item (Item)
            The item being rotated.

    Returns:
        boolean
            Whether the item can be rotated.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow item rotation
        function MODULE:CanPlayerRotateItem(client, item)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restrict rotation for certain item types
        function MODULE:CanPlayerRotateItem(client, item)
            if not item then return false end

            -- Don't allow rotation of stackable items
            if item.maxQuantity and item.maxQuantity > 1 then
                return false
            end

            -- Don't allow rotation of equipped items
            if item:getData("equip", false) then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item rotation controls
        function MODULE:CanPlayerRotateItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't rotate items
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't rotate items
            end

            -- Check item ownership
            if item:getOwner() ~= client then
                return false -- Can't rotate others' items
            end

            -- Check if item is equipped
            if item:getData("equip", false) then
                return false -- Can't rotate equipped items
            end

            -- Check item type restrictions
            local restrictedTypes = {
                "weapon", "armor", "vehicle"
            }

            if table.HasValue(restrictedTypes, item.uniqueID) then
                return false -- Certain item types can't be rotated
            end

            -- Check item size (large items might not be rotatable)
            if item.width and item.height then
                if item.width > 3 or item.height > 3 then
                    return false -- Too large to rotate
                end
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                return false -- Can't rotate items from other factions
            end

            -- Check flag requirements
            if item.rotateFlagRequired and not char:hasFlags(item.rotateFlagRequired) then
                return false
            end

            -- Check level requirements
            if item.rotateLevelRequired and char:getLevel and char:getLevel() < item.rotateLevelRequired then
                return false
            end

            -- Check rotation cooldown
            local lastRotated = item:getData("lastRotated", 0)
            local cooldown = item:getData("rotateCooldown", 0)

            if cooldown > 0 and (CurTime() - lastRotated) < cooldown then
                return false
            end

            -- Check if item allows rotation
            if item:getData("noRotate", false) then
                return false
            end

            -- Check inventory type (some inventories might not allow rotation)
            local inventory = item:getInv()
            if inventory and inventory:getData("noRotate", false) then
                return false
            end

            -- Update rotation timestamp
            item:setData("lastRotated", CurTime())

            -- Log item rotation
            lia.log.add(client:Name() .. " rotated item: " .. item.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerRotateItem(client, item)
end

--[[
    Purpose:
        Determines if a player can see a specific log category.

    When Called:
        When checking log visibility permissions.

    Parameters:
        client (Player)
            The player checking logs.
        category (string)
            The log category.

    Returns:
        boolean
            Whether the player can see the log category.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Admins can see all logs
        function MODULE:CanPlayerSeeLogCategory(client, category)
            if not IsValid(client) then return false end

            return client:IsAdmin()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Role-based log access
        function MODULE:CanPlayerSeeLogCategory(client, category)
            if not IsValid(client) then return false end

            local userGroup = client:GetUserGroup()

            -- Define which groups can see which categories
            local categoryPermissions = {
                superadmin = {"*"}, -- All categories
                admin = {"normal", "warning", "error", "security"},
                moderator = {"normal", "warning"}
            }

            local allowedCategories = categoryPermissions[userGroup]
            if not allowedCategories then return false end

            -- Check if category is allowed or wildcard allows all
            return table.HasValue(allowedCategories, "*") or table.HasValue(allowedCategories, category)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced log category permissions with character and faction checks
        function MODULE:CanPlayerSeeLogCategory(client, category)
            if not IsValid(client) then return false end

            -- Super admins can see everything
            if client:IsSuperAdmin() then
                return true
            end

            -- Check user group permissions
            local userGroup = client:GetUserGroup()
            local groupPermissions = lia.config.get("logPermissions", {})[userGroup]

            if not groupPermissions then
                return false -- No permissions defined for this group
            end

            -- Check if category is in allowed list
            if not table.HasValue(groupPermissions.categories or {}, category) and
               not table.HasValue(groupPermissions.categories or {}, "*") then
                return false
            end

            -- Check character requirements
            local char = client:getChar()
            if not char then return false end

            -- Check flag requirements for sensitive logs
            local sensitiveCategories = {"security", "admin", "private"}
            if table.HasValue(sensitiveCategories, category) then
                local requiredFlag = groupPermissions.sensitiveFlag or "A"
                if not char:hasFlags(requiredFlag) then
                    return false
                end
            end

            -- Check faction restrictions
            if groupPermissions.factionRestricted then
                local charFaction = char:getFaction()
                local allowedFactions = groupPermissions.allowedFactions or {}

                if not table.HasValue(allowedFactions, charFaction) and
                   not table.HasValue(allowedFactions, "*") then
                    return false
                end
            end

            -- Check class restrictions
            if groupPermissions.classRestricted then
                local charClass = char:getClass()
                local allowedClasses = groupPermissions.allowedClasses or {}

                if not table.HasValue(allowedClasses, charClass) and
                   not table.HasValue(allowedClasses, "*") then
                    return false
                end
            end

            -- Check level requirements for advanced logs
            if groupPermissions.levelRequired and groupPermissions.levelRequired[category] then
                local requiredLevel = groupPermissions.levelRequired[category]
                local playerLevel = char:getLevel and char:getLevel() or 1

                if playerLevel < requiredLevel then
                    return false
                end
            end

            -- Check reputation requirements
            if groupPermissions.reputationRequired and groupPermissions.reputationRequired[category] then
                local requiredRep = groupPermissions.reputationRequired[category]
                local playerRep = char:getData("reputation", 0)

                if playerRep < requiredRep then
                    return false
                end
            end

            -- Check time restrictions (logs might be restricted during certain hours)
            if groupPermissions.timeRestricted then
                local currentTime = os.date("*t")
                local restrictions = groupPermissions.timeRestricted

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Check if player is in a restricted area
            if groupPermissions.locationRestricted then
                local pos = client:GetPos()
                local restrictedZones = groupPermissions.restrictedZones or {}

                for _, zone in ipairs(restrictedZones) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        return false
                    end
                end
            end

            -- Log the log viewing attempt (meta logging)
            if category == "security" then
                lia.log.add(client:Name() .. " accessed " .. category .. " logs", FLAG_SECURITY)
            end

            return true
        end
        ```
]]
function CanPlayerSeeLogCategory(client, category)
end

--[[
    Purpose:
        Determines if a player can spawn storage.

    When Called:
        When a player attempts to spawn storage entities.

    Parameters:
        client (Player)
            The player attempting to spawn storage.
        entity (Entity)
            The storage entity.
        info (table)
            Storage spawn information.

    Returns:
        boolean
            Whether storage can be spawned.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow storage spawning
        function MODULE:CanPlayerSpawnStorage(client, entity, info)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restrict by user group and limits
        function MODULE:CanPlayerSpawnStorage(client, entity, info)
            if not IsValid(client) then return false end

            -- Check user group permissions
            if not client:IsAdmin() then
                return false -- Only admins can spawn storage
            end

            -- Check storage spawn limits
            local maxStorage = lia.config.get("maxPlayerStorage", 5)
            local currentStorage = client:getData("spawnedStorage", 0)

            if currentStorage >= maxStorage then
                return false -- Reached storage limit
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced storage spawning with multiple validations
        function MODULE:CanPlayerSpawnStorage(client, entity, info)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't spawn storage
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't spawn storage
            end

            -- Check user group permissions
            local userGroup = client:GetUserGroup()
            local allowedGroups = lia.config.get("storageSpawnGroups", {"superadmin", "admin"})

            if not table.HasValue(allowedGroups, userGroup) then
                return false
            end

            -- Check character permissions
            if not char:hasFlags("S") and not client:hasPrivilege("Spawn Storage") then
                return false -- Requires storage spawn flag or privilege
            end

            -- Check storage type restrictions
            if info and info.storageType then
                local restrictedTypes = lia.config.get("restrictedStorageTypes", {})
                if table.HasValue(restrictedTypes, info.storageType) then
                    return false
                end
            end

            -- Check faction restrictions
            local charFaction = char:getFaction()
            local factionData = lia.faction.get(charFaction)

            if factionData and factionData.restrictStorage then
                return false -- Faction cannot spawn storage
            end

            -- Check storage spawn limits
            local maxStorage = char:getData("maxStorage", lia.config.get("defaultMaxStorage", 3))
            local currentStorage = char:getData("currentStorage", 0)

            if currentStorage >= maxStorage then
                return false -- Reached personal storage limit
            end

            -- Check global server storage limits
            local serverMaxStorage = lia.config.get("serverMaxStorage", 50)
            local serverCurrentStorage = lia.data.get("serverStorageCount", 0)

            if serverCurrentStorage >= serverMaxStorage then
                return false -- Server storage limit reached
            end

            -- Check location restrictions
            local pos = info and info.pos or client:GetPos()
            local restrictedZones = lia.config.get("storageRestrictedZones", {})

            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Cannot spawn storage in restricted zones
                end
            end

            -- Check distance from other storage entities
            local minDistance = lia.config.get("minStorageDistance", 200)
            for _, ent in ipairs(ents.FindInSphere(pos, minDistance)) do
                if ent.isStorage or string.find(ent:GetClass(), "storage") then
                    return false -- Too close to existing storage
                end
            end

            -- Check level requirements
            local requiredLevel = info and info.levelRequired or lia.config.get("storageLevelRequired", 0)
            local playerLevel = char:getLevel and char:getLevel() or 1

            if playerLevel < requiredLevel then
                return false
            end

            -- Check reputation requirements
            local requiredRep = info and info.repRequired or lia.config.get("storageRepRequired", 0)
            local playerRep = char:getData("reputation", 0)

            if playerRep < requiredRep then
                return false
            end

            -- Check time restrictions
            local currentTime = os.date("*t")
            local spawnHours = lia.config.get("storageSpawnHours", {start = 0, end_ = 24})

            if currentTime.hour < spawnHours.start or currentTime.hour > spawnHours.end_ then
                return false -- Outside allowed spawn hours
            end

            -- Check if player has required materials/currency
            if info and info.cost then
                if not char:hasMoney(info.cost) then
                    return false -- Insufficient funds
                end
            end

            -- Update storage counts
            char:setData("currentStorage", currentStorage + 1)
            lia.data.set("serverStorageCount", serverCurrentStorage + 1)

            -- Log storage spawning
            lia.log.add(client:Name() .. " spawned storage: " ..
                (info and info.storageType or "unknown"), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerSpawnStorage(client, entity, info)
end

--[[
    Purpose:
        Determines if a player can switch characters.

    When Called:
        When a player attempts to switch characters.

    Parameters:
        client (Player)
            The player switching characters.
        currentChar (Character)
            The current character.
        character (Character)
            The target character.

    Returns:
        boolean
            Whether the character switch is allowed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow character switching
        function MODULE:CanPlayerSwitchChar(client, currentChar, character)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic restrictions on character switching
        function MODULE:CanPlayerSwitchChar(client, currentChar, character)
            if not IsValid(client) or not character then return false end

            -- Can't switch to the same character
            if currentChar and currentChar:getID() == character:getID() then
                return false
            end

            -- Check if target character is valid
            if not character:getName() or character:getName() == "" then
                return false
            end

            -- Check if player owns the target character
            if character:getPlayer() ~= client then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character switching with cooldowns and restrictions
        function MODULE:CanPlayerSwitchChar(client, currentChar, character)
            if not IsValid(client) or not character then return false end

            local char = client:getChar()
            if not char then return false end

            -- Can't switch to the same character
            if currentChar and currentChar:getID() == character:getID() then
                return false
            end

            -- Check if target character exists and is owned by player
            if not character:getName() or character:getName() == "" then
                return false
            end

            if character:getPlayer() ~= client then
                return false
            end

            -- Check if player is alive (can't switch while dead unless admin)
            if not client:Alive() and not client:hasPrivilege("Staff Permissions") then
                return false
            end

            -- Check wanted status (wanted players can't switch characters)
            if char:getData("wanted", false) then
                return false
            end

            -- Check if player is in combat
            if char:getData("inCombat", false) then
                return false -- Can't switch during combat
            end

            -- Check character switch cooldown
            local lastSwitch = client:getData("lastCharSwitch", 0)
            local cooldown = lia.config.get("charSwitchCooldown", 30) -- 30 seconds default

            if (CurTime() - lastSwitch) < cooldown then
                return false -- Still on cooldown
            end

            -- Check if character is banned/restricted
            if character:getData("banned", false) then
                return false -- Character is banned
            end

            -- Check faction restrictions (some factions may not allow switching)
            local targetFaction = lia.faction.get(character:getFaction())
            if targetFaction and targetFaction.noCharSwitch then
                return false
            end

            -- Check if target character is in a restricted area
            local charPos = character:getData("pos")
            if charPos then
                local restrictedZones = lia.config.get("charSwitchRestrictedZones", {})
                for _, zone in ipairs(restrictedZones) do
                    if charPos:WithinAABox(zone.min, zone.max) then
                        return false -- Character is in restricted zone
                    end
                end
            end

            -- Check if target character has active quests/objectives
            if character:getData("activeQuests", {}) then
                local activeQuests = character:getData("activeQuests")
                for questID, questData in pairs(activeQuests) do
                    if questData.noSwitch then
                        return false -- Quest prevents character switching
                    end
                end
            end

            -- Check reputation requirements for certain characters
            local minRep = character:getData("switchMinRep")
            if minRep then
                local playerRep = char:getData("reputation", 0)
                if playerRep < minRep then
                    return false
                end
            end

            -- Check time restrictions
            local currentTime = os.date("*t")
            local switchHours = lia.config.get("charSwitchHours", {start = 0, end_ = 24})

            if currentTime.hour < switchHours.start or currentTime.hour > switchHours.end_ then
                if not client:hasPrivilege("Staff Permissions") then
                    return false -- Outside allowed switching hours
                end
            end

            -- Update switch timestamp
            client:setData("lastCharSwitch", CurTime())

            -- Log character switch
            lia.log.add(client:Name() .. " switching to character: " .. character:getName(), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerSwitchChar(client, currentChar, character)
end

--[[
    Purpose:
        Determines if a player can take an item.

    When Called:
        When a player attempts to take an item.

    Parameters:
        client (Player)
            The player attempting to take the item.
        item (Item)
            The item being taken.

    Returns:
        boolean
            Whether the item can be taken.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow item taking
        function MODULE:CanPlayerTakeItem(client, item)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic ownership and distance checks
        function MODULE:CanPlayerTakeItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if item belongs to player
            if item:getOwner() and item:getOwner() ~= client then
                return false -- Can't take others' items
            end

            -- Check distance if item has an entity
            local itemEntity = item:getEntity()
            if IsValid(itemEntity) then
                local distance = client:GetPos():Distance(itemEntity:GetPos())
                if distance > 150 then
                    return false -- Too far away
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item taking with multiple validations
        function MODULE:CanPlayerTakeItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't take items
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't take items
            end

            -- Check item ownership
            local itemOwner = item:getOwner()
            if itemOwner and itemOwner ~= client then
                -- Check if it's a shared item or player has permission
                if not item:getData("shared", false) and not client:hasPrivilege("Staff Permissions") then
                    return false -- Can't take others' items
                end
            end

            -- Check item restrictions
            if item.noTake then
                return false -- Item cannot be taken
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                -- Check if factions are allied
                local playerFaction = lia.faction.get(char:getFaction())
                if not (playerFaction and playerFaction.allies and table.HasValue(playerFaction.allies, itemFaction)) then
                    return false -- Can't take items from other factions
                end
            end

            -- Check class restrictions
            local itemClass = item:getData("classRestriction")
            if itemClass and itemClass ~= char:getClass() then
                return false
            end

            -- Check flag requirements
            if item.takeFlagRequired and not char:hasFlags(item.takeFlagRequired) then
                return false
            end

            -- Check level requirements
            if item.takeLevelRequired then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < item.takeLevelRequired then
                    return false
                end
            end

            -- Check distance if item has an entity
            local itemEntity = item:getEntity()
            if IsValid(itemEntity) then
                local distance = client:GetPos():Distance(itemEntity:GetPos())
                local maxDistance = lia.config.get("maxItemTakeDistance", 150)

                if distance > maxDistance then
                    return false
                end

                -- Check line of sight
                local trace = util.TraceLine({
                    start = client:EyePos(),
                    endpos = itemEntity:GetPos() + Vector(0, 0, 10),
                    filter = {client, itemEntity}
                })

                if trace.Hit then
                    return false -- No line of sight
                end
            end

            -- Check inventory space
            local inventory = char:getInv()
            if inventory and not inventory:add(item, true) then
                return false -- No space in inventory
            end

            -- Check item weight limits
            if item.weight then
                local currentWeight = self:GetInventoryWeight(client)
                local maxWeight = char:getData("maxCarryWeight", 50)

                if currentWeight + item.weight > maxWeight then
                    return false -- Too heavy
                end
            end

            -- Check item durability/condition
            if item:getData("durability", 100) <= 0 then
                return false -- Item is broken
            end

            -- Check curse status
            if item:getData("cursed", false) and not char:getData("curseImmunity", false) then
                return false -- Can't take cursed items safely
            end

            -- Check if item is locked/secured
            if item:getData("locked", false) then
                if not item:getData("hasKey", false) and not char:hasFlags("L") then
                    return false -- Item is locked
                end
            end

            -- Check time restrictions
            if item.takeTimeRestricted then
                local currentTime = os.date("*t")
                local restrictions = item.takeTimeRestricted

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Check reputation requirements
            if item.takeRepRequired then
                local playerRep = char:getData("reputation", 0)
                if playerRep < item.takeRepRequired then
                    return false
                end
            end

            -- Check location restrictions
            local pos = itemEntity and IsValid(itemEntity) and itemEntity:GetPos() or client:GetPos()
            local restrictedZones = lia.config.get("itemTakeRestrictedZones", {})

            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Cannot take items in restricted zones
                end
            end

            -- Log item taking
            lia.log.add(client:Name() .. " took item: " .. item.name, FLAG_NORMAL)

            return true
        end

        -- Helper function to calculate inventory weight
        function MODULE:GetInventoryWeight(client)
            local char = client:getChar()
            if not char then return 0 end

            local inventory = char:getInv()
            if not inventory then return 0 end

            local totalWeight = 0
            for _, item in pairs(inventory:getItems()) do
                if item.weight then
                    totalWeight = totalWeight + (item.weight * item:getQuantity())
                end
            end

            return totalWeight
        end
        ```
]]
function CanPlayerTakeItem(client, item)
end

--[[
    Purpose:
        Determines if a player can throw a punch.

    When Called:
        When a player attempts to throw a punch.

    Parameters:
        client (Player)
            The player attempting to punch.

    Returns:
        boolean
            Whether the punch is allowed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow punching
        function MODULE:CanPlayerThrowPunch(client)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic restrictions on punching
        function MODULE:CanPlayerThrowPunch(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Can't punch while dead
            if not client:Alive() then
                return false
            end

            -- Check if player is restrained
            if char:getData("restrained", false) then
                return false
            end

            -- Check wanted status (wanted players might be restricted)
            if char:getData("wanted", false) then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced punching system with combat and roleplay restrictions
        function MODULE:CanPlayerThrowPunch(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't punch
            end

            -- Check if player is restrained/handcuffed
            if char:getData("restrained", false) or char:getData("handcuffed", false) then
                return false -- Can't punch while restrained
            end

            -- Check if player is frozen/stunned
            if client:IsFrozen() or char:getData("stunned", false) then
                return false -- Can't punch while incapacitated
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't initiate combat
            end

            -- Check if player is in a no-combat zone
            local pos = client:GetPos()
            local noCombatZones = lia.config.get("noCombatZones", {})

            for _, zone in ipairs(noCombatZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- No punching in safe zones
                end
            end

            -- Check faction restrictions (peaceful factions can't punch)
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.peaceful then
                return false -- Peaceful factions can't initiate violence
            end

            -- Check class restrictions
            local classID = char:getClass()
            if classID then
                local class = lia.class.get(classID)
                if class and class.noCombat then
                    return false -- Non-combat classes can't punch
                end
            end

            -- Check flag restrictions
            if char:hasFlags("P") then -- Pacifist flag
                return false -- Pacifists can't punch
            end

            -- Check stamina requirements
            local stamina = client:getLocalVar("stamina", 100)
            local minStamina = lia.config.get("punchMinStamina", 20)

            if stamina < minStamina then
                return false -- Not enough stamina to punch
            end

            -- Check punch cooldown
            local lastPunch = client:getData("lastPunch", 0)
            local cooldown = lia.config.get("punchCooldown", 1.5)

            if (CurTime() - lastPunch) < cooldown then
                return false -- Still on cooldown
            end

            -- Check if player is in a vehicle
            if client:InVehicle() then
                return false -- Can't punch from vehicles
            end

            -- Check if player has equipped items that prevent punching
            local inventory = char:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if item:getData("equip", false) and item.noPunch then
                        return false -- Certain equipped items prevent punching
                    end
                end
            end

            -- Check health requirements
            local healthPercent = (client:Health() / client:GetMaxHealth()) * 100
            if healthPercent < lia.config.get("punchMinHealth", 20) then
                return false -- Too injured to punch effectively
            end

            -- Check time restrictions (during events, etc.)
            if lia.config.get("combatDisabled", false) then
                return false -- Combat is globally disabled
            end

            -- Check reputation restrictions
            local reputation = char:getData("reputation", 0)
            if reputation < lia.config.get("punchMinReputation", -1000) then
                return false -- Too disreputable to fight
            end

            -- Check if target is valid (must be within range and in line of sight)
            local target = client:GetEyeTrace().Entity
            if IsValid(target) and target:IsPlayer() then
                local distance = client:GetPos():Distance(target:GetPos())
                if distance > lia.config.get("punchMaxDistance", 100) then
                    return false -- Target too far
                end

                -- Check if target is protected (admin, etc.)
                if target:hasPrivilege("Staff Permissions") and not client:hasPrivilege("Staff Permissions") then
                    return false -- Can't punch staff unless you're staff too
                end

                -- Check if target is in the same faction and faction is peaceful
                local targetChar = target:getChar()
                if targetChar and faction and faction.peaceful and targetChar:getFaction() == char:getFaction() then
                    return false -- Can't punch faction members in peaceful factions
                end
            end

            -- Update punch timestamp
            client:setData("lastPunch", CurTime())

            -- Log punch attempt
            lia.log.add(client:Name() .. " attempted to throw punch", FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerThrowPunch(client)
end

--[[
    Purpose:
        Determines if a player can trade with a vendor.

    When Called:
        When a player attempts to trade with a vendor.

    Parameters:
        client (Player)
            The player attempting to trade.
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The type of item being traded.
        isSellingToVendor (boolean)
            Whether selling to or buying from vendor.

    Returns:
        boolean
            Whether the trade is allowed.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow trading
        function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic trading restrictions
        function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
            if not IsValid(client) or not IsValid(vendor) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't trade
            end

            -- Check distance
            local maxDistance = 150
            if client:GetPos():Distance(vendor:GetPos()) > maxDistance then
                return false -- Too far from vendor
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced vendor trading system with multiple restrictions
        function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
            if not IsValid(client) or not IsValid(vendor) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't trade
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't trade
            end

            -- Check if player is restrained
            if char:getData("restrained", false) then
                return false -- Can't trade while restrained
            end

            -- Check distance with line of sight
            local distance = client:GetPos():Distance(vendor:GetPos())
            local maxDistance = lia.config.get("vendorTradeDistance", 150)

            if distance > maxDistance then
                return false
            end

            -- Check line of sight
            local trace = util.TraceLine({
                start = client:EyePos(),
                endpos = vendor:GetPos() + Vector(0, 0, 50),
                filter = {client, vendor}
            })

            if trace.Hit then
                return false -- No line of sight to vendor
            end

            -- Check vendor status
            if vendor:getNetVar("disabled", false) then
                return false -- Vendor is disabled
            end

            -- Check vendor operating hours
            local currentTime = os.date("*t")
            local operatingHours = vendor:getNetVar("operatingHours")
            if operatingHours then
                local currentMinutes = currentTime.hour * 60 + currentTime.min
                if currentMinutes < operatingHours.start or currentMinutes > operatingHours.end then
                    return false -- Outside operating hours
                end
            end

            -- Check faction restrictions
            local vendorFaction = vendor:getNetVar("faction")
            if vendorFaction then
                if char:getFaction() ~= vendorFaction then
                    -- Check if factions are hostile
                    if self:IsFactionHostile(char:getFaction(), vendorFaction) then
                        return false -- Hostile factions can't trade
                    end

                    -- Check allied faction trading permissions
                    local playerFaction = lia.faction.get(char:getFaction())
                    if not (playerFaction and playerFaction.allies and table.HasValue(playerFaction.allies, vendorFaction)) then
                        local alliedTrade = vendor:getNetVar("allowAlliedTrade", true)
                        if not alliedTrade then
                            return false
                        end
                    end
                end
            end

            -- Check reputation requirements
            local minRep = vendor:getNetVar("minReputation", 0)
            local playerRep = char:getData("reputation", 0)

            if playerRep < minRep then
                return false
            end

            -- Check flag requirements
            local requiredFlags = vendor:getNetVar("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) do
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
            end

            -- Check item type restrictions
            local restrictedItems = vendor:getNetVar("restrictedItems", {})
            if table.HasValue(restrictedItems, itemType) then
                return false
            end

            -- Check selling vs buying restrictions
            if isSellingToVendor then
                -- Selling restrictions
                if vendor:getNetVar("noSelling", false) then
                    return false -- Vendor doesn't accept sales
                end

                -- Check if item is sellable
                if itemType then
                    local sellableItems = vendor:getNetVar("sellableItems", {})
                    if sellableItems[1] and not table.HasValue(sellableItems, itemType) then
                        return false -- Item not accepted by vendor
                    end
                end
            else
                -- Buying restrictions
                if vendor:getNetVar("noBuying", false) then
                    return false -- Vendor doesn't sell items
                end

                -- Check if player can afford items
                local playerMoney = char:getMoney()
                local itemPrice = vendor:getNetVar("priceMultiplier", 1.0) * (vendor.prices and vendor.prices[itemType] or 100)

                if playerMoney < itemPrice then
                    return false -- Can't afford item
                end
            end

            -- Check trade cooldown
            local lastTrade = client:getData("lastVendorTrade", 0)
            local cooldown = lia.config.get("vendorTradeCooldown", 0.5)

            if (CurTime() - lastTrade) < cooldown then
                return false -- Trading too frequently
            end

            -- Check if vendor has stock (for buying)
            if not isSellingToVendor and itemType then
                local stock = vendor:getNetVar("stock", {})[itemType] or 0
                if stock <= 0 then
                    return false -- Out of stock
                end
            end

            -- Check player inventory space (for buying)
            if not isSellingToVendor then
                local inventory = char:getInv()
                if inventory and not inventory:add(itemType, 1, true) then
                    return false -- No space in inventory
                end
            end

            -- Check if item exists in player inventory (for selling)
            if isSellingToVendor and itemType then
                local inventory = char:getInv()
                if inventory then
                    local hasItem = false
                    for _, item in pairs(inventory:getItems()) do
                        if item.uniqueID == itemType and item:getQuantity() > 0 then
                            hasItem = true
                            break
                        end
                    end
                    if not hasItem then
                        return false -- Player doesn't have item
                    end
                end
            end

            -- Check special vendor conditions (events, holidays, etc.)
            if vendor:getNetVar("eventOnly", false) then
                if not lia.config.get("eventMode", false) then
                    return false -- Vendor only available during events
                end
            end

            -- Update trade timestamp
            client:setData("lastVendorTrade", CurTime())

            -- Log trade attempt
            lia.log.add(client:Name() .. " attempted " ..
                (isSellingToVendor and "selling" or "buying") ..
                " " .. (itemType or "unknown") .. " with vendor", FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Determines if a player can unequip an item.

    When Called:
        When a player attempts to unequip an item.

    Parameters:
        client (Player)
            The player attempting to unequip.
        item (Item)
            The item being unequipped.

    Returns:
        boolean
            Whether the item can be unequipped.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow unequipping
        function MODULE:CanPlayerUnequipItem(client, item)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic unequipping restrictions
        function MODULE:CanPlayerUnequipItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't unequip
            end

            -- Check if item is actually equipped
            if not item:getData("equip", false) then
                return false -- Item not equipped
            end

            -- Check if player owns the item
            if item:getOwner() ~= client then
                return false -- Can't unequip others' items
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced unequipping system with combat and safety restrictions
        function MODULE:CanPlayerUnequipItem(client, item)
            if not IsValid(client) or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't unequip
            end

            -- Check if player is restrained
            if char:getData("restrained", false) then
                return false -- Can't unequip while restrained
            end

            -- Check if item is actually equipped
            if not item:getData("equip", false) then
                return false -- Item not equipped
            end

            -- Check if player owns the item
            if item:getOwner() ~= client then
                return false -- Can't unequip others' items
            end

            -- Check item durability/condition
            if item:getData("durability", 100) <= 0 then
                return false -- Item is broken and can't be unequipped safely
            end

            -- Check if unequipping would cause problems
            if item:getData("cursed", false) and not char:getData("curseImmunity", false) then
                return false -- Can't unequip cursed items
            end

            -- Check combat status (some items can't be unequipped during combat)
            if char:getData("inCombat", false) then
                if item.noCombatUnequip then
                    return false -- Item cannot be unequipped during combat
                end

                -- Check combat unequip cooldown
                local lastUnequip = item:getData("lastUnequip", 0)
                local combatCooldown = item:getData("combatUnequipCooldown", 30)

                if (CurTime() - lastUnequip) < combatCooldown then
                    return false -- Too soon to unequip during combat
                end
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction and itemFaction ~= char:getFaction() then
                return false -- Can't unequip items from other factions
            end

            -- Check class restrictions
            local itemClass = item:getData("classRestriction")
            if itemClass and itemClass ~= char:getClass() then
                return false
            end

            -- Check flag requirements
            if item.unequipFlagRequired and not char:hasFlags(item.unequipFlagRequired) then
                return false
            end

            -- Check level requirements for safe unequipping
            if item.unequipLevelRequired then
                local playerLevel = char:getLevel and char:getLevel() or 1
                if playerLevel < item.unequipLevelRequired then
                    return false -- Not skilled enough to unequip safely
                end
            end

            -- Check unequip cooldown
            local lastUnequip = item:getData("lastUnequip", 0)
            local cooldown = item:getData("unequipCooldown", 0)

            if cooldown > 0 and (CurTime() - lastUnequip) < cooldown then
                return false -- Item on unequip cooldown
            end

            -- Check environmental restrictions
            if item:getData("noUnequipWet", false) and client:WaterLevel() > 0 then
                return false -- Can't unequip when wet
            end

            -- Check if unequipping requires tools or assistance
            if item.requiresUnequipTool then
                local hasTool = false
                local inventory = char:getInv()

                if inventory then
                    for _, invItem in pairs(inventory:getItems()) do
                        if invItem.uniqueID == item.requiresUnequipTool then
                            hasTool = true
                            break
                        end
                    end
                end

                if not hasTool then
                    return false -- Required tool not available
                end
            end

            -- Check if unequipping would leave player vulnerable
            if item.providesProtection then
                -- Check if unequipping would reduce protection below safe threshold
                local currentProtection = self:GetPlayerProtectionLevel(client)
                local itemProtection = item.providesProtection
                local minProtection = lia.config.get("minProtectionLevel", 10)

                if (currentProtection - itemProtection) < minProtection then
                    -- Allow unequipping only if player acknowledges risk or has backup
                    if not char:getData("acknowledgedRisk", false) then
                        return false -- Too risky to unequip
                    end
                end
            end

            -- Check location restrictions
            local pos = client:GetPos()
            local restrictedZones = lia.config.get("unequipRestrictedZones", {})

            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Cannot unequip in restricted zones
                end
            end

            -- Check time restrictions
            if item.timeRestrictedUnequip then
                local currentTime = os.date("*t")
                local restrictions = item.timeRestrictedUnequip

                if restrictions.start and restrictions.end then
                    local currentMinutes = currentTime.hour * 60 + currentTime.min
                    if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                        return false
                    end
                end
            end

            -- Update unequip timestamp
            item:setData("lastUnequip", CurTime())

            -- Reset risk acknowledgment
            if char:getData("acknowledgedRisk", false) then
                char:setData("acknowledgedRisk", false)
            end

            -- Log unequipping
            lia.log.add(client:Name() .. " unequipped item: " .. item.name, FLAG_NORMAL)

            return true
        end

        -- Helper function to calculate player protection level
        function MODULE:GetPlayerProtectionLevel(client)
            local char = client:getChar()
            if not char then return 0 end

            local inventory = char:getInv()
            if not inventory then return 0 end

            local totalProtection = 0
            for _, item in pairs(inventory:getItems()) do
                if item:getData("equip", false) and item.providesProtection then
                    totalProtection = totalProtection + item.providesProtection
                end
            end

            return totalProtection
        end
        ```
]]
function CanPlayerUnequipItem(client, item)
end

--[[
    Purpose:
        Determines if a player can unlock a door.

    When Called:
        When a player attempts to unlock a door.

    Parameters:
        client (Player)
            The player attempting to unlock.
        door (Entity)
            The door being unlocked.

    Returns:
        boolean
            Whether the door can be unlocked.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow unlocking
        function MODULE:CanPlayerUnlock(client, door)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic ownership and distance checks
        function MODULE:CanPlayerUnlock(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership
            if door:getNetVar("owner") == client then
                return true -- Owner can always unlock
            end

            -- Check distance
            local maxDistance = 100
            if client:GetPos():Distance(door:GetPos()) > maxDistance then
                return false -- Too far away
            end

            -- Check if door is already unlocked
            if not door:getNetVar("locked", false) then
                return false -- Already unlocked
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door unlocking system with permissions and security
        function MODULE:CanPlayerUnlock(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't unlock doors
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't unlock doors
            end

            -- Check distance with line of sight
            local distance = client:GetPos():Distance(door:GetPos())
            local maxDistance = lia.config.get("maxUnlockDistance", 100)

            if distance > maxDistance then
                return false
            end

            -- Check line of sight
            local trace = util.TraceLine({
                start = client:EyePos(),
                endpos = door:GetPos() + Vector(0, 0, 50),
                filter = {client, door}
            })

            if trace.Hit then
                return false -- No line of sight
            end

            -- Check if door is already unlocked
            if not door:getNetVar("locked", false) then
                return false -- Already unlocked
            end

            -- Check ownership first
            local owner = door:getNetVar("owner")
            if owner == client then
                return true -- Owner can always unlock
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction then
                if char:getFaction() == doorFaction then
                    -- Check faction rank/permissions
                    local factionRank = char:getData("factionRank", 0)
                    local requiredRank = door:getNetVar("unlockRankRequired", 1)

                    if factionRank >= requiredRank then
                        return true
                    end

                    -- Check specific faction flags
                    if char:hasFlags("U") then -- Unlock permission flag
                        return true
                    end
                end

                -- Check allied faction permissions
                local playerFaction = lia.faction.get(char:getFaction())
                if playerFaction and playerFaction.allies then
                    for _, allyFaction in ipairs(playerFaction.allies) do
                        if allyFaction == doorFaction then
                            local allyPermissions = door:getNetVar("allyUnlockPermissions", false)
                            if allyPermissions then
                                return true
                            end
                        end
                    end
                end
            end

            -- Check class permissions
            local doorClass = door:getNetVar("classRestriction")
            if doorClass and char:getClass() == doorClass then
                -- Class leaders can unlock class doors
                if char:hasFlags("C") then -- Class leader flag
                    return true
                end
            end

            -- Check shared access permissions
            local sharedUsers = door:getNetVar("sharedUsers", {})
            if table.HasValue(sharedUsers, char:getID()) then
                local sharedPermissions = door:getNetVar("sharedUnlockPermissions", false)
                if sharedPermissions then
                    return true
                end
            end

            -- Check key ownership
            local hasKey = false
            if door:getNetVar("requiresKey", false) then
                hasKey = char:getData("doorKeys", {})[door:EntIndex()]
                if not hasKey then
                    return false -- No key for this door
                end
            end

            -- Check lockpicking (if no key required)
            if not door:getNetVar("requiresKey", false) and not hasKey then
                -- Check lockpicking skills
                if not char:hasFlags("L") then -- Lockpick flag required
                    return false
                end

                -- Check lockpicking tools
                local hasTools = false
                local inventory = char:getInv()
                if inventory then
                    for _, item in pairs(inventory:getItems()) do
                        if item.isLockpick then
                            hasTools = true
                            break
                        end
                    end
                end

                if not hasTools then
                    return false -- No lockpicking tools
                end

                -- Check lockpicking skill level
                local lockpickSkill = char:getAttrib("lockpicking", 0)
                local lockDifficulty = door:getNetVar("lockDifficulty", 25)

                if lockpickSkill < lockDifficulty then
                    return false -- Not skilled enough
                end

                -- Chance of breaking lockpick
                if math.random() < lia.config.get("lockpickBreakChance", 0.1) then
                    -- Remove a lockpick from inventory
                    if inventory then
                        for _, item in pairs(inventory:getItems()) do
                            if item.isLockpick then
                                item:remove()
                                client:notify("Your lockpick broke!")
                                lia.log.add(client:Name() .. " broke a lockpick on door", FLAG_WARNING)
                                break
                            end
                        end
                    end
                end
            end

            -- Check time restrictions
            local timeRestriction = door:getNetVar("unlockTimeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false
                end
            end

            -- Check unlock cooldown
            local lastUnlock = door:getNetVar("lastUnlockTime", 0)
            local cooldown = door:getNetVar("unlockCooldown", 0)

            if cooldown > 0 and (CurTime() - lastUnlock) < cooldown then
                return false -- Door on unlock cooldown
            end

            -- Check alarm system (unlocking might trigger alarm)
            if door:getNetVar("hasAlarm", false) then
                -- Chance of triggering alarm
                if math.random() < lia.config.get("alarmTriggerChance", 0.3) then
                    -- Trigger alarm
                    self:TriggerDoorAlarm(door, client)
                end
            end

            -- Update unlock timestamp
            door:setNetVar("lastUnlockTime", CurTime())

            -- Log door unlocking
            lia.log.add(client:Name() .. " unlocked door: " .. (door:EntIndex() or "unknown"), FLAG_NORMAL)

            return true
        end

        -- Helper function to trigger door alarm
        function MODULE:TriggerDoorAlarm(door, client)
            -- Alert nearby players or authorities
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) <= 500 and ply ~= client then
                    ply:notify("Security alarm triggered at door!")
                end
            end

            -- Log security breach
            lia.log.add("Security alarm triggered by " .. client:Name() .. " at door " .. door:EntIndex(), FLAG_WARNING)

            -- Could add additional security measures here
        end
        ```
]]
function CanPlayerUnlock(client, door)
end

--[[
    Purpose:
        Determines if a player can use a character.

    When Called:
        When a player attempts to select/use a character.

    Parameters:
        client (Player)
            The player attempting to use the character.
        character (Character)
            The character being used.

    Returns:
        boolean
            Whether the character can be used.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow character usage
        function MODULE:CanPlayerUseChar(client, character)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic ownership and validity checks
        function MODULE:CanPlayerUseChar(client, character)
            if not IsValid(client) or not character then return false end

            -- Check if character belongs to player
            if character:getPlayer() ~= client then
                return false
            end

            -- Check if character is valid
            if not character:getName() or character:getName() == "" then
                return false
            end

            -- Check if character is banned
            if character:getData("banned", false) then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character usage system with restrictions and validations
        function MODULE:CanPlayerUseChar(client, character)
            if not IsValid(client) or not character then return false end

            -- Check if character belongs to player
            if character:getPlayer() ~= client then
                return false -- Can't use others' characters
            end

            -- Check if character is valid
            if not character:getName() or character:getName() == "" then
                return false -- Invalid character
            end

            -- Check if character is banned
            if character:getData("banned", false) then
                return false -- Character is banned
            end

            -- Check character lock status
            if character:getData("locked", false) then
                return false -- Character is locked
            end

            -- Check whitelist/blacklist
            local steamID = client:SteamID()
            local charWhitelist = character:getData("whitelist")
            local charBlacklist = character:getData("blacklist")

            if charWhitelist and not table.HasValue(charWhitelist, steamID) then
                return false -- Not whitelisted for this character
            end

            if charBlacklist and table.HasValue(charBlacklist, steamID) then
                return false -- Blacklisted from this character
            end

            -- Check faction restrictions
            local charFaction = character:getFaction()
            local factionData = lia.faction.get(charFaction)

            if factionData then
                -- Check faction whitelist
                if factionData.whitelist and not client:hasPrivilege("Bypass Faction Restrictions") then
                    if not table.HasValue(factionData.whitelist, steamID) then
                        return false -- Not whitelisted for faction
                    end
                end

                -- Check faction limits
                if factionData.limit then
                    local factionCount = 0
                    for _, ply in player.Iterator() do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == charFaction then
                            factionCount = factionCount + 1
                        end
                    end

                    if factionCount >= factionData.limit then
                        return false -- Faction limit reached
                    end
                end

                -- Check faction playtime requirements
                if factionData.playtimeRequired then
                    local playerPlaytime = client:getData("playtime", 0)
                    if playerPlaytime < factionData.playtimeRequired then
                        return false -- Insufficient playtime
                    end
                end
            end

            -- Check class restrictions
            local charClass = character:getClass()
            if charClass then
                local classData = lia.class.get(charClass)
                if classData then
                    -- Check class limits
                    if classData.limit then
                        local classCount = 0
                        for _, ply in player.Iterator() do
                            local plyChar = ply:getChar()
                            if plyChar and plyChar:getClass() == charClass then
                                classCount = classCount + 1
                            end
                        end

                        if classCount >= classData.limit then
                            return false -- Class limit reached
                        end
                    end
                end
            end

            -- Check character level requirements
            local minLevel = character:getData("minLevel", 0)
            local playerLevel = character:getLevel and character:getLevel() or 1

            if playerLevel < minLevel then
                return false -- Character requires higher level
            end

            -- Check reputation requirements
            local minRep = character:getData("minReputation", -10000)
            local playerRep = character:getData("reputation", 0)

            if playerRep < minRep then
                return false -- Insufficient reputation
            end

            -- Check time restrictions
            local currentTime = os.date("*t")
            local timeRestriction = character:getData("timeRestriction")

            if timeRestriction then
                local currentMinutes = currentTime.hour * 60 + currentTime.min
                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false -- Outside allowed hours
                end
            end

            -- Check character cooldown (can't switch too frequently)
            local lastUsed = character:getData("lastUsed", 0)
            local cooldown = character:getData("useCooldown", 0)

            if cooldown > 0 and (os.time() - lastUsed) < cooldown then
                return false -- Character on cooldown
            end

            -- Check server population limits for certain character types
            if character:getData("unique", false) then
                -- Unique characters can only be used by one player at a time
                for _, ply in player.Iterator() do
                    if ply:getChar() == character and ply ~= client then
                        return false -- Character already in use
                    end
                end
            end

            -- Check event/seasonal restrictions
            if character:getData("seasonal") then
                local currentMonth = currentTime.month
                if currentMonth ~= character:getData("seasonal") then
                    return false -- Not the right season
                end
            end

            -- Check prerequisite characters (must have used other chars first)
            local prerequisites = character:getData("prerequisites", {})
            for _, prereqID in ipairs(prerequisites) do
                local hasPrereq = false
                for _, charID in ipairs(client.liaCharList or {}) do
                    if charID == prereqID then
                        local prereqChar = lia.char.getCharacter(client, charID)
                        if prereqChar and prereqChar:getData("used", false) then
                            hasPrereq = true
                            break
                        end
                    end
                end

                if not hasPrereq then
                    return false -- Missing prerequisite character
                end
            end

            -- Update character usage data
            character:setData("lastUsed", os.time())
            character:setData("used", true)
            character:setData("useCount", character:getData("useCount", 0) + 1)

            -- Log character usage
            lia.log.add(client:Name() .. " selected character: " .. character:getName(), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerUseChar(client, character)
end

--[[
    Purpose:
        Determines if a player can use a command.

    When Called:
        When a player attempts to use a command.

    Parameters:
        client (Player)
            The player attempting to use the command.
        command (string)
            The command being used.

    Returns:
        boolean
            Whether the command can be used.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow commands
        function MODULE:CanPlayerUseCommand(client, command)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Admin-only commands
        function MODULE:CanPlayerUseCommand(client, command)
            if not IsValid(client) then return false end

            -- Admin-only commands
            local adminCommands = {
                "ban", "kick", "slay", "god", "noclip"
            }

            if table.HasValue(adminCommands, command) then
                return client:IsAdmin()
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced command permission system
        function MODULE:CanPlayerUseCommand(client, command)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive (some commands require living players)
            local requiresAlive = {
                "me", "it", "roll", "charflip", "fallover"
            }

            if table.HasValue(requiresAlive, command) and not client:Alive() then
                return false -- Dead players can't use emote commands
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                local restrictedForWanted = {
                    "advert", "broadcast", "radio"
                }

                if table.HasValue(restrictedForWanted, command) then
                    return false -- Wanted players can't use communication commands
                end
            end

            -- Check command cooldowns
            local lastUsed = client:getData("commandCooldowns", {})[command] or 0
            local cooldown = lia.config.get("commandCooldowns", {})[command] or 0

            if cooldown > 0 and (CurTime() - lastUsed) < cooldown then
                return false -- Command on cooldown
            end

            -- Check user group permissions
            local userGroup = client:GetUserGroup()
            local commandPermissions = lia.config.get("commandPermissions", {})

            if commandPermissions[command] then
                local allowedGroups = commandPermissions[command]
                if not table.HasValue(allowedGroups, userGroup) and not table.HasValue(allowedGroups, "*") then
                    return false -- User group not allowed
                end
            end

            -- Check character permissions
            if char:hasFlags("B") then -- Blocked flag prevents command usage
                return false
            end

            -- Check faction restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.restrictedCommands then
                if table.HasValue(faction.restrictedCommands, command) then
                    return false -- Faction can't use this command
                end
            end

            -- Check class restrictions
            local classID = char:getClass()
            if classID then
                local class = lia.class.get(classID)
                if class and class.restrictedCommands then
                    if table.HasValue(class.restrictedCommands, command) then
                        return false -- Class can't use this command
                    end
                end
            end

            -- Check flag requirements for specific commands
            local flagRequirements = lia.config.get("commandFlagRequirements", {})
            if flagRequirements[command] then
                local requiredFlag = flagRequirements[command]
                if not char:hasFlags(requiredFlag) then
                    return false -- Missing required flag
                end
            end

            -- Check level requirements
            local levelRequirements = lia.config.get("commandLevelRequirements", {})
            if levelRequirements[command] then
                local requiredLevel = levelRequirements[command]
                local playerLevel = char:getLevel and char:getLevel() or 1

                if playerLevel < requiredLevel then
                    return false -- Insufficient level
                end
            end

            -- Check reputation requirements
            local repRequirements = lia.config.get("commandRepRequirements", {})
            if repRequirements[command] then
                local requiredRep = repRequirements[command]
                local playerRep = char:getData("reputation", 0)

                if playerRep < requiredRep then
                    return false -- Insufficient reputation
                end
            end

            -- Check time restrictions
            local currentTime = os.date("*t")
            local timeRestrictions = lia.config.get("commandTimeRestrictions", {})

            if timeRestrictions[command] then
                local restriction = timeRestrictions[command]
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < restriction.start or currentMinutes > restriction.end then
                    return false -- Outside allowed hours
                end
            end

            -- Check location restrictions
            local pos = client:GetPos()
            local locationRestrictions = lia.config.get("commandLocationRestrictions", {})

            if locationRestrictions[command] then
                local allowedZones = locationRestrictions[command]
                local inAllowedZone = false

                for _, zone in ipairs(allowedZones) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        inAllowedZone = true
                        break
                    end
                end

                if not inAllowedZone then
                    return false -- Not in allowed location
                end
            end

            -- Check command usage limits per minute
            local usageLimits = lia.config.get("commandUsageLimits", {})
            if usageLimits[command] then
                local maxUses = usageLimits[command]
                local usageData = client:getData("commandUsage", {})
                local currentMinute = math.floor(CurTime() / 60)

                usageData[command] = usageData[command] or {}
                usageData[command][currentMinute] = (usageData[command][currentMinute] or 0) + 1

                if usageData[command][currentMinute] > maxUses then
                    return false -- Exceeded usage limit
                end

                client:setData("commandUsage", usageData)
            end

            -- Update command cooldown
            local cooldowns = client:getData("commandCooldowns", {})
            cooldowns[command] = CurTime()
            client:setData("commandCooldowns", cooldowns)

            -- Log command usage for moderation
            if lia.config.get("logCommands", {})[command] then
                lia.log.add(client:Name() .. " used command: " .. command, FLAG_NORMAL)
            end

            return true
        end
        ```
]]
function CanPlayerUseCommand(client, command)
end

--[[
    Purpose:
        Determines if a player can use a door.

    When Called:
        When a player attempts to use a door.

    Parameters:
        client (Player)
            The player attempting to use the door.
        door (Entity)
            The door being used.

    Returns:
        boolean
            Whether the door can be used.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow door usage
        function MODULE:CanPlayerUseDoor(client, door)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic ownership and access checks
        function MODULE:CanPlayerUseDoor(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check ownership
            if door:getNetVar("owner") == client then
                return true -- Owner can always use door
            end

            -- Check faction access
            local doorFaction = door:getNetVar("faction")
            if doorFaction and char:getFaction() == doorFaction then
                return true -- Faction members can use faction doors
            end

            -- Check if door is locked
            if door:getNetVar("locked", false) then
                return false -- Can't use locked doors
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door usage system with comprehensive permissions
        function MODULE:CanPlayerUseDoor(client, door)
            if not IsValid(client) or not IsValid(door) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't use doors
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't use doors
            end

            -- Check distance
            local distance = client:GetPos():Distance(door:GetPos())
            local maxDistance = lia.config.get("maxDoorUseDistance", 120)

            if distance > maxDistance then
                return false -- Too far from door
            end

            -- Check line of sight
            local trace = util.TraceLine({
                start = client:EyePos(),
                endpos = door:GetPos() + Vector(0, 0, 50),
                filter = {client, door}
            })

            if trace.Hit then
                return false -- No line of sight to door
            end

            -- Check ownership first
            local owner = door:getNetVar("owner")
            if owner == client then
                return true -- Owner can always use their door
            end

            -- Check if door is disabled
            if door:getNetVar("disabled", false) then
                return false -- Door is disabled
            end

            -- Check if door is locked
            if door:getNetVar("locked", false) then
                return false -- Can't use locked doors
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction then
                local playerFaction = char:getFaction()

                if playerFaction == doorFaction then
                    -- Check faction rank requirements
                    local requiredRank = door:getNetVar("factionRankRequired", 0)
                    local playerRank = char:getData("factionRank", 0)

                    if playerRank >= requiredRank then
                        return true
                    end
                end

                -- Check allied faction access
                local factionData = lia.faction.get(playerFaction)
                if factionData and factionData.allies then
                    for _, allyFaction in ipairs(factionData.allies) do
                        if allyFaction == doorFaction then
                            local alliedAccess = door:getNetVar("allowAlliedAccess", true)
                            if alliedAccess then
                                return true
                            end
                        end
                    end
                end
            end

            -- Check class permissions
            local doorClass = door:getNetVar("classRestriction")
            if doorClass and char:getClass() == doorClass then
                return true -- Class members can use class doors
            end

            -- Check shared access permissions
            local sharedUsers = door:getNetVar("sharedUsers", {})
            if table.HasValue(sharedUsers, char:getID()) then
                local sharedAccess = door:getNetVar("sharedAccessEnabled", true)
                if sharedAccess then
                    return true
                end
            end

            -- Check flag requirements
            local requiredFlags = door:getNetVar("requiredFlags")
            if requiredFlags then
                for _, flag in ipairs(requiredFlags) then
                    if not char:hasFlags(flag) then
                        return false
                    end
                end
                return true -- Has all required flags
            end

            -- Check reputation requirements
            local minRep = door:getNetVar("minReputation", 0)
            local playerRep = char:getData("reputation", 0)

            if playerRep < minRep then
                return false -- Insufficient reputation
            end

            -- Check level requirements
            local minLevel = door:getNetVar("minLevel", 0)
            local playerLevel = char:getLevel and char:getLevel() or 1

            if playerLevel < minLevel then
                return false -- Insufficient level
            end

            -- Check time restrictions
            local timeRestriction = door:getNetVar("timeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false -- Outside allowed hours
                end
            end

            -- Check door usage cooldown
            local lastUsed = door:getNetVar("lastUsed", 0)
            local cooldown = door:getNetVar("useCooldown", 0)

            if cooldown > 0 and (CurTime() - lastUsed) < cooldown then
                return false -- Door on cooldown
            end

            -- Check door health/durability
            local doorHealth = door:getNetVar("health", 100)
            if doorHealth <= 0 then
                return false -- Door is broken
            end

            -- Check if door is being used by someone else
            if door:getNetVar("inUse", false) then
                return false -- Door is currently in use
            end

            -- Check location restrictions (certain doors may only be usable in specific areas)
            local pos = door:GetPos()
            local restrictedZones = door:getNetVar("restrictedZones")
            if restrictedZones then
                local inRestrictedZone = false
                for _, zone in ipairs(restrictedZones) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        inRestrictedZone = true
                        break
                    end
                end
                if inRestrictedZone then
                    return false -- Door is in restricted zone
                end
            end

            -- Update door usage data
            door:setNetVar("lastUsed", CurTime())
            door:setNetVar("useCount", door:getNetVar("useCount", 0) + 1)

            -- Log door usage
            lia.log.add(client:Name() .. " used door: " .. (door:EntIndex() or "unknown"), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerUseDoor(client, door)
end

--[[
    Purpose:
        Determines if an item action can be run.

    When Called:
        When attempting to execute an item action.

    Parameters:
        itemTable (table)
            The item table.
        action (string)
            The action to run.

    Returns:
        boolean
            Whether the action can be run.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow item actions
        function MODULE:CanRunItemAction(itemTable, action)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic action restrictions
        function MODULE:CanRunItemAction(itemTable, action)
            if not itemTable then return false end

            -- Don't allow certain actions on stackable items
            if action == "use" and itemTable.maxQuantity and itemTable.maxQuantity > 1 then
                return false -- Can't use stackable items individually
            end

            -- Don't allow drop action on equipped items
            if action == "drop" and itemTable:getData("equip", false) then
                return false -- Must unequip first
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item action system with comprehensive restrictions
        function MODULE:CanRunItemAction(itemTable, action)
            if not itemTable then return false end

            local itemOwner = itemTable:getOwner()
            if not IsValid(itemOwner) then return false end

            local char = itemOwner:getChar()
            if not char then return false end

            -- Check if player is alive
            if not itemOwner:Alive() then
                return false -- Dead players can't perform item actions
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                local restrictedActions = {"use", "equip", "consume"}
                if table.HasValue(restrictedActions, action) then
                    return false -- Wanted players can't use certain items
                end
            end

            -- Check if player is restrained
            if char:getData("restrained", false) then
                return false -- Restrained players can't perform actions
            end

            -- Action-specific validations
            if action == "use" then
                -- Check item durability
                if itemTable:getData("durability", 100) <= 0 then
                    return false -- Item is broken
                end

                -- Check if item requires specific conditions to use
                if itemTable.useRequirements then
                    for requirement, value in pairs(itemTable.useRequirements) do
                        if requirement == "level" and char:getLevel and char:getLevel() < value then
                            return false
                        elseif requirement == "skill" and char:getAttrib(value.skill, 0) < value.level then
                            return false
                        end
                    end
                end

                -- Check use cooldown
                local lastUsed = itemTable:getData("lastUsed", 0)
                local cooldown = itemTable:getData("useCooldown", 0)

                if cooldown > 0 and (CurTime() - lastUsed) < cooldown then
                    return false
                end

            elseif action == "equip" then
                -- Check if item is already equipped
                if itemTable:getData("equip", false) then
                    return false -- Already equipped
                end

                -- Check equipment slot availability
                if itemTable.slot then
                    local inventory = char:getInv()
                    if inventory then
                        for _, invItem in pairs(inventory:getItems()) do
                            if invItem:getData("equip", false) and invItem.slot == itemTable.slot then
                                return false -- Slot already occupied
                            end
                        end
                    end
                end

                -- Check faction/class restrictions
                if itemTable.factionRequired and itemTable.factionRequired ~= char:getFaction() then
                    return false
                end

                if itemTable.classRequired and itemTable.classRequired ~= char:getClass() then
                    return false
                end

            elseif action == "drop" then
                -- Check if item is equipped
                if itemTable:getData("equip", false) then
                    return false -- Must unequip first
                end

                -- Check if item is soulbound
                if itemTable:getData("soulbound", false) then
                    return false -- Soulbound items can't be dropped
                end

                -- Check if dropping is allowed in current location
                local pos = itemOwner:GetPos()
                local noDropZones = lia.config.get("noDropZones", {})

                for _, zone in ipairs(noDropZones) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        return false -- Cannot drop items here
                    end
                end

            elseif action == "consume" then
                -- Check if item is consumable
                if not itemTable.consumable then
                    return false -- Not a consumable item
                end

                -- Check consumption restrictions (hunger, health, etc.)
                if itemTable.consumptionRequirements then
                    for req, value in pairs(itemTable.consumptionRequirements) do
                        if req == "maxHunger" and itemOwner:getHunger and itemOwner:getHunger() >= value then
                            return false -- Not hungry enough
                        elseif req == "maxHealth" and itemOwner:Health() >= value then
                            return false -- Health too high
                        end
                    end
                end

            elseif action == "combine" then
                -- Check if combination is allowed
                if not itemTable.canCombine then
                    return false -- Item cannot be combined
                end

                -- Check if player has required secondary items
                if itemTable.combineRequirements then
                    local inventory = char:getInv()
                    if inventory then
                        for _, req in ipairs(itemTable.combineRequirements) do
                            local hasItem = false
                            for _, invItem in pairs(inventory:getItems()) do
                                if invItem.uniqueID == req.item and invItem:getQuantity() >= req.quantity then
                                    hasItem = true
                                    break
                                end
                            end
                            if not hasItem then
                                return false -- Missing required item
                            end
                        end
                    end
                end

            elseif action == "custom" then
                -- Custom actions have their own validation logic
                if itemTable.customActionCheck then
                    return itemTable:customActionCheck(itemOwner, char)
                end
            end

            -- Check item ownership
            if itemTable:getOwner() ~= itemOwner then
                return false -- Can't perform actions on others' items
            end

            -- Check flag requirements
            if itemTable.flagRequired and not char:hasFlags(itemTable.flagRequired) then
                return false
            end

            -- Check level requirements for action
            if itemTable.actionLevelRequired and itemTable.actionLevelRequired[action] then
                local requiredLevel = itemTable.actionLevelRequired[action]
                local playerLevel = char:getLevel and char:getLevel() or 1

                if playerLevel < requiredLevel then
                    return false
                end
            end

            -- Check reputation requirements
            if itemTable.reputationRequired then
                local playerRep = char:getData("reputation", 0)
                if playerRep < itemTable.reputationRequired then
                    return false
                end
            end

            -- Check environmental restrictions
            if itemTable.noActionUnderwater and itemOwner:WaterLevel() > 0 then
                return false -- Cannot perform action underwater
            end

            -- Check time restrictions
            if itemTable.actionTimeRestrictions and itemTable.actionTimeRestrictions[action] then
                local currentTime = os.date("*t")
                local restrictions = itemTable.actionTimeRestrictions[action]
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                    return false -- Outside allowed hours
                end
            end

            -- Check curse status
            if itemTable:getData("cursed", false) and not char:getData("curseImmunity", false) then
                if action == "use" or action == "equip" then
                    return false -- Can't safely perform these actions
                end
            end

            -- Update action timestamp for cooldowns
            if action == "use" then
                itemTable:setData("lastUsed", CurTime())
            end

            -- Log item action for security
            lia.log.add(itemOwner:Name() .. " performed " .. action .. " on " .. itemTable.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanRunItemAction(itemTable, action)
end

--[[
    Purpose:
        Determines if entity data can be saved.

    When Called:
        When attempting to save entity data.

    Parameters:
        entity (Entity)
            The entity being saved.
        inventory (Inventory)
            The entity's inventory.

    Returns:
        boolean
            Whether the data can be saved.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow data saving
        function MODULE:CanSaveData(entity, inventory)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic entity type restrictions
        function MODULE:CanSaveData(entity, inventory)
            if not IsValid(entity) then return false end

            -- Only save data for certain entity types
            local allowedClasses = {
                "lia_vendor",
                "lia_container",
                "lia_storage",
                "lia_door"
            }

            return table.HasValue(allowedClasses, entity:GetClass())
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced data saving with comprehensive validations
        function MODULE:CanSaveData(entity, inventory)
            if not IsValid(entity) then return false end

            -- Check entity ownership
            local owner = entity:getNetVar("owner")
            if not IsValid(owner) then
                -- Allow saving unowned public entities
                if not entity:getNetVar("public", false) then
                    return false
                end
            else
                -- Check if owner has permission to save data
                local char = owner:getChar()
                if not char then return false end

                -- Check faction restrictions (some factions can't save certain entities)
                local entityFaction = entity:getNetVar("faction")
                if entityFaction then
                    local factionData = lia.faction.get(entityFaction)
                    if factionData and factionData.noDataSaving then
                        return false -- Faction cannot save entity data
                    end

                    -- Check if player belongs to the faction
                    if char:getFaction() ~= entityFaction then
                        return false -- Can't save data for other faction's entities
                    end
                end

                -- Check class restrictions
                local entityClassRestriction = entity:getNetVar("classRestriction")
                if entityClassRestriction and char:getClass() ~= entityClassRestriction then
                    return false
                end

                -- Check flag requirements
                local requiredFlags = entity:getNetVar("saveDataFlags")
                if requiredFlags then
                    for _, flag in ipairs(requiredFlags) do
                        if not char:hasFlags(flag) then
                            return false
                        end
                    end
                end
            end

            -- Check entity type restrictions
            local class = entity:GetClass()
            local allowedClasses = lia.config.get("saveableEntityClasses", {
                "lia_vendor",
                "lia_container",
                "lia_storage",
                "lia_door",
                "prop_physics"
            })

            if not table.HasValue(allowedClasses, class) then
                return false
            end

            -- Check entity health/durability (don't save destroyed entities)
            local health = entity:Health()
            local maxHealth = entity:GetMaxHealth()

            if health <= 0 or (maxHealth > 0 and health/maxHealth < 0.1) then
                return false -- Entity is too damaged to save
            end

            -- Check entity location (don't save in restricted areas)
            local pos = entity:GetPos()
            local restrictedZones = lia.config.get("dataSaveRestrictedZones", {})

            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Cannot save data in restricted zones
                end
            end

            -- Check if entity is in a no-save zone (temporary areas)
            local noSaveZones = lia.config.get("noDataSaveZones", {})
            for _, zone in ipairs(noSaveZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Entity is in a temporary area
                end
            end

            -- Check inventory contents (don't save if inventory has restricted items)
            if inventory then
                local restrictedItems = lia.config.get("restrictedSaveItems", {})
                for _, item in pairs(inventory:getItems()) do
                    if table.HasValue(restrictedItems, item.uniqueID) then
                        return false -- Contains restricted item
                    end

                    -- Check item quantities (prevent save scamming with stacked items)
                    if item:getQuantity() > lia.config.get("maxSaveItemQuantity", 100) then
                        return false -- Too many items of this type
                    end
                end

                -- Check total inventory value (expensive inventories might not be savable)
                local totalValue = 0
                for _, item in pairs(inventory:getItems()) do
                    totalValue = totalValue + (item.price or 0) * item:getQuantity()
                end

                if totalValue > lia.config.get("maxSaveInventoryValue", 10000) then
                    return false -- Inventory too valuable to save
                end
            end

            -- Check entity age (don't save very new entities to prevent spam)
            local creationTime = entity:getNetVar("creationTime", 0)
            local minAge = lia.config.get("minEntityAgeForSaving", 60) -- 1 minute

            if (CurTime() - creationTime) < minAge then
                return false -- Entity too new to save
            end

            -- Check server performance (don't save too many entities)
            local currentSavedEntities = lia.data.get("savedEntityCount", 0)
            local maxSavedEntities = lia.config.get("maxSavedEntities", 1000)

            if currentSavedEntities >= maxSavedEntities then
                return false -- Server entity limit reached
            end

            -- Check if entity is currently in use
            if entity:getNetVar("inUse", false) then
                return false -- Don't save while entity is being used
            end

            -- Check for duplicate saves (prevent spam saving)
            local lastSave = entity:getNetVar("lastDataSave", 0)
            local saveCooldown = lia.config.get("entitySaveCooldown", 300) -- 5 minutes

            if (CurTime() - lastSave) < saveCooldown then
                return false -- Entity saved too recently
            end

            -- Check special conditions (events, etc.)
            if entity:getNetVar("eventOnly", false) then
                if not lia.config.get("eventMode", false) then
                    return false -- Only save during events
                end
            end

            -- Update save timestamp
            entity:setNetVar("lastDataSave", CurTime())

            -- Increment saved entity counter
            lia.data.set("savedEntityCount", currentSavedEntities + 1)

            -- Log data saving for security
            lia.log.add("Entity data saved: " .. class .. " at " .. tostring(pos), FLAG_NORMAL)

            return true
        end
        ```
]]
function CanSaveData(entity, inventory)
end

--[[
    Purpose:
        Handles character cleanup when deleted or unloaded.

    When Called:
        When a character is being cleaned up.

    Parameters:
        character (Character)
            The character being cleaned up.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic cleanup logging
        function MODULE:CharCleanUp(character)
            print("Character cleaned up: " .. character:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove character-related entities
        function MODULE:CharCleanUp(character)
            -- Remove any entities owned by this character
            for _, ent in ipairs(ents.GetAll()) do
                if ent:getNetVar("owner") == character:getPlayer() then
                    -- Only remove certain types of entities
                    if ent:GetClass():find("lia_") then
                        ent:Remove()
                    end
                end
            end

            -- Log cleanup
            lia.log.add("Character cleaned up: " .. character:getName(), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive character cleanup system
        function MODULE:CharCleanUp(character)
            local player = character:getPlayer()
            local steamID = IsValid(player) and player:SteamID() or "unknown"

            -- Clean up owned entities
            local entitiesCleaned = 0
            for _, ent in ipairs(ents.GetAll()) do
                if ent:getNetVar("owner") == player then
                    local class = ent:GetClass()

                    -- Remove persistent entities owned by this character
                    if ent:getNetVar("persistent", false) and
                       table.HasValue(lia.config.get("cleanupEntityClasses", {"lia_vendor", "lia_container", "lia_storage"}), class) then

                        -- Save entity data before removal if needed
                        if ent:getNetVar("saveOnCleanup", true) then
                            self:SaveEntityData(ent)
                        end

                        ent:Remove()
                        entitiesCleaned = entitiesCleaned + 1
                    end
                end
            end

            -- Clean up active timers related to this character
            local charID = character:getID()
            if timer.Exists("CharTimer_" .. charID) then
                timer.Remove("CharTimer_" .. charID)
            end

            -- Clean up character-specific data
            character:setData("cleanupTime", os.time())
            character:setData("lastLocation", IsValid(player) and player:GetPos() or Vector(0, 0, 0))

            -- Remove character from any active factions/classes if needed
            if character:getFaction() then
                local faction = lia.faction.get(character:getFaction())
                if faction and faction.onCharCleanup then
                    faction:onCharCleanup(character)
                end
            end

            if character:getClass() then
                local class = lia.class.get(character:getClass())
                if class and class.onCharCleanup then
                    class:onCharCleanup(character)
                end
            end

            -- Clean up inventory items that require cleanup
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if item.onCharCleanup then
                        item:onCharCleanup(character)
                    end

                    -- Remove temporary items
                    if item:getData("temporary", false) then
                        item:remove()
                    end
                end
            end

            -- Clean up character flags and permissions
            local flagsToRemove = character:getData("cleanupFlags", {})
            for _, flag in ipairs(flagsToRemove) do
                character:takeFlags(flag)
            end

            -- Remove character from any active quests
            local activeQuests = character:getData("activeQuests", {})
            for questID, questData in pairs(activeQuests) do
                -- Clean up quest-specific data
                if questData.cleanupRequired then
                    self:CleanupQuestData(character, questID, questData)
                end
            end

            -- Clean up character relationships (friends, enemies, etc.)
            local relationships = character:getData("relationships", {})
            for targetID, relationData in pairs(relationships) do
                if relationData.cleanupOnCharDelete then
                    relationships[targetID] = nil
                end
            end
            character:setData("relationships", relationships)

            -- Remove character from any group memberships
            local groups = character:getData("groups", {})
            for groupID, _ in pairs(groups) do
                self:RemoveFromGroup(character, groupID)
            end

            -- Clean up any active effects or buffs
            local activeEffects = character:getData("activeEffects", {})
            for effectID, effectData in pairs(activeEffects) do
                if effectData.cleanupOnCharDelete then
                    activeEffects[effectID] = nil
                    -- Remove any associated timers or hooks
                    if effectData.timerName then
                        timer.Remove(effectData.timerName)
                    end
                end
            end
            character:setData("activeEffects", activeEffects)

            -- Log comprehensive cleanup
            lia.log.add(string.format("Character cleanup completed - Name: %s, SteamID: %s, Entities cleaned: %d",
                character:getName(), steamID, entitiesCleaned), FLAG_NORMAL)

            -- Send notification to player if online
            if IsValid(player) then
                player:notify("Your character '" .. character:getName() .. "' has been cleaned up.")
            end

            -- Trigger any post-cleanup events
            hook.Run("OnCharCleanupComplete", character, entitiesCleaned)
        end

        -- Helper function to save entity data before cleanup
        function MODULE:SaveEntityData(entity)
            if not IsValid(entity) then return end

            local entityData = {
                class = entity:GetClass(),
                pos = entity:GetPos(),
                ang = entity:GetAngles(),
                model = entity:GetModel(),
                color = entity:GetColor(),
                material = entity:GetMaterial(),
                netVars = {}
            }

            -- Save important net vars
            for key, value in pairs(entity:getNetVars()) do
                if not table.HasValue({"owner", "creationTime"}, key) then -- Don't save ownership data
                    entityData.netVars[key] = value
                end
            end

            -- Save inventory if it exists
            if entity.getInv then
                local inventory = entity:getInv()
                if inventory then
                    entityData.inventory = {}
                    for _, item in pairs(inventory:getItems()) do
                        table.insert(entityData.inventory, {
                            uniqueID = item.uniqueID,
                            quantity = item:getQuantity(),
                            data = item:getData()
                        })
                    end
                end
            end

            -- Store in character data for potential restoration
            local owner = entity:getNetVar("owner")
            if IsValid(owner) then
                local char = owner:getChar()
                if char then
                    local savedEntities = char:getData("savedEntities", {})
                    table.insert(savedEntities, entityData)
                    char:setData("savedEntities", savedEntities)
                end
            end
        end

        -- Helper function to cleanup quest data
        function MODULE:CleanupQuestData(character, questID, questData)
            -- Remove quest-related entities
            if questData.entities then
                for _, entID in ipairs(questData.entities) do
                    local ent = ents.GetByIndex(entID)
                    if IsValid(ent) then
                        ent:Remove()
                    end
                end
            end

            -- Clean up quest timers
            if questData.timers then
                for _, timerName in ipairs(questData.timers) do
                    timer.Remove(timerName)
                end
            end

            -- Log quest cleanup
            lia.log.add("Quest cleanup for character " .. character:getName() .. ": " .. questID, FLAG_NORMAL)
        end

        -- Helper function to remove character from groups
        function MODULE:RemoveFromGroup(character, groupID)
            local groupData = lia.data.get("groups", {})[groupID]
            if groupData and groupData.members then
                for i, memberID in ipairs(groupData.members) do
                    if memberID == character:getID() then
                        table.remove(groupData.members, i)
                        break
                    end
                end

                -- If group is now empty, remove it entirely
                if #groupData.members == 0 then
                    lia.data.delete("groups", groupID)
                else
                    lia.data.set("groups", groupID, groupData)
                end
            end
        end
        ```
]]
function CharCleanUp(character)
end

--[[
    Purpose:
        Called when a character is loaded from the database.

    When Called:
        When a character is successfully loaded and becomes active.

    Parameters:
        characterID (number)
            The ID of the loaded character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character loading
        function MODULE:CharLoaded(characterID)
            print("Character loaded with ID: " .. characterID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize character data and setup auto-save
        function MODULE:CharLoaded(characterID)
            -- Get the character object
            lia.char.getCharacter(characterID, nil, function(character)
                if not character then return end

                local client = character:getPlayer()
                if not IsValid(client) then return end

                -- Initialize character-specific data
                character:setData("lastLogin", os.time())

                -- Log character loading
                lia.log.add(client:Name() .. " loaded character: " .. character:getName(), FLAG_NORMAL)

                -- Setup any character-specific timers or effects
                self:InitializeCharacterEffects(character)
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive character loading with validation and initialization
        function MODULE:CharLoaded(characterID)
            lia.char.getCharacter(characterID, nil, function(character)
                if not character then
                    lia.log.add("Failed to load character with ID: " .. characterID, FLAG_WARNING)
                    return
                end

                local client = character:getPlayer()
                if not IsValid(client) then return end

                -- Validate character data integrity
                local validationResult = self:ValidateCharacterData(character)
                if not validationResult.valid then
                    lia.log.add("Character data validation failed for " .. character:getName() .. ": " .. validationResult.error, FLAG_ERROR)
                    client:notify("Your character data appears to be corrupted. Please contact an administrator.")
                    return
                end

                -- Initialize character statistics
                character:setData("loginCount", (character:getData("loginCount") or 0) + 1)
                character:setData("lastLogin", os.time())
                character:setData("lastLoginIP", client:IPAddress())

                -- Load character-specific configurations
                self:LoadCharacterConfig(character)

                -- Initialize faction-specific data
                if character:getFaction() then
                    local faction = lia.faction.get(character:getFaction())
                    if faction and faction.onCharLoaded then
                        faction:onCharLoaded(character, client)
                    end
                end

                -- Initialize class-specific data
                if character:getClass() then
                    local class = lia.class.get(character:getClass())
                    if class and class.onCharLoaded then
                        class:onCharLoaded(character, client)
                    end
                end

                -- Setup character timers (auto-save, etc.)
                self:SetupCharacterTimers(character)

                -- Load and apply any active effects
                self:LoadActiveEffects(character)

                -- Update character playtime
                local playTime = character:getData("playTime", 0)
                character:setData("playTime", playTime)

                -- Start playtime tracking
                self:StartPlaytimeTracking(character)

                -- Log successful character loading
                lia.log.add(string.format("Character loaded - Player: %s (%s), Character: %s (ID: %d), Faction: %s, Class: %s",
                    client:Name(),
                    client:SteamID(),
                    character:getName(),
                    character:getID(),
                    character:getFaction() or "None",
                    character:getClass() or "None"), FLAG_NORMAL)

                -- Send character loaded notification
                hook.Run("OnCharacterLoaded", client, character)
            end)
        end

        -- Helper function to validate character data
        function MODULE:ValidateCharacterData(character)
            -- Basic validation checks
            if not character:getName() or character:getName() == "" then
                return {valid = false, error = "Invalid character name"}
            end

            if not character:getFaction() then
                return {valid = false, error = "No faction assigned"}
            end

            -- Check for required data fields
            local requiredFields = {"money", "health"}
            for _, field in ipairs(requiredFields) do
                if character:getData(field) == nil then
                    return {valid = false, error = "Missing required data field: " .. field}
                end
            end

            return {valid = true}
        end
        ```
]]
function CharLoaded(characterID)
end

--[[
    Purpose:
        Called when a character is deleted.

    When Called:
        After a character is deleted from the database.

    Parameters:
        client (Player)
            The player whose character was deleted.
        character (Character)
            The deleted character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character deletion
        function MODULE:CharDeleted(client, character)
            lia.log.add(client:Name() .. " deleted character: " .. character:getName(), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Notify player and update statistics
        function MODULE:CharDeleted(client, character)
            -- Notify the player
            if IsValid(client) then
                client:notify("Character '" .. character:getName() .. "' has been deleted.")
            end

            -- Update deletion statistics
            local deletions = lia.data.get("characterDeletions", 0) + 1
            lia.data.set("characterDeletions", deletions)

            -- Log the deletion
            lia.log.add(client:Name() .. " (" .. client:SteamID() .. ") deleted character: " ..
                character:getName() .. " (ID: " .. character:getID() .. ")", FLAG_WARNING)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive character deletion handling
        function MODULE:CharDeleted(client, character)
            local steamID = IsValid(client) and client:SteamID() or "unknown"
            local charName = character:getName()
            local charID = character:getID()

            -- Log deletion with detailed information
            lia.log.add(string.format("Character deletion - Player: %s (%s), Character: %s (ID: %d), Faction: %s, Class: %s",
                IsValid(client) and client:Name() or "Unknown",
                steamID,
                charName,
                charID,
                character:getFaction() or "None",
                character:getClass() or "None"), FLAG_WARNING)

            -- Update global statistics
            local stats = lia.data.get("characterStats", {})
            stats.totalDeletions = (stats.totalDeletions or 0) + 1
            stats.lastDeletion = os.time()
            lia.data.set("characterStats", stats)

            -- Update player-specific statistics
            if IsValid(client) then
                local playerStats = client:getData("characterStats", {})
                playerStats.deletions = (playerStats.deletions or 0) + 1
                playerStats.lastDeletion = os.time()
                playerStats.lastDeletedChar = charName
                client:setData("characterStats", playerStats)

                -- Notify the player
                client:notify(L("characterDeleted", {name = charName}))
            end

            -- Handle faction-specific deletion logic
            if character:getFaction() then
                local faction = lia.faction.get(character:getFaction())
                if faction and faction.onCharDeleted then
                    faction:onCharDeleted(character, client)
                end

                -- Update faction statistics
                local factionStats = lia.data.get("factionStats", {})[character:getFaction()] or {}
                factionStats.deletions = (factionStats.deletions or 0) + 1
                lia.data.set("factionStats", factionStats)
            end

            -- Handle class-specific deletion logic
            if character:getClass() then
                local class = lia.class.get(character:getClass())
                if class and class.onCharDeleted then
                    class:onCharDeleted(character, client)
                end
            end

            -- Clean up any remaining references to this character
            self:CleanupCharacterReferences(character)

            -- Handle any active quests this character had
            local activeQuests = character:getData("activeQuests", {})
            for questID, questData in pairs(activeQuests) do
                -- Notify quest system of character deletion
                hook.Run("OnQuestCharacterDeleted", questID, character, client)

                -- Clean up quest data
                self:CleanupQuestOnCharDelete(questID, character)
            end

            -- Handle character relationships
            self:UpdateCharacterRelationships(character)

            -- Archive character data for potential recovery
            if lia.config.get("archiveDeletedCharacters", true) then
                self:ArchiveCharacterData(character, client)
            end

            -- Remove character from any active groups or organizations
            self:RemoveCharacterFromGroups(character)

            -- Handle any items that were bound to this character
            self:HandleSoulboundItems(character)

            -- Update server-wide character counts
            local serverStats = lia.data.get("serverCharacterStats", {})
            serverStats.totalCharacters = (serverStats.totalCharacters or 0) - 1
            serverStats.deletedCharacters = (serverStats.deletedCharacters or 0) + 1
            lia.data.set("serverCharacterStats", serverStats)

            -- Check if this triggers any server events
            self:CheckDeletionTriggers(character, client)

            -- Notify administrators of character deletion
            for _, ply in player.Iterator() do
                if ply:hasPrivilege("Staff Permissions") then
                    ply:notify("Character deleted: " .. charName .. " by " .. (IsValid(client) and client:Name() or "Unknown"))
                end
            end

            -- Trigger any post-deletion hooks
            hook.Run("OnCharDeletedComplete", client, character)

            -- Discord webhook notification for character deletions
            if lia.config.get("discordWebhookURL") and lia.config.get("logCharacterDeletions", true) then
                local embed = {
                    title = "Character Deleted",
                    description = string.format("**Player:** %s\n**SteamID:** %s\n**Character:** %s\n**Faction:** %s\n**Class:** %s",
                        IsValid(client) and client:Name() or "Unknown",
                        steamID,
                        charName,
                        character:getFaction() or "None",
                        character:getClass() or "None"),
                    color = 0xFF0000, -- Red
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
                }
                hook.Run("DiscordRelaySend", embed)
            end
        end

        -- Helper function to cleanup character references
        function MODULE:CleanupCharacterReferences(character)
            -- Remove from any caches or lookup tables
            if lia.char.characters then
                lia.char.characters[character:getID()] = nil
            end

            -- Clean up any timers associated with this character
            local charID = character:getID()
            for _, timerName in ipairs(timer.GetAll()) do
                if timerName:find("Char" .. charID) or timerName:find(tostring(charID)) then
                    timer.Remove(timerName)
                end
            end

            -- Remove from any active player lists
            for _, ply in player.Iterator() do
                if ply:getChar() and ply:getChar():getID() == charID then
                    ply:setNetVar("liaChar", nil)
                    break
                end
            end
        end

        -- Helper function to cleanup quest data on character deletion
        function MODULE:CleanupQuestOnCharDelete(questID, character)
            local questData = lia.data.get("quests", {})[questID]
            if questData then
                -- Remove character from quest participants
                if questData.participants then
                    questData.participants[character:getID()] = nil

                    -- If no participants left, cancel the quest
                    if table.Count(questData.participants) == 0 then
                        questData.status = "cancelled"
                        questData.cancelledBy = "character_deletion"
                        questData.cancelledTime = os.time()
                    end
                end

                lia.data.set("quests", questID, questData)
            end
        end

        -- Helper function to update character relationships
        function MODULE:UpdateCharacterRelationships(deletedChar)
            -- Get all characters and update their relationships
            local allChars = lia.char.getAll()
            for _, char in pairs(allChars) do
                local relationships = char:getData("relationships", {})
                if relationships[deletedChar:getID()] then
                    relationships[deletedChar:getID()] = nil
                    char:setData("relationships", relationships)
                end
            end
        end

        -- Helper function to archive character data
        function MODULE:ArchiveCharacterData(character, client)
            local archiveData = {
                characterID = character:getID(),
                name = character:getName(),
                steamID = IsValid(client) and client:SteamID() or "unknown",
                faction = character:getFaction(),
                class = character:getClass(),
                money = character:getMoney(),
                playTime = character:getPlayTime(),
                created = character:getData("created"),
                deleted = os.time(),
                inventory = {},
                data = character:getData()
            }

            -- Archive inventory
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    table.insert(archiveData.inventory, {
                        uniqueID = item.uniqueID,
                        name = item.name,
                        quantity = item:getQuantity(),
                        data = item:getData()
                    })
                end
            end

            -- Store in archived characters
            local archived = lia.data.get("archivedCharacters", {})
            archived[character:getID()] = archiveData
            lia.data.set("archivedCharacters", archived)

            lia.log.add("Character data archived: " .. character:getName(), FLAG_NORMAL)
        end

        -- Helper function to remove character from groups
        function MODULE:RemoveCharacterFromGroups(character)
            local groups = lia.data.get("groups", {})
            for groupID, groupData in pairs(groups) do
                if groupData.members then
                    for i, memberID in ipairs(groupData.members) do
                        if memberID == character:getID() then
                            table.remove(groupData.members, i)
                            break
                        end
                    end

                    -- Remove empty groups
                    if #groupData.members == 0 then
                        groups[groupID] = nil
                    end
                end
            end
            lia.data.set("groups", groups)
        end

        -- Helper function to handle soulbound items
        function MODULE:HandleSoulboundItems(character)
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if item:getData("soulbound", false) then
                        -- Soulbound items are destroyed when character is deleted
                        lia.log.add("Soulbound item destroyed: " .. item.name .. " (Character: " .. character:getName() .. ")", FLAG_WARNING)
                        item:remove()
                    end
                end
            end
        end

        -- Helper function to check deletion triggers
        function MODULE:CheckDeletionTriggers(character, client)
            -- Check if this deletion triggers any server events
            local triggers = lia.config.get("deletionTriggers", {})

            for _, trigger in ipairs(triggers) do
                if trigger.condition == "character_deleted" then
                    if trigger.faction and trigger.faction == character:getFaction() then
                        -- Execute trigger action
                        self:ExecuteTriggerAction(trigger.action, character, client)
                    end
                end
            end
        end

        -- Helper function to execute trigger actions
        function MODULE:ExecuteTriggerAction(action, character, client)
            if action.type == "notify_staff" then
                for _, ply in player.Iterator() do
                    if ply:hasPrivilege("Staff Permissions") then
                        ply:notify("Character deletion trigger activated: " .. character:getName())
                    end
                end
            elseif action.type == "log_event" then
                lia.log.add("Deletion trigger activated for character: " .. character:getName(), FLAG_WARNING)
            elseif action.type == "discord_webhook" then
                -- Send Discord notification
                local embed = {
                    title = "Character Deletion Trigger",
                    description = "A character deletion has triggered an event notification.",
                    color = 0xFFA500,
                    fields = {
                        {name = "Character", value = character:getName(), inline = true},
                        {name = "Player", value = IsValid(client) and client:Name() or "Unknown", inline = true}
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
                }
                hook.Run("DiscordRelaySend", embed)
            end
        end
        ```
]]
function CharDeleted(client, character)
end

--[[
    Purpose:
        Called after a character is saved to the database.

    When Called:
        After character data has been successfully saved.

    Parameters:
        character (Character)
            The character that was saved.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character saves
        function MODULE:CharPostSave(character)
            print("Character saved: " .. character:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update save statistics and notify player
        function MODULE:CharPostSave(character)
            -- Update save count
            local saves = character:getData("saveCount", 0) + 1
            character:setData("saveCount", saves)

            -- Notify player of successful save
            local client = character:getPlayer()
            if IsValid(client) then
                client:notify("Character data saved successfully.")
            end

            -- Log the save
            lia.log.add("Character saved: " .. character:getName(), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive post-save processing with backups and analytics
        function MODULE:CharPostSave(character)
            local client = character:getPlayer()
            local currentTime = os.time()

            -- Update save statistics
            local saveStats = character:getData("saveStats", {
                totalSaves = 0,
                lastSave = 0,
                firstSave = 0,
                averageSaveInterval = 0
            })

            saveStats.totalSaves = saveStats.totalSaves + 1
            saveStats.lastSave = currentTime

            if saveStats.firstSave == 0 then
                saveStats.firstSave = currentTime
            end

            -- Calculate average save interval
            if saveStats.totalSaves > 1 then
                local totalTime = currentTime - saveStats.firstSave
                saveStats.averageSaveInterval = totalTime / (saveStats.totalSaves - 1)
            end

            character:setData("saveStats", saveStats)

            -- Create backup if it's been long enough
            local lastBackup = character:getData("lastBackup", 0)
            local backupInterval = 3600 * 24 -- 24 hours
            if currentTime - lastBackup > backupInterval then
                self:CreateCharacterBackup(character)
                character:setData("lastBackup", currentTime)
            end

            -- Update character analytics
            self:UpdateCharacterAnalytics(character, "saved")

            -- Check for save streaks or achievements
            self:CheckSaveAchievements(character)

            -- Send save confirmation to client
            if IsValid(client) then
                net.Start("CharacterSaved")
                    net.WriteUInt(character:getID(), 32)
                    net.WriteUInt(currentTime, 32)
                net.Send(client)

                -- Update client-side save timestamp
                client:setNetVar("lastSave", currentTime)
            end

            -- Log detailed save information
            lia.log.add(string.format("Character saved - ID: %d, Name: %s, Player: %s, Saves: %d",
                character:getID(),
                character:getName(),
                IsValid(client) and client:Name() or "Unknown",
                saveStats.totalSaves), FLAG_NORMAL)

            -- Trigger any post-save hooks
            hook.Run("OnCharacterPostSave", character, client)
        end

        -- Helper function to create character backups
        function MODULE:CreateCharacterBackup(character)
            local backupData = {
                characterData = character:getData(),
                inventory = {},
                timestamp = os.time()
            }

            -- Backup inventory
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    table.insert(backupData.inventory, {
                        uniqueID = item.uniqueID,
                        data = item:getData(),
                        quantity = item:getQuantity()
                    })
                end
            end

            -- Save backup to file
            local backupPath = string.format("lilia/backups/char_%d_%d.json",
                character:getID(), backupData.timestamp)

            file.Write(backupPath, util.TableToJSON(backupData))
        end
        ```
]]
function CharPostSave(character)
end

--[[
    Purpose:
        Called before a character is saved to the database.

    When Called:
        Before character data is written to the database.

    Parameters:
        character (Character)
            The character about to be saved.

    Returns:
        boolean
            Whether the character should be saved (return false to cancel).

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow saving
        function MODULE:CharPreSave(character)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate character data before saving
        function MODULE:CharPreSave(character)
            -- Check if character has required data
            if not character:getName() or character:getName() == "" then
                lia.log.add("Attempted to save character with invalid name", FLAG_WARNING)
                return false
            end

            -- Update last modified timestamp
            character:setData("lastModified", os.time())

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive pre-save validation and processing
        function MODULE:CharPreSave(character)
            local client = character:getPlayer()

            -- Validate character integrity
            if not self:ValidateCharacterForSave(character) then
                if IsValid(client) then
                    client:notify("Character data validation failed. Save cancelled.")
                end
                return false
            end

            -- Update save metadata
            local saveMeta = character:getData("saveMetadata", {})
            saveMeta.lastSaveAttempt = os.time()
            saveMeta.saveCount = (saveMeta.saveCount or 0) + 1
            saveMeta.lastModifiedBy = IsValid(client) and client:SteamID() or "system"
            character:setData("saveMetadata", saveMeta)

            -- Compress large data fields if needed
            self:OptimizeCharacterData(character)

            -- Create pre-save backup for recovery
            if self:ShouldCreateRecoveryBackup(character) then
                self:CreateRecoveryBackup(character)
            end

            -- Check for conflicting saves
            if self:IsCharacterBeingSavedElsewhere(character) then
                lia.log.add("Conflicting save detected for character: " .. character:getName(), FLAG_WARNING)
                return false
            end

            -- Update character statistics
            local stats = character:getData("statistics", {})
            stats.totalSaveAttempts = (stats.totalSaveAttempts or 0) + 1
            character:setData("statistics", stats)

            -- Log pre-save operations
            lia.log.add(string.format("Pre-save validation passed for character: %s (ID: %d)",
                character:getName(), character:getID()), FLAG_NORMAL)

            -- Run any pre-save hooks
            local result = hook.Run("OnCharacterPreSave", character, client)
            if result == false then
                return false
            end

            return true
        end

        -- Helper function to validate character data
        function MODULE:ValidateCharacterForSave(character)
            -- Check required fields
            local required = {"name", "faction", "money"}
            for _, field in ipairs(required) do
                if character:getData(field) == nil then
                    lia.log.add("Missing required field '" .. field .. "' for character: " .. character:getName(), FLAG_ERROR)
                    return false
                end
            end

            -- Validate name length
            local name = character:getName()
            if #name < 2 or #name > 32 then
                return false
            end

            -- Check for invalid characters in name
            if name:match("[<>]") then
                return false
            end

            return true
        end
        ```
]]
function CharPreSave(character)
end

--[[
    Purpose:
        Called when a character is restored from the database.

    When Called:
        After character data is loaded from the database and restored.

    Parameters:
        character (Character)
            The character that was restored.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character restoration
        function MODULE:CharRestored(character)
            print("Character restored: " .. character:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize character after restoration
        function MODULE:CharRestored(character)
            -- Set restoration timestamp
            character:setData("lastRestored", os.time())

            -- Validate restored data
            if not character:getData("money") then
                character:setData("money", lia.config.get("DefaultMoney", 0))
            end

            -- Log the restoration
            lia.log.add("Character restored: " .. character:getName(), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive character restoration with validation and recovery
        function MODULE:CharRestored(character)
            local client = character:getPlayer()
            local currentTime = os.time()

            -- Validate restored character data
            local validationResult = self:ValidateRestoredCharacter(character)
            if not validationResult.valid then
                lia.log.add("Character restoration validation failed: " .. validationResult.error, FLAG_ERROR)

                -- Attempt recovery from backup
                if self:AttemptCharacterRecovery(character) then
                    lia.log.add("Character recovery successful for: " .. character:getName(), FLAG_NORMAL)
                else
                    -- Create emergency character
                    self:CreateEmergencyCharacter(character, client)
                    return
                end
            end

            -- Update restoration statistics
            local restoreStats = character:getData("restoreStats", {
                totalRestores = 0,
                lastRestore = 0,
                restoreHistory = {}
            })

            restoreStats.totalRestores = restoreStats.totalRestores + 1
            restoreStats.lastRestore = currentTime

            -- Keep history of last 10 restores
            table.insert(restoreStats.restoreHistory, currentTime)
            if #restoreStats.restoreHistory > 10 then
                table.remove(restoreStats.restoreHistory, 1)
            end

            character:setData("restoreStats", restoreStats)

            -- Restore character relationships and references
            self:RestoreCharacterRelationships(character)

            -- Reinitialize character timers and effects
            self:ReinitializeCharacterTimers(character)

            -- Check for data migration needs
            if self:CharacterNeedsMigration(character) then
                self:MigrateCharacterData(character)
            end

            -- Update character playtime tracking
            local playTime = character:getData("totalPlayTime", 0)
            character:setData("lastLoginTime", currentTime)

            -- Send restoration confirmation to client
            if IsValid(client) then
                client:notify("Character '" .. character:getName() .. "' restored successfully.")

                -- Update client-side data
                client:setNetVar("characterRestored", currentTime)
            end

            -- Log detailed restoration information
            lia.log.add(string.format("Character restored - ID: %d, Name: %s, Player: %s, Restores: %d",
                character:getID(),
                character:getName(),
                IsValid(client) and client:Name() or "Unknown",
                restoreStats.totalRestores), FLAG_NORMAL)

            -- Trigger post-restoration hooks
            hook.Run("OnCharacterRestored", character, client)
        end

        -- Helper function to validate restored character
        function MODULE:ValidateRestoredCharacter(character)
            -- Check for corrupted data
            if not character:getName() or character:getName() == "" then
                return {valid = false, error = "Invalid character name"}
            end

            -- Verify faction exists
            local faction = character:getFaction()
            if faction and not lia.faction.get(faction) then
                return {valid = false, error = "Invalid faction: " .. faction}
            end

            -- Check inventory integrity
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if not item.uniqueID then
                        return {valid = false, error = "Corrupted inventory item"}
                    end
                end
            end

            return {valid = true}
        end
        ```
]]
function CharRestored(character)
end

--[[
    Purpose:
        Forces a character to be recognized by others.

    When Called:
        When forcing character recognition.

    Parameters:
        player (Player)
            The player being recognized.
        range (number)
            The recognition range.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Force recognition for all players in range
        function MODULE:CharForceRecognized(player, range)
            for _, ply in player.Iterator() do
                if ply ~= player and ply:GetPos():Distance(player:GetPos()) <= range then
                    ply:recognize(player)
                end
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Recognition based on faction relationships
        function MODULE:CharForceRecognized(player, range)
            local char = player:getChar()
            if not char then return end

            local playerFaction = char:getFaction()

            for _, ply in player.Iterator() do
                if ply ~= player and ply:GetPos():Distance(player:GetPos()) <= range then
                    local plyChar = ply:getChar()
                    if plyChar then
                        local plyFaction = plyChar:getFaction()

                        -- Recognize allies and same faction
                        if plyFaction == playerFaction or
                           self:IsFactionAlly(playerFaction, plyFaction) then
                            ply:recognize(player)
                        end
                    end
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced recognition system with multiple factors
        function MODULE:CharForceRecognized(player, range)
            local char = player:getChar()
            if not char then return end

            local playerFaction = char:getFaction()
            local playerClass = char:getClass()
            local playerFlags = char:getFlags()
            local playerRep = char:getData("reputation", 0)

            -- Track recognition events for analytics
            local recognitionEvent = {
                timestamp = os.time(),
                player = player:Name(),
                position = player:GetPos(),
                range = range,
                recognizedPlayers = {}
            }

            for _, ply in player.Iterator() do
                if ply ~= player and ply:GetPos():Distance(player:GetPos()) <= range then
                    local plyChar = ply:getChar()
                    if plyChar then
                        local shouldRecognize = false
                        local recognitionReason = ""

                        -- Check line of sight
                        local trace = util.TraceLine({
                            start = player:EyePos(),
                            endpos = ply:EyePos(),
                            filter = {player, ply}
                        })

                        if trace.Hit then
                            -- No direct line of sight, but maybe recognize through other means
                            local distance = player:GetPos():Distance(ply:GetPos())
                            if distance <= range * 0.3 then -- Very close
                                shouldRecognize = true
                                recognitionReason = "proximity"
                            end
                        else
                            shouldRecognize = true
                            recognitionReason = "line_of_sight"
                        end

                        -- Apply faction-based recognition rules
                        if shouldRecognize then
                            local plyFaction = plyChar:getFaction()
                            local plyClass = plyChar:getClass()
                            local plyFlags = plyChar:getFlags()
                            local plyRep = plyChar:getData("reputation", 0)

                            -- Same faction always recognizes
                            if plyFaction == playerFaction then
                                shouldRecognize = true
                                recognitionReason = recognitionReason .. "_same_faction"
                            elseif self:IsFactionAlly(playerFaction, plyFaction) then
                                shouldRecognize = true
                                recognitionReason = recognitionReason .. "_allied_faction"
                            elseif self:IsFactionHostile(playerFaction, plyFaction) then
                                -- Hostile factions may not recognize each other
                                if math.random() < 0.3 then -- 30% chance
                                    shouldRecognize = false
                                    recognitionReason = recognitionReason .. "_hostile_faction_random"
                                else
                                    shouldRecognize = true
                                    recognitionReason = recognitionReason .. "_hostile_faction_override"
                                end
                            end

                            -- Reputation-based recognition
                            local repDifference = math.abs(playerRep - plyRep)
                            if repDifference > 500 then
                                if playerRep > plyRep and math.random() < 0.8 then
                                    shouldRecognize = true
                                    recognitionReason = recognitionReason .. "_high_reputation"
                                elseif plyRep > playerRep and math.random() < 0.6 then
                                    shouldRecognize = false
                                    recognitionReason = recognitionReason .. "_low_reputation"
                                end
                            end

                            -- Flag-based recognition
                            if char:hasFlags("R") then -- Recognition flag
                                shouldRecognize = true
                                recognitionReason = recognitionReason .. "_recognition_flag"
                            end

                            if plyChar:hasFlags("H") then -- Hidden flag
                                if not char:hasFlags("I") then -- Investigator flag required
                                    shouldRecognize = false
                                    recognitionReason = recognitionReason .. "_hidden_character"
                                end
                            end

                            -- Class-based recognition rules
                            if playerClass and plyClass then
                                if playerClass == plyClass then
                                    shouldRecognize = true
                                    recognitionReason = recognitionReason .. "_same_class"
                                elseif self:AreClassesRelated(playerClass, plyClass) then
                                    shouldRecognize = true
                                    recognitionReason = recognitionReason .. "_related_class"
                                end
                            end

                            -- Time-based recognition modifiers
                            local currentTime = os.date("*t")
                            if currentTime.hour >= 22 or currentTime.hour <= 6 then
                                -- Night time - harder to recognize
                                if math.random() < 0.2 then
                                    shouldRecognize = false
                                    recognitionReason = recognitionReason .. "_night_time_penalty"
                                end
                            end

                            -- Weather-based recognition modifiers
                            if lia.config.get("weatherAffectsRecognition", false) then
                                -- This would depend on your weather system
                                local isRaining = false -- Replace with actual weather check
                                if isRaining and math.random() < 0.25 then
                                    shouldRecognize = false
                                    recognitionReason = recognitionReason .. "_weather_penalty"
                                end
                            end

                            -- Apply recognition
                            if shouldRecognize then
                                ply:recognize(player)

                                -- Track successful recognition
                                table.insert(recognitionEvent.recognizedPlayers, {
                                    name = ply:Name(),
                                    reason = recognitionReason,
                                    distance = player:GetPos():Distance(ply:GetPos())
                                })

                                -- Log individual recognition
                                lia.log.add(string.format("%s recognized %s (%s)",
                                    player:Name(), ply:Name(), recognitionReason), FLAG_NORMAL)
                            end
                        end
                    end
                end
            end

            -- Store recognition event for analytics
            local recognitionHistory = lia.data.get("recognitionHistory", {})
            table.insert(recognitionHistory, recognitionEvent)

            -- Keep only last 1000 events
            if #recognitionHistory > 1000 then
                table.remove(recognitionHistory, 1)
            end

            lia.data.set("recognitionHistory", recognitionHistory)

            -- Trigger post-recognition events
            hook.Run("OnCharForceRecognizedComplete", player, range, recognitionEvent)
        end

        -- Helper function to check if factions are allied
        function MODULE:IsFactionAlly(faction1, faction2)
            local factionData = lia.faction.get(faction1)
            if factionData and factionData.allies then
                return table.HasValue(factionData.allies, faction2)
            end
            return false
        end

        -- Helper function to check if factions are hostile
        function MODULE:IsFactionHostile(faction1, faction2)
            local factionData = lia.faction.get(faction1)
            if factionData and factionData.hostile then
                return table.HasValue(factionData.hostile, faction2)
            end
            return false
        end

        -- Helper function to check if classes are related
        function MODULE:AreClassesRelated(class1, class2)
            -- This would depend on your class hierarchy system
            -- For example, different ranks in same profession
            local relatedClasses = {
                ["police_officer"] = {"police_chief", "detective"},
                ["citizen"] = {"mayor", "business_owner"}
            }

            return relatedClasses[class1] and table.HasValue(relatedClasses[class1], class2)
        end
        ```
]]
function CharForceRecognized(player, range)
end

--[[
    Purpose:
        Checks if a character has specific flags.

    When Called:
        When checking character permissions/flags.

    Parameters:
        character (Character)
            The character to check.
        flags (string)
            The flags to check for.

    Returns:
        boolean
            Whether the character has the flags.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Direct flag check
        function MODULE:CharHasFlags(character, flags)
            local charFlags = character:getFlags()
            for i = 1, #flags do
                if not string.find(charFlags, flags[i]) then
                    return false
                end
            end
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Flag checking with inheritance
        function MODULE:CharHasFlags(character, flags)
            local charFlags = character:getFlags()

            -- Check if character has all required flags
            for i = 1, #flags do
                local flag = flags[i]
                if not string.find(charFlags, flag) then
                    -- Check for flag inheritance (e.g., admin inherits moderator)
                    if not self:CheckFlagInheritance(charFlags, flag) then
                        return false
                    end
                end
            end

            return true
        end

        -- Helper function for flag inheritance
        function MODULE:CheckFlagInheritance(charFlags, requiredFlag)
            local inheritance = {
                ["Z"] = {"Y", "X"}, -- Super admin inherits admin and moderator
                ["Y"] = {"X"},      -- Admin inherits moderator
            }

            if inheritance[requiredFlag] then
                for _, inheritedFlag in ipairs(inheritance[requiredFlag]) do
                    if string.find(charFlags, inheritedFlag) then
                        return true
                    end
                end
            end

            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced flag system with temporary flags and restrictions
        function MODULE:CharHasFlags(character, flags)
            local charFlags = character:getFlags()
            local tempFlags = character:getData("temporaryFlags", {})
            local restrictedFlags = character:getData("restrictedFlags", {})

            -- Combine permanent and temporary flags
            local effectiveFlags = charFlags

            -- Add temporary flags that are still active
            local currentTime = os.time()
            for flag, expiry in pairs(tempFlags) do
                if expiry > currentTime then
                    effectiveFlags = effectiveFlags .. flag
                elseif expiry > 0 then
                    -- Flag has expired, remove it
                    tempFlags[flag] = nil
                end
            end

            -- Update temporary flags (remove expired ones)
            if table.Count(tempFlags) ~= table.Count(character:getData("temporaryFlags", {})) then
                character:setData("temporaryFlags", tempFlags)
            end

            -- Check each required flag
            for i = 1, #flags do
                local flag = flags[i]

                -- Check if flag is restricted
                if restrictedFlags[flag] then
                    local restrictionExpiry = restrictedFlags[flag]
                    if restrictionExpiry == 0 or restrictionExpiry > currentTime then
                        return false -- Flag is restricted
                    else
                        -- Restriction has expired, remove it
                        restrictedFlags[flag] = nil
                        character:setData("restrictedFlags", restrictedFlags)
                    end
                end

                -- Check if character has the flag
                if not string.find(effectiveFlags, flag) then
                    -- Check flag inheritance
                    if not self:CheckAdvancedFlagInheritance(effectiveFlags, flag) then
                        -- Check for conditional flags (based on other character data)
                        if not self:CheckConditionalFlags(character, flag) then
                            -- Check for faction/class granted flags
                            if not self:CheckFactionClassFlags(character, flag) then
                                return false
                            end
                        end
                    end
                end
            end

            -- Log flag check for security monitoring
            if lia.config.get("logFlagChecks", false) then
                lia.log.add(string.format("Flag check for %s: %s - Result: %s",
                    character:getName(), table.concat(flags, ","), "true"), FLAG_NORMAL)
            end

            return true
        end

        -- Helper function for advanced flag inheritance
        function MODULE:CheckAdvancedFlagInheritance(charFlags, requiredFlag)
            local inheritanceRules = {
                ["Z"] = {"Y", "X", "W"},     -- Super admin
                ["Y"] = {"X", "W"},         -- Admin
                ["X"] = {"W"},              -- Moderator
                ["P"] = {"C", "B"},         -- Police chief inherits captain and officer
                ["C"] = {"B"},              -- Police captain inherits officer
                ["M"] = {"D", "E"}          -- Mayor inherits deputy and employee
            }

            local function hasInheritedFlag(flags, targetFlag)
                if string.find(flags, targetFlag) then
                    return true
                end

                local inherited = inheritanceRules[targetFlag]
                if inherited then
                    for _, inheritedFlag in ipairs(inherited) do
                        if hasInheritedFlag(flags, inheritedFlag) then
                            return true
                        end
                    end
                end

                return false
            end

            return hasInheritedFlag(charFlags, requiredFlag)
        end

        -- Helper function for conditional flags
        function MODULE:CheckConditionalFlags(character, flag)
            local conditions = {
                ["V"] = function(char) -- VIP flag based on playtime/money
                    return char:getPlayTime() > 3600 or char:getMoney() > 50000
                end,
                ["R"] = function(char) -- Recognized flag based on reputation
                    return char:getData("reputation", 0) > 1000
                end,
                ["L"] = function(char) -- Lockpicking flag based on thief skill
                    return char:getAttrib("thief", 0) > 50
                end
            }

            if conditions[flag] then
                return conditions[flag](character)
            end

            return false
        end

        -- Helper function for faction/class granted flags
        function MODULE:CheckFactionClassFlags(character, flag)
            local faction = character:getFaction()
            local class = character:getClass()

            -- Faction-granted flags
            if faction then
                local factionData = lia.faction.get(faction)
                if factionData and factionData.grantedFlags then
                    if table.HasValue(factionData.grantedFlags, flag) then
                        return true
                    end
                end
            end

            -- Class-granted flags
            if class then
                local classData = lia.class.get(class)
                if classData and classData.grantedFlags then
                    if table.HasValue(classData.grantedFlags, flag) then
                        return true
                    end
                end
            end

            -- Check for equipment-granted flags
            local inventory = character:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if item:getData("equip", false) and item.grantedFlags then
                        if table.HasValue(item.grantedFlags, flag) then
                            return true
                        end
                    end
                end
            end

            return false
        end
        ```
]]
function CharHasFlags(character, flags)
end

--[[
    Purpose:
        Determines if a faction limit has been reached.

    When Called:
        When checking if a player can join a faction.

    Parameters:
        faction (table)
            The faction data.
        character (Character)
            The character attempting to join.
        client (Player)
            The player attempting to join.

    Returns:
        boolean
            Whether the faction limit has been reached.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check basic faction member count
        function MODULE:CheckFactionLimitReached(faction, character, client)
            if not faction.limit then return false end

            -- Count current faction members
            local memberCount = 0
            for _, ply in player.Iterator() do
                local char = ply:getChar()
                if char and char:getFaction() == faction.uniqueID then
                    memberCount = memberCount + 1
                end
            end

            return memberCount >= faction.limit
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check faction limits with whitelist considerations
        function MODULE:CheckFactionLimitReached(faction, character, client)
            if not faction.limit then return false end

            -- Check if player is on whitelist (unlimited slots)
            local whitelist = faction:getData("whitelist", {})
            if table.HasValue(whitelist, client:SteamID()) then
                return false
            end

            -- Count current active faction members
            local memberCount = 0
            local activeMembers = 0

            for _, ply in player.Iterator() do
                local char = ply:getChar()
                if char and char:getFaction() == faction.uniqueID then
                    memberCount = memberCount + 1

                    -- Count active members (online recently)
                    if ply:IsConnected() and (CurTime() - ply:GetCreationTime()) < 300 then -- Online in last 5 minutes
                        activeMembers = activeMembers + 1
                    end
                end
            end

            -- Use active member count if faction has activity requirements
            local checkCount = faction.requireActiveMembers and activeMembers or memberCount

            return checkCount >= faction.limit
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced faction limit checking with dynamic limits and special conditions
        function MODULE:CheckFactionLimitReached(faction, character, client)
            -- No limit set
            if not faction.limit then return false end

            -- Check special permissions (admins, donators, etc.)
            if self:HasFactionJoinOverride(client, faction) then
                return false
            end

            -- Get dynamic limit based on server population
            local baseLimit = faction.limit
            local serverPopulation = #player.GetAll()
            local dynamicLimit = self:CalculateDynamicFactionLimit(faction, baseLimit, serverPopulation)

            -- Count current faction members with activity weighting
            local memberStats = self:GetFactionMemberStats(faction.uniqueID)
            local effectiveMemberCount = self:CalculateEffectiveMemberCount(memberStats, faction)

            -- Check temporary limit increases (events, promotions, etc.)
            local temporaryBonus = faction:getData("temporaryLimitBonus", 0)
            local adjustedLimit = dynamicLimit + temporaryBonus

            -- Check faction rank requirements
            if character:getData("factionRank", 1) < (faction.minJoinRank or 1) then
                return true -- Character doesn't meet rank requirements
            end

            -- Check faction reputation requirements
            if character:getData("factionReputation", 0) < (faction.minJoinReputation or 0) then
                return true -- Character doesn't meet reputation requirements
            end

            -- Check if faction is at capacity
            if effectiveMemberCount >= adjustedLimit then
                -- Check if there's a queue system
                if faction.queueEnabled then
                    return self:IsInFactionQueue(client, faction.uniqueID)
                end
                return true
            end

            -- Check faction diversity requirements
            if faction.diversityRequired then
                if not self:MeetsFactionDiversityRequirements(character, faction) then
                    return true
                end
            end

            -- Check faction balance (prevent one faction from dominating)
            if self:FactionWouldUnbalanceServer(character, faction) then
                return true
            end

            -- Check recruitment cooldown
            if self:IsOnFactionRecruitmentCooldown(client, faction.uniqueID) then
                return true
            end

            -- Check faction stability (unstable factions may have reduced limits)
            local stabilityMultiplier = faction:getData("stabilityMultiplier", 1.0)
            adjustedLimit = math.floor(adjustedLimit * stabilityMultiplier)

            return effectiveMemberCount >= adjustedLimit
        end

        -- Helper function to check for faction join overrides
        function MODULE:HasFactionJoinOverride(client, faction)
            -- Admin override
            if client:IsAdmin() then return true end

            -- Donation override
            if client:getData("donatorLevel", 0) >= (faction.donatorOverrideLevel or 999) then
                return true
            end

            -- Special permissions
            local specialPerms = faction:getData("specialPermissions", {})
            if table.HasValue(specialPerms, client:SteamID()) then
                return true
            end

            -- Beta tester override
            if client:getData("betaTester", false) and faction.allowBetaTesters then
                return true
            end

            return false
        end

        -- Helper function to calculate dynamic faction limits
        function MODULE:CalculateDynamicFactionLimit(faction, baseLimit, serverPopulation)
            -- Scale limit based on server population
            local scalingFactor = math.min(serverPopulation / 20, 3) -- Max 3x scaling
            local scaledLimit = math.floor(baseLimit * scalingFactor)

            -- Apply faction-specific multipliers
            local factionMultiplier = faction:getData("populationMultiplier", 1.0)
            scaledLimit = math.floor(scaledLimit * factionMultiplier)

            -- Apply server-wide faction limit adjustments
            local serverFactionMultiplier = lia.config.get("factionLimitMultiplier", 1.0)
            scaledLimit = math.floor(scaledLimit * serverFactionMultiplier)

            return math.max(scaledLimit, faction.minLimit or 1)
        end

        -- Helper function to get faction member statistics
        function MODULE:GetFactionMemberStats(factionID)
            local stats = {
                totalMembers = 0,
                activeMembers = 0,
                veryActiveMembers = 0,
                inactiveMembers = 0,
                averageLevel = 0,
                totalLevel = 0
            }

            for _, ply in player.Iterator() do
                local char = ply:getChar()
                if char and char:getFaction() == factionID then
                    stats.totalMembers = stats.totalMembers + 1
                    stats.totalLevel = stats.totalLevel + (char:getData("level", 1) or 1)

                    -- Activity tracking
                    local lastSeen = char:getData("lastSeen", 0)
                    local timeSinceLastSeen = os.time() - lastSeen

                    if timeSinceLastSeen < 86400 then -- Active in last 24 hours
                        stats.activeMembers = stats.activeMembers + 1
                    elseif timeSinceLastSeen < 604800 then -- Active in last week
                        stats.veryActiveMembers = stats.veryActiveMembers + 1
                    else
                        stats.inactiveMembers = stats.inactiveMembers + 1
                    end
                end
            end

            stats.averageLevel = stats.totalMembers > 0 and (stats.totalLevel / stats.totalMembers) or 0

            return stats
        end

        -- Helper function to calculate effective member count
        function MODULE:CalculateEffectiveMemberCount(memberStats, faction)
            -- Weight active members more heavily
            local effectiveCount = memberStats.veryActiveMembers * 1.0 + -- Full weight for very active
                                  memberStats.activeMembers * 0.8 +     -- 80% weight for active
                                  memberStats.inactiveMembers * 0.3      -- 30% weight for inactive

            -- Adjust based on average level (higher level members count more)
            local levelMultiplier = math.max(0.5, math.min(2.0, memberStats.averageLevel / 50))
            effectiveCount = effectiveCount * levelMultiplier

            return math.floor(effectiveCount)
        end

        -- Helper function to check faction diversity requirements
        function MODULE:MeetsFactionDiversityRequirements(character, faction)
            -- This would implement checks for gender, race, class diversity, etc.
            -- For example, ensure faction isn't 90% male or 90% one race

            local diversityReqs = faction.diversityRequirements
            if not diversityReqs then return true end

            -- Check gender diversity
            if diversityReqs.genderBalance then
                local currentGenderRatio = self:GetFactionGenderRatio(faction.uniqueID)
                local charGender = character:getData("gender", "male")

                -- Prevent joining if it would unbalance gender ratio too much
                if charGender == "male" and currentGenderRatio.male > 0.7 then
                    return false
                elseif charGender == "female" and currentGenderRatio.female > 0.7 then
                    return false
                end
            end

            -- Check class diversity
            if diversityReqs.classBalance then
                local currentClassDistribution = self:GetFactionClassDistribution(faction.uniqueID)
                local charClass = character:getClass()

                -- Prevent joining if class would exceed maximum percentage
                local classPercentage = currentClassDistribution[charClass] or 0
                if classPercentage > (diversityReqs.maxClassPercentage or 0.5) then
                    return false
                end
            end

            return true
        end

        -- Helper function to check if faction would unbalance server
        function MODULE:FactionWouldUnbalanceServer(character, faction)
            local totalPlayers = #player.GetAll()
            if totalPlayers < 10 then return false end -- Not enough players to worry about balance

            local factionCount = 0
            for _, ply in player.Iterator() do
                local char = ply:getChar()
                if char and char:getFaction() == faction.uniqueID then
                    factionCount = factionCount + 1
                end
            end

            local factionPercentage = (factionCount + 1) / totalPlayers -- +1 for the joining player
            local maxFactionPercentage = lia.config.get("maxFactionPercentage", 0.4) -- Default 40%

            return factionPercentage > maxFactionPercentage
        end

        -- Helper function to check recruitment cooldown
        function MODULE:IsOnFactionRecruitmentCooldown(client, factionID)
            local cooldownData = client:getData("factionRecruitmentCooldowns", {})
            local lastRecruitment = cooldownData[factionID]

            if not lastRecruitment then return false end

            local cooldownTime = lia.config.get("factionRecruitmentCooldown", 300) -- 5 minutes default
            return (os.time() - lastRecruitment) < cooldownTime
        end

        -- Helper function to check if player is in faction queue
        function MODULE:IsInFactionQueue(client, factionID)
            local queue = lia.data.get("factionQueues", {})[factionID] or {}
            return table.HasValue(queue, client:SteamID())
        end
        ```
]]
function CheckFactionLimitReached(faction, character, client)
end

--[[
    Purpose:
        Handles character selection.

    When Called:
        When a player chooses a character.

    Parameters:
        characterID (number)
            The ID of the chosen character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic character selection logging
        function MODULE:ChooseCharacter(characterID)
            print("Player chose character ID: " .. characterID)

            -- Basic validation
            if not characterID or characterID <= 0 then
                print("Invalid character ID")
                return
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Character selection with validation and logging
        function MODULE:ChooseCharacter(characterID)
            -- Get the client (assuming this is called in a player context)
            local client = self.player or LocalPlayer()

            -- Validate character exists and belongs to player
            lia.char.getCharacter(client, characterID, function(character)
                if not character then
                    client:notify("Character not found!")
                    return
                end

                -- Check if character is banned
                if character:getData("banned", false) then
                    client:notify("This character is banned!")
                    return
                end

                -- Log character selection
                lia.log.add(client:Name() .. " selected character: " .. character:getName(), FLAG_NORMAL)

                -- Update character statistics
                character:setData("timesSelected", character:getData("timesSelected", 0) + 1)
                character:setData("lastSelected", os.time())

                -- Send notification to player
                client:notify("Selected character: " .. character:getName())
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character selection with analytics and special handling
        function MODULE:ChooseCharacter(characterID)
            local client = self.player or LocalPlayer()
            local startTime = CurTime()

            -- Validate character selection
            lia.char.getCharacter(client, characterID, function(character)
                if not character then
                    client:notify("Character not found!")
                    self:LogFailedSelection(client, characterID, "character_not_found")
                    return
                end

                -- Check character status
                if character:getData("banned", false) then
                    client:notify("This character is banned!")
                    self:LogFailedSelection(client, characterID, "character_banned")
                    return
                end

                -- Check character cooldown (if applicable)
                local lastSelected = character:getData("lastSelected", 0)
                local cooldown = character:getData("selectionCooldown", 0)

                if cooldown > 0 and (os.time() - lastSelected) < cooldown then
                    local remainingTime = cooldown - (os.time() - lastSelected)
                    client:notify("You must wait " .. remainingTime .. " seconds before selecting this character again!")
                    self:LogFailedSelection(client, characterID, "cooldown_active")
                    return
                end

                -- Check character prerequisites
                if not self:CharacterMeetsPrerequisites(character, client) then
                    client:notify("This character does not meet the prerequisites for selection!")
                    self:LogFailedSelection(client, characterID, "prerequisites_not_met")
                    return
                end

                -- Handle special character types
                if character:getData("specialCharacter", false) then
                    if not self:HandleSpecialCharacterSelection(character, client) then
                        return
                    end
                end

                -- Update character statistics
                self:UpdateCharacterSelectionStats(character, client)

                -- Handle character switching (if currently playing)
                if client:getChar() then
                    self:HandleCharacterSwitch(client:getChar(), character, client)
                end

                -- Apply character-specific settings
                self:ApplyCharacterSettings(character, client)

                -- Send character selection confirmation
                self:SendCharacterSelectionConfirmation(character, client)

                -- Log successful selection
                self:LogSuccessfulSelection(character, client, CurTime() - startTime)

                -- Trigger post-selection events
                hook.Run("OnCharacterSelected", character, client)

                -- Update server statistics
                self:UpdateServerSelectionStats(character, client)
            end)
        end

        -- Helper function to check character prerequisites
        function MODULE:CharacterMeetsPrerequisites(character, client)
            -- Check level requirements
            local requiredLevel = character:getData("requiredLevel", 0)
            if character:getData("level", 1) < requiredLevel then
                return false
            end

            -- Check faction requirements
            local requiredFaction = character:getData("requiredFaction")
            if requiredFaction and character:getFaction() ~= requiredFaction then
                return false
            end

            -- Check completed quests
            local requiredQuests = character:getData("requiredQuests", {})
            for _, questID in ipairs(requiredQuests) do
                if not character:getData("completedQuests", {})[questID] then
                    return false
                end
            end

            -- Check time-based restrictions
            local timeRestriction = character:getData("selectionTimeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false
                end
            end

            return true
        end

        -- Helper function to handle special character selection
        function MODULE:HandleSpecialCharacterSelection(character, client)
            local specialType = character:getData("specialType")

            if specialType == "admin_only" and not client:IsAdmin() then
                client:notify("This character is restricted to administrators!")
                return false
            elseif specialType == "donator_only" then
                local donatorLevel = character:getData("requiredDonatorLevel", 1)
                if client:getData("donatorLevel", 0) < donatorLevel then
                    client:notify("This character requires donator status!")
                    return false
                end
            elseif specialType == "event_only" then
                if not lia.config.get("eventMode", false) then
                    client:notify("This character is only available during events!")
                    return false
                end
            elseif specialType == "beta_tester" then
                if not client:getData("betaTester", false) then
                    client:notify("This character is only available to beta testers!")
                    return false
                end
            end

            return true
        end

        -- Helper function to update character selection statistics
        function MODULE:UpdateCharacterSelectionStats(character, client)
            -- Update selection count
            local selectionCount = character:getData("selectionCount", 0) + 1
            character:setData("selectionCount", selectionCount)

            -- Update last selected timestamp
            character:setData("lastSelected", os.time())

            -- Track selection history
            local selectionHistory = character:getData("selectionHistory", {})
            table.insert(selectionHistory, {
                timestamp = os.time(),
                playerName = client:Name(),
                steamID = client:SteamID()
            })

            -- Keep only last 10 selections
            if #selectionHistory > 10 then
                table.remove(selectionHistory, 1)
            end

            character:setData("selectionHistory", selectionHistory)

            -- Update player statistics
            local playerStats = client:getData("characterStats", {})
            playerStats.totalSelections = (playerStats.totalSelections or 0) + 1
            playerStats.lastCharacterSelected = character:getID()
            client:setData("characterStats", playerStats)
        end

        -- Helper function to handle character switching
        function MODULE:HandleCharacterSwitch(oldCharacter, newCharacter, client)
            -- Clean up old character
            if oldCharacter then
                self:CleanupOldCharacter(oldCharacter, client)
            end

            -- Prepare new character
            self:PrepareNewCharacter(newCharacter, client)

            -- Handle inventory transfer if needed
            if lia.config.get("transferInventoryOnSwitch", false) then
                self:TransferInventoryBetweenCharacters(oldCharacter, newCharacter, client)
            end

            -- Log character switch
            lia.log.add(client:Name() .. " switched from '" .. (oldCharacter and oldCharacter:getName() or "None") ..
                       "' to '" .. newCharacter:getName() .. "'", FLAG_NORMAL)
        end

        -- Helper function to apply character settings
        function MODULE:ApplyCharacterSettings(character, client)
            -- Apply character-specific model
            if character:getData("customModel") then
                client:SetModel(character:getData("customModel"))
            end

            -- Apply character-specific walk speed
            if character:getData("walkSpeed") then
                client:SetWalkSpeed(character:getData("walkSpeed"))
            end

            -- Apply character-specific run speed
            if character:getData("runSpeed") then
                client:SetRunSpeed(character:getData("runSpeed"))
            end

            -- Apply character-specific jump power
            if character:getData("jumpPower") then
                client:SetJumpPower(character:getData("jumpPower"))
            end

            -- Set character-specific data on player
            client:SetNWString("characterName", character:getName())
            client:SetNWInt("characterID", character:getID())
            client:SetNWString("characterFaction", character:getFaction() or "")
        end

        -- Helper function to send selection confirmation
        function MODULE:SendCharacterSelectionConfirmation(character, client)
            local confirmationData = {
                characterName = character:getName(),
                characterFaction = character:getFaction(),
                characterClass = character:getClass(),
                characterLevel = character:getData("level", 1),
                selectionTime = CurTime()
            }

            -- Send to client
            net.Start("CharacterSelectionConfirmed")
                net.WriteTable(confirmationData)
            net.Send(client)

            -- Show notification
            client:notify("Successfully selected: " .. character:getName())
        end

        -- Helper function to log successful selection
        function MODULE:LogSuccessfulSelection(character, client, selectionTime)
            lia.log.add(string.format("Character selection - Player: %s (%s), Character: %s (ID: %d), Time: %.2fs",
                client:Name(), client:SteamID(), character:getName(), character:getID(), selectionTime), FLAG_NORMAL)
        end

        -- Helper function to log failed selection
        function MODULE:LogFailedSelection(client, characterID, reason)
            lia.log.add(string.format("Character selection failed - Player: %s (%s), CharacterID: %d, Reason: %s",
                client:Name(), client:SteamID(), characterID, reason), FLAG_WARNING)
        end

        -- Helper function to update server statistics
        function MODULE:UpdateServerSelectionStats(character, client)
            local serverStats = lia.data.get("serverCharacterStats", {})
            serverStats.totalSelections = (serverStats.totalSelections or 0) + 1
            serverStats.lastSelectionTime = os.time()
            serverStats.mostSelectedCharacter = character:getName()
            lia.data.set("serverCharacterStats", serverStats)
        end
        ```
]]
function ChooseCharacter(characterID)
end

--[[
    Purpose:
        Called when a command is added to the command system.

    When Called:
        When new commands are registered with the framework.

    Parameters:
        command (string)
            The command name.
        data (table)
            The command data and configuration.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log command registration
        function MODULE:CommandAdded(command, data)
            print("Command registered: " .. command)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track command categories and permissions
        function MODULE:CommandAdded(command, data)
            -- Initialize command tracking if needed
            self.registeredCommands = self.registeredCommands or {}

            -- Store command information
            self.registeredCommands[command] = {
                category = data.category or "General",
                adminOnly = data.adminOnly or false,
                superAdminOnly = data.superAdminOnly or false,
                registeredAt = os.time()
            }

            -- Log command registration
            lia.log.add("Command registered: " .. command .. " (Category: " .. (data.category or "General") .. ")", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced command management and validation
        function MODULE:CommandAdded(command, data)
            -- Validate command data
            if not self:ValidateCommandData(command, data) then
                lia.log.add("Invalid command data for: " .. command, FLAG_ERROR)
                return
            end

            -- Initialize comprehensive command tracking
            self.commandRegistry = self.commandRegistry or {}

            -- Store detailed command information
            self.commandRegistry[command] = {
                data = table.Copy(data),
                registeredAt = os.time(),
                registeredBy = "system", -- Could be enhanced to track who registered it
                usageCount = 0,
                lastUsed = 0,
                restricted = data.restricted or false,
                cooldown = data.cooldown or 0,
                category = data.category or "Uncategorized"
            }

            -- Update command categories
            self:UpdateCommandCategories(command, data.category)

            -- Set up command monitoring
            self:SetupCommandMonitoring(command, data)

            -- Register command with external systems
            self:RegisterWithExternalSystems(command, data)

            -- Log comprehensive command registration
            lia.log.add(string.format("Command registered - Name: %s, Category: %s, AdminOnly: %s, Restricted: %s",
                command,
                data.category or "Uncategorized",
                tostring(data.adminOnly or false),
                tostring(data.restricted or false)), FLAG_NORMAL)

            -- Trigger post-registration hooks
            hook.Run("OnCommandRegistered", command, data)
        end

        -- Helper function to validate command data
        function MODULE:ValidateCommandData(command, data)
            -- Check for required fields
            if not command or command == "" then
                return false
            end

            -- Validate command syntax
            if not string.match(command, "^[a-zA-Z0-9_]+$") then
                return false
            end

            -- Check for duplicate commands
            if self.commandRegistry and self.commandRegistry[command] then
                lia.log.add("Attempted to register duplicate command: " .. command, FLAG_WARNING)
                return false
            end

            return true
        end
        ```
]]
function CommandAdded(command, data)
end

--[[
    Purpose:
        Called when a command is executed.

    When Called:
        After a command has been run.

    Parameters:
        client (Player)
            The player who ran the command.
        command (string)
            The command that was run.
        arguments (table)
            The command arguments.
        results (any)
            The command results.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log command execution
        function MODULE:CommandRan(client, command, arguments, results)
            print(client:Name() .. " ran command: " .. command)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Command logging with basic filtering
        function MODULE:CommandRan(client, command, arguments, results)
            -- Don't log sensitive commands
            local sensitiveCommands = {
                "login", "register", "changepassword", "admin"
            }

            if not table.HasValue(sensitiveCommands, command) then
                local argString = table.concat(arguments, " ")
                lia.log.add(client:Name() .. " executed: /" .. command .. " " .. argString, FLAG_NORMAL)

                -- Track command usage statistics
                local stats = lia.data.get("commandStats", {})
                stats[command] = (stats[command] or 0) + 1
                lia.data.set("commandStats", stats)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced command monitoring and analytics
        function MODULE:CommandRan(client, command, arguments, results)
            -- Skip logging for spam commands
            if self:IsSpamCommand(command, client) then
                return
            end

            -- Get command metadata
            local commandData = lia.command.get(command)
            local isAdminCommand = commandData and commandData.adminOnly
            local commandCategory = commandData and commandData.category or "general"

            -- Log command execution with context
            local logData = {
                player = client:Name(),
                steamID = client:SteamID(),
                command = command,
                arguments = self:SanitizeArguments(arguments),
                timestamp = os.time(),
                isAdmin = isAdminCommand,
                category = commandCategory,
                success = results ~= false,
                character = client:getChar() and client:getChar():getName() or "No Character"
            }

            -- Store in command history
            self:StoreCommandHistory(logData)

            -- Update player command statistics
            self:UpdatePlayerCommandStats(client, command, commandCategory)

            -- Check for command abuse patterns
            if self:CheckCommandAbuse(client, command, logData) then
                self:HandleCommandAbuse(client, command)
                return
            end

            -- Execute post-command actions
            self:ExecutePostCommandActions(client, command, arguments, results)

            -- Send analytics data
            if lia.config.get("commandAnalytics", false) then
                self:SendCommandAnalytics(logData)
            end

            -- Trigger custom events
            hook.Run("OnCommandExecuted", client, command, arguments, results)
        end

        -- Helper function to check if command is spam
        function MODULE:IsSpamCommand(command, client)
            local spamCommands = {
                "me", "it", "roll", "flip", "yell", "whisper"
            }

            if table.HasValue(spamCommands, command) then
                -- Allow limited spam commands per minute
                local playerSpam = self.playerSpamCount[client:SteamID()] or {}
                local currentTime = CurTime()
                local timeWindow = 60 -- 1 minute

                -- Clean old entries
                for cmd, times in pairs(playerSpam) do
                    for i = #times, 1, -1 do
                        if currentTime - times[i] > timeWindow then
                            table.remove(times, i)
                        end
                    end
                end

                -- Check current command spam
                playerSpam[command] = playerSpam[command] or {}
                table.insert(playerSpam[command], currentTime)

                self.playerSpamCount[client:SteamID()] = playerSpam

                -- Allow max 10 of each spam command per minute
                return #playerSpam[command] > 10
            end

            return false
        end

        -- Helper function to sanitize arguments for logging
        function MODULE:SanitizeArguments(arguments)
            local sanitized = {}

            for _, arg in ipairs(arguments) do
                -- Hide sensitive information
                if string.find(arg:lower(), "password") or
                   string.find(arg:lower(), "token") or
                   string.find(arg:lower(), "key") then
                    table.insert(sanitized, "[REDACTED]")
                elseif #arg > 100 then
                    -- Truncate long arguments
                    table.insert(sanitized, arg:sub(1, 100) .. "...")
                else
                    table.insert(sanitized, arg)
                end
            end

            return sanitized
        end

        -- Helper function to store command history
        function MODULE:StoreCommandHistory(logData)
            local history = lia.data.get("commandHistory", {})
            table.insert(history, logData)

            -- Keep only last 10000 commands
            if #history > 10000 then
                table.remove(history, 1)
            end

            lia.data.set("commandHistory", history)
        end

        -- Helper function to update player command statistics
        function MODULE:UpdatePlayerCommandStats(client, command, category)
            local playerStats = client:getData("commandStats", {})
            playerStats.totalCommands = (playerStats.totalCommands or 0) + 1
            playerStats[command] = (playerStats[command] or 0) + 1
            playerStats["category_" .. category] = (playerStats["category_" .. category] or 0) + 1

            -- Track last used command
            playerStats.lastCommand = command
            playerStats.lastCommandTime = os.time()

            client:setData("commandStats", playerStats)
        end

        -- Helper function to check for command abuse
        function MODULE:CheckCommandAbuse(client, command, logData)
            -- Check for rapid command execution
            local recentCommands = self:GetRecentPlayerCommands(client, 10) -- Last 10 commands
            local currentTime = CurTime()

            if #recentCommands >= 10 then
                local timeSpan = currentTime - recentCommands[1].timestamp
                if timeSpan < 5 then -- 10 commands in 5 seconds
                    return true
                end
            end

            -- Check for command spam (same command repeatedly)
            local sameCommandCount = 0
            for _, cmd in ipairs(recentCommands) do
                if cmd.command == command then
                    sameCommandCount = sameCommandCount + 1
                end
            end

            if sameCommandCount >= 5 then -- Same command 5+ times in recent history
                return true
            end

            return false
        end

        -- Helper function to handle command abuse
        function MODULE:HandleCommandAbuse(client, command)
            lia.log.add(client:Name() .. " flagged for command abuse: " .. command, FLAG_WARNING)

            -- Increment abuse counter
            local abuseCount = client:getData("commandAbuseCount", 0) + 1
            client:setData("commandAbuseCount", abuseCount)

            -- Apply penalties based on abuse level
            if abuseCount >= 5 then
                -- Temporary mute for severe abuse
                client:setData("mutedUntil", os.time() + 300) -- 5 minutes
                client:notify("You have been temporarily muted for command spam.")
            elseif abuseCount >= 3 then
                -- Warning for moderate abuse
                client:notify("Please stop spamming commands. Further violations will result in penalties.")
            else
                -- Light warning for first offenses
                client:notify("Please avoid rapid command usage.")
            end
        end

        -- Helper function to execute post-command actions
        function MODULE:ExecutePostCommandActions(client, command, arguments, results)
            -- Execute custom actions based on command
            if command == "givemoney" and results then
                -- Log money transactions
                local amount = tonumber(arguments[2])
                if amount then
                    self:LogMoneyTransaction(client, amount, "command")
                end
            elseif command == "ban" and results then
                -- Notify admins of bans
                self:NotifyAdminsOfBan(client, arguments)
            elseif command == "kick" and results then
                -- Log kicks
                self:LogPlayerKick(client, arguments)
            end
        end

        -- Helper function to send command analytics
        function MODULE:SendCommandAnalytics(logData)
            -- Send to external analytics service if configured
            if lia.config.get("externalAnalytics", false) then
                -- This would send data to an external service
                -- For now, just store locally
                local analytics = lia.data.get("commandAnalytics", {})
                table.insert(analytics, logData)

                -- Keep only recent analytics (last 24 hours)
                local cutoffTime = os.time() - 86400
                for i = #analytics, 1, -1 do
                    if analytics[i].timestamp < cutoffTime then
                        table.remove(analytics, i)
                    end
                end

                lia.data.set("commandAnalytics", analytics)
            end
        end

        -- Helper function to get recent player commands
        function MODULE:GetRecentPlayerCommands(client, count)
            local history = lia.data.get("commandHistory", {})
            local playerCommands = {}
            local steamID = client:SteamID()

            for i = #history, 1, -1 do
                if history[i].steamID == steamID then
                    table.insert(playerCommands, history[i])
                    if #playerCommands >= count then
                        break
                    end
                end
            end

            return playerCommands
        end
        ```
]]
function CommandRan(client, command, arguments, results)
end

--[[
    Purpose:
        Handles character creation.

    When Called:
        When a new character is created.

    Parameters:
        data (table)
            The character creation data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character creation
        function MODULE:CreateCharacter(data)
            print("New character created: " .. (data.name or "Unknown"))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add basic character setup and validation
        function MODULE:CreateCharacter(data)
            -- Validate required data
            if not data.name or not data.faction then
                error("Character creation failed: missing required data")
                return
            end

            -- Add creation timestamp
            data.created = os.time()

            -- Set default values
            data.money = data.money or lia.config.get("defaultMoney", 100)
            data.health = data.health or 100
            data.armor = data.armor or 0

            -- Log character creation
            lia.log.add("Character created: " .. data.name .. " (" .. data.faction .. ")", FLAG_NORMAL)

            -- Send welcome message
            timer.Simple(1, function()
                if data.client then
                    data.client:notify("Welcome to the server, " .. data.name .. "!")
                end
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character creation with faction-specific setup and analytics
        function MODULE:CreateCharacter(data)
            -- Validate all required data
            local validationErrors = self:ValidateCharacterData(data)
            if #validationErrors > 0 then
                local errorMsg = "Character creation failed:\n" .. table.concat(validationErrors, "\n")
                if data.client then
                    data.client:notify(errorMsg)
                end
                lia.log.add("Character creation failed for " .. (data.client and data.client:Name() or "Unknown") ..
                           ": " .. table.concat(validationErrors, ", "), FLAG_WARNING)
                return
            end

            -- Pre-creation processing
            data = self:PreProcessCharacterData(data)

            -- Apply faction-specific modifications
            data = self:ApplyFactionModifications(data)

            -- Set creation metadata
            data.created = os.time()
            data.createdBy = data.client and data.client:SteamID() or "unknown"
            data.creationIP = data.client and data.client:IPAddress() or "unknown"
            data.creationVersion = lia.version

            -- Initialize character statistics
            data.stats = {
                totalPlayTime = 0,
                itemsUsed = 0,
                doorsUsed = 0,
                moneyEarned = 0,
                moneySpent = 0,
                kills = 0,
                deaths = 0,
                questsCompleted = 0
            }

            -- Apply starting bonuses based on faction/class
            data = self:ApplyStartingBonuses(data)

            -- Set up character flags and permissions
            data = self:InitializeCharacterPermissions(data)

            -- Create custom inventory if needed
            if data.customInventory then
                data.inventory = self:CreateCustomInventory(data)
            end

            -- Initialize character relationships
            data.relationships = self:InitializeCharacterRelationships(data)

            -- Apply character background effects
            if data.background then
                data = self:ApplyBackgroundEffects(data)
            end

            -- Set up character goals and objectives
            data.goals = self:GenerateCharacterGoals(data)

            -- Initialize achievement tracking
            data.achievements = {}
            data.achievementProgress = {}

            -- Apply server-wide character creation modifiers
            data = self:ApplyServerModifiers(data)

            -- Log detailed character creation
            self:LogCharacterCreation(data)

            -- Send creation analytics
            self:SendCreationAnalytics(data)

            -- Trigger post-creation events
            hook.Run("OnCharacterCreated", data)

            -- Set up welcome sequence
            self:SetupWelcomeSequence(data)

            -- Apply any pending character modifications
            data = self:ApplyPendingModifications(data)

            -- Final validation
            local finalValidation = self:FinalCharacterValidation(data)
            if not finalValidation.valid then
                lia.log.add("Character creation final validation failed: " .. finalValidation.reason, FLAG_ERROR)
                return
            end
        end

        -- Helper function to validate character data
        function MODULE:ValidateCharacterData(data)
            local errors = {}

            -- Basic validation
            if not data.name or #data.name < 2 then
                table.insert(errors, "Name must be at least 2 characters long")
            end

            if data.name and #data.name > 32 then
                table.insert(errors, "Name cannot exceed 32 characters")
            end

            if not data.faction then
                table.insert(errors, "Faction must be selected")
            end

            if not data.model then
                table.insert(errors, "Model must be selected")
            end

            -- Name validation
            if data.name then
                if string.find(data.name, "[^%w%s]") then
                    table.insert(errors, "Name contains invalid characters")
                end

                -- Check for banned words
                local bannedWords = {"admin", "moderator", "owner", "fuck", "shit"}
                local lowerName = string.lower(data.name)
                for _, word in ipairs(bannedWords) do
                    if string.find(lowerName, word) then
                        table.insert(errors, "Name contains banned word: " .. word)
                        break
                    end
                end
            end

            -- Faction validation
            if data.faction then
                local factionData = lia.faction.get(data.faction)
                if not factionData then
                    table.insert(errors, "Invalid faction selected")
                elseif factionData.restricted and data.client and not data.client:IsAdmin() then
                    table.insert(errors, "This faction is restricted")
                end
            end

            -- Model validation
            if data.model and not self:IsValidCharacterModel(data.model, data.faction) then
                table.insert(errors, "Invalid model for selected faction")
            end

            -- Custom validation based on server rules
            local customErrors = self:CustomCharacterValidation(data)
            for _, error in ipairs(customErrors) do
                table.insert(errors, error)
            end

            return errors
        end

        -- Helper function to pre-process character data
        function MODULE:PreProcessCharacterData(data)
            -- Clean and format name
            data.name = string.Trim(data.name)
            data.name = string.gsub(data.name, "%s+", " ") -- Replace multiple spaces with single space

            -- Set default values
            data.money = data.money or lia.config.get("defaultMoney", 100)
            data.health = data.health or 100
            data.armor = data.armor or 0
            data.stamina = data.stamina or lia.config.get("defaultStamina", 100)

            -- Initialize data tables
            data.data = data.data or {}
            data.attributes = data.attributes or {}
            data.inventory = data.inventory or {}

            return data
        end

        -- Helper function to apply faction modifications
        function MODULE:ApplyFactionModifications(data)
            local factionData = lia.faction.get(data.faction)
            if not factionData then return data end

            -- Apply faction bonuses
            if factionData.startingMoney then
                data.money = (data.money or 0) + factionData.startingMoney
            end

            if factionData.startingHealth then
                data.health = factionData.startingHealth
            end

            -- Apply faction attributes
            if factionData.attributes then
                for attr, value in pairs(factionData.attributes) do
                    data.attributes[attr] = (data.attributes[attr] or 0) + value
                end
            end

            -- Set faction-specific data
            data.data.factionJoinDate = os.time()
            data.data.factionRank = factionData.defaultRank or 1

            return data
        end

        -- Helper function to apply starting bonuses
        function MODULE:ApplyStartingBonuses(data)
            -- Class bonuses
            if data.class then
                local classData = lia.class.get(data.class)
                if classData and classData.startingBonuses then
                    for stat, bonus in pairs(classData.startingBonuses) do
                        if stat == "money" then
                            data.money = (data.money or 0) + bonus
                        elseif stat == "health" then
                            data.health = (data.health or 0) + bonus
                        elseif stat == "armor" then
                            data.armor = (data.armor or 0) + bonus
                        else
                            data.attributes[stat] = (data.attributes[stat] or 0) + bonus
                        end
                    end
                end
            end

            -- Background bonuses
            if data.background then
                local backgroundBonuses = self:GetBackgroundBonuses(data.background)
                for stat, bonus in pairs(backgroundBonuses) do
                    if stat == "money" then
                        data.money = (data.money or 0) + bonus
                    elseif stat == "health" then
                        data.health = (data.health or 0) + bonus
                    elseif stat == "armor" then
                        data.armor = (data.armor or 0) + bonus
                    else
                        data.attributes[stat] = (data.attributes[stat] or 0) + bonus
                    end
                end
            end

            -- Trait bonuses
            if data.traits then
                for _, trait in ipairs(data.traits) do
                    local traitBonuses = self:GetTraitBonuses(trait)
                    for stat, bonus in pairs(traitBonuses) do
                        if stat == "money" then
                            data.money = (data.money or 0) + bonus
                        elseif stat == "health" then
                            data.health = (data.health or 0) + bonus
                        elseif stat == "armor" then
                            data.armor = (data.armor or 0) + bonus
                        else
                            data.attributes[stat] = (data.attributes[stat] or 0) + bonus
                        end
                    end
                end
            end

            return data
        end

        -- Helper function to initialize character permissions
        function MODULE:InitializeCharacterPermissions(data)
            data.flags = data.flags or {}

            -- Add faction default flags
            local factionData = lia.faction.get(data.faction)
            if factionData and factionData.defaultFlags then
                for _, flag in ipairs(factionData.defaultFlags) do
                    table.insert(data.flags, flag)
                end
            end

            -- Add class default flags
            if data.class then
                local classData = lia.class.get(data.class)
                if classData and classData.defaultFlags then
                    for _, flag in ipairs(classData.defaultFlags) do
                        table.insert(data.flags, flag)
                    end
                end
            end

            -- Initialize permission levels
            data.permissionLevel = 1
            data.canUseCommands = true
            data.canTrade = true

            return data
        end

        -- Helper function to create custom inventory
        function MODULE:CreateCustomInventory(data)
            local inventory = {}

            -- Add faction starting items
            local factionData = lia.faction.get(data.faction)
            if factionData and factionData.startingItems then
                for _, itemData in ipairs(factionData.startingItems) do
                    table.insert(inventory, {
                        uniqueID = itemData.uniqueID,
                        quantity = itemData.quantity or 1,
                        data = itemData.data or {}
                    })
                end
            end

            -- Add class starting items
            if data.class then
                local classData = lia.class.get(data.class)
                if classData and classData.startingItems then
                    for _, itemData in ipairs(classData.startingItems) do
                        table.insert(inventory, {
                            uniqueID = itemData.uniqueID,
                            quantity = itemData.quantity or 1,
                            data = itemData.data or {}
                        })
                    end
                end
            end

            -- Add selected equipment
            if data.startingEquipment then
                for _, itemID in ipairs(data.startingEquipment) do
                    table.insert(inventory, {
                        uniqueID = itemID,
                        quantity = 1,
                        data = {}
                    })
                end
            end

            return inventory
        end

        -- Helper function to initialize character relationships
        function MODULE:InitializeCharacterRelationships(data)
            return {
                friends = {},
                enemies = {},
                organizations = {},
                reputation = {
                    overall = 0,
                    factions = {},
                    individuals = {}
                }
            }
        end

        -- Helper function to apply background effects
        function MODULE:ApplyBackgroundEffects(data)
            if data.background == "street_kid" then
                data.attributes["agility"] = (data.attributes["agility"] or 0) + 2
                data.attributes["survival"] = (data.attributes["survival"] or 0) + 1
            elseif data.background == "corporate" then
                data.attributes["intelligence"] = (data.attributes["intelligence"] or 0) + 2
                data.attributes["business"] = (data.attributes["business"] or 0) + 1
                data.money = (data.money or 0) + 500
            elseif data.background == "military" then
                data.attributes["strength"] = (data.attributes["strength"] or 0) + 2
                data.attributes["discipline"] = (data.attributes["discipline"] or 0) + 1
                data.health = (data.health or 0) + 10
            elseif data.background == "criminal" then
                data.attributes["stealth"] = (data.attributes["stealth"] or 0) + 2
                data.attributes["lockpicking"] = (data.attributes["lockpicking"] or 0) + 1
            end

            return data
        end

        -- Helper function to generate character goals
        function MODULE:GenerateCharacterGoals(data)
            local goals = {}

            -- Basic goals
            table.insert(goals, {
                id = "earn_money",
                description = "Earn your first $1000",
                progress = 0,
                target = 1000,
                reward = "bonus_money_100"
            })

            table.insert(goals, {
                id = "make_friends",
                description = "Make 5 friends",
                progress = 0,
                target = 5,
                reward = "social_bonus"
            })

            -- Faction-specific goals
            local factionData = lia.faction.get(data.faction)
            if factionData and factionData.startingGoals then
                for _, goal in ipairs(factionData.startingGoals) do
                    table.insert(goals, goal)
                end
            end

            return goals
        end

        -- Helper function to apply server modifiers
        function MODULE:ApplyServerModifiers(data)
            -- Apply server-wide attribute bonuses
            local serverAttrBonus = lia.config.get("characterAttributeBonus", 0)
            if serverAttrBonus > 0 then
                for attr, _ in pairs(data.attributes) do
                    data.attributes[attr] = data.attributes[attr] + serverAttrBonus
                end
            end

            -- Apply server-wide money bonus
            local serverMoneyBonus = lia.config.get("characterMoneyBonus", 0)
            if serverMoneyBonus > 0 then
                data.money = (data.money or 0) + serverMoneyBonus
            end

            -- Apply difficulty modifiers
            local difficulty = lia.config.get("serverDifficulty", "normal")
            if difficulty == "hard" then
                data.health = math.floor((data.health or 100) * 0.9) -- 10% health reduction
                data.money = math.floor((data.money or 100) * 0.8) -- 20% money reduction
            elseif difficulty == "easy" then
                data.health = math.floor((data.health or 100) * 1.1) -- 10% health bonus
                data.money = math.floor((data.money or 100) * 1.2) -- 20% money bonus
            end

            return data
        end

        -- Helper function to log character creation
        function MODULE:LogCharacterCreation(data)
            local logData = string.format("Character created - Name: %s, Faction: %s, Class: %s, Money: %s, Created by: %s",
                data.name, data.faction, data.class or "None", data.money, data.createdBy)

            lia.log.add(logData, FLAG_NORMAL)

            -- Detailed logging for admins
            if lia.config.get("detailedCharacterCreationLogging", false) then
                local detailedLog = {
                    "Detailed character creation:",
                    "  Name: " .. data.name,
                    "  Faction: " .. data.faction,
                    "  Class: " .. (data.class or "None"),
                    "  Model: " .. (data.model or "Default"),
                    "  Money: " .. data.money,
                    "  Health: " .. data.health,
                    "  Background: " .. (data.background or "None"),
                    "  Traits: " .. (data.traits and table.concat(data.traits, ", ") or "None"),
                    "  Skills: " .. (data.skills and table.Count(data.skills) or 0) .. " allocated",
                    "  Created by: " .. data.createdBy,
                    "  Creation IP: " .. data.creationIP
                }

                lia.log.add(table.concat(detailedLog, "\n"), FLAG_NORMAL)
            end
        end

        -- Helper function to send creation analytics
        function MODULE:SendCreationAnalytics(data)
            if not lia.config.get("characterCreationAnalytics", false) then return end

            local analytics = lia.data.get("characterCreationAnalytics", {})
            table.insert(analytics, {
                timestamp = os.time(),
                faction = data.faction,
                class = data.class,
                background = data.background,
                hasTraits = data.traits and #data.traits > 0,
                startingMoney = data.money,
                creator = data.createdBy
            })

            -- Keep only recent analytics (last 30 days)
            local cutoffTime = os.time() - (30 * 24 * 60 * 60)
            for i = #analytics, 1, -1 do
                if analytics[i].timestamp < cutoffTime then
                    table.remove(analytics, i)
                end
            end

            lia.data.set("characterCreationAnalytics", analytics)
        end

        -- Helper function to set up welcome sequence
        function MODULE:SetupWelcomeSequence(data)
            if not data.client then return end

            -- Send welcome message after character loads
            timer.Simple(2, function()
                if IsValid(data.client) then
                    data.client:notify("Welcome to " .. lia.config.get("serverName", "the server") .. ", " .. data.name .. "!")

                    -- Send faction-specific welcome
                    local factionData = lia.faction.get(data.faction)
                    if factionData and factionData.welcomeMessage then
                        timer.Simple(3, function()
                            if IsValid(data.client) then
                                data.client:notify(factionData.welcomeMessage)
                            end
                        end)
                    end

                    -- Show tutorial if enabled
                    if lia.config.get("showNewPlayerTutorial", true) then
                        timer.Simple(5, function()
                            if IsValid(data.client) then
                                self:ShowNewPlayerTutorial(data.client)
                            end
                        end)
                    end
                end
            end)
        end

        -- Helper function for final validation
        function MODULE:FinalCharacterValidation(data)
            -- Check final constraints
            if data.money < 0 then
                return {valid = false, reason = "Invalid money amount"}
            end

            if data.health <= 0 then
                return {valid = false, reason = "Invalid health amount"}
            end

            -- Ensure required data is present
            if not data.name or not data.faction or not data.model then
                return {valid = false, reason = "Missing required character data"}
            end

            return {valid = true}
        end

        -- Additional helper functions
        function MODULE:IsValidCharacterModel(model, faction)
            -- Basic model validation - in a real implementation, you'd check against faction-allowed models
            return model and string.find(model, "models/player") ~= nil
        end

        function MODULE:CustomCharacterValidation(data)
            -- Server-specific validation rules
            local errors = {}

            -- Example: Check name uniqueness
            if self:IsNameTaken(data.name, data.client) then
                table.insert(errors, "This name is already taken")
            end

            -- Example: Check character limits per player
            if data.client and self:GetPlayerCharacterCount(data.client) >= lia.config.get("maxCharactersPerPlayer", 5) then
                table.insert(errors, "Maximum character limit reached")
            end

            return errors
        end

        function MODULE:GetBackgroundBonuses(background)
            local bonuses = {
                street_kid = {agility = 1, survival = 1},
                corporate = {intelligence = 1, money = 200},
                military = {strength = 1, health = 5},
                criminal = {stealth = 1, lockpicking = 1}
            }
            return bonuses[background] or {}
        end

        function MODULE:GetTraitBonuses(trait)
            local bonuses = {
                lucky = {luck = 2},
                tough = {endurance = 1, health = 10},
                smart = {intelligence = 1},
                charismatic = {charisma = 1},
                athletic = {agility = 1, strength = 1},
                creative = {crafting = 1}
            }
            return bonuses[trait] or {}
        end

        function MODULE:IsNameTaken(name, client)
            -- This would check the database for existing character names
            -- For this example, we'll return false (not taken)
            return false
        end

        function MODULE:GetPlayerCharacterCount(client)
            -- This would query the database for character count
            -- For this example, we'll return 0
            return 0
        end

        function MODULE:ShowNewPlayerTutorial(client)
            -- This would show a tutorial interface
            -- For this example, just send a message
            client:notify("Welcome! Use the F1 key to access the help menu.")
        end
        ```
]]
function CreateCharacter(data)
end

--[[
    Purpose:
        Handles creating default inventory for characters.

    When Called:
        When a new character is created and needs default items.

    Parameters:
        character (Character)
            The character being created.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Give basic starting items
        function MODULE:CreateDefaultInventory(character)
            character:getInv():add("wallet")
            character:getInv():add("identification")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Give faction-specific starting items
        function MODULE:CreateDefaultInventory(character)
            local faction = character:getFaction()
            local inventory = character:getInv()

            -- Basic items for all characters
            inventory:add("wallet")
            inventory:add("identification")

            -- Faction-specific items
            if faction == FACTION_POLICE then
                inventory:add("handcuffs")
                inventory:add("nightstick")
            elseif faction == FACTION_MEDIC then
                inventory:add("health_kit")
                inventory:add("bandages")
            elseif faction == FACTION_CITIZEN then
                inventory:add("crowbar")
                inventory:add("lockpick")
            end

            -- Class-specific items
            local class = character:getClass()
            if class then
                local classData = lia.class.list[class]
                if classData and classData.startingInventory then
                    for _, item in ipairs(classData.startingInventory) do
                        inventory:add(item)
                    end
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory creation with validation and customization
        function MODULE:CreateDefaultInventory(character)
            local inventory = character:getInv()
            local client = character:getPlayer()

            -- Validate inventory exists
            if not inventory then
                lia.log.add("Failed to create default inventory for character: " .. character:getName(), FLAG_ERROR)
                return
            end

            -- Add basic essential items
            self:AddEssentialItems(character, inventory)

            -- Add faction-specific equipment
            self:AddFactionEquipment(character, inventory)

            -- Add class-specific gear
            self:AddClassEquipment(character, inventory)

            -- Add attribute-based items
            self:AddAttributeBasedItems(character, inventory)

            -- Add reputation-based items
            self:AddReputationBasedItems(character, inventory)

            -- Add randomized starting items
            self:AddRandomizedItems(character, inventory)

            -- Validate final inventory
            self:ValidateStartingInventory(character, inventory)

            -- Log inventory creation
            self:LogInventoryCreation(character, inventory)

            -- Send notification to player
            if IsValid(client) then
                client:notify("Your character has been equipped with starting items.")
            end

            -- Trigger post-inventory creation hooks
            hook.Run("OnCharacterInventoryCreated", character, inventory)
        end

        -- Helper function to add essential items
        function MODULE:AddEssentialItems(character, inventory)
            local essentialItems = {
                "wallet",
                "identification",
                "backpack"
            }

            for _, item in ipairs(essentialItems) do
                if not inventory:hasItem(item) then
                    inventory:add(item)
                end
            end
        end

        -- Helper function to add faction equipment
        function MODULE:AddFactionEquipment(character, inventory)
            local faction = character:getFaction()
            if not faction then return end

            local factionEquipment = self.factionEquipment[faction] or {}
            for _, item in ipairs(factionEquipment) do
                inventory:add(item)
            end
        end
        ```
]]
function CreateDefaultInventory(character)
end

--[[
    Purpose:
        Handles creating salary timers.

    When Called:
        When salary system is initialized.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic salary timer
        function MODULE:CreateSalaryTimers()
            timer.Create("liaSalaryTimer", 300, 0, function()
                for _, client in player.Iterator() do
                    if IsValid(client) then
                        -- Give basic salary
                        local character = client:getChar()
                        if character then
                            character:giveMoney(50)
                            client:notify("You received your salary!")
                        end
                    end
                end
            end)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create faction-based salary timers
        function MODULE:CreateSalaryTimers()
            -- Create individual timers for different factions
            local salaryData = {
                ["citizen"] = {amount = 100, interval = 600}, -- 10 minutes
                ["police"] = {amount = 150, interval = 600},
                ["medic"] = {amount = 140, interval = 600},
                ["admin"] = {amount = 200, interval = 300} -- 5 minutes
            }

            for factionID, data in pairs(salaryData) do
                timer.Create("liaSalary_" .. factionID, data.interval, 0, function()
                    for _, client in player.Iterator() do
                        if IsValid(client) then
                            local character = client:getChar()
                            if character and character:getFaction() == factionID then
                                character:giveMoney(data.amount)
                                client:notify("Salary received: $" .. data.amount)
                            end
                        end
                    end
                end)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary system with performance bonuses and taxes
        function MODULE:CreateSalaryTimers()
            -- Main salary timer
            timer.Create("liaAdvancedSalary", 600, 0, function() -- Every 10 minutes
                for _, client in player.Iterator() do
                    if IsValid(client) then
                        local character = client:getChar()
                        if not character then continue end

                        -- Calculate base salary
                        local baseSalary = self:GetBaseSalary(character)

                        -- Apply performance bonus
                        local performanceBonus = self:CalculatePerformanceBonus(character, client)

                        -- Apply faction/class multipliers
                        local factionMultiplier = self:GetFactionSalaryMultiplier(character:getFaction())
                        local classMultiplier = self:GetClassSalaryMultiplier(character:getClass())

                        -- Calculate total salary
                        local totalSalary = math.floor(baseSalary * (1 + performanceBonus) * factionMultiplier * classMultiplier)

                        -- Apply taxes
                        local taxRate = self:GetTaxRate(character)
                        local taxAmount = math.floor(totalSalary * taxRate)
                        local netSalary = totalSalary - taxAmount

                        -- Give salary
                        character:giveMoney(netSalary)

                        -- Log transaction
                        lia.log.add(client:Name() .. " received salary: $" .. netSalary ..
                                  " (Base: $" .. baseSalary .. ", Tax: $" .. taxAmount .. ")", FLAG_NORMAL)

                        -- Send detailed notification
                        client:notify(string.format("Salary: $%d (Tax: $%d, Performance: +%d%%)",
                                                  netSalary, taxAmount, math.floor(performanceBonus * 100)))

                        -- Check for salary achievements
                        self:CheckSalaryAchievements(character, netSalary)
                    end
                end
            end)

            -- Overtime bonus timer (for long play sessions)
            timer.Create("liaOvertimeBonus", 3600, 0, function() -- Every hour
                for _, client in player.Iterator() do
                    if IsValid(client) then
                        local character = client:getChar()
                        if not character then continue end

                        local playTime = client:GetUTimeTotalTime()
                        if playTime >= 7200 then -- 2+ hours
                            local bonus = math.floor(character:getSalary() * 0.1) -- 10% bonus
                            character:giveMoney(bonus)
                            client:notify("Overtime bonus: $" .. bonus)
                        end
                    end
                end
            end)

            -- Special event salary bonuses
            timer.Create("liaSpecialSalaryEvents", 1800, 0, function() -- Every 30 minutes
                -- Random chance for special bonuses
                if math.random() < 0.1 then -- 10% chance
                    local bonusAmount = math.random(50, 200)
                    for _, client in player.Iterator() do
                        if IsValid(client) and client:getChar() then
                            client:getChar():giveMoney(bonusAmount)
                            client:notify("Special bonus payment: $" .. bonusAmount)
                        end
                    end
                    lia.log.add("Special salary bonus distributed: $" .. bonusAmount .. " to all players", FLAG_NORMAL)
                end
            end)
        end

        -- Helper functions for salary calculation
        function MODULE:GetBaseSalary(character)
            local faction = lia.faction.get(character:getFaction())
            return faction and faction.salary or 100
        end

        function MODULE:CalculatePerformanceBonus(character, client)
            -- Bonus based on playtime this session
            local sessionTime = CurTime() - (client.liaJoinTime or CurTime())
            local hoursPlayed = sessionTime / 3600

            -- Bonus tiers
            if hoursPlayed >= 4 then return 0.5 -- 50% bonus for 4+ hours
            elseif hoursPlayed >= 2 then return 0.25 -- 25% bonus for 2+ hours
            elseif hoursPlayed >= 1 then return 0.1 -- 10% bonus for 1+ hours
            end

            return 0
        end

        function MODULE:GetFactionSalaryMultiplier(factionID)
            local multipliers = {
                ["police"] = 1.2,
                ["medic"] = 1.15,
                ["admin"] = 1.5,
                ["citizen"] = 1.0
            }
            return multipliers[factionID] or 1.0
        end
        ```
]]
function CreateSalaryTimers()
end

--[[
    Purpose:
        Handles character deletion.

    When Called:
        When a character is deleted.

    Parameters:
        characterID (number)
            The ID of the character to delete.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character deletion
        function MODULE:DeleteCharacter(characterID)
            print("Deleting character with ID: " .. characterID)
            lia.log.add("Character deletion requested for ID: " .. characterID, FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate and log character deletion
        function MODULE:DeleteCharacter(characterID)
            -- Get character data before deletion
            lia.char.getCharacter(characterID, nil, function(character)
                if character then
                    local charName = character:getName()
                    local owner = character:getPlayer()

                    -- Log deletion with details
                    lia.log.add(string.format("Character '%s' (ID: %d) deleted by %s",
                        charName, characterID,
                        IsValid(owner) and owner:Name() or "Unknown"), FLAG_WARNING)

                    -- Notify player if online
                    if IsValid(owner) then
                        owner:notify("Your character '" .. charName .. "' has been deleted.")
                    end

                    -- Clean up related data
                    self:CleanupCharacterData(characterID)
                else
                    lia.log.add("Attempted to delete non-existent character ID: " .. characterID, FLAG_ERROR)
                end
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive character deletion with validation and recovery
        function MODULE:DeleteCharacter(characterID)
            -- Validate deletion request
            if not self:ValidateDeletionRequest(characterID) then
                lia.log.add("Invalid character deletion request for ID: " .. characterID, FLAG_ERROR)
                return
            end

            -- Create backup before deletion
            self:CreateCharacterBackup(characterID)

            -- Get character information
            lia.char.getCharacter(characterID, nil, function(character)
                if not character then
                    lia.log.add("Character not found for deletion: " .. characterID, FLAG_ERROR)
                    return
                end

                local charName = character:getName()
                local owner = character:getPlayer()
                local steamID = IsValid(owner) and owner:SteamID() or "unknown"

                -- Log comprehensive deletion information
                lia.log.add(string.format("Character deletion initiated - Name: %s, ID: %d, Owner: %s (%s), Faction: %s",
                    charName, characterID,
                    IsValid(owner) and owner:Name() or "Unknown",
                    steamID,
                    character:getFaction() or "None"), FLAG_WARNING)

                -- Check for deletion restrictions
                if self:HasDeletionRestrictions(character) then
                    if IsValid(owner) then
                        owner:notify("This character cannot be deleted due to active restrictions.")
                    end
                    return
                end

                -- Notify related systems
                self:NotifyCharacterDeletion(character)

                -- Clean up inventory and items
                self:CleanupCharacterInventory(character)

                -- Remove from faction/class records
                self:RemoveFromFactionRecords(character)

                -- Handle quest/mission cleanup
                self:CleanupActiveQuests(character)

                -- Update statistics
                self:UpdateDeletionStatistics(character)

                -- Send deletion confirmation
                if IsValid(owner) then
                    owner:notify("Character '" .. charName .. "' has been permanently deleted.")
                    net.Start("CharacterDeleted")
                        net.WriteUInt(characterID, 32)
                    net.Send(owner)
                end

                -- Trigger post-deletion events
                hook.Run("OnCharacterDeleted", character, owner)

                -- Schedule final cleanup
                timer.Simple(1, function()
                    self:PerformFinalCleanup(characterID)
                end)
            end)
        end

        -- Helper function to validate deletion request
        function MODULE:ValidateDeletionRequest(characterID)
            if not characterID or characterID <= 0 then
                return false
            end

            -- Check if character exists
            local exists = false
            lia.char.getCharacter(characterID, nil, function(character)
                exists = character ~= nil
            end)

            return exists
        end

        -- Helper function to create backup
        function MODULE:CreateCharacterBackup(characterID)
            -- Implementation for creating character backup before deletion
            lia.log.add("Character backup created for ID: " .. characterID, FLAG_NORMAL)
        end
        ```
]]
function DeleteCharacter(characterID)
end

--[[
    Purpose:
        Handles sending embeds to Discord.

    When Called:
        When Discord relay messages are sent.

    Parameters:
        embed (table)
            The Discord embed data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log Discord relay
        function MODULE:DiscordRelaySend(embed)
            print("Sending embed to Discord")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate and log Discord messages
        function MODULE:DiscordRelaySend(embed)
            -- Validate embed structure
            if not embed.title and not embed.description then
                lia.log.add("Invalid Discord embed: missing title or description", FLAG_WARNING)
                return
            end

            -- Log the relay
            local title = embed.title or "No Title"
            lia.log.add("Discord relay: " .. title, FLAG_NORMAL)

            -- Add server information to embed
            embed.footer = embed.footer or {}
            embed.footer.text = (embed.footer.text or "") .. " - " .. GetHostName()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced Discord integration with filtering and enhancement
        function MODULE:DiscordRelaySend(embed)
            -- Validate embed data
            if not self:ValidateDiscordEmbed(embed) then
                lia.log.add("Discord embed validation failed", FLAG_ERROR)
                return
            end

            -- Apply content filtering
            embed = self:FilterDiscordContent(embed)

            -- Add server branding
            embed = self:AddServerBranding(embed)

            -- Apply rate limiting
            if self:IsRateLimited(embed) then
                lia.log.add("Discord relay rate limited", FLAG_WARNING)
                return
            end

            -- Add contextual information
            embed = self:AddContextualInfo(embed)

            -- Handle different embed types
            if embed.type == "character" then
                embed = self:EnhanceCharacterEmbed(embed)
            elseif embed.type == "admin" then
                embed = self:EnhanceAdminEmbed(embed)
            elseif embed.type == "system" then
                embed = self:EnhanceSystemEmbed(embed)
            end

            -- Add timestamp if missing
            embed.timestamp = embed.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")

            -- Queue for sending (handle potential failures)
            self:QueueDiscordMessage(embed)

            -- Log comprehensive relay information
            self:LogDiscordRelay(embed)

            -- Update relay statistics
            self:UpdateRelayStatistics(embed)

            -- Trigger post-relay hooks
            hook.Run("OnDiscordMessageQueued", embed)
        end

        -- Helper function to validate Discord embed
        function MODULE:ValidateDiscordEmbed(embed)
            if not embed then return false end

            -- Check for required fields
            if not embed.title and not embed.description and not embed.fields then
                return false
            end

            -- Validate color (should be number)
            if embed.color and not isnumber(embed.color) then
                return false
            end

            -- Check embed size limits
            if embed.title and #embed.title > 256 then
                return false
            end

            if embed.description and #embed.description > 4096 then
                return false
            end

            return true
        end

        -- Helper function to filter content
        function MODULE:FilterDiscordContent(embed)
            -- Remove sensitive information
            if embed.description then
                embed.description = self:FilterSensitiveInfo(embed.description)
            end

            if embed.title then
                embed.title = self:FilterSensitiveInfo(embed.title)
            end

            return embed
        end
        ```
]]
function DiscordRelaySend(embed)
end

--[[
    Purpose:
        Called when Discord relay is unavailable.

    When Called:
        When Discord integration fails or is unavailable.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log Discord unavailability
        function MODULE:DiscordRelayUnavailable()
            print("Discord relay is unavailable")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle Discord outage gracefully
        function MODULE:DiscordRelayUnavailable()
            -- Log the outage
            lia.log.add("Discord relay unavailable - switching to alternative logging", FLAG_WARNING)

            -- Notify administrators
            for _, client in player.Iterator() do
                if client:hasPrivilege("Server Admin") then
                    client:notify("Discord integration is currently unavailable.")
                end
            end

            -- Enable alternative logging
            self:EnableAlternativeLogging(true)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive Discord outage handling and recovery
        function MODULE:DiscordRelayUnavailable()
            -- Record outage start time
            self.discordOutageStart = CurTime()

            -- Log comprehensive outage information
            lia.log.add("Discord relay service unavailable - initiating recovery protocols", FLAG_ERROR)

            -- Update system status
            self.discordStatus = "unavailable"

            -- Notify all staff members
            self:NotifyStaffOfDiscordOutage()

            -- Switch to backup communication systems
            self:ActivateBackupCommunication()

            -- Attempt automatic recovery
            self:AttemptDiscordRecovery()

            -- Start outage monitoring
            self:StartOutageMonitoring()

            -- Update server status displays
            self:UpdateServerStatusDisplays()

            -- Log system impact
            self:LogDiscordOutageImpact()

            -- Schedule status checks
            timer.Create("DiscordStatusCheck", 300, 0, function()
                if self:CheckDiscordStatus() then
                    self:HandleDiscordRecovery()
                end
            end)

            -- Trigger emergency protocols if needed
            if self:IsCriticalDiscordOutage() then
                self:ActivateEmergencyProtocols()
            end

            -- Update monitoring dashboards
            self:UpdateMonitoringDashboards()

            -- Send outage alerts to external systems
            self:SendExternalOutageAlerts()
        end

        -- Helper function to notify staff
        function MODULE:NotifyStaffOfDiscordOutage()
            local staffMessage = "⚠️ **DISCORD INTEGRATION UNAVAILABLE** ⚠️\n" ..
                               "Discord relay service is down. Administrative actions may be logged locally only."

            for _, client in player.Iterator() do
                if client:hasPrivilege("Staff") then
                    client:notify(staffMessage)
                    client:ChatPrint(staffMessage)
                end
            end
        end

        -- Helper function to attempt recovery
        function MODULE:AttemptDiscordRecovery()
            -- Try to reconnect after a delay
            timer.Simple(60, function()
                if self:TestDiscordConnection() then
                    lia.log.add("Discord connection recovered automatically", FLAG_NORMAL)
                    self:HandleDiscordRecovery()
                else
                    lia.log.add("Discord recovery attempt failed", FLAG_WARNING)
                end
            end)
        end
        ```
]]
function DiscordRelayUnavailable()
end

--[[
    Purpose:
        Called when messages are relayed from Discord.

    When Called:
        When Discord messages are received and processed.

    Parameters:
        embed (table)
            The Discord embed data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log Discord relay reception
        function MODULE:DiscordRelayed(embed)
            print("Received embed from Discord")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Process Discord messages and relay to server
        function MODULE:DiscordRelayed(embed)
            -- Validate embed from Discord
            if not embed or not embed.content then
                lia.log.add("Invalid Discord relay message received", FLAG_WARNING)
                return
            end

            -- Log the relayed message
            lia.log.add("Discord relay: " .. (embed.content or "No content"), FLAG_NORMAL)

            -- Relay to in-game chat if it's a public message
            if embed.channel == "general" then
                for _, client in player.Iterator() do
                    client:ChatPrint("[Discord] " .. (embed.author or "Unknown") .. ": " .. (embed.content or ""))
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced Discord message processing and integration
        function MODULE:DiscordRelayed(embed)
            -- Validate incoming Discord message
            if not self:ValidateDiscordMessage(embed) then
                lia.log.add("Invalid Discord message received", FLAG_ERROR)
                return
            end

            -- Process message based on type
            if embed.type == "command" then
                self:ProcessDiscordCommand(embed)
            elseif embed.type == "announcement" then
                self:ProcessDiscordAnnouncement(embed)
            elseif embed.type == "admin" then
                self:ProcessDiscordAdminMessage(embed)
            else
                self:ProcessDiscordChatMessage(embed)
            end

            -- Apply content filtering
            embed = self:FilterDiscordContent(embed)

            -- Check for Discord-specific commands
            if self:IsDiscordCommand(embed.content) then
                self:ExecuteDiscordCommand(embed)
                return
            end

            -- Relay to appropriate channels
            self:RelayToGameChannels(embed)

            -- Update Discord integration statistics
            self:UpdateDiscordStats(embed)

            -- Handle attachments if present
            if embed.attachments then
                self:ProcessDiscordAttachments(embed)
            end

            -- Log comprehensive message information
            self:LogDiscordMessage(embed)

            -- Trigger post-processing hooks
            hook.Run("OnDiscordMessageProcessed", embed)
        end

        -- Helper function to validate Discord message
        function MODULE:ValidateDiscordMessage(embed)
            if not embed then return false end
            if not embed.author then return false end
            if not embed.content and not embed.embeds then return false end

            -- Check message length limits
            if embed.content and #embed.content > 2000 then
                return false
            end

            return true
        end

        -- Helper function to process Discord chat messages
        function MODULE:ProcessDiscordChatMessage(embed)
            local message = embed.content
            local author = embed.author.username or "Unknown"

            -- Format for in-game display
            local formattedMessage = string.format("[Discord] %s: %s", author, message)

            -- Send to all players or specific groups
            if embed.channel == "admin" then
                for _, client in player.Iterator() do
                    if client:hasPrivilege("Admin") then
                        client:ChatPrint(formattedMessage)
                    end
                end
            else
                for _, client in player.Iterator() do
                    client:ChatPrint(formattedMessage)
                end
            end
        end
        ```
]]
function DiscordRelayed(embed)
end

--[[
    Purpose:
        Handles toggling door enabled state.

    When Called:
        When a door's enabled state is toggled.

    Parameters:
        client (Player)
            The player toggling the door.
        door (Entity)
            The door entity.
        newState (boolean)
            The new enabled state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door state changes
        function MODULE:DoorEnabledToggled(client, door, newState)
            print("Door " .. tostring(door) .. " " .. (newState and "enabled" or "disabled") .. " by " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track door states and notify players
        function MODULE:DoorEnabledToggled(client, door, newState)
            -- Update door state tracking
            self.doorStates = self.doorStates or {}
            self.doorStates[door] = newState

            -- Log the change
            lia.log.add(client:Name() .. " " .. (newState and "enabled" or "disabled") .. " door: " .. tostring(door), FLAG_NORMAL)

            -- Notify nearby players
            local nearbyPlayers = {}
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) < 500 then
                    table.insert(nearbyPlayers, ply)
                end
            end

            if #nearbyPlayers > 0 then
                local message = "Door has been " .. (newState and "enabled" or "disabled") .. " by " .. client:Name()
                for _, ply in ipairs(nearbyPlayers) do
                    ply:ChatPrint(message)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door management with access control and logging
        function MODULE:DoorEnabledToggled(client, door, newState)
            -- Validate permissions
            if not self:HasDoorTogglePermission(client, door) then
                client:notify("You don't have permission to toggle this door.")
                return
            end

            -- Check door ownership/co-ownership
            if not self:IsDoorOwner(client, door) and not self:IsDoorCoOwner(client, door) then
                client:notify("You don't own this door.")
                return
            end

            -- Update door data
            door:setNetVar("enabled", newState)

            -- Handle door state change effects
            if newState then
                self:OnDoorEnabled(client, door)
            else
                self:OnDoorDisabled(client, door)
            end

            -- Update door access lists
            self:UpdateDoorAccessLists(door, newState)

            -- Sync with database
            self:SyncDoorStateToDatabase(door, newState)

            -- Update door statistics
            self:UpdateDoorStatistics(door, client, newState)

            -- Handle special door types
            if self:IsSpecialDoor(door) then
                self:HandleSpecialDoorToggle(door, newState)
            end

            -- Check for conflicting door states
            self:CheckDoorConflicts(door, newState)

            -- Update door visual indicators
            self:UpdateDoorVisualIndicators(door, newState)

            -- Log comprehensive door toggle
            lia.log.add(string.format("Door toggled - Player: %s (%s), Door: %s, State: %s, Location: %s",
                client:Name(),
                client:SteamID(),
                tostring(door),
                newState and "Enabled" or "Disabled",
                tostring(door:GetPos())), FLAG_NORMAL)

            -- Send network update to all relevant players
            self:BroadcastDoorStateUpdate(door, newState, client)

            -- Trigger door toggle hooks
            hook.Run("OnDoorStateChanged", client, door, newState)

            -- Schedule door state verification
            timer.Simple(5, function()
                if IsValid(door) then
                    self:VerifyDoorState(door, newState)
                end
            end)
        end

        -- Helper function to check door toggle permissions
        function MODULE:HasDoorTogglePermission(client, door)
            -- Check admin permissions
            if client:IsAdmin() then return true end

            -- Check door-specific permissions
            local doorData = door:getNetVar("doorData", {})
            if doorData.allowedPlayers then
                for _, steamID in ipairs(doorData.allowedPlayers) do
                    if client:SteamID() == steamID then
                        return true
                    end
                end
            end

            return false
        end

        -- Helper function to check door ownership
        function MODULE:IsDoorOwner(client, door)
            local owner = door:getNetVar("owner")
            return owner and owner == client:SteamID()
        end
        ```
]]
function DoorEnabledToggled(client, door, newState)
end

--[[
    Purpose:
        Handles toggling door hidden state.

    When Called:
        When a door's hidden state is toggled.

    Parameters:
        client (Player)
            The player toggling the door.
        entity (Entity)
            The door entity.
        newState (boolean)
            The new hidden state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door visibility changes
        function MODULE:DoorHiddenToggled(client, entity, newState)
            print("Door " .. tostring(entity) .. " " .. (newState and "hidden" or "shown") .. " by " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track hidden doors and update visibility
        function MODULE:DoorHiddenToggled(client, entity, newState)
            -- Update door visibility tracking
            self.hiddenDoors = self.hiddenDoors or {}
            self.hiddenDoors[entity] = newState

            -- Update door rendering
            entity:SetNoDraw(newState)

            -- Log the change
            lia.log.add(client:Name() .. " " .. (newState and "hid" or "showed") .. " door: " .. tostring(entity), FLAG_NORMAL)

            -- Notify nearby players
            local nearbyPlayers = {}
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(entity:GetPos()) < 300 then
                    table.insert(nearbyPlayers, ply)
                end
            end

            if #nearbyPlayers > 0 then
                local message = "Door has been " .. (newState and "hidden" or "revealed") .. " by " .. client:Name()
                for _, ply in ipairs(nearbyPlayers) do
                    ply:ChatPrint(message)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door visibility management with permissions and effects
        function MODULE:DoorHiddenToggled(client, entity, newState)
            -- Validate permissions
            if not self:CanToggleDoorVisibility(client, entity) then
                client:notify("You don't have permission to toggle door visibility.")
                return
            end

            -- Check if door can be hidden (some doors should always be visible)
            if self:IsCriticalDoor(entity) and newState then
                client:notify("This door cannot be hidden.")
                return
            end

            -- Update door visibility with effects
            if newState then
                self:HideDoorWithEffect(entity, client)
            else
                self:ShowDoorWithEffect(entity, client)
            end

            -- Update door data
            entity:setNetVar("hidden", newState)

            -- Handle visibility-dependent systems
            self:UpdateVisibilityDependentSystems(entity, newState)

            -- Update minimap and radar visibility
            self:UpdateDoorOnMinimap(entity, newState)

            -- Sync visibility state across server
            self:SyncDoorVisibilityState(entity, newState)

            -- Handle door access when hidden
            if newState then
                self:RestrictHiddenDoorAccess(entity)
            else
                self:RestoreDoorAccess(entity)
            end

            -- Update door statistics
            self:UpdateDoorVisibilityStats(entity, client, newState)

            -- Log comprehensive visibility toggle
            lia.log.add(string.format("Door visibility toggled - Player: %s (%s), Door: %s, State: %s, Location: %s",
                client:Name(),
                client:SteamID(),
                tostring(entity),
                newState and "Hidden" or "Visible",
                tostring(entity:GetPos())), FLAG_NORMAL)

            -- Send network update to all players
            self:BroadcastDoorVisibilityUpdate(entity, newState, client)

            -- Trigger visibility change hooks
            hook.Run("OnDoorVisibilityChanged", client, entity, newState)

            -- Schedule visibility verification
            timer.Simple(10, function()
                if IsValid(entity) then
                    self:VerifyDoorVisibility(entity, newState)
                end
            end)
        end

        -- Helper function to check visibility toggle permissions
        function MODULE:CanToggleDoorVisibility(client, entity)
            -- Check admin permissions
            if client:IsAdmin() then return true end

            -- Check door ownership
            local owner = entity:getNetVar("owner")
            if owner and owner == client:SteamID() then return true end

            -- Check co-ownership
            local coOwners = entity:getNetVar("coOwners", {})
            for _, steamID in ipairs(coOwners) do
                if steamID == client:SteamID() then
                    return true
                end
            end

            return false
        end

        -- Helper function to hide door with effect
        function MODULE:HideDoorWithEffect(entity, client)
            -- Create fade effect
            entity:SetRenderMode(RENDERMODE_TRANSALPHA)
            entity:SetColor(Color(255, 255, 255, 0))

            -- Play sound effect
            entity:EmitSound("doors/door_metal_rusty_move1.wav")

            -- Create particle effect
            local effectData = EffectData()
            effectData:SetOrigin(entity:GetPos())
            effectData:SetNormal(entity:GetForward())
            util.Effect("fade_door", effectData)
        end
        ```
]]
function DoorHiddenToggled(client, entity, newState)
end

--[[
    Purpose:
        Handles toggling door lock state.

    When Called:
        When a door's lock state is toggled.

    Parameters:
        client (Player)
            The player toggling the door.
        door (Entity)
            The door entity.
        state (boolean)
            The new lock state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door lock changes
        function MODULE:DoorLockToggled(client, door, state)
            print("Door " .. tostring(door) .. " " .. (state and "locked" or "unlocked") .. " by " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle door locking with sound effects
        function MODULE:DoorLockToggled(client, door, state)
            -- Update door lock state
            door:Fire(state and "Lock" or "Unlock")

            -- Play appropriate sound
            local soundPath = state and "doors/door_locked2.wav" or "doors/door_latch1.wav"
            door:EmitSound(soundPath)

            -- Log the change
            lia.log.add(client:Name() .. " " .. (state and "locked" or "unlocked") .. " door: " .. tostring(door), FLAG_NORMAL)

            -- Notify nearby players
            local nearbyPlayers = {}
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) < 200 then
                    table.insert(nearbyPlayers, ply)
                end
            end

            if #nearbyPlayers > 0 then
                local message = "Door has been " .. (state and "locked" or "unlocked") .. " by " .. client:Name()
                for _, ply in ipairs(nearbyPlayers) do
                    ply:ChatPrint(message)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door locking with access control and security features
        function MODULE:DoorLockToggled(client, door, state)
            -- Validate lock/unlock permissions
            if not self:CanLockDoor(client, door) then
                client:notify("You don't have permission to " .. (state and "lock" or "unlock") .. " this door.")
                return
            end

            -- Check door lock restrictions (some doors might be permanently locked/unlocked)
            if self:IsRestrictedDoor(door) then
                local restriction = self:GetDoorRestriction(door)
                if (state and restriction.noLock) or (not state and restriction.noUnlock) then
                    client:notify("This door's lock state cannot be changed.")
                    return
                end
            end

            -- Handle electronic lock systems
            if self:IsElectronicLock(door) then
                self:HandleElectronicLock(door, state, client)
            else
                -- Handle mechanical lock
                self:HandleMechanicalLock(door, state, client)
            end

            -- Update door data
            door:setNetVar("locked", state)

            -- Handle lock state effects
            if state then
                self:OnDoorLocked(door, client)
            else
                self:OnDoorUnlocked(door, client)
            end

            -- Update access control systems
            self:UpdateAccessControl(door, state)

            -- Handle security systems
            if state then
                self:ActivateDoorSecurity(door)
            else
                self:DeactivateDoorSecurity(door)
            end

            -- Update door lock statistics
            self:UpdateDoorLockStats(door, client, state)

            -- Check for auto-lock features
            if not state and self:ShouldAutoLock(door) then
                self:ScheduleAutoLock(door)
            end

            -- Handle key management
            self:UpdateDoorKeys(door, state, client)

            -- Log comprehensive lock toggle
            lia.log.add(string.format("Door lock toggled - Player: %s (%s), Door: %s, State: %s, Location: %s",
                client:Name(),
                client:SteamID(),
                tostring(door),
                state and "Locked" or "Unlocked",
                tostring(door:GetPos())), FLAG_NORMAL)

            -- Send network update to relevant players
            self:BroadcastDoorLockUpdate(door, state, client)

            -- Trigger lock state change hooks
            hook.Run("OnDoorLockStateChanged", client, door, state)

            -- Handle alarm systems
            if self:ShouldTriggerAlarm(door, state, client) then
                self:TriggerDoorAlarm(door, state, client)
            end
        end

        -- Helper function to check door locking permissions
        function MODULE:CanLockDoor(client, door)
            -- Check admin permissions
            if client:IsAdmin() then return true end

            -- Check door ownership
            local owner = door:getNetVar("owner")
            if owner and owner == client:SteamID() then return true end

            -- Check co-ownership
            local coOwners = door:getNetVar("coOwners", {})
            for _, steamID in ipairs(coOwners) do
                if steamID == client:SteamID() then
                    return true
                end
            end

            -- Check granted permissions
            local allowedPlayers = door:getNetVar("allowedPlayers", {})
            for _, steamID in ipairs(allowedPlayers) do
                if steamID == client:SteamID() then
                    return true
                end
            end

            return false
        end

        -- Helper function to handle mechanical locks
        function MODULE:HandleMechanicalLock(door, state, client)
            -- Fire door lock/unlock
            door:Fire(state and "Lock" or "Unlock")

            -- Play sound effect
            local soundPath = state and "doors/door_locked2.wav" or "doors/door_latch1.wav"
            door:EmitSound(soundPath)

            -- Create visual effect
            local effectData = EffectData()
            effectData:SetOrigin(door:GetPos() + door:GetForward() * 10)
            effectData:SetNormal(door:GetForward())
            util.Effect(state and "lock_door" or "unlock_door", effectData)
        end
        ```
]]
function DoorLockToggled(client, door, state)
end

--[[
    Purpose:
        Handles toggling door ownable state.

    When Called:
        When a door's ownable state is toggled.

    Parameters:
        client (Player)
            The player toggling the door.
        door (Entity)
            The door entity.
        newState (boolean)
            The new ownable state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door ownable changes
        function MODULE:DoorOwnableToggled(client, door, newState)
            print("Door " .. tostring(door) .. " " .. (newState and "can now be owned" or "can no longer be owned") .. " by " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle door ownership toggling with notifications
        function MODULE:DoorOwnableToggled(client, door, newState)
            -- Update door ownable state
            door:setNetVar("ownable", newState)

            -- Clear ownership if making unownable
            if not newState then
                door:setNetVar("owner", nil)
                door:setNetVar("coOwners", {})
                door:setNetVar("allowedPlayers", {})
            end

            -- Log the change
            lia.log.add(client:Name() .. " made door " .. tostring(door) .. " " ..
                (newState and "ownable" or "unownable"), FLAG_NORMAL)

            -- Notify nearby players
            local nearbyPlayers = {}
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) < 300 then
                    table.insert(nearbyPlayers, ply)
                end
            end

            if #nearbyPlayers > 0 then
                local message = "Door ownership has been " ..
                    (newState and "enabled" or "disabled") .. " by " .. client:Name()
                for _, ply in ipairs(nearbyPlayers) do
                    ply:ChatPrint(message)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door ownership management with validation and cleanup
        function MODULE:DoorOwnableToggled(client, door, newState)
            -- Validate permissions
            if not self:CanToggleDoorOwnable(client, door) then
                client:notify("You don't have permission to change door ownership settings.")
                return
            end

            -- Check if door can be made ownable/unownable
            if not newState and self:IsCriticalDoor(door) then
                client:notify("Critical doors cannot be made unownable.")
                return
            end

            -- Handle transition effects
            if newState then
                self:EnableDoorOwnership(door, client)
            else
                self:DisableDoorOwnership(door, client)
            end

            -- Update door data
            door:setNetVar("ownable", newState)

            -- Handle ownership cleanup when disabling
            if not newState then
                self:CleanupDoorOwnership(door, client)
            end

            -- Update door ownership statistics
            self:UpdateDoorOwnershipStats(door, client, newState)

            -- Handle door listing systems
            self:UpdateDoorListings(door, newState)

            -- Update property management systems
            self:UpdatePropertyManagement(door, newState)

            -- Handle rental systems
            if newState then
                self:EnableDoorRental(door)
            else
                self:DisableDoorRental(door)
            end

            -- Update door value calculations
            self:RecalculateDoorValue(door, newState)

            -- Log comprehensive ownership toggle
            lia.log.add(string.format("Door ownership toggled - Player: %s (%s), Door: %s, State: %s, Location: %s",
                client:Name(),
                client:SteamID(),
                tostring(door),
                newState and "Ownable" or "Unownable",
                tostring(door:GetPos())), FLAG_NORMAL)

            -- Send network update to all players
            self:BroadcastDoorOwnershipUpdate(door, newState, client)

            -- Trigger ownership change hooks
            hook.Run("OnDoorOwnershipToggled", client, door, newState)

            -- Handle property tax implications
            if not newState then
                self:HandleOwnershipRemovalTaxes(door, client)
            end

            -- Schedule ownership verification
            timer.Simple(5, function()
                if IsValid(door) then
                    self:VerifyDoorOwnershipState(door, newState)
                end
            end)
        end

        -- Helper function to check ownership toggle permissions
        function MODULE:CanToggleDoorOwnable(client, door)
            -- Check super admin permissions
            if client:IsSuperAdmin() then return true end

            -- Check server ownership
            if door:getNetVar("serverOwned") then
                return client:hasPrivilege("Manage Server Property")
            end

            return false
        end

        -- Helper function to cleanup door ownership
        function MODULE:CleanupDoorOwnership(door, client)
            local owner = door:getNetVar("owner")
            local coOwners = door:getNetVar("coOwners", {})
            local allowedPlayers = door:getNetVar("allowedPlayers", {})

            -- Refund ownership costs if applicable
            if owner then
                self:ProcessOwnershipRefund(door, owner, client)
            end

            -- Clear all ownership data
            door:setNetVar("owner", nil)
            door:setNetVar("coOwners", {})
            door:setNetVar("allowedPlayers", {})
            door:setNetVar("ownershipData", {})

            -- Update property records
            self:RemoveFromPropertyRecords(door)

            -- Notify affected players
            self:NotifyOwnershipRemoval(door, owner, coOwners, allowedPlayers)
        end
        ```
]]
function DoorOwnableToggled(client, door, newState)
end

--[[
    Purpose:
        Handles setting door price.

    When Called:
        When a door's price is set.

    Parameters:
        client (Player)
            The player setting the price.
        door (Entity)
            The door entity.
        price (number)
            The new price.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door price changes
        function MODULE:DoorPriceSet(client, door, price)
            print("Door " .. tostring(door) .. " price set to $" .. price .. " by " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate and set door price
        function MODULE:DoorPriceSet(client, door, price)
            -- Validate price range
            if price < 0 then
                client:notify("Door price cannot be negative.")
                return
            end

            if price > 100000 then
                client:notify("Door price cannot exceed $100,000.")
                return
            end

            -- Update door price
            door:setNetVar("price", price)

            -- Log the change
            lia.log.add(client:Name() .. " set door " .. tostring(door) .. " price to $" .. price, FLAG_NORMAL)

            -- Notify nearby players
            local nearbyPlayers = {}
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) < 300 then
                    table.insert(nearbyPlayers, ply)
                end
            end

            if #nearbyPlayers > 0 then
                local message = "Door price set to $" .. price .. " by " .. client:Name()
                for _, ply in ipairs(nearbyPlayers) do
                    ply:ChatPrint(message)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door pricing with validation, market analysis, and economic systems
        function MODULE:DoorPriceSet(client, door, price)
            -- Validate permissions
            if not self:CanSetDoorPrice(client, door) then
                client:notify("You don't have permission to set door prices.")
                return
            end

            -- Validate price parameters
            local validation = self:ValidateDoorPrice(price, door)
            if not validation.valid then
                client:notify(validation.error)
                return
            end

            -- Get previous price for comparison
            local oldPrice = door:getNetVar("price", 0)

            -- Apply economic modifiers
            price = self:ApplyEconomicModifiers(price, door, client)

            -- Check for price change restrictions
            if self:IsPriceChangeRestricted(door, oldPrice, price, client) then
                client:notify("Price change is restricted for this door.")
                return
            end

            -- Handle price history tracking
            self:UpdateDoorPriceHistory(door, oldPrice, price, client)

            -- Update door market value
            self:UpdateDoorMarketValue(door, price)

            -- Apply location-based pricing modifiers
            price = self:ApplyLocationModifiers(price, door)

            -- Handle tax implications
            local taxAmount = self:CalculatePriceChangeTax(price, oldPrice)
            if taxAmount > 0 then
                self:ProcessPriceChangeTax(client, taxAmount)
            end

            -- Update door data
            door:setNetVar("price", price)
            door:setNetVar("lastPriceChange", os.time())
            door:setNetVar("priceSetBy", client:SteamID())

            -- Update property listings
            self:UpdatePropertyListings(door, price)

            -- Handle price alerts and notifications
            self:SendPriceChangeAlerts(door, oldPrice, price, client)

            -- Update real estate market data
            self:UpdateMarketData(door, price)

            -- Calculate and apply appreciation/depreciation
            self:CalculatePropertyAppreciation(door, oldPrice, price)

            -- Log comprehensive price change
            lia.log.add(string.format("Door price set - Player: %s (%s), Door: %s, Old Price: $%d, New Price: $%d, Location: %s",
                client:Name(),
                client:SteamID(),
                tostring(door),
                oldPrice,
                price,
                tostring(door:GetPos())), FLAG_NORMAL)

            -- Send network update to relevant players
            self:BroadcastDoorPriceUpdate(door, price, client)

            -- Trigger price change hooks
            hook.Run("OnDoorPriceChanged", client, door, oldPrice, price)

            -- Handle auction system integration
            if self:IsDoorInAuction(door) then
                self:UpdateAuctionPrice(door, price)
            end

            -- Schedule price verification
            timer.Simple(10, function()
                if IsValid(door) then
                    self:VerifyDoorPrice(door, price)
                end
            end)
        end

        -- Helper function to validate door price setting permissions
        function MODULE:CanSetDoorPrice(client, door)
            -- Check admin permissions
            if client:IsAdmin() then return true end

            -- Check door ownership
            local owner = door:getNetVar("owner")
            if owner and owner == client:SteamID() then return true end

            -- Check property management permissions
            if client:hasPrivilege("Manage Properties") then return true end

            return false
        end

        -- Helper function to validate door price
        function MODULE:ValidateDoorPrice(price, door)
            -- Check price range
            if price < 0 then
                return {valid = false, error = "Door price cannot be negative."}
            end

            if price > self.maxDoorPrice then
                return {valid = false, error = "Door price cannot exceed $" .. self.maxDoorPrice .. "."}
            end

            -- Check price change rate limits
            local lastChange = door:getNetVar("lastPriceChange", 0)
            if os.time() - lastChange < self.priceChangeCooldown then
                return {valid = false, error = "Please wait before changing the price again."}
            end

            return {valid = true}
        end

        -- Helper function to apply economic modifiers
        function MODULE:ApplyEconomicModifiers(price, door, client)
            -- Apply inflation modifier
            price = price * self.economyInflationRate

            -- Apply location-based modifier
            local locationBonus = self:GetLocationValueBonus(door:GetPos())
            price = price * (1 + locationBonus)

            -- Apply player reputation modifier
            local reputationMod = self:GetPlayerReputationModifier(client)
            price = price * (1 + reputationMod)

            return math.floor(price)
        end
        ```
]]
function DoorPriceSet(client, door, price)
end

--[[
    Purpose:
        Handles setting door title.

    When Called:
        When a door's title is set.

    Parameters:
        client (Player)
            The player setting the title.
        door (Entity)
            The door entity.
        name (string)
            The new title.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door title changes
        function MODULE:DoorTitleSet(client, door, name)
            lia.log.add(client:Name() .. " set door title to: " .. name)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate and sanitize door titles
        function MODULE:DoorTitleSet(client, door, name)
            -- Sanitize the name
            local sanitized = string.Trim(name)
            if string.len(sanitized) > 50 then
                sanitized = string.sub(sanitized, 1, 50)
            end

            -- Log the change
            lia.log.add(client:Name() .. " set door title to: " .. sanitized)

            -- Update door data
            door:setNetVar("title", sanitized)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door title system with permissions and validation
        function MODULE:DoorTitleSet(client, door, name)
            if not IsValid(door) or not IsValid(client) then return end

            -- Check if player owns the door
            local doorData = door:getNetVar("doorData")
            if not doorData or doorData.owner ~= client:SteamID() then
                client:notify("You don't own this door!")
                return
            end

            -- Validate and sanitize
            local sanitized = string.Trim(name)
            if string.len(sanitized) == 0 then
                client:notify("Door title cannot be empty")
                return
            end

            if string.len(sanitized) > 50 then
                sanitized = string.sub(sanitized, 1, 50)
                client:notify("Door title truncated to 50 characters")
            end

            -- Check for profanity
            if self:ContainsProfanity(sanitized) then
                client:notify("Door title contains inappropriate content")
                lia.log.add(client:Name() .. " attempted to set inappropriate door title: " .. sanitized, FLAG_WARNING)
                return
            end

            -- Update door data
            door:setNetVar("title", sanitized)

            -- Log the change
            lia.log.add(client:Name() .. " (" .. client:SteamID() .. ") set door title to: " .. sanitized)

            -- Notify nearby players
            for _, ply in player.Iterator() do
                if ply:GetPos():Distance(door:GetPos()) < 200 then
                    ply:notify(client:Name() .. " set the door title to: " .. sanitized)
                end
            end
        end
        ```
]]
function DoorTitleSet(client, door, name)
end

--[[
    Purpose:
        Handles fetching spawn points.

    When Called:
        When spawn points need to be retrieved.

    Parameters:
        None

    Returns:
        table
            Table of spawn points.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return basic spawn points
        function MODULE:FetchSpawns()
            return {
                {pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
            }
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get spawn points from map data
        function MODULE:FetchSpawns()
            local spawns = {}
            local mapName = game.GetMap()

            -- Get spawn points from config
            if lia.config.get("SpawnPoints") then
                spawns = table.Copy(lia.config.get("SpawnPoints"))
            end

            -- Add default spawn if none exist
            if #spawns == 0 then
                table.insert(spawns, {
                    pos = Vector(0, 0, 0),
                    ang = Angle(0, 0, 0),
                    name = "Default Spawn"
                })
            end

            return spawns
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced spawn system with faction/class filtering
        function MODULE:FetchSpawns()
            local spawns = {}
            local mapName = game.GetMap()

            -- Load spawns from database
            lia.db.query("SELECT * FROM spawns WHERE map = ?", {mapName}, function(data)
                if data and #data > 0 then
                    for _, spawn in ipairs(data) do
                        table.insert(spawns, {
                            pos = util.StringToType(spawn.position, "Vector"),
                            ang = util.StringToType(spawn.angle, "Angle"),
                            name = spawn.name or "Spawn",
                            faction = spawn.faction,
                            class = spawn.class,
                            team = spawn.team
                        })
                    end
                end
            end)

            -- Fallback to config spawns
            if #spawns == 0 and lia.config.get("SpawnPoints") then
                spawns = table.Copy(lia.config.get("SpawnPoints"))
            end

            -- Validate spawns
            for i = #spawns, 1, -1 do
                local spawn = spawns[i]
                if not spawn.pos or spawn.pos == Vector(0, 0, 0) then
                    table.remove(spawns, i)
                end
            end

            -- Add default spawn if still empty
            if #spawns == 0 then
                table.insert(spawns, {
                    pos = Vector(0, 0, 0),
                    ang = Angle(0, 0, 0),
                    name = "Default Spawn"
                })
            end

            return spawns
        end
        ```
]]
function FetchSpawns()
end

--[[
    Purpose:
        Forces a character's recognition range.

    When Called:
        When forcing character recognition.

    Parameters:
        player (Player)
            The player being recognized.
        range (number)
            The recognition range.
        fakeName (string)
            Optional fake name for recognition.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Force recognition for all nearby players
        function MODULE:ForceRecognizeRange(player, range, fakeName)
            if IsValid(player) then
                player:SetNetVar("forceRecognized", true)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Force recognition with custom range
        function MODULE:ForceRecognizeRange(player, range, fakeName)
            if not IsValid(player) then return end

            local character = player:getChar()
            if not character then return end

            -- Set recognition data
            character:setData("forceRecognized", true)
            character:setData("recognitionRange", range or 500)

            if fakeName then
                character:setData("fakeName", fakeName)
            end

            -- Notify player
            player:notify("You have been force recognized")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced recognition system with logging and notifications
        function MODULE:ForceRecognizeRange(player, range, fakeName)
            if not IsValid(player) then return end

            local character = player:getChar()
            if not character then return end

            -- Validate range
            local validRange = math.Clamp(range or 500, 0, 10000)

            -- Set recognition data
            character:setData("forceRecognized", true)
            character:setData("recognitionRange", validRange)
            character:setData("recognitionTime", CurTime())

            if fakeName then
                character:setData("fakeName", fakeName)
                character:setData("usingFakeName", true)
            end

            -- Notify all nearby players
            for _, ply in player.Iterator() do
                if ply ~= player and ply:GetPos():Distance(player:GetPos()) <= validRange then
                    local targetChar = ply:getChar()
                    if targetChar then
                        targetChar:setData("recognized_" .. character:getID(), true)
                        ply:notify("You recognized " .. (fakeName or character:getName()))
                    end
                end
            end

            -- Log the action
            lia.log.add("Force recognized " .. player:Name() .. " with range " .. validRange, FLAG_ADMIN)

            -- Notify target
            player:notify("You have been force recognized with range: " .. validRange)
        end
        ```
]]
function ForceRecognizeRange(player, range, fakeName)
end

--[[
    Purpose:
        Gets admin stick information lists.

    When Called:
        When retrieving admin stick information.

    Parameters:
        target (Player)
            The target player.
        lists (table)
            The information lists.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic player info to lists
        function MODULE:GetAdminStickLists(target, lists)
            if IsValid(target) then
                table.insert(lists, "Name: " .. target:Name())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted player information
        function MODULE:GetAdminStickLists(target, lists)
            if not IsValid(target) then return end

            local character = target:getChar()
            if character then
                table.insert(lists, "Character: " .. character:getName())
                table.insert(lists, "Faction: " .. (lia.faction.get(character:getFaction()) and lia.faction.get(character:getFaction()).name or "Unknown"))
                table.insert(lists, "Money: " .. lia.currency.get(character:getMoney()))
                table.insert(lists, "Health: " .. target:Health() .. "/" .. target:GetMaxHealth())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive admin information with multiple categories
        function MODULE:GetAdminStickLists(target, lists)
            if not IsValid(target) then return end

            local character = target:getChar()
            if not character then return end

            -- Basic Info
            table.insert(lists, {
                category = "Basic Info",
                items = {
                    "SteamID: " .. target:SteamID(),
                    "Character: " .. character:getName(),
                    "Character ID: " .. character:getID(),
                    "Playtime: " .. lia.time.formatDHM(target:getPlayTime())
                }
            })

            -- Character Info
            local faction = lia.faction.get(character:getFaction())
            local class = lia.class.get(character:getClass())
            table.insert(lists, {
                category = "Character",
                items = {
                    "Faction: " .. (faction and faction.name or "Unknown"),
                    "Class: " .. (class and class.name or "Unknown"),
                    "Money: " .. lia.currency.get(character:getMoney()),
                    "Level: " .. (character:getData("level") or 1)
                }
            })

            -- Status Info
            table.insert(lists, {
                category = "Status",
                items = {
                    "Health: " .. target:Health() .. "/" .. target:GetMaxHealth(),
                    "Armor: " .. target:Armor() .. "/" .. target:GetMaxArmor(),
                    "Position: " .. tostring(target:GetPos()),
                    "Angle: " .. tostring(target:GetAngles())
                }
            })

            -- Warnings
            hook.Run("GetWarnings", character:getID()):next(function(warnings)
                if warnings and #warnings > 0 then
                    table.insert(lists, {
                        category = "Warnings",
                        items = {}
                    })
                    for i, warning in ipairs(warnings) do
                        table.insert(lists[#lists].items, "Warning #" .. i .. ": " .. warning.message)
                    end
                end
            end)
        end
        ```
]]
function GetAdminStickLists(target, lists)
end

--[[
    Purpose:
        Gets all case claims.

    When Called:
        When retrieving case claim information.

    Parameters:
        None

    Returns:
        table
            Table of case claims.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return empty claims table
        function MODULE:GetAllCaseClaims()
            return {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get claims from database
        function MODULE:GetAllCaseClaims()
            local claims = {}

            lia.db.query("SELECT * FROM case_claims", {}, function(data)
                if data then
                    claims = data
                end
            end)

            return claims
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced case claims system with filtering and validation
        function MODULE:GetAllCaseClaims()
            local claims = {}

            -- Query database for all claims
            lia.db.query("SELECT * FROM case_claims WHERE status = ? ORDER BY created DESC", {"active"}, function(data)
                if data and #data > 0 then
                    for _, claim in ipairs(data) do
                        -- Validate claim data
                        if claim.requester and claim.message and claim.ticketID then
                            -- Get requester info
                            local requester = player.GetBySteamID(claim.requester)
                            local requesterName = claim.requester
                            if IsValid(requester) then
                                local char = requester:getChar()
                                if char then
                                    requesterName = char:getName()
                                else
                                    requesterName = requester:Name()
                                end
                            end

                            -- Get claimer info if exists
                            local claimerName = nil
                            if claim.claimer then
                                local claimer = player.GetBySteamID(claim.claimer)
                                if IsValid(claimer) then
                                    local char = claimer:getChar()
                                    if char then
                                        claimerName = char:getName()
                                    else
                                        claimerName = claimer:Name()
                                    end
                                end
                            end

                            table.insert(claims, {
                                id = claim.id,
                                ticketID = claim.ticketID,
                                requester = claim.requester,
                                requesterName = requesterName,
                                claimer = claim.claimer,
                                claimerName = claimerName,
                                message = claim.message,
                                status = claim.status,
                                created = claim.created,
                                claimed = claim.claimed,
                                priority = claim.priority or "normal"
                            })
                        end
                    end
                end
            end)

            -- Sort by priority and date
            table.SortByMember(claims, "priority", function(a, b)
                local priorityOrder = {high = 1, medium = 2, normal = 3, low = 4}
                local aPriority = priorityOrder[a.priority] or 3
                local bPriority = priorityOrder[b.priority] or 3

                if aPriority ~= bPriority then
                    return aPriority < bPriority
                end

                return tonumber(a.created) > tonumber(b.created)
            end)

            return claims
        end
        ```
]]
function GetAllCaseClaims()
end

--[[
    Purpose:
        Gets door information.

    When Called:
        When retrieving door data for display.

    Parameters:
        entity (Entity)
            The door entity.
        doorData (table)
            The door data.
        doorInfo (table)
            The door information.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic door name
        function MODULE:GetDoorInfo(entity, doorData, doorInfo)
            if doorData.name then
                table.insert(doorInfo, doorData.name)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted door information
        function MODULE:GetDoorInfo(entity, doorData, doorInfo)
            if doorData.name then
                table.insert(doorInfo, {text = "Door: " .. doorData.name, color = color_white})
            end

            if doorData.locked then
                table.insert(doorInfo, {text = "Locked", color = Color(255, 0, 0)})
            else
                table.insert(doorInfo, {text = "Unlocked", color = Color(0, 255, 0)})
            end

            if doorData.owner then
                table.insert(doorInfo, {text = "Owner: " .. doorData.owner, color = Color(200, 200, 200)})
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door info with access control display
        function MODULE:GetDoorInfo(entity, doorData, doorInfo)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Door name
            if doorData.name then
                table.insert(doorInfo, {
                    text = doorData.name,
                    color = Color(255, 255, 255),
                    priority = 1
                })
            end

            -- Ownership information
            if doorData.ownable then
                if doorData.owner then
                    local owner = player.GetBySteamID(doorData.owner)
                    local ownerName = doorData.owner
                    if IsValid(owner) then
                        local ownerChar = owner:getChar()
                        if ownerChar then
                            ownerName = ownerChar:getName()
                        end
                    end
                    table.insert(doorInfo, {
                        text = "Owner: " .. ownerName,
                        color = Color(100, 200, 100),
                        priority = 2
                    })
                else
                    if doorData.price and doorData.price > 0 then
                        table.insert(doorInfo, {
                            text = "For Sale: " .. lia.currency.get(doorData.price),
                            color = Color(255, 255, 100),
                            priority = 2
                        })
                    else
                        table.insert(doorInfo, {
                            text = "Unowned",
                            color = Color(200, 200, 200),
                            priority = 2
                        })
                    end
                end
            end

            -- Lock status
            if doorData.locked then
                local canAccess = hook.Run("CanPlayerAccessDoor", client, entity, DOOR_ACCESS_USE) or false
                table.insert(doorInfo, {
                    text = canAccess and "Locked (You have access)" or "Locked",
                    color = canAccess and Color(255, 200, 100) or Color(255, 100, 100),
                    priority = 3
                })
            else
                table.insert(doorInfo, {
                    text = "Unlocked",
                    color = Color(100, 255, 100),
                    priority = 3
                })
            end

            -- Faction/class restrictions
            if doorData.factions then
                local hasAccess = false
                for _, factionID in ipairs(doorData.factions) do
                    if character:getFaction() == factionID then
                        hasAccess = true
                        break
                    end
                end
                if not hasAccess then
                    table.insert(doorInfo, {
                        text = "Restricted Access",
                        color = Color(255, 150, 150),
                        priority = 4
                    })
                end
            end
        end
        ```
]]
function GetDoorInfo(entity, doorData, doorInfo)
end

--[[
    Purpose:
        Gets door information for admin stick.

    When Called:
        When displaying door info in admin tools.

    Parameters:
        target (Player)
            The target player.
        extraInfo (table)
            Additional information.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic door count
        function MODULE:GetDoorInfoForAdminStick(target, extraInfo)
            if IsValid(target) then
                local doorCount = 0
                for _, door in ipairs(ents.FindByClass("prop_door_rotating")) do
                    local doorData = door:getNetVar("doorData")
                    if doorData and doorData.owner == target:SteamID() then
                        doorCount = doorCount + 1
                    end
                end
                table.insert(extraInfo, "Owned Doors: " .. doorCount)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted door ownership info
        function MODULE:GetDoorInfoForAdminStick(target, extraInfo)
            if not IsValid(target) then return end

            local character = target:getChar()
            if not character then return end

            local ownedDoors = {}
            local totalValue = 0

            for _, door in ipairs(ents.FindByClass("prop_door_rotating")) do
                local doorData = door:getNetVar("doorData")
                if doorData and doorData.owner == target:SteamID() then
                    table.insert(ownedDoors, {
                        name = doorData.name or "Unnamed Door",
                        price = doorData.price or 0,
                        locked = doorData.locked or false
                    })
                    totalValue = totalValue + (doorData.price or 0)
                end
            end

            if #ownedDoors > 0 then
                table.insert(extraInfo, "Owned Doors: " .. #ownedDoors)
                table.insert(extraInfo, "Total Door Value: " .. lia.currency.get(totalValue))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive door information with detailed stats
        function MODULE:GetDoorInfoForAdminStick(target, extraInfo)
            if not IsValid(target) then return end

            local character = target:getChar()
            if not character then return end

            local ownedDoors = {}
            local lockedDoors = 0
            local unlockedDoors = 0
            local totalValue = 0
            local factionDoors = 0

            -- Scan all doors
            for _, door in ipairs(ents.FindByClass("prop_door_rotating")) do
                local doorData = door:getNetVar("doorData")
                if doorData then
                    local isOwner = doorData.owner == target:SteamID()
                    local hasAccess = false

                    -- Check faction access
                    if doorData.factions then
                        for _, factionID in ipairs(doorData.factions) do
                            if character:getFaction() == factionID then
                                hasAccess = true
                                factionDoors = factionDoors + 1
                                break
                            end
                        end
                    end

                    if isOwner then
                        table.insert(ownedDoors, {
                            name = doorData.name or "Unnamed Door",
                            price = doorData.price or 0,
                            locked = doorData.locked or false,
                            position = door:GetPos()
                        })
                        totalValue = totalValue + (doorData.price or 0)

                        if doorData.locked then
                            lockedDoors = lockedDoors + 1
                        else
                            unlockedDoors = unlockedDoors + 1
                        end
                    end
                end
            end

            -- Add formatted information
            if #ownedDoors > 0 then
                table.insert(extraInfo, {
                    category = "Door Ownership",
                    items = {
                        "Total Owned: " .. #ownedDoors,
                        "Locked: " .. lockedDoors,
                        "Unlocked: " .. unlockedDoors,
                        "Total Value: " .. lia.currency.get(totalValue)
                    }
                })
            end

            if factionDoors > 0 then
                table.insert(extraInfo, {
                    category = "Faction Access",
                    items = {
                        "Faction Doors: " .. factionDoors
                    }
                })
            end
        end
        ```
]]
function GetDoorInfoForAdminStick(target, extraInfo)
end

--[[
    Purpose:
        Gets entity save data.

    When Called:
        When preparing entity data for saving.

    Parameters:
        entity (Entity)
            The entity to save.

    Returns:
        table
            The save data.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return basic entity data
        function MODULE:GetEntitySaveData(entity)
            if IsValid(entity) then
                return {
                    class = entity:GetClass(),
                    pos = entity:GetPos(),
                    ang = entity:GetAngles()
                }
            end
            return {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Save entity with custom properties
        function MODULE:GetEntitySaveData(entity)
            if not IsValid(entity) then return {} end

            local data = {
                class = entity:GetClass(),
                model = entity:GetModel(),
                pos = entity:GetPos(),
                ang = entity:GetAngles(),
                material = entity:GetMaterial(),
                color = entity:GetColor(),
                skin = entity:GetSkin()
            }

            -- Save custom data if exists
            if entity:getNetVar("customData") then
                data.customData = entity:getNetVar("customData")
            end

            return data
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced entity saving with validation and custom properties
        function MODULE:GetEntitySaveData(entity)
            if not IsValid(entity) then return {} end

            -- Check if entity should be saved
            if not hook.Run("CanPersistEntity", entity) then
                return {}
            end

            local data = {
                class = entity:GetClass(),
                model = entity:GetModel(),
                pos = entity:GetPos(),
                ang = entity:GetAngles(),
                material = entity:GetMaterial(),
                color = entity:GetColor(),
                skin = entity:GetSkin(),
                bodygroups = {},
                scale = entity:GetModelScale(),
                frozen = entity:IsFrozen(),
                collision = entity:GetCollisionGroup()
            }

            -- Save bodygroups
            for i = 0, entity:GetNumBodyGroups() - 1 do
                data.bodygroups[i] = entity:GetBodygroup(i)
            end

            -- Save custom netvars
            local customNetVars = entity:getNetVar("saveData") or {}
            for key, value in pairs(customNetVars) do
                data[key] = value
            end

            -- Save inventory if entity has one
            if entity:getNetVar("inventoryID") then
                data.inventoryID = entity:getNetVar("inventoryID")
            end

            -- Save door data if it's a door
            if entity:getNetVar("doorData") then
                local doorData = entity:getNetVar("doorData")
                data.doorData = {
                    name = doorData.name,
                    owner = doorData.owner,
                    locked = doorData.locked,
                    ownable = doorData.ownable,
                    price = doorData.price
                }
            end

            -- Validate data
            if not data.pos or data.pos == Vector(0, 0, 0) then
                return {}
            end

            return data
        end
        ```
]]
function GetEntitySaveData(entity)
end

--[[
    Purpose:
        Gets the maximum number of characters per player.

    When Called:
        When checking character limits.

    Parameters:
        client (Player)
            The player.

    Returns:
        number
            The maximum character count.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return default character limit
        function MODULE:GetMaxPlayerChar(client)
            return 3
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Return limit based on player rank
        function MODULE:GetMaxPlayerChar(client)
            if not IsValid(client) then return 3 end

            -- Check if player is VIP
            if client:IsUserGroup("vip") then
                return 5
            elseif client:IsUserGroup("superadmin") then
                return 10
            end

            return 3
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character limit system with multiple factors
        function MODULE:GetMaxPlayerChar(client)
            if not IsValid(client) then return 3 end

            local baseLimit = lia.config.get("MaxCharacters", 3)
            local additionalSlots = 0

            -- Check user group bonuses
            local userGroups = {
                ["vip"] = 2,
                ["premium"] = 3,
                ["superadmin"] = 7,
                ["admin"] = 5
            }

            for group, bonus in pairs(userGroups) do
                if client:IsUserGroup(group) then
                    additionalSlots = math.max(additionalSlots, bonus)
                end
            end

            -- Check playtime bonuses
            hook.Run("GetPlayTime", client):next(function(playTime)
                if playTime and playTime > 2592000 then -- 30 days
                    additionalSlots = additionalSlots + 1
                end
            end)

            -- Check donation status
            if client:getData("donator", false) then
                additionalSlots = additionalSlots + 2
            end

            -- Calculate final limit
            local finalLimit = baseLimit + additionalSlots
            local maxLimit = lia.config.get("MaxCharacterLimit", 10)

            return math.Clamp(finalLimit, 1, maxLimit)
        end
        ```
]]
function GetMaxPlayerChar(client)
end

--[[
    Purpose:
        Gets the play time for a player.

    When Called:
        When retrieving player statistics.

    Parameters:
        client (Player)
            The player.

    Returns:
        number
            The play time in seconds.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return playtime from character data
        function MODULE:GetPlayTime(client)
            if not IsValid(client) then return 0 end

            local character = client:getChar()
            if character then
                return character:getData("playTime", 0)
            end

            return 0
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Calculate total playtime across all characters
        function MODULE:GetPlayTime(client)
            if not IsValid(client) then return 0 end

            local totalPlayTime = 0

            -- Get playtime from current character
            local character = client:getChar()
            if character then
                totalPlayTime = totalPlayTime + (character:getData("playTime", 0))
            end

            -- Add playtime from other characters if stored
            local allPlayTime = client:getData("totalPlayTime", 0)
            if allPlayTime > 0 then
                totalPlayTime = totalPlayTime + allPlayTime
            end

            return totalPlayTime
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced playtime tracking with database integration
        function MODULE:GetPlayTime(client)
            if not IsValid(client) then return 0 end

            local steamID = client:SteamID()
            local totalPlayTime = 0

            -- Query database for total playtime across all characters
            lia.db.query("SELECT SUM(playTime) as total FROM characters WHERE _steamID = ?", {steamID}, function(data)
                if data and data[1] and data[1].total then
                    totalPlayTime = tonumber(data[1].total) or 0
                end
            end)

            -- Add current session time
            local sessionStart = client:getData("sessionStart", CurTime())
            local sessionTime = CurTime() - sessionStart
            totalPlayTime = totalPlayTime + sessionTime

            -- Cache the result
            client:setData("cachedPlayTime", totalPlayTime)

            -- Update playtime display
            hook.Run("OnPlayTimeUpdated", client, totalPlayTime)

            return totalPlayTime
        end
        ```
]]
function GetPlayTime(client)
end

--[[
    Purpose:
        Gets the price override for vendor items.

    When Called:
        When calculating vendor prices.

    Parameters:
        vendor (Entity)
            The vendor entity.
        uniqueID (string)
            The item unique ID.
        price (number)
            The base price.
        isSellingToVendor (boolean)
            Whether selling to vendor.

    Returns:
        number
            The overridden price.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Apply fixed discount
        function MODULE:GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)
            if isSellingToVendor then
                return price * 0.5 -- 50% of value when selling
            end
            return price
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply vendor-specific pricing
        function MODULE:GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)
            if not IsValid(vendor) then return price end

            local vendorData = vendor:getNetVar("vendorData")
            if not vendorData then return price end

            -- Check for custom price override
            if vendorData.prices and vendorData.prices[uniqueID] then
                return vendorData.prices[uniqueID]
            end

            -- Apply vendor multiplier
            local multiplier = vendorData.priceMultiplier or 1.0
            if isSellingToVendor then
                multiplier = multiplier * (vendorData.sellMultiplier or 0.5)
            end

            return math.Round(price * multiplier)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced pricing system with dynamic factors
        function MODULE:GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)
            if not IsValid(vendor) then return price end

            local vendorData = vendor:getNetVar("vendorData")
            if not vendorData then return price end

            local finalPrice = price

            -- Check for explicit price override
            if vendorData.prices and vendorData.prices[uniqueID] then
                finalPrice = vendorData.prices[uniqueID]
            else
                -- Apply base multiplier
                local multiplier = vendorData.priceMultiplier or 1.0

                -- Apply sell/buy multiplier
                if isSellingToVendor then
                    multiplier = multiplier * (vendorData.sellMultiplier or 0.5)

                    -- Check item condition if selling
                    local itemTable = lia.item.list[uniqueID]
                    if itemTable and itemTable.condition then
                        local conditionMultiplier = itemTable.condition / 100
                        multiplier = multiplier * conditionMultiplier
                    end
                else
                    multiplier = multiplier * (vendorData.buyMultiplier or 1.0)
                end

                -- Apply faction/class discounts
                local client = LocalPlayer()
                if IsValid(client) then
                    local character = client:getChar()
                    if character then
                        local faction = lia.faction.get(character:getFaction())
                        if faction and vendorData.factionDiscounts then
                            local discount = vendorData.factionDiscounts[faction.uniqueID] or 0
                            multiplier = multiplier * (1 - discount)
                        end

                        local class = lia.class.get(character:getClass())
                        if class and vendorData.classDiscounts then
                            local discount = vendorData.classDiscounts[class.uniqueID] or 0
                            multiplier = multiplier * (1 - discount)
                        end
                    end
                end

                -- Apply stock-based pricing
                if vendorData.stock and vendorData.stock[uniqueID] then
                    local stock = vendorData.stock[uniqueID]
                    local maxStock = vendorData.maxStock and vendorData.maxStock[uniqueID] or 100

                    if stock < maxStock * 0.2 then -- Low stock
                        multiplier = multiplier * 1.2
                    elseif stock > maxStock * 0.8 then -- High stock
                        multiplier = multiplier * 0.9
                    end
                end

                finalPrice = math.Round(price * multiplier)
            end

            -- Ensure minimum price
            local minPrice = vendorData.minPrice or 1
            finalPrice = math.max(finalPrice, minPrice)

            return finalPrice
        end
        ```
]]
function GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)
end

--[[
    Purpose:
        Gets the salary amount for a player.

    When Called:
        When calculating salary payments.

    Parameters:
        client (Player)
            The player.
        faction (table)
            The faction.
        class (table)
            The class.

    Returns:
        number
            The salary amount.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return base class salary
        function MODULE:GetSalaryAmount(client, faction, class)
            if class and class.salary then
                return class.salary
            end
            return 0
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Calculate salary with faction bonuses
        function MODULE:GetSalaryAmount(client, faction, class)
            if not IsValid(client) then return 0 end

            local baseSalary = 0

            if class and class.salary then
                baseSalary = class.salary
            elseif faction and faction.salary then
                baseSalary = faction.salary
            end

            -- Apply faction multiplier
            if faction and faction.salaryMultiplier then
                baseSalary = baseSalary * faction.salaryMultiplier
            end

            return math.Round(baseSalary)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary system with multiple factors
        function MODULE:GetSalaryAmount(client, faction, class)
            if not IsValid(client) then return 0 end

            local character = client:getChar()
            if not character then return 0 end

            local baseSalary = 0

            -- Get base salary from class or faction
            if class and class.salary then
                baseSalary = class.salary
            elseif faction and faction.salary then
                baseSalary = faction.salary
            else
                baseSalary = lia.config.get("DefaultSalary", 100)
            end

            -- Apply faction multiplier
            if faction and faction.salaryMultiplier then
                baseSalary = baseSalary * faction.salaryMultiplier
            end

            -- Apply rank bonuses
            local rank = character:getData("rank", 1)
            if rank > 1 then
                baseSalary = baseSalary * (1 + (rank - 1) * 0.1)
            end

            -- Apply playtime bonuses
            hook.Run("GetPlayTime", client):next(function(playTime)
                if playTime and playTime > 2592000 then -- 30 days
                    baseSalary = baseSalary * 1.1
                end
            end)

            -- Apply performance bonuses
            local performance = character:getData("performance", 100)
            if performance > 100 then
                baseSalary = baseSalary * (performance / 100)
            end

            -- Apply faction-specific bonuses
            if faction and faction.uniqueID == FACTION_POLICE then
                local arrests = character:getData("arrests", 0)
                if arrests > 10 then
                    baseSalary = baseSalary * 1.05
                end
            end

            -- Ensure minimum salary
            local minSalary = lia.config.get("MinSalary", 50)
            baseSalary = math.max(baseSalary, minSalary)

            return math.Round(baseSalary)
        end
        ```
]]
function GetSalaryAmount(client, faction, class)
end

--[[
    Purpose:
        Gets tickets by requester.

    When Called:
        When retrieving support tickets.

    Parameters:
        steamID (string)
            The requester's SteamID.

    Returns:
        table
            Table of tickets.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return empty tickets table
        function MODULE:GetTicketsByRequester(steamID)
            return {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get tickets from database
        function MODULE:GetTicketsByRequester(steamID)
            local tickets = {}

            lia.db.query("SELECT * FROM tickets WHERE requester = ?", {steamID}, function(data)
                if data then
                    tickets = data
                end
            end)

            return tickets
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ticket retrieval with filtering and formatting
        function MODULE:GetTicketsByRequester(steamID)
            if not steamID then return {} end

            local tickets = {}

            -- Query database for tickets
            lia.db.query("SELECT * FROM tickets WHERE requester = ? ORDER BY created DESC", {steamID}, function(data)
                if data and #data > 0 then
                    for _, ticket in ipairs(data) do
                        -- Get claimer info if exists
                        local claimerName = nil
                        if ticket.claimer then
                            local claimer = player.GetBySteamID(ticket.claimer)
                            if IsValid(claimer) then
                                local char = claimer:getChar()
                                if char then
                                    claimerName = char:getName()
                                else
                                    claimerName = claimer:Name()
                                end
                            end
                        end

                        -- Format ticket data
                        table.insert(tickets, {
                            id = ticket.id,
                            ticketID = ticket.ticketID,
                            requester = ticket.requester,
                            claimer = ticket.claimer,
                            claimerName = claimerName,
                            message = ticket.message,
                            status = ticket.status,
                            priority = ticket.priority or "normal",
                            created = ticket.created,
                            claimed = ticket.claimed,
                            closed = ticket.closed,
                            responses = ticket.responses or {}
                        })
                    end
                end
            end)

            -- Sort by priority and status
            table.sort(tickets, function(a, b)
                local priorityOrder = {high = 1, medium = 2, normal = 3, low = 4}
                local statusOrder = {open = 1, claimed = 2, closed = 3}

                local aPriority = priorityOrder[a.priority] or 3
                local bPriority = priorityOrder[b.priority] or 3
                local aStatus = statusOrder[a.status] or 3
                local bStatus = statusOrder[b.status] or 3

                if aStatus ~= bStatus then
                    return aStatus < bStatus
                end

                if aPriority ~= bPriority then
                    return aPriority < bPriority
                end

                return tonumber(a.created) > tonumber(b.created)
            end)

            return tickets
        end
        ```
]]
function GetTicketsByRequester(steamID)
end

--[[
    Purpose:
        Gets the vendor sale scale.

    When Called:
        When calculating vendor sale multipliers.

    Parameters:
        vendor (Entity)
            The vendor entity.

    Returns:
        number
            The sale scale.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return default scale
        function MODULE:GetVendorSaleScale(vendor)
            return 1.0
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get scale from vendor data
        function MODULE:GetVendorSaleScale(vendor)
            if not IsValid(vendor) then return 1.0 end

            local vendorData = vendor:getNetVar("vendorData")
            if vendorData and vendorData.saleScale then
                return vendorData.saleScale
            end

            return 1.0
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced sale scale calculation with dynamic factors
        function MODULE:GetVendorSaleScale(vendor)
            if not IsValid(vendor) then return 1.0 end

            local vendorData = vendor:getNetVar("vendorData")
            if not vendorData then return 1.0 end

            local baseScale = vendorData.saleScale or 1.0

            -- Apply time-based scaling
            local hour = tonumber(os.date("%H"))
            if hour >= 22 or hour < 6 then -- Night time
                baseScale = baseScale * 0.9 -- 10% discount at night
            end

            -- Apply player-specific scaling
            local client = LocalPlayer()
            if IsValid(client) then
                local character = client:getChar()
                if character then
                    -- Faction discounts
                    local faction = lia.faction.get(character:getFaction())
                    if faction and vendorData.factionDiscounts then
                        local discount = vendorData.factionDiscounts[faction.uniqueID] or 0
                        baseScale = baseScale * (1 - discount)
                    end

                    -- Reputation bonuses
                    local reputation = character:getData("reputation", 0)
                    if reputation > 100 then
                        baseScale = baseScale * 1.05
                    elseif reputation < -50 then
                        baseScale = baseScale * 0.95
                    end
                end
            end

            -- Apply stock-based scaling
            if vendorData.stock then
                local totalStock = 0
                local totalMaxStock = 0
                for uniqueID, stock in pairs(vendorData.stock) do
                    totalStock = totalStock + stock
                    local maxStock = vendorData.maxStock and vendorData.maxStock[uniqueID] or 100
                    totalMaxStock = totalMaxStock + maxStock
                end

                if totalMaxStock > 0 then
                    local stockPercent = totalStock / totalMaxStock
                    if stockPercent < 0.3 then -- Low stock
                        baseScale = baseScale * 1.15 -- Increase prices
                    elseif stockPercent > 0.8 then -- High stock
                        baseScale = baseScale * 0.9 -- Decrease prices
                    end
                end
            end

            -- Clamp scale
            return math.Clamp(baseScale, 0.5, 2.0)
        end
        ```
]]
function GetVendorSaleScale(vendor)
end

--[[
    Purpose:
        Gets warnings for a character.

    When Called:
        When retrieving warning data.

    Parameters:
        charID (number)
            The character ID.

    Returns:
        table
            Table of warnings.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get warnings for a character
        function MODULE:GetWarnings(charID)
            return lia.warning.get(charID) or {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get warnings with filtering
        function MODULE:GetWarnings(charID)
            local warnings = lia.warning.get(charID) or {}

            -- Filter active warnings only
            local activeWarnings = {}
            for _, warning in ipairs(warnings) do
                if not warning.removed then
                    table.insert(activeWarnings, warning)
                end
            end

            return activeWarnings
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced warning retrieval with caching and validation
        function MODULE:GetWarnings(charID)
            if not charID then return {} end

            -- Check cache first
            if self.warningCache and self.warningCache[charID] then
                local cacheTime = self.warningCache[charID].time
                if CurTime() - cacheTime < 60 then -- Cache for 60 seconds
                    return self.warningCache[charID].data
                end
            end

            -- Get warnings from database
            local warnings = lia.warning.get(charID) or {}

            -- Validate and process warnings
            local processedWarnings = {}
            for _, warning in ipairs(warnings) do
                -- Validate warning data
                if warning.id and warning.reason then
                    -- Add formatted date
                    warning.formattedDate = os.date("%Y-%m-%d %H:%M:%S", warning.time or os.time())

                    -- Check if warning is still active
                    if not warning.removed and (not warning.expires or warning.expires > os.time()) then
                        table.insert(processedWarnings, warning)
                    end
                end
            end

            -- Cache results
            self.warningCache = self.warningCache or {}
            self.warningCache[charID] = {
                data = processedWarnings,
                time = CurTime()
            }

            return processedWarnings
        end
        ```
]]
function GetWarnings(charID)
end

--[[
    Purpose:
        Gets warnings by issuer.

    When Called:
        When retrieving warnings issued by an admin.

    Parameters:
        steamID (string)
            The issuer's SteamID.

    Returns:
        table
            Table of warnings.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get warnings by issuer
        function MODULE:GetWarningsByIssuer(steamID)
            return lia.warning.getByIssuer(steamID) or {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get warnings with issuer information
        function MODULE:GetWarningsByIssuer(steamID)
            if not steamID then return {} end

            local warnings = lia.warning.getByIssuer(steamID) or {}

            -- Add issuer name to each warning
            for _, warning in ipairs(warnings) do
                local issuer = player.GetBySteamID(steamID)
                if IsValid(issuer) then
                    warning.issuerName = issuer:Name()
                else
                    warning.issuerName = "Unknown"
                end
            end

            return warnings
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced warning retrieval with statistics
        function MODULE:GetWarningsByIssuer(steamID)
            if not steamID then return {} end

            -- Get all warnings by this issuer
            local warnings = lia.warning.getByIssuer(steamID) or {}

            -- Process and analyze warnings
            local processedWarnings = {
                warnings = {},
                statistics = {
                    total = 0,
                    active = 0,
                    removed = 0,
                    byCharacter = {}
                }
            }

            for _, warning in ipairs(warnings) do
                processedWarnings.statistics.total = processedWarnings.statistics.total + 1

                if warning.removed then
                    processedWarnings.statistics.removed = processedWarnings.statistics.removed + 1
                else
                    processedWarnings.statistics.active = processedWarnings.statistics.active + 1
                end

                -- Group by character
                local charID = warning.charID or 0
                processedWarnings.statistics.byCharacter[charID] = (processedWarnings.statistics.byCharacter[charID] or 0) + 1

                -- Add formatted data
                warning.formattedDate = os.date("%Y-%m-%d %H:%M:%S", warning.time or os.time())

                -- Get issuer name
                local issuer = player.GetBySteamID(steamID)
                warning.issuerName = IsValid(issuer) and issuer:Name() or "Unknown"

                table.insert(processedWarnings.warnings, warning)
            end

            return processedWarnings
        end
        ```
]]
function GetWarningsByIssuer(steamID)
end

--[[
    Purpose:
        Handles item transfer requests.

    When Called:
        When a player requests to transfer an item.

    Parameters:
        client (Player)
            The player making the request.
        itemID (number)
            The item ID.
        x (number)
            The X position.
        y (number)
            The Y position.
        inventoryID (number)
            The destination inventory ID.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic item transfer handling
        function MODULE:HandleItemTransferRequest(client, itemID, x, y, inventoryID)
            local item = lia.item.get(itemID)
            if item then
                item:transfer(inventoryID, x, y)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Item transfer with validation
        function MODULE:HandleItemTransferRequest(client, itemID, x, y, inventoryID)
            if not IsValid(client) then return end

            local item = lia.item.get(itemID)
            if not item then return end

            -- Check if player can transfer
            if not hook.Run("CanPlayerTransferItem", client, item) then
                client:notify("You cannot transfer this item")
                return
            end

            -- Transfer item
            item:transfer(inventoryID, x, y)
            client:notify("Item transferred")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item transfer with logging and validation
        function MODULE:HandleItemTransferRequest(client, itemID, x, y, inventoryID)
            if not IsValid(client) then return end

            local item = lia.item.get(itemID)
            if not item then
                client:notifyError("Item not found")
                return
            end

            -- Validate transfer permissions
            if not hook.Run("CanPlayerTransferItem", client, item) then
                client:notifyError("You don't have permission to transfer this item")
                return
            end

            -- Validate destination inventory
            local inventory = lia.inventory.get(inventoryID)
            if not inventory then
                client:notifyError("Destination inventory not found")
                return
            end

            -- Check inventory space
            if not inventory:canFit(item, x, y) then
                client:notifyError("Item cannot fit in destination")
                return
            end

            -- Perform transfer
            item:transfer(inventoryID, x, y)

            -- Log transfer
            lia.log.add(string.format(
                "%s transferred item %s (ID: %d) to inventory %d",
                client:Name(),
                item:getName(),
                itemID,
                inventoryID
            ), FLAG_NORMAL)

            -- Notify success
            client:notify("Item transferred successfully")
        end
        ```
]]
function HandleItemTransferRequest(client, itemID, x, y, inventoryID)
end

--[[
    Purpose:
        Initializes storage for an entity.

    When Called:
        When setting up storage containers.

    Parameters:
        entity (Entity)
            The entity to initialize storage for.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic storage initialization
        function MODULE:InitializeStorage(entity)
            if IsValid(entity) then
                entity:setNetVar("storage", true)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize storage with default inventory
        function MODULE:InitializeStorage(entity)
            if not IsValid(entity) then return end

            -- Create storage inventory
            local inventory = lia.inventory.create({
                w = 10,
                h = 10,
                name = "Storage Container"
            })

            entity:setNetVar("inventory", inventory:getID())
            entity:setNetVar("storage", true)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced storage initialization with validation
        function MODULE:InitializeStorage(entity)
            if not IsValid(entity) then return end

            -- Get storage configuration
            local storageConfig = entity:getNetVar("storageConfig", {})
            local width = storageConfig.width or 10
            local height = storageConfig.height or 10
            local name = storageConfig.name or "Storage Container"

            -- Create storage inventory
            local inventory = lia.inventory.create({
                w = width,
                h = height,
                name = name
            })

            if not inventory then
                lia.log.add("Failed to create storage inventory for entity " .. entity:EntIndex(), FLAG_ERROR)
                return
            end

            -- Set up entity storage
            entity:setNetVar("inventory", inventory:getID())
            entity:setNetVar("storage", true)
            entity:setNetVar("storageName", name)

            -- Add default items if configured
            if storageConfig.defaultItems then
                for _, itemData in ipairs(storageConfig.defaultItems) do
                    inventory:add(itemData.uniqueID, itemData.quantity or 1)
                end
            end

            -- Log initialization
            lia.log.add(string.format(
                "Storage initialized for entity %d: %dx%d inventory (ID: %d)",
                entity:EntIndex(),
                width,
                height,
                inventory:getID()
            ), FLAG_NORMAL)
        end
        ```
]]
function InitializeStorage(entity)
end

--[[
    Purpose:
        Handles item combination.

    When Called:
        When players attempt to combine items.

    Parameters:
        client (Player)
            The player combining items.
        item (Item)
            The item being used.
        target (Item)
            The target item.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic item combination
        function MODULE:ItemCombine(client, item, target)
            if item and target then
                print("Combining " .. item:getName() .. " with " .. target:getName())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Item combination with recipe checking
        function MODULE:ItemCombine(client, item, target)
            if not IsValid(client) or not item or not target then return end

            -- Check for combination recipe
            local recipe = self:FindCombinationRecipe(item, target)
            if recipe then
                -- Remove items
                item:remove()
                target:remove()

                -- Give result item
                local char = client:getChar()
                if char then
                    char:getInv():add(recipe.result)
                    client:notify("Items combined successfully!")
                end
            else
                client:notify("These items cannot be combined")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item combination with validation and effects
        function MODULE:ItemCombine(client, item, target)
            if not IsValid(client) then return end
            if not item or not target then
                client:notifyError("Invalid items")
                return
            end

            local char = client:getChar()
            if not char then return end

            -- Find combination recipe
            local recipe = self:FindCombinationRecipe(item, target)
            if not recipe then
                client:notifyError("These items cannot be combined")
                return
            end

            -- Validate recipe requirements
            if recipe.requiresSkill then
                local skill = char:getData("skill_" .. recipe.requiresSkill, 0)
                if skill < recipe.skillLevel then
                    client:notifyError("You don't have the required skill level")
                    return
                end
            end

            -- Check if player has required tools
            if recipe.requiresTools then
                for _, toolID in ipairs(recipe.requiresTools) do
                    if not char:getInv():hasItem(toolID) then
                        client:notifyError("You need a " .. toolID .. " to combine these items")
                        return
                    end
                end
            end

            -- Remove source items
            item:remove()
            target:remove()

            -- Create result item
            local resultItem = char:getInv():add(recipe.result, recipe.quantity or 1)

            -- Apply skill experience
            if recipe.skillExperience then
                for skill, exp in pairs(recipe.skillExperience) do
                    char:addSkillExperience(skill, exp)
                end
            end

            -- Play combination effect
            if recipe.effect then
                local effectData = EffectData()
                effectData:SetOrigin(client:GetPos())
                util.Effect(recipe.effect, effectData)
            end

            -- Log combination
            lia.log.add(string.format(
                "%s combined %s with %s to create %s",
                client:Name(),
                item:getName(),
                target:getName(),
                recipe.result
            ), FLAG_NORMAL)

            client:notify("Items combined successfully!")
        end
        ```
]]
function ItemCombine(client, item, target)
end

--[[
    Purpose:
        Called when a key is used to lock an entity.

    When Called:
        When players lock doors or containers.

    Parameters:
        owner (Player)
            The owner of the key.
        entity (Entity)
            The entity being locked.
        time (number)
            The lock time.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when keys are used to lock entities
        function MODULE:KeyLock(owner, entity, time)
            print(owner:Name() .. " locked an entity")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track lock events and notify nearby players
        function MODULE:KeyLock(owner, entity, time)
            local char = owner:getChar()
            if char then
                lia.log.add(owner:Name() .. " locked entity " .. tostring(entity), FLAG_NORMAL)

                -- Notify nearby players
                for _, v in player.Iterator() do
                    if v:GetPos():Distance(entity:GetPos()) < 200 then
                        v:notify("You hear a lock click.")
                    end
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced locking system with permissions, logging, and integration
        function MODULE:KeyLock(owner, entity, time)
            local char = owner:getChar()
            if not char then return end

            -- Check if entity can be locked
            if not IsValid(entity) then return end

            -- Log the lock event
            lia.log.add(string.format("%s (%s) locked entity %s at %s",
                owner:Name(),
                owner:SteamID(),
                tostring(entity),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store lock data
            entity:SetNetVar("lockedBy", owner:SteamID())
            entity:SetNetVar("lockedTime", os.time())
            entity:SetNetVar("lockDuration", time or 0)

            -- Notify nearby players with sound
            for _, v in player.Iterator() do
                local dist = v:GetPos():Distance(entity:GetPos())
                if dist < 300 then
                    v:notify("You hear a lock click.")
                    if dist < 100 then
                        v:EmitSound("items/flashlight1.wav", 60, 100)
                    end
                end
            end

            -- Update door data if it's a door
            if entity:GetClass() == "lia_door" then
                local doorData = entity:getNetVar("doorData")
                if doorData then
                    doorData.locked = true
                    entity:setNetVar("doorData", doorData)
                end
            end
        end
        ```
]]
function KeyLock(owner, entity, time)
end

--[[
    Purpose:
        Called when a key is used to unlock an entity.

    When Called:
        When players unlock doors or containers.

    Parameters:
        owner (Player)
            The owner of the key.
        entity (Entity)
            The entity being unlocked.
        time (number)
            The unlock time.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when keys are used to unlock entities
        function MODULE:KeyUnlock(owner, entity, time)
            print(owner:Name() .. " unlocked an entity")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track unlock events and validate access
        function MODULE:KeyUnlock(owner, entity, time)
            local char = owner:getChar()
            if char then
                lia.log.add(owner:Name() .. " unlocked entity " .. tostring(entity), FLAG_NORMAL)

                -- Check if entity was locked by this player
                local lockedBy = entity:GetNetVar("lockedBy")
                if lockedBy == owner:SteamID() then
                    entity:SetNetVar("lockedBy", nil)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced unlocking with permissions, validation, and logging
        function MODULE:KeyUnlock(owner, entity, time)
            local char = owner:getChar()
            if not char then return end

            if not IsValid(entity) then return end

            -- Verify unlock permission
            local lockedBy = entity:GetNetVar("lockedBy")
            local canUnlock = false

            if lockedBy == owner:SteamID() then
                canUnlock = true
            elseif owner:IsAdmin() then
                canUnlock = true
            elseif hook.Run("CanPlayerUnlock", owner, entity) then
                canUnlock = true
            end

            if not canUnlock then
                owner:notify("You don't have permission to unlock this.")
                return
            end

            -- Log the unlock event
            lia.log.add(string.format("%s (%s) unlocked entity %s at %s",
                owner:Name(),
                owner:SteamID(),
                tostring(entity),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Clear lock data
            entity:SetNetVar("lockedBy", nil)
            entity:SetNetVar("lockedTime", nil)
            entity:SetNetVar("lockDuration", nil)

            -- Notify nearby players
            for _, v in player.Iterator() do
                local dist = v:GetPos():Distance(entity:GetPos())
                if dist < 300 then
                    v:notify("You hear a lock click.")
                    if dist < 100 then
                        v:EmitSound("items/flashlight1.wav", 60, 100)
                    end
                end
            end

            -- Update door data if it's a door
            if entity:GetClass() == "lia_door" then
                local doorData = entity:getNetVar("doorData")
                if doorData then
                    doorData.locked = false
                    entity:setNetVar("doorData", doorData)
                end
            end
        end
        ```
]]
function KeyUnlock(owner, entity, time)
end

--[[
    Purpose:
        Called when loading server data.

    When Called:
        During server initialization data loading.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load basic configuration data
        function MODULE:LoadData()
            MODULE.customData = MODULE.customData or {}
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load data from database or files
        function MODULE:LoadData()
            MODULE.customData = {}

            -- Load from file
            if file.Exists("lilia_data/module_custom.txt", "DATA") then
                local data = file.Read("lilia_data/module_custom.txt", "DATA")
                if data then
                    MODULE.customData = util.JSONToTable(data) or {}
                end
            end

            -- Load from database
            lia.db.query("SELECT * FROM custom_module_data", function(data)
                if data then
                    for _, row in ipairs(data) do
                        MODULE.customData[row.key] = row.value
                    end
                end
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Complex data loading with validation, error handling, and fallbacks
        function MODULE:LoadData()
            MODULE.customData = {}
            MODULE.loadedData = false

            -- Try loading from database first
            lia.db.query("SELECT * FROM custom_module_data WHERE map = ?", {game.GetMap()}, function(data)
                if data and #data > 0 then
                    for _, row in ipairs(data) do
                        local key = row.key
                        local value = row.value

                        -- Validate and parse JSON values
                        if string.StartWith(value, "{") or string.StartWith(value, "[") then
                            local parsed = util.JSONToTable(value)
                            if parsed then
                                MODULE.customData[key] = parsed
                            else
                                MODULE.customData[key] = value
                            end
                        else
                            MODULE.customData[key] = value
                        end
                    end

                    MODULE.loadedData = true
                    print("[MODULE] Loaded " .. #data .. " data entries from database")
                else
                    -- Fallback to file system
                    MODULE:LoadDataFromFile()
                end
            end)

            -- Load file-based data as backup
            MODULE:LoadDataFromFile()
        end

        function MODULE:LoadDataFromFile()
            local path = "lilia_data/" .. game.GetMap() .. "/module_custom.txt"
            if file.Exists(path, "DATA") then
                local data = file.Read(path, "DATA")
                if data then
                    local parsed = util.JSONToTable(data)
                    if parsed then
                        table.Merge(MODULE.customData, parsed)
                        print("[MODULE] Loaded data from file system")
                    end
                end
            end
        end
        ```
]]
function LoadData()
end

--[[
    Purpose:
        Called when the admin system is loaded.

    When Called:
        After admin groups and privileges are initialized.

    Parameters:
        groups (table)
            The admin groups.
        privileges (table)
            The admin privileges.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when admin system loads
        function MODULE:OnAdminSystemLoaded(groups, privileges)
            print("Admin system loaded with " .. table.Count(groups) .. " groups")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize custom admin features
        function MODULE:OnAdminSystemLoaded(groups, privileges)
            MODULE.adminGroups = groups
            MODULE.adminPrivileges = privileges

            -- Add custom privilege
            privileges["custom_privilege"] = {
                name = "Custom Privilege",
                description = "Access to custom features"
            }
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced admin system integration with validation and logging
        function MODULE:OnAdminSystemLoaded(groups, privileges)
            MODULE.adminGroups = groups
            MODULE.adminPrivileges = privileges
            MODULE.adminLoaded = true

            -- Validate and merge custom privileges
            local customPrivileges = {
                ["custom_privilege"] = {
                    name = "Custom Privilege",
                    description = "Access to custom features",
                    category = "general"
                },
                ["advanced_feature"] = {
                    name = "Advanced Feature",
                    description = "Access to advanced features",
                    category = "advanced"
                }
            }

            for key, priv in pairs(customPrivileges) do
                if not privileges[key] then
                    privileges[key] = priv
                    print("[MODULE] Added custom privilege: " .. key)
                end
            end

            -- Validate group structure
            for groupName, groupData in pairs(groups) do
                if not groupData.privileges then
                    groupData.privileges = {}
                end
                if not groupData.inherit then
                    groupData.inherit = {}
                end
            end

            -- Log admin system load
            lia.log.add("Admin system loaded: " .. table.Count(groups) .. " groups, " .. table.Count(privileges) .. " privileges", FLAG_NORMAL)

            -- Notify modules that admin system is ready
            hook.Run("AdminSystemReady", groups, privileges)
        end
        ```
]]
function OnAdminSystemLoaded(groups, privileges)
end

--[[
    Purpose:
        Called when a character is created.

    When Called:
        After a new character is successfully created.

    Parameters:
        client (Player)
            The player who created the character.
        character (Character)
            The new character.
        originalData (table)
            The original creation data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Welcome message for new characters
        function MODULE:OnCharCreated(client, character, originalData)
            client:notify("Welcome! Your character has been created.")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize character with custom data and logging
        function MODULE:OnCharCreated(client, character, originalData)
            -- Set custom data
            character:setData("created", os.time())
            character:setData("playTime", 0)

            -- Log creation
            lia.log.add(string.format("%s created character %s (ID: %d)",
                client:Name(),
                character:getName(),
                character:getID()),
                FLAG_NORMAL)

            -- Give starter items
            local faction = character:getFaction()
            if faction and faction.startingItems then
                for _, itemID in ipairs(faction.startingItems) do
                    character:getInv():add(itemID)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Complex character creation with validation, cross-module integration, and events
        function MODULE:OnCharCreated(client, character, originalData)
            if not IsValid(client) or not character then return end

            -- Initialize character data
            local charData = character:getData()
            charData.created = os.time()
            charData.createdBy = client:SteamID()
            charData.playTime = 0
            charData.lastLogin = os.time()
            charData.stats = {
                kills = 0,
                deaths = 0,
                moneyEarned = 0,
                itemsFound = 0
            }

            -- Log detailed creation
            lia.log.add(string.format("%s (%s) created character %s (ID: %d, Faction: %s)",
                client:Name(),
                client:SteamID(),
                character:getName(),
                character:getID(),
                character:getFaction() and character:getFaction().name or "Unknown"),
                FLAG_NORMAL)

            -- Apply faction-specific bonuses
            local faction = character:getFaction()
            if faction then
                -- Starting money
                if faction.startingMoney then
                    character:giveMoney(faction.startingMoney)
                end

                -- Starting items
                if faction.startingItems then
                    local inv = character:getInv()
                    if inv then
                        for _, itemData in ipairs(faction.startingItems) do
                            if isstring(itemData) then
                                inv:add(itemData)
                            elseif istable(itemData) then
                                inv:add(itemData[1], itemData[2] or 1, itemData[3] or {})
                            end
                        end
                    end
                end
            end

            -- Apply class-specific bonuses
            local class = character:getClass()
            if class and class.onCreated then
                class.onCreated(client, character, originalData)
            end

            -- Notify modules
            hook.Run("CharacterFullyCreated", client, character, originalData)

            -- Send welcome message
            timer.Simple(1, function()
                if IsValid(client) then
                    client:notify("Welcome, " .. character:getName() .. "!")
                end
            end)
        end
        ```
]]
function OnCharCreated(client, character, originalData)
end

--[[
    Purpose:
        Called when a character is deleted.

    When Called:
        When a character deletion is requested.

    Parameters:
        client (Player)
            The player requesting deletion.
        characterID (number)
            The ID of the character to delete.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character deletion
        function MODULE:OnCharDelete(client, characterID)
            print("Character " .. characterID .. " deleted")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle character deletion with cleanup
        function MODULE:OnCharDelete(client, characterID)
            lia.log.add(string.format("%s deleted character ID %d",
                client:Name(),
                characterID),
                FLAG_NORMAL)

            -- Clean up character data
            lia.db.query("DELETE FROM character_data WHERE charID = ?", {characterID})
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced deletion with validation, cleanup, and logging
        function MODULE:OnCharDelete(client, characterID)
            if not characterID then return end

            -- Get character before deletion
            local character = lia.char.loaded[characterID]
            local charName = character and character:getName() or "Unknown"

            -- Log deletion with details
            lia.log.add(string.format("%s (%s) deleted character %s (ID: %d)",
                client:Name(),
                client:SteamID(),
                charName,
                characterID),
                FLAG_NORMAL)

            -- Clean up inventory
            if character then
                local inv = character:getInv()
                if inv then
                    inv:destroy()
                end
            end

            -- Clean up database entries
            lia.db.query("DELETE FROM character_data WHERE charID = ?", {characterID})
            lia.db.query("DELETE FROM character_items WHERE charID = ?", {characterID})
            lia.db.query("DELETE FROM character_warnings WHERE charID = ?", {characterID})

            -- Notify modules
            hook.Run("CharacterDeleted", client, characterID, character)

            -- Update player's character count
            if IsValid(client) then
                client:syncCharList()
            end
        end
        ```
]]
function OnCharDelete(client, characterID)
end

--[[
    Purpose:
        Called when a character disconnects.

    When Called:
        When a player disconnects from a character.

    Parameters:
        client (Player)
            The disconnecting player.
        character (Character)
            The character being disconnected from.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character disconnection
        function MODULE:OnCharDisconnect(client, character)
            print(client:Name() .. " disconnected from character")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Save character data on disconnect
        function MODULE:OnCharDisconnect(client, character)
            if character then
                character:setData("lastDisconnect", os.time())
                character:save()

                lia.log.add(client:Name() .. " disconnected from " .. character:getName(), FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced disconnect handling with cleanup and data persistence
        function MODULE:OnCharDisconnect(client, character)
            if not IsValid(client) or not character then return end

            -- Update last disconnect time
            character:setData("lastDisconnect", os.time())
            character:setData("lastPosition", client:GetPos())
            character:setData("lastAngles", client:GetAngles())

            -- Save playtime
            local playTime = character:getData("playTime", 0)
            local sessionTime = os.time() - (character:getData("lastLogin", os.time()))
            character:setData("playTime", playTime + sessionTime)

            -- Save inventory
            local inv = character:getInv()
            if inv then
                inv:sync()
            end

            -- Save character
            character:save()

            -- Log disconnection
            lia.log.add(string.format("%s (%s) disconnected from %s (ID: %d)",
                client:Name(),
                client:SteamID(),
                character:getName(),
                character:getID()),
                FLAG_NORMAL)

            -- Clean up temporary data
            if character:getData("tempData") then
                character:setData("tempData", nil)
            end

            -- Notify modules
            hook.Run("CharacterDisconnected", client, character)
        end
        ```
]]
function OnCharDisconnect(client, character)
end

--[[
    Purpose:
        Called when a character fallover occurs.

    When Called:
        When characters enter fallover state.

    Parameters:
        client (Player)
            The player.
        ragdoll (Entity)
            The ragdoll entity.
        state (boolean)
            The fallover state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when character falls over
        function MODULE:OnCharFallover(client, ragdoll, state)
            if state then
                print(client:Name() .. " fell over")
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track fallover state and notify
        function MODULE:OnCharFallover(client, ragdoll, state)
            local char = client:getChar()
            if char then
                char:setData("falloverState", state)

                if state then
                    lia.log.add(client:Name() .. " fell over", FLAG_NORMAL)
                    -- Notify nearby players
                    for _, v in player.Iterator() do
                        if v:GetPos():Distance(client:GetPos()) < 300 then
                            v:notify("You see " .. char:getName() .. " fall over.")
                        end
                    end
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced fallover system with injuries, effects, and recovery
        function MODULE:OnCharFallover(client, ragdoll, state)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            char:setData("falloverState", state)
            char:setData("falloverTime", state and os.time() or nil)

            if state then
                -- Log fallover
                lia.log.add(string.format("%s (%s) fell over at %s",
                    client:Name(),
                    client:SteamID(),
                    os.date("%Y-%m-%d %H:%M:%S")),
                    FLAG_NORMAL)

                -- Apply injury chance
                local injuryChance = hook.Run("GetInjuryChance", client) or 10
                if math.random(100) <= injuryChance then
                    char:setData("injuries", char:getData("injuries", {}) + 1)
                    client:notify("You sustained an injury from the fall!")
                end

                -- Notify nearby players
                for _, v in player.Iterator() do
                    local dist = v:GetPos():Distance(client:GetPos())
                    if dist < 500 then
                        v:notify("You see " .. char:getName() .. " fall over.")
                        if dist < 200 then
                            v:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 60, 100)
                        end
                    end
                end

                -- Set recovery timer
                timer.Create("charFallover_" .. client:SteamID(), 5, 1, function()
                    if IsValid(client) and IsValid(ragdoll) then
                        hook.Run("OnCharGetup", client, ragdoll)
                    end
                end)
            else
                -- Character got up
                char:setData("falloverTime", nil)
            end
        end
        ```
]]
function OnCharFallover(client, ragdoll, state)
end

--[[
    Purpose:
        Called when character flags are given.

    When Called:
        When flags are added to a character.

    Parameters:
        player (Player)
            The player.
        character (Character)
            The character.
        addedFlags (string)
            The flags that were added.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when flags are given
        function MODULE:OnCharFlagsGiven(player, character, addedFlags)
            print("Flags given to character: " .. addedFlags)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track flag changes and notify
        function MODULE:OnCharFlagsGiven(player, character, addedFlags)
            lia.log.add(string.format("%s received flags: %s",
                character:getName(),
                addedFlags),
                FLAG_NORMAL)

            -- Store flag history
            local flagHistory = character:getData("flagHistory", {})
            table.insert(flagHistory, {
                flags = addedFlags,
                time = os.time(),
                givenBy = player:SteamID()
            })
            character:setData("flagHistory", flagHistory)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced flag system with validation, logging, and integration
        function MODULE:OnCharFlagsGiven(player, character, addedFlags)
            if not character or not addedFlags then return end

            -- Validate flags
            local validFlags = {}
            for flag in string.gmatch(addedFlags, ".") do
                if hook.Run("IsValidFlag", flag) then
                    table.insert(validFlags, flag)
                end
            end

            if #validFlags == 0 then return end

            -- Log flag assignment
            lia.log.add(string.format("%s (%s) gave flags '%s' to %s (ID: %d)",
                player:Name(),
                player:SteamID(),
                addedFlags,
                character:getName(),
                character:getID()),
                FLAG_NORMAL)

            -- Store flag history
            local flagHistory = character:getData("flagHistory", {})
            table.insert(flagHistory, {
                flags = addedFlags,
                time = os.time(),
                givenBy = player:SteamID(),
                givenByName = player:Name()
            })

            -- Limit history size
            if #flagHistory > 50 then
                table.remove(flagHistory, 1)
            end

            character:setData("flagHistory", flagHistory)

            -- Apply flag-specific effects
            for flag in string.gmatch(addedFlags, ".") do
                hook.Run("OnFlagGiven", character, flag, player)
            end

            -- Notify modules
            hook.Run("CharacterFlagsUpdated", character, addedFlags, true)
        end
        ```
]]
function OnCharFlagsGiven(player, character, addedFlags)
end

--[[
    Purpose:
        Called when character flags are taken.

    When Called:
        When flags are removed from a character.

    Parameters:
        player (Player)
            The player.
        character (Character)
            The character.
        removedFlags (string)
            The flags that were removed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when flags are taken
        function MODULE:OnCharFlagsTaken(player, character, removedFlags)
            print("Flags removed from character: " .. removedFlags)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track flag removal and log
        function MODULE:OnCharFlagsTaken(player, character, removedFlags)
            lia.log.add(string.format("%s lost flags: %s",
                character:getName(),
                removedFlags),
                FLAG_NORMAL)

            -- Store removal in history
            local flagHistory = character:getData("flagHistory", {})
            table.insert(flagHistory, {
                flags = "-" .. removedFlags,
                time = os.time(),
                removedBy = player:SteamID()
            })
            character:setData("flagHistory", flagHistory)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced flag removal with validation and logging
        function MODULE:OnCharFlagsTaken(player, character, removedFlags)
            if not character or not removedFlags then return end

            -- Log flag removal
            lia.log.add(string.format("%s (%s) removed flags '%s' from %s (ID: %d)",
                player:Name(),
                player:SteamID(),
                removedFlags,
                character:getName(),
                character:getID()),
                FLAG_NORMAL)

            -- Store removal in history
            local flagHistory = character:getData("flagHistory", {})
            table.insert(flagHistory, {
                flags = "-" .. removedFlags,
                time = os.time(),
                removedBy = player:SteamID(),
                removedByName = player:Name()
            })

            -- Limit history size
            if #flagHistory > 50 then
                table.remove(flagHistory, 1)
            end

            character:setData("flagHistory", flagHistory)

            -- Apply flag-specific removal effects
            for flag in string.gmatch(removedFlags, ".") do
                hook.Run("OnFlagRemoved", character, flag, player)
            end

            -- Notify modules
            hook.Run("CharacterFlagsUpdated", character, removedFlags, false)
        end
        ```
]]
function OnCharFlagsTaken(player, character, removedFlags)
end

--[[
    Purpose:
        Called when a character gets up from fallover.

    When Called:
        When characters recover from fallover state.

    Parameters:
        target (Player)
            The target player.
        entity (Entity)
            The entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when character gets up
        function MODULE:OnCharGetup(target, entity)
            print(target:Name() .. " got up")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track recovery and clear fallover state
        function MODULE:OnCharGetup(target, entity)
            local char = target:getChar()
            if char then
                char:setData("falloverState", false)
                char:setData("falloverTime", nil)

                lia.log.add(target:Name() .. " recovered from fallover", FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced recovery system with effects and validation
        function MODULE:OnCharGetup(target, entity)
            if not IsValid(target) then return end

            local char = target:getChar()
            if not char then return end

            -- Clear fallover state
            char:setData("falloverState", false)
            local falloverTime = char:getData("falloverTime")
            char:setData("falloverTime", nil)

            -- Calculate recovery time
            if falloverTime then
                local recoveryTime = os.time() - falloverTime
                lia.log.add(string.format("%s recovered from fallover after %d seconds",
                    target:Name(),
                    recoveryTime),
                    FLAG_NORMAL)
            end

            -- Apply recovery effects
            hook.Run("OnCharacterRecovered", target, entity)

            -- Remove ragdoll if valid
            if IsValid(entity) then
                timer.Simple(0.5, function()
                    if IsValid(entity) then
                        entity:Remove()
                    end
                end)
            end
        end
        ```
]]
function OnCharGetup(target, entity)
end

--[[
    Purpose:
        Called when a character is kicked.

    When Called:
        When a character is kicked by an admin.

    Parameters:
        character (Character)
            The character being kicked.
        admin (Player)
            The admin performing the kick.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character kick
        function MODULE:OnCharKick(character, admin)
            print("Character " .. character:getName() .. " was kicked")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track kicks and log
        function MODULE:OnCharKick(character, admin)
            lia.log.add(string.format("%s kicked character %s (ID: %d)",
                admin:Name(),
                character:getName(),
                character:getID()),
                FLAG_NORMAL)

            -- Store kick history
            character:setData("kickHistory", character:getData("kickHistory", {}) + 1)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced kick system with logging and integration
        function MODULE:OnCharKick(character, admin)
            if not character or not IsValid(admin) then return end

            -- Log kick with details
            lia.log.add(string.format("%s (%s) kicked character %s (ID: %d) at %s",
                admin:Name(),
                admin:SteamID(),
                character:getName(),
                character:getID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store kick history
            local kickHistory = character:getData("kickHistory", {})
            table.insert(kickHistory, {
                admin = admin:SteamID(),
                adminName = admin:Name(),
                time = os.time(),
                reason = character:getData("kickReason") or "No reason provided"
            })

            -- Limit history
            if #kickHistory > 20 then
                table.remove(kickHistory, 1)
            end

            character:setData("kickHistory", kickHistory)
            character:setData("kickCount", (character:getData("kickCount", 0) + 1))

            -- Notify modules
            hook.Run("CharacterKicked", character, admin)

            -- Get player if online
            local player = character:getPlayer()
            if IsValid(player) then
                player:Kick("Character kicked by " .. admin:Name())
            end
        end
        ```
]]
function OnCharKick(character, admin)
end

--[[
    Purpose:
        Called when a character is permanently killed.

    When Called:
        When a character is permakilled.

    Parameters:
        character (Character)
            The character being permakilled.
        time (number)
            The time of permakill.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log permakill
        function MODULE:OnCharPermakilled(character, time)
            print("Character " .. character:getName() .. " was permakilled")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle permakill with logging
        function MODULE:OnCharPermakilled(character, time)
            lia.log.add(string.format("Character %s (ID: %d) was permakilled at %s",
                character:getName(),
                character:getID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            character:setData("permakilled", true)
            character:setData("permakillTime", time or os.time())
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced permakill handling with cleanup and restrictions
        function MODULE:OnCharPermakilled(character, time)
            if not character then return end

            local permakillTime = time or os.time()

            -- Log permakill
            lia.log.add(string.format("Character %s (ID: %d) was permakilled at %s",
                character:getName(),
                character:getID(),
                os.date("%Y-%m-%d %H:%M:%S", permakillTime)),
                FLAG_CRITICAL)

            -- Mark as permakilled
            character:setData("permakilled", true)
            character:setData("permakillTime", permakillTime)

            -- Remove all items from inventory
            local inv = character:getInv()
            if inv then
                for _, item in pairs(inv:getItems()) do
                    item:remove()
                end
            end

            -- Reset money
            character:setMoney(0)

            -- Clear all flags
            character:setFlags("")

            -- Save character
            character:save()

            -- Notify player if online
            local player = character:getPlayer()
            if IsValid(player) then
                player:notify("Your character has been permanently killed.")
            end

            -- Notify modules
            hook.Run("CharacterPermakilled", character, permakillTime)
        end
        ```
]]
function OnCharPermakilled(character, time)
end

--[[
    Purpose:
        Called when a character trades with a vendor.

    When Called:
        When vendor trading occurs.

    Parameters:
        client (Player)
            The trading player.
        vendor (Entity)
            The vendor entity.
        item (Item)
            The item being traded.
        isSellingToVendor (boolean)
            Whether selling to vendor.
        character (Character)
            The character.
        itemType (string)
            The item type.
        isFailed (boolean)
            Whether the trade failed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log vendor trades
        function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
            if not isFailed then
                print(client:Name() .. " traded with vendor")
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track trades and log
        function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
            if isFailed then return end

            local action = isSellingToVendor and "sold" or "bought"
            lia.log.add(string.format("%s %s %s from vendor",
                client:Name(),
                action,
                itemType),
                FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced trade tracking with validation and analytics
        function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
            if not IsValid(client) or not character then return end

            if isFailed then
                lia.log.add(string.format("%s failed to trade %s with vendor",
                    client:Name(),
                    itemType),
                    FLAG_WARNING)
                return
            end

            local action = isSellingToVendor and "sold" or "bought"
            local vendorName = IsValid(vendor) and vendor:GetName() or "Unknown"

            -- Log trade
            lia.log.add(string.format("%s (%s) %s %s from vendor %s",
                client:Name(),
                client:SteamID(),
                action,
                itemType,
                vendorName),
                FLAG_NORMAL)

            -- Track trade statistics
            local tradeStats = character:getData("tradeStats", {})
            tradeStats.totalTrades = (tradeStats.totalTrades or 0) + 1
            tradeStats[action .. "Count"] = (tradeStats[action .. "Count"] or 0) + 1
            character:setData("tradeStats", tradeStats)

            -- Apply vendor-specific effects
            if IsValid(vendor) then
                local vendorData = vendor:getNetVar("vendorData")
                if vendorData and vendorData.onTrade then
                    vendorData.onTrade(client, item, isSellingToVendor)
                end
            end

            -- Notify modules
            hook.Run("VendorTradeCompleted", client, vendor, item, isSellingToVendor, character, itemType)
        end
        ```
]]
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
end

--[[
    Purpose:
        Called when chat messages are received.

    When Called:
        When chat messages are processed server-side.

    Parameters:
        client (Player)
            The sending player.
        chatType (string)
            The chat type.
        text (string)
            The message text.
        anonymous (boolean)
            Whether the message is anonymous.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log chat messages
        function MODULE:OnChatReceived(client, chatType, text, anonymous)
            print(client:Name() .. " said: " .. text)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Filter and log chat
        function MODULE:OnChatReceived(client, chatType, text, anonymous)
            -- Filter profanity
            if string.find(string.lower(text), "badword") then
                client:notify("Please watch your language.")
                return false -- Prevent message
            end

            lia.log.add(string.format("%s [%s]: %s",
                client:Name(),
                chatType,
                text),
                FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced chat filtering with logging and moderation
        function MODULE:OnChatReceived(client, chatType, text, anonymous)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Check if player is muted
            if char:getData("muted", false) then
                client:notify("You are muted and cannot speak.")
                return false
            end

            -- Filter profanity
            local filteredWords = {"badword1", "badword2"}
            local filteredText = text
            for _, word in ipairs(filteredWords) do
                filteredText = string.gsub(string.lower(filteredText), word, string.rep("*", #word))
            end

            if filteredText ~= text then
                client:notify("Your message contained inappropriate language.")
                lia.log.add(string.format("%s tried to use profanity: %s",
                    client:Name(),
                    text),
                    FLAG_WARNING)
                return false
            end

            -- Log all chat
            lia.log.add(string.format("%s (%s) [%s]%s: %s",
                client:Name(),
                client:SteamID(),
                chatType,
                anonymous and " [ANON]" or "",
                text),
                FLAG_NORMAL)

            -- Check for admin commands in chat
            if client:IsAdmin() and string.StartWith(text, "/") then
                local command = string.match(text, "/(%w+)")
                if command then
                    hook.Run("PlayerUseCommand", client, command, string.sub(text, #command + 3))
                end
            end
        end
        ```
]]
function OnChatReceived(client, chatType, text, anonymous)
end

--[[
    Purpose:
        Called when a cheater is caught.

    When Called:
        When anti-cheat systems detect cheating.

    Parameters:
        client (Player)
            The cheating player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log cheater detection
        function MODULE:OnCheaterCaught(client)
            print("Cheater detected: " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle cheater with logging and action
        function MODULE:OnCheaterCaught(client)
            lia.log.add(string.format("Cheater detected: %s (%s)",
                client:Name(),
                client:SteamID()),
                FLAG_CRITICAL)

            -- Kick the player
            client:Kick("Cheating detected")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced anti-cheat with logging, actions, and tracking
        function MODULE:OnCheaterCaught(client)
            if not IsValid(client) then return end

            -- Log cheater detection
            lia.log.add(string.format("CHEATER DETECTED: %s (%s) at %s",
                client:Name(),
                client:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_CRITICAL)

            -- Store cheater data
            local char = client:getChar()
            if char then
                local cheaterData = char:getData("cheaterData", {})
                table.insert(cheaterData, {
                    time = os.time(),
                    steamID = client:SteamID(),
                    ip = client:IPAddress()
                })
                char:setData("cheaterData", cheaterData)
                char:setData("isCheater", true)
                char:save()
            end

            -- Notify admins
            for _, v in player.Iterator() do
                if v:IsAdmin() then
                    v:notify("[ANTI-CHEAT] " .. client:Name() .. " detected as cheater")
                end
            end

            -- Ban the player
            client:Ban(0, "Cheating detected")
            client:Kick("Cheating detected - You have been banned")
        end
        ```
]]
function OnCheaterCaught(client)
end

--[[
    Purpose:
        Called when cheater status changes.

    When Called:
        When a player's cheat status is updated.

    Parameters:
        client (Player)
            The admin changing status.
        target (Player)
            The target player.
        newStatus (string)
            The new cheat status.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log status change
        function MODULE:OnCheaterStatusChanged(client, target, newStatus)
            print("Cheater status changed for " .. target:Name() .. ": " .. newStatus)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update status and log
        function MODULE:OnCheaterStatusChanged(client, target, newStatus)
            local char = target:getChar()
            if char then
                char:setData("cheaterStatus", newStatus)

                lia.log.add(string.format("%s changed %s's cheater status to: %s",
                    client:Name(),
                    target:Name(),
                    newStatus),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced status management with validation and logging
        function MODULE:OnCheaterStatusChanged(client, target, newStatus)
            if not IsValid(client) or not IsValid(target) then return end

            if not client:IsAdmin() then
                client:notify("You don't have permission to change cheater status.")
                return
            end

            local char = target:getChar()
            if not char then return end

            local oldStatus = char:getData("cheaterStatus", "none")
            char:setData("cheaterStatus", newStatus)
            char:setData("cheaterStatusChangedBy", client:SteamID())
            char:setData("cheaterStatusChangedTime", os.time())

            -- Log status change
            lia.log.add(string.format("%s (%s) changed %s (%s)'s cheater status from %s to %s",
                client:Name(),
                client:SteamID(),
                target:Name(),
                target:SteamID(),
                oldStatus,
                newStatus),
                FLAG_CRITICAL)

            -- Store in history
            local statusHistory = char:getData("cheaterStatusHistory", {})
            table.insert(statusHistory, {
                from = oldStatus,
                to = newStatus,
                by = client:SteamID(),
                byName = client:Name(),
                time = os.time()
            })

            if #statusHistory > 50 then
                table.remove(statusHistory, 1)
            end

            char:setData("cheaterStatusHistory", statusHistory)
            char:save()

            -- Apply status-based effects
            if newStatus == "banned" then
                target:Ban(0, "Marked as cheater")
            elseif newStatus == "cleared" then
                char:setData("isCheater", false)
            end

            -- Notify modules
            hook.Run("CheaterStatusUpdated", target, oldStatus, newStatus, client)
        end
        ```
]]
function OnCheaterStatusChanged(client, target, newStatus)
end

--[[
    Purpose:
        Called when a player ragdoll is created.

    When Called:
        When player ragdolls are created.

    Parameters:
        player (Player)
            The player.
        entity (Entity)
            The ragdoll entity.
        isDead (boolean)
            Whether the player is dead.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log ragdoll creation
        function MODULE:OnCreatePlayerRagdoll(player, entity, isDead)
            print(player:Name() .. " ragdoll created")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize ragdoll appearance
        function MODULE:OnCreatePlayerRagdoll(player, entity, isDead)
            if IsValid(entity) then
                local char = player:getChar()
                if char then
                    entity:SetSkin(char:getData("skin", 0))
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ragdoll system with effects and persistence
        function MODULE:OnCreatePlayerRagdoll(player, entity, isDead)
            if not IsValid(player) or not IsValid(entity) then return end

            local char = player:getChar()
            if not char then return end

            -- Set ragdoll model and skin
            entity:SetModel(player:GetModel())
            entity:SetSkin(char:getData("skin", 0))

            -- Apply body groups
            for i = 0, player:GetNumBodyGroups() - 1 do
                entity:SetBodygroup(i, player:GetBodygroup(i))
            end

            -- Store ragdoll data
            entity:SetNetVar("ragdollOwner", player:SteamID())
            entity:SetNetVar("ragdollTime", os.time())
            entity:SetNetVar("isDead", isDead)

            -- Apply death effects
            if isDead then
                -- Create blood effects
                local effectdata = EffectData()
                effectdata:SetOrigin(entity:GetPos())
                util.Effect("bloodimpact", effectdata)

                -- Set ragdoll to persist
                entity:SetSaveValue("persist", true)
            end

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(entity:GetPos()) < 500 then
                    v:notify("You see " .. char:getName() .. "'s body.")
                end
            end
        end
        ```
]]
function OnCreatePlayerRagdoll(player, entity, isDead)
end

--[[
    Purpose:
        Called when an entity is loaded.

    When Called:
        When entities are loaded from save data.

    Parameters:
        entity (Entity)
            The loaded entity.
        data (table)
            The entity data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log entity loading
        function MODULE:OnEntityLoaded(entity, data)
            print("Entity loaded: " .. tostring(entity))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restore entity properties
        function MODULE:OnEntityLoaded(entity, data)
            if data and data.pos then
                entity:SetPos(data.pos)
            end
            if data and data.ang then
                entity:SetAngles(data.ang)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced entity restoration with validation
        function MODULE:OnEntityLoaded(entity, data)
            if not IsValid(entity) or not data then return end

            -- Restore position and angles
            if data.pos then
                entity:SetPos(Vector(data.pos[1], data.pos[2], data.pos[3]))
            end
            if data.ang then
                entity:SetAngles(Angle(data.ang[1], data.ang[2], data.ang[3]))
            end

            -- Restore model
            if data.model then
                entity:SetModel(data.model)
            end

            -- Restore custom data
            if data.customData then
                entity:SetNetVar("customData", data.customData)
            end

            -- Restore health
            if data.health then
                entity:SetHealth(data.health)
            end

            -- Apply saved properties
            if data.properties then
                for key, value in pairs(data.properties) do
                    entity:SetKeyValue(key, tostring(value))
                end
            end

            -- Notify modules
            hook.Run("EntityRestored", entity, data)
        end
        ```
]]
function OnEntityLoaded(entity, data)
end

--[[
    Purpose:
        Called when entity persistence is updated.

    When Called:
        When entity save data is updated.

    Parameters:
        entity (Entity)
            The entity.
        data (table)
            The updated data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log entity update
        function MODULE:OnEntityPersistUpdated(entity, data)
            print("Entity persistence updated")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track entity changes
        function MODULE:OnEntityPersistUpdated(entity, data)
            if IsValid(entity) then
                entity:SetNetVar("lastUpdated", os.time())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced persistence tracking with validation
        function MODULE:OnEntityPersistUpdated(entity, data)
            if not IsValid(entity) or not data then return end

            -- Validate data
            if not data.pos or not data.ang then
                return
            end

            -- Store update timestamp
            entity:SetNetVar("lastUpdated", os.time())
            entity:SetNetVar("updateCount", (entity:GetNetVar("updateCount", 0) + 1))

            -- Log significant changes
            local oldPos = entity:GetNetVar("lastSavedPos")
            if oldPos then
                local dist = Vector(data.pos[1], data.pos[2], data.pos[3]):Distance(oldPos)
                if dist > 100 then
                    lia.log.add(string.format("Entity %s moved %d units",
                        tostring(entity),
                        dist),
                        FLAG_NORMAL)
                end
            end

            -- Store last saved position
            entity:SetNetVar("lastSavedPos", Vector(data.pos[1], data.pos[2], data.pos[3]))

            -- Notify modules
            hook.Run("EntityPersistenceChanged", entity, data)
        end
        ```
]]
function OnEntityPersistUpdated(entity, data)
end

--[[
    Purpose:
        Called when an entity is persisted.

    When Called:
        When entities are saved to the database.

    Parameters:
        entity (Entity)
            The entity being persisted.
        entityData (table)
            The entity data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log entity persistence
        function MODULE:OnEntityPersisted(entity, entityData)
            print("Entity persisted: " .. tostring(entity))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom data to persistence
        function MODULE:OnEntityPersisted(entity, entityData)
            if IsValid(entity) then
                entityData.customData = entity:GetNetVar("customData")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced persistence with validation and metadata
        function MODULE:OnEntityPersisted(entity, entityData)
            if not IsValid(entity) then return end

            -- Add metadata
            entityData.persistedAt = os.time()
            entityData.map = game.GetMap()
            entityData.serverName = GetHostName()

            -- Store custom data
            local customData = entity:GetNetVar("customData")
            if customData then
                entityData.customData = customData
            end

            -- Store owner if applicable
            local owner = entity:GetNetVar("owner")
            if owner then
                entityData.owner = owner
            end

            -- Validate critical data
            if not entityData.pos or not entityData.ang then
                entityData.pos = {entity:GetPos().x, entity:GetPos().y, entity:GetPos().z}
                entityData.ang = {entity:GetAngles().p, entity:GetAngles().y, entity:GetAngles().r}
            end

            -- Store model
            entityData.model = entity:GetModel()

            -- Store health
            if entity:Health() > 0 then
                entityData.health = entity:Health()
            end

            -- Log persistence
            lia.log.add(string.format("Entity %s persisted at %s",
                tostring(entity),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)
        end
        ```
]]
function OnEntityPersisted(entity, entityData)
end

--[[
    Purpose:
        Called when an item is added to a player.

    When Called:
        When items are given to players.

    Parameters:
        owner (Player)
            The item owner.
        item (Item)
            The item being added.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item addition
        function MODULE:OnItemAdded(owner, item)
            print(owner:Name() .. " received item: " .. item.uniqueID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track item additions and notify
        function MODULE:OnItemAdded(owner, item)
            local char = owner:getChar()
            if char then
                lia.log.add(string.format("%s received item: %s",
                    owner:Name(),
                    item.uniqueID),
                    FLAG_NORMAL)

                owner:notify("You received: " .. item.name)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item tracking with validation and effects
        function MODULE:OnItemAdded(owner, item)
            if not IsValid(owner) or not item then return end

            local char = owner:getChar()
            if not char then return end

            -- Log item addition
            lia.log.add(string.format("%s (%s) received item %s (ID: %s)",
                owner:Name(),
                owner:SteamID(),
                item.uniqueID,
                item.id),
                FLAG_NORMAL)

            -- Track item statistics
            local itemStats = char:getData("itemStats", {})
            itemStats.totalReceived = (itemStats.totalReceived or 0) + 1
            itemStats[item.uniqueID] = (itemStats[item.uniqueID] or 0) + 1
            char:setData("itemStats", itemStats)

            -- Apply item-specific effects
            if item.onReceived then
                item.onReceived(owner, item)
            end

            -- Notify player
            timer.Simple(0.1, function()
                if IsValid(owner) then
                    owner:notify("You received: " .. item.name)
                end
            end)

            -- Apply achievement/progress tracking
            hook.Run("ItemReceived", owner, item)
        end
        ```
]]
function OnItemAdded(owner, item)
end

--[[
    Purpose:
        Called when an item is created.

    When Called:
        When item entities are created.

    Parameters:
        itemTable (table)
            The item table.
        itemEntity (Entity)
            The item entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item creation
        function MODULE:OnItemCreated(itemTable, itemEntity)
            print("Item created: " .. itemTable.name)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize item entity on creation
        function MODULE:OnItemCreated(itemTable, itemEntity)
            if IsValid(itemEntity) then
                itemEntity:SetNetVar("itemName", itemTable.name)
                itemEntity:SetNetVar("itemID", itemTable.uniqueID)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item creation with customization and validation
        function MODULE:OnItemCreated(itemTable, itemEntity)
            if not itemTable or not IsValid(itemEntity) then return end

            -- Set item properties
            itemEntity:SetNetVar("itemName", itemTable.name)
            itemEntity:SetNetVar("itemID", itemTable.uniqueID)
            itemEntity:SetNetVar("itemCategory", itemTable.category)

            -- Apply custom model if specified
            if itemTable.model then
                itemEntity:SetModel(itemTable.model)
            end

            -- Set physics properties
            local phys = itemEntity:GetPhysicsObject()
            if IsValid(phys) then
                if itemTable.mass then
                    phys:SetMass(itemTable.mass)
                end
                if itemTable.material then
                    itemEntity:SetMaterial(itemTable.material)
                end
            end

            -- Apply glow effect for special items
            if itemTable.rare then
                itemEntity:SetRenderMode(RENDERMODE_TRANSADD)
                itemEntity:SetColor(Color(255, 255, 0, 100))
            end

            -- Log item creation
            lia.log.add(string.format("Item created: %s (ID: %s)",
                itemTable.name,
                itemTable.uniqueID),
                FLAG_NORMAL)
        end
        ```
]]
function OnItemCreated(itemTable, itemEntity)
end

--[[
    Purpose:
        Called when an item is spawned.

    When Called:
        When item entities are spawned in the world.

    Parameters:
        itemEntity (Entity)
            The spawned item entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item spawn
        function MODULE:OnItemSpawned(itemEntity)
            print("Item spawned at: " .. tostring(itemEntity:GetPos()))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track spawn and apply effects
        function MODULE:OnItemSpawned(itemEntity)
            if IsValid(itemEntity) then
                itemEntity:SetNetVar("spawnTime", os.time())

                -- Make item glow briefly
                itemEntity:SetRenderMode(RENDERMODE_TRANSADD)
                timer.Simple(2, function()
                    if IsValid(itemEntity) then
                        itemEntity:SetRenderMode(RENDERMODE_NORMAL)
                    end
                end)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced spawn system with effects and tracking
        function MODULE:OnItemSpawned(itemEntity)
            if not IsValid(itemEntity) then return end

            -- Store spawn data
            itemEntity:SetNetVar("spawnTime", os.time())
            itemEntity:SetNetVar("spawnPos", itemEntity:GetPos())

            -- Create spawn effect
            local effectdata = EffectData()
            effectdata:SetOrigin(itemEntity:GetPos())
            util.Effect("item_spawn", effectdata)

            -- Play spawn sound
            itemEntity:EmitSound("items/ammopickup.wav", 60, 100)

            -- Apply glow effect
            itemEntity:SetRenderMode(RENDERMODE_TRANSADD)
            itemEntity:SetColor(Color(255, 255, 255, 200))

            -- Remove glow after 3 seconds
            timer.Create("itemGlow_" .. itemEntity:EntIndex(), 3, 1, function()
                if IsValid(itemEntity) then
                    itemEntity:SetRenderMode(RENDERMODE_NORMAL)
                    itemEntity:SetColor(Color(255, 255, 255, 255))
                end
            end)

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(itemEntity:GetPos()) < 300 then
                    v:notify("An item has appeared nearby.")
                end
            end
        end
        ```
]]
function OnItemSpawned(itemEntity)
end

--[[
    Purpose:
        Called when OOC messages are sent.

    When Called:
        When out-of-character messages are sent.

    Parameters:
        client (Player)
            The sending player.
        message (string)
            The message content.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log OOC messages
        function MODULE:OnOOCMessageSent(client, message)
            print(client:Name() .. " [OOC]: " .. message)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Filter and log OOC
        function MODULE:OnOOCMessageSent(client, message)
            lia.log.add(string.format("%s [OOC]: %s",
                client:Name(),
                message),
                FLAG_NORMAL)

            -- Filter profanity
            if string.find(string.lower(message), "badword") then
                client:notify("Please keep OOC chat appropriate.")
                return false
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced OOC moderation with rate limiting
        function MODULE:OnOOCMessageSent(client, message)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Rate limiting
            local lastOOC = char:getData("lastOOCTime", 0)
            local timeSince = os.time() - lastOOC
            if timeSince < 3 then
                client:notify("Please wait before sending another OOC message.")
                return false
            end

            char:setData("lastOOCTime", os.time())

            -- Filter profanity
            local filteredWords = {"badword1", "badword2"}
            for _, word in ipairs(filteredWords) do
                if string.find(string.lower(message), word) then
                    client:notify("Please keep OOC chat appropriate.")
                    lia.log.add(string.format("%s tried to use profanity in OOC: %s",
                        client:Name(),
                        message),
                        FLAG_WARNING)
                    return false
                end
            end

            -- Log OOC message
            lia.log.add(string.format("%s (%s) [OOC]: %s",
                client:Name(),
                client:SteamID(),
                message),
                FLAG_NORMAL)
        end
        ```
]]
function OnOOCMessageSent(client, message)
end

--[[
    Purpose:
        Called when money is picked up.

    When Called:
        When players pick up money entities.

    Parameters:
        client (Player)
            The player picking up money.
        moneyEntity (Entity)
            The money entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log money pickup
        function MODULE:OnPickupMoney(client, moneyEntity)
            print(client:Name() .. " picked up money")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track money pickups
        function MODULE:OnPickupMoney(client, moneyEntity)
            local char = client:getChar()
            if char then
                local amount = moneyEntity:GetNetVar("amount", 0)
                lia.log.add(string.format("%s picked up $%d",
                    client:Name(),
                    amount),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced money pickup with validation and effects
        function MODULE:OnPickupMoney(client, moneyEntity)
            if not IsValid(client) or not IsValid(moneyEntity) then return end

            local char = client:getChar()
            if not char then return end

            local amount = moneyEntity:GetNetVar("amount", 0)
            if amount <= 0 then return end

            -- Log pickup
            lia.log.add(string.format("%s (%s) picked up $%d at %s",
                client:Name(),
                client:SteamID(),
                amount,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Track statistics
            local moneyStats = char:getData("moneyStats", {})
            moneyStats.totalFound = (moneyStats.totalFound or 0) + amount
            moneyStats.pickupCount = (moneyStats.pickupCount or 0) + 1
            char:setData("moneyStats", moneyStats)

            -- Create pickup effect
            local effectdata = EffectData()
            effectdata:SetOrigin(moneyEntity:GetPos())
            util.Effect("money_pickup", effectdata)

            -- Play sound
            client:EmitSound("items/smallmedkit1.wav", 60, 100)

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(moneyEntity:GetPos()) < 200 then
                    v:notify("You see " .. char:getName() .. " pick up money.")
                end
            end
        end
        ```
]]
function OnPickupMoney(client, moneyEntity)
end

--[[
    Purpose:
        Called when a player drops a weapon.

    When Called:
        When players drop weapons.

    Parameters:
        client (Player)
            The dropping player.
        originalWeapon (Entity)
            The original weapon.
        droppedEntity (Entity)
            The dropped entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log weapon drop
        function MODULE:OnPlayerDropWeapon(client, originalWeapon, droppedEntity)
            print(client:Name() .. " dropped a weapon")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track weapon drops
        function MODULE:OnPlayerDropWeapon(client, originalWeapon, droppedEntity)
            local char = client:getChar()
            if char then
                lia.log.add(string.format("%s dropped weapon: %s",
                    client:Name(),
                    originalWeapon:GetClass()),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced weapon drop system with persistence and effects
        function MODULE:OnPlayerDropWeapon(client, originalWeapon, droppedEntity)
            if not IsValid(client) or not IsValid(droppedEntity) then return end

            local char = client:getChar()
            if not char then return end

            -- Log weapon drop
            lia.log.add(string.format("%s (%s) dropped weapon %s at %s",
                client:Name(),
                client:SteamID(),
                originalWeapon:GetClass(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store weapon data on dropped entity
            droppedEntity:SetNetVar("weaponClass", originalWeapon:GetClass())
            droppedEntity:SetNetVar("droppedBy", client:SteamID())
            droppedEntity:SetNetVar("dropTime", os.time())

            -- Set persistence
            droppedEntity:SetSaveValue("persist", true)

            -- Create drop effect
            local effectdata = EffectData()
            effectdata:SetOrigin(droppedEntity:GetPos())
            util.Effect("weapon_drop", effectdata)

            -- Play sound
            droppedEntity:EmitSound("weapons/weapon_drop.wav", 60, 100)

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(droppedEntity:GetPos()) < 300 then
                    v:notify("You hear a weapon drop.")
                end
            end

            -- Track statistics
            local weaponStats = char:getData("weaponStats", {})
            weaponStats.dropped = (weaponStats.dropped or 0) + 1
            char:setData("weaponStats", weaponStats)
        end
        ```
]]
function OnPlayerDropWeapon(client, originalWeapon, droppedEntity)
end

--[[
    Purpose:
        Called when a player enters a sequence.

    When Called:
        When players start animations/sequences.

    Parameters:
        player (Player)
            The player.
        sequenceName (string)
            The sequence name.
        callback (function)
            The callback function.
        time (number)
            The sequence time.
        noFreeze (boolean)
            Whether to freeze the player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log sequence entry
        function MODULE:OnPlayerEnterSequence(player, sequenceName, callback, time, noFreeze)
            print(player:Name() .. " entered sequence: " .. sequenceName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track sequences and apply effects
        function MODULE:OnPlayerEnterSequence(player, sequenceName, callback, time, noFreeze)
            local char = player:getChar()
            if char then
                char:setData("currentSequence", sequenceName)
                char:setData("sequenceStart", os.time())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced sequence system with validation and effects
        function MODULE:OnPlayerEnterSequence(player, sequenceName, callback, time, noFreeze)
            if not IsValid(player) then return end

            local char = player:getChar()
            if not char then return end

            -- Validate sequence
            if not sequenceName or sequenceName == "" then return end

            -- Store sequence data
            char:setData("currentSequence", sequenceName)
            char:setData("sequenceStart", os.time())
            char:setData("sequenceDuration", time or 0)

            -- Log sequence entry
            lia.log.add(string.format("%s entered sequence: %s",
                player:Name(),
                sequenceName),
                FLAG_NORMAL)

            -- Apply sequence-specific effects
            if sequenceName == "sit" then
                player:SetAnimation(ACT_GMOD_SIT_ROLLERCOASTER)
            elseif sequenceName == "lay" then
                player:SetAnimation(ACT_GMOD_TAUNT_LAUGH)
            end

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(player:GetPos()) < 200 then
                    v:notify("You see " .. char:getName() .. " start " .. sequenceName .. ".")
                end
            end
        end
        ```
]]
function OnPlayerEnterSequence(player, sequenceName, callback, time, noFreeze)
end

--[[
    Purpose:
        Called when a player interacts with an item.

    When Called:
        When players use items.

    Parameters:
        client (Player)
            The interacting player.
        action (string)
            The interaction action.
        item (Item)
            The item being interacted with.
        result (any)
            The interaction result.
        data (table)
            Additional interaction data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item interactions
        function MODULE:OnPlayerInteractItem(client, action, item, result, data)
            print(client:Name() .. " used " .. item.name .. " with action: " .. action)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track interactions and apply effects
        function MODULE:OnPlayerInteractItem(client, action, item, result, data)
            local char = client:getChar()
            if char then
                lia.log.add(string.format("%s used %s (action: %s)",
                    client:Name(),
                    item.name,
                    action),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced interaction system with validation and tracking
        function MODULE:OnPlayerInteractItem(client, action, item, result, data)
            if not IsValid(client) or not item then return end

            local char = client:getChar()
            if not char then return end

            -- Log interaction
            lia.log.add(string.format("%s (%s) used %s (ID: %s) with action: %s",
                client:Name(),
                client:SteamID(),
                item.name,
                item.id,
                action),
                FLAG_NORMAL)

            -- Track item usage statistics
            local usageStats = char:getData("itemUsageStats", {})
            usageStats.total = (usageStats.total or 0) + 1
            usageStats[item.uniqueID] = (usageStats[item.uniqueID] or 0) + 1
            usageStats[action] = (usageStats[action] or 0) + 1
            char:setData("itemUsageStats", usageStats)

            -- Apply item-specific post-interaction effects
            if item.onInteract then
                item.onInteract(client, action, result, data)
            end

            -- Check for achievements
            if result and result.success then
                hook.Run("ItemInteractionSuccess", client, item, action)
            end

            -- Notify modules
            hook.Run("ItemInteractionCompleted", client, item, action, result, data)
        end
        ```
]]
function OnPlayerInteractItem(client, action, item, result, data)
end

--[[
    Purpose:
        Called when a player joins a class.

    When Called:
        When players join classes.

    Parameters:
        client (Player)
            The joining player.
        class (table)
            The class data.
        oldClass (table)
            The previous class.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log class join
        function MODULE:OnPlayerJoinClass(client, class, oldClass)
            print(client:Name() .. " joined class: " .. class.name)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track class changes and notify
        function MODULE:OnPlayerJoinClass(client, class, oldClass)
            local char = client:getChar()
            if char then
                lia.log.add(string.format("%s joined class: %s",
                    client:Name(),
                    class.name),
                    FLAG_NORMAL)

                client:notify("You joined: " .. class.name)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced class system with validation and effects
        function MODULE:OnPlayerJoinClass(client, class, oldClass)
            if not IsValid(client) or not class then return end

            local char = client:getChar()
            if not char then return end

            -- Log class change
            local oldClassName = oldClass and oldClass.name or "None"
            lia.log.add(string.format("%s (%s) joined class %s (from %s)",
                client:Name(),
                client:SteamID(),
                class.name,
                oldClassName),
                FLAG_NORMAL)

            -- Store class history
            local classHistory = char:getData("classHistory", {})
            table.insert(classHistory, {
                class = class.name,
                classID = class.index,
                time = os.time(),
                from = oldClassName
            })

            if #classHistory > 20 then
                table.remove(classHistory, 1)
            end

            char:setData("classHistory", classHistory)

            -- Apply class-specific bonuses
            if class.onJoined then
                class.onJoined(client, char, oldClass)
            end

            -- Give class starting items
            if class.startingItems then
                local inv = char:getInv()
                if inv then
                    for _, itemID in ipairs(class.startingItems) do
                        inv:add(itemID)
                    end
                end
            end

            -- Notify player
            client:notify("You joined: " .. class.name)

            -- Notify modules
            hook.Run("ClassJoined", client, class, oldClass)
        end
        ```
]]
function OnPlayerJoinClass(client, class, oldClass)
end

--[[
    Purpose:
        Called when a player leaves a sequence.

    When Called:
        When players finish animations/sequences.

    Parameters:
        player (Player)
            The player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log sequence exit
        function MODULE:OnPlayerLeaveSequence(player)
            print(player:Name() .. " left sequence")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clear sequence data
        function MODULE:OnPlayerLeaveSequence(player)
            local char = player:getChar()
            if char then
                char:setData("currentSequence", nil)
                char:setData("sequenceStart", nil)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced sequence exit with tracking and effects
        function MODULE:OnPlayerLeaveSequence(player)
            if not IsValid(player) then return end

            local char = player:getChar()
            if not char then return end

            -- Get sequence data
            local sequenceName = char:getData("currentSequence")
            local sequenceStart = char:getData("sequenceStart")

            -- Calculate duration
            if sequenceStart then
                local duration = os.time() - sequenceStart
                lia.log.add(string.format("%s left sequence %s after %d seconds",
                    player:Name(),
                    sequenceName or "unknown",
                    duration),
                    FLAG_NORMAL)
            end

            -- Clear sequence data
            char:setData("currentSequence", nil)
            char:setData("sequenceStart", nil)
            char:setData("sequenceDuration", nil)

            -- Reset animation
            player:SetAnimation(ACT_GMOD_GESTURE_BOW)
            timer.Simple(0.5, function()
                if IsValid(player) then
                    player:SetAnimation(ACT_IDLE)
                end
            end)

            -- Notify modules
            hook.Run("SequenceCompleted", player, sequenceName)
        end
        ```
]]
function OnPlayerLeaveSequence(player)
end

--[[
    Purpose:
        Called when a player loses a stack item.

    When Called:
        When stackable items are lost.

    Parameters:
        itemTypeOrItem (string|Item)
            The item type or item.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log stack item loss
        function MODULE:OnPlayerLostStackItem(itemTypeOrItem)
            local itemID = isstring(itemTypeOrItem) and itemTypeOrItem or itemTypeOrItem.uniqueID
            print("Stack item lost: " .. itemID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track stack item losses
        function MODULE:OnPlayerLostStackItem(itemTypeOrItem)
            local itemID = isstring(itemTypeOrItem) and itemTypeOrItem or itemTypeOrItem.uniqueID
            lia.log.add("Stack item lost: " .. itemID, FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced stack item tracking with analytics
        function MODULE:OnPlayerLostStackItem(itemTypeOrItem)
            local itemID = isstring(itemTypeOrItem) and itemTypeOrItem or itemTypeOrItem.uniqueID

            -- Log loss
            lia.log.add(string.format("Stack item lost: %s at %s",
                itemID,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Track global statistics
            MODULE.stackItemLosses = MODULE.stackItemLosses or {}
            MODULE.stackItemLosses[itemID] = (MODULE.stackItemLosses[itemID] or 0) + 1
        end
        ```
]]
function OnPlayerLostStackItem(itemTypeOrItem)
end

--[[
    Purpose:
        Called when a player enters observer mode.

    When Called:
        When players start spectating.

    Parameters:
        client (Player)
            The observing player.
        state (boolean)
            The observer state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log observer state change
        function MODULE:OnPlayerObserve(client, state)
            print(client:Name() .. " observer mode: " .. tostring(state))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track observer state
        function MODULE:OnPlayerObserve(client, state)
            local char = client:getChar()
            if char then
                char:setData("observerMode", state)
                lia.log.add(string.format("%s %s observer mode",
                    client:Name(),
                    state and "entered" or "left"),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced observer system with restrictions and logging
        function MODULE:OnPlayerObserve(client, state)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Store observer state
            char:setData("observerMode", state)
            char:setData("observerTime", state and os.time() or nil)

            -- Log observer state change
            lia.log.add(string.format("%s (%s) %s observer mode at %s",
                client:Name(),
                client:SteamID(),
                state and "entered" or "left",
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Apply observer restrictions
            if state then
                -- Disable player movement
                client:SetMoveType(MOVETYPE_OBSERVER)
                client:SetNoDraw(true)

                -- Notify admins
                for _, v in player.Iterator() do
                    if v:IsAdmin() then
                        v:notify(client:Name() .. " entered observer mode")
                    end
                end
            else
                -- Restore player
                client:SetMoveType(MOVETYPE_WALK)
                client:SetNoDraw(false)

                -- Calculate observer duration
                local observerTime = char:getData("observerTime")
                if observerTime then
                    local duration = os.time() - observerTime
                    lia.log.add(string.format("%s was in observer mode for %d seconds",
                        client:Name(),
                        duration),
                        FLAG_NORMAL)
                end
            end
        end
        ```
]]
function OnPlayerObserve(client, state)
end

--[[
    Purpose:
        Called when a player purchases a door.

    When Called:
        When door purchases occur.

    Parameters:
        client (Player)
            The purchasing player.
        door (Entity)
            The door entity.
        isPurchase (boolean)
            Whether it's a purchase or sale.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door purchase
        function MODULE:OnPlayerPurchaseDoor(client, door, isPurchase)
            local action = isPurchase and "purchased" or "sold"
            print(client:Name() .. " " .. action .. " a door")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track door transactions
        function MODULE:OnPlayerPurchaseDoor(client, door, isPurchase)
            local char = client:getChar()
            if char then
                local action = isPurchase and "purchased" or "sold"
                lia.log.add(string.format("%s %s door at %s",
                    client:Name(),
                    action,
                    tostring(door:GetPos())),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door transaction system with validation and logging
        function MODULE:OnPlayerPurchaseDoor(client, door, isPurchase)
            if not IsValid(client) or not IsValid(door) then return end

            local char = client:getChar()
            if not char then return end

            local action = isPurchase and "purchased" or "sold"
            local price = door:GetNetVar("price", 0)

            -- Log transaction
            lia.log.add(string.format("%s (%s) %s door at %s for $%d",
                client:Name(),
                client:SteamID(),
                action,
                tostring(door:GetPos()),
                price),
                FLAG_NORMAL)

            -- Store transaction history
            local doorHistory = char:getData("doorHistory", {})
            table.insert(doorHistory, {
                door = tostring(door),
                position = door:GetPos(),
                action = action,
                price = price,
                time = os.time()
            })

            if #doorHistory > 50 then
                table.remove(doorHistory, 1)
            end

            char:setData("doorHistory", doorHistory)

            -- Update door ownership
            if isPurchase then
                door:SetNetVar("owner", client:SteamID())
                door:SetNetVar("owned", true)
            else
                door:SetNetVar("owner", nil)
                door:SetNetVar("owned", false)
            end

            -- Notify nearby players
            for _, v in player.Iterator() do
                if v:GetPos():Distance(door:GetPos()) < 200 then
                    v:notify("You see " .. char:getName() .. " " .. action .. " the door.")
                end
            end
        end
        ```
]]
function OnPlayerPurchaseDoor(client, door, isPurchase)
end

--[[
    Purpose:
        Called when a player switches classes.

    When Called:
        When players change classes.

    Parameters:
        client (Player)
            The switching player.
        class (table)
            The new class.
        oldClass (table)
            The old class.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log class switch
        function MODULE:OnPlayerSwitchClass(client, class, oldClass)
            print(client:Name() .. " switched to class: " .. class.name)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track class switches
        function MODULE:OnPlayerSwitchClass(client, class, oldClass)
            local char = client:getChar()
            if char then
                local oldName = oldClass and oldClass.name or "None"
                lia.log.add(string.format("%s switched from %s to %s",
                    client:Name(),
                    oldName,
                    class.name),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced class switching with validation and effects
        function MODULE:OnPlayerSwitchClass(client, class, oldClass)
            if not IsValid(client) or not class then return end

            local char = client:getChar()
            if not char then return end

            local oldName = oldClass and oldClass.name or "None"

            -- Log class switch
            lia.log.add(string.format("%s (%s) switched from class %s to %s",
                client:Name(),
                client:SteamID(),
                oldName,
                class.name),
                FLAG_NORMAL)

            -- Store class switch history
            local switchHistory = char:getData("classSwitchHistory", {})
            table.insert(switchHistory, {
                from = oldName,
                to = class.name,
                fromID = oldClass and oldClass.index or nil,
                toID = class.index,
                time = os.time()
            })

            if #switchHistory > 30 then
                table.remove(switchHistory, 1)
            end

            char:setData("classSwitchHistory", switchHistory)

            -- Apply class switch effects
            if oldClass and oldClass.onLeave then
                oldClass.onLeave(client, char)
            end

            if class.onJoined then
                class.onJoined(client, char, oldClass)
            end

            -- Notify player
            client:notify("You switched to: " .. class.name)

            -- Notify modules
            hook.Run("ClassSwitched", client, class, oldClass)
        end
        ```
]]
function OnPlayerSwitchClass(client, class, oldClass)
end

--[[
    Purpose:
        Called when salary is adjusted.

    When Called:
        When salary calculations are modified.

    Parameters:
        client (Player)
            The player whose salary is adjusted.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log salary adjustment
        function MODULE:OnSalaryAdjust(client)
            print("Salary adjusted for: " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track salary adjustments
        function MODULE:OnSalaryAdjust(client)
            local char = client:getChar()
            if char then
                char:setData("salaryAdjusted", true)
                char:setData("salaryAdjustTime", os.time())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary adjustment with calculations and logging
        function MODULE:OnSalaryAdjust(client)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Store adjustment data
            char:setData("salaryAdjusted", true)
            char:setData("salaryAdjustTime", os.time())

            -- Calculate adjustment based on playtime
            local playTime = char:getData("playTime", 0)
            local adjustmentFactor = 1.0

            if playTime > 3600 then -- 1 hour
                adjustmentFactor = 1.1
            elseif playTime > 7200 then -- 2 hours
                adjustmentFactor = 1.2
            end

            -- Apply faction bonuses
            local faction = char:getFaction()
            if faction and faction.salaryBonus then
                adjustmentFactor = adjustmentFactor * faction.salaryBonus
            end

            char:setData("salaryAdjustmentFactor", adjustmentFactor)

            lia.log.add(string.format("Salary adjusted for %s (factor: %.2f)",
                client:Name(),
                adjustmentFactor),
                FLAG_NORMAL)
        end
        ```
]]
function OnSalaryAdjust(client)
end

--[[
    Purpose:
        Called when salary is given to a player.

    When Called:
        When salary payments are made.

    Parameters:
        client (Player)
            The receiving player.
        character (Character)
            The character.
        pay (number)
            The payment amount.
        faction (table)
            The faction.
        class (table)
            The class.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log salary payment
        function MODULE:OnSalaryGiven(client, character, pay, faction, class)
            print(client:Name() .. " received salary: $" .. pay)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track salary payments
        function MODULE:OnSalaryGiven(client, character, pay, faction, class)
            lia.log.add(string.format("%s received salary: $%d",
                client:Name(),
                pay),
                FLAG_NORMAL)

            -- Track total earnings
            local totalEarnings = character:getData("totalEarnings", 0)
            character:setData("totalEarnings", totalEarnings + pay)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary system with tracking and analytics
        function MODULE:OnSalaryGiven(client, character, pay, faction, class)
            if not IsValid(client) or not character then return end

            -- Log salary payment
            lia.log.add(string.format("%s (%s) received salary: $%d (Faction: %s, Class: %s)",
                client:Name(),
                client:SteamID(),
                pay,
                faction and faction.name or "None",
                class and class.name or "None"),
                FLAG_NORMAL)

            -- Track salary statistics
            local salaryStats = character:getData("salaryStats", {})
            salaryStats.totalReceived = (salaryStats.totalReceived or 0) + pay
            salaryStats.paymentCount = (salaryStats.paymentCount or 0) + 1
            salaryStats.lastPayment = os.time()
            salaryStats.lastAmount = pay
            character:setData("salaryStats", salaryStats)

            -- Track faction/class earnings
            if faction then
                local factionEarnings = character:getData("factionEarnings", {})
                factionEarnings[faction.uniqueID] = (factionEarnings[faction.uniqueID] or 0) + pay
                character:setData("factionEarnings", factionEarnings)
            end

            -- Apply bonus tracking
            local adjustmentFactor = character:getData("salaryAdjustmentFactor", 1.0)
            if adjustmentFactor > 1.0 then
                local bonus = pay * (adjustmentFactor - 1.0)
                salaryStats.totalBonus = (salaryStats.totalBonus or 0) + bonus
                character:setData("salaryStats", salaryStats)
            end

            -- Notify player
            client:notify("You received your salary: $" .. pay)

            -- Notify modules
            hook.Run("SalaryPaid", client, character, pay, faction, class)
        end
        ```
]]
function OnSalaryGiven(client, character, pay, faction, class)
end

--[[
    Purpose:
        Called when saved items are loaded.

    When Called:
        When persisted items are restored.

    Parameters:
        loadedItems (table)
            The loaded items.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item loading
        function MODULE:OnSavedItemLoaded(loadedItems)
            print("Loaded " .. #loadedItems .. " items")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Process loaded items
        function MODULE:OnSavedItemLoaded(loadedItems)
            lia.log.add(string.format("Loaded %d saved items", #loadedItems), FLAG_NORMAL)

            for _, item in ipairs(loadedItems) do
                if item.customData then
                    item:setData("restored", true)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item restoration with validation
        function MODULE:OnSavedItemLoaded(loadedItems)
            if not loadedItems then return end

            local successCount = 0
            local failCount = 0

            for _, item in ipairs(loadedItems) do
                if IsValid(item) then
                    -- Restore item data
                    if item.customData then
                        item:setData("restored", true)
                        item:setData("restoredAt", os.time())
                    end

                    -- Validate item
                    if item:validateItem() then
                        successCount = successCount + 1
                    else
                        failCount = failCount + 1
                        item:remove()
                    end
                else
                    failCount = failCount + 1
                end
            end

            lia.log.add(string.format("Loaded %d items: %d success, %d failed",
                #loadedItems,
                successCount,
                failCount),
                FLAG_NORMAL)
        end
        ```
]]
function OnSavedItemLoaded(loadedItems)
end

--[[
    Purpose:
        Called when server logs are generated.

    When Called:
        When server events are logged.

    Parameters:
        client (Player)
            The involved player.
        logType (string)
            The log type.
        logString (string)
            The log message.
        category (string)
            The log category.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log server events
        function MODULE:OnServerLog(client, logType, logString, category)
            print("[LOG] " .. logType .. ": " .. logString)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Filter and log important events
        function MODULE:OnServerLog(client, logType, logString, category)
            if category == "admin" or category == "warning" then
                lia.log.add(string.format("[%s] %s: %s",
                    category or "general",
                    logType,
                    logString),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced logging system with categorization and storage
        function MODULE:OnServerLog(client, logType, logString, category)
            category = category or "general"

            -- Log to file based on category
            local logFile = "lilia_logs/" .. category .. "_" .. os.date("%Y-%m-%d") .. ".txt"
            local logEntry = string.format("[%s] %s: %s - %s\n",
                os.date("%H:%M:%S"),
                logType,
                client and client:Name() or "SERVER",
                logString)

            file.Append(logFile, logEntry)

            -- Store critical logs in database
            if category == "admin" or category == "warning" or category == "error" then
                lia.db.query("INSERT INTO server_logs (category, log_type, message, player, timestamp) VALUES (?, ?, ?, ?, ?)", {
                    category,
                    logType,
                    logString,
                    client and client:SteamID() or "SERVER",
                    os.time()
                })
            end

            -- Notify admins of critical events
            if category == "error" or category == "warning" then
                for _, v in player.Iterator() do
                    if v:IsAdmin() then
                        v:notify("[LOG] " .. logType .. ": " .. logString)
                    end
                end
            end
        end
        ```
]]
function OnServerLog(client, logType, logString, category)
end

--[[
    Purpose:
        Called when a ticket is claimed.

    When Called:
        When support tickets are claimed.

    Parameters:
        client (Player)
            The claiming staff member.
        requester (Player)
            The ticket requester.
        ticketMessage (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log ticket claim
        function MODULE:OnTicketClaimed(client, requester, ticketMessage)
            print(client:Name() .. " claimed ticket from " .. requester:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track ticket claims
        function MODULE:OnTicketClaimed(client, requester, ticketMessage)
            lia.log.add(string.format("%s claimed ticket from %s",
                client:Name(),
                requester:Name()),
                FLAG_NORMAL)

            requester:notify("Your ticket has been claimed by " .. client:Name())
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ticket system with tracking and notifications
        function MODULE:OnTicketClaimed(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            -- Log ticket claim
            lia.log.add(string.format("%s (%s) claimed ticket from %s (%s) - %s",
                client:Name(),
                client:SteamID(),
                requester:Name(),
                requester:SteamID(),
                ticketMessage),
                FLAG_NORMAL)

            -- Store claim data
            local ticketData = {
                claimedBy = client:SteamID(),
                claimedByName = client:Name(),
                claimedAt = os.time(),
                message = ticketMessage
            }

            requester:setData("ticketClaimed", ticketData)

            -- Notify requester
            requester:notify("Your ticket has been claimed by " .. client:Name())

            -- Notify other staff
            for _, v in player.Iterator() do
                if v:IsAdmin() and v ~= client then
                    v:notify(client:Name() .. " claimed a ticket from " .. requester:Name())
                end
            end

            -- Track staff performance
            local staffStats = client:getData("staffStats", {})
            staffStats.ticketsClaimed = (staffStats.ticketsClaimed or 0) + 1
            client:setData("staffStats", staffStats)
        end
        ```
]]
function OnTicketClaimed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a ticket is closed.

    When Called:
        When support tickets are closed.

    Parameters:
        client (Player)
            The closing staff member.
        requester (Player)
            The ticket requester.
        ticketMessage (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log ticket closure
        function MODULE:OnTicketClosed(client, requester, ticketMessage)
            print(client:Name() .. " closed ticket from " .. requester:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track ticket closures
        function MODULE:OnTicketClosed(client, requester, ticketMessage)
            lia.log.add(string.format("%s closed ticket from %s",
                client:Name(),
                requester:Name()),
                FLAG_NORMAL)

            requester:notify("Your ticket has been closed by " .. client:Name())
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ticket closure with analytics
        function MODULE:OnTicketClosed(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            -- Get ticket data
            local ticketData = requester:getData("ticketClaimed")
            local duration = 0
            if ticketData and ticketData.claimedAt then
                duration = os.time() - ticketData.claimedAt
            end

            -- Log closure
            lia.log.add(string.format("%s (%s) closed ticket from %s (%s) - Duration: %d seconds",
                client:Name(),
                client:SteamID(),
                requester:Name(),
                requester:SteamID(),
                duration),
                FLAG_NORMAL)

            -- Clear ticket data
            requester:setData("ticketClaimed", nil)

            -- Notify requester
            requester:notify("Your ticket has been closed by " .. client:Name())

            -- Track staff performance
            local staffStats = client:getData("staffStats", {})
            staffStats.ticketsClosed = (staffStats.ticketsClosed or 0) + 1
            staffStats.totalTicketTime = (staffStats.totalTicketTime or 0) + duration
            client:setData("staffStats", staffStats)

            -- Store ticket history
            local ticketHistory = requester:getData("ticketHistory", {})
            table.insert(ticketHistory, {
                closedBy = client:SteamID(),
                closedByName = client:Name(),
                closedAt = os.time(),
                duration = duration,
                message = ticketMessage
            })

            if #ticketHistory > 20 then
                table.remove(ticketHistory, 1)
            end

            requester:setData("ticketHistory", ticketHistory)
        end
        ```
]]
function OnTicketClosed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a ticket is created.

    When Called:
        When support tickets are submitted.

    Parameters:
        requester (Player)
            The ticket requester.
        message (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log ticket creation
        function MODULE:OnTicketCreated(requester, message)
            print(requester:Name() .. " created a ticket: " .. message)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track tickets and notify staff
        function MODULE:OnTicketCreated(requester, message)
            lia.log.add(string.format("%s created ticket: %s",
                requester:Name(),
                message),
                FLAG_NORMAL)

            -- Notify online staff
            for _, v in player.Iterator() do
                if v:IsAdmin() then
                    v:notify("New ticket from " .. requester:Name())
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ticket system with tracking and prioritization
        function MODULE:OnTicketCreated(requester, message)
            if not IsValid(requester) then return end

            local char = requester:getChar()
            if not char then return end

            -- Log ticket creation
            lia.log.add(string.format("%s (%s) created ticket: %s",
                requester:Name(),
                requester:SteamID(),
                message),
                FLAG_NORMAL)

            -- Store ticket data
            local ticketID = os.time() .. "_" .. requester:SteamID()
            local ticketData = {
                id = ticketID,
                requester = requester:SteamID(),
                requesterName = requester:Name(),
                message = message,
                createdAt = os.time(),
                status = "open"
            }

            char:setData("currentTicket", ticketData)

            -- Track ticket statistics
            local ticketStats = char:getData("ticketStats", {})
            ticketStats.totalCreated = (ticketStats.totalCreated or 0) + 1
            char:setData("ticketStats", ticketStats)

            -- Notify online staff
            local staffCount = 0
            for _, v in player.Iterator() do
                if v:IsAdmin() then
                    v:notify("New ticket from " .. requester:Name() .. ": " .. message)
                    staffCount = staffCount + 1
                end
            end

            -- Notify requester
            requester:notify("Your ticket has been submitted. " .. staffCount .. " staff members have been notified.")

            -- Store in database
            lia.db.query("INSERT INTO tickets (ticket_id, requester, message, created_at, status) VALUES (?, ?, ?, ?, ?)", {
                ticketID,
                requester:SteamID(),
                message,
                os.time(),
                "open"
            })
        end
        ```
]]
function OnTicketCreated(requester, message)
end

--[[
    Purpose:
        Called when a player is transferred.

    When Called:
        When character transfers occur.

    Parameters:
        targetPlayer (Player)
            The transferred player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log transfer
        function MODULE:OnTransferred(targetPlayer)
            print(targetPlayer:Name() .. " was transferred")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track transfers
        function MODULE:OnTransferred(targetPlayer)
            local char = targetPlayer:getChar()
            if char then
                char:setData("transferred", true)
                lia.log.add(targetPlayer:Name() .. " was transferred", FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer system with tracking
        function MODULE:OnTransferred(targetPlayer)
            if not IsValid(targetPlayer) then return end

            local char = targetPlayer:getChar()
            if not char then return end

            -- Log transfer
            lia.log.add(string.format("%s (%s) was transferred at %s",
                targetPlayer:Name(),
                targetPlayer:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store transfer data
            char:setData("transferred", true)
            char:setData("transferTime", os.time())

            -- Track transfer history
            local transferHistory = char:getData("transferHistory", {})
            table.insert(transferHistory, {
                time = os.time(),
                steamID = targetPlayer:SteamID()
            })

            if #transferHistory > 10 then
                table.remove(transferHistory, 1)
            end

            char:setData("transferHistory", transferHistory)
        end
        ```
]]
function OnTransferred(targetPlayer)
end

--[[
    Purpose:
        Called when a usergroup is created.

    When Called:
        When admin usergroups are created.

    Parameters:
        groupName (string)
            The group name.
        groupData (table)
            The group data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log usergroup creation
        function MODULE:OnUsergroupCreated(groupName, groupData)
            print("Usergroup created: " .. groupName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track usergroup creation
        function MODULE:OnUsergroupCreated(groupName, groupData)
            lia.log.add(string.format("Usergroup created: %s", groupName), FLAG_NORMAL)

            -- Initialize default permissions
            if not groupData.privileges then
                groupData.privileges = {}
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced usergroup system with validation
        function MODULE:OnUsergroupCreated(groupName, groupData)
            if not groupName or groupName == "" then return end

            -- Log creation
            lia.log.add(string.format("Usergroup created: %s at %s",
                groupName,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Validate and initialize group data
            if not groupData.privileges then
                groupData.privileges = {}
            end

            if not groupData.inherit then
                groupData.inherit = {}
            end

            -- Set default values
            groupData.created = os.time()
            groupData.memberCount = 0

            -- Store in database
            lia.db.query("INSERT INTO usergroups (name, data, created_at) VALUES (?, ?, ?)", {
                groupName,
                util.TableToJSON(groupData),
                os.time()
            })

            -- Notify modules
            hook.Run("UsergroupCreated", groupName, groupData)
        end
        ```
]]
function OnUsergroupCreated(groupName, groupData)
end

--[[
    Purpose:
        Called when usergroup permissions change.

    When Called:
        When admin usergroup permissions are modified.

    Parameters:
        groupName (string)
            The group name.
        groupData (table)
            The group data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log permission changes
        function MODULE:OnUsergroupPermissionsChanged(groupName, groupData)
            print("Permissions changed for: " .. groupName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track permission changes
        function MODULE:OnUsergroupPermissionsChanged(groupName, groupData)
            lia.log.add(string.format("Permissions changed for %s", groupName), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced permission tracking with validation
        function MODULE:OnUsergroupPermissionsChanged(groupName, groupData)
            if not groupName or not groupData then return end

            -- Log permission change
            lia.log.add(string.format("Permissions changed for %s at %s",
                groupName,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_CRITICAL)

            -- Validate permissions
            if groupData.privileges then
                for priv, enabled in pairs(groupData.privileges) do
                    if not hook.Run("IsValidPrivilege", priv) then
                        lia.log.add(string.format("Invalid privilege '%s' in group %s", priv, groupName), FLAG_WARNING)
                    end
                end
            end

            -- Update database
            lia.db.query("UPDATE usergroups SET data = ?, updated_at = ? WHERE name = ?", {
                util.TableToJSON(groupData),
                os.time(),
                groupName
            })

            -- Notify affected players
            for _, v in player.Iterator() do
                if v:GetUserGroup() == groupName then
                    v:notify("Your usergroup permissions have been updated.")
                end
            end

            -- Notify modules
            hook.Run("UsergroupPermissionsUpdated", groupName, groupData)
        end
        ```
]]
function OnUsergroupPermissionsChanged(groupName, groupData)
end

--[[
    Purpose:
        Called when a usergroup is removed.

    When Called:
        When admin usergroups are deleted.

    Parameters:
        groupName (string)
            The group name.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log usergroup removal
        function MODULE:OnUsergroupRemoved(groupName)
            print("Usergroup removed: " .. groupName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track removal and reassign members
        function MODULE:OnUsergroupRemoved(groupName)
            lia.log.add(string.format("Usergroup removed: %s", groupName), FLAG_NORMAL)

            -- Reassign members to default group
            for _, v in player.Iterator() do
                if v:GetUserGroup() == groupName then
                    v:SetUserGroup("user")
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced removal with member reassignment
        function MODULE:OnUsergroupRemoved(groupName)
            if not groupName then return end

            -- Log removal
            lia.log.add(string.format("Usergroup removed: %s at %s",
                groupName,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_CRITICAL)

            -- Count and reassign members
            local memberCount = 0
            for _, v in player.Iterator() do
                if v:GetUserGroup() == groupName then
                    v:SetUserGroup("user")
                    v:notify("Your usergroup has been removed. You have been moved to the default group.")
                    memberCount = memberCount + 1
                end
            end

            -- Update database
            lia.db.query("UPDATE players SET usergroup = 'user' WHERE usergroup = ?", {groupName})
            lia.db.query("DELETE FROM usergroups WHERE name = ?", {groupName})

            -- Log member reassignment
            if memberCount > 0 then
                lia.log.add(string.format("%d members reassigned from %s", memberCount, groupName), FLAG_NORMAL)
            end

            -- Notify modules
            hook.Run("UsergroupRemoved", groupName)
        end
        ```
]]
function OnUsergroupRemoved(groupName)
end

--[[
    Purpose:
        Called when a usergroup is renamed.

    When Called:
        When admin usergroups are renamed.

    Parameters:
        oldName (string)
            The old group name.
        newName (string)
            The new group name.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log rename
        function MODULE:OnUsergroupRenamed(oldName, newName)
            print("Usergroup renamed: " .. oldName .. " -> " .. newName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track rename and update players
        function MODULE:OnUsergroupRenamed(oldName, newName)
            lia.log.add(string.format("Usergroup renamed: %s -> %s", oldName, newName), FLAG_NORMAL)

            -- Update player usergroups
            for _, v in player.Iterator() do
                if v:GetUserGroup() == oldName then
                    v:SetUserGroup(newName)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced rename with validation and updates
        function MODULE:OnUsergroupRenamed(oldName, newName)
            if not oldName or not newName or oldName == newName then return end

            -- Log rename
            lia.log.add(string.format("Usergroup renamed: %s -> %s at %s",
                oldName,
                newName,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_CRITICAL)

            -- Update database
            lia.db.query("UPDATE usergroups SET name = ?, updated_at = ? WHERE name = ?", {
                newName,
                os.time(),
                oldName
            })

            lia.db.query("UPDATE players SET usergroup = ? WHERE usergroup = ?", {newName, oldName})

            -- Update player usergroups
            local updatedCount = 0
            for _, v in player.Iterator() do
                if v:GetUserGroup() == oldName then
                    v:SetUserGroup(newName)
                    v:notify("Your usergroup has been renamed to: " .. newName)
                    updatedCount = updatedCount + 1
                end
            end

            if updatedCount > 0 then
                lia.log.add(string.format("%d players updated for rename", updatedCount), FLAG_NORMAL)
            end

            -- Notify modules
            hook.Run("UsergroupRenamed", oldName, newName)
        end
        ```
]]
function OnUsergroupRenamed(oldName, newName)
end

--[[
    Purpose:
        Called when a vendor is edited.

    When Called:
        When vendor settings are modified.

    Parameters:
        client (Player)
            The editing player.
        vendor (Entity)
            The vendor entity.
        key (string)
            The edited property.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log vendor edit
        function MODULE:OnVendorEdited(client, vendor, key)
            print(client:Name() .. " edited vendor: " .. key)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track vendor edits
        function MODULE:OnVendorEdited(client, vendor, key)
            lia.log.add(string.format("%s edited vendor %s: %s",
                client:Name(),
                tostring(vendor),
                key),
                FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced vendor edit tracking with validation
        function MODULE:OnVendorEdited(client, vendor, key)
            if not IsValid(client) or not IsValid(vendor) then return end

            -- Log edit
            lia.log.add(string.format("%s (%s) edited vendor %s: %s at %s",
                client:Name(),
                client:SteamID(),
                tostring(vendor),
                key,
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store edit history
            local editHistory = vendor:GetNetVar("editHistory", {})
            table.insert(editHistory, {
                editor = client:SteamID(),
                editorName = client:Name(),
                key = key,
                time = os.time()
            })

            if #editHistory > 50 then
                table.remove(editHistory, 1)
            end

            vendor:SetNetVar("editHistory", editHistory)

            -- Validate edit
            if key == "price" then
                local price = vendor:GetNetVar("price", 0)
                if price < 0 then
                    vendor:SetNetVar("price", 0)
                    client:notify("Price cannot be negative.")
                end
            end

            -- Notify modules
            hook.Run("VendorEdited", vendor, key, client)
        end
        ```
]]
function OnVendorEdited(client, vendor, key)
end

--[[
    Purpose:
        Called when a player accesses a vendor.

    When Called:
        When players interact with vendors.

    Parameters:
        activator (Player)
            The player accessing the vendor.
        vendor (Entity)
            The vendor entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log vendor access
        function MODULE:PlayerAccessVendor(activator, vendor)
            print(activator:Name() .. " accessed vendor")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track vendor access
        function MODULE:PlayerAccessVendor(activator, vendor)
            local char = activator:getChar()
            if char then
                lia.log.add(string.format("%s accessed vendor at %s",
                    activator:Name(),
                    tostring(vendor:GetPos())),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced vendor access tracking with restrictions
        function MODULE:PlayerAccessVendor(activator, vendor)
            if not IsValid(activator) or not IsValid(vendor) then return end

            local char = activator:getChar()
            if not char then return end

            -- Log access
            lia.log.add(string.format("%s (%s) accessed vendor at %s",
                activator:Name(),
                activator:SteamID(),
                tostring(vendor:GetPos())),
                FLAG_NORMAL)

            -- Track access statistics
            local vendorStats = char:getData("vendorStats", {})
            vendorStats.accessCount = (vendorStats.accessCount or 0) + 1
            vendorStats.lastAccess = os.time()
            char:setData("vendorStats", vendorStats)

            -- Check vendor restrictions
            local vendorData = vendor:GetNetVar("vendorData")
            if vendorData and vendorData.restricted then
                local faction = char:getFaction()
                if faction and not vendorData.allowedFactions[faction.uniqueID] then
                    activator:notify("You don't have access to this vendor.")
                    return false
                end
            end
        end
        ```
]]
function PlayerAccessVendor(activator, vendor)
end

--[[
    Purpose:
        Called when a player is detected cheating.

    When Called:
        When anti-cheat systems detect cheating.

    Parameters:
        client (Player)
            The cheating player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log cheat detection
        function MODULE:PlayerCheatDetected(client)
            print("Cheater detected: " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle cheater with logging
        function MODULE:PlayerCheatDetected(client)
            lia.log.add(string.format("Cheater detected: %s (%s)",
                client:Name(),
                client:SteamID()),
                FLAG_CRITICAL)

            client:Kick("Cheating detected")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced anti-cheat with logging and actions
        function MODULE:PlayerCheatDetected(client)
            if not IsValid(client) then return end

            -- Log detection
            lia.log.add(string.format("CHEATER DETECTED: %s (%s) at %s",
                client:Name(),
                client:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_CRITICAL)

            -- Store cheater data
            local char = client:getChar()
            if char then
                char:setData("isCheater", true)
                char:setData("cheatDetectedAt", os.time())
                char:save()
            end

            -- Notify admins
            for _, v in player.Iterator() do
                if v:IsAdmin() then
                    v:notify("[ANTI-CHEAT] " .. client:Name() .. " detected as cheater")
                end
            end

            -- Ban player
            client:Ban(0, "Cheating detected")
            client:Kick("Cheating detected - You have been banned")
        end
        ```
]]
function PlayerCheatDetected(client)
end

--[[
    Purpose:
        Called when a player is gagged.

    When Called:
        When players are gagged by admins.

    Parameters:
        target (Player)
            The player being gagged.
        admin (Player)
            The admin performing the gag.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log gag
        function MODULE:PlayerGagged(target, admin)
            print(admin:Name() .. " gagged " .. target:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track gags
        function MODULE:PlayerGagged(target, admin)
            local char = target:getChar()
            if char then
                char:setData("gagged", true)
                lia.log.add(string.format("%s gagged %s",
                    admin:Name(),
                    target:Name()),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced gag system with tracking and duration
        function MODULE:PlayerGagged(target, admin)
            if not IsValid(target) or not IsValid(admin) then return end

            local char = target:getChar()
            if not char then return end

            -- Log gag
            lia.log.add(string.format("%s (%s) gagged %s (%s) at %s",
                admin:Name(),
                admin:SteamID(),
                target:Name(),
                target:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store gag data
            char:setData("gagged", true)
            char:setData("gaggedBy", admin:SteamID())
            char:setData("gaggedAt", os.time())
            char:setData("gagDuration", 0) -- 0 = permanent
            char:save()

            -- Store gag history
            local gagHistory = char:getData("gagHistory", {})
            table.insert(gagHistory, {
                admin = admin:SteamID(),
                adminName = admin:Name(),
                time = os.time(),
                duration = 0
            })

            if #gagHistory > 20 then
                table.remove(gagHistory, 1)
            end

            char:setData("gagHistory", gagHistory)

            -- Notify player
            target:notify("You have been gagged by " .. admin:Name())
        end
        ```
]]
function PlayerGagged(target, admin)
end

--[[
    Purpose:
        Called when player chat messages are sent.

    When Called:
        When chat messages are processed server-side.

    Parameters:
        speaker (Player)
            The message sender.
        chatType (string)
            The chat type.
        text (string)
            The message text.
        anonymous (boolean)
            Whether the message is anonymous.
        receivers (table)
            The message receivers.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log messages
        function MODULE:PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
            print(speaker:Name() .. " [" .. chatType .. "]: " .. text)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track and filter messages
        function MODULE:PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
            lia.log.add(string.format("%s [%s]: %s",
                speaker:Name(),
                chatType,
                text),
                FLAG_NORMAL)

            -- Filter profanity
            if string.find(string.lower(text), "badword") then
                return false -- Prevent message
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced message system with moderation and analytics
        function MODULE:PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
            if not IsValid(speaker) then return end

            local char = speaker:getChar()
            if not char then return end

            -- Check if gagged
            if char:getData("gagged", false) then
                speaker:notify("You are gagged and cannot speak.")
                return false
            end

            -- Check if muted
            if char:getData("muted", false) then
                speaker:notify("You are muted and cannot speak.")
                return false
            end

            -- Filter profanity
            local filteredWords = {"badword1", "badword2"}
            for _, word in ipairs(filteredWords) do
                if string.find(string.lower(text), word) then
                    speaker:notify("Your message contained inappropriate language.")
                    lia.log.add(string.format("%s tried to use profanity: %s",
                        speaker:Name(),
                        text),
                        FLAG_WARNING)
                    return false
                end
            end

            -- Log message
            lia.log.add(string.format("%s (%s) [%s]%s: %s",
                speaker:Name(),
                speaker:SteamID(),
                chatType,
                anonymous and " [ANON]" or "",
                text),
                FLAG_NORMAL)

            -- Track message statistics
            local msgStats = char:getData("messageStats", {})
            msgStats.total = (msgStats.total or 0) + 1
            msgStats[chatType] = (msgStats[chatType] or 0) + 1
            char:setData("messageStats", msgStats)
        end
        ```
]]
function PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
end

--[[
    Purpose:
        Called when a player's model changes.

    When Called:
        When player models are changed.

    Parameters:
        client (Player)
            The player whose model changed.
        value (string)
            The new model.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log model change
        function MODULE:PlayerModelChanged(client, value)
            print(client:Name() .. " changed model to: " .. value)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track model changes
        function MODULE:PlayerModelChanged(client, value)
            local char = client:getChar()
            if char then
                char:setData("currentModel", value)
                lia.log.add(string.format("%s changed model to: %s",
                    client:Name(),
                    value),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model change tracking with validation
        function MODULE:PlayerModelChanged(client, value)
            if not IsValid(client) or not value then return end

            local char = client:getChar()
            if not char then return end

            -- Validate model
            if not util.IsValidModel(value) then
                client:notify("Invalid model: " .. value)
                return
            end

            -- Log model change
            local oldModel = char:getData("currentModel")
            lia.log.add(string.format("%s (%s) changed model from %s to %s",
                client:Name(),
                client:SteamID(),
                oldModel or "unknown",
                value),
                FLAG_NORMAL)

            -- Store model
            char:setData("currentModel", value)
            char:setData("modelChangedAt", os.time())

            -- Track model history
            local modelHistory = char:getData("modelHistory", {})
            table.insert(modelHistory, {
                model = value,
                time = os.time(),
                from = oldModel
            })

            if #modelHistory > 20 then
                table.remove(modelHistory, 1)
            end

            char:setData("modelHistory", modelHistory)

            -- Apply model-specific effects
            hook.Run("ModelChanged", client, value, oldModel)
        end
        ```
]]
function PlayerModelChanged(client, value)
end

--[[
    Purpose:
        Called when a player is muted.

    When Called:
        When players are muted by admins.

    Parameters:
        target (Player)
            The player being muted.
        admin (Player)
            The admin performing the mute.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log mute
        function MODULE:PlayerMuted(target, admin)
            print(admin:Name() .. " muted " .. target:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track mutes
        function MODULE:PlayerMuted(target, admin)
            local char = target:getChar()
            if char then
                char:setData("muted", true)
                lia.log.add(string.format("%s muted %s",
                    admin:Name(),
                    target:Name()),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced mute system with tracking and duration
        function MODULE:PlayerMuted(target, admin)
            if not IsValid(target) or not IsValid(admin) then return end

            local char = target:getChar()
            if not char then return end

            -- Log mute
            lia.log.add(string.format("%s (%s) muted %s (%s) at %s",
                admin:Name(),
                admin:SteamID(),
                target:Name(),
                target:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Store mute data
            char:setData("muted", true)
            char:setData("mutedBy", admin:SteamID())
            char:setData("mutedAt", os.time())
            char:setData("muteDuration", 0) -- 0 = permanent
            char:save()

            -- Store mute history
            local muteHistory = char:getData("muteHistory", {})
            table.insert(muteHistory, {
                admin = admin:SteamID(),
                adminName = admin:Name(),
                time = os.time(),
                duration = 0
            })

            if #muteHistory > 20 then
                table.remove(muteHistory, 1)
            end

            char:setData("muteHistory", muteHistory)

            -- Notify player
            target:notify("You have been muted by " .. admin:Name())
        end
        ```
]]
function PlayerMuted(target, admin)
end

--[[
    Purpose:
        Called to determine if a player should act.

    When Called:
        When player actions need to be determined.

    Parameters:
        None

    Returns:
        boolean
            Whether the player should act.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow actions
        function MODULE:PlayerShouldAct()
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if player can act
        function MODULE:PlayerShouldAct()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            return char and not char:getData("frozen", false)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced action validation with multiple checks
        function MODULE:PlayerShouldAct()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if frozen
            if char:getData("frozen", false) then
                return false
            end

            -- Check if in sequence
            if char:getData("currentSequence") then
                return false
            end

            -- Check if unconscious
            if char:getData("unconscious", false) then
                return false
            end

            -- Check if dead
            if not client:Alive() then
                return false
            end

            return true
        end
        ```
]]
function PlayerShouldAct()
end

--[[
    Purpose:
        Called to determine if a player should be permanently killed.

    When Called:
        When permakill conditions are checked.

    Parameters:
        client (Player)
            The player being checked.
        inflictor (Entity)
            The damage inflictor.
        attacker (Player)
            The attacker.

    Returns:
        boolean
            Whether the player should be permakilled.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Never permakill
        function MODULE:PlayerShouldPermaKill(client, inflictor, attacker)
            return false
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check permakill conditions
        function MODULE:PlayerShouldPermaKill(client, inflictor, attacker)
            local char = client:getChar()
            if char then
                -- Permakill if death count is high
                local deathCount = char:getData("deathCount", 0)
                return deathCount >= 10
            end
            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced permakill system with multiple conditions
        function MODULE:PlayerShouldPermaKill(client, inflictor, attacker)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check death count
            local deathCount = char:getData("deathCount", 0)
            if deathCount >= 10 then
                return true
            end

            -- Check if killed by admin
            if IsValid(attacker) and attacker:IsAdmin() then
                local reason = attacker:GetNetVar("permakillReason")
                if reason then
                    lia.log.add(string.format("%s permakilled %s: %s",
                        attacker:Name(),
                        client:Name(),
                        reason),
                        FLAG_CRITICAL)
                    return true
                end
            end

            -- Check character age
            local created = char:getData("created", 0)
            if created > 0 then
                local age = os.time() - created
                -- Permakill if character is very old and has many deaths
                if age > 2592000 and deathCount >= 5 then -- 30 days
                    return true
                end
            end

            return false
        end
        ```
]]
function PlayerShouldPermaKill(client, inflictor, attacker)
end

--[[
    Purpose:
        Called when a player selects a spawn point.

    When Called:
        When players choose spawn locations.

    Parameters:
        client (Player)
            The player selecting spawn.
        pos (Vector)
            The spawn position.
        ang (Angle)
            The spawn angle.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log spawn selection
        function MODULE:PlayerSpawnPointSelected(client, pos, ang)
            print(client:Name() .. " selected spawn at " .. tostring(pos))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track spawn selections
        function MODULE:PlayerSpawnPointSelected(client, pos, ang)
            local char = client:getChar()
            if char then
                char:setData("lastSpawnPos", pos)
                lia.log.add(string.format("%s selected spawn at %s",
                    client:Name(),
                    tostring(pos)),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced spawn system with validation and tracking
        function MODULE:PlayerSpawnPointSelected(client, pos, ang)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Log spawn selection
            lia.log.add(string.format("%s (%s) selected spawn at %s",
                client:Name(),
                client:SteamID(),
                tostring(pos)),
                FLAG_NORMAL)

            -- Store spawn data
            char:setData("lastSpawnPos", pos)
            char:setData("lastSpawnAng", ang)
            char:setData("lastSpawnTime", os.time())

            -- Track spawn history
            local spawnHistory = char:getData("spawnHistory", {})
            table.insert(spawnHistory, {
                pos = pos,
                ang = ang,
                time = os.time(),
                map = game.GetMap()
            })

            if #spawnHistory > 20 then
                table.remove(spawnHistory, 1)
            end

            char:setData("spawnHistory", spawnHistory)

            -- Validate spawn location
            if not util.IsInWorld(pos) then
                client:notify("Invalid spawn location selected.")
                return
            end

            -- Apply spawn effects
            hook.Run("SpawnPointSelected", client, pos, ang)
        end
        ```
]]
function PlayerSpawnPointSelected(client, pos, ang)
end

--[[
    Purpose:
        Called when a player gains stamina.

    When Called:
        When stamina is restored to players.

    Parameters:
        player (Player)
            The player gaining stamina.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log stamina gain
        function MODULE:PlayerStaminaGained(player)
            print(player:Name() .. " gained stamina")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track stamina changes
        function MODULE:PlayerStaminaGained(player)
            local char = player:getChar()
            if char then
                char:setData("staminaGained", (char:getData("staminaGained", 0) + 1))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced stamina system with tracking and effects
        function MODULE:PlayerStaminaGained(player)
            if not IsValid(player) then return end

            local char = player:getChar()
            if not char then return end

            -- Track stamina gain
            local staminaStats = char:getData("staminaStats", {})
            staminaStats.totalGained = (staminaStats.totalGained or 0) + 1
            staminaStats.lastGain = os.time()
            char:setData("staminaStats", staminaStats)

            -- Apply stamina gain effects
            local currentStamina = char:getData("stamina", 100)
            local maxStamina = hook.Run("GetCharMaxStamina", char) or 100

            if currentStamina < maxStamina then
                -- Play stamina restore sound
                player:EmitSound("items/smallmedkit1.wav", 60, 100)
            end
        end
        ```
]]
function PlayerStaminaGained(player)
end

--[[
    Purpose:
        Called when a player loses stamina.

    When Called:
        When stamina is depleted from players.

    Parameters:
        player (Player)
            The player losing stamina.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log stamina loss
        function MODULE:PlayerStaminaLost(player)
            print(player:Name() .. " lost stamina")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track stamina loss
        function MODULE:PlayerStaminaLost(player)
            local char = player:getChar()
            if char then
                char:setData("staminaLost", (char:getData("staminaLost", 0) + 1))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced stamina system with effects and tracking
        function MODULE:PlayerStaminaLost(player)
            if not IsValid(player) then return end

            local char = player:getChar()
            if not char then return end

            -- Track stamina loss
            local staminaStats = char:getData("staminaStats", {})
            staminaStats.totalLost = (staminaStats.totalLost or 0) + 1
            staminaStats.lastLoss = os.time()
            char:setData("staminaStats", staminaStats)

            -- Check if stamina depleted
            local currentStamina = char:getData("stamina", 100)
            if currentStamina <= 0 then
                -- Apply exhaustion effects
                player:SetWalkSpeed(100)
                player:SetRunSpeed(150)

                -- Notify player
                player:notify("You are exhausted!")
            end
        end
        ```
]]
function PlayerStaminaLost(player)
end

--[[
    Purpose:
        Called when a player throws a punch.

    When Called:
        When players perform punch attacks.

    Parameters:
        client (Player)
            The punching player.
        trace (table)
            The punch trace result.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log punch
        function MODULE:PlayerThrowPunch(client, trace)
            print(client:Name() .. " threw a punch")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track punches
        function MODULE:PlayerThrowPunch(client, trace)
            local char = client:getChar()
            if char then
                local punchCount = char:getData("punchCount", 0)
                char:setData("punchCount", punchCount + 1)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced punch system with damage and effects
        function MODULE:PlayerThrowPunch(client, trace)
            if not IsValid(client) or not trace then return end

            local char = client:getChar()
            if not char then return end

            -- Track punch statistics
            local combatStats = char:getData("combatStats", {})
            combatStats.punchesThrown = (combatStats.punchesThrown or 0) + 1
            char:setData("combatStats", combatStats)

            -- Check if hit target
            if trace.Hit and IsValid(trace.Entity) then
                local target = trace.Entity
                if target:IsPlayer() then
                    local targetChar = target:getChar()
                    if targetChar then
                        -- Calculate damage
                        local damage = hook.Run("GetPlayerPunchDamage", client, 10, trace)
                        if damage > 0 then
                            -- Apply damage
                            target:TakeDamage(damage, client, client)

                            -- Play hit sound
                            target:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 60, 100)
                        end
                    end
                end
            end

            -- Play punch sound
            client:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav", 60, 100)
        end
        ```
]]
function PlayerThrowPunch(client, trace)
end

--[[
    Purpose:
        Called when a player is ungagged.

    When Called:
        When players are ungagged by admins.

    Parameters:
        target (Player)
            The player being ungagged.
        admin (Player)
            The admin removing the gag.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log ungag
        function MODULE:PlayerUngagged(target, admin)
            print(admin:Name() .. " ungagged " .. target:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove gag status
        function MODULE:PlayerUngagged(target, admin)
            local char = target:getChar()
            if char then
                char:setData("gagged", false)
                lia.log.add(string.format("%s ungagged %s",
                    admin:Name(),
                    target:Name()),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ungag system with tracking
        function MODULE:PlayerUngagged(target, admin)
            if not IsValid(target) or not IsValid(admin) then return end

            local char = target:getChar()
            if not char then return end

            -- Log ungag
            lia.log.add(string.format("%s (%s) ungagged %s (%s) at %s",
                admin:Name(),
                admin:SteamID(),
                target:Name(),
                target:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Remove gag data
            char:setData("gagged", false)
            local gagTime = char:getData("gaggedAt")
            char:setData("gaggedAt", nil)
            char:setData("gaggedBy", nil)
            char:save()

            -- Calculate gag duration
            if gagTime then
                local duration = os.time() - gagTime
                lia.log.add(string.format("%s was gagged for %d seconds",
                    target:Name(),
                    duration),
                    FLAG_NORMAL)
            end

            -- Notify player
            target:notify("You have been ungagged by " .. admin:Name())
        end
        ```
]]
function PlayerUngagged(target, admin)
end

--[[
    Purpose:
        Called when a player is unmuted.

    When Called:
        When players are unmuted by admins.

    Parameters:
        target (Player)
            The player being unmuted.
        admin (Player)
            The admin removing the mute.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log unmute
        function MODULE:PlayerUnmuted(target, admin)
            print(admin:Name() .. " unmuted " .. target:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove mute status
        function MODULE:PlayerUnmuted(target, admin)
            local char = target:getChar()
            if char then
                char:setData("muted", false)
                lia.log.add(string.format("%s unmuted %s",
                    admin:Name(),
                    target:Name()),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced unmute system with tracking
        function MODULE:PlayerUnmuted(target, admin)
            if not IsValid(target) or not IsValid(admin) then return end

            local char = target:getChar()
            if not char then return end

            -- Log unmute
            lia.log.add(string.format("%s (%s) unmuted %s (%s) at %s",
                admin:Name(),
                admin:SteamID(),
                target:Name(),
                target:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Remove mute data
            char:setData("muted", false)
            local muteTime = char:getData("mutedAt")
            char:setData("mutedAt", nil)
            char:setData("mutedBy", nil)
            char:save()

            -- Calculate mute duration
            if muteTime then
                local duration = os.time() - muteTime
                lia.log.add(string.format("%s was muted for %d seconds",
                    target:Name(),
                    duration),
                    FLAG_NORMAL)
            end

            -- Notify player
            target:notify("You have been unmuted by " .. admin:Name())
        end
        ```
]]
function PlayerUnmuted(target, admin)
end

--[[
    Purpose:
        Called when a player uses a door.

    When Called:
        When players interact with doors.

    Parameters:
        client (Player)
            The player using the door.
        door (Entity)
            The door entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log door usage
        function MODULE:PlayerUseDoor(client, door)
            print(client:Name() .. " used door")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track door usage
        function MODULE:PlayerUseDoor(client, door)
            local char = client:getChar()
            if char then
                lia.log.add(string.format("%s used door at %s",
                    client:Name(),
                    tostring(door:GetPos())),
                    FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door system with access control and tracking
        function MODULE:PlayerUseDoor(client, door)
            if not IsValid(client) or not IsValid(door) then return end

            local char = client:getChar()
            if not char then return end

            -- Check door access
            local doorData = door:GetNetVar("doorData")
            if doorData and doorData.locked then
                local owner = doorData.owner
                if owner and owner ~= client:SteamID() then
                    if not hook.Run("CanPlayerUnlock", client, door) then
                        client:notify("This door is locked.")
                        return false
                    end
                end
            end

            -- Log door usage
            lia.log.add(string.format("%s (%s) used door at %s",
                client:Name(),
                client:SteamID(),
                tostring(door:GetPos())),
                FLAG_NORMAL)

            -- Track door usage statistics
            local doorStats = char:getData("doorStats", {})
            doorStats.totalUsed = (doorStats.totalUsed or 0) + 1
            char:setData("doorStats", doorStats)
        end
        ```
]]
function PlayerUseDoor(client, door)
end

--[[
    Purpose:
        Called after door data is loaded.

    When Called:
        After door persistence data is loaded.

    Parameters:
        entity (Entity)
            The door entity.
        doorData (table)
            The loaded door data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Process door data
        function MODULE:PostDoorDataLoad(entity, doorData)
            if doorData then
                entity:SetNetVar("doorData", doorData)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restore door properties
        function MODULE:PostDoorDataLoad(entity, doorData)
            if IsValid(entity) and doorData then
                if doorData.locked then
                    entity:SetNetVar("locked", true)
                end
                if doorData.owner then
                    entity:SetNetVar("owner", doorData.owner)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door restoration with validation
        function MODULE:PostDoorDataLoad(entity, doorData)
            if not IsValid(entity) or not doorData then return end

            -- Restore door properties
            entity:SetNetVar("doorData", doorData)

            if doorData.locked then
                entity:SetNetVar("locked", true)
            end

            if doorData.owner then
                entity:SetNetVar("owner", doorData.owner)
            end

            if doorData.price then
                entity:SetNetVar("price", doorData.price)
            end

            -- Validate and restore custom data
            if doorData.customData then
                entity:SetNetVar("customData", doorData.customData)
            end

            -- Apply door-specific restoration
            hook.Run("DoorRestored", entity, doorData)
        end
        ```
]]
function PostDoorDataLoad(entity, doorData)
end

--[[
    Purpose:
        Called after server data is loaded.

    When Called:
        After server initialization data loading.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Initialize after data load
        function MODULE:PostLoadData()
            print("Data loaded, initializing module")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Process loaded data
        function MODULE:PostLoadData()
            MODULE.initialized = true
            lia.log.add("Server data loaded successfully", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced post-load processing with validation
        function MODULE:PostLoadData()
            MODULE.initialized = true
            MODULE.loadTime = os.time()

            -- Validate loaded data
            if MODULE.customData then
                for key, value in pairs(MODULE.customData) do
                    if not value or value == "" then
                        MODULE.customData[key] = nil
                    end
                end
            end

            -- Log successful load
            lia.log.add(string.format("Server data loaded at %s",
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)

            -- Notify modules
            hook.Run("DataLoaded", MODULE.customData)
        end
        ```
]]
function PostLoadData()
end

--[[
    Purpose:
        Called after a player initially spawns.

    When Called:
        After initial player spawn.

    Parameters:
        client (Player)
            The spawning player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Welcome message
        function MODULE:PostPlayerInitialSpawn(client)
            client:notify("Welcome to the server!")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize player data
        function MODULE:PostPlayerInitialSpawn(client)
            local char = client:getChar()
            if char then
                char:setData("firstSpawn", os.time())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced spawn initialization with setup
        function MODULE:PostPlayerInitialSpawn(client)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Set first spawn time
            if not char:getData("firstSpawn") then
                char:setData("firstSpawn", os.time())
            end

            -- Give welcome items
            local inv = char:getInv()
            if inv then
                inv:add("handbook")
                inv:add("radio")
            end

            -- Send welcome message
            timer.Simple(2, function()
                if IsValid(client) then
                    client:notify("Welcome to the server, " .. char:getName() .. "!")
                end
            end)

            -- Log spawn
            lia.log.add(string.format("%s (%s) spawned at %s",
                client:Name(),
                client:SteamID(),
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)
        end
        ```
]]
function PostPlayerInitialSpawn(client)
end

--[[
    Purpose:
        Called after a player loads a character.

    When Called:
        After character loading is complete.

    Parameters:
        client (Player)
            The player loading the character.
        character (Character)
            The loaded character.
        currentChar (boolean)
            Whether this is the current character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Notify character loaded
        function MODULE:PostPlayerLoadedChar(client, character, currentChar)
            if currentChar then
                client:notify("Character loaded!")
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize character data
        function MODULE:PostPlayerLoadedChar(client, character, currentChar)
            if currentChar then
                character:setData("lastLogin", os.time())
                character:save()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character loading with setup
        function MODULE:PostPlayerLoadedChar(client, character, currentChar)
            if not IsValid(client) or not character then return end

            if currentChar then
                -- Update last login
                character:setData("lastLogin", os.time())

                -- Calculate playtime
                local lastLogin = character:getData("lastLoginBefore", os.time())
                local sessionTime = os.time() - lastLogin
                local totalPlayTime = character:getData("playTime", 0) + sessionTime
                character:setData("playTime", totalPlayTime)

                -- Restore inventory
                local inv = character:getInv()
                if inv then
                    inv:sync()
                end

                -- Apply character-specific effects
                local faction = character:getFaction()
                if faction and faction.onLoad then
                    faction.onLoad(client, character)
                end

                -- Log character load
                lia.log.add(string.format("%s (%s) loaded character %s (ID: %d)",
                    client:Name(),
                    client:SteamID(),
                    character:getName(),
                    character:getID()),
                    FLAG_NORMAL)

                -- Notify modules
                hook.Run("CharacterFullyLoaded", client, character)
            end
        end
        ```
]]
function PostPlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Called after player loadout is set.

    When Called:
        After player equipment is assigned.

    Parameters:
        client (Player)
            The player whose loadout was set.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log loadout
        function MODULE:PostPlayerLoadout(client)
            print(client:Name() .. " loadout set")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track loadout
        function MODULE:PostPlayerLoadout(client)
            local char = client:getChar()
            if char then
                char:setData("loadoutSet", os.time())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced loadout system with validation
        function MODULE:PostPlayerLoadout(client)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Store loadout time
            char:setData("loadoutSet", os.time())

            -- Validate weapons
            for _, wep in ipairs(client:GetWeapons()) do
                if not hook.Run("CanPlayerChooseWeapon", wep) then
                    client:StripWeapon(wep:GetClass())
                end
            end

            -- Apply faction/class loadout
            local faction = char:getFaction()
            if faction and faction.loadout then
                for _, wep in ipairs(faction.loadout) do
                    client:Give(wep)
                end
            end

            local class = char:getClass()
            if class and class.loadout then
                for _, wep in ipairs(class.loadout) do
                    client:Give(wep)
                end
            end
        end
        ```
]]
function PostPlayerLoadout(client)
end

--[[
    Purpose:
        Called after player chat messages.

    When Called:
        After player messages are processed.

    Parameters:
        client (Player)
            The player who sent the message.
        message (string)
            The message content.
        chatType (string)
            The chat type.
        anonymous (boolean)
            Whether the message was anonymous.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log messages
        function MODULE:PostPlayerSay(client, message, chatType, anonymous)
            print(client:Name() .. " said: " .. message)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track message statistics
        function MODULE:PostPlayerSay(client, message, chatType, anonymous)
            local char = client:getChar()
            if char then
                local msgCount = char:getData("messageCount", 0)
                char:setData("messageCount", msgCount + 1)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced message tracking with analytics
        function MODULE:PostPlayerSay(client, message, chatType, anonymous)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Track message statistics
            local msgStats = char:getData("messageStats", {})
            msgStats.total = (msgStats.total or 0) + 1
            msgStats[chatType] = (msgStats[chatType] or 0) + 1
            msgStats.lastMessage = os.time()
            char:setData("messageStats", msgStats)

            -- Check for command keywords
            if string.find(string.lower(message), "help") then
                client:notify("Type /help for commands")
            end

            -- Apply message effects
            hook.Run("MessageProcessed", client, message, chatType, anonymous)
        end
        ```
]]
function PostPlayerSay(client, message, chatType, anonymous)
end

--[[
    Purpose:
        Called before character deletion.

    When Called:
        Before a character is deleted.

    Parameters:
        characterID (number)
            The ID of the character to delete.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log pre-deletion
        function MODULE:PreCharDelete(characterID)
            print("Preparing to delete character: " .. characterID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate deletion
        function MODULE:PreCharDelete(characterID)
            local character = lia.char.loaded[characterID]
            if character then
                -- Check if character can be deleted
                if character:getData("protected", false) then
                    return false -- Prevent deletion
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced pre-deletion validation and cleanup
        function MODULE:PreCharDelete(characterID)
            if not characterID then return end

            local character = lia.char.loaded[characterID]
            if not character then return end

            -- Check if protected
            if character:getData("protected", false) then
                lia.log.add(string.format("Attempted to delete protected character %d", characterID), FLAG_WARNING)
                return false
            end

            -- Backup character data
            local backupData = {
                name = character:getName(),
                steamID = character:getPlayer() and character:getPlayer():SteamID() or "Unknown",
                data = character:getData(),
                time = os.time()
            }

            -- Save backup
            file.Write("lilia_backups/char_" .. characterID .. "_" .. os.time() .. ".txt", util.TableToJSON(backupData))

            -- Log pre-deletion
            lia.log.add(string.format("Preparing to delete character %d (%s)",
                characterID,
                character:getName()),
                FLAG_NORMAL)

            -- Clean up inventory
            local inv = character:getInv()
            if inv then
                for _, item in pairs(inv:getItems()) do
                    item:remove()
                end
            end
        end
        ```
]]
function PreCharDelete(characterID)
end

--[[
    Purpose:
        Called before door data is saved.

    When Called:
        Before door persistence data is saved.

    Parameters:
        door (Entity)
            The door entity.
        doorData (table)
            The door data to save.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add timestamp
        function MODULE:PreDoorDataSave(door, doorData)
            doorData.savedAt = os.time()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate and prepare data
        function MODULE:PreDoorDataSave(door, doorData)
            if IsValid(door) then
                doorData.pos = door:GetPos()
                doorData.ang = door:GetAngles()
                doorData.savedAt = os.time()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door data preparation with validation
        function MODULE:PreDoorDataSave(door, doorData)
            if not IsValid(door) then return end

            -- Add metadata
            doorData.savedAt = os.time()
            doorData.map = game.GetMap()
            doorData.version = "1.0"

            -- Store position and angles
            doorData.pos = {door:GetPos().x, door:GetPos().y, door:GetPos().z}
            doorData.ang = {door:GetAngles().p, door:GetAngles().y, door:GetAngles().r}

            -- Store door properties
            local doorNetData = door:GetNetVar("doorData")
            if doorNetData then
                doorData.locked = doorNetData.locked
                doorData.owner = doorNetData.owner
                doorData.price = doorNetData.price
            end

            -- Validate data
            if not doorData.pos or not doorData.ang then
                lia.log.add("Invalid door data for save", FLAG_WARNING)
                return false
            end

            -- Clean up temporary data
            doorData.tempData = nil
        end
        ```
]]
function PreDoorDataSave(door, doorData)
end

--[[
    Purpose:
        Called before player item interaction.

    When Called:
        Before players interact with items.

    Parameters:
        client (Player)
            The interacting player.
        action (string)
            The interaction action.
        item (Item)
            The item being interacted with.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log interaction
        function MODULE:PrePlayerInteractItem(client, action, item)
            print(client:Name() .. " will interact with " .. item.name)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate interaction
        function MODULE:PrePlayerInteractItem(client, action, item)
            local char = client:getChar()
            if char then
                -- Check if item is usable
                if item:getData("broken", false) then
                    client:notify("This item is broken.")
                    return false
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced interaction validation with permissions
        function MODULE:PrePlayerInteractItem(client, action, item)
            if not IsValid(client) or not item then return end

            local char = client:getChar()
            if not char then return end

            -- Check if item is broken
            if item:getData("broken", false) then
                client:notify("This item is broken and cannot be used.")
                return false
            end

            -- Check cooldowns
            local lastUse = item:getData("lastUsed", 0)
            local cooldown = item:getData("cooldown", 0)
            if cooldown > 0 and (os.time() - lastUse) < cooldown then
                local remaining = cooldown - (os.time() - lastUse)
                client:notify("Item is on cooldown. " .. remaining .. " seconds remaining.")
                return false
            end

            -- Check permissions
            if item:getData("restricted", false) then
                local faction = char:getFaction()
                if not faction or not item:getData("allowedFactions")[faction.uniqueID] then
                    client:notify("You don't have permission to use this item.")
                    return false
                end
            end

            -- Log interaction attempt
            lia.log.add(string.format("%s (%s) attempting to interact with %s (action: %s)",
                client:Name(),
                client:SteamID(),
                item.name,
                action),
                FLAG_NORMAL)
        end
        ```
]]
function PrePlayerInteractItem(client, action, item)
end

--[[
    Purpose:
        Called before player character loading.

    When Called:
        Before character loading is complete.

    Parameters:
        client (Player)
            The player loading the character.
        character (Character)
            The character being loaded.
        currentChar (boolean)
            Whether this is the current character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log pre-load
        function MODULE:PrePlayerLoadedChar(client, character, currentChar)
            print("Loading character: " .. character:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Prepare character data
        function MODULE:PrePlayerLoadedChar(client, character, currentChar)
            if currentChar then
                character:setData("loading", true)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced pre-load processing with validation
        function MODULE:PrePlayerLoadedChar(client, character, currentChar)
            if not IsValid(client) or not character then return end

            if currentChar then
                -- Mark as loading
                character:setData("loading", true)
                character:setData("loadStartTime", os.time())

                -- Validate character data
                if not character:getName() or character:getName() == "" then
                    client:notify("Character has invalid name.")
                    return false
                end

                -- Check if character is banned
                if character:getData("banned", false) then
                    client:notify("This character is banned.")
                    return false
                end

                -- Check if character is permakilled
                if character:getData("permakilled", false) then
                    client:notify("This character is permanently dead.")
                    return false
                end

                -- Log character load start
                lia.log.add(string.format("%s (%s) loading character %s (ID: %d)",
                    client:Name(),
                    client:SteamID(),
                    character:getName(),
                    character:getID()),
                    FLAG_NORMAL)
            end
        end
        ```
]]
function PrePlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Called before salary is given.

    When Called:
        Before salary payments are processed.

    Parameters:
        client (Player)
            The player receiving salary.
        character (Character)
            The character.
        pay (number)
            The payment amount.
        faction (table)
            The faction.
        class (table)
            The class.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log pre-salary
        function MODULE:PreSalaryGive(client, character, pay, faction, class)
            print(client:Name() .. " will receive " .. pay)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Adjust salary
        function MODULE:PreSalaryGive(client, character, pay, faction, class)
            -- Double salary for VIPs
            if character:getData("vip", false) then
                return pay * 2
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced salary system with bonuses and deductions
        function MODULE:PreSalaryGive(client, character, pay, faction, class)
            if not IsValid(client) or not character then return end

            local finalPay = pay

            -- Apply bonuses
            if character:getData("vip", false) then
                finalPay = finalPay * 1.5
            end

            if character:getData("loyal", false) then
                finalPay = finalPay + 50
            end

            -- Apply deductions
            local warnings = character:getData("warnings", {})
            if #warnings > 0 then
                finalPay = finalPay * (1 - (#warnings * 0.1))
            end

            -- Check attendance
            local attendance = character:getData("attendance", 100)
            finalPay = finalPay * (attendance / 100)

            -- Log salary calculation
            lia.log.add(string.format("%s (%s) salary: base=%d, final=%d",
                client:Name(),
                client:SteamID(),
                pay,
                finalPay),
                FLAG_NORMAL)

            return math.max(0, finalPay)
        end
        ```
]]
function PreSalaryGive(client, character, pay, faction, class)
end

--[[
    Purpose:
        Called to register admin stick subcategories.

    When Called:
        When admin tool subcategories are registered.

    Parameters:
        categories (table)
            The subcategory definitions.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom category
        function MODULE:RegisterAdminStickSubcategories(categories)
            table.insert(categories, {name = "Custom", icon = "icon16/star.png"})
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register multiple categories
        function MODULE:RegisterAdminStickSubcategories(categories)
            table.insert(categories, {
                name = "Custom Tools",
                icon = "icon16/wrench.png",
                items = {
                    {name = "Custom Command", command = "customcmd"}
                }
            })
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced category system with permissions
        function MODULE:RegisterAdminStickSubcategories(categories)
            -- Add custom category with full structure
            table.insert(categories, {
                name = "Custom Tools",
                icon = "icon16/wrench.png",
                permission = "customtools",
                items = {
                    {
                        name = "Custom Command 1",
                        command = "customcmd1",
                        permission = "customcmd1",
                        icon = "icon16/star.png"
                    },
                    {
                        name = "Custom Command 2",
                        command = "customcmd2",
                        permission = "customcmd2",
                        icon = "icon16/star.png"
                    }
                }
            })

            -- Add another category
            table.insert(categories, {
                name = "Advanced Tools",
                icon = "icon16/cog.png",
                permission = "advancedtools",
                items = {
                    {
                        name = "Advanced Tool",
                        command = "advancedtool",
                        permission = "advancedtool",
                        icon = "icon16/cog.png"
                    }
                }
            })
        end
        ```
]]
function RegisterAdminStickSubcategories(categories)
end

--[[
    Purpose:
        Called to register prepared database statements.

    When Called:
        During database initialization.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register one statement
        function MODULE:RegisterPreparedStatements()
            lia.db.prepare("custom_query", "SELECT * FROM custom_table WHERE id = ?")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register multiple statements
        function MODULE:RegisterPreparedStatements()
            lia.db.prepare("get_custom_data", "SELECT * FROM custom_table WHERE id = ?")
            lia.db.prepare("set_custom_data", "UPDATE custom_table SET data = ? WHERE id = ?")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced statement registration with validation
        function MODULE:RegisterPreparedStatements()
            -- Register custom data queries
            lia.db.prepare("get_custom_data", "SELECT * FROM custom_table WHERE id = ?")
            lia.db.prepare("set_custom_data", "UPDATE custom_table SET data = ? WHERE id = ?")
            lia.db.prepare("insert_custom_data", "INSERT INTO custom_table (id, data) VALUES (?, ?)")
            lia.db.prepare("delete_custom_data", "DELETE FROM custom_table WHERE id = ?")

            -- Register statistics queries
            lia.db.prepare("get_player_stats", "SELECT * FROM player_stats WHERE steamid = ?")
            lia.db.prepare("update_player_stats", "UPDATE player_stats SET stats = ? WHERE steamid = ?")

            -- Register log queries
            lia.db.prepare("log_action", "INSERT INTO action_logs (steamid, action, time) VALUES (?, ?, ?)")

            -- Validate statements
            if not lia.db.prepared then
                lia.db.prepared = {}
            end
        end
        ```
]]
function RegisterPreparedStatements()
end

--[[
    Purpose:
        Called to remove warnings.

    When Called:
        When warnings are removed from characters.

    Parameters:
        charID (number)
            The character ID.
        index (number)
            The warning index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log warning removal
        function MODULE:RemoveWarning(charID, index)
            print("Warning " .. index .. " removed from character " .. charID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove and log warning
        function MODULE:RemoveWarning(charID, index)
            local character = lia.char.loaded[charID]
            if character then
                local warnings = character:getData("warnings", {})
                if warnings[index] then
                    table.remove(warnings, index)
                    character:setData("warnings", warnings)
                    lia.log.add(string.format("Warning %d removed from character %d", index, charID), FLAG_NORMAL)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced warning removal with validation and logging
        function MODULE:RemoveWarning(charID, index)
            if not charID or not index then return end

            local character = lia.char.loaded[charID]
            if not character then return end

            local warnings = character:getData("warnings", {})
            if not warnings[index] then
                lia.log.add(string.format("Attempted to remove non-existent warning %d from character %d",
                    index,
                    charID),
                    FLAG_WARNING)
                return false
            end

            -- Get warning data before removal
            local warningData = warnings[index]

            -- Remove warning
            table.remove(warnings, index)
            character:setData("warnings", warnings)
            character:save()

            -- Log removal
            lia.log.add(string.format("Warning removed from character %d (%s): %s",
                charID,
                character:getName(),
                warningData.reason or "No reason"),
                FLAG_NORMAL)

            -- Notify player if online
            local player = character:getPlayer()
            if IsValid(player) then
                player:notify("A warning has been removed from your character.")
            end
        end
        ```
]]
function RemoveWarning(charID, index)
end

--[[
    Purpose:
        Called to run admin system commands.

    When Called:
        When admin commands are executed.

    Parameters:
        command (string)
            The command to run.
        victim (Player)
            The target player.
        duration (number)
            The command duration.
        reason (string)
            The command reason.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log command execution
        function MODULE:RunAdminSystemCommand(command, victim, duration, reason)
            print("Admin command executed: " .. command)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track command usage
        function MODULE:RunAdminSystemCommand(command, victim, duration, reason)
            lia.log.add(string.format("Admin command: %s on %s",
                command,
                victim:Name()),
                FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced command system with validation and tracking
        function MODULE:RunAdminSystemCommand(command, victim, duration, reason)
            if not command or not IsValid(victim) then return end

            -- Log command execution
            lia.log.add(string.format("Admin command executed: %s on %s (%s) - Duration: %s, Reason: %s",
                command,
                victim:Name(),
                victim:SteamID(),
                duration or "N/A",
                reason or "No reason"),
                FLAG_CRITICAL)

            -- Track command statistics
            local cmdStats = MODULE.commandStats or {}
            cmdStats[command] = (cmdStats[command] or 0) + 1
            MODULE.commandStats = cmdStats

            -- Validate command
            local allowedCommands = {"kick", "ban", "mute", "gag", "freeze"}
            if not table.HasValue(allowedCommands, command) then
                lia.log.add(string.format("Invalid admin command attempted: %s", command), FLAG_WARNING)
                return false
            end

            -- Apply command-specific logic
            if command == "kick" then
                timer.Simple(duration or 0, function()
                    if IsValid(victim) then
                        victim:Kick(reason or "Kicked by admin")
                    end
                end)
            elseif command == "ban" then
                victim:Ban(duration or 0, reason or "Banned by admin")
            end

            -- Notify modules
            hook.Run("AdminCommandExecuted", command, victim, duration, reason)
        end
        ```
]]
function RunAdminSystemCommand(command, victim, duration, reason)
end

--[[
    Purpose:
        Called to save server data.

    When Called:
        During server data persistence.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Save basic data
        function MODULE:SaveData()
            MODULE.savedData = MODULE.customData
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Save with timestamp
        function MODULE:SaveData()
            MODULE.savedData = {
                data = MODULE.customData,
                savedAt = os.time()
            }
            lia.log.add("Server data saved", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced save system with validation and backup
        function MODULE:SaveData()
            -- Create backup
            if MODULE.customData then
                local backupPath = "lilia_backups/data_" .. os.time() .. ".txt"
                file.Write(backupPath, util.TableToJSON(MODULE.customData))
            end

            -- Validate data
            local dataToSave = {}
            if MODULE.customData then
                for key, value in pairs(MODULE.customData) do
                    if value and value ~= "" then
                        dataToSave[key] = value
                    end
                end
            end

            -- Save to database
            lia.db.query("UPDATE server_data SET data = ?, saved_at = ? WHERE id = 1", {
                util.TableToJSON(dataToSave),
                os.time()
            })

            -- Store in memory
            MODULE.savedData = {
                data = dataToSave,
                savedAt = os.time(),
                version = "1.0"
            }

            -- Log save
            lia.log.add(string.format("Server data saved at %s",
                os.date("%Y-%m-%d %H:%M:%S")),
                FLAG_NORMAL)
        end
        ```
]]
function SaveData()
end

--[[
    Purpose:
        Called to send popup messages.

    When Called:
        When popup notifications are sent to players.

    Parameters:
        client (Player)
            The target player.
        message (string)
            The popup message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Send popup
        function MODULE:SendPopup(client, message)
            client:notify(message)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send with customization
        function MODULE:SendPopup(client, message)
            client:notify(message, "info")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced popup system with types and tracking
        function MODULE:SendPopup(client, message)
            if not IsValid(client) or not message then return end

            -- Determine popup type
            local popupType = "info"
            if string.find(string.lower(message), "error") then
                popupType = "error"
            elseif string.find(string.lower(message), "warning") then
                popupType = "warning"
            elseif string.find(string.lower(message), "success") then
                popupType = "success"
            end

            -- Send popup
            client:notify(message, popupType)

            -- Track popup statistics
            local char = client:getChar()
            if char then
                local popupStats = char:getData("popupStats", {})
                popupStats.total = (popupStats.total or 0) + 1
                popupStats[popupType] = (popupStats[popupType] or 0) + 1
                char:setData("popupStats", popupStats)
            end

            -- Log important popups
            if popupType == "error" or popupType == "warning" then
                lia.log.add(string.format("Popup sent to %s (%s): %s [%s]",
                    client:Name(),
                    client:SteamID(),
                    message,
                    popupType),
                    FLAG_NORMAL)
            end
        end
        ```
]]
function SendPopup(client, message)
end

--[[
    Purpose:
        Called to setup bag inventory access rules.

    When Called:
        When bag inventory permissions are configured.

    Parameters:
        inventory (Inventory)
            The bag inventory.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Allow all access
        function MODULE:SetupBagInventoryAccessRules(inventory)
            -- Basic access rules
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check ownership
        function MODULE:SetupBagInventoryAccessRules(inventory)
            if inventory then
                local owner = inventory:getData("owner")
                if owner then
                    -- Set access rules for owner
                    inventory:addAccessRule(function(client)
                        return client:getChar():getID() == owner
                    end)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced access rules with factions and permissions
        function MODULE:SetupBagInventoryAccessRules(inventory)
            if not inventory then return end

            local owner = inventory:getData("owner")
            local accessLevel = inventory:getData("accessLevel", "owner")

            -- Owner access
            if owner then
                inventory:addAccessRule(function(client)
                    return client:getChar():getID() == owner
                end)
            end

            -- Faction access
            if accessLevel == "faction" then
                local factionID = inventory:getData("factionID")
                if factionID then
                    inventory:addAccessRule(function(client)
                        local char = client:getChar()
                        return char and char:getFaction().uniqueID == factionID
                    end)
                end
            end

            -- Class access
            if accessLevel == "class" then
                local classID = inventory:getData("classID")
                if classID then
                    inventory:addAccessRule(function(client)
                        local char = client:getChar()
                        return char and char:getClass().uniqueID == classID
                    end)
                end
            end

            -- Admin access
            if accessLevel == "admin" then
                inventory:addAccessRule(function(client)
                    return client:IsAdmin()
                end)
            end

            -- Public access
            if accessLevel == "public" then
                inventory:addAccessRule(function(client)
                    return true
                end)
            end

            -- Special access rules
            local specialRules = inventory:getData("specialRules", {})
            for _, rule in ipairs(specialRules) do
                inventory:addAccessRule(rule)
            end
        end
        ```
]]
function SetupBagInventoryAccessRules(inventory)
end

--[[
    Purpose:
        Called to setup bot players.

    When Called:
        When bot players are initialized.

    Parameters:
        client (Player)
            The bot player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic bot setup
        function MODULE:SetupBotPlayer(client)
            client:SetModel("models/player.mdl")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Give bot basic equipment
        function MODULE:SetupBotPlayer(client)
            client:SetModel("models/player.mdl")
            client:Give("weapon_crowbar")
            client:SetHealth(100)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced bot setup with character and faction
        function MODULE:SetupBotPlayer(client)
            if not IsValid(client) then return end

            -- Create a basic character for the bot
            local charData = {
                name = "Bot Player",
                model = "models/player.mdl",
                faction = "citizen", -- Default faction
                class = "citizen",
                money = 500,
                attributes = {
                    strength = 10,
                    agility = 10,
                    intelligence = 10
                }
            }

            -- Set bot properties
            client:SetModel(charData.model)
            client:SetHealth(100)
            client:SetArmor(0)

            -- Give basic equipment
            client:Give("weapon_crowbar")
            client:Give("weapon_pistol")

            -- Set ammo
            client:SetAmmo(50, "pistol")

            -- Store character data
            client:SetNetVar("charData", charData)

            -- Set bot flags
            client:SetNetVar("isBot", true)
            client:SetNetVar("botType", "generic")

            -- Initialize bot AI
            timer.Simple(1, function()
                if IsValid(client) then
                    hook.Run("InitializeBotAI", client)
                end
            end)

            -- Log bot creation
            lia.log.add("Bot player initialized: " .. client:Name(), FLAG_NORMAL)
        end
        ```
]]
function SetupBotPlayer(client)
end

--[[
    Purpose:
        Called to setup database.

    When Called:
        During database initialization.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic database setup
        function MODULE:SetupDatabase()
            print("Database setup started")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create basic tables
        function MODULE:SetupDatabase()
            lia.db.query("CREATE TABLE IF NOT EXISTS custom_data (id INTEGER PRIMARY KEY, data TEXT)")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced database setup with multiple tables and indexes
        function MODULE:SetupDatabase()
            -- Create custom tables
            local queries = {
                "CREATE TABLE IF NOT EXISTS custom_data (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE, value TEXT, created_at INTEGER)",
                "CREATE TABLE IF NOT EXISTS player_stats (steamid TEXT PRIMARY KEY, stats TEXT, last_updated INTEGER)",
                "CREATE TABLE IF NOT EXISTS server_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, message TEXT, timestamp INTEGER)",
                "CREATE TABLE IF NOT EXISTS item_templates (id INTEGER PRIMARY KEY AUTOINCREMENT, uniqueid TEXT UNIQUE, data TEXT)",
                "CREATE INDEX IF NOT EXISTS idx_custom_data_key ON custom_data(key)",
                "CREATE INDEX IF NOT EXISTS idx_player_stats_steamid ON player_stats(steamid)",
                "CREATE INDEX IF NOT EXISTS idx_server_logs_timestamp ON server_logs(timestamp)",
                "CREATE INDEX IF NOT EXISTS idx_item_templates_uniqueid ON item_templates(uniqueid)"
            }

            -- Execute all queries
            for _, query in ipairs(queries) do
                local success, errorMsg = lia.db.query(query)
                if not success then
                    lia.log.add("Database setup error: " .. errorMsg, FLAG_WARNING)
                end
            end

            -- Verify tables exist
            local tables = {"custom_data", "player_stats", "server_logs", "item_templates"}
            for _, tableName in ipairs(tables) do
                local result = lia.db.query("SELECT name FROM sqlite_master WHERE type='table' AND name=?", {tableName})
                if not result or #result == 0 then
                    lia.log.add("Failed to create table: " .. tableName, FLAG_ERROR)
                end
            end

            -- Set up database version
            lia.db.query("INSERT OR REPLACE INTO custom_data (key, value, created_at) VALUES (?, ?, ?)",
                {"db_version", "1.0", os.time()})

            lia.log.add("Database setup completed successfully", FLAG_NORMAL)
        end
        ```
]]
function SetupDatabase()
end

--[[
    Purpose:
        Called to setup PAC data from items.

    When Called:
        When PAC data is loaded from items.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic PAC setup
        function MODULE:SetupPACDataFromItems()
            print("Setting up PAC data from items")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load PAC data from equipped items
        function MODULE:SetupPACDataFromItems()
            for _, client in player.Iterator() do
                if IsValid(client) then
                    local char = client:getChar()
                    if char then
                        local inv = char:getInv()
                        if inv then
                            -- Process equipped items for PAC data
                        end
                    end
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced PAC data setup with validation and caching
        function MODULE:SetupPACDataFromItems()
            MODULE.pacDataCache = MODULE.pacDataCache or {}

            for _, client in player.Iterator() do
                if not IsValid(client) then continue end

                local char = client:getChar()
                if not char then continue end

                local inv = char:getInv()
                if not inv then continue end

                local steamID = client:SteamID()
                local pacData = {
                    parts = {},
                    outfits = {},
                    lastUpdated = os.time()
                }

                -- Process all equipped items for PAC data
                for _, item in pairs(inv:getItems()) do
                    if item.pacData and item:getData("equipped", false) then
                        -- Validate PAC data
                        if MODULE.ValidatePACData(item.pacData) then
                            -- Add to character's PAC data
                            for partName, partData in pairs(item.pacData.parts or {}) do
                                pacData.parts[partName] = partData
                            end

                            -- Add outfits
                            for outfitName, outfitData in pairs(item.pacData.outfits or {}) do
                                pacData.outfits[outfitName] = outfitData
                            end
                        else
                            lia.log.add(string.format("Invalid PAC data in item %s for player %s",
                                item.uniqueID, client:Name()), FLAG_WARNING)
                        end
                    end
                end

                -- Cache PAC data
                MODULE.pacDataCache[steamID] = pacData

                -- Apply PAC data to player
                client:SetNetVar("pacData", pacData)

                -- Log PAC setup
                if table.Count(pacData.parts) > 0 then
                    lia.log.add(string.format("Applied %d PAC parts to %s",
                        table.Count(pacData.parts), client:Name()), FLAG_NORMAL)
                end
            end

            -- Clean up old cache entries
            for steamID, data in pairs(MODULE.pacDataCache) do
                if data.lastUpdated < (os.time() - 3600) then -- 1 hour
                    MODULE.pacDataCache[steamID] = nil
                end
            end
        end
        ```
]]
function SetupPACDataFromItems()
end

--[[
    Purpose:
        Called to setup player models.

    When Called:
        When player character models are configured.

    Parameters:
        entity (Entity)
            The player entity.
        character (Character)
            The character.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set basic model
        function MODULE:SetupPlayerModel(entity, character)
            entity:SetModel("models/player.mdl")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set model based on character data
        function MODULE:SetupPlayerModel(entity, character)
            if character then
                local model = character:getData("model", "models/player.mdl")
                entity:SetModel(model)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model setup with validation and effects
        function MODULE:SetupPlayerModel(entity, character)
            if not IsValid(entity) or not character then return end

            -- Get model from character data
            local model = character:getData("model", "models/player.mdl")

            -- Validate model exists
            if not util.IsValidModel(model) then
                lia.log.add(string.format("Invalid model '%s' for character %s, using default",
                    model, character:getName()), FLAG_WARNING)
                model = "models/player.mdl"
            end

            -- Set the model
            entity:SetModel(model)

            -- Apply model-specific settings
            local modelData = MODULE.GetModelData(model)
            if modelData then
                -- Set bodygroups
                if modelData.bodygroups then
                    for groupID, value in pairs(modelData.bodygroups) do
                        entity:SetBodygroup(groupID, value)
                    end
                end

                -- Set skin
                if modelData.skin then
                    entity:SetSkin(modelData.skin)
                end

                -- Apply model scale if specified
                if modelData.scale then
                    entity:SetModelScale(modelData.scale, 0)
                end
            end

            -- Store model data
            character:setData("currentModel", model)
            character:setData("modelSetAt", os.time())

            -- Apply faction-specific model modifications
            local faction = character:getFaction()
            if faction and faction.onModelSet then
                faction.onModelSet(entity, character)
            end

            -- Apply class-specific modifications
            local class = character:getClass()
            if class and class.onModelSet then
                class.onModelSet(entity, character)
            end

            -- Log model change
            lia.log.add(string.format("Set model '%s' for character %s (%s)",
                model, character:getName(), entity:Name()), FLAG_NORMAL)

            -- Update player color/material if needed
            hook.Run("PlayerModelChanged", entity, model)
        end
        ```
]]
function SetupPlayerModel(entity, character)
end

--[[
    Purpose:
        Determines if saved items should be deleted.

    When Called:
        When deciding whether to clean up persisted items.

    Parameters:
        None

    Returns:
        boolean
            Whether saved items should be deleted.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always delete saved items
        function MODULE:ShouldDeleteSavedItems()
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Delete items based on server settings
        function MODULE:ShouldDeleteSavedItems()
            -- Check server configuration
            if lia.config.get("DeleteSavedItemsOnMapChange", true) then
                return true
            end
            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced cleanup with conditions and logging
        function MODULE:ShouldDeleteSavedItems()
            -- Check if map is changing
            local isMapChanging = game.IsDedicated() and GetGlobalBool("MapChanging", false)

            if isMapChanging then
                -- Always delete on map change
                lia.log.add("Deleting saved items due to map change", FLAG_NORMAL)
                return true
            end

            -- Check server configuration
            if lia.config.get("AutoCleanupSavedItems", false) then
                -- Check cleanup interval
                local lastCleanup = GetGlobalInt("LastSavedItemsCleanup", 0)
                local cleanupInterval = lia.config.get("SavedItemsCleanupInterval", 24) * 3600 -- hours to seconds

                if (os.time() - lastCleanup) > cleanupInterval then
                    -- Log cleanup
                    lia.log.add("Performing scheduled cleanup of saved items", FLAG_NORMAL)
                    SetGlobalInt("LastSavedItemsCleanup", os.time())
                    return true
                end
            end

            -- Check for manual cleanup command
            if GetGlobalBool("ForceSavedItemsCleanup", false) then
                lia.log.add("Performing forced cleanup of saved items", FLAG_WARNING)
                SetGlobalBool("ForceSavedItemsCleanup", false)
                return true
            end

            -- Check storage limits
            local itemCount = MODULE.GetSavedItemCount()
            local maxItems = lia.config.get("MaxSavedItems", 1000)

            if itemCount > maxItems then
                lia.log.add(string.format("Deleting saved items: %d items exceed limit of %d", itemCount, maxItems), FLAG_WARNING)
                return true
            end

            return false
        end
        ```
]]
function ShouldDeleteSavedItems()
end

--[[
    Purpose:
        Determines if client ragdoll should be spawned.

    When Called:
        When deciding whether to create client-side ragdolls.

    Parameters:
        client (Player)
            The player.

    Returns:
        boolean
            Whether ragdoll should be spawned.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always spawn ragdolls
        function MODULE:ShouldSpawnClientRagdoll(client)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Spawn ragdolls based on player state
        function MODULE:ShouldSpawnClientRagdoll(client)
            if not IsValid(client) then return false end

            -- Don't spawn ragdoll if player is alive
            if client:Alive() then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ragdoll spawning with permissions and conditions
        function MODULE:ShouldSpawnClientRagdoll(client)
            if not IsValid(client) then return false end

            -- Don't spawn ragdoll if player is alive
            if client:Alive() then
                return false
            end

            -- Check if ragdolls are disabled globally
            if lia.config.get("DisableRagdolls", false) then
                return false
            end

            -- Check player permissions
            if client:IsAdmin() and lia.config.get("DisableRagdollsForAdmins", false) then
                return false
            end

            -- Check character data
            local char = client:getChar()
            if char then
                -- Check faction restrictions
                local faction = char:getFaction()
                if faction and faction.disableRagdolls then
                    return false
                end

                -- Check class restrictions
                local class = char:getClass()
                if class and class.disableRagdolls then
                    return false
                end

                -- Check character flags
                if char:getData("disableRagdolls", false) then
                    return false
                end
            end

            -- Check damage type
            local lastDamage = client.LastDamageData
            if lastDamage then
                -- Don't spawn ragdoll for certain damage types
                if lastDamage.DamageType == DMG_DROWN then
                    return false
                end

                -- Check damage amount
                if lastDamage.Damage < lia.config.get("MinRagdollDamage", 10) then
                    return false
                end
            end

            -- Check server performance
            local playerCount = player.GetCount()
            if playerCount > lia.config.get("HighPlayerCount", 20) then
                -- Reduce ragdoll spawning on high player counts
                if math.random() > 0.5 then
                    return false
                end
            end

            -- Check for existing ragdolls
            local existingRagdolls = ents.FindByClass("prop_ragdoll")
            if #existingRagdolls > lia.config.get("MaxRagdolls", 10) then
                -- Clean up old ragdolls before spawning new ones
                table.sort(existingRagdolls, function(a, b)
                    return (a.spawnTime or 0) < (b.spawnTime or 0)
                end)

                for i = 1, math.min(3, #existingRagdolls - lia.config.get("MaxRagdolls", 10) + 1) do
                    if IsValid(existingRagdolls[i]) then
                        existingRagdolls[i]:Remove()
                    end
                end
            end

            return true
        end
        ```
]]
function ShouldSpawnClientRagdoll(client)
end

--[[
    Purpose:
        Determines if items can be transferred to storage.

    When Called:
        When checking storage transfer permissions.

    Parameters:
        client (Player)
            The player attempting transfer.
        storage (table)
            The storage data.
        item (Item)
            The item being transferred.

    Returns:
        boolean
            Whether the item can be transferred.

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Allow all transfers
        function MODULE:StorageCanTransferItem(client, storage, item)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check basic storage capacity
        function MODULE:StorageCanTransferItem(client, storage, item)
            if not storage or not item then return false end

            -- Check if storage has capacity
            local capacity = storage:getCapacity()
            local currentWeight = storage:getWeight()
            local itemWeight = item:getWeight()

            if (currentWeight + itemWeight) > capacity then
                return false -- Storage is full
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer validation with permissions and restrictions
        function MODULE:StorageCanTransferItem(client, storage, item)
            if not IsValid(client) or not storage or not item then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check storage ownership
            if storage:getOwner() and storage:getOwner() ~= char:getID() then
                -- Check if client has permission to access this storage
                if not storage:canAccess(client) then
                    return false
                end
            end

            -- Check item restrictions
            if item.isRestricted then
                if not client:IsAdmin() then
                    return false -- Only admins can transfer restricted items
                end
            end

            -- Check faction restrictions
            local itemFaction = item.faction
            if itemFaction then
                local charFaction = char:getFaction()
                if charFaction and charFaction.uniqueID ~= itemFaction then
                    -- Item is faction-specific
                    if not client:IsAdmin() then
                        return false
                    end
                end
            end

            -- Check class restrictions
            local itemClass = item.class
            if itemClass then
                local charClass = char:getClass()
                if charClass and charClass.uniqueID ~= itemClass then
                    -- Item is class-specific
                    if not client:IsAdmin() then
                        return false
                    end
                end
            end

            -- Check storage capacity
            local capacity = storage:getCapacity()
            local currentWeight = storage:getWeight()
            local itemWeight = item:getWeight()

            if (currentWeight + itemWeight) > capacity then
                return false -- Storage is full
            end

            -- Check item type restrictions
            if storage.restrictedTypes then
                if table.HasValue(storage.restrictedTypes, item.uniqueID) then
                    return false -- This item type is not allowed in this storage
                end
            end

            -- Check storage access level
            local accessLevel = storage:getAccessLevel()
            if accessLevel > char:getAccessLevel() then
                return false -- Insufficient access level
            end

            -- Check for transfer cooldowns
            local lastTransfer = char:getData("lastStorageTransfer", 0)
            local cooldown = lia.config.get("StorageTransferCooldown", 0.1) -- seconds

            if (CurTime() - lastTransfer) < cooldown then
                return false -- Transfer too soon after previous transfer
            end

            -- Check distance from storage
            local storageEnt = storage:getEntity()
            if IsValid(storageEnt) then
                local dist = client:GetPos():Distance(storageEnt:GetPos())
                local maxDist = lia.config.get("MaxStorageTransferDistance", 200)

                if dist > maxDist then
                    return false -- Too far from storage
                end
            end

            -- Log successful transfer check
            lia.log.add(string.format("%s checked transfer of %s to storage %s",
                client:Name(), item.name, storage:getID() or "unknown"), FLAG_NORMAL)

            return true
        end
        ```
]]
function StorageCanTransferItem(client, storage, item)
end

--[[
    Purpose:
        Called when storage entity is removed.

    When Called:
        When storage containers are removed.

    Parameters:
        storageEntity (Entity)
            The storage entity.
        inventory (Inventory)
            The storage inventory.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic cleanup
        function MODULE:StorageEntityRemoved(storageEntity, inventory)
            -- Clean up any references
            if inventory then
                inventory:destroy()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Log storage removal and handle item distribution
        function MODULE:StorageEntityRemoved(storageEntity, inventory)
            if not inventory then return end

            -- Log the storage removal
            lia.log.add("Storage entity removed, inventory ID: " .. inventory:getID(), FLAG_NORMAL)

            -- Handle items in the storage
            local items = inventory:getItems()
            if table.Count(items) > 0 then
                -- Drop items on the ground or move to another storage
                for _, item in pairs(items) do
                    -- Item handling logic here
                end
            end

            -- Clean up the inventory
            inventory:destroy()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced storage removal with notifications and data preservation
        function MODULE:StorageEntityRemoved(storageEntity, inventory)
            if not IsValid(storageEntity) or not inventory then return end

            -- Get storage data before removal
            local storageData = storageEntity:getStorageData()
            local owner = storageEntity:getOwner()
            local storageType = storageEntity:getStorageType()

            -- Log detailed information
            lia.log.add(string.format("Storage entity removed - Type: %s, Owner: %s, Location: %s",
                storageType or "unknown",
                owner and "Player ID " .. owner or "No owner",
                tostring(storageEntity:GetPos())), FLAG_WARNING)

            -- Handle inventory contents
            local items = inventory:getItems()
            local itemCount = table.Count(items)

            if itemCount > 0 then
                -- Notify owner if possible
                if owner then
                    local ownerPlayer = player.GetByID(owner)
                    if IsValid(ownerPlayer) then
                        ownerPlayer:notify(string.format("Your %s was destroyed! %d items were lost.",
                            storageType or "storage", itemCount))
                    end
                end

                -- Attempt to save items to persistent storage or drop them
                local savedItems = 0
                for _, item in pairs(items) do
                    if item.canPersist then
                        -- Save to persistent storage
                        MODULE.SaveItemToPersistentStorage(item)
                        savedItems = savedItems + 1
                    else
                        -- Drop item on ground
                        local pos = storageEntity:GetPos()
                        item:spawn(pos + Vector(math.random(-50, 50), math.random(-50, 50), 10))
                    end
                end

                lia.log.add(string.format("Storage removal: %d/%d items saved to persistent storage",
                    savedItems, itemCount), FLAG_NORMAL)
            end

            -- Handle storage-specific cleanup
            if storageType == "bank" then
                -- Special handling for bank storage
                MODULE.HandleBankStorageRemoval(owner, inventory)
            elseif storageType == "vendor" then
                -- Special handling for vendor storage
                MODULE.HandleVendorStorageRemoval(owner, inventory)
            end

            -- Update statistics
            MODULE.UpdateStorageRemovalStats(storageType, itemCount, owner)

            -- Clean up any timers or hooks related to this storage
            timer.Remove("storage_" .. inventory:getID())
            hook.Remove("PlayerDisconnected", "storage_cleanup_" .. inventory:getID())

            -- Remove any network variables
            storageEntity:SetNetVar("storageID", nil)
            storageEntity:SetNetVar("storageType", nil)

            -- Final cleanup
            inventory:destroy()

            -- Notify administrators of suspicious activity
            if itemCount > 50 then
                MODULE.NotifyAdminsOfLargeStorageRemoval(storageEntity, itemCount, owner)
            end
        end
        ```
]]
function StorageEntityRemoved(storageEntity, inventory)
end

--[[
    Purpose:
        Called when storage inventory is set.

    When Called:
        When storage inventories are assigned.

    Parameters:
        entity (Entity)
            The storage entity.
        inventory (Inventory)
            The inventory.
        isCar (boolean)
            Whether this is a car trunk.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic inventory setup
        function MODULE:StorageInventorySet(entity, inventory, isCar)
            -- Initialize storage properties
            entity:SetNetVar("hasInventory", true)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Setup inventory with basic configuration
        function MODULE:StorageInventorySet(entity, inventory, isCar)
            if not IsValid(entity) or not inventory then return end

            -- Set inventory properties
            inventory:setCapacity(isCar and 20 or 50) -- Cars have less capacity
            entity:SetNetVar("inventoryID", inventory:getID())
            entity:SetNetVar("isCarStorage", isCar)

            -- Log inventory assignment
            lia.log.add(string.format("Inventory %s assigned to %s storage (%s)",
                inventory:getID(), isCar and "car" or "entity", entity:GetClass()), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory setup with type-specific configurations
        function MODULE:StorageInventorySet(entity, inventory, isCar)
            if not IsValid(entity) or not inventory then return end

            local storageType = MODULE.DetermineStorageType(entity)
            local capacity, restrictions, features = MODULE.GetStorageConfig(storageType, isCar)

            -- Set capacity based on storage type
            inventory:setCapacity(capacity)

            -- Apply restrictions
            if restrictions then
                inventory:setRestrictions(restrictions)
            end

            -- Setup special features
            if features then
                for feature, enabled in pairs(features) do
                    if enabled then
                        MODULE.EnableStorageFeature(entity, inventory, feature)
                    end
                end
            end

            -- Handle car-specific setup
            if isCar then
                MODULE.SetupCarStorage(entity, inventory)
                entity:SetNetVar("carStorage", true)

                -- Add car-specific restrictions
                inventory:addRestriction("no_explosives", true)
                inventory:addRestriction("max_weight", 100)
            else
                entity:SetNetVar("carStorage", false)
            end

            -- Setup network variables
            entity:SetNetVar("inventoryID", inventory:getID())
            entity:SetNetVar("storageType", storageType)
            entity:SetNetVar("capacity", capacity)

            -- Initialize storage timers
            timer.Create("storage_maintenance_" .. inventory:getID(), 300, 0, function()
                if IsValid(entity) and inventory then
                    MODULE.MaintainStorage(entity, inventory)
                end
            end)

            -- Setup access control
            MODULE.SetupStorageAccess(entity, inventory, storageType)

            -- Handle special storage types
            if storageType == "bank" then
                MODULE.InitializeBankStorage(entity, inventory)
            elseif storageType == "vendor" then
                MODULE.InitializeVendorStorage(entity, inventory)
            elseif storageType == "faction" then
                MODULE.InitializeFactionStorage(entity, inventory)
            end

            -- Log detailed setup information
            lia.log.add(string.format("Advanced inventory setup - Type: %s, Capacity: %d, Car: %s, Entity: %s",
                storageType, capacity, tostring(isCar), entity:GetClass()), FLAG_NORMAL)

            -- Send setup confirmation to nearby players
            local nearbyPlayers = MODULE.GetNearbyPlayers(entity:GetPos(), 500)
            for _, ply in ipairs(nearbyPlayers) do
                if IsValid(ply) then
                    net.Start("StorageSetupComplete")
                        net.WriteEntity(entity)
                        net.WriteString(storageType)
                        net.WriteBool(isCar)
                    net.Send(ply)
                end
            end

            -- Update global storage tracking
            MODULE.RegisterStorage(entity, inventory, storageType)

            -- Setup backup system
            if MODULE.ShouldBackupStorage(storageType) then
                MODULE.SetupStorageBackup(entity, inventory)
            end
        end
        ```
]]
function StorageInventorySet(entity, inventory, isCar)
end

--[[
    Purpose:
        Called when items are removed from storage.

    When Called:
        When storage contents are cleared.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:StorageItemRemoved()
            -- Log that items were removed from storage
            lia.log.add("Storage items removed", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track removal statistics
        function MODULE:StorageItemRemoved()
            -- Update global statistics
            local currentCount = GetGlobalInt("StorageRemovals", 0)
            SetGlobalInt("StorageRemovals", currentCount + 1)

            -- Log with timestamp
            lia.log.add("Storage items removed at " .. os.date("%H:%M:%S"), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive item removal tracking and cleanup
        function MODULE:StorageItemRemoved()
            -- Get current time for logging
            local currentTime = os.time()
            local timeString = os.date("%Y-%m-%d %H:%M:%S", currentTime)

            -- Update removal statistics
            local dailyRemovals = GetGlobalInt("DailyStorageRemovals", 0)
            local totalRemovals = GetGlobalInt("TotalStorageRemovals", 0)

            SetGlobalInt("DailyStorageRemovals", dailyRemovals + 1)
            SetGlobalInt("TotalStorageRemovals", totalRemovals + 1)
            SetGlobalInt("LastStorageRemoval", currentTime)

            -- Check for unusual activity
            local recentRemovals = MODULE.GetRecentStorageRemovals(300) -- Last 5 minutes
            if #recentRemovals > 10 then
                MODULE.FlagSuspiciousActivity("mass_storage_removal", recentRemovals)
            end

            -- Clean up temporary data
            MODULE.CleanupTemporaryStorageData()

            -- Update storage health metrics
            MODULE.UpdateStorageHealth()

            -- Log detailed information
            lia.log.add(string.format("Storage item removal - Time: %s, Daily: %d, Total: %d",
                timeString, dailyRemovals + 1, totalRemovals + 1), FLAG_NORMAL)

            -- Reset daily counter at midnight
            local lastReset = GetGlobalInt("LastDailyReset", 0)
            local currentDay = os.date("%Y%m%d", currentTime)

            if os.date("%Y%m%d", lastReset) ~= currentDay then
                SetGlobalInt("DailyStorageRemovals", 1)
                SetGlobalInt("LastDailyReset", currentTime)
                lia.log.add("Daily storage removal counter reset", FLAG_NORMAL)
            end

            -- Trigger maintenance tasks if needed
            if (totalRemovals + 1) % 100 == 0 then -- Every 100 removals
                MODULE.RunStorageMaintenance()
                lia.log.add("Storage maintenance triggered after 100 removals", FLAG_WARNING)
            end

            -- Update client-side displays
            MODULE.BroadcastStorageUpdate()

            -- Check for and clean up orphaned references
            MODULE.CleanupOrphanedStorageReferences()

            -- Update economy metrics
            MODULE.UpdateEconomyMetrics("storage_removal")

            -- Send notification to administrators if configured
            if lia.config.get("NotifyAdminsOnStorageRemoval", false) then
                MODULE.NotifyAdminsOfStorageActivity("removal", {
                    time = timeString,
                    dailyCount = dailyRemovals + 1,
                    totalCount = totalRemovals + 1
                })
            end

            -- Archive removal data for analytics
            MODULE.ArchiveStorageActivity("removal", {
                timestamp = currentTime,
                serverUptime = CurTime(),
                playerCount = player.GetCount()
            })
        end
        ```
]]
function StorageItemRemoved()
end

--[[
    Purpose:
        Called when storage is opened.

    When Called:
        When storage containers are accessed.

    Parameters:
        storage (table)
            The storage data.
        isCar (boolean)
            Whether this is a car trunk.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:StorageOpen(storage, isCar)
            -- Log storage access
            lia.log.add("Storage opened", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Log access with details
        function MODULE:StorageOpen(storage, isCar)
            if not storage then return end

            local storageType = isCar and "car trunk" or "storage container"
            lia.log.add(string.format("%s opened", storageType), FLAG_NORMAL)

            -- Update access statistics
            MODULE.IncrementStorageAccessCount()
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive storage access tracking and security
        function MODULE:StorageOpen(storage, isCar)
            if not storage then return end

            -- Get player and character information
            local client = storage:getClient()
            local char = client and client:getChar()
            local storageType = isCar and "car trunk" or "storage container"

            -- Log detailed access information
            lia.log.add(string.format("Storage opened - Type: %s, Player: %s, Character: %s, Location: %s",
                storageType,
                client and client:Name() or "Unknown",
                char and char:getName() or "Unknown",
                storage:getEntity() and tostring(storage:getEntity():GetPos()) or "Unknown"
            ), FLAG_NORMAL)

            -- Update access statistics
            local accessCount = GetGlobalInt("TotalStorageAccesses", 0)
            SetGlobalInt("TotalStorageAccesses", accessCount + 1)

            -- Track player-specific access
            if client then
                MODULE.TrackPlayerStorageAccess(client, storageType)
            end

            -- Security checks
            if MODULE.CheckStorageSecurity(storage) then
                MODULE.LogSecurityEvent("storage_access", {
                    player = client,
                    storage = storage,
                    type = storageType,
                    timestamp = os.time()
                })
            end

            -- Update storage activity
            storage:setData("lastAccessed", os.time())
            storage:setData("lastAccessedBy", client and client:Name() or "Unknown")

            -- Handle car-specific logic
            if isCar then
                MODULE.HandleCarStorageAccess(client, storage)
            else
                MODULE.HandleContainerStorageAccess(client, storage)
            end

            -- Check for suspicious activity
            if MODULE.DetectSuspiciousStorageAccess(client, storage) then
                MODULE.FlagSuspiciousActivity(client, "unusual_storage_access")
            end

            -- Update client-side UI
            if client then
                MODULE.SendStorageUINotification(client, storage, "opened")
            end

            -- Trigger storage maintenance if needed
            if math.random() < 0.1 then -- 10% chance
                MODULE.PerformStorageMaintenance(storage)
            end

            -- Handle special storage types
            local specialType = storage:getData("specialType")
            if specialType then
                MODULE.HandleSpecialStorageAccess(client, storage, specialType)
            end

            -- Update economy metrics
            MODULE.UpdateStorageEconomyMetrics(storage, "access")

            -- Send notification to storage owner if different player
            local owner = storage:getOwner()
            if owner and owner ~= (char and char:getID()) and client then
                local ownerPlayer = player.GetByID(owner)
                if IsValid(ownerPlayer) and ownerPlayer ~= client then
                    ownerPlayer:notify(string.format("Your %s was accessed by %s",
                        storageType, client:Name()))
                end
            end

            -- Archive access data for analytics
            MODULE.ArchiveStorageAccessData({
                player = client,
                storage = storage,
                type = storageType,
                timestamp = os.time(),
                location = storage:getEntity() and storage:getEntity():GetPos()
            })

            -- Check for and apply storage fees
            if MODULE.ShouldChargeStorageFee(storage) then
                MODULE.ApplyStorageFee(client, storage)
            end
        end
        ```
]]
function StorageOpen(storage, isCar)
end

--[[
    Purpose:
        Called when storage is restored.

    When Called:
        When storage data is restored from save.

    Parameters:
        entity (Entity)
            The storage entity.
        inventory (Inventory)
            The restored inventory.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic restoration logging
        function MODULE:StorageRestored(entity, inventory)
            -- Log that storage was restored
            lia.log.add("Storage restored from save", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate restored storage
        function MODULE:StorageRestored(entity, inventory)
            if not IsValid(entity) or not inventory then return end

            -- Validate inventory integrity
            local itemCount = table.Count(inventory:getItems())
            lia.log.add(string.format("Storage restored with %d items", itemCount), FLAG_NORMAL)

            -- Mark as restored
            entity:SetNetVar("restored", true)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive storage restoration with validation and recovery
        function MODULE:StorageRestored(entity, inventory)
            if not IsValid(entity) or not inventory then
                lia.log.add("Failed to restore storage - invalid entity or inventory", FLAG_WARNING)
                return
            end

            -- Get restoration metadata
            local restoreTime = os.time()
            local storageType = entity:GetClass()
            local itemCount = table.Count(inventory:getItems())

            -- Log detailed restoration information
            lia.log.add(string.format("Storage restoration - Entity: %s, Type: %s, Items: %d, Time: %s",
                tostring(entity), storageType, itemCount, os.date("%Y-%m-%d %H:%M:%S", restoreTime)), FLAG_NORMAL)

            -- Validate inventory data integrity
            local validItems = 0
            local invalidItems = 0
            local items = inventory:getItems()

            for id, item in pairs(items) do
                if MODULE.ValidateItemData(item) then
                    validItems = validItems + 1
                else
                    invalidItems = invalidItems + 1
                    lia.log.add(string.format("Invalid item found during restoration: %s", id), FLAG_WARNING)
                    -- Remove invalid item
                    inventory:removeItem(id)
                end
            end

            -- Update restoration statistics
            local totalRestorations = GetGlobalInt("TotalStorageRestorations", 0)
            SetGlobalInt("TotalStorageRestorations", totalRestorations + 1)

            -- Set network variables for client sync
            entity:SetNetVar("restored", true)
            entity:SetNetVar("restoreTime", restoreTime)
            entity:SetNetVar("itemCount", validItems)

            -- Handle special storage types
            if storageType == "lia_bank" then
                MODULE.RestoreBankStorage(entity, inventory)
            elseif storageType == "lia_vendor" then
                MODULE.RestoreVendorStorage(entity, inventory)
            elseif entity:GetNetVar("isCarStorage", false) then
                MODULE.RestoreCarStorage(entity, inventory)
            end

            -- Check for data consistency
            MODULE.ValidateStorageConsistency(entity, inventory)

            -- Restore storage permissions
            MODULE.RestoreStoragePermissions(entity, inventory)

            -- Update storage tracking system
            MODULE.RegisterRestoredStorage(entity, inventory, {
                restoreTime = restoreTime,
                itemCount = validItems,
                storageType = storageType
            })

            -- Send restoration notification to nearby players
            local nearbyPlayers = MODULE.GetNearbyPlayers(entity:GetPos(), 300)
            for _, ply in ipairs(nearbyPlayers) do
                if IsValid(ply) then
                    MODULE.SendStorageRestorationNotification(ply, entity, validItems)
                end
            end

            -- Trigger post-restoration hooks
            hook.Run("PostStorageRestored", entity, inventory, validItems, invalidItems)

            -- Log restoration summary
            if invalidItems > 0 then
                lia.log.add(string.format("Storage restoration completed - Valid: %d, Invalid: %d, Removed: %d",
                    validItems, invalidItems, invalidItems), FLAG_WARNING)
            else
                lia.log.add(string.format("Storage restoration completed successfully - %d items restored",
                    validItems), FLAG_NORMAL)
            end

            -- Update server-wide restoration metrics
            MODULE.UpdateRestorationMetrics(storageType, validItems, invalidItems)

            -- Check for restoration limits
            if totalRestorations + 1 > MODULE.GetMaxRestorationsPerHour() then
                MODULE.FlagHighRestorationActivity()
            end

            -- Initialize restoration monitoring
            MODULE.StartStorageMonitoring(entity, inventory)
        end
        ```
]]
function StorageRestored(entity, inventory)
end

--[[
    Purpose:
        Called to store spawn points.

    When Called:
        When saving spawn point data.

    Parameters:
        spawns (table)
            The spawn points.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic spawn saving
        function MODULE:StoreSpawns(spawns)
            -- Save spawn points to file
            file.Write("spawns.txt", util.TableToJSON(spawns))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Save spawns with validation
        function MODULE:StoreSpawns(spawns)
            if not spawns or table.Count(spawns) == 0 then
                lia.log.add("No spawn points to save", FLAG_WARNING)
                return
            end

            -- Validate spawn points
            local validSpawns = {}
            for k, spawn in pairs(spawns) do
                if isvector(spawn) then
                    table.insert(validSpawns, spawn)
                end
            end

            -- Save validated spawns
            file.Write("spawns.json", util.TableToJSON(validSpawns))
            lia.log.add(string.format("Saved %d spawn points", #validSpawns), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced spawn point storage with categorization and metadata
        function MODULE:StoreSpawns(spawns)
            if not spawns or table.Count(spawns) == 0 then
                lia.log.add("No spawn points provided for storage", FLAG_WARNING)
                return
            end

            local currentTime = os.time()
            local serverID = GetHostName() or "Unknown Server"
            local mapName = game.GetMap()

            -- Categorize spawn points
            local categorizedSpawns = {
                default = {},
                faction = {},
                class = {},
                admin = {},
                special = {}
            }

            local totalSpawns = 0
            local validSpawns = 0
            local invalidSpawns = 0

            -- Process and categorize each spawn point
            for category, spawnList in pairs(spawns) do
                if istable(spawnList) then
                    for i, spawnData in ipairs(spawnList) do
                        totalSpawns = totalSpawns + 1

                        if MODULE.ValidateSpawnPoint(spawnData) then
                            validSpawns = validSpawns + 1

                            -- Determine spawn category
                            local spawnCategory = MODULE.GetSpawnCategory(spawnData)
                            if not categorizedSpawns[spawnCategory] then
                                categorizedSpawns[spawnCategory] = {}
                            end

                            -- Add metadata to spawn point
                            local enrichedSpawn = {
                                position = spawnData.position or spawnData,
                                angle = spawnData.angle or Angle(0, 0, 0),
                                category = spawnCategory,
                                faction = spawnData.faction,
                                class = spawnData.class,
                                level = spawnData.level,
                                flags = spawnData.flags or {},
                                created = currentTime,
                                lastUsed = spawnData.lastUsed,
                                usageCount = spawnData.usageCount or 0
                            }

                            table.insert(categorizedSpawns[spawnCategory], enrichedSpawn)
                        else
                            invalidSpawns = invalidSpawns + 1
                            lia.log.add(string.format("Invalid spawn point in category %s: %s", category, tostring(spawnData)), FLAG_WARNING)
                        end
                    end
                end
            end

            -- Create storage data structure
            local storageData = {
                metadata = {
                    serverID = serverID,
                    mapName = mapName,
                    savedAt = currentTime,
                    totalSpawns = totalSpawns,
                    validSpawns = validSpawns,
                    invalidSpawns = invalidSpawns,
                    version = "2.0"
                },
                spawns = categorizedSpawns
            }

            -- Backup existing spawn data
            if file.Exists("spawns_backup.json", "DATA") then
                file.Rename("spawns_backup.json", "spawns_old.json")
            end

            if file.Exists("spawns.json", "DATA") then
                file.Rename("spawns.json", "spawns_backup.json")
            end

            -- Save new spawn data
            local jsonData = util.TableToJSON(storageData, true)
            if jsonData then
                file.Write("spawns.json", jsonData)
                lia.log.add(string.format("Spawn points saved - Valid: %d, Invalid: %d, Categories: %d",
                    validSpawns, invalidSpawns, table.Count(categorizedSpawns)), FLAG_NORMAL)

                -- Update global spawn statistics
                SetGlobalInt("TotalSpawnPoints", validSpawns)
                SetGlobalString("LastSpawnSave", os.date("%Y-%m-%d %H:%M:%S", currentTime))

                -- Notify administrators
                MODULE.NotifyAdminsOfSpawnSave(validSpawns, invalidSpawns)

                -- Trigger spawn validation
                MODULE.ValidateAllSpawnPoints(categorizedSpawns)

                -- Update spawn distribution analytics
                MODULE.AnalyzeSpawnDistribution(categorizedSpawns)

            else
                lia.log.add("Failed to serialize spawn data", FLAG_ERROR)
            end

            -- Clean up old backups (keep only last 5)
            MODULE.CleanupOldSpawnBackups()

            -- Log detailed save information
            lia.log.add(string.format("Spawn storage completed - Server: %s, Map: %s, Time: %s",
                serverID, mapName, os.date("%c", currentTime)), FLAG_NORMAL)
        end
        ```
]]
function StoreSpawns(spawns)
end

--[[
    Purpose:
        Called to synchronize character list.

    When Called:
        When sending character list to clients.

    Parameters:
        client (Player)
            The client to sync with.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic character list sync
        function MODULE:SyncCharList(client)
            -- Send basic character list to client
            local chars = lia.char.get(client)
            net.Start("CharList")
                net.WriteTable(chars)
            net.Send(client)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Sync with character filtering
        function MODULE:SyncCharList(client)
            if not IsValid(client) then return end

            local chars = lia.char.get(client)
            local filteredChars = {}

            -- Filter characters based on permissions
            for id, char in pairs(chars) do
                if MODULE.CanPlayerAccessCharacter(client, char) then
                    table.insert(filteredChars, char)
                end
            end

            -- Send filtered list
            net.Start("CharList")
                net.WriteTable(filteredChars)
            net.Send(client)

            lia.log.add(string.format("Synced %d characters for %s", #filteredChars, client:Name()), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character synchronization with caching and analytics
        function MODULE:SyncCharList(client)
            if not IsValid(client) then return end

            local startTime = SysTime()
            local steamID = client:SteamID()
            local chars = lia.char.get(client)

            -- Initialize sync tracking
            MODULE.InitializeSyncTracking(client)

            -- Filter and enrich character data
            local enrichedChars = {}
            local totalChars = 0
            local activeChars = 0
            local bannedChars = 0

            for charID, char in pairs(chars) do
                totalChars = totalChars + 1

                -- Check character access permissions
                if MODULE.CanPlayerAccessCharacter(client, char) then
                    -- Enrich character data with additional information
                    local enrichedChar = table.Copy(char)
                    enrichedChar.canSelect = MODULE.CanSelectCharacter(client, char)
                    enrichedChar.lastPlayed = MODULE.GetCharacterLastPlayed(char)
                    enrichedChar.playTime = MODULE.GetCharacterPlayTime(char)
                    enrichedChar.achievements = MODULE.GetCharacterAchievements(char)
                    enrichedChar.status = MODULE.GetCharacterStatus(char)

                    -- Check if character is active
                    if char.active then
                        activeChars = activeChars + 1
                    end

                    -- Check if character is banned
                    if MODULE.IsCharacterBanned(char) then
                        bannedChars = bannedChars + 1
                        enrichedChar.banned = true
                        enrichedChar.banReason = MODULE.GetCharacterBanReason(char)
                    end

                    -- Add faction and class information
                    enrichedChar.factionData = MODULE.GetFactionDisplayData(char.faction)
                    enrichedChar.classData = MODULE.GetClassDisplayData(char.class)

                    -- Add character statistics
                    enrichedChar.stats = MODULE.GetCharacterStats(char)

                    table.insert(enrichedChars, enrichedChar)
                end
            end

            -- Sort characters by priority (active first, then by last played)
            table.sort(enrichedChars, function(a, b)
                if a.active ~= b.active then
                    return a.active
                end
                return (a.lastPlayed or 0) > (b.lastPlayed or 0)
            end)

            -- Prepare sync data package
            local syncData = {
                characters = enrichedChars,
                metadata = {
                    totalCharacters = totalChars,
                    activeCharacters = activeChars,
                    bannedCharacters = bannedChars,
                    availableSlots = MODULE.GetAvailableCharacterSlots(client),
                    maxSlots = MODULE.GetMaxCharacterSlots(client),
                    lastSync = os.time(),
                    serverTime = os.time()
                },
                settings = {
                    allowCharacterCreation = MODULE.CanCreateCharacter(client),
                    allowCharacterDeletion = MODULE.CanDeleteCharacter(client),
                    autoSelectLastCharacter = MODULE.GetAutoSelectPreference(client)
                }
            }

            -- Compress data if it's large
            local jsonData = util.TableToJSON(syncData)
            if #jsonData > 60000 then -- Compress if over ~60KB
                local compressed = util.Compress(jsonData)
                if compressed then
                    net.Start("CharListCompressed")
                        net.WriteData(compressed, #compressed)
                        net.WriteInt(#jsonData, 32) -- Original size for decompression
                    net.Send(client)
                else
                    -- Fallback to uncompressed if compression fails
                    net.Start("CharList")
                        net.WriteString(jsonData)
                    net.Send(client)
                end
            else
                -- Send uncompressed data
                net.Start("CharList")
                    net.WriteString(jsonData)
                net.Send(client)
            end

            -- Update sync statistics
            local syncTime = SysTime() - startTime
            MODULE.UpdateSyncStats(client, {
                charactersSynced = #enrichedChars,
                syncTime = syncTime,
                dataSize = #jsonData,
                compressed = (#jsonData > 60000)
            })

            -- Log sync completion
            lia.log.add(string.format("Character list sync completed for %s - Characters: %d, Time: %.3fs, Size: %d bytes",
                client:Name(), #enrichedChars, syncTime, #jsonData), FLAG_NORMAL)

            -- Trigger post-sync hooks
            hook.Run("PostCharacterListSync", client, enrichedChars, syncData)

            -- Send sync confirmation
            timer.Simple(0.1, function()
                if IsValid(client) then
                    net.Start("CharListSyncConfirm")
                        net.WriteInt(#enrichedChars, 16)
                        net.WriteFloat(syncTime)
                    net.Send(client)
                end
            end)

            -- Cache sync data for potential reuse
            MODULE.CacheCharacterSyncData(client, syncData)

            -- Update player sync history
            MODULE.UpdatePlayerSyncHistory(client, {
                timestamp = os.time(),
                characters = #enrichedChars,
                syncTime = syncTime
            })
        end
        ```
]]
function SyncCharList(client)
end

--[[
    Purpose:
        Called when ticket system claims tickets.

    When Called:
        When support tickets are claimed.

    Parameters:
        client (Player)
            The claiming staff member.
        requester (Player)
            The ticket requester.
        ticketMessage (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ticket claim logging
        function MODULE:TicketSystemClaim(client, requester, ticketMessage)
            -- Log the ticket claim
            lia.log.add(string.format("%s claimed ticket from %s", client:Name(), requester:Name()), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update ticket status and notify players
        function MODULE:TicketSystemClaim(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            -- Update ticket status
            MODULE.SetTicketStatus(requester, "claimed", client)

            -- Notify both players
            client:notify("You have claimed the ticket from " .. requester:Name())
            requester:notify("Your ticket has been claimed by " .. client:Name())

            -- Log the claim
            lia.log.add(string.format("Ticket claimed - Staff: %s, Player: %s, Message: %s",
                client:Name(), requester:Name(), ticketMessage), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive ticket claim system with tracking and notifications
        function MODULE:TicketSystemClaim(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            local currentTime = os.time()
            local claimID = "claim_" .. currentTime .. "_" .. client:UserID() .. "_" .. requester:UserID()

            -- Validate claim permissions
            if not MODULE.CanClaimTickets(client) then
                client:notify("You don't have permission to claim tickets!")
                return
            end

            -- Check if ticket is already claimed
            if MODULE.IsTicketClaimed(requester) then
                client:notify("This ticket has already been claimed!")
                return
            end

            -- Check claim limits
            local activeClaims = MODULE.GetActiveClaims(client)
            if activeClaims >= MODULE.GetMaxClaimsPerStaff(client) then
                client:notify("You have reached your maximum active ticket claims!")
                return
            end

            -- Create claim record
            local claimData = {
                id = claimID,
                staffMember = client,
                staffSteamID = client:SteamID(),
                requester = requester,
                requesterSteamID = requester:SteamID(),
                ticketMessage = ticketMessage,
                claimedAt = currentTime,
                status = "active",
                priority = MODULE.CalculateTicketPriority(ticketMessage),
                category = MODULE.CategorizeTicket(ticketMessage)
            }

            -- Store claim data
            MODULE.StoreTicketClaim(claimData)

            -- Update ticket status
            MODULE.SetTicketStatus(requester, "claimed", client, claimID)

            -- Set claim timeout
            timer.Create("ticket_claim_timeout_" .. claimID, MODULE.GetClaimTimeout(), 1, function()
                if MODULE.IsTicketClaimed(requester) and MODULE.GetTicketClaimant(requester) == client then
                    MODULE.AutoUnclaimTicket(requester, "timeout")
                end
            end)

            -- Notify staff member
            client:notify(string.format("Ticket claimed successfully!\nRequester: %s\nMessage: %s",
                requester:Name(), ticketMessage))

            -- Notify requester
            requester:notify(string.format("Your support ticket has been claimed by %s (%s).\nThey will assist you shortly.",
                client:Name(), client:GetUserGroup()))

            -- Log detailed claim information
            lia.log.add(string.format("Ticket Claim - ID: %s, Staff: %s (%s), Player: %s (%s), Priority: %s, Category: %s, Message: %s",
                claimID,
                client:Name(), client:SteamID(),
                requester:Name(), requester:SteamID(),
                claimData.priority, claimData.category,
                ticketMessage), FLAG_NORMAL)

            -- Update statistics
            MODULE.UpdateClaimStatistics(client, "claim")
            MODULE.UpdateTicketStatistics(claimData.category, "claimed")

            -- Send claim notification to other staff
            MODULE.NotifyOtherStaff(client, "ticket_claimed", {
                claimer = client:Name(),
                requester = requester:Name(),
                message = ticketMessage
            })

            -- Start claim monitoring
            MODULE.StartClaimMonitoring(claimID, client, requester)

            -- Handle priority tickets
            if claimData.priority == "high" then
                MODULE.EscalateHighPriorityTicket(claimData)
            end

            -- Update staff workload
            MODULE.UpdateStaffWorkload(client, 1)

            -- Send claim confirmation to client UI
            net.Start("TicketClaimConfirm")
                net.WriteString(claimID)
                net.WriteEntity(requester)
                net.WriteString(ticketMessage)
            net.Send(client)

            -- Update ticket queue for all staff
            MODULE.BroadcastTicketQueueUpdate()

            -- Trigger claim analytics
            MODULE.TrackTicketClaimAnalytics(claimData)

            -- Check for auto-assignment rules
            MODULE.CheckAutoAssignmentRules(client, claimData)

            -- Handle VIP tickets
            if MODULE.IsVIPPlayer(requester) then
                MODULE.ApplyVIPTicketHandling(claimData)
            end
        end
        ```
]]
function TicketSystemClaim(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when ticket system closes tickets.

    When Called:
        When support tickets are closed.

    Parameters:
        client (Player)
            The closing staff member.
        requester (Player)
            The ticket requester.
        ticketMessage (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ticket close logging
        function MODULE:TicketSystemClose(client, requester, ticketMessage)
            -- Log the ticket closure
            lia.log.add(string.format("%s closed ticket from %s", client:Name(), requester:Name()), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update ticket status and notify players
        function MODULE:TicketSystemClose(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            -- Update ticket status
            MODULE.SetTicketStatus(requester, "closed", client)

            -- Notify both players
            client:notify("You have closed the ticket from " .. requester:Name())
            requester:notify("Your ticket has been closed by " .. client:Name())

            -- Log the closure
            lia.log.add(string.format("Ticket closed - Staff: %s, Player: %s, Message: %s",
                client:Name(), requester:Name(), ticketMessage), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive ticket closure system with feedback and analytics
        function MODULE:TicketSystemClose(client, requester, ticketMessage)
            if not IsValid(client) or not IsValid(requester) then return end

            local currentTime = os.time()
            local claimID = MODULE.GetTicketClaimID(requester)

            -- Validate closure permissions
            if not MODULE.CanCloseTickets(client) then
                client:notify("You don't have permission to close tickets!")
                return
            end

            -- Check if ticket belongs to this staff member
            if not MODULE.IsTicketClaimedBy(client, requester) and not MODULE.CanCloseAnyTicket(client) then
                client:notify("You can only close tickets you have claimed!")
                return
            end

            -- Get ticket data
            local ticketData = MODULE.GetTicketData(requester)
            if not ticketData then
                client:notify("Ticket data not found!")
                return
            end

            -- Calculate resolution time
            local resolutionTime = currentTime - ticketData.claimedAt
            local resolutionHours = math.floor(resolutionTime / 3600)
            local resolutionMinutes = math.floor((resolutionTime % 3600) / 60)

            -- Create closure record
            local closureData = {
                id = "closure_" .. currentTime .. "_" .. client:UserID() .. "_" .. requester:UserID(),
                ticketID = claimID,
                staffMember = client,
                staffSteamID = client:SteamID(),
                requester = requester,
                requesterSteamID = requester:SteamID(),
                originalMessage = ticketMessage,
                closedAt = currentTime,
                resolutionTime = resolutionTime,
                resolutionTimeFormatted = string.format("%dh %dm", resolutionHours, resolutionMinutes),
                category = ticketData.category,
                priority = ticketData.priority,
                satisfactionRating = nil -- To be filled by requester feedback
            }

            -- Store closure data
            MODULE.StoreTicketClosure(closureData)

            -- Update ticket status
            MODULE.SetTicketStatus(requester, "closed", client, closureData.id)

            -- Clean up claim timers
            timer.Remove("ticket_claim_timeout_" .. claimID)

            -- Update staff workload
            MODULE.UpdateStaffWorkload(client, -1)

            -- Notify staff member
            client:notify(string.format("Ticket closed successfully!\nRequester: %s\nResolution Time: %s",
                requester:Name(), closureData.resolutionTimeFormatted))

            -- Notify requester with feedback request
            requester:notify(string.format("Your support ticket has been resolved by %s.\nResolution Time: %s\nPlease rate your experience!",
                client:Name(), closureData.resolutionTimeFormatted))

            -- Request feedback from requester
            timer.Simple(5, function()
                if IsValid(requester) then
                    MODULE.RequestTicketFeedback(requester, closureData.id)
                end
            end)

            -- Log detailed closure information
            lia.log.add(string.format("Ticket Closure - ID: %s, Staff: %s (%s), Player: %s (%s), Resolution: %s, Category: %s, Priority: %s, Original: %s",
                closureData.id,
                client:Name(), client:SteamID(),
                requester:Name(), requester:SteamID(),
                closureData.resolutionTimeFormatted,
                closureData.category, closureData.priority,
                ticketMessage), FLAG_NORMAL)

            -- Update statistics
            MODULE.UpdateClosureStatistics(client, closureData)
            MODULE.UpdateTicketStatistics(closureData.category, "closed")

            -- Check resolution time goals
            if resolutionTime > MODULE.GetResolutionTimeGoal(closureData.priority) then
                MODULE.FlagSlowResolution(closureData)
            end

            -- Send closure notification to other staff
            MODULE.NotifyOtherStaff(client, "ticket_closed", {
                closer = client:Name(),
                requester = requester:Name(),
                resolutionTime = closureData.resolutionTimeFormatted,
                category = closureData.category
            })

            -- Update ticket queue
            MODULE.RemoveFromTicketQueue(requester)
            MODULE.BroadcastTicketQueueUpdate()

            -- Send closure confirmation to client UI
            net.Start("TicketClosureConfirm")
                net.WriteString(closureData.id)
                net.WriteEntity(requester)
                net.WriteString(closureData.resolutionTimeFormatted)
            net.Send(client)

            -- Trigger closure analytics
            MODULE.TrackTicketClosureAnalytics(closureData)

            -- Handle follow-up actions
            MODULE.ScheduleFollowUpActions(closureData)

            -- Check for escalation cases
            if MODULE.ShouldEscalateClosure(closureData) then
                MODULE.EscalateTicketClosure(closureData)
            end

            -- Update staff performance metrics
            MODULE.UpdateStaffPerformance(client, closureData)

            -- Clean up ticket data
            MODULE.CleanupTicketData(requester)

            -- Archive ticket for records
            MODULE.ArchiveTicket(closureData)
        end
        ```
]]
function TicketSystemClose(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when ticket system creates tickets.

    When Called:
        When support tickets are submitted.

    Parameters:
        requester (Player)
            The ticket requester.
        message (string)
            The ticket message.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ticket creation logging
        function MODULE:TicketSystemCreated(requester, message)
            -- Log the ticket creation
            lia.log.add(string.format("%s created a ticket: %s", requester:Name(), message), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update ticket queue and notify staff
        function MODULE:TicketSystemCreated(requester, message)
            if not IsValid(requester) then return end

            -- Add to ticket queue
            MODULE.AddToTicketQueue(requester, message)

            -- Notify available staff
            MODULE.NotifyAvailableStaff(requester, message)

            -- Log the creation
            lia.log.add(string.format("Ticket created - Player: %s, Message: %s",
                requester:Name(), message), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive ticket creation with categorization and auto-assignment
        function MODULE:TicketSystemCreated(requester, message)
            if not IsValid(requester) then return end

            local currentTime = os.time()
            local ticketID = "ticket_" .. currentTime .. "_" .. requester:UserID()

            -- Validate ticket content
            if not MODULE.ValidateTicketMessage(message) then
                requester:notify("Your ticket message is invalid. Please provide more details.")
                return
            end

            -- Check ticket spam prevention
            if MODULE.IsTicketSpam(requester) then
                requester:notify("You have submitted too many tickets recently. Please wait before submitting another.")
                return
            end

            -- Categorize ticket
            local category = MODULE.CategorizeTicket(message)
            local priority = MODULE.CalculateTicketPriority(message)

            -- Create ticket data
            local ticketData = {
                id = ticketID,
                requester = requester,
                requesterSteamID = requester:SteamID(),
                message = message,
                category = category,
                priority = priority,
                createdAt = currentTime,
                status = "open",
                assignedTo = nil,
                tags = MODULE.ExtractTicketTags(message),
                language = MODULE.DetectLanguage(message),
                estimatedResolutionTime = MODULE.EstimateResolutionTime(category, priority)
            }

            -- Store ticket data
            MODULE.StoreTicket(ticketData)

            -- Add to appropriate queues
            MODULE.AddToTicketQueue(ticketData)
            MODULE.AddToCategoryQueue(category, ticketData)
            MODULE.AddToPriorityQueue(priority, ticketData)

            -- Auto-assign if possible
            local assignedStaff = MODULE.AutoAssignTicket(ticketData)
            if assignedStaff then
                MODULE.AssignTicketToStaff(ticketData, assignedStaff)
            end

            -- Notify requester
            requester:notify(string.format("Your support ticket has been submitted!\nCategory: %s\nPriority: %s\nEstimated wait time: %s",
                category, priority, MODULE.FormatWaitTime(ticketData.estimatedResolutionTime)))

            -- Notify staff
            MODULE.BroadcastTicketToStaff(ticketData)

            -- Log detailed creation information
            lia.log.add(string.format("Ticket Created - ID: %s, Player: %s (%s), Category: %s, Priority: %s, Message: %s",
                ticketID,
                requester:Name(), requester:SteamID(),
                category, priority, message), FLAG_NORMAL)

            -- Update statistics
            MODULE.UpdateTicketCreationStatistics(requester, category, priority)

            -- Handle special cases
            if priority == "critical" then
                MODULE.HandleCriticalTicket(ticketData)
            elseif MODULE.IsVIPPlayer(requester) then
                MODULE.ApplyVIPTicketPriority(ticketData)
            end

            -- Send creation confirmation to client
            net.Start("TicketCreatedConfirm")
                net.WriteString(ticketID)
                net.WriteString(category)
                net.WriteString(priority)
            net.Send(requester)

            -- Trigger creation analytics
            MODULE.TrackTicketCreationAnalytics(ticketData)

            -- Check for similar existing tickets
            local similarTickets = MODULE.FindSimilarTickets(ticketData)
            if #similarTickets > 0 then
                MODULE.SuggestSimilarTickets(requester, similarTickets)
            end

            -- Update server ticket metrics
            MODULE.UpdateServerTicketMetrics()

            -- Handle language-specific routing
            if ticketData.language ~= "english" then
                MODULE.RouteToLanguageStaff(ticketData)
            end

            -- Set up ticket timeout
            timer.Create("ticket_timeout_" .. ticketID, MODULE.GetTicketTimeout(), 1, function()
                if MODULE.GetTicketStatus(ticketID) == "open" then
                    MODULE.AutoCloseTicket(ticketID, "timeout")
                end
            end)

            -- Send ticket creation notification to Discord/webhooks
            MODULE.SendExternalNotification(ticketData)

            -- Update requester's ticket history
            MODULE.UpdatePlayerTicketHistory(requester, ticketData)

            -- Check for ticket creation limits
            MODULE.CheckTicketCreationLimits(requester)
        end
        ```
]]
function TicketSystemCreated(requester, message)
end

--[[
    Purpose:
        Called to toggle door locks.

    When Called:
        When door lock state is toggled.

    Parameters:
        client (Player)
            The player toggling the lock.
        door (Entity)
            The door entity.
        state (boolean)
            The lock state.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic lock toggle logging
        function MODULE:ToggleLock(client, door, state)
            -- Log the lock toggle
            lia.log.add(string.format("%s %s %s", client:Name(), state and "locked" or "unlocked", tostring(door)), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update door state and play sound
        function MODULE:ToggleLock(client, door, state)
            if not IsValid(client) or not IsValid(door) then return end

            -- Update door lock state
            door:SetLocked(state)

            -- Play appropriate sound
            if state then
                door:EmitSound("doors/door_latch1.wav")
            else
                door:EmitSound("doors/door_latch3.wav")
            end

            -- Log the action
            lia.log.add(string.format("%s %s door at %s", client:Name(), state and "locked" or "unlocked", tostring(door:GetPos())), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive lock management with security and access control
        function MODULE:ToggleLock(client, door, state)
            if not IsValid(client) or not IsValid(door) then return end

            local char = client:getChar()
            if not char then return end

            -- Check if player has permission to toggle this lock
            if not MODULE.CanToggleLock(client, door) then
                client:notify("You don't have permission to " .. (state and "lock" or "unlock") .. " this door!")
                return
            end

            -- Get door data
            local doorData = MODULE.GetDoorData(door)
            local doorName = doorData and doorData.name or "Door"
            local doorOwner = doorData and doorData.owner

            -- Check ownership permissions
            if doorOwner and doorOwner ~= char:getID() then
                -- Check if client has access permissions
                if not MODULE.HasDoorAccess(client, door) then
                    client:notify("You don't own this door and don't have access!")
                    MODULE.LogSecurityEvent(client, "unauthorized_lock_attempt", door)
                    return
                end
            end

            -- Update door lock state
            door:SetLocked(state)

            -- Update door data
            if doorData then
                doorData.locked = state
                doorData.lastToggled = os.time()
                doorData.lastToggledBy = client:Name()
                MODULE.UpdateDoorData(door, doorData)
            end

            -- Play appropriate sound with variation
            local soundPath = state and "doors/door_latch1.wav" or "doors/door_latch3.wav"
            door:EmitSound(soundPath, 75, math.random(95, 105))

            -- Visual effects
            local effectData = EffectData()
            effectData:SetOrigin(door:GetPos())
            effectData:SetNormal(door:GetForward())
            util.Effect("lock_toggle", effectData)

            -- Notify nearby players
            local nearbyPlayers = MODULE.GetNearbyPlayers(door:GetPos(), 300)
            for _, ply in ipairs(nearbyPlayers) do
                if ply ~= client and IsValid(ply) then
                    ply:notify(string.format("%s %s the %s", client:Name(), state and "locked" or "unlocked", doorName))
                end
            end

            -- Log detailed action
            lia.log.add(string.format("Lock Toggled - Player: %s (%s), Door: %s, State: %s, Location: %s",
                client:Name(), client:SteamID(),
                doorName, state and "locked" or "unlocked",
                tostring(door:GetPos())), FLAG_NORMAL)

            -- Update security logs
            MODULE.LogDoorAccess(client, door, state and "lock" or "unlock")

            -- Check for suspicious activity
            if MODULE.IsSuspiciousLockActivity(client, door, state) then
                MODULE.FlagSuspiciousActivity(client, "suspicious_lock_activity")
            end

            -- Update door statistics
            MODULE.UpdateDoorStatistics(door, state and "locked" or "unlocked", client)

            -- Handle special door types
            if MODULE.IsSpecialDoor(door) then
                MODULE.HandleSpecialDoorToggle(door, state, client)
            end

            -- Trigger alarm systems if applicable
            if state and MODULE.ShouldTriggerAlarm(door) then
                MODULE.TriggerDoorAlarm(door, client)
            end

            -- Update client-side lock indicators
            net.Start("DoorLockToggled")
                net.WriteEntity(door)
                net.WriteBool(state)
                net.WriteString(client:Name())
            net.Broadcast()

            -- Handle auto-lock timers
            if state and MODULE.ShouldAutoUnlock(door) then
                timer.Create("auto_unlock_" .. door:EntIndex(), MODULE.GetAutoUnlockTime(door), 1, function()
                    if IsValid(door) then
                        door:SetLocked(false)
                        MODULE.LogAutoUnlock(door)
                    end
                end)
            end

            -- Update faction door permissions
            MODULE.UpdateFactionDoorPermissions(door, state, client)

            -- Handle key usage
            if MODULE.RequiresKey(door) then
                MODULE.UseDoorKey(client, door, state)
            end

            -- Send to external logging systems
            MODULE.SendDoorEventToExternalLogs(client, door, state)
        end
        ```
]]
function ToggleLock(client, door, state)
end

--[[
    Purpose:
        Called to update entity persistence.

    When Called:
        When entity save data needs updating.

    Parameters:
        entity (Entity)
            The entity to update.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic persistence update
        function MODULE:UpdateEntityPersistence(entity)
            -- Mark entity for save
            entity:SetNetVar("needsSave", true)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update with validation
        function MODULE:UpdateEntityPersistence(entity)
            if not IsValid(entity) then return end

            -- Update last modified time
            entity:SetNetVar("lastModified", os.time())
            entity:SetNetVar("needsSave", true)

            -- Log the update
            lia.log.add(string.format("Entity persistence updated: %s", entity:GetClass()), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive persistence with data integrity
        function MODULE:UpdateEntityPersistence(entity)
            if not IsValid(entity) then return end

            local currentTime = os.time()

            -- Validate entity data before persistence
            if MODULE.ValidateEntityForPersistence(entity) then
                -- Update persistence metadata
                entity:SetNetVar("lastPersistenceUpdate", currentTime)
                entity:SetNetVar("persistenceVersion", MODULE.GetCurrentPersistenceVersion())
                entity:SetNetVar("needsSave", true)

                -- Update entity statistics
                local saveCount = entity:GetNetVar("saveCount", 0) + 1
                entity:SetNetVar("saveCount", saveCount)

                -- Handle special entity types
                if entity:IsPlayer() then
                    MODULE.UpdatePlayerPersistence(entity)
                elseif entity:IsVehicle() then
                    MODULE.UpdateVehiclePersistence(entity)
                elseif MODULE.IsPersistentEntity(entity) then
                    MODULE.UpdateCustomEntityPersistence(entity)
                end

                -- Log detailed persistence update
                lia.log.add(string.format("Entity persistence updated - Class: %s, Saves: %d, Time: %s",
                    entity:GetClass(), saveCount, os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

                -- Trigger persistence events
                hook.Run("EntityPersistenceUpdated", entity, currentTime)

            else
                -- Handle invalid entities
                lia.log.add(string.format("Failed to update persistence for invalid entity: %s",
                    entity:GetClass() or "unknown"), FLAG_WARNING)

                -- Mark for cleanup if necessary
                MODULE.FlagEntityForCleanup(entity)
            end
        end
        ```
]]
function UpdateEntityPersistence(entity)
end

--[[
    Purpose:
        Called when vendor class restrictions are updated.

    When Called:
        When vendor class access is modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        classID (string)
            The class ID.
        allowed (boolean)
            Whether the class is allowed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorClassUpdated(vendor, classID, allowed)
            -- Log the class restriction update
            lia.log.add(string.format("Vendor class updated: %s %s", classID, allowed and "allowed" or "denied"), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor data
        function MODULE:VendorClassUpdated(vendor, classID, allowed)
            if not IsValid(vendor) or not classID then return end

            -- Update vendor's class restrictions
            local restrictions = vendor:getData("classRestrictions", {})
            restrictions[classID] = allowed
            vendor:setData("classRestrictions", restrictions)

            -- Log the update
            lia.log.add(string.format("Vendor %s class restriction updated: %s -> %s",
                vendor:getNetVar("name", "Unknown"), classID, allowed and "allowed" or "denied"), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive class restriction management
        function MODULE:VendorClassUpdated(vendor, classID, allowed)
            if not IsValid(vendor) or not classID then return end

            local currentTime = os.time()

            -- Get class information
            local classData = lia.class.get(classID)
            if not classData then
                lia.log.add(string.format("Attempted to update restrictions for invalid class: %s", classID), FLAG_WARNING)
                return
            end

            -- Update vendor's class restrictions
            local restrictions = vendor:getData("classRestrictions", {})
            local oldAllowed = restrictions[classID]
            restrictions[classID] = allowed
            vendor:setData("classRestrictions", restrictions)

            -- Update restriction history
            local history = vendor:getData("classRestrictionHistory", {})
            table.insert(history, {
                classID = classID,
                oldAllowed = oldAllowed,
                newAllowed = allowed,
                timestamp = currentTime,
                admin = "system" -- Would be replaced with actual admin in real implementation
            })
            vendor:setData("classRestrictionHistory", history)

            -- Notify players who might be affected
            MODULE.NotifyAffectedPlayers(vendor, classID, allowed)

            -- Update vendor statistics
            local stats = vendor:getData("restrictionStats", {})
            stats.totalClassUpdates = (stats.totalClassUpdates or 0) + 1
            stats.lastClassUpdate = currentTime
            vendor:setData("restrictionStats", stats)

            -- Log detailed update
            lia.log.add(string.format("Vendor class restriction updated - Vendor: %s, Class: %s (%s), Changed: %s -> %s, Time: %s",
                vendor:getNetVar("name", "Unknown"),
                classData.name, classID,
                oldAllowed and "allowed" or "denied",
                allowed and "allowed" or "denied",
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Handle special cases
            if allowed and MODULE.IsRestrictedClass(classID) then
                MODULE.LogRestrictedClassAccess(vendor, classID, currentTime)
            end

            -- Update client-side displays
            MODULE.BroadcastVendorUpdate(vendor, "class_restriction")

            -- Check for conflicts with other restrictions
            MODULE.CheckClassRestrictionConflicts(vendor, classID, allowed)

            -- Trigger synchronization
            MODULE.SyncVendorRestrictions(vendor)
        end
        ```
]]
function VendorClassUpdated(vendor, classID, allowed)
end

--[[
    Purpose:
        Called when vendor settings are edited.

    When Called:
        When vendor properties are modified.

    Parameters:
        liaVendorEnt (Entity)
            The vendor entity.
        key (string)
            The property key.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorEdited(liaVendorEnt, key)
            -- Log the vendor edit
            lia.log.add(string.format("Vendor edited: %s", key), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor data
        function MODULE:VendorEdited(liaVendorEnt, key)
            if not IsValid(liaVendorEnt) or not key then return end

            -- Mark vendor as modified
            liaVendorEnt:setData("lastEdited", os.time())
            liaVendorEnt:setData("modifiedKeys", liaVendorEnt:getData("modifiedKeys", {}))

            -- Log the edit
            lia.log.add(string.format("Vendor %s property edited: %s",
                liaVendorEnt:getNetVar("name", "Unknown"), key), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive vendor editing with validation and tracking
        function MODULE:VendorEdited(liaVendorEnt, key)
            if not IsValid(liaVendorEnt) or not key then return end

            local currentTime = os.time()
            local vendorName = liaVendorEnt:getNetVar("name", "Unknown Vendor")

            -- Validate the edit key
            if not MODULE.IsValidVendorProperty(key) then
                lia.log.add(string.format("Invalid vendor property edit attempt: %s for vendor %s", key, vendorName), FLAG_WARNING)
                return
            end

            -- Track edit history
            local editHistory = liaVendorEnt:getData("editHistory", {})
            table.insert(editHistory, {
                key = key,
                timestamp = currentTime,
                editor = "system" -- Would be actual editor in real implementation
            })

            -- Keep only last 50 edits
            if #editHistory > 50 then
                table.remove(editHistory, 1)
            end

            liaVendorEnt:setData("editHistory", editHistory)

            -- Update modification metadata
            liaVendorEnt:setData("lastEdited", currentTime)
            liaVendorEnt:setData("totalEdits", liaVendorEnt:getData("totalEdits", 0) + 1)

            -- Handle special property types
            if MODULE.IsCriticalVendorProperty(key) then
                MODULE.LogCriticalVendorEdit(liaVendorEnt, key, currentTime)
            elseif MODULE.IsInventoryProperty(key) then
                MODULE.ValidateVendorInventory(liaVendorEnt)
            elseif MODULE.IsPricingProperty(key) then
                MODULE.ValidateVendorPricing(liaVendorEnt)
            end

            -- Update vendor statistics
            local stats = liaVendorEnt:getData("editStats", {})
            stats[key] = (stats[key] or 0) + 1
            stats.lastEdit = currentTime
            liaVendorEnt:setData("editStats", stats)

            -- Log detailed edit information
            lia.log.add(string.format("Vendor edited - Name: %s, Property: %s, Total Edits: %d, Time: %s",
                vendorName, key,
                liaVendorEnt:getData("totalEdits", 1),
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Trigger synchronization
            MODULE.SyncVendorData(liaVendorEnt)

            -- Notify relevant clients
            MODULE.NotifyVendorUpdate(liaVendorEnt, key)

            -- Check for edit conflicts
            if MODULE.HasEditConflicts(liaVendorEnt, key) then
                MODULE.ResolveEditConflicts(liaVendorEnt, key)
            end

            -- Update backup data
            MODULE.UpdateVendorBackup(liaVendorEnt)

            -- Handle property-specific actions
            MODULE.HandleVendorPropertyEdit(liaVendorEnt, key, currentTime)

            -- Trigger custom events
            hook.Run("VendorPropertyEdited", liaVendorEnt, key, currentTime)
        end
        ```
]]
function VendorEdited(liaVendorEnt, key)
end

--[[
    Purpose:
        Called when vendor faction restrictions are updated.

    When Called:
        When vendor faction access is modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        factionID (string)
            The faction ID.
        allowed (boolean)
            Whether the faction is allowed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorFactionUpdated(vendor, factionID, allowed)
            -- Log the faction restriction update
            lia.log.add(string.format("Vendor faction updated: %s %s", factionID, allowed and "allowed" or "denied"), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor data
        function MODULE:VendorFactionUpdated(vendor, factionID, allowed)
            if not IsValid(vendor) or not factionID then return end

            -- Update vendor's faction restrictions
            local restrictions = vendor:getData("factionRestrictions", {})
            restrictions[factionID] = allowed
            vendor:setData("factionRestrictions", restrictions)

            -- Log the update
            lia.log.add(string.format("Vendor %s faction restriction updated: %s -> %s",
                vendor:getNetVar("name", "Unknown"), factionID, allowed and "allowed" or "denied"), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive faction restriction management
        function MODULE:VendorFactionUpdated(vendor, factionID, allowed)
            if not IsValid(vendor) or not factionID then return end

            local currentTime = os.time()

            -- Get faction information
            local factionData = lia.faction.get(factionID)
            if not factionData then
                lia.log.add(string.format("Attempted to update restrictions for invalid faction: %s", factionID), FLAG_WARNING)
                return
            end

            -- Update vendor's faction restrictions
            local restrictions = vendor:getData("factionRestrictions", {})
            local oldAllowed = restrictions[factionID]
            restrictions[factionID] = allowed
            vendor:setData("factionRestrictions", restrictions)

            -- Update restriction history
            local history = vendor:getData("factionRestrictionHistory", {})
            table.insert(history, {
                factionID = factionID,
                oldAllowed = oldAllowed,
                newAllowed = allowed,
                timestamp = currentTime,
                admin = "system"
            })
            vendor:setData("factionRestrictionHistory", history)

            -- Notify players from affected faction
            MODULE.NotifyFactionMembers(vendor, factionID, allowed)

            -- Update vendor statistics
            local stats = vendor:getData("restrictionStats", {})
            stats.totalFactionUpdates = (stats.totalFactionUpdates or 0) + 1
            stats.lastFactionUpdate = currentTime
            vendor:setData("restrictionStats", stats)

            -- Log detailed update
            lia.log.add(string.format("Vendor faction restriction updated - Vendor: %s, Faction: %s (%s), Changed: %s -> %s, Time: %s",
                vendor:getNetVar("name", "Unknown"),
                factionData.name, factionID,
                oldAllowed and "allowed" or "denied",
                allowed and "allowed" or "denied",
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Handle faction-specific logic
            if allowed and MODULE.IsHostileFaction(factionID) then
                MODULE.LogHostileFactionAccess(vendor, factionID, currentTime)
            end

            -- Update client-side displays
            MODULE.BroadcastVendorUpdate(vendor, "faction_restriction")

            -- Check for conflicts with other restrictions
            MODULE.CheckFactionRestrictionConflicts(vendor, factionID, allowed)

            -- Trigger synchronization
            MODULE.SyncVendorRestrictions(vendor)
        end
        ```
]]
function VendorFactionUpdated(vendor, factionID, allowed)
end

--[[
    Purpose:
        Called when vendor item max stock is updated.

    When Called:
        When vendor item stock limits are modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The item type.
        value (number)
            The max stock value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorItemMaxStockUpdated(vendor, itemType, value)
            -- Log the stock update
            lia.log.add(string.format("Vendor item max stock updated: %s -> %d", itemType, value), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor inventory
        function MODULE:VendorItemMaxStockUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            -- Update vendor's item stock limits
            local stockLimits = vendor:getData("itemStockLimits", {})
            stockLimits[itemType] = value
            vendor:setData("itemStockLimits", stockLimits)

            -- Log the update
            lia.log.add(string.format("Vendor %s item stock limit updated: %s -> %d",
                vendor:getNetVar("name", "Unknown"), itemType, value), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive stock management
        function MODULE:VendorItemMaxStockUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            local currentTime = os.time()

            -- Validate the value
            if value < 0 then
                lia.log.add(string.format("Invalid stock limit for %s: %d", itemType, value), FLAG_WARNING)
                return
            end

            -- Get item information
            local itemData = lia.item.get(itemType)
            if not itemData then
                lia.log.add(string.format("Attempted to update stock for invalid item: %s", itemType), FLAG_WARNING)
                return
            end

            -- Update vendor's item stock limits
            local stockLimits = vendor:getData("itemStockLimits", {})
            local oldValue = stockLimits[itemType] or 0
            stockLimits[itemType] = value
            vendor:setData("itemStockLimits", stockLimits)

            -- Update stock history
            local history = vendor:getData("stockLimitHistory", {})
            table.insert(history, {
                itemType = itemType,
                oldValue = oldValue,
                newValue = value,
                timestamp = currentTime,
                admin = "system"
            })
            vendor:setData("stockLimitHistory", history)

            -- Check current stock against new limit
            local currentStock = MODULE.GetVendorItemStock(vendor, itemType)
            if currentStock > value then
                -- Reduce current stock to match new limit
                MODULE.AdjustVendorStock(vendor, itemType, value)
                lia.log.add(string.format("Reduced %s stock from %d to %d to match new limit", itemType, currentStock, value), FLAG_WARNING)
            end

            -- Update vendor statistics
            local stats = vendor:getData("stockStats", {})
            stats.totalStockUpdates = (stats.totalStockUpdates or 0) + 1
            stats.lastStockUpdate = currentTime
            vendor:setData("stockStats", stats)

            -- Log detailed update
            lia.log.add(string.format("Vendor item stock limit updated - Vendor: %s, Item: %s (%s), Changed: %d -> %d, Time: %s",
                vendor:getNetVar("name", "Unknown"),
                itemData.name, itemType,
                oldValue, value,
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Handle economic impacts
            if value == 0 then
                MODULE.HandleItemOutOfStock(vendor, itemType)
            elseif oldValue == 0 and value > 0 then
                MODULE.HandleItemRestocked(vendor, itemType)
            end

            -- Update client-side displays
            MODULE.BroadcastVendorUpdate(vendor, "stock_limit")

            -- Trigger synchronization
            MODULE.SyncVendorStockLimits(vendor)
        end
        ```
]]
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when vendor item mode is updated.

    When Called:
        When vendor item trading modes are modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The item type.
        value (number)
            The mode value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorItemModeUpdated(vendor, itemType, value)
            -- Log the mode update
            lia.log.add(string.format("Vendor item mode updated: %s -> %d", itemType, value), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor trading modes
        function MODULE:VendorItemModeUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            -- Update vendor's item trading modes
            local tradingModes = vendor:getData("itemTradingModes", {})
            tradingModes[itemType] = value
            vendor:setData("itemTradingModes", tradingModes)

            -- Log the update
            lia.log.add(string.format("Vendor %s item trading mode updated: %s -> %d",
                vendor:getNetVar("name", "Unknown"), itemType, value), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive trading mode management
        function MODULE:VendorItemModeUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            local currentTime = os.time()

            -- Validate the mode value
            local validModes = MODULE.GetValidTradingModes()
            if not table.HasValue(validModes, value) then
                lia.log.add(string.format("Invalid trading mode for %s: %d", itemType, value), FLAG_WARNING)
                return
            end

            -- Get item information
            local itemData = lia.item.get(itemType)
            if not itemData then
                lia.log.add(string.format("Attempted to update mode for invalid item: %s", itemType), FLAG_WARNING)
                return
            end

            -- Update vendor's item trading modes
            local tradingModes = vendor:getData("itemTradingModes", {})
            local oldValue = tradingModes[itemType] or 0
            tradingModes[itemType] = value
            vendor:setData("itemTradingModes", tradingModes)

            -- Update mode history
            local history = vendor:getData("modeChangeHistory", {})
            table.insert(history, {
                itemType = itemType,
                oldMode = oldValue,
                newMode = value,
                timestamp = currentTime,
                admin = "system"
            })
            vendor:setData("modeChangeHistory", history)

            -- Handle mode-specific logic
            if value == MODULE.TRADING_MODE_BUY_ONLY then
                MODULE.SetupBuyOnlyMode(vendor, itemType)
            elseif value == MODULE.TRADING_MODE_SELL_ONLY then
                MODULE.SetupSellOnlyMode(vendor, itemType)
            elseif value == MODULE.TRADING_MODE_BARTER then
                MODULE.SetupBarterMode(vendor, itemType)
            end

            -- Update vendor statistics
            local stats = vendor:getData("tradingStats", {})
            stats.totalModeUpdates = (stats.totalModeUpdates or 0) + 1
            stats.lastModeUpdate = currentTime
            vendor:setData("tradingStats", stats)

            -- Log detailed update
            lia.log.add(string.format("Vendor item trading mode updated - Vendor: %s, Item: %s (%s), Mode: %d -> %d, Time: %s",
                vendor:getNetVar("name", "Unknown"),
                itemData.name, itemType,
                oldValue, value,
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Notify affected players
            MODULE.NotifyTradingModeChange(vendor, itemType, value)

            -- Update client-side displays
            MODULE.BroadcastVendorUpdate(vendor, "trading_mode")

            -- Trigger synchronization
            MODULE.SyncVendorTradingModes(vendor)
        end
        ```
]]
function VendorItemModeUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when vendor item price is updated.

    When Called:
        When vendor item prices are modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The item type.
        value (number)
            The price value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorItemPriceUpdated(vendor, itemType, value)
            -- Log the price update
            lia.log.add(string.format("Vendor item price updated: %s -> %d", itemType, value), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor prices
        function MODULE:VendorItemPriceUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            -- Update vendor's item prices
            local prices = vendor:getData("itemPrices", {})
            prices[itemType] = value
            vendor:setData("itemPrices", prices)

            -- Log the update
            lia.log.add(string.format("Vendor %s item price updated: %s -> %d",
                vendor:getNetVar("name", "Unknown"), itemType, value), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive price management with economic impact
        function MODULE:VendorItemPriceUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            local currentTime = os.time()

            -- Validate the price value
            if value < 0 then
                lia.log.add(string.format("Invalid price for %s: %d", itemType, value), FLAG_WARNING)
                return
            end

            -- Get item information
            local itemData = lia.item.get(itemType)
            if not itemData then
                lia.log.add(string.format("Attempted to update price for invalid item: %s", itemType), FLAG_WARNING)
                return
            end

            -- Update vendor's item prices
            local prices = vendor:getData("itemPrices", {})
            local oldPrice = prices[itemType] or itemData.price or 0
            prices[itemType] = value
            vendor:setData("itemPrices", prices)

            -- Update price history
            local history = vendor:getData("priceChangeHistory", {})
            table.insert(history, {
                itemType = itemType,
                oldPrice = oldPrice,
                newPrice = value,
                timestamp = currentTime,
                admin = "system"
            })
            vendor:setData("priceChangeHistory", history)

            -- Calculate price change percentage
            local priceChange = 0
            if oldPrice > 0 then
                priceChange = ((value - oldPrice) / oldPrice) * 100
            end

            -- Handle economic impacts
            if priceChange > 50 then
                MODULE.HandlePriceInflation(vendor, itemType, priceChange)
            elseif priceChange < -50 then
                MODULE.HandlePriceDeflation(vendor, itemType, priceChange)
            end

            -- Update vendor statistics
            local stats = vendor:getData("priceStats", {})
            stats.totalPriceUpdates = (stats.totalPriceUpdates or 0) + 1
            stats.lastPriceUpdate = currentTime
            stats.averagePriceChange = ((stats.averagePriceChange or 0) + priceChange) / 2
            vendor:setData("priceStats", stats)

            -- Log detailed update
            lia.log.add(string.format("Vendor item price updated - Vendor: %s, Item: %s (%s), Price: %d -> %d (%.1f%%), Time: %s",
                vendor:getNetVar("name", "Unknown"),
                itemData.name, itemType,
                oldPrice, value, priceChange,
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Notify players of significant price changes
            if math.abs(priceChange) > 25 then
                MODULE.NotifyPriceChange(vendor, itemType, oldPrice, value, priceChange)
            end

            -- Update market analytics
            MODULE.UpdateMarketAnalytics(vendor, itemType, value, oldPrice)

            -- Update client-side displays
            MODULE.BroadcastVendorUpdate(vendor, "price")

            -- Trigger synchronization
            MODULE.SyncVendorPrices(vendor)
        end
        ```
]]
function VendorItemPriceUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when vendor item stock is updated.

    When Called:
        When vendor item stock levels are modified.

    Parameters:
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The item type.
        value (number)
            The stock value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorItemStockUpdated(vendor, itemType, value)
            lia.log.add(string.format("Vendor item stock updated: %s -> %d", itemType, value), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update vendor stock
        function MODULE:VendorItemStockUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            local stock = vendor:getData("itemStock", {})
            stock[itemType] = value
            vendor:setData("itemStock", stock)

            lia.log.add(string.format("Vendor %s stock updated: %s -> %d",
                vendor:getNetVar("name", "Unknown"), itemType, value), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced stock management
        function MODULE:VendorItemStockUpdated(vendor, itemType, value)
            if not IsValid(vendor) or not itemType then return end

            local currentTime = os.time()
            local itemData = lia.item.get(itemType)
            if not itemData then return end

            local stock = vendor:getData("itemStock", {})
            local oldStock = stock[itemType] or 0
            stock[itemType] = value
            vendor:setData("itemStock", stock)

            -- Update stock history
            local history = vendor:getData("stockHistory", {})
            table.insert(history, {
                itemType = itemType,
                oldStock = oldStock,
                newStock = value,
                timestamp = currentTime
            })
            vendor:setData("stockHistory", history)

            -- Handle stock events
            if value == 0 and oldStock > 0 then
                MODULE.HandleOutOfStock(vendor, itemType)
            elseif value > 0 and oldStock == 0 then
                MODULE.HandleRestocked(vendor, itemType)
            end

            lia.log.add(string.format("Vendor stock updated - %s: %s (%s) %d -> %d",
                vendor:getNetVar("name", "Unknown"), itemData.name, itemType, oldStock, value), FLAG_NORMAL)

            MODULE.SyncVendorStock(vendor)
        end
        ```
]]
function VendorItemStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when vendor is opened.

    When Called:
        When vendors are accessed by players.

    Parameters:
        vendor (Entity)
            The vendor entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic logging
        function MODULE:VendorOpened(vendor)
            lia.log.add("Vendor opened", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track vendor access
        function MODULE:VendorOpened(vendor)
            if not IsValid(vendor) then return end

            vendor:setData("lastOpened", os.time())
            vendor:setData("openCount", vendor:getData("openCount", 0) + 1)

            lia.log.add(string.format("Vendor %s opened", vendor:getNetVar("name", "Unknown")), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive vendor opening tracking
        function MODULE:VendorOpened(vendor)
            if not IsValid(vendor) then return end

            local currentTime = os.time()
            local vendorName = vendor:getNetVar("name", "Unknown Vendor")

            -- Update vendor statistics
            vendor:setData("lastOpened", currentTime)
            vendor:setData("totalOpens", vendor:getData("totalOpens", 0) + 1)

            -- Track opening history
            local openHistory = vendor:getData("openHistory", {})
            table.insert(openHistory, {
                timestamp = currentTime,
                playerCount = player.GetCount()
            })
            vendor:setData("openHistory", openHistory)

            -- Log detailed opening
            lia.log.add(string.format("Vendor opened - Name: %s, Total Opens: %d, Time: %s",
                vendorName, vendor:getData("totalOpens"), os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            -- Update global vendor statistics
            MODULE.UpdateGlobalVendorStats("opened")

            -- Handle vendor maintenance
            MODULE.CheckVendorMaintenance(vendor)

            -- Trigger opening events
            hook.Run("VendorOpenedDetailed", vendor, currentTime)
        end
        ```
]]
function VendorOpened(vendor)
end

--[[
    Purpose:
        Called when vendor is synchronized.

    When Called:
        When vendor data is synced with clients.

    Parameters:
        vendor (Entity)
            The vendor entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic sync logging
        function MODULE:VendorSynchronized(vendor)
            lia.log.add("Vendor synchronized", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Mark as synced
        function MODULE:VendorSynchronized(vendor)
            if not IsValid(vendor) then return end

            vendor:setData("lastSynced", os.time())
            vendor:SetNetVar("synced", true)

            lia.log.add(string.format("Vendor %s synchronized", vendor:getNetVar("name", "Unknown")), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive sync tracking
        function MODULE:VendorSynchronized(vendor)
            if not IsValid(vendor) then return end

            local currentTime = os.time()
            local vendorName = vendor:getNetVar("name", "Unknown Vendor")

            -- Update sync statistics
            vendor:setData("lastSynced", currentTime)
            vendor:setData("totalSyncs", vendor:getData("totalSyncs", 0) + 1)
            vendor:SetNetVar("synced", true)

            -- Track sync history
            local syncHistory = vendor:getData("syncHistory", {})
            table.insert(syncHistory, {
                timestamp = currentTime,
                dataSize = MODULE.CalculateVendorDataSize(vendor)
            })
            vendor:setData("syncHistory", syncHistory)

            lia.log.add(string.format("Vendor synchronized - Name: %s, Total Syncs: %d, Time: %s",
                vendorName, vendor:getData("totalSyncs"), os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_NORMAL)

            MODULE.UpdateGlobalSyncStats(vendor)
        end
        ```
]]
function VendorSynchronized(vendor)
end

--[[
    Purpose:
        Called when vendor trading occurs.

    When Called:
        When players trade with vendors.

    Parameters:
        client (Player)
            The trading player.
        vendor (Entity)
            The vendor entity.
        itemType (string)
            The item type.
        isSellingToVendor (boolean)
            Whether selling to vendor.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic trade logging
        function MODULE:VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
            lia.log.add(string.format("Trade: %s %s %s", client:Name(), isSellingToVendor and "sold" or "bought", itemType), FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update trade statistics
        function MODULE:VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
            if not IsValid(client) or not IsValid(vendor) then return end

            local stats = vendor:getData("tradeStats", {})
            local key = isSellingToVendor and "sells" or "buys"
            stats[key] = (stats[key] or 0) + 1
            vendor:setData("tradeStats", stats)

            lia.log.add(string.format("Vendor trade - %s %s %s from %s",
                client:Name(), isSellingToVendor and "sold" or "bought", itemType, vendor:getNetVar("name", "Unknown")), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive trade tracking and analytics
        function MODULE:VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
            if not IsValid(client) or not IsValid(vendor) then return end

            local currentTime = os.time()
            local itemData = lia.item.get(itemType)
            if not itemData then return end

            -- Record trade details
            local tradeData = {
                timestamp = currentTime,
                player = client,
                vendor = vendor,
                itemType = itemType,
                itemName = itemData.name,
                isSelling = isSellingToVendor,
                price = MODULE.GetTradePrice(vendor, itemType, isSellingToVendor)
            }

            -- Update vendor trade statistics
            local stats = vendor:getData("tradeStats", {})
            local key = isSellingToVendor and "totalSells" or "totalBuys"
            stats[key] = (stats[key] or 0) + 1
            stats.lastTrade = currentTime
            vendor:setData("tradeStats", stats)

            -- Update player trade history
            local char = client:getChar()
            if char then
                local history = char:getData("tradeHistory", {})
                table.insert(history, tradeData)
                char:setData("tradeHistory", history)
            end

            lia.log.add(string.format("Vendor trade - Player: %s, Vendor: %s, Item: %s (%s), Action: %s, Price: %d",
                client:Name(), vendor:getNetVar("name", "Unknown"), itemData.name, itemType,
                isSellingToVendor and "sold" or "bought", tradeData.price), FLAG_NORMAL)

            MODULE.UpdateTradeAnalytics(tradeData)
        end
        ```
]]
function VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Called when warnings are issued.

    When Called:
        When admin warnings are given to players.

    Parameters:
        admin (Player)
            The issuing admin.
        target (Player)
            The warned player.
        reason (string)
            The warning reason.
        count (number)
            The warning count.
        warnerSteamID (string)
            The admin's SteamID.
        targetSteamID (string)
            The target's SteamID.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic warning logging
        function MODULE:WarningIssued(admin, target, reason, count, warnerSteamID, targetSteamID)
            lia.log.add(string.format("Warning issued: %s warned %s for %s", admin:Name(), target:Name(), reason), FLAG_WARNING)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update warning statistics
        function MODULE:WarningIssued(admin, target, reason, count, warnerSteamID, targetSteamID)
            if not IsValid(target) then return end

            local char = target:getChar()
            if char then
                char:setData("warnings", count)
                char:setData("lastWarning", os.time())
            end

            lia.log.add(string.format("Warning %d issued to %s by %s: %s", count, target:Name(), admin:Name(), reason), FLAG_WARNING)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive warning tracking and consequences
        function MODULE:WarningIssued(admin, target, reason, count, warnerSteamID, targetSteamID)
            if not IsValid(target) or not IsValid(admin) then return end

            local currentTime = os.time()
            local char = target:getChar()

            -- Record warning details
            local warningData = {
                admin = admin,
                adminSteamID = warnerSteamID,
                target = target,
                targetSteamID = targetSteamID,
                reason = reason,
                count = count,
                timestamp = currentTime
            }

            -- Update character warning data
            if char then
                local warnings = char:getData("warnings", 0)
                char:setData("warnings", count)
                char:setData("lastWarning", currentTime)
                char:setData("lastWarningReason", reason)
                char:setData("lastWarningAdmin", admin:Name())

                -- Track warning history
                local history = char:getData("warningHistory", {})
                table.insert(history, warningData)
                char:setData("warningHistory", history)
            end

            -- Log detailed warning
            lia.log.add(string.format("Warning issued - Admin: %s (%s), Target: %s (%s), Reason: %s, Count: %d, Time: %s",
                admin:Name(), warnerSteamID, target:Name(), targetSteamID, reason, count,
                os.date("%Y-%m-%d %H:%M:%S", currentTime)), FLAG_WARNING)

            -- Handle warning consequences
            MODULE.ApplyWarningConsequences(target, count, reason)

            -- Notify relevant parties
            MODULE.NotifyWarningIssued(admin, target, reason, count)

            -- Update warning statistics
            MODULE.UpdateWarningStats(admin, target, reason)

            -- Check for ban thresholds
            if MODULE.ShouldAutoBan(target, count) then
                MODULE.AutoBanPlayer(target, count, reason)
            end
        end
        ```
]]
function WarningIssued(admin, target, reason, count, warnerSteamID, targetSteamID)
end

--[[
    Purpose:
        Called when warnings are removed.

    When Called:
        When admin warnings are removed from players.

    Parameters:
        admin (Player)
            The removing admin.
        target (Player)
            The player whose warning was removed.
        warningData (table)
            The warning data.
        index (number)
            The warning index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log warning removal
        function MODULE:WarningRemoved(admin, target, warningData, index)
            print(admin:Name() .. " removed warning from " .. target:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Warning removal with notification
        function MODULE:WarningRemoved(admin, target, warningData, index)
            if not IsValid(admin) or not IsValid(target) then return end

            -- Notify target player
            target:notify("A warning has been removed from your record")

            -- Log removal
            lia.log.add(string.format(
                "%s removed warning #%d from %s",
                admin:Name(),
                index,
                target:Name()
            ), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced warning removal with validation and logging
        function MODULE:WarningRemoved(admin, target, warningData, index)
            if not IsValid(admin) or not IsValid(target) then return end
            if not warningData then return end

            -- Validate admin permissions
            if not admin:IsAdmin() and not admin:hasPrivilege("Remove Warnings") then
                lia.log.add(admin:Name() .. " attempted to remove warning without permission", FLAG_WARNING)
                return
            end

            -- Get character data
            local char = target:getChar()
            if not char then return end

            -- Update warning status in database
            lia.warning.remove(char:getID(), index)

            -- Notify target player
            target:notify("A warning has been removed from your record by " .. admin:Name())

            -- Send updated warning list to target
            local warnings = lia.warning.get(char:getID())
            net.Start("liaWarningUpdate")
            net.WriteTable(warnings)
            net.Send(target)

            -- Log comprehensive removal
            lia.log.add(string.format(
                "%s (%s) removed warning #%d from %s (%s) - Reason: %s",
                admin:Name(),
                admin:SteamID(),
                index,
                target:Name(),
                target:SteamID(),
                warningData.reason or "Unknown"
            ), FLAG_NORMAL)

            -- Update warning statistics
            self:UpdateWarningStatistics(char:getID())

            -- Trigger post-removal hook
            hook.Run("OnWarningRemoved", admin, target, warningData, index)
        end
        ```
]]
function WarningRemoved(admin, target, warningData, index)
end

--[[
    Purpose:
        Called when the database connection is established.

    When Called:
        When the server successfully connects to the database.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log database connection
        function MODULE:DatabaseConnected()
            print("Database connected successfully!")
            lia.log.add("Database connection established", FLAG_NORMAL)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize database-dependent systems
        function MODULE:DatabaseConnected()
            lia.log.add("Database connected - initializing systems", FLAG_NORMAL)

            -- Load server configuration from database
            self:LoadServerConfig()

            -- Initialize player data tables
            self:InitializePlayerTables()

            -- Set up data synchronization
            self:SetupDataSync()

            -- Notify administrators
            for _, client in player.Iterator() do
                if client:IsAdmin() then
                    client:ChatPrint("Database connection established")
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive database initialization and validation
        function MODULE:DatabaseConnected()
            lia.log.add("Database connection established - performing initialization", FLAG_NORMAL)

            -- Validate database schema
            self:ValidateDatabaseSchema()

            -- Run database migrations if needed
            self:RunDatabaseMigrations()

            -- Initialize core data tables
            self:InitializeCoreTables()

            -- Load server configuration and settings
            self:LoadServerConfiguration()

            -- Set up automated data backups
            self:SetupAutomatedBackups()

            -- Initialize player statistics tracking
            self:InitializeStatisticsTracking()

            -- Set up data integrity checks
            self:SetupDataIntegrityChecks()

            -- Initialize cross-server data synchronization
            self:InitializeCrossServerSync()

            -- Load and validate item data
            self:LoadAndValidateItemData()

            -- Set up performance monitoring
            self:SetupDatabasePerformanceMonitoring()

            -- Send initialization complete notification
            timer.Simple(1, function()
                lia.log.add("Database initialization completed successfully", FLAG_NORMAL)

                -- Notify all connected players
                net.Start("DatabaseReady")
                net.Broadcast()
            end)

            -- Schedule regular maintenance tasks
            self:ScheduleMaintenanceTasks()

            -- Initialize admin logging system
            self:InitializeAdminLogging()
        end

        -- Helper function to validate database schema
        function MODULE:ValidateDatabaseSchema()
            -- Check for required tables
            local requiredTables = {
                "characters", "players", "items", "inventories"
            }

            for _, tableName in ipairs(requiredTables) do
                if not self:TableExists(tableName) then
                    lia.log.add("Missing required table: " .. tableName, FLAG_ERROR)
                    -- Attempt to create missing tables
                    self:CreateMissingTable(tableName)
                end
            end
        end

        -- Helper function to run migrations
        function MODULE:RunDatabaseMigrations()
            local currentVersion = self:GetDatabaseVersion()
            local latestVersion = self:GetLatestMigrationVersion()

            if currentVersion < latestVersion then
                lia.log.add("Running database migrations from v" .. currentVersion .. " to v" .. latestVersion, FLAG_NORMAL)

                for version = currentVersion + 1, latestVersion do
                    self:RunMigration(version)
                end

                self:UpdateDatabaseVersion(latestVersion)
            end
        end
        ```
]]
function DatabaseConnected()
end

--[[
    Purpose:
        Called to set persistent data for a module

    When Called:
        When storing module data that should persist across server restarts

    Parameters:
        value (any)
            The data value to store
        global (boolean, optional)
            If true, store data globally across all gamemodes and maps
        ignoreMap (boolean, optional)
            If true, store data for all maps in the current gamemode

    Returns:
        None

    Realm:
        Server

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Store basic module data
    function MODULE:setData(value, global, ignoreMap)
        -- Default behavior stores data for current gamemode and map
        lia.data.set(self.uniqueID, value, global, ignoreMap)
    end
    ```

    Medium Complexity:

    ```lua
    -- Medium: Store data with validation
    function MODULE:setData(value, global, ignoreMap)
        -- Validate data before storing
        if type(value) ~= "table" then
            print("Warning: Module data should be a table")
            return
        end

        -- Store with custom scoping
        lia.data.set(self.uniqueID, value, global, ignoreMap)

        -- Log data change
        lia.log.add("Module " .. self.uniqueID .. " data updated", FLAG_NORMAL)
    end
    ```

    High Complexity:

    ```lua
    -- High: Complex data storage with backup and validation
    function MODULE:setData(value, global, ignoreMap)
        -- Validate data structure
        if not istable(value) then
            print("Error: Module data must be a table")
            return
        end

        -- Create backup of current data
        local currentData = self:getData({})
        if table.Count(currentData) > 0 then
            local backupKey = self.uniqueID .. "_backup_" .. os.time()
            lia.data.set(backupKey, currentData, global, ignoreMap)
        end

        -- Validate required fields
        if value.requiredField == nil then
            print("Warning: Required field missing, using default")
            value.requiredField = "default"
        end

        -- Store validated data
        lia.data.set(self.uniqueID, value, global, ignoreMap)

        -- Notify dependent modules
        hook.Run("ModuleDataChanged", self.uniqueID, value)

        -- Log detailed change
        lia.log.add(string.format(
            "Module %s data updated (Global: %s, IgnoreMap: %s)",
            self.uniqueID,
            tostring(global or false),
            tostring(ignoreMap or false)
        ), FLAG_NORMAL)
    end
    ```
]]
function setData(value, global, ignoreMap)
end
