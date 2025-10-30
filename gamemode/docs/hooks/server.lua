--[[
    Server-Side Hooks

    Server-side hook system for the Lilia framework.
    These hooks run on the server and are used for game logic, data management, and server-side processing.
]]
--[[
    Overview:
        Server-side hooks in the Lilia framework handle game logic, data persistence, player management, and other server-specific functionality. All server hooks follow the standard Garry's Mod hook system and can be overridden or extended by addons and modules.
]]
--[[
    Purpose:
        Adds a warning to a character's record in the administration system
    When Called:
        When an admin issues a warning to a player
    Parameters:
        charID (number) - The character ID of the warned player
        warned (string) - The name of the warned player
        warnedSteamID (string) - The Steam ID of the warned player
        timestamp (number) - Unix timestamp when the warning was issued
        message (string) - The warning message/reason
        warner (string) - The name of the admin who issued the warning
        warnerSteamID (string) - The Steam ID of the admin who issued the warning
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a basic warning
    hook.Run("AddWarning", charID, playerName, steamID, os.time(), "Rule violation", adminName, adminSteamID)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add warning with custom message
    local reason = "Excessive RDM - 3 kills in 5 minutes"
    local timestamp = os.time()
    hook.Run("AddWarning", target:getChar():getID(), target:Nick(), target:SteamID(),
    timestamp, reason, client:Nick(), client:SteamID())
    ```

    High Complexity:

    ```lua
    -- High: Add warning with validation and logging
    hook.Add("AddWarning", "MyAddon", function(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
        -- Log the warning to a custom system
        print(string.format("Warning issued: %s warned %s for: %s", warner, warned, message))

        -- Send notification to other admins
        for _, admin in ipairs(player.GetAll()) do
            if admin:IsAdmin() then
                admin:ChatPrint(string.format("[WARNING] %s warned %s: %s", warner, warned, message))
            end
        end

        -- Check for warning limits
        local warnings = hook.Run("GetWarnings", charID)
        if #warnings >= 3 then
            -- Auto-kick after 3 warnings
            local target = player.GetBySteamID(warnedSteamID)
            if IsValid(target) then
                target:Kick("Too many warnings")
            end
        end
    end)
    ```
]]
function AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
end

--[[
    Purpose:
        Allows modification of character creation data before the character is created
    When Called:
        During character creation process, before the character is saved to database
    Parameters:
        client (Player) - The player creating the character
        data (table) - The current character data being created
        newData (table) - Additional data to be merged with the character data
        originalData (table) - The original character data before any modifications
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add default money to new characters
    hook.Add("AdjustCreationData", "MyAddon", function(client, data, newData, originalData)
        data.money = data.money + 1000 -- Give extra starting money
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify character based on faction
    hook.Add("AdjustCreationData", "FactionBonuses", function(client, data, newData, originalData)
        if data.faction == "police" then
            data.money = data.money + 500 -- Police get extra money
            data.desc = data.desc .. "\n\n[Police Officer]"
            elseif data.faction == "citizen" then
                data.money = data.money + 200 -- Citizens get small bonus
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation system with validation
    hook.Add("AdjustCreationData", "AdvancedCreation", function(client, data, newData, originalData)
        -- Validate character name
        if string.len(data.name) < 3 then
            data.name = data.name .. " Jr."
        end

        -- Add faction-specific bonuses
        local factionBonuses = {
        ["police"] = {money = 1000, items = {"weapon_pistol"}},
            ["medic"] = {money = 800, items = {"medkit"}},
                ["citizen"] = {money = 200, items = {}}
                }

                local bonus = factionBonuses[data.faction]
                if bonus then
                    data.money = data.money + bonus.money
                    data.startingItems = data.startingItems or {}
                        for _, item in ipairs(bonus.items) do
                            table.insert(data.startingItems, item)
                        end
                    end

                    -- Add creation timestamp
                    data.creationTime = os.time()
                    data.creationIP = client:IPAddress()
                end)
    ```
]]
function AdjustCreationData(client, data, newData, originalData)
end

--[[
    Purpose:
        Called when a bag item's inventory is ready and accessible
    When Called:
        When a bag item's inventory is created or restored from database
    Parameters:
        self (Item) - The bag item instance
        inventory (Inventory) - The inventory instance that was created/loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log when bag inventory is ready
    hook.Add("BagInventoryReady", "MyAddon", function(self, inventory)
        print("Bag inventory ready for item: " .. self.uniqueID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add special items to bag inventory
    hook.Add("BagInventoryReady", "SpecialBags", function(self, inventory)
        if self.uniqueID == "magic_bag" then
            -- Add a magic item to the bag
            local magicItem = lia.item.instance("magic_crystal")
            if magicItem then
                inventory:add(magicItem)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bag inventory system with validation
    hook.Add("BagInventoryReady", "AdvancedBags", function(self, inventory)
        local char = self:getOwner()
        if not char then return end

            -- Set up faction-specific bag contents
            local faction = char:getFaction()
            local bagContents = {
            ["police"] = {
                {item = "handcuffs", quantity = 1},
                    {item = "police_badge", quantity = 1},
                        {item = "radio", quantity = 1}
                            },
                            ["medic"] = {
                                {item = "medkit", quantity = 2},
                                    {item = "bandage", quantity = 5},
                                        {item = "stethoscope", quantity = 1}
                                            },
                                            ["citizen"] = {
                                                {item = "wallet", quantity = 1},
                                                    {item = "phone", quantity = 1}
                                                    }
                                                }

                                                local contents = bagContents[faction]
                                                if contents then
                                                    for _, content in ipairs(contents) do
                                                        local item = lia.item.instance(content.item)
                                                        if item then
                                                            item:setData("quantity", content.quantity)
                                                            inventory:add(item)
                                                        end
                                                    end
                                                end

                                                -- Set up access rules based on character data
                                                local charLevel = char:getData("level", 1)
                                                if charLevel >= 10 then
                                                    -- High level characters get extra space
                                                    inventory:setData("maxWeight", inventory:getData("maxWeight", 100) * 1.5)
                                                end

                                                -- Log the bag creation
                                                print(string.format("Bag inventory created for %s (Level %d, Faction: %s)",
                                                char:getName(), charLevel, faction))
                                            end)
    ```
]]
function BagInventoryReady(self, inventory)
end

--[[
    Purpose:
        Called when a bag item's inventory is removed or destroyed
    When Called:
        When a bag item is deleted or its inventory is cleaned up
    Parameters:
        self (Item) - The bag item instance
        inv (Inventory) - The inventory instance that was removed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log when bag inventory is removed
    hook.Add("BagInventoryRemoved", "MyAddon", function(self, inv)
        print("Bag inventory removed for item: " .. self.uniqueID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up custom data when bag is removed
    hook.Add("BagInventoryRemoved", "CleanupBags", function(self, inv)
        local char = self:getOwner()
        if char then
            char:setData("bagCount", (char:getData("bagCount", 0) - 1))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex cleanup with item recovery
    hook.Add("BagInventoryRemoved", "AdvancedCleanup", function(self, inv)
        local char = self:getOwner()
        if not char then return end

            -- Check if bag had valuable items
            local valuableItems = {}
            for _, item in pairs(inv:getItems()) do
                if item.uniqueID == "gold_bar" or item.uniqueID == "diamond" then
                    table.insert(valuableItems, item)
                end
            end

            -- Transfer valuable items to character inventory
            if #valuableItems > 0 then
                local charInv = char:getInv()
                for _, item in ipairs(valuableItems) do
                    charInv:add(item)
                end
                char:getPlayer():ChatPrint("Valuable items recovered from destroyed bag!")
            end
        end)
    ```
]]
function BagInventoryRemoved(self, inv)
end

--[[
    Purpose:
        Determines if a character can be transferred to a different faction
    When Called:
        When attempting to transfer a character to another faction
    Parameters:
        targetChar (Character) - The character being transferred
        faction (string) - The target faction name
        client (Player) - The player requesting the transfer
    Returns:
        boolean - True if transfer is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all transfers
    hook.Add("CanBeTransfered", "MyAddon", function(targetChar, faction, client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction restrictions
    hook.Add("CanBeTransfered", "FactionRestrictions", function(targetChar, faction, client)
        local currentFaction = targetChar:getFaction()
        if currentFaction == "police" and faction == "criminal" then
            return false -- Police can't become criminals
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer validation system
    hook.Add("CanBeTransfered", "AdvancedTransfers", function(targetChar, faction, client)
        local charLevel = targetChar:getData("level", 1)
        local charMoney = targetChar:getMoney()

        -- Check level requirements
        local factionRequirements = {
        ["police"] = 5,
        ["medic"] = 3,
        ["mayor"] = 10
    }

    local requiredLevel = factionRequirements[faction]
    if requiredLevel and charLevel < requiredLevel then
        client:ChatPrint("You need to be level " .. requiredLevel .. " to join " .. faction)
        return false
    end

    -- Check money requirements
    local transferCost = 1000
    if charMoney < transferCost then
        client:ChatPrint("You need $" .. transferCost .. " to transfer factions")
        return false
    end

    -- Check cooldown
    local lastTransfer = targetChar:getData("lastFactionTransfer", 0)
    if os.time() - lastTransfer < 3600 then -- 1 hour cooldown
        client:ChatPrint("You must wait before transferring factions again")
        return false
    end

    return true
    end)
    ```
]]
function CanBeTransfered(targetChar, faction, client)
end

--[[
    Purpose:
        Determines if a character can be transferred (alias for CanBeTransfered)
    When Called:
        When attempting to transfer a character to another faction
    Parameters:
        targetChar (Character) - The character being transferred
        faction (string) - The target faction name
        client (Player) - The player requesting the transfer
    Returns:
        boolean - True if transfer is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Use same logic as CanBeTransfered
    hook.Add("CanCharBeTransfered", "MyAddon", function(targetChar, faction, client)
        return hook.Run("CanBeTransfered", targetChar, faction, client)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add additional character-specific checks
    hook.Add("CanCharBeTransfered", "CharChecks", function(targetChar, faction, client)
        -- Check if character is banned
        if targetChar:isBanned() then
            return false
        end

        -- Check character age
        local charAge = targetChar:getData("age", 18)
        if faction == "police" and charAge < 21 then
            return false -- Must be 21+ to be police
        end

        return hook.Run("CanBeTransfered", targetChar, faction, client)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Advanced character transfer system
    hook.Add("CanCharBeTransfered", "AdvancedCharTransfers", function(targetChar, faction, client)
        local charData = targetChar:getData()

        -- Check character reputation
        local reputation = charData.reputation or 0
        if faction == "police" and reputation < 50 then
            client:ChatPrint("You need a good reputation to join the police")
            return false
        end

        -- Check for outstanding warrants
        if charData.warrants and #charData.warrants > 0 then
            client:ChatPrint("You have outstanding warrants and cannot transfer")
            return false
        end

        -- Check faction capacity
        local factionCount = 0
        for _, char in pairs(lia.char.getCharacters()) do
            if char:getFaction() == faction then
                factionCount = factionCount + 1
            end
        end

        local maxFactionMembers = {
        ["police"] = 10,
        ["medic"] = 5,
        ["mayor"] = 1
    }

    local maxMembers = maxFactionMembers[faction]
    if maxMembers and factionCount >= maxMembers then
        client:ChatPrint("That faction is full")
        return false
    end

    return hook.Run("CanBeTransfered", targetChar, faction, client)
    end)
    ```
]]
function CanCharBeTransfered(targetChar, faction, client)
end

--[[
    Purpose:
        Determines if a character can be deleted
    When Called:
        When a player attempts to delete a character
    Parameters:
        client (Player) - The player requesting the deletion
        character (Character) - The character to be deleted
    Returns:
        boolean - True if deletion is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all character deletions
    hook.Add("CanDeleteChar", "MyAddon", function(client, character)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Prevent deletion of high-level characters
    hook.Add("CanDeleteChar", "LevelRestrictions", function(client, character)
        local charLevel = character:getData("level", 1)
        if charLevel > 10 then
            client:ChatPrint("You cannot delete characters above level 10")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex deletion validation system
    hook.Add("CanDeleteChar", "AdvancedDeletion", function(client, character)
        local charMoney = character:getMoney()
        local charLevel = character:getData("level", 1)

        -- Check if character has valuable items
        local hasValuables = false
        local charInv = character:getInv()
        for _, item in pairs(charInv:getItems()) do
            if item.uniqueID == "gold_bar" or item.uniqueID == "diamond" then
                hasValuables = true
                break
            end
        end

        if hasValuables then
            client:ChatPrint("You must remove all valuable items before deleting this character")
            return false
        end

        -- Check if character is in a faction
        local faction = character:getFaction()
        if faction ~= "citizen" then
            client:ChatPrint("You must leave your faction before deleting this character")
            return false
        end

        -- Check cooldown
        local lastDeletion = client:getData("lastCharDeletion", 0)
        if os.time() - lastDeletion < 86400 then -- 24 hour cooldown
            client:ChatPrint("You must wait 24 hours before deleting another character")
            return false
        end

        return true
    end)
    ```
]]
function CanDeleteChar(client, character)
end

--[[
    Purpose:
        Determines if a player can invite another player to a class
    When Called:
        When attempting to invite a player to join a class
    Parameters:
        client (Player) - The player sending the invitation
        target (Player) - The player being invited
    Returns:
        boolean - True if invitation is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all class invitations
    hook.Add("CanInviteToClass", "MyAddon", function(client, target)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if players are in same faction
    hook.Add("CanInviteToClass", "FactionRestrictions", function(client, target)
        local clientChar = client:getChar()
        local targetChar = target:getChar()

        if not clientChar or not targetChar then return false end

            if clientChar:getFaction() ~= targetChar:getFaction() then
                client:ChatPrint("You can only invite players from your faction")
                return false
            end

            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class invitation system
    hook.Add("CanInviteToClass", "AdvancedInvitations", function(client, target)
        local clientChar = client:getChar()
        local targetChar = target:getChar()

        if not clientChar or not targetChar then return false end

            -- Check if client has permission to invite
            if not clientChar:hasFlags("C") then
                client:ChatPrint("You don't have permission to invite players to classes")
                return false
            end

            -- Check if target is already in a class
            local targetClass = targetChar:getClass()
            if targetClass and targetClass ~= "" then
                client:ChatPrint("That player is already in a class")
                return false
            end

            -- Check faction compatibility
            if clientChar:getFaction() ~= targetChar:getFaction() then
                client:ChatPrint("You can only invite players from your faction")
                return false
            end

            -- Check level requirements
            local clientLevel = clientChar:getData("level", 1)
            local targetLevel = targetChar:getData("level", 1)
            if targetLevel < clientLevel - 5 then
                client:ChatPrint("That player is too low level to join your class")
                return false
            end

            return true
        end)
    ```
]]
--[[
    Purpose:
        Called to check if a player can invite another to a class
    When Called:
        When attempting to invite a player to a class
    Parameters:
        client (Player) - The player attempting the invite
        target (Player) - The player being invited
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow admins only
    hook.Add("CanInviteToClass", "MyAddon", function(client, target)
        return client:IsAdmin()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction and rank
    hook.Add("CanInviteToClass", "ClassInviteCheck", function(client, target)
        local char = client:getChar()
        if not char then return false end

            local rank = char:getData("rank", 0)
            return rank >= 3
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class invitation system
    hook.Add("CanInviteToClass", "AdvancedClassInvite", function(client, target)
        local char = client:getChar()
        local targetChar = target:getChar()
        if not char or not targetChar then return false end

            -- Check if client has permission
            local rank = char:getData("rank", 0)
            if rank < 3 then
                client:ChatPrint("You need rank 3 or higher to invite players")
                return false
            end

            -- Check if target is in same faction
            if char:getFaction() ~= targetChar:getFaction() then
                client:ChatPrint("Target must be in your faction")
                return false
            end

            -- Check cooldown
            local lastInvite = char:getData("lastClassInvite", 0)
            if os.time() - lastInvite < 60 then
                client:ChatPrint("Please wait before inviting again")
                return false
            end

            char:setData("lastClassInvite", os.time())
            return true
        end)
    ```
]]
function CanInviteToClass(client, target)
end

--[[
    Purpose:
        Called to check if a player can invite another to a faction
    When Called:
        When attempting to invite a player to a faction
    Parameters:
        client (Player) - The player attempting the invite
        target (Player) - The player being invited
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow admins only
    hook.Add("CanInviteToFaction", "MyAddon", function(client, target)
        return client:IsAdmin()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction leader status
    hook.Add("CanInviteToFaction", "FactionInviteCheck", function(client, target)
        local char = client:getChar()
        if not char then return false end

            return char:getData("factionLeader", false)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex faction invitation system
    hook.Add("CanInviteToFaction", "AdvancedFactionInvite", function(client, target)
        local char = client:getChar()
        local targetChar = target:getChar()
        if not char or not targetChar then return false end

            -- Check if client is faction leader
            if not char:getData("factionLeader", false) then
                client:ChatPrint("Only faction leaders can invite players")
                return false
            end

            -- Check faction member limit
            local faction = char:getFaction()
            local memberCount = 0
            for _, ply in ipairs(player.GetAll()) do
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == faction then
                    memberCount = memberCount + 1
                end
            end

            local maxMembers = 20
            if memberCount >= maxMembers then
                client:ChatPrint("Faction is at maximum capacity")
                return false
            end

            -- Check cooldown
            local lastInvite = char:getData("lastFactionInvite", 0)
            if os.time() - lastInvite < 120 then
                client:ChatPrint("Please wait before inviting again")
                return false
            end

            char:setData("lastFactionInvite", os.time())
            return true
        end)
    ```
]]
function CanInviteToFaction(client, target)
end

--[[
    Purpose:
        Determines if an item can be transferred between inventories
    When Called:
        When attempting to move an item from one inventory to another
    Parameters:
        item (Item) - The item being transferred
        fromInventory (Inventory) - The source inventory
        toInventory (Inventory) - The destination inventory
        client (Player) - The player performing the transfer
    Returns:
        boolean - True if transfer is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item transfers
    hook.Add("CanItemBeTransfered", "MyAddon", function(item, fromInventory, toInventory, client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Prevent transfer of certain items
    hook.Add("CanItemBeTransfered", "ItemRestrictions", function(item, fromInventory, toInventory, client)
        local restrictedItems = {"admin_weapon", "god_mode_item"}
        if table.HasValue(restrictedItems, item.uniqueID) then
            client:ChatPrint("This item cannot be transferred")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer validation system
    hook.Add("CanItemBeTransfered", "AdvancedTransfers", function(item, fromInventory, toInventory, client)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is bound to character
            if item:getData("boundTo", "") == char:getID() then
                client:ChatPrint("This item is bound to you and cannot be transferred")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("factionRestriction")
            if itemFaction then
                local targetChar = toInventory:getOwner()
                if targetChar and targetChar:getFaction() ~= itemFaction then
                    client:ChatPrint("This item can only be given to " .. itemFaction .. " members")
                    return false
                end
            end

            -- Check weight limits
            local itemWeight = item:getData("weight", 1)
            local targetWeight = toInventory:getData("weight", 0)
            local maxWeight = toInventory:getData("maxWeight", 100)
            if targetWeight + itemWeight > maxWeight then
                client:ChatPrint("The destination inventory is too heavy")
                return false
            end

            -- Check if target inventory is locked
            if toInventory:getData("locked", false) then
                client:ChatPrint("The destination inventory is locked")
                return false
            end

            return true
        end)
    ```
]]
--[[
    Purpose:
        Called to check if an item can be transferred between inventories
    When Called:
        When attempting to move an item from one inventory to another
    Parameters:
        item (Item) - The item being transferred
        fromInventory (Inventory) - The source inventory
        toInventory (Inventory) - The destination inventory
        client (Player) - The player performing the transfer
    Returns:
        boolean - True if transfer is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all transfers
    hook.Add("CanItemBeTransfered", "MyAddon", function(item, fromInventory, toInventory, client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check inventory types
    hook.Add("CanItemBeTransfered", "InventoryTypeCheck", function(item, fromInventory, toInventory, client)
        -- Prevent transferring to vendor inventories
        if toInventory.isVendor then
            return false
        end

        -- Check if item is transferable
        if item:getData("noTransfer", false) then
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer validation system
    hook.Add("CanItemBeTransfered", "AdvancedTransferValidation", function(item, fromInventory, toInventory, client)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is transferable
            if item:getData("noTransfer", false) then
                client:ChatPrint("This item cannot be transferred")
                return false
            end

            -- Check inventory types
            if toInventory.isVendor then
                client:ChatPrint("Cannot transfer items to vendor inventories")
                return false
            end

            -- Check weight limits
            local itemWeight = item:getWeight()
            local currentWeight = toInventory:getWeight()
            local maxWeight = toInventory:getMaxWeight()

            if currentWeight + itemWeight > maxWeight then
                client:ChatPrint("Not enough space in destination inventory")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction then
                local charFaction = char:getFaction()
                if itemFaction ~= charFaction then
                    client:ChatPrint("You cannot transfer faction-restricted items")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to transfer this item")
                return false
            end

            -- Check if item is equipped
            if item:getData("equipped", false) then
                client:ChatPrint("Cannot transfer equipped items")
                return false
            end

            -- Check for special item restrictions
            if item.uniqueID == "weapon_pistol" then
                -- Special handling for weapons
                if not char:hasFlags("w") then
                    client:ChatPrint("You need weapon flags to transfer weapons")
                    return false
                end
            end

            return true
        end)
    ```
]]
function CanItemBeTransfered(item, fromInventory, toInventory, client)
end

--[[
    Purpose:
        Called to check if a player can edit a vendor
    When Called:
        When attempting to modify vendor settings
    Parameters:
        self (Entity) - The vendor entity
        vendor (table) - The vendor data table
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow admins only
    hook.Add("CanPerformVendorEdit", "MyAddon", function(self, vendor)
        local client = self.activator
        return client and client:IsAdmin()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check vendor ownership
    hook.Add("CanPerformVendorEdit", "VendorEditCheck", function(self, vendor)
        local client = self.activator
        if not client then return false end

            local char = client:getChar()
            if not char then return false end

                local owner = vendor.owner
                return owner == char:getID() or client:IsAdmin()
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor editing system
    hook.Add("CanPerformVendorEdit", "AdvancedVendorEdit", function(self, vendor)
        local client = self.activator
        if not client then return false end

            local char = client:getChar()
            if not char then return false end

                -- Admins can always edit
                if client:IsAdmin() then return true end

                    -- Check vendor ownership
                    local owner = vendor.owner
                    if owner ~= char:getID() then
                        client:ChatPrint("You don't own this vendor")
                        return false
                    end

                    -- Check edit cooldown
                    local lastEdit = char:getData("lastVendorEdit", 0)
                    if os.time() - lastEdit < 30 then
                        client:ChatPrint("Please wait before editing again")
                        return false
                    end

                    char:setData("lastVendorEdit", os.time())
                    return true
                end)
    ```
]]
function CanPerformVendorEdit(self, vendor)
end

--[[
    Purpose:
        Called to check if an entity can be persisted
    When Called:
        When determining if an entity should be saved across map changes
    Parameters:
        entity (Entity) - The entity to check
    Returns:
        boolean - True to persist, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Persist all props
    hook.Add("CanPersistEntity", "MyAddon", function(entity)
        return entity:GetClass() == "prop_physics"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Persist specific entities
    hook.Add("CanPersistEntity", "EntityPersistCheck", function(entity)
        local persistClasses = {
        ["prop_physics"] = true,
        ["prop_dynamic"] = true,
        ["lia_item"] = true
    }

    return persistClasses[entity:GetClass()] or false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity persistence system
    hook.Add("CanPersistEntity", "AdvancedEntityPersist", function(entity)
        if not IsValid(entity) then return false end

            -- Check entity class
            local persistClasses = {
            ["prop_physics"] = true,
            ["prop_dynamic"] = true,
            ["lia_item"] = true,
            ["lia_vendor"] = true
        }

        if not persistClasses[entity:GetClass()] then
            return false
        end

        -- Check if entity is marked as temporary
        if entity:getNetVar("temporary", false) then
            return false
        end

        -- Check entity age
        local spawnTime = entity:getNetVar("spawnTime", 0)
        if os.time() - spawnTime < 60 then
            return false
        end

        -- Check entity owner
        local owner = entity:getNetVar("owner")
        if owner then
            local ownerPly = player.GetBySteamID(owner)
            if not IsValid(ownerPly) then
                return false
            end
        end

        return true
    end)
    ```
]]
function CanPersistEntity(entity)
end

--[[
    Purpose:
        Called to check if money can be picked up
    When Called:
        When a player attempts to pick up money
    Parameters:
        activator (Player) - The player trying to pick up money
        self (Entity) - The money entity
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all money pickup
    hook.Add("CanPickupMoney", "MyAddon", function(activator, self)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check distance and amount
    hook.Add("CanPickupMoney", "CheckMoneyPickup", function(activator, self)
        local distance = activator:GetPos():Distance(self:GetPos())
        if distance > 100 then
            return false
        end

        local amount = self:getNetVar("amount", 0)
        if amount <= 0 then
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex money pickup system
    hook.Add("CanPickupMoney", "AdvancedMoneyPickup", function(activator, self)
        if not IsValid(activator) or not IsValid(self) then return false end

            local char = activator:getChar()
            if not char then return false end

                -- Check distance
                local distance = activator:GetPos():Distance(self:GetPos())
                if distance > 100 then
                    activator:ChatPrint("You are too far away to pick up the money")
                    return false
                end

                -- Check amount
                local amount = self:getNetVar("amount", 0)
                if amount <= 0 then
                    return false
                end

                -- Check if money is owned
                local owner = self:getNetVar("owner")
                if owner and owner ~= char:getID() then
                    local ownerChar = lia.char.loaded[owner]
                    if ownerChar and ownerChar:getData("alive", true) then
                        activator:ChatPrint("This money belongs to someone else")
                        return false
                    end
                end

                -- Check faction restrictions
                local faction = char:getFaction()
                if faction == "ghost" then
                    return false
                end

                -- Check if player is tied
                if char:getData("tied", false) then
                    activator:ChatPrint("You cannot pick up money while tied")
                    return false
                end

                return true
            end)
    ```
]]
function CanPickupMoney(activator, self)
end

--[[
    Purpose:
        Determines if a player can access a door with specific access level
    When Called:
        When a player attempts to use a door
    Parameters:
        client (Player) - The player attempting to access the door
        self (Entity) - The door entity
        access (string) - The access level being checked
    Returns:
        boolean - True if access is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all door access
    hook.Add("CanPlayerAccessDoor", "MyAddon", function(client, self, access)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if player has door key
    hook.Add("CanPlayerAccessDoor", "KeySystem", function(client, self, access)
        local char = client:getChar()
        if not char then return false end

            local doorData = self:getNetVar("doorData")
            if doorData and doorData.key then
                local charInv = char:getInv()
                for _, item in pairs(charInv:getItems()) do
                    if item.uniqueID == doorData.key then
                        return true
                    end
                end
                client:ChatPrint("You need a key to access this door")
                return false
            end

            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door access system
    hook.Add("CanPlayerAccessDoor", "AdvancedDoors", function(client, self, access)
        local char = client:getChar()
        if not char then return false end

            local doorData = self:getNetVar("doorData")
            if not doorData then return true end

                -- Check faction restrictions
                local allowedFactions = doorData.allowedFactions
                if allowedFactions then
                    local faction = char:getFaction()
                    if not table.HasValue(allowedFactions, faction) then
                        client:ChatPrint("Your faction cannot access this door")
                        return false
                    end
                end

                -- Check time restrictions
                local timeRestriction = doorData.timeRestriction
                if timeRestriction then
                    local currentHour = tonumber(os.date("%H"))
                    if currentHour < timeRestriction.start or currentHour > timeRestriction.end then
                        client:ChatPrint("This door is only accessible during " .. timeRestriction.start .. ":00-" .. timeRestriction.end .. ":00")
                        return false
                    end
                end

                -- Check key requirements
                if doorData.key then
                    local charInv = char:getInv()
                    local hasKey = false
                    for _, item in pairs(charInv:getItems()) do
                        if item.uniqueID == doorData.key then
                            hasKey = true
                            break
                        end
                    end
                    if not hasKey then
                        client:ChatPrint("You need a key to access this door")
                        return false
                    end
                end

                -- Check access level
                local requiredAccess = doorData.accessLevel or 1
                local charAccess = char:getData("accessLevel", 1)
                if charAccess < requiredAccess then
                    client:ChatPrint("You don't have sufficient access level for this door")
                    return false
                end

                return true
            end)
    ```
]]
--[[
    Purpose:
        Called to check if a player can access a door
    When Called:
        When a player attempts to interact with a door
    Parameters:
        client (Player) - The player attempting access
        self (Entity) - The door entity
        access (number) - The access level being checked
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all players
    hook.Add("CanPlayerAccessDoor", "MyAddon", function(client, self, access)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check door ownership
    hook.Add("CanPlayerAccessDoor", "DoorAccessCheck", function(client, self, access)
        local char = client:getChar()
        if not char then return false end

            local owner = self:getNetVar("owner")
            return owner == char:getID()
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door access system
    hook.Add("CanPlayerAccessDoor", "AdvancedDoorAccess", function(client, self, access)
        local char = client:getChar()
        if not char then return false end

            -- Admins can access all doors
            if client:IsAdmin() then return true end

                -- Check door ownership
                local owner = self:getNetVar("owner")
                if owner == char:getID() then return true end

                    -- Check faction access
                    local allowedFactions = self:getNetVar("allowedFactions", {})
                    if table.HasValue(allowedFactions, char:getFaction()) then
                        return true
                    end

                    -- Check if player has key
                    local doorID = self:getNetVar("doorID")
                    if doorID and char:getInv():hasItem("door_key_" .. doorID) then
                        return true
                    end

                    return false
                end)
    ```
]]
function CanPlayerAccessDoor(client, self, access)
end

--[[
    Purpose:
        Called to check if a player can access a vendor
    When Called:
        When a player attempts to interact with a vendor
    Parameters:
        activator (Player) - The player attempting access
        self (Entity) - The vendor entity
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all players
    hook.Add("CanPlayerAccessVendor", "MyAddon", function(activator, self)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction restrictions
    hook.Add("CanPlayerAccessVendor", "VendorAccessCheck", function(activator, self)
        local char = activator:getChar()
        if not char then return false end

            local allowedFactions = self:getNetVar("allowedFactions", {})
            if #allowedFactions > 0 and not table.HasValue(allowedFactions, char:getFaction()) then
                return false
            end

            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor access system
    hook.Add("CanPlayerAccessVendor", "AdvancedVendorAccess", function(activator, self)
        local char = activator:getChar()
        if not char then return false end

            -- Check faction restrictions
            local allowedFactions = self:getNetVar("allowedFactions", {})
            if #allowedFactions > 0 and not table.HasValue(allowedFactions, char:getFaction()) then
                activator:ChatPrint("Your faction cannot access this vendor")
                return false
            end

            -- Check level requirements
            local requiredLevel = self:getNetVar("requiredLevel", 0)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                activator:ChatPrint("You need to be level " .. requiredLevel .. " to access this vendor")
                return false
            end

            -- Check reputation
            local requiredRep = self:getNetVar("requiredReputation", 0)
            local charRep = char:getData("reputation", 0)
            if charRep < requiredRep then
                activator:ChatPrint("You need " .. requiredRep .. " reputation to access this vendor")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerAccessVendor(activator, self)
end

--[[
    Purpose:
        Called to check if a player can choose a weapon
    When Called:
        When a player attempts to select a weapon
    Parameters:
        weapon (Weapon) - The weapon being chosen
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all weapons
    hook.Add("CanPlayerChooseWeapon", "MyAddon", function(weapon)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Restrict specific weapons
    hook.Add("CanPlayerChooseWeapon", "RestrictWeapons", function(weapon)
        local restrictedWeapons = {"weapon_crowbar", "weapon_stunstick"}
        return not table.HasValue(restrictedWeapons, weapon:GetClass())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon selection system
    hook.Add("CanPlayerChooseWeapon", "AdvancedWeaponSelection", function(weapon)
        local client = weapon:GetOwner()
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check faction restrictions
                local faction = char:getFaction()
                local weaponClass = weapon:GetClass()

                if faction == "police" then
                    local policeWeapons = {"weapon_pistol", "weapon_stunstick"}
                    return table.HasValue(policeWeapons, weaponClass)
                    elseif faction == "medic" then
                        local medicWeapons = {"weapon_medkit", "weapon_stunstick"}
                        return table.HasValue(medicWeapons, weaponClass)
                    end

                    -- Check level requirements
                    local requiredLevel = weapon:getData("requiredLevel", 1)
                    local charLevel = char:getData("level", 1)
                    if charLevel < requiredLevel then
                        return false
                    end

                    -- Check if weapon is broken
                    local durability = weapon:getData("durability", 100)
                    if durability <= 0 then
                        return false
                    end

                    return true
                end)
    ```
]]
function CanPlayerChooseWeapon(weapon)
end

--[[
    Purpose:
        Determines if a player can create a new character
    When Called:
        When a player attempts to create a new character
    Parameters:
        client (Player) - The player creating the character
        data (table) - The character creation data
    Returns:
        boolean - True if creation is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all character creation
    hook.Add("CanPlayerCreateChar", "MyAddon", function(client, data)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check character limit
    hook.Add("CanPlayerCreateChar", "CharLimit", function(client, data)
        local charCount = #client.liaCharList or 0
        local maxChars = hook.Run("GetMaxPlayerChar", client) or 5

        if charCount >= maxChars then
            client:ChatPrint("You have reached the maximum number of characters")
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation validation
    hook.Add("CanPlayerCreateChar", "AdvancedCreation", function(client, data)
        -- Check if player is banned
        if client:IsBanned() then
            client:ChatPrint("You are banned and cannot create characters")
            return false
        end

        -- Check character name validity
        local name = data.name or ""
        if string.len(name) < 3 then
            client:ChatPrint("Character name must be at least 3 characters long")
            return false
        end

        if string.len(name) > 32 then
            client:ChatPrint("Character name must be less than 32 characters")
            return false
        end

        -- Check for inappropriate names
        local bannedWords = {"admin", "moderator", "staff", "test"}
        for _, word in ipairs(bannedWords) do
            if string.find(string.lower(name), string.lower(word)) then
                client:ChatPrint("That name is not allowed")
                return false
            end
        end

        -- Check faction restrictions
        local faction = data.faction
        local playerLevel = client:getData("level", 1)
        local factionRequirements = {
        ["police"] = 5,
        ["medic"] = 3,
        ["mayor"] = 10
    }

    local requiredLevel = factionRequirements[faction]
    if requiredLevel and playerLevel < requiredLevel then
        client:ChatPrint("You need to be level " .. requiredLevel .. " to create a " .. faction .. " character")
        return false
    end

    -- Check character count
    local charCount = #client.liaCharList or 0
    local maxChars = hook.Run("GetMaxPlayerChar", client) or 5
    if charCount >= maxChars then
        client:ChatPrint("You have reached the maximum number of characters")
        return false
    end

    return true
    end)
    ```
]]
function CanPlayerCreateChar(client, data)
end

--[[
    Purpose:
        Determines if a player can drop an item
    When Called:
        When a player attempts to drop an item from their inventory
    Parameters:
        client (Player) - The player dropping the item
        item (Item) - The item being dropped
    Returns:
        boolean - True if dropping is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item drops
    hook.Add("CanPlayerDropItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Prevent dropping of certain items
    hook.Add("CanPlayerDropItem", "ItemRestrictions", function(client, item)
        local restrictedItems = {"admin_weapon", "god_mode_item"}
        if table.HasValue(restrictedItems, item.uniqueID) then
            client:ChatPrint("You cannot drop this item")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item drop validation
    hook.Add("CanPlayerDropItem", "AdvancedDrops", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is bound
            if item:getData("bound", false) then
                client:ChatPrint("This item is bound to you and cannot be dropped")
                return false
            end

            -- Check if player is in a safe zone
            local pos = client:GetPos()
            local safeZones = {
            {pos = Vector(0, 0, 0), radius = 500}, -- Spawn area
                {pos = Vector(1000, 1000, 0), radius = 200} -- Bank area
                }

                for _, zone in ipairs(safeZones) do
                    if pos:Distance(zone.pos) < zone.radius then
                        client:ChatPrint("You cannot drop items in safe zones")
                        return false
                    end
                end

                -- Check item value
                local itemValue = item:getData("value", 0)
                if itemValue > 1000 then
                    local charMoney = char:getMoney()
                    if charMoney < itemValue * 0.1 then -- 10% deposit
                        client:ChatPrint("You need $" .. (itemValue * 0.1) .. " to drop this valuable item")
                        return false
                    end
                end

                -- Check faction restrictions
                local faction = char:getFaction()
                if faction == "police" and item.uniqueID == "illegal_item" then
                    client:ChatPrint("Police cannot drop illegal items")
                    return false
                end

                return true
            end)
    ```
]]
--[[
    Purpose:
        Called to check if a player can drop an item
    When Called:
        When a player attempts to drop an item
    Parameters:
        client (Player) - The player attempting to drop the item
        item (Item) - The item being dropped
    Returns:
        boolean - True if dropping is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item drops
    hook.Add("CanPlayerDropItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check item restrictions
    hook.Add("CanPlayerDropItem", "ItemDropCheck", function(client, item)
        -- Prevent dropping important items
        if item:getData("noDrop", false) then
            client:ChatPrint("This item cannot be dropped")
            return false
        end

        -- Check if item is equipped
        if item:getData("equipped", false) then
            client:ChatPrint("Cannot drop equipped items")
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item drop validation system
    hook.Add("CanPlayerDropItem", "AdvancedDropValidation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is droppable
            if item:getData("noDrop", false) then
                client:ChatPrint("This item cannot be dropped")
                return false
            end

            -- Check if item is equipped
            if item:getData("equipped", false) then
                client:ChatPrint("Cannot drop equipped items")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction then
                local charFaction = char:getFaction()
                if itemFaction ~= charFaction then
                    client:ChatPrint("You cannot drop faction-restricted items")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to drop this item")
                return false
            end

            -- Check for special item restrictions
            if item.uniqueID == "weapon_pistol" then
                -- Special handling for weapons
                if not char:hasFlags("w") then
                    client:ChatPrint("You need weapon flags to drop weapons")
                    return false
                end
                elseif item.uniqueID == "money" then
                    -- Special handling for money
                    local amount = item:getData("amount", 0)
                    if amount > 1000 then
                        client:ChatPrint("Cannot drop more than $1000 at once")
                        return false
                    end
                end

                -- Check location restrictions
                local pos = client:GetPos()
                local restrictedAreas = {
                {pos = Vector(0, 0, 0), radius = 100}, -- Example restricted area
                }

                for _, area in ipairs(restrictedAreas) do
                    if pos:Distance(area.pos) < area.radius then
                        client:ChatPrint("Cannot drop items in this area")
                        return false
                    end
                end

                -- Check for admin restrictions
                if char:getData("adminRestricted", false) then
                    client:ChatPrint("You are restricted from dropping items")
                    return false
                end

                return true
            end)
    ```
]]
function CanPlayerDropItem(client, item)
end

--[[
    Purpose:
        Called to check if a player can earn salary
    When Called:
        When salary payment is being processed
    Parameters:
        client (Player) - The player being checked
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all players
    hook.Add("CanPlayerEarnSalary", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if player is AFK
    hook.Add("CanPlayerEarnSalary", "SalaryAFKCheck", function(client)
        local isAFK = client:getNetVar("afk", false)
        if isAFK then
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary eligibility system
    hook.Add("CanPlayerEarnSalary", "AdvancedSalaryCheck", function(client)
        local char = client:getChar()
        if not char then return false end

            -- Check if player is AFK
            local isAFK = client:getNetVar("afk", false)
            if isAFK then
                return false
            end

            -- Check minimum playtime
            local playTime = client:GetUTimeTotalTime()
            if playTime < 3600 then
                return false
            end

            -- Check faction requirements
            local faction = char:getFaction()
            if faction == "citizen" then
                -- Citizens need to be employed
                if not char:getData("employed", false) then
                    return false
                end
            end

            return true
        end)
    ```
]]
function CanPlayerEarnSalary(client)
end

--[[
    Purpose:
        Determines if a player can equip an item
    When Called:
        When a player attempts to equip an item
    Parameters:
        client (Player) - The player equipping the item
        item (Item) - The item being equipped
    Returns:
        boolean - True if equipping is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item equipping
    hook.Add("CanPlayerEquipItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check level requirements
    hook.Add("CanPlayerEquipItem", "LevelRequirements", function(client, item)
        local char = client:getChar()
        if not char then return false end

            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)

            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to equip this item")
                return false
            end

            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex equipment validation system
    hook.Add("CanPlayerEquipItem", "AdvancedEquipment", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check faction restrictions
            local allowedFactions = item:getData("allowedFactions")
            if allowedFactions then
                local faction = char:getFaction()
                if not table.HasValue(allowedFactions, faction) then
                    client:ChatPrint("Your faction cannot equip this item")
                    return false
                end
            end

            -- Check attribute requirements
            local requiredAttribs = item:getData("requiredAttributes")
            if requiredAttribs then
                for attr, value in pairs(requiredAttribs) do
                    local charAttr = char:getAttrib(attr, 0)
                    if charAttr < value then
                        client:ChatPrint("You need " .. attr .. " " .. value .. " to equip this item")
                        return false
                    end
                end
            end

            -- Check if item slot is already occupied
            local itemSlot = item:getData("slot")
            if itemSlot then
                local equippedItems = char:getData("equippedItems", {})
                if equippedItems[itemSlot] then
                    client:ChatPrint("You already have an item equipped in that slot")
                    return false
                end
            end

            -- Check weight limits
            local itemWeight = item:getData("weight", 1)
            local currentWeight = char:getData("currentWeight", 0)
            local maxWeight = char:getData("maxWeight", 100)
            if currentWeight + itemWeight > maxWeight then
                client:ChatPrint("Equipping this item would exceed your weight limit")
                return false
            end

            -- Check if item is broken
            if item:getData("broken", false) then
                client:ChatPrint("This item is broken and cannot be equipped")
                return false
            end

            return true
        end)
    ```
]]
--[[
    Purpose:
        Called to check if a player can equip an item
    When Called:
        When a player attempts to equip an item
    Parameters:
        client (Player) - The player attempting to equip the item
        item (Item) - The item being equipped
    Returns:
        boolean - True if equipping is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item equips
    hook.Add("CanPlayerEquipItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check item type restrictions
    hook.Add("CanPlayerEquipItem", "ItemEquipCheck", function(client, item)
        -- Check if item is equippable
        if not item:getData("equippable", false) then
            client:ChatPrint("This item cannot be equipped")
            return false
        end

        -- Check if already equipped
        if item:getData("equipped", false) then
            client:ChatPrint("This item is already equipped")
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item equip validation system
    hook.Add("CanPlayerEquipItem", "AdvancedEquipValidation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is equippable
            if not item:getData("equippable", false) then
                client:ChatPrint("This item cannot be equipped")
                return false
            end

            -- Check if already equipped
            if item:getData("equipped", false) then
                client:ChatPrint("This item is already equipped")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction then
                local charFaction = char:getFaction()
                if itemFaction ~= charFaction then
                    client:ChatPrint("You cannot equip faction-restricted items")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to equip this item")
                return false
            end

            -- Check attribute requirements
            local requiredAttribs = item:getData("requiredAttribs", {})
            for attr, value in pairs(requiredAttribs) do
                local charAttr = char:getAttrib(attr, 0)
                if charAttr < value then
                    client:ChatPrint("You need " .. attr .. " " .. value .. " to equip this item")
                    return false
                end
            end

            -- Check for conflicting items
            local itemType = item:getData("itemType")
            if itemType then
                local equippedItems = char:getInv():getItems()
                for _, equippedItem in pairs(equippedItems) do
                    if equippedItem:getData("equipped", false) and equippedItem:getData("itemType") == itemType then
                        client:ChatPrint("You already have a " .. itemType .. " equipped")
                        return false
                    end
                end
            end

            -- Check for special item restrictions
            if item.uniqueID == "weapon_pistol" then
                -- Special handling for weapons
                if not char:hasFlags("w") then
                    client:ChatPrint("You need weapon flags to equip weapons")
                    return false
                end
                elseif item.uniqueID == "armor_vest" then
                    -- Special handling for armor
                    local charClass = char:getClass()
                    if charClass == "citizen" then
                        client:ChatPrint("Citizens cannot equip armor")
                        return false
                    end
                end

                -- Check for admin restrictions
                if char:getData("adminRestricted", false) then
                    client:ChatPrint("You are restricted from equipping items")
                    return false
                end

                return true
            end)
    ```
]]
function CanPlayerEquipItem(client, item)
end

--[[
    Purpose:
        Called to check if a player can hold an object
    When Called:
        When a player attempts to pick up or hold an entity
    Parameters:
        client (Player) - The player attempting to hold the object
        entity (Entity) - The entity being held
    Returns:
        boolean - True if holding is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all object holding
    hook.Add("CanPlayerHoldObject", "MyAddon", function(client, entity)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check entity type restrictions
    hook.Add("CanPlayerHoldObject", "ObjectHoldCheck", function(client, entity)
        -- Prevent holding certain entity types
        if entity:GetClass() == "prop_physics" then
            return true
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex object holding validation
    hook.Add("CanPlayerHoldObject", "AdvancedHoldValidation", function(client, entity)
        local char = client:getChar()
        if not char then return false end

            -- Check entity validity
            if not IsValid(entity) then return false end

                -- Check entity class
                local allowedClasses = {"prop_physics", "prop_physics_multiplayer"}
                if not table.HasValue(allowedClasses, entity:GetClass()) then
                    return false
                end

                -- Check faction restrictions
                local faction = char:getFaction()
                if faction == "prisoner" then
                    client:ChatPrint("Prisoners cannot hold objects")
                    return false
                end

                -- Check level requirements
                local charLevel = char:getData("level", 1)
                if charLevel < 5 then
                    client:ChatPrint("You need to be level 5 to hold objects")
                    return false
                end

                return true
            end)
    ```
]]
function CanPlayerHoldObject(client, entity)
end

--[[
    Purpose:
        Called to check if a player can interact with an item
    When Called:
        When a player attempts to perform an action on an item
    Parameters:
        client (Player) - The player attempting the interaction
        action (string) - The action being performed
        self (Item) - The item being interacted with
        data (table) - Additional data for the interaction
    Returns:
        boolean - True if interaction is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item interactions
    hook.Add("CanPlayerInteractItem", "MyAddon", function(client, action, self, data)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check action restrictions
    hook.Add("CanPlayerInteractItem", "ItemInteractionCheck", function(client, action, self, data)
        -- Check if action is allowed
        if action == "use" then
            return true
            elseif action == "drop" then
                if self:getData("noDrop", false) then
                    return false
                end
                return true
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item interaction validation
    hook.Add("CanPlayerInteractItem", "AdvancedInteractionValidation", function(client, action, self, data)
        local char = client:getChar()
        if not char then return false end

            -- Check action restrictions
            if action == "use" then
                -- Check if item is usable
                if self:getData("noUse", false) then
                    client:ChatPrint("This item cannot be used")
                    return false
                end
                elseif action == "drop" then
                    -- Check if item is droppable
                    if self:getData("noDrop", false) then
                        client:ChatPrint("This item cannot be dropped")
                        return false
                    end
                    elseif action == "equip" then
                        -- Check if item is equippable
                        if not self:getData("equippable", false) then
                            client:ChatPrint("This item cannot be equipped")
                            return false
                        end
                    end

                    -- Check faction restrictions
                    local itemFaction = self:getData("faction")
                    if itemFaction then
                        local charFaction = char:getFaction()
                        if itemFaction ~= charFaction then
                            client:ChatPrint("You cannot interact with faction-restricted items")
                            return false
                        end
                    end

                    return true
                end)
    ```
]]
function CanPlayerInteractItem(client, action, self, data)
end

--[[
    Purpose:
        Called to check if a player can join a class
    When Called:
        When a player attempts to join a specific class
    Parameters:
        client (Player) - The player attempting to join the class
        class (number) - The class ID being joined
        info (table) - Additional class information
    Returns:
        boolean - True if joining is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all class joins
    hook.Add("CanPlayerJoinClass", "MyAddon", function(client, class, info)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction requirements
    hook.Add("CanPlayerJoinClass", "ClassJoinCheck", function(client, class, info)
        local char = client:getChar()
        if not char then return false end

            local faction = char:getFaction()
            if faction == info.faction then
                return true
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class join validation
    hook.Add("CanPlayerJoinClass", "AdvancedClassJoin", function(client, class, info)
        local char = client:getChar()
        if not char then return false end

            -- Check faction requirements
            if info.faction and char:getFaction() ~= info.faction then
                client:ChatPrint("You must be in the " .. info.faction .. " faction to join this class")
                return false
            end

            -- Check level requirements
            if info.level and char:getData("level", 1) < info.level then
                client:ChatPrint("You need to be level " .. info.level .. " to join this class")
                return false
            end

            -- Check flag requirements
            if info.flags and not char:hasFlags(info.flags) then
                client:ChatPrint("You don't have the required flags to join this class")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerJoinClass(client, class, info)
end

--[[
    Purpose:
        Called to check if a player can knock on doors
    When Called:
        When a player attempts to knock on a door
    Parameters:
        client (Player) - The player attempting to knock
    Returns:
        boolean - True if knocking is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all knocking
    hook.Add("CanPlayerKnock", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check character status
    hook.Add("CanPlayerKnock", "KnockCheck", function(client)
        local char = client:getChar()
        if not char then return false end

            if char:getData("unconscious", false) then
                return false
            end
            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex knock validation
    hook.Add("CanPlayerKnock", "AdvancedKnockValidation", function(client)
        local char = client:getChar()
        if not char then return false end

            -- Check if player is unconscious
            if char:getData("unconscious", false) then
                client:ChatPrint("You cannot knock while unconscious")
                return false
            end

            -- Check if player is gagged
            if char:getData("gagged", false) then
                client:ChatPrint("You cannot knock while gagged")
                return false
            end

            -- Check knock cooldown
            local lastKnock = char:getData("lastKnock", 0)
            if os.time() - lastKnock < 2 then
                client:ChatPrint("Please wait before knocking again")
                return false
            end

            char:setData("lastKnock", os.time())
            return true
        end)
    ```
]]
function CanPlayerKnock(client)
end

--[[
    Purpose:
        Called to check if a player can lock a door
    When Called:
        When a player attempts to lock a door
    Parameters:
        client (Player) - The player attempting to lock the door
        door (Entity) - The door entity being locked
    Returns:
        boolean - True if locking is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all door locking
    hook.Add("CanPlayerLock", "MyAddon", function(client, door)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check door ownership
    hook.Add("CanPlayerLock", "DoorLockCheck", function(client, door)
        local owner = door:getNetVar("owner")
        if owner == client:SteamID() then
            return true
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door lock validation
    hook.Add("CanPlayerLock", "AdvancedDoorLock", function(client, door)
        local char = client:getChar()
        if not char then return false end

            -- Check door ownership
            local owner = door:getNetVar("owner")
            if owner and owner ~= client:SteamID() then
                client:ChatPrint("You don't own this door")
                return false
            end

            -- Check if door is lockable
            if door:getNetVar("noLock", false) then
                client:ChatPrint("This door cannot be locked")
                return false
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction and char:getFaction() ~= doorFaction then
                client:ChatPrint("You don't have permission to lock this door")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerLock(client, door)
end

--[[
    Purpose:
        Called to check if a player can modify configuration
    When Called:
        When a player attempts to change a config value
    Parameters:
        client (Player) - The player attempting to modify config
        key (string) - The configuration key being modified
    Returns:
        boolean - True if modification is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Only allow admins
    hook.Add("CanPlayerModifyConfig", "MyAddon", function(client, key)
        return client:IsAdmin()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check specific config permissions
    hook.Add("CanPlayerModifyConfig", "ConfigModCheck", function(client, key)
        if client:IsSuperAdmin() then
            return true
            elseif client:IsAdmin() and key ~= "serverPassword" then
                return true
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex config modification validation
    hook.Add("CanPlayerModifyConfig", "AdvancedConfigMod", function(client, key)
        -- Super admins can modify anything
        if client:IsSuperAdmin() then
            return true
        end

        -- Regular admins have limited access
        if client:IsAdmin() then
            local restrictedKeys = {"serverPassword", "rconPassword", "adminFlags"}
            if table.HasValue(restrictedKeys, key) then
                client:ChatPrint("You don't have permission to modify this config")
                return false
            end
            return true
        end

        -- Check custom permissions
        local char = client:getChar()
        if char and char:hasFlags("c") then
            return true
        end

        client:ChatPrint("You don't have permission to modify config")
        return false
    end)
    ```
]]
function CanPlayerModifyConfig(client, key)
end

--[[
    Purpose:
        Called to check if a player can open the scoreboard
    When Called:
        When a player attempts to open the scoreboard
    Parameters:
        client (Player) - The player attempting to open the scoreboard
    Returns:
        boolean - True if opening is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all scoreboard access
    hook.Add("CanPlayerOpenScoreboard", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check character status
    hook.Add("CanPlayerOpenScoreboard", "ScoreboardCheck", function(client)
        local char = client:getChar()
        if not char then return false end

            if char:getData("unconscious", false) then
                return false
            end
            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard access validation
    hook.Add("CanPlayerOpenScoreboard", "AdvancedScoreboardAccess", function(client)
        local char = client:getChar()
        if not char then return false end

            -- Check if player is unconscious
            if char:getData("unconscious", false) then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction == "prisoner" then
                return false
            end

            -- Check level requirements
            if char:getData("level", 1) < 1 then
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerOpenScoreboard(client)
end

--[[
    Purpose:
        Called to check if a player can rotate an item in inventory
    When Called:
        When a player attempts to rotate an item
    Parameters:
        client (Player) - The player attempting to rotate the item
        item (Item) - The item being rotated
    Returns:
        boolean - True if rotation is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item rotation
    hook.Add("CanPlayerRotateItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check item properties
    hook.Add("CanPlayerRotateItem", "RotateCheck", function(client, item)
        -- Check if item is rotatable
        if item:getData("noRotate", false) then
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item rotation validation
    hook.Add("CanPlayerRotateItem", "AdvancedRotation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is rotatable
            if item:getData("noRotate", false) then
                client:ChatPrint("This item cannot be rotated")
                return false
            end

            -- Check if item is equipped
            if item:getData("equipped", false) then
                client:ChatPrint("Cannot rotate equipped items")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerRotateItem(client, item)
end

--[[
    Purpose:
        Called to check if a player can see a log category
    When Called:
        When determining which log categories a player can view
    Parameters:
        client (Player) - The player checking log access
        k (string) - The log category key
    Returns:
        boolean - True if viewing is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow admins to see all logs
    hook.Add("CanPlayerSeeLogCategory", "MyAddon", function(client, k)
        return client:IsAdmin()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different permissions for different categories
    hook.Add("CanPlayerSeeLogCategory", "LogCategoryCheck", function(client, k)
        if client:IsSuperAdmin() then
            return true
            elseif client:IsAdmin() and k ~= "admin" then
                return true
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex log category access control
    hook.Add("CanPlayerSeeLogCategory", "AdvancedLogAccess", function(client, k)
        -- Super admins see everything
        if client:IsSuperAdmin() then
            return true
        end

        -- Regular admins have limited access
        if client:IsAdmin() then
            local restrictedCategories = {"admin", "system", "security"}
            if table.HasValue(restrictedCategories, k) then
                return false
            end
            return true
        end

        -- Check custom permissions
        local char = client:getChar()
        if char and char:hasFlags("l") then
            return true
        end

        return false
    end)
    ```
]]
function CanPlayerSeeLogCategory(client, k)
end

--[[
    Purpose:
        Called to check if a player can spawn storage entities
    When Called:
        When a player attempts to spawn a storage container
    Parameters:
        client (Player) - The player attempting to spawn storage
        entity (Entity) - The storage entity being spawned
        info (table) - Information about the storage entity
    Returns:
        boolean - True if spawning is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all storage spawning
    hook.Add("CanPlayerSpawnStorage", "MyAddon", function(client, entity, info)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction permissions
    hook.Add("CanPlayerSpawnStorage", "StorageSpawnCheck", function(client, entity, info)
        local char = client:getChar()
        if not char then return false end

            if char:hasFlags("s") then
                return true
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage spawn validation
    hook.Add("CanPlayerSpawnStorage", "AdvancedStorageSpawn", function(client, entity, info)
        local char = client:getChar()
        if not char then return false end

            -- Check storage flags
            if not char:hasFlags("s") then
                client:ChatPrint("You need storage flags to spawn storage")
                return false
            end

            -- Check faction restrictions
            if info.faction and char:getFaction() ~= info.faction then
                client:ChatPrint("You cannot spawn this faction's storage")
                return false
            end

            -- Check level requirements
            if info.level and char:getData("level", 1) < info.level then
                client:ChatPrint("You need to be level " .. info.level .. " to spawn this storage")
                return false
            end

            -- Check storage limit
            local storageCount = char:getData("storageCount", 0)
            if storageCount >= 5 then
                client:ChatPrint("You have reached the maximum storage limit")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerSpawnStorage(client, entity, info)
end

--[[
    Purpose:
        Called to check if a player can switch characters
    When Called:
        When a player attempts to switch from one character to another
    Parameters:
        client (Player) - The player attempting to switch
        currentChar (Character) - The current character
        character (Character) - The character being switched to
    Returns:
        boolean - True if switching is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all character switching
    hook.Add("CanPlayerSwitchChar", "MyAddon", function(client, currentChar, character)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check switch cooldown
    hook.Add("CanPlayerSwitchChar", "SwitchCooldown", function(client, currentChar, character)
        local lastSwitch = currentChar:getData("lastSwitch", 0)
        if os.time() - lastSwitch < 300 then -- 5 minute cooldown
            client:ChatPrint("Please wait before switching characters")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character switch validation
    hook.Add("CanPlayerSwitchChar", "AdvancedCharSwitch", function(client, currentChar, character)
        -- Check switch cooldown
        local lastSwitch = currentChar:getData("lastSwitch", 0)
        if os.time() - lastSwitch < 300 then
            client:ChatPrint("Please wait " .. (300 - (os.time() - lastSwitch)) .. " seconds before switching")
            return false
        end

        -- Check if current character is in combat
        if currentChar:getData("inCombat", false) then
            client:ChatPrint("You cannot switch characters while in combat")
            return false
        end

        -- Check if current character is unconscious
        if currentChar:getData("unconscious", false) then
            client:ChatPrint("You cannot switch characters while unconscious")
            return false
        end

        -- Check faction switch limits
        if currentChar:getFaction() ~= character:getFaction() then
            local factionSwitches = currentChar:getData("factionSwitches", 0)
            if factionSwitches >= 3 then
                client:ChatPrint("You have reached the maximum faction switch limit")
                return false
            end
            currentChar:setData("factionSwitches", factionSwitches + 1)
        end

        -- Update last switch time
        currentChar:setData("lastSwitch", os.time())
        return true
    end)
    ```
]]
function CanPlayerSwitchChar(client, currentChar, character)
end

--[[
    Purpose:
        Called to check if a player can take an item
    When Called:
        When a player attempts to take an item from the ground or another source
    Parameters:
        client (Player) - The player attempting to take the item
        item (Item) - The item being taken
    Returns:
        boolean - True if taking is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item takes
    hook.Add("CanPlayerTakeItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check item restrictions
    hook.Add("CanPlayerTakeItem", "ItemTakeCheck", function(client, item)
        -- Check if item is takeable
        if item:getData("noTake", false) then
            client:ChatPrint("This item cannot be taken")
            return false
        end

        -- Check if item is owned by someone else
        local owner = item:getData("owner")
        if owner and owner ~= client:SteamID() then
            client:ChatPrint("This item belongs to someone else")
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item take validation system
    hook.Add("CanPlayerTakeItem", "AdvancedTakeValidation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is takeable
            if item:getData("noTake", false) then
                client:ChatPrint("This item cannot be taken")
                return false
            end

            -- Check if item is owned by someone else
            local owner = item:getData("owner")
            if owner and owner ~= client:SteamID() then
                client:ChatPrint("This item belongs to someone else")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction then
                local charFaction = char:getFaction()
                if itemFaction ~= charFaction then
                    client:ChatPrint("You cannot take faction-restricted items")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to take this item")
                return false
            end

            -- Check weight limits
            local itemWeight = item:getWeight()
            local inventory = char:getInv()
            local currentWeight = inventory:getWeight()
            local maxWeight = inventory:getMaxWeight()

            if currentWeight + itemWeight > maxWeight then
                client:ChatPrint("Not enough space in your inventory")
                return false
            end

            -- Check for special item restrictions
            if item.uniqueID == "weapon_pistol" then
                -- Special handling for weapons
                if not char:hasFlags("w") then
                    client:ChatPrint("You need weapon flags to take weapons")
                    return false
                end
                elseif item.uniqueID == "money" then
                    -- Special handling for money
                    local amount = item:getData("amount", 0)
                    if amount > 10000 then
                        client:ChatPrint("Cannot take more than $10,000 at once")
                        return false
                    end
                end

                -- Check location restrictions
                local pos = client:GetPos()
                local itemPos = item:getData("position")
                if itemPos and pos:Distance(itemPos) > 100 then
                    client:ChatPrint("Item is too far away")
                    return false
                end

                -- Check for admin restrictions
                if char:getData("adminRestricted", false) then
                    client:ChatPrint("You are restricted from taking items")
                    return false
                end

                return true
            end)
    ```
]]
function CanPlayerTakeItem(client, item)
end

--[[
    Purpose:
        Called to check if a player can throw a punch
    When Called:
        When a player attempts to punch
    Parameters:
        client (Player) - The player attempting to punch
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all players
    hook.Add("CanPlayerThrowPunch", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check stamina
    hook.Add("CanPlayerThrowPunch", "PunchStaminaCheck", function(client)
        local stamina = client:getNetVar("stamina", 100)
        if stamina < 10 then
            client:ChatPrint("Not enough stamina to punch")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex punch system
    hook.Add("CanPlayerThrowPunch", "AdvancedPunchSystem", function(client)
        local char = client:getChar()
        if not char then return false end

            -- Check stamina
            local stamina = client:getNetVar("stamina", 100)
            if stamina < 10 then
                client:ChatPrint("Not enough stamina to punch")
                return false
            end

            -- Check cooldown
            local lastPunch = char:getData("lastPunch", 0)
            if CurTime() - lastPunch < 1 then
                return false
            end

            -- Check if player is tied
            if char:getData("tied", false) then
                return false
            end

            char:setData("lastPunch", CurTime())
            return true
        end)
    ```
]]
function CanPlayerThrowPunch(client)
end

--[[
    Purpose:
        Called to check if a player can trade with a vendor
    When Called:
        When a player attempts to buy/sell from a vendor
    Parameters:
        client (Player) - The player attempting to trade
        vendor (table) - The vendor data
        itemType (string) - The item type being traded
        isSellingToVendor (boolean) - True if selling, false if buying
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all trades
    hook.Add("CanPlayerTradeWithVendor", "MyAddon", function(client, vendor, itemType, isSellingToVendor)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction restrictions
    hook.Add("CanPlayerTradeWithVendor", "VendorTradeCheck", function(client, vendor, itemType, isSellingToVendor)
        local char = client:getChar()
        if not char then return false end

            local allowedFactions = vendor.allowedFactions
            if allowedFactions and not table.HasValue(allowedFactions, char:getFaction()) then
                client:ChatPrint("Your faction cannot trade with this vendor")
                return false
            end

            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor trading system
    hook.Add("CanPlayerTradeWithVendor", "AdvancedVendorTrade", function(client, vendor, itemType, isSellingToVendor)
        local char = client:getChar()
        if not char then return false end

            -- Check faction restrictions
            local allowedFactions = vendor.allowedFactions
            if allowedFactions and not table.HasValue(allowedFactions, char:getFaction()) then
                client:ChatPrint("Your faction cannot trade with this vendor")
                return false
            end

            -- Check level requirements
            local requiredLevel = vendor.requiredLevel or 0
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to trade with this vendor")
                return false
            end

            -- Check reputation
            local requiredRep = vendor.requiredReputation or 0
            local charRep = char:getData("reputation", 0)
            if charRep < requiredRep then
                client:ChatPrint("You need " .. requiredRep .. " reputation to trade with this vendor")
                return false
            end

            -- Check trade cooldown
            local lastTrade = char:getData("lastVendorTrade", 0)
            if os.time() - lastTrade < 5 then
                client:ChatPrint("Please wait before trading again")
                return false
            end

            char:setData("lastVendorTrade", os.time())
            return true
        end)
    ```
]]
function CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Called to check if a player can unequip an item
    When Called:
        When a player attempts to unequip an item
    Parameters:
        client (Player) - The player attempting to unequip the item
        item (Item) - The item being unequipped
    Returns:
        boolean - True if unequipping is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item unequips
    hook.Add("CanPlayerUnequipItem", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if item is equipped
    hook.Add("CanPlayerUnequipItem", "ItemUnequipCheck", function(client, item)
        -- Check if item is equipped
        if not item:getData("equipped", false) then
            client:ChatPrint("This item is not equipped")
            return false
        end

        -- Check if item is unequippable
        if item:getData("noUnequip", false) then
            client:ChatPrint("This item cannot be unequipped")
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item unequip validation system
    hook.Add("CanPlayerUnequipItem", "AdvancedUnequipValidation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Check if item is equipped
            if not item:getData("equipped", false) then
                client:ChatPrint("This item is not equipped")
                return false
            end

            -- Check if item is unequippable
            if item:getData("noUnequip", false) then
                client:ChatPrint("This item cannot be unequipped")
                return false
            end

            -- Check faction restrictions
            local itemFaction = item:getData("faction")
            if itemFaction then
                local charFaction = char:getFaction()
                if itemFaction ~= charFaction then
                    client:ChatPrint("You cannot unequip faction-restricted items")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                client:ChatPrint("You need to be level " .. requiredLevel .. " to unequip this item")
                return false
            end

            -- Check for special item restrictions
            if item.uniqueID == "weapon_pistol" then
                -- Special handling for weapons
                if not char:hasFlags("w") then
                    client:ChatPrint("You need weapon flags to unequip weapons")
                    return false
                end
                elseif item.uniqueID == "armor_vest" then
                    -- Special handling for armor
                    local charClass = char:getClass()
                    if charClass == "citizen" then
                        client:ChatPrint("Citizens cannot unequip armor")
                        return false
                    end
                end

                -- Check for admin restrictions
                if char:getData("adminRestricted", false) then
                    client:ChatPrint("You are restricted from unequipping items")
                    return false
                end

                -- Check inventory space
                local inventory = char:getInv()
                if inventory:getWeight() + item:getWeight() > inventory:getMaxWeight() then
                    client:ChatPrint("Not enough space in your inventory")
                    return false
                end

                return true
            end)
    ```
]]
function CanPlayerUnequipItem(client, item)
end

--[[
    Purpose:
        Called to check if a player can unlock a door
    When Called:
        When a player attempts to unlock a door
    Parameters:
        client (Player) - The player attempting to unlock the door
        door (Entity) - The door entity being unlocked
    Returns:
        boolean - True if unlocking is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all door unlocking
    hook.Add("CanPlayerUnlock", "MyAddon", function(client, door)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check door ownership
    hook.Add("CanPlayerUnlock", "DoorUnlockCheck", function(client, door)
        local owner = door:getNetVar("owner")
        if owner == client:SteamID() then
            return true
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door unlock validation
    hook.Add("CanPlayerUnlock", "AdvancedDoorUnlock", function(client, door)
        local char = client:getChar()
        if not char then return false end

            -- Check door ownership
            local owner = door:getNetVar("owner")
            if owner and owner ~= client:SteamID() then
                client:ChatPrint("You don't own this door")
                return false
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction and char:getFaction() ~= doorFaction then
                client:ChatPrint("You don't have permission to unlock this door")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerUnlock(client, door)
end

--[[
    Purpose:
        Called to check if a player can use a character
    When Called:
        When a player attempts to load a character
    Parameters:
        client (Player) - The player attempting to use the character
        character (Character) - The character being used
    Returns:
        boolean - True if using is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all character usage
    hook.Add("CanPlayerUseChar", "MyAddon", function(client, character)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check character ownership
    hook.Add("CanPlayerUseChar", "CharUseCheck", function(client, character)
        if character:getSteamID() == client:SteamID() then
            return true
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character use validation
    hook.Add("CanPlayerUseChar", "AdvancedCharUse", function(client, character)
        -- Check character ownership
        if character:getSteamID() ~= client:SteamID() then
            client:ChatPrint("This character doesn't belong to you")
            return false
        end

        -- Check if character is banned
        if character:getData("banned", false) then
            client:ChatPrint("This character is banned")
            return false
        end

        -- Check if character is deleted
        if character:getData("deleted", false) then
            client:ChatPrint("This character has been deleted")
            return false
        end

        return true
    end)
    ```
]]
function CanPlayerUseChar(client, character)
end

--[[
    Purpose:
        Called to check if a player can use a command
    When Called:
        When a player attempts to execute a command
    Parameters:
        client (Player) - The player attempting to use the command
        command (string) - The command being executed
    Returns:
        boolean - True if command use is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all commands
    hook.Add("CanPlayerUseCommand", "MyAddon", function(client, command)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check admin commands
    hook.Add("CanPlayerUseCommand", "CommandCheck", function(client, command)
        local adminCommands = {"kick", "ban", "slay"}
        if table.HasValue(adminCommands, command) then
            return client:IsAdmin()
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex command permission system
    hook.Add("CanPlayerUseCommand", "AdvancedCommandPerms", function(client, command)
        local char = client:getChar()
        if not char then return false end

            -- Check admin commands
            local adminCommands = {"kick", "ban", "slay", "bring", "goto"}
            if table.HasValue(adminCommands, command) then
                if not client:IsAdmin() then
                    client:ChatPrint("You need admin permissions to use this command")
                    return false
                end
            end

            -- Check faction-specific commands
            local factionCommands = {
            ["police"] = {"arrest", "warrant", "unarrest"},
                ["medic"] = {"heal", "revive"}
                }

                local faction = char:getFaction()
                for fac, commands in pairs(factionCommands) do
                    if table.HasValue(commands, command) then
                        if faction ~= fac then
                            client:ChatPrint("You need to be in the " .. fac .. " faction to use this command")
                            return false
                        end
                    end
                end

                -- Check command cooldowns
                local lastCommand = char:getData("lastCommand_" .. command, 0)
                if os.time() - lastCommand < 5 then
                    client:ChatPrint("Please wait before using this command again")
                    return false
                end
                char:setData("lastCommand_" .. command, os.time())

                return true
            end)
    ```
]]
function CanPlayerUseCommand(client, command)
end

--[[
    Purpose:
        Called to check if a player can use a door
    When Called:
        When a player attempts to interact with a door
    Parameters:
        client (Player) - The player attempting to use the door
        door (Entity) - The door entity being used
    Returns:
        boolean - True if door use is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all door usage
    hook.Add("CanPlayerUseDoor", "MyAddon", function(client, door)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check door ownership
    hook.Add("CanPlayerUseDoor", "DoorUseCheck", function(client, door)
        local owner = door:getNetVar("owner")
        if owner and owner ~= client:SteamID() then
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door use validation
    hook.Add("CanPlayerUseDoor", "AdvancedDoorUse", function(client, door)
        local char = client:getChar()
        if not char then return false end

            -- Check door ownership
            local owner = door:getNetVar("owner")
            if owner and owner ~= client:SteamID() then
                -- Check if door is shared
                local sharedWith = door:getNetVar("sharedWith", {})
                if not table.HasValue(sharedWith, client:SteamID()) then
                    client:ChatPrint("You don't have permission to use this door")
                    return false
                end
            end

            -- Check faction permissions
            local doorFaction = door:getNetVar("faction")
            if doorFaction and char:getFaction() ~= doorFaction then
                client:ChatPrint("You don't have permission to use this faction's door")
                return false
            end

            -- Check if door is locked
            if door:getNetVar("locked", false) then
                client:ChatPrint("This door is locked")
                return false
            end

            return true
        end)
    ```
]]
function CanPlayerUseDoor(client, door)
end

--[[
    Purpose:
        Called to check if a player can view inventories
    When Called:
        When a player attempts to open any inventory
    Parameters:
        None
    Returns:
        boolean - True if viewing inventories is allowed, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all inventory viewing
    hook.Add("CanPlayerViewInventory", "MyAddon", function()
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check player status
    hook.Add("CanPlayerViewInventory", "InventoryViewCheck", function()
        local client = LocalPlayer()
        if not client then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check if player is unconscious
                if char:getData("unconscious", false) then
                    client:ChatPrint("You cannot view inventories while unconscious")
                    return false
                end

                return true
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory view validation system
    hook.Add("CanPlayerViewInventory", "AdvancedInventoryView", function()
        local client = LocalPlayer()
        if not client then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check if player is unconscious
                if char:getData("unconscious", false) then
                    client:ChatPrint("You cannot view inventories while unconscious")
                    return false
                end

                -- Check if player is dead
                if client:Health() <= 0 then
                    client:ChatPrint("You cannot view inventories while dead")
                    return false
                end

                -- Check if player is gagged
                if char:getData("gagged", false) then
                    client:ChatPrint("You cannot view inventories while gagged")
                    return false
                end

                -- Check if player is muted
                if char:getData("muted", false) then
                    client:ChatPrint("You cannot view inventories while muted")
                    return false
                end

                -- Check for admin restrictions
                if char:getData("adminRestricted", false) then
                    client:ChatPrint("You are restricted from viewing inventories")
                    return false
                end

                -- Check faction restrictions
                local faction = char:getFaction()
                if faction == "prisoner" then
                    client:ChatPrint("Prisoners cannot view inventories")
                    return false
                end

                -- Check level requirements
                local charLevel = char:getData("level", 1)
                if charLevel < 1 then
                    client:ChatPrint("You need to be level 1 to view inventories")
                    return false
                end

                -- Check for special conditions
                local pos = client:GetPos()
                local restrictedAreas = {
                {pos = Vector(0, 0, 0), radius = 100}, -- Example restricted area
                }

                for _, area in ipairs(restrictedAreas) do
                    if pos:Distance(area.pos) < area.radius then
                        client:ChatPrint("Cannot view inventories in this area")
                        return false
                    end
                end

                return true
            end)
    ```
]]
function CanPlayerViewInventory()
end

--[[
    Purpose:
        Called to check if an item action can be run
    When Called:
        When attempting to execute an item action
    Parameters:
        itemTable (table) - The item table containing the action
        k (string) - The action key being executed
    Returns:
        boolean - True if action can be run, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all item actions
    hook.Add("CanRunItemAction", "MyAddon", function(itemTable, k)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check action restrictions
    hook.Add("CanRunItemAction", "ActionCheck", function(itemTable, k)
        -- Check if action exists
        if not itemTable[k] then
            return false
        end

        -- Check if action is disabled
        if itemTable:getData("actionDisabled", false) then
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item action validation
    hook.Add("CanRunItemAction", "AdvancedActionValidation", function(itemTable, k)
        -- Check if action exists
        if not itemTable[k] then
            return false
        end

        -- Check if action is disabled
        if itemTable:getData("actionDisabled", false) then
            return false
        end

        -- Check faction restrictions
        local actionFaction = itemTable:getData("actionFaction")
        if actionFaction then
            local char = LocalPlayer():getChar()
            if char and char:getFaction() ~= actionFaction then
                return false
            end
        end

        -- Check level requirements
        local requiredLevel = itemTable:getData("requiredLevel", 1)
        local char = LocalPlayer():getChar()
        if char then
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                return false
            end
        end

        return true
    end)
    ```
]]
function CanRunItemAction(itemTable, k)
end

--[[
    Purpose:
        Called to check if entity data can be saved
    When Called:
        When attempting to save entity data to the database
    Parameters:
        ent (Entity) - The entity being saved
        inventory (Inventory) - The inventory associated with the entity
    Returns:
        boolean - True if data can be saved, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all data saving
    hook.Add("CanSaveData", "MyAddon", function(ent, inventory)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check entity validity
    hook.Add("CanSaveData", "DataSaveCheck", function(ent, inventory)
        -- Check if entity is valid
        if not IsValid(ent) then
            return false
        end

        -- Check if entity is persistent
        if not ent:getNetVar("persistent", false) then
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data save validation
    hook.Add("CanSaveData", "AdvancedDataSave", function(ent, inventory)
        -- Check if entity is valid
        if not IsValid(ent) then
            return false
        end

        -- Check if entity is persistent
        if not ent:getNetVar("persistent", false) then
            return false
        end

        -- Check if entity has owner
        local owner = ent:getNetVar("owner")
        if not owner then
            return false
        end

        -- Check if owner is online
        local ownerPlayer = player.GetBySteamID(owner)
        if not IsValid(ownerPlayer) then
            return false
        end

        -- Check if entity is in valid location
        local pos = ent:GetPos()
        if pos.z < -1000 or pos.z > 1000 then
            return false
        end

        return true
    end)
    ```
]]
function CanSaveData(ent, inventory)
end

--[[
    Purpose:
        Called when a character is cleaned up
    When Called:
        When a character is being removed from memory
    Parameters:
        character (Character) - The character being cleaned up
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character cleanup
    hook.Add("CharCleanUp", "MyAddon", function(character)
        print("Character cleaned up: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up character data
    hook.Add("CharCleanUp", "CharDataCleanup", function(character)
        -- Clear character data
        character:setData("lastCleanup", os.time())

        -- Clear temporary data
        character:setData("tempData", nil)
        character:setData("cachedData", nil)

        print("Character data cleaned up: " .. character:getName())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character cleanup system
    hook.Add("CharCleanUp", "AdvancedCharCleanup", function(character)
        -- Clear character data
        character:setData("lastCleanup", os.time())

        -- Clear temporary data
        character:setData("tempData", nil)
        character:setData("cachedData", nil)

        -- Clear active effects
        character:setData("activeEffects", {})

            -- Clear active quests
            character:setData("activeQuests", {})

                -- Clear recognition data
                character:setData("recognitions", {})

                    -- Clear inventory cache
                    local inventory = character:getInv()
                    if inventory then
                        inventory:setData("cachedItems", nil)
                    end

                    -- Clear position data
                    character:setData("lastPos", nil)
                    character:setData("lastAng", nil)

                    -- Log cleanup
                    print(string.format("Character %s (ID: %d) cleaned up",
                    character:getName(), character:getID()))
                end)
    ```
]]
function CharCleanUp(character)
end

--[[
    Purpose:
        Called when a character is deleted
    When Called:
        When a character is successfully deleted
    Parameters:
        client (Player) - The player whose character was deleted
        character (Character) - The character that was deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character deletion
    hook.Add("CharDeleted", "MyAddon", function(client, character)
        print(client:Name() .. " deleted character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle character deletion effects
    hook.Add("CharDeleted", "CharDeletionEffects", function(client, character)
        -- Clear character data
        character:setData("deleted", true)
        character:setData("deletionTime", os.time())

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(character:getName() .. " was deleted")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character deletion system
    hook.Add("CharDeleted", "AdvancedCharDeletion", function(client, character)
        -- Set deletion data
        character:setData("deleted", true)
        character:setData("deletionTime", os.time())

        -- Clear character inventory
        local inventory = character:getInv()
        if inventory then
            local items = inventory:getItems()
            for _, item in pairs(items) do
                inventory:remove(item)
            end
        end

        -- Clear character money
        character:setMoney(0)

        -- Clear character attributes
        local attributes = character:getAttribs()
        for attr, _ in pairs(attributes) do
            character:setAttrib(attr, 0)
        end

        -- Clear character data
        character:setData("level", 1)
        character:setData("experience", 0)
        character:setData("activeQuests", {})
            character:setData("activeEffects", {})

                -- Check for faction-specific effects
                local faction = character:getFaction()
                if faction == "police" then
                    -- Police character deleted
                    for _, ply in ipairs(player.GetAll()) do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == "police" and ply ~= client then
                            ply:ChatPrint("[POLICE] " .. character:getName() .. " was deleted")
                        end
                    end
                    elseif faction == "medic" then
                        -- Medic character deleted
                        for _, ply in ipairs(player.GetAll()) do
                            local plyChar = ply:getChar()
                            if plyChar and plyChar:getFaction() == "medic" and ply ~= client then
                                ply:ChatPrint("[MEDICAL] " .. character:getName() .. " was deleted")
                            end
                        end
                    end

                    -- Notify other players
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client then
                            ply:ChatPrint(character:getName() .. " was deleted")
                        end
                    end

                    -- Log deletion
                    print(string.format("%s deleted character %s (Faction: %s)",
                    client:Name(), character:getName(), faction))
                end)
    ```
]]
function CharDeleted(client, character)
end

--[[
    Purpose:
        Called to force character recognition
    When Called:
        When a character is forced to be recognized
    Parameters:
        ply (Player) - The player being recognized
        range (number) - The recognition range
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log forced recognition
    hook.Add("CharForceRecognized", "MyAddon", function(ply, range)
        print(ply:Name() .. " was force recognized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle forced recognition effects
    hook.Add("CharForceRecognized", "ForceRecognitionEffects", function(ply, range)
        local char = ply:getChar()
        if char then
            -- Set recognition data
            char:setData("forceRecognized", true)
            char:setData("recognitionTime", os.time())

            -- Notify player
            ply:ChatPrint("You have been force recognized")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex force recognition system
    hook.Add("CharForceRecognized", "AdvancedForceRecognition", function(ply, range)
        local char = ply:getChar()
        if not char then return end

            -- Set recognition data
            char:setData("forceRecognized", true)
            char:setData("recognitionTime", os.time())
            char:setData("recognitionRange", range)

            -- Check for faction-specific effects
            local faction = char:getFaction()
            if faction == "police" then
                -- Police force recognition
                for _, target in ipairs(player.GetAll()) do
                    if target ~= ply then
                        local targetChar = target:getChar()
                        if targetChar and targetChar:getFaction() == "police" then
                            target:ChatPrint("[POLICE] " .. char:getName() .. " was force recognized")
                        end
                    end
                end
                elseif faction == "medic" then
                    -- Medic force recognition
                    for _, target in ipairs(player.GetAll()) do
                        if target ~= ply then
                            local targetChar = target:getChar()
                            if targetChar and targetChar:getFaction() == "medic" then
                                target:ChatPrint("[MEDICAL] " .. char:getName() .. " was force recognized")
                            end
                        end
                    end
                end

                -- Notify player
                ply:ChatPrint("You have been force recognized")

                -- Log force recognition
                print(string.format("%s was force recognized (Faction: %s, Range: %d)",
                ply:Name(), faction, range))
            end)
    ```
]]
function CharForceRecognized(ply, range)
end

--[[
    Purpose:
        Called to check if a character has specific flags
    When Called:
        When checking if a character has certain permissions
    Parameters:
        self (Character) - The character being checked
        flags (string) - The flags to check for
    Returns:
        boolean - True if character has flags, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Check basic flags
    hook.Add("CharHasFlags", "MyAddon", function(self, flags)
        return self:getData("flags", ""):find(flags) ~= nil
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check faction-based flags
    hook.Add("CharHasFlags", "FactionFlags", function(self, flags)
        local faction = self:getFaction()
        local factionFlags = {
        ["police"] = "w",
        ["medic"] = "m",
        ["citizen"] = ""
    }

    local hasFactionFlags = factionFlags[faction] or ""
    return hasFactionFlags:find(flags) ~= nil
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex flag checking system
    hook.Add("CharHasFlags", "AdvancedFlagCheck", function(self, flags)
        -- Check basic flags
        local charFlags = self:getData("flags", "")
        if charFlags:find(flags) then
            return true
        end

        -- Check faction-based flags
        local faction = self:getFaction()
        local factionFlags = {
        ["police"] = "w",
        ["medic"] = "m",
        ["citizen"] = ""
    }

    local hasFactionFlags = factionFlags[faction] or ""
    if hasFactionFlags:find(flags) then
        return true
    end

    -- Check level-based flags
    local charLevel = self:getData("level", 1)
    if charLevel >= 10 and flags == "v" then
        return true
    end

    -- Check admin flags
    local client = self:getPlayer()
    if client and client:IsAdmin() and flags == "a" then
        return true
    end

    return false
    end)
    ```
]]
function CharHasFlags(self, flags)
end

--[[
    Purpose:
        Called when a character is loaded for a player
    When Called:
        When a character is successfully loaded and set up for a player
    Parameters:
        id (number) - The character ID that was loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character loading
    hook.Add("CharLoaded", "MyAddon", function(id)
        print("Character " .. id .. " loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up character-specific data
    hook.Add("CharLoaded", "CharSetup", function(id)
        local char = lia.char.getByID(id)
        if char then
            char:setData("lastLogin", os.time())
            char:setData("loginCount", (char:getData("loginCount", 0) + 1))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character loading system
    hook.Add("CharLoaded", "AdvancedCharLoading", function(id)
        local char = lia.char.getByID(id)
        if not char then return end

            local client = char:getPlayer()
            if not IsValid(client) then return end

                -- Set up faction-specific bonuses
                local faction = char:getFaction()
                if faction == "police" then
                    char:setData("salary", 1000)
                    char:setData("authority", 5)
                    elseif faction == "medic" then
                        char:setData("salary", 800)
                        char:setData("healingBonus", 1.2)
                    end

                    -- Check for returning player bonuses
                    local lastLogin = char:getData("lastLogin", 0)
                    local timeSinceLogin = os.time() - lastLogin
                    if timeSinceLogin > 86400 then -- 24 hours
                        char:setData("returningPlayerBonus", true)
                        client:ChatPrint("Welcome back! You have a returning player bonus.")
                    end

                    -- Set up character statistics
                    local loginCount = char:getData("loginCount", 0)
                    char:setData("totalPlayTime", char:getData("totalPlayTime", 0) + 1)

                    -- Update character appearance
                    hook.Run("SetupPlayerModel", client, char)

                    -- Sync character data
                    char:sync()
                end)
    ```
]]
--[[
    Purpose:
        Called when a character is loaded
    When Called:
        When a character is successfully loaded from the database
    Parameters:
        id (number) - The ID of the character that was loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character loading
    hook.Add("CharLoaded", "MyAddon", function(id)
        print("Character loaded: " .. id)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle character loading effects
    hook.Add("CharLoaded", "CharLoadingEffects", function(id)
        local character = lia.char.getByID(id)
        if character then
            -- Set loading data
            character:setData("loaded", true)
            character:setData("loadTime", os.time())

            print("Character " .. character:getName() .. " loaded successfully")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character loading system
    hook.Add("CharLoaded", "AdvancedCharLoading", function(id)
        local character = lia.char.getByID(id)
        if not character then return end

            -- Set loading data
            character:setData("loaded", true)
            character:setData("loadTime", os.time())

            -- Get character data
            local name = character:getName()
            local faction = character:getFaction()
            local level = character:getData("level", 1)

            -- Check for faction-specific loading effects
            if faction == "police" then
                -- Police character loaded
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "police" then
                        ply:ChatPrint("[POLICE] " .. name .. " has joined the force")
                    end
                end
                elseif faction == "medic" then
                    -- Medic character loaded
                    for _, ply in ipairs(player.GetAll()) do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == "medic" then
                            ply:ChatPrint("[MEDICAL] " .. name .. " has joined the medical staff")
                        end
                    end
                end

                -- Check for level-based effects
                if level >= 10 then
                    print("High level character loaded: " .. name .. " (Level " .. level .. ")")
                end

                -- Log character loading
                print(string.format("Character %s (ID: %d, Faction: %s, Level: %d) loaded successfully",
                name, id, faction, level))
            end)
    ```
]]
function CharLoaded(id)
end

--[[
    Purpose:
        Called after a character is saved
    When Called:
        After character data has been saved to the database
    Parameters:
        self (Character) - The character that was saved
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character save
    hook.Add("CharPostSave", "MyAddon", function(self)
        print("Character " .. self:getName() .. " saved")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update save timestamp
    hook.Add("CharPostSave", "SaveTimestamp", function(self)
        self:setData("lastSave", os.time())
        print("Character " .. self:getName() .. " saved at " .. os.date("%H:%M:%S"))
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex post-save handling
    hook.Add("CharPostSave", "AdvancedPostSave", function(self)
        -- Update save timestamp
        self:setData("lastSave", os.time())

        -- Increment save count
        local saveCount = self:getData("saveCount", 0) + 1
        self:setData("saveCount", saveCount)

        -- Create backup every 10 saves
        if saveCount % 10 == 0 then
            lia.char.createBackup(self:getID())
            print("Backup created for character " .. self:getName())
        end

        print(string.format("Character %s saved (Save #%d)", self:getName(), saveCount))
    end)
    ```
]]
function CharPostSave(self)
end

--[[
    Purpose:
        Called before a character is saved
    When Called:
        Before character data is saved to the database
    Parameters:
        character (Character) - The character being saved
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character save
    hook.Add("CharPreSave", "MyAddon", function(character)
        print("Saving character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate character data
    hook.Add("CharPreSave", "SaveValidation", function(character)
        -- Validate money
        local money = character:getMoney()
        if money < 0 then
            character:setMoney(0)
            print("Fixed negative money for " .. character:getName())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex pre-save validation
    hook.Add("CharPreSave", "AdvancedPreSave", function(character)
        -- Validate money
        local money = character:getMoney()
        if money < 0 then
            character:setMoney(0)
            elseif money > 1000000 then
                character:setMoney(1000000)
            end

            -- Validate attributes
            local attributes = character:getAttribs()
            for attr, value in pairs(attributes) do
                if value < 0 then
                    character:setAttrib(attr, 0)
                    elseif value > 100 then
                        character:setAttrib(attr, 100)
                    end
                end

                -- Update save preparation timestamp
                character:setData("preSaveTime", os.time())

                print("Character " .. character:getName() .. " validated and ready for save")
            end)
    ```
]]
function CharPreSave(character)
end

--[[
    Purpose:
        Called when a character is restored
    When Called:
        When a character is restored from backup or death
    Parameters:
        character (Character) - The character being restored
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character restoration
    hook.Add("CharRestored", "MyAddon", function(character)
        print("Character " .. character:getName() .. " restored")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle restoration effects
    hook.Add("CharRestored", "RestorationEffects", function(character)
        character:setData("restored", true)
        character:setData("restoreTime", os.time())
        print("Character " .. character:getName() .. " restored successfully")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character restoration
    hook.Add("CharRestored", "AdvancedRestoration", function(character)
        -- Set restoration data
        character:setData("restored", true)
        character:setData("restoreTime", os.time())

        -- Restore health and stamina
        local client = character:getPlayer()
        if client then
            client:SetHealth(100)
            client:setNetVar("stamina", 100)
        end

        -- Clear negative effects
        character:setData("unconscious", false)
        character:setData("bleeding", false)

        print("Character " .. character:getName() .. " fully restored")
    end)
    ```
]]
function CharRestored(character)
end

--[[
    Purpose:
        Called when chat is parsed
    When Called:
        When a chat message is processed and parsed
    Parameters:
        client (Player) - The player who sent the message
        chatType (string) - The type of chat (ic, ooc, etc)
        message (string) - The message content
        anonymous (boolean) - Whether the message is anonymous
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log parsed chat
    hook.Add("ChatParsed", "MyAddon", function(client, chatType, message, anonymous)
        print(client:Name() .. " sent " .. chatType .. " message: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter chat messages
    hook.Add("ChatParsed", "ChatFilter", function(client, chatType, message, anonymous)
        -- Filter spam
        if string.len(message) > 500 then
            client:ChatPrint("Message too long")
            return false
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat parsing
    hook.Add("ChatParsed", "AdvancedChatParse", function(client, chatType, message, anonymous)
        local char = client:getChar()
        if not char then return false end

            -- Check for spam
            local lastMessage = char:getData("lastMessage", "")
            if lastMessage == message then
                client:ChatPrint("Don't spam the same message")
                return false
            end
            char:setData("lastMessage", message)

            -- Check message length
            if string.len(message) > 500 then
                client:ChatPrint("Message too long (max 500 characters)")
                return false
            end

            -- Log chat
            lia.log.add(client, "chat", chatType, message)
        end)
    ```
]]
function ChatParsed(client, chatType, message, anonymous)
end

--[[
    Purpose:
        Called to check if a faction limit has been reached
    When Called:
        When checking if more players can join a faction
    Parameters:
        faction (number) - The faction ID being checked
        character (Character) - The character attempting to join
        client (Player) - The player attempting to join
    Returns:
        boolean - True if limit is reached, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: No faction limits
    hook.Add("CheckFactionLimitReached", "MyAddon", function(faction, character, client)
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Basic faction limits
    hook.Add("CheckFactionLimitReached", "FactionLimits", function(faction, character, client)
        local factionData = lia.faction.indices[faction]
        if factionData and factionData.limit then
            local count = 0
            for _, ply in ipairs(player.GetAll()) do
                local char = ply:getChar()
                if char and char:getFaction() == faction then
                    count = count + 1
                end
            end
            return count >= factionData.limit
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex faction limit system
    hook.Add("CheckFactionLimitReached", "AdvancedFactionLimits", function(faction, character, client)
        local factionData = lia.faction.indices[faction]
        if not factionData then return false end

            -- Count current faction members
            local count = 0
            for _, ply in ipairs(player.GetAll()) do
                local char = ply:getChar()
                if char and char:getFaction() == faction then
                    count = count + 1
                end
            end

            -- Check base limit
            local limit = factionData.limit or math.huge

            -- Adjust limit based on server population
            local playerCount = #player.GetAll()
            if playerCount < 10 then
                limit = math.floor(limit * 0.5)
                elseif playerCount > 50 then
                    limit = math.floor(limit * 1.5)
                end

                -- Check if limit is reached
                if count >= limit then
                    client:ChatPrint("Faction limit reached (" .. count .. "/" .. limit .. ")")
                    return true
                end

                return false
            end)
    ```
]]
function CheckFactionLimitReached(faction, character, client)
end

--[[
    Purpose:
        Called when a command is executed
    When Called:
        After a command has been run by a player
    Parameters:
        client (Player) - The player who ran the command
        command (string) - The command that was executed
        arguments (table) - The arguments passed to the command
        results (any) - The results returned by the command
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log command execution
    hook.Add("CommandRan", "MyAddon", function(client, command, arguments, results)
        print(client:Name() .. " ran command: " .. command)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track command usage
    hook.Add("CommandRan", "CommandUsageTracking", function(client, command, arguments, results)
        local char = client:getChar()
        if char then
            local commandCount = char:getData("commandCount", 0) + 1
            char:setData("commandCount", commandCount)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex command execution tracking
    hook.Add("CommandRan", "AdvancedCommandTracking", function(client, command, arguments, results)
        local char = client:getChar()
        if not char then return end

            -- Track command usage
            local commandCount = char:getData("commandCount", 0) + 1
            char:setData("commandCount", commandCount)

            -- Track command history
            local commandHistory = char:getData("commandHistory", {})
            table.insert(commandHistory, {
                command = command,
                arguments = arguments,
                timestamp = os.time(),
                results = results
                })

                -- Keep only last 50 commands
                if #commandHistory > 50 then
                    table.remove(commandHistory, 1)
                end

                char:setData("commandHistory", commandHistory)

                -- Log command execution
                lia.log.add(client, "command", command, table.concat(arguments, " "))

                print(string.format("%s ran command: %s (Args: %d, Success: %s)",
                client:Name(), command, #arguments, tostring(results ~= false)))
            end)
    ```
]]
function CommandRan(client, command, arguments, results)
end

--[[
    Purpose:
        Called when a configuration value changes
    When Called:
        When a config option is modified
    Parameters:
        key (string) - The configuration key that changed
        value (any) - The new value
        oldValue (any) - The previous value
        client (Player) - The player who changed the config (if applicable)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log config changes
    hook.Add("ConfigChanged", "MyAddon", function(key, value, oldValue, client)
        print("Config changed: " .. key .. " = " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle specific config changes
    hook.Add("ConfigChanged", "ConfigHandling", function(key, value, oldValue, client)
        if key == "maxPlayers" then
            game.MaxPlayers = value
            elseif key == "serverName" then
                RunConsoleCommand("hostname", value)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex config change handling
    hook.Add("ConfigChanged", "AdvancedConfigChange", function(key, value, oldValue, client)
        -- Log config change
        if client then
            lia.log.add(client, "config", key, tostring(oldValue) .. " -> " .. tostring(value))
        end

        -- Handle specific config changes
        if key == "maxPlayers" then
            game.MaxPlayers = value
            print("Max players updated to: " .. value)
            elseif key == "serverName" then
                RunConsoleCommand("hostname", value)
                print("Server name updated to: " .. value)
                elseif key == "password" then
                    if value and value ~= "" then
                        RunConsoleCommand("sv_password", value)
                        print("Server password set")
                        else
                            RunConsoleCommand("sv_password", "")
                            print("Server password removed")
                        end
                    end

                    -- Notify admins
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ply:ChatPrint("[CONFIG] " .. key .. " changed to: " .. tostring(value))
                        end
                    end
                end)
    ```
]]
function ConfigChanged(key, value, oldValue, client)
end

--[[
    Purpose:
        Called when creating a character
    When Called:
        When a new character is being created
    Parameters:
        data (table) - The character creation data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character creation
    hook.Add("CreateCharacter", "MyAddon", function(data)
        print("Creating character: " .. data.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add default items
    hook.Add("CreateCharacter", "DefaultItems", function(data)
        data.items = data.items or {}
            table.insert(data.items, "wallet")
            table.insert(data.items, "phone")
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation
    hook.Add("CreateCharacter", "AdvancedCreation", function(data)
        -- Add default items
        data.items = data.items or {}
            table.insert(data.items, "wallet")
            table.insert(data.items, "phone")

            -- Add faction-specific items
            local factionItems = {
            ["police"] = {"handcuffs", "radio"},
                ["medic"] = {"medkit", "bandage"}
                }

                local items = factionItems[data.faction]
                if items then
                    for _, item in ipairs(items) do
                        table.insert(data.items, item)
                    end
                end

                -- Set creation timestamp
                data.createdAt = os.time()

                print("Character " .. data.name .. " created with " .. #data.items .. " items")
            end)
    ```
]]
function CreateCharacter(data)
end

--[[
    Purpose:
        Called to create a character's default inventory
    When Called:
        When a new character needs an inventory created
    Parameters:
        character (Character) - The character receiving the inventory
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory creation
    hook.Add("CreateDefaultInventory", "MyAddon", function(character)
        print("Creating inventory for: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set inventory size based on faction
    hook.Add("CreateDefaultInventory", "FactionInventory", function(character)
        local faction = character:getFaction()
        local sizes = {
        ["police"] = {w = 8, h = 6},
            ["medic"] = {w = 7, h = 5},
                ["citizen"] = {w = 6, h = 4}
                }

                local size = sizes[faction] or {w = 6, h = 4}
                character:getInv():setSize(size.w, size.h)
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory setup
    hook.Add("CreateDefaultInventory", "AdvancedInventorySetup", function(character)
        local faction = character:getFaction()

        -- Set inventory size based on faction
        local sizes = {
        ["police"] = {w = 8, h = 6},
            ["medic"] = {w = 7, h = 5},
                ["citizen"] = {w = 6, h = 4}
                }

                local size = sizes[faction] or {w = 6, h = 4}
                local inv = character:getInv()
                inv:setSize(size.w, size.h)

                -- Set weight limits
                local weights = {
                ["police"] = 50,
                ["medic"] = 40,
                ["citizen"] = 30
            }

            inv:setData("maxWeight", weights[faction] or 30)

            -- Add starting items
            local startingItems = {
            ["police"] = {"handcuffs", "radio"},
                ["medic"] = {"medkit"},
                    ["citizen"] = {"wallet"}
                    }

                    local items = startingItems[faction] or {}
                    for _, itemID in ipairs(items) do
                        local item = lia.item.instance(itemID)
                        if item then
                            inv:add(item)
                        end
                    end

                    print("Inventory created for " .. character:getName() .. " (" .. size.w .. "x" .. size.h .. ")")
                end)
    ```
]]
function CreateDefaultInventory(character)
end

--[[
    Purpose:
        Called to create salary timers
    When Called:
        When salary payment timers need to be initialized
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log salary timer creation
    hook.Add("CreateSalaryTimers", "MyAddon", function()
        print("Salary timers created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up basic salary system
    hook.Add("CreateSalaryTimers", "SalarySetup", function()
        timer.Create("SalaryPayment", 300, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                char:giveMoney(100)
            end
        end
    end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary system
    hook.Add("CreateSalaryTimers", "AdvancedSalary", function()
        timer.Create("SalaryPayment", 300, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if not char then continue end

                -- Calculate salary based on faction
                local faction = char:getFaction()
                local salaries = {
                ["police"] = 200,
                ["medic"] = 150,
                ["citizen"] = 50
            }

            local salary = salaries[faction] or 50

            -- Apply bonuses
            local level = char:getData("level", 1)
            salary = salary + (level * 5)

            -- Give salary
            char:giveMoney(salary)
            ply:ChatPrint("You received your salary: $" .. salary)
        end
    end)
    end)
    ```
]]
--[[
    Purpose:
        Called to create salary timers
    When Called:
        When salary system is being initialized
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Create basic salary timer
    hook.Add("CreateSalaryTimers", "MyAddon", function()
        timer.Create("SalaryTimer", 300, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                char:giveMoney(100)
            end
        end
    end)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-based salary timers
    hook.Add("CreateSalaryTimers", "FactionSalaryTimers", function()
        timer.Create("SalaryTimer", 300, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                local faction = char:getFaction()
                local salary = 100

                if faction == "police" then
                    salary = 200
                    elseif faction == "medic" then
                        salary = 150
                    end

                    char:giveMoney(salary)
                    ply:ChatPrint("You received $" .. salary .. " salary")
                end
            end
        end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary timer system
    hook.Add("CreateSalaryTimers", "AdvancedSalaryTimers", function()
        timer.Create("SalaryTimer", 300, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if not char then continue end

                -- Check if player can earn salary
                if not hook.Run("CanPlayerEarnSalary", ply) then
                    continue
                end

                -- Calculate base salary
                local faction = char:getFaction()
                local baseSalary = hook.Run("GetSalaryAmount", ply, faction) or 100

                -- Apply level bonus
                local level = char:getData("level", 1)
                local levelBonus = math.floor(level * 5)

                -- Apply rank bonus
                local rank = char:getData("rank", 0)
                local rankBonus = rank * 25

                -- Calculate total salary
                local totalSalary = baseSalary + levelBonus + rankBonus

                -- Give salary
                char:giveMoney(totalSalary)
                ply:ChatPrint("You received $" .. totalSalary .. " salary")

                -- Update statistics
                local totalEarned = char:getData("totalSalaryEarned", 0)
                char:setData("totalSalaryEarned", totalEarned + totalSalary)
            end
        end)
    end)
    ```
]]
function CreateSalaryTimers()
end

--[[
    Purpose:
        Called for custom class validation
    When Called:
        When validating a player's class change
    Parameters:
        client (Player) - The player changing class
        newClass (string) - The new class being validated
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all class changes
    hook.Add("CustomClassValidation", "MyAddon", function(client, newClass)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check level requirements
    hook.Add("CustomClassValidation", "ClassLevelCheck", function(client, newClass)
        local char = client:getChar()
        if not char then return false end

            local classLevels = {
            ["warrior"] = 1,
            ["mage"] = 5,
            ["rogue"] = 10
        }

        local requiredLevel = classLevels[newClass] or 1
        local charLevel = char:getData("level", 1)

        if charLevel < requiredLevel then
            client:ChatPrint("You need to be level " .. requiredLevel .. " to become a " .. newClass)
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class validation system
    hook.Add("CustomClassValidation", "AdvancedClassValidation", function(client, newClass)
        local char = client:getChar()
        if not char then return false end

            -- Check level requirements
            local classLevels = {
            ["warrior"] = 1,
            ["mage"] = 5,
            ["rogue"] = 10,
            ["paladin"] = 15
        }

        local requiredLevel = classLevels[newClass] or 1
        local charLevel = char:getData("level", 1)

        if charLevel < requiredLevel then
            client:ChatPrint("You need to be level " .. requiredLevel .. " to become a " .. newClass)
            return false
        end

        -- Check faction restrictions
        local faction = char:getFaction()
        local classFactions = {
        ["paladin"] = {"police", "medic"},
            ["rogue"] = {"citizen"}
            }

            local allowedFactions = classFactions[newClass]
            if allowedFactions and not table.HasValue(allowedFactions, faction) then
                client:ChatPrint("Your faction cannot become a " .. newClass)
                return false
            end

            -- Check prerequisites
            local classPrereqs = {
            ["paladin"] = {"warrior"},
                ["mage"] = {"apprentice"}
                }

                local prereqs = classPrereqs[newClass]
                if prereqs then
                    local completedClasses = char:getData("completedClasses", {})
                    for _, prereq in ipairs(prereqs) do
                        if not table.HasValue(completedClasses, prereq) then
                            client:ChatPrint("You must complete " .. prereq .. " class first")
                            return false
                        end
                    end
                end

                return true
            end)
    ```
]]
function CustomClassValidation(client, newClass)
end

--[[
    Purpose:
        Called for custom log handling
    When Called:
        When a log message is being processed
    Parameters:
        message (string) - The log message
        category (string) - The log category
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Print all logs
    hook.Add("CustomLogHandler", "MyAddon", function(message, category)
        print("[" .. category .. "] " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter logs by category
    hook.Add("CustomLogHandler", "LogFilter", function(message, category)
        local importantCategories = {"admin", "error", "warning"}

        if table.HasValue(importantCategories, category) then
            print("[IMPORTANT][" .. category .. "] " .. message)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex log handling system
    hook.Add("CustomLogHandler", "AdvancedLogHandler", function(message, category)
        -- Print to console
        print("[" .. category .. "] " .. message)

        -- Save to database
        lia.db.query("INSERT INTO logs (timestamp, category, message) VALUES (?, ?, ?)", os.time(), category, message)

        -- Notify admins of important logs
        local importantCategories = {"admin", "error", "warning", "exploit"}
        if table.HasValue(importantCategories, category) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[LOG][" .. category .. "] " .. message)
                end
            end
        end

        -- Send to Discord webhook for critical logs
        if category == "error" or category == "exploit" then
            local embed = {
            title = "Critical Log: " .. category,
            description = message,
            color = 16711680,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }
        hook.Run("DiscordRelaySend", embed)
    end
    end)
    ```
]]
function CustomLogHandler(message, category)
end

--[[
    Purpose:
        Called when database is connected
    When Called:
        When the database connection is established
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log connection
    hook.Add("DatabaseConnected", "MyAddon", function()
        print("Database connected")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize tables
    hook.Add("DatabaseConnected", "DatabaseInit", function()
        lia.db.query("CREATE TABLE IF NOT EXISTS custom_data (id INTEGER PRIMARY KEY, data TEXT)")
        print("Database connected and tables initialized")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database initialization
    hook.Add("DatabaseConnected", "AdvancedDatabaseInit", function()
        -- Create tables
        local tables = {
        "CREATE TABLE IF NOT EXISTS custom_data (id INTEGER PRIMARY KEY, data TEXT)",
        "CREATE TABLE IF NOT EXISTS player_stats (steamid TEXT PRIMARY KEY, kills INTEGER, deaths INTEGER)",
        "CREATE TABLE IF NOT EXISTS achievements (id INTEGER PRIMARY KEY, name TEXT, description TEXT)"
    }

    for _, query in ipairs(tables) do
        lia.db.query(query)
    end

    -- Create indexes
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_player_stats_steamid ON player_stats(steamid)")

    print("Database connected and fully initialized")
    end)
    ```
]]
function DatabaseConnected()
end

--[[
    Purpose:
        Called when a character is deleted
    When Called:
        When a character deletion is processed
    Parameters:
        id (number) - The character ID being deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log deletion
    hook.Add("DeleteCharacter", "MyAddon", function(id)
        print("Character " .. id .. " deleted")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up character data
    hook.Add("DeleteCharacter", "CharacterCleanup", function(id)
        lia.db.query("DELETE FROM character_items WHERE charid = ?", id)
        lia.db.query("DELETE FROM character_stats WHERE charid = ?", id)
        print("Character " .. id .. " deleted and data cleaned up")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character deletion system
    hook.Add("DeleteCharacter", "AdvancedCharacterDeletion", function(id)
        -- Clean up character data
        lia.db.query("DELETE FROM character_items WHERE charid = ?", id)
        lia.db.query("DELETE FROM character_stats WHERE charid = ?", id)
        lia.db.query("DELETE FROM character_achievements WHERE charid = ?", id)

        -- Archive character data
        lia.db.query("INSERT INTO character_archive SELECT * FROM characters WHERE id = ?", id)

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Character " .. id .. " has been deleted")
            end
        end

        print("Character " .. id .. " deleted and archived")
    end)
    ```
]]
function DeleteCharacter(id)
end

--[[
    Purpose:
        Called to send a Discord relay message
    When Called:
        When sending a message to Discord
    Parameters:
        embed (table) - The Discord embed data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log Discord send
    hook.Add("DiscordRelaySend", "MyAddon", function(embed)
        print("Sending Discord message: " .. (embed.title or "No title"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add server info to embed
    hook.Add("DiscordRelaySend", "DiscordServerInfo", function(embed)
        embed.footer = {
            text = "Server: " .. GetHostName()
        }
        print("Sending Discord message with server info")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex Discord relay system
    hook.Add("DiscordRelaySend", "AdvancedDiscordRelay", function(embed)
        -- Add server info
        embed.footer = {
            text = "Server: " .. GetHostName() .. " | Players: " .. #player.GetAll()
        }

        -- Add timestamp if not present
        if not embed.timestamp then
            embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        end

        -- Add color based on type
        if not embed.color then
            if string.find(embed.title or "", "Error") then
                embed.color = 16711680 -- Red
                elseif string.find(embed.title or "", "Warning") then
                    embed.color = 16776960 -- Yellow
                    else
                        embed.color = 65280 -- Green
                    end
                end

                print("Sending Discord message: " .. (embed.title or "No title"))
            end)
    ```
]]
function DiscordRelaySend(embed)
end

--[[
    Purpose:
        Called when Discord relay is unavailable
    When Called:
        When Discord relay connection fails
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log unavailability
    hook.Add("DiscordRelayUnavailable", "MyAddon", function()
        print("Discord relay is unavailable")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins
    hook.Add("DiscordRelayUnavailable", "DiscordNotify", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Discord relay is unavailable")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex Discord failover system
    hook.Add("DiscordRelayUnavailable", "AdvancedDiscordFailover", function()
        -- Log to file
        file.Append("discord_errors.txt", os.date() .. ": Discord relay unavailable\n")

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ERROR] Discord relay is unavailable")
            end
        end

        -- Attempt reconnection
        timer.Simple(60, function()
        print("Attempting to reconnect Discord relay...")
        -- Reconnection logic here
    end)
    end)
    ```
]]
function DiscordRelayUnavailable()
end

--[[
    Purpose:
        Called when a message is relayed to Discord
    When Called:
        After a message is successfully sent to Discord
    Parameters:
        embed (table) - The Discord embed that was sent
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log successful relay
    hook.Add("DiscordRelayed", "MyAddon", function(embed)
        print("Message relayed to Discord")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track relay statistics
    hook.Add("DiscordRelayed", "DiscordStats", function(embed)
        local relayCount = lia.data.get("discordRelayCount", 0)
        lia.data.set("discordRelayCount", relayCount + 1)
        print("Message relayed to Discord (Total: " .. (relayCount + 1) .. ")")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex Discord relay tracking
    hook.Add("DiscordRelayed", "AdvancedDiscordTracking", function(embed)
        -- Update statistics
        local relayCount = lia.data.get("discordRelayCount", 0)
        lia.data.set("discordRelayCount", relayCount + 1)

        -- Log to database
        lia.db.query("INSERT INTO discord_logs (timestamp, title, description) VALUES (?, ?, ?)",
        os.time(), embed.title or "No title", embed.description or "No description")

        -- Track relay types
        local relayTypes = lia.data.get("discordRelayTypes", {})
        local msgType = embed.title or "unknown"
        relayTypes[msgType] = (relayTypes[msgType] or 0) + 1
        lia.data.set("discordRelayTypes", relayTypes)

        print("Message relayed to Discord: " .. msgType)
    end)
    ```
]]
function DiscordRelayed(embed)
end

--[[
    Purpose:
        Called when a door's enabled state is toggled
    When Called:
        When a door is enabled or disabled
    Parameters:
        client (Player) - The player toggling the state
        door (Entity) - The door entity
        newState (boolean) - The new enabled state
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door state change
    hook.Add("DoorEnabledToggled", "MyAddon", function(client, door, newState)
        print(client:Name() .. " set door to " .. (newState and "enabled" or "disabled"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify nearby players
    hook.Add("DoorEnabledToggled", "DoorStateNotify", function(client, door, newState)
        local doorPos = door:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(doorPos) < 500 then
                ply:ChatPrint("A door has been " .. (newState and "enabled" or "disabled"))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door state management
    hook.Add("DoorEnabledToggled", "AdvancedDoorState", function(client, door, newState)
        -- Log the change
        print(client:Name() .. " set door to " .. (newState and "enabled" or "disabled"))

        -- Update door data
        door:setNetVar("enabled", newState)
        door:setNetVar("lastToggled", os.time())
        door:setNetVar("lastToggledBy", client:SteamID())

        -- Notify nearby players
        local doorPos = door:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(doorPos) < 500 then
                ply:ChatPrint(client:Name() .. " " .. (newState and "enabled" or "disabled") .. " a door")
            end
        end

        -- Log to database
        lia.db.query("INSERT INTO door_logs (timestamp, steamid, doorid, action) VALUES (?, ?, ?, ?)",
        os.time(), client:SteamID(), door:MapCreationID(), newState and "enabled" or "disabled")
    end)
    ```
]]
function DoorEnabledToggled(client, door, newState)
end

--[[
    Purpose:
        Called when a door's hidden state is toggled
    When Called:
        When a door is made hidden or visible
    Parameters:
        client (Player) - The player toggling the door visibility
        entity (Entity) - The door entity
        newState (boolean) - The new hidden state
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door visibility change
    hook.Add("DoorHiddenToggled", "MyAddon", function(client, entity, newState)
        print(client:Name() .. " toggled door visibility to " .. tostring(newState))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify nearby players
    hook.Add("DoorHiddenToggled", "NotifyDoorVisibility", function(client, entity, newState)
        local doorPos = entity:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(doorPos) < 500 then
                ply:ChatPrint("A door has been " .. (newState and "hidden" or "made visible"))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door visibility system
    hook.Add("DoorHiddenToggled", "AdvancedDoorVisibility", function(client, entity, newState)
        -- Update door data
        entity:setNetVar("hidden", newState)
        entity:setNetVar("lastToggled", os.time())
        entity:setNetVar("lastToggledBy", client:SteamID())

        -- Log to database
        lia.db.query("INSERT INTO door_logs (timestamp, steamid, doorid, action) VALUES (?, ?, ?, ?)",
        os.time(), client:SteamID(), entity:MapCreationID(), newState and "hidden" or "unhidden")

        -- Notify nearby players
        local doorPos = entity:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(doorPos) < 500 and ply ~= client then
                ply:ChatPrint(client:Name() .. " " .. (newState and "hid" or "unhid") .. " a door")
            end
        end

        -- Update door physics
        if newState then
            entity:SetNoDraw(true)
            entity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            else
                entity:SetNoDraw(false)
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
            end
        end)
    ```
]]
function DoorHiddenToggled(client, entity, newState)
end

--[[
    Purpose:
        Called when a door's lock state is toggled
    When Called:
        When a door is locked or unlocked
    Parameters:
        client (Player) - The player toggling the door lock
        door (Entity) - The door entity
        state (boolean) - True if locked, false if unlocked
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door lock changes
    hook.Add("DoorLockToggled", "MyAddon", function(client, door, state)
        local status = state and "locked" or "unlocked"
        print(client:Name() .. " " .. status .. " door " .. door:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track door lock statistics
    hook.Add("DoorLockToggled", "DoorTracking", function(client, door, state)
        local doorData = door:getNetVar("doorData", {})
        doorData.lockCount = (doorData.lockCount or 0) + 1
        doorData.lastLocked = os.time()
        door:setNetVar("doorData", doorData)

        local char = client:getChar()
        if char then
            char:setData("doorsLocked", (char:getData("doorsLocked", 0) + 1))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door locking system
    hook.Add("DoorLockToggled", "AdvancedDoorLocking", function(client, door, state)
        local char = client:getChar()
        if not char then return end

            -- Check if player has permission to lock doors
            if not char:hasFlags("D") then
                client:ChatPrint("You don't have permission to lock doors")
                return false
            end

            -- Check if door is owned by player
            local doorOwner = door:getNetVar("owner")
            if doorOwner and doorOwner ~= char:getID() then
                client:ChatPrint("You don't own this door")
                return false
            end

            -- Check for lock cooldown
            local lastLock = char:getData("lastDoorLock", 0)
            local lockCooldown = 5 -- 5 seconds
            if os.time() - lastLock < lockCooldown then
                client:ChatPrint("Please wait before locking another door")
                return false
            end

            -- Update door data
            local doorData = door:getNetVar("doorData", {})
            doorData.lockCount = (doorData.lockCount or 0) + 1
            doorData.lastLocked = os.time()
            doorData.lockedBy = char:getID()
            door:setNetVar("doorData", doorData)

            -- Update character statistics
            char:setData("doorsLocked", (char:getData("doorsLocked", 0) + 1))
            char:setData("lastDoorLock", os.time())

            -- Check for achievement
            local doorsLocked = char:getData("doorsLocked", 0)
            if doorsLocked >= 100 and not char:getData("achievement_locksmith", false) then
                char:setData("achievement_locksmith", true)
                client:ChatPrint("Achievement unlocked: Locksmith!")
            end

            -- Notify nearby players
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(door:GetPos()) < 500 then
                    local status = state and "locked" or "unlocked"
                    ply:ChatPrint(client:Name() .. " " .. status .. " a door")
                end
            end

            -- Log door lock
            print(string.format("%s %s door %s at %s",
            client:Name(), state and "locked" or "unlocked", door:EntIndex(), os.date("%Y-%m-%d %H:%M:%S")))
        end)
    ```
]]
function DoorLockToggled(client, door, state)
end

--[[
    Purpose:
        Called when a door's ownable status is toggled
    When Called:
        When a door is set to be ownable or not ownable
    Parameters:
        client (Player) - The player toggling the ownable status
        door (Entity) - The door entity
        newState (boolean) - The new ownable state (true = ownable, false = not ownable)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ownable toggle
    hook.Add("DoorOwnableToggled", "MyAddon", function(client, door, newState)
        print(client:Name() .. " set door ownable to: " .. tostring(newState))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle ownable state changes
    hook.Add("DoorOwnableToggled", "OwnableHandling", function(client, door, newState)
        local doorData = door:getNetVar("doorData", {})
        doorData.ownable = newState
        door:setNetVar("doorData", doorData)

        if not newState then
            -- Clear owner when door becomes non-ownable
            door:setNetVar("owner", nil)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ownable toggle system
    hook.Add("DoorOwnableToggled", "AdvancedOwnableToggle", function(client, door, newState)
        local char = client:getChar()
        if not char then return end

            -- Update door data
            local doorData = door:getNetVar("doorData", {})
            doorData.ownable = newState
            doorData.ownableChangedBy = char:getID()
            doorData.ownableChangedAt = os.time()
            door:setNetVar("doorData", doorData)

            if not newState then
                -- Clear owner and related data
                local owner = door:getNetVar("owner")
                if owner then
                    door:setNetVar("owner", nil)
                    door:setNetVar("locked", false)
                    door:setNetVar("sharedWith", {})

                        -- Notify previous owner
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:SteamID() == owner then
                                ply:ChatPrint("Your door has been set to non-ownable")
                            end
                        end
                    end
                end

                -- Notify nearby players
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(door:GetPos()) < 500 then
                        ply:ChatPrint("Door " .. door:EntIndex() .. " is now " .. (newState and "ownable" or "not ownable"))
                    end
                end

                -- Log ownable toggle
                print(string.format("%s set door %s ownable to: %s",
                client:Name(), door:EntIndex(), tostring(newState)))
            end)
    ```
]]
function DoorOwnableToggled(client, door, newState)
end

--[[
    Purpose:
        Called when a door's price is set
    When Called:
        When a door's purchase price is modified
    Parameters:
        client (Player) - The player setting the price
        door (Entity) - The door entity
        price (number) - The new price for the door
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door price changes
    hook.Add("DoorPriceSet", "MyAddon", function(client, door, price)
        print(client:Name() .. " set door price to $" .. price)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate door prices
    hook.Add("DoorPriceSet", "DoorPriceValidation", function(client, door, price)
        if price < 0 then
            client:ChatPrint("Door price cannot be negative")
            return false
        end

        if price > 100000 then
            client:ChatPrint("Door price cannot exceed $100,000")
            return false
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door pricing system
    hook.Add("DoorPriceSet", "AdvancedDoorPricing", function(client, door, price)
        local char = client:getChar()
        if not char then return end

            -- Check if player has permission to set door prices
            if not char:hasFlags("D") then
                client:ChatPrint("You don't have permission to set door prices")
                return false
            end

            -- Check if door is owned by player
            local doorOwner = door:getNetVar("owner")
            if doorOwner and doorOwner ~= char:getID() then
                client:ChatPrint("You don't own this door")
                return false
            end

            -- Validate price range
            if price < 0 then
                client:ChatPrint("Door price cannot be negative")
                return false
            end

            -- Check faction-based price limits
            local faction = char:getFaction()
            local maxPrices = {
            ["police"] = 50000,
            ["medic"] = 40000,
            ["citizen"] = 25000,
            ["criminal"] = 15000
        }

        local maxPrice = maxPrices[faction] or 25000
        if price > maxPrice then
            client:ChatPrint("Door price exceeds your faction limit of $" .. maxPrice)
            return false
        end

        -- Check for price changes
        local oldPrice = door:getNetVar("price", 0)
        if oldPrice > 0 and price ~= oldPrice then
            local priceChange = price - oldPrice
            local changePercent = (priceChange / oldPrice) * 100

            if math.abs(changePercent) > 50 then
                client:ChatPrint("Warning: Price change is over 50%")
            end
        end

        -- Update door data
        local doorData = door:getNetVar("doorData", {})
        doorData.price = price
        doorData.priceSetBy = char:getID()
        doorData.priceSetTime = os.time()
        door:setNetVar("doorData", doorData)

        -- Update character statistics
        char:setData("doorsPriced", (char:getData("doorsPriced", 0) + 1))

        -- Check for achievement
        local doorsPriced = char:getData("doorsPriced", 0)
        if doorsPriced >= 50 and not char:getData("achievement_realtor", false) then
            char:setData("achievement_realtor", true)
            client:ChatPrint("Achievement unlocked: Realtor!")
        end

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(door:GetPos()) < 500 then
                ply:ChatPrint(client:Name() .. " set door price to $" .. price)
            end
        end

        -- Log door price change
        print(string.format("%s set door %s price to $%d (was $%d)",
        client:Name(), door:EntIndex(), price, oldPrice))
    end)
    ```
]]
--[[
    Purpose:
        Called when a door's price is set
    When Called:
        When a door's purchase/rent price is changed
    Parameters:
        client (Player) - The player setting the price
        door (Entity) - The door entity
        price (number) - The new price
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log price change
    hook.Add("DoorPriceSet", "MyAddon", function(client, door, price)
        print(client:Name() .. " set door price to $" .. price)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate price range
    hook.Add("DoorPriceSet", "DoorPriceValidation", function(client, door, price)
        if price < 0 or price > 10000 then
            client:ChatPrint("Price must be between $0 and $10000")
            return false
        end

        door:setNetVar("price", price)
        client:ChatPrint("Door price set to $" .. price)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door pricing system
    hook.Add("DoorPriceSet", "AdvancedDoorPricing", function(client, door, price)
        -- Validate price range
        if price < 0 or price > 10000 then
            client:ChatPrint("Price must be between $0 and $10000")
            return false
        end

        -- Check admin override
        if not client:IsAdmin() then
            local char = client:getChar()
            if not char then return false end

                -- Check door ownership
                local owner = door:getNetVar("owner")
                if owner ~= char:getID() then
                    client:ChatPrint("You don't own this door")
                    return false
                end
            end

            -- Set price
            door:setNetVar("price", price)
            door:setNetVar("priceSetBy", client:SteamID())
            door:setNetVar("priceSetTime", os.time())

            -- Notify nearby players
            local doorPos = door:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(doorPos) < 500 and ply ~= client then
                    ply:ChatPrint("A door's price was set to $" .. price)
                end
            end

            client:ChatPrint("Door price set to $" .. price)

            -- Log to database
            lia.db.query("INSERT INTO door_logs (timestamp, steamid, doorid, action, value) VALUES (?, ?, ?, ?, ?)",
            os.time(), client:SteamID(), door:MapCreationID(), "price_set", price)
        end)
    ```
]]
function DoorPriceSet(client, door, price)
end

--[[
    Purpose:
        Called when a door's title is set
    When Called:
        When a door's display name is changed
    Parameters:
        client (Player) - The player setting the title
        door (Entity) - The door entity
        name (string) - The new door title
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log title change
    hook.Add("DoorTitleSet", "MyAddon", function(client, door, name)
        print(client:Name() .. " set door title to: " .. name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate title length
    hook.Add("DoorTitleSet", "DoorTitleValidation", function(client, door, name)
        if #name > 50 then
            client:ChatPrint("Door title must be 50 characters or less")
            return false
        end

        door:setNetVar("title", name)
        client:ChatPrint("Door title set to: " .. name)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door title system
    hook.Add("DoorTitleSet", "AdvancedDoorTitle", function(client, door, name)
        -- Validate title length
        if #name > 50 then
            client:ChatPrint("Door title must be 50 characters or less")
            return false
        end

        -- Filter inappropriate content
        local bannedWords = {"spam", "hack", "cheat"}
        for _, word in ipairs(bannedWords) do
            if string.find(string.lower(name), string.lower(word)) then
                client:ChatPrint("Door title contains inappropriate content")
                return false
            end
        end

        -- Check admin override
        if not client:IsAdmin() then
            local char = client:getChar()
            if not char then return false end

                -- Check door ownership
                local owner = door:getNetVar("owner")
                if owner ~= char:getID() then
                    client:ChatPrint("You don't own this door")
                    return false
                end
            end

            -- Set title
            door:setNetVar("title", name)
            door:setNetVar("titleSetBy", client:SteamID())
            door:setNetVar("titleSetTime", os.time())

            -- Notify nearby players
            local doorPos = door:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(doorPos) < 500 and ply ~= client then
                    ply:ChatPrint("A door's title was changed to: " .. name)
                end
            end

            client:ChatPrint("Door title set to: " .. name)

            -- Log to database
            lia.db.query("INSERT INTO door_logs (timestamp, steamid, doorid, action, value) VALUES (?, ?, ?, ?, ?)",
            os.time(), client:SteamID(), door:MapCreationID(), "title_set", name)
        end)
    ```
]]
function DoorTitleSet(client, door, name)
end

--[[
    Purpose:
        Called to fetch spawn points
    When Called:
        When spawn points need to be loaded or refreshed
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log spawn fetching
    hook.Add("FetchSpawns", "MyAddon", function()
        print("Fetching spawn points")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load spawn points from database
    hook.Add("FetchSpawns", "SpawnLoading", function()
        local spawns = lia.db.query("SELECT * FROM spawns")
        lia.spawns = spawns
        print("Loaded " .. #spawns .. " spawn points")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex spawn point system
    hook.Add("FetchSpawns", "AdvancedSpawnSystem", function()
        -- Load spawns from database
        local spawns = lia.db.query("SELECT * FROM spawns WHERE active = 1")

        -- Categorize spawns by faction
        lia.spawns = {
            police = {},
                medic = {},
                    citizen = {},
                        criminal = {}
                        }

                        for _, spawn in ipairs(spawns) do
                            local faction = spawn.faction or "citizen"
                            if lia.spawns[faction] then
                                table.insert(lia.spawns[faction], {
                                    pos = Vector(spawn.x, spawn.y, spawn.z),
                                    ang = Angle(spawn.pitch, spawn.yaw, spawn.roll),
                                    name = spawn.name
                                    })
                                end
                            end

                            -- Log spawn counts
                            for faction, factionSpawns in pairs(lia.spawns) do
                                print(faction .. " spawns: " .. #factionSpawns)
                            end
                        end)
    ```
]]
function FetchSpawns()
end

--[[
    Purpose:
        Called to force recognition range
    When Called:
        When setting the recognition range for a player
    Parameters:
        ply (Player) - The player to set recognition range for
        range (number) - The recognition range
        fakeName (string) - The fake name to use (optional)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log recognition range setting
    hook.Add("ForceRecognizeRange", "MyAddon", function(ply, range, fakeName)
        print("Set recognition range for " .. ply:Name() .. ": " .. range)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set recognition data
    hook.Add("ForceRecognizeRange", "RecognitionRange", function(ply, range, fakeName)
        local char = ply:getChar()
        if char then
            char:setData("recognitionRange", range)
            if fakeName then
                char:setData("fakeName", fakeName)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex recognition range system
    hook.Add("ForceRecognizeRange", "AdvancedRecognitionRange", function(ply, range, fakeName)
        local char = ply:getChar()
        if not char then return end

            -- Set recognition range
            char:setData("recognitionRange", range)
            char:setData("recognitionRangeSet", os.time())

            -- Set fake name if provided
            if fakeName and fakeName ~= "" then
                char:setData("fakeName", fakeName)
                char:setData("usingFakeName", true)
                else
                    char:setData("fakeName", nil)
                    char:setData("usingFakeName", false)
                end

                -- Notify player
                ply:ChatPrint("Recognition range set to " .. range .. " units")
                if fakeName then
                    ply:ChatPrint("Fake name set to: " .. fakeName)
                end

                -- Log recognition range change
                print(string.format("Recognition range set for %s: %d units (Fake name: %s)",
                ply:Name(), range, fakeName or "None"))
            end)
    ```
]]
function ForceRecognizeRange(ply, range, fakeName)
end

--[[
    Purpose:
        Called to get all case claims
    When Called:
        When retrieving all active case claims
    Parameters:
        None
    Returns:
        table - Table of all case claims
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return empty claims table
    hook.Add("GetAllCaseClaims", "MyAddon", function()
        return {}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load claims from database
    hook.Add("GetAllCaseClaims", "ClaimsLoading", function()
        local claims = lia.db.query("SELECT * FROM case_claims WHERE active = 1")
        return claims or {}
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex case claims system
    hook.Add("GetAllCaseClaims", "AdvancedCaseClaims", function()
        -- Load claims from database
        local claims = lia.db.query("SELECT * FROM case_claims WHERE active = 1")

        -- Process and format claims
        local processedClaims = {}
        for _, claim in ipairs(claims or {}) do
            local processedClaim = {
            id = claim.id,
            caseNumber = claim.case_number,
            claimant = claim.claimant,
            amount = claim.amount,
            status = claim.status,
            createdAt = claim.created_at,
            description = claim.description
        }

        -- Add claimant character info
        local char = lia.char.getByID(claim.claimant)
        if char then
            processedClaim.claimantName = char:getName()
            processedClaim.claimantFaction = char:getFaction()
        end

        table.insert(processedClaims, processedClaim)
    end

    -- Sort by creation date
    table.sort(processedClaims, function(a, b)
    return a.createdAt > b.createdAt
    end)

    return processedClaims
    end)
    ```
]]
function GetAllCaseClaims()
end

--[[
    Purpose:
        Gets the maximum value for a character attribute
    When Called:
        When checking the maximum value for a character attribute
    Parameters:
        target (Player) - The player whose attribute is being checked
        attrKey (string) - The attribute key to get the max for
    Returns:
        number - The maximum value for the attribute
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default max
    hook.Add("GetAttributeMax", "MyAddon", function(target, attrKey)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different maxes for different attributes
    hook.Add("GetAttributeMax", "AttributeMaxes", function(target, attrKey)
        local maxes = {
        ["str"] = 50,
        ["con"] = 50,
        ["dex"] = 50,
        ["int"] = 50,
        ["wis"] = 50,
        ["cha"] = 50
    }
    return maxes[attrKey] or 100
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex attribute max system
    hook.Add("GetAttributeMax", "AdvancedAttributeMax", function(target, attrKey)
        local char = target:getChar()
        if not char then return 100 end

            local baseMax = 100

            -- Faction bonuses
            local faction = char:getFaction()
            local factionBonuses = {
            ["police"] = {str = 10, con = 5},
                ["medic"] = {int = 10, wis = 5},
                    ["engineer"] = {int = 15, dex = 5}
                    }

                    local factionBonus = factionBonuses[faction]
                    if factionBonus and factionBonus[attrKey] then
                        baseMax = baseMax + factionBonus[attrKey]
                    end

                    -- Level bonuses
                    local charLevel = char:getData("level", 1)
                    local levelBonus = math.floor(charLevel / 10) * 5
                    baseMax = baseMax + levelBonus

                    -- Equipment bonuses
                    local inventory = char:getInv()
                    for _, item in pairs(inventory:getItems()) do
                        local attrBonus = item:getData("attrBonus")
                        if attrBonus and attrBonus[attrKey] then
                            baseMax = baseMax + attrBonus[attrKey]
                        end
                    end

                    -- Perk bonuses
                    local perks = char:getData("perks", {})
                    for _, perk in ipairs(perks) do
                        if perk.type == "attributeMax" and perk.attribute == attrKey then
                            baseMax = baseMax + perk.value
                        end
                    end

                    return math.max(baseMax, 1) -- Minimum of 1
                end)
    ```
]]
--[[
    Purpose:
        Called to get the maximum value for an attribute
    When Called:
        When calculating attribute limits
    Parameters:
        target (Player) - The player whose attribute max is being checked
        attrKey (string) - The attribute key
    Returns:
        number - The maximum attribute value
    Realm:
        Shared
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default max
    hook.Add("GetAttributeMax", "MyAddon", function(target, attrKey)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Attribute-specific maxes
    hook.Add("GetAttributeMax", "AttributeMaxes", function(target, attrKey)
        local maxes = {
        ["str"] = 100,
        ["dex"] = 80,
        ["int"] = 120
    }

    return maxes[attrKey] or 100
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex attribute max system
    hook.Add("GetAttributeMax", "AdvancedAttributeMax", function(target, attrKey)
        local char = target:getChar()
        if not char then return 100 end

            -- Base max
            local baseMax = 100

            -- Faction bonuses
            local faction = char:getFaction()
            if faction == "warrior" and attrKey == "str" then
                baseMax = baseMax + 20
                elseif faction == "mage" and attrKey == "int" then
                    baseMax = baseMax + 30
                end

                -- Level bonuses
                local level = char:getData("level", 1)
                baseMax = baseMax + (level * 2)

                -- Item bonuses
                local inventory = char:getInv()
                if inventory then
                    for _, item in pairs(inventory:getItems()) do
                        if item:getData("equipped", false) then
                            local attrBonus = item.attrBonus or {}
                            if attrBonus[attrKey] then
                                baseMax = baseMax + attrBonus[attrKey]
                            end
                        end
                    end
                end

                return baseMax
            end)
    ```
]]
function GetAttributeMax(target, attrKey)
end

--[[
    Purpose:
        Called to get the starting maximum for an attribute
    When Called:
        When a character is created
    Parameters:
        client (Player) - The player creating the character
        k (string) - The attribute key
    Returns:
        number - The starting maximum attribute value
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default starting max
    hook.Add("GetAttributeStartingMax", "MyAddon", function(client, k)
        return 50
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Attribute-specific starting maxes
    hook.Add("GetAttributeStartingMax", "AttributeStartingMaxes", function(client, k)
        local startingMaxes = {
        ["str"] = 50,
        ["dex"] = 40,
        ["int"] = 60
    }

    return startingMaxes[k] or 50
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex starting attribute system
    hook.Add("GetAttributeStartingMax", "AdvancedStartingAttributes", function(client, k)
        -- Base starting max
        local baseMax = 50

        -- Check if player has played before
        local playTime = client:GetUTimeTotalTime()
        if playTime > 36000 then -- 10 hours
            baseMax = baseMax + 10
        end

        -- Check for donator status
        if client:getNetVar("donator", false) then
            baseMax = baseMax + 5
        end

        -- Attribute-specific bonuses
        local attrBonuses = {
        ["str"] = 0,
        ["dex"] = -10,
        ["int"] = 10
    }

    baseMax = baseMax + (attrBonuses[k] or 0)

    return baseMax
    end)
    ```
]]
function GetAttributeStartingMax(client, k)
end

--[[
    Purpose:
        Gets the maximum stamina for a character
    When Called:
        When calculating character stamina limits
    Parameters:
        char (Character) - The character to get max stamina for
    Returns:
        number - The maximum stamina value
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default max stamina
    hook.Add("GetCharMaxStamina", "MyAddon", function(char)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base stamina on constitution
    hook.Add("GetCharMaxStamina", "ConstitutionStamina", function(char)
        local con = char:getAttrib("con", 0)
        return 100 + (con * 5)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex stamina system
    hook.Add("GetCharMaxStamina", "AdvancedStamina", function(char)
        local baseStamina = 100

        -- Constitution bonus
        local con = char:getAttrib("con", 0)
        local conBonus = con * 5

        -- Level bonus
        local charLevel = char:getData("level", 1)
        local levelBonus = charLevel * 2

        -- Faction bonus
        local faction = char:getFaction()
        local factionBonuses = {
        ["police"] = 20,
        ["medic"] = 15,
        ["athlete"] = 50,
        ["citizen"] = 0
    }
    local factionBonus = factionBonuses[faction] or 0

    -- Equipment bonuses
    local inventory = char:getInv()
    local equipmentBonus = 0
    for _, item in pairs(inventory:getItems()) do
        if item:getData("equipped", false) then
            local staminaBonus = item:getData("staminaBonus", 0)
            equipmentBonus = equipmentBonus + staminaBonus
        end
    end

    -- Perk bonuses
    local perks = char:getData("perks", {})
    local perkBonus = 0
    for _, perk in ipairs(perks) do
        if perk.type == "stamina" then
            perkBonus = perkBonus + perk.value
        end
    end

    -- Calculate final stamina
    local finalStamina = baseStamina + conBonus + levelBonus + factionBonus + equipmentBonus + perkBonus

    -- Apply debuffs
    local debuffs = char:getData("debuffs", {})
    for _, debuff in ipairs(debuffs) do
        if debuff.type == "stamina" then
            finalStamina = finalStamina * (1 - debuff.value)
        end
    end

    return math.max(math.floor(finalStamina), 10) -- Minimum of 10
    end)
    ```
]]
function GetCharMaxStamina(char)
end

--[[
    Purpose:
        Modifies damage scaling for different hitgroups
    When Called:
        When calculating damage to apply to a player
    Parameters:
        hitgroup (number) - The hitgroup that was hit
        dmgInfo (CTakeDamageInfo) - The damage information
        damageScale (number) - The current damage scale
    Returns:
        number - The modified damage scale
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return original scale
    hook.Add("GetDamageScale", "MyAddon", function(hitgroup, dmgInfo, damageScale)
        return damageScale
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different scales for different hitgroups
    hook.Add("GetDamageScale", "HitgroupScales", function(hitgroup, dmgInfo, damageScale)
        local scales = {
        [HITGROUP_HEAD] = 2.0,
        [HITGROUP_CHEST] = 1.0,
        [HITGROUP_STOMACH] = 1.2,
        [HITGROUP_LEFTARM] = 0.8,
        [HITGROUP_RIGHTARM] = 0.8,
        [HITGROUP_LEFTLEG] = 0.9,
        [HITGROUP_RIGHTLEG] = 0.9
    }
    return scales[hitgroup] or 1.0
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex damage scaling system
    hook.Add("GetDamageScale", "AdvancedDamage", function(hitgroup, dmgInfo, damageScale)
        local target = dmgInfo:GetAttacker()
        local attacker = dmgInfo:GetAttacker()

        if not IsValid(target) or not IsValid(attacker) then
            return damageScale
        end

        local targetChar = target:getChar()
        local attackerChar = attacker:getChar()

        if not targetChar or not attackerChar then
            return damageScale
        end

        local finalScale = damageScale

        -- Base hitgroup scales
        local hitgroupScales = {
        [HITGROUP_HEAD] = 2.0,
        [HITGROUP_CHEST] = 1.0,
        [HITGROUP_STOMACH] = 1.2,
        [HITGROUP_LEFTARM] = 0.8,
        [HITGROUP_RIGHTARM] = 0.8,
        [HITGROUP_LEFTLEG] = 0.9,
        [HITGROUP_RIGHTLEG] = 0.9
    }

    finalScale = finalScale * (hitgroupScales[hitgroup] or 1.0)

    -- Armor protection
    local armor = target:getData("armor", 0)
    if armor > 0 then
        local protection = math.min(armor / 100, 0.8) -- Max 80% protection
        finalScale = finalScale * (1 - protection)
    end

    -- Faction damage modifiers
    local targetFaction = targetChar:getFaction()
    local attackerFaction = attackerChar:getFaction()

    if targetFaction == "police" and attackerFaction == "criminal" then
        finalScale = finalScale * 1.2 -- 20% more damage to police from criminals
        elseif targetFaction == "criminal" and attackerFaction == "police" then
            finalScale = finalScale * 0.8 -- 20% less damage to criminals from police
        end

        -- Weapon type modifiers
        local weapon = attacker:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            if weaponClass == "weapon_pistol" then
                finalScale = finalScale * 0.9 -- Pistols do less damage
                elseif weaponClass == "weapon_shotgun" then
                    finalScale = finalScale * 1.3 -- Shotguns do more damage
                end
            end

            -- Critical hit chance
            local critChance = attackerChar:getData("critChance", 0.05)
            if math.random() < critChance then
                finalScale = finalScale * 2.0 -- Double damage on crit
            end

            return math.max(finalScale, 0.1) -- Minimum 10% damage
        end)
    ```
]]
--[[
    Purpose:
        Called to get damage scale for a hitgroup
    When Called:
        When calculating damage to a player
    Parameters:
        hitgroup (number) - The hitgroup that was hit
        dmgInfo (CTakeDamageInfo) - The damage info
        damageScale (number) - The current damage scale
    Returns:
        number - The modified damage scale
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default scale
    hook.Add("GetDamageScale", "MyAddon", function(hitgroup, dmgInfo, damageScale)
        return damageScale
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hitgroup-specific scaling
    hook.Add("GetDamageScale", "HitgroupScaling", function(hitgroup, dmgInfo, damageScale)
        if hitgroup == HITGROUP_HEAD then
            return damageScale * 2
            elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
                return damageScale * 0.5
            end

            return damageScale
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex damage scaling system
    hook.Add("GetDamageScale", "AdvancedDamageScale", function(hitgroup, dmgInfo, damageScale)
        local attacker = dmgInfo:GetAttacker()
        local victim = dmgInfo:GetInflictor()

        -- Hitgroup scaling
        if hitgroup == HITGROUP_HEAD then
            damageScale = damageScale * 2
            elseif hitgroup == HITGROUP_CHEST then
                damageScale = damageScale * 1.2
                elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
                    damageScale = damageScale * 0.5
                end

                -- Armor scaling
                if IsValid(victim) and victim:IsPlayer() then
                    local char = victim:getChar()
                    if char then
                        local armor = char:getData("armor", 0)
                        if armor > 0 then
                            damageScale = damageScale * (1 - (armor / 200))
                        end
                    end
                end

                return damageScale
            end)
    ```
]]
function GetDamageScale(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Called to get default character description
    When Called:
        When creating a new character
    Parameters:
        client (Player) - The player creating the character
        factionIndex (number) - The faction index
        context (table) - Additional context data
    Returns:
        string - The default description
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return generic description
    hook.Add("GetDefaultCharDesc", "MyAddon", function(client, factionIndex, context)
        return "A new character"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-specific descriptions
    hook.Add("GetDefaultCharDesc", "FactionDescriptions", function(client, factionIndex, context)
        local factionDescs = {
        [1] = "A citizen of the city",
        [2] = "A police officer",
        [3] = "A medical professional"
    }

    return factionDescs[factionIndex] or "A new character"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex description generation
    hook.Add("GetDefaultCharDesc", "AdvancedCharDesc", function(client, factionIndex, context)
        local faction = lia.faction.indices[factionIndex]
        if not faction then return "A new character" end

            -- Generate description based on faction and context
            local desc = "A " .. (faction.name or "character")

            if context and context.model then
                local gender = hook.Run("GetModelGender", context.model) or "person"
                desc = "A " .. gender .. " working as a " .. (faction.name or "character")
            end

            return desc
        end)
    ```
]]
function GetDefaultCharDesc(client, factionIndex, context)
end

--[[
    Purpose:
        Called to get default character name
    When Called:
        When creating a new character
    Parameters:
        client (Player) - The player creating the character
        factionIndex (number) - The faction index
        context (table) - Additional context data
    Returns:
        string - The default name
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return generic name
    hook.Add("GetDefaultCharName", "MyAddon", function(client, factionIndex, context)
        return "John Doe"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-specific names
    hook.Add("GetDefaultCharName", "FactionNames", function(client, factionIndex, context)
        local factionNames = {
        [1] = "Citizen #" .. math.random(1000, 9999),
        [2] = "Officer " .. client:Name(),
        [3] = "Dr. " .. client:Name()
    }

    return factionNames[factionIndex] or "John Doe"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex name generation
    hook.Add("GetDefaultCharName", "AdvancedCharName", function(client, factionIndex, context)
        local faction = lia.faction.indices[factionIndex]
        if not faction then return "John Doe" end

            -- Generate name based on faction
            local firstName = client:Name()
            local lastName = "Doe"

            if faction.uniqueID == "police" then
                return "Officer " .. firstName .. " " .. lastName
                elseif faction.uniqueID == "medic" then
                    return "Dr. " .. firstName .. " " .. lastName
                    elseif faction.uniqueID == "citizen" then
                        return firstName .. " " .. lastName
                    end

                    return firstName .. " " .. lastName
                end)
    ```
]]
function GetDefaultCharName(client, factionIndex, context)
end

--[[
    Purpose:
        Called to get default inventory size
    When Called:
        When creating a character's inventory
    Parameters:
        client (Player) - The player
        char (Character) - The character
    Returns:
        table - {width, height} inventory size
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default size
    hook.Add("GetDefaultInventorySize", "MyAddon", function(client, char)
        return {6, 4}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-based sizes
    hook.Add("GetDefaultInventorySize", "FactionInventorySize", function(client, char)
        local faction = char:getFaction()

        if faction == "police" then
            return {8, 6}
            elseif faction == "medic" then
                return {7, 5}
            end

            return {6, 4}
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory sizing
    hook.Add("GetDefaultInventorySize", "AdvancedInventorySize", function(client, char)
        local baseSize = {6, 4}

        -- Faction bonuses
        local faction = char:getFaction()
        if faction == "police" then
            baseSize = {8, 6}
                elseif faction == "medic" then
                    baseSize = {7, 5}
                    end

                    -- Donator bonus
                    if client:getNetVar("donator", false) then
                        baseSize[1] = baseSize[1] + 2
                        baseSize[2] = baseSize[2] + 1
                    end

                    -- Level bonus
                    local level = char:getData("level", 1)
                    if level >= 10 then
                        baseSize[1] = baseSize[1] + 1
                    end
                    if level >= 20 then
                        baseSize[2] = baseSize[2] + 1
                    end

                    return baseSize
                end)
    ```
]]
function GetDefaultInventorySize(client, char)
end

--[[
    Purpose:
        Called to get default inventory type
    When Called:
        When creating a character's inventory
    Parameters:
        character (Character) - The character
    Returns:
        string - The inventory type
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default type
    hook.Add("GetDefaultInventoryType", "MyAddon", function(character)
        return "grid"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-based types
    hook.Add("GetDefaultInventoryType", "FactionInventoryType", function(character)
        local faction = character:getFaction()

        if faction == "police" then
            return "police_grid"
            elseif faction == "medic" then
                return "medical_grid"
            end

            return "grid"
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory type system
    hook.Add("GetDefaultInventoryType", "AdvancedInventoryType", function(character)
        local faction = character:getFaction()
        local level = character:getData("level", 1)

        -- Faction-specific types
        if faction == "police" then
            if level >= 10 then
                return "police_advanced_grid"
            end
            return "police_grid"
            elseif faction == "medic" then
                if level >= 10 then
                    return "medical_advanced_grid"
                end
                return "medical_grid"
            end

            -- Default type with level progression
            if level >= 20 then
                return "advanced_grid"
            end

            return "grid"
        end)
    ```
]]
function GetDefaultInventoryType(character)
end

--[[
    Purpose:
        Called to get entity save data
    When Called:
        When saving entity data to the database
    Parameters:
        ent (Entity) - The entity to get save data for
    Returns:
        table - The save data for the entity
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return basic save data
    hook.Add("GetEntitySaveData", "MyAddon", function(ent)
        return {
        pos = ent:GetPos(),
        ang = ent:GetAngles(),
        model = ent:GetModel()
    }
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom entity data
    hook.Add("GetEntitySaveData", "EntityData", function(ent)
        local data = {
        pos = ent:GetPos(),
        ang = ent:GetAngles(),
        model = ent:GetModel(),
        class = ent:GetClass()
    }

    -- Add custom data
    if ent.customData then
        data.customData = ent.customData
    end

    return data
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity save data system
    hook.Add("GetEntitySaveData", "AdvancedEntitySave", function(ent)
        local data = {
        pos = ent:GetPos(),
        ang = ent:GetAngles(),
        model = ent:GetModel(),
        class = ent:GetClass(),
        health = ent:Health(),
        maxHealth = ent:GetMaxHealth()
    }

    -- Add networked variables
    local netVars = ent:getNetVar("saveData", {})
    for key, value in pairs(netVars) do
        data[key] = value
    end

    -- Add custom entity data
    if ent.customData then
        data.customData = ent.customData
    end

    -- Add owner information
    local owner = ent:getNetVar("owner")
    if owner then
        data.owner = owner
    end

    -- Add creation timestamp
    data.createdAt = ent:getNetVar("createdAt", os.time())

    return data
    end)
    ```
]]
function GetEntitySaveData(ent)
end

--[[
    Purpose:
        Called to get hands attack speed
    When Called:
        When calculating unarmed attack speed for a player
    Parameters:
        client (Player) - The player whose attack speed is being calculated
    Returns:
        number - The attack speed multiplier
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default attack speed
    hook.Add("GetHandsAttackSpeed", "MyAddon", function(client)
        return 1.0
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base speed on dexterity
    hook.Add("GetHandsAttackSpeed", "DexteritySpeed", function(client)
        local char = client:getChar()
        if not char then return 1.0 end

            local dex = char:getAttrib("dex", 0)
            return 1.0 + (dex * 0.1)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex attack speed system
    hook.Add("GetHandsAttackSpeed", "AdvancedAttackSpeed", function(client)
        local char = client:getChar()
        if not char then return 1.0 end

            local baseSpeed = 1.0

            -- Dexterity bonus
            local dex = char:getAttrib("dex", 0)
            local dexBonus = dex * 0.1

            -- Level bonus
            local level = char:getData("level", 1)
            local levelBonus = level * 0.05

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["athlete"] = 0.3,
            ["police"] = 0.1,
            ["citizen"] = 0.0
        }

        local factionBonus = factionBonuses[faction] or 0.0

        -- Equipment bonus
        local equipmentBonus = 0.0
        local inventory = char:getInv()
        if inventory then
            for _, item in pairs(inventory:getItems()) do
                if item:getData("equipped", false) and item.uniqueID == "boxing_gloves" then
                    equipmentBonus = equipmentBonus + 0.2
                end
            end
        end

        return baseSpeed + dexBonus + levelBonus + factionBonus + equipmentBonus
    end)
    ```
]]
function GetHandsAttackSpeed(client)
end

--[[
    Purpose:
        Called to get item drop model
    When Called:
        When determining the model for a dropped item
    Parameters:
        itemTable (table) - The item table
        self (Item) - The item instance
    Returns:
        string - The model path for the dropped item
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default model
    hook.Add("GetItemDropModel", "MyAddon", function(itemTable, self)
        return itemTable.model or "models/props_junk/cardboard_box004a.mdl"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Use item-specific models
    hook.Add("GetItemDropModel", "ItemModels", function(itemTable, self)
        local models = {
        ["weapon_pistol"] = "models/weapons/w_pistol.mdl",
        ["medkit"] = "models/items/medkit.mdl",
        ["money"] = "models/props/cs_assault/money.mdl"
    }

    return models[itemTable.uniqueID] or itemTable.model or "models/props_junk/cardboard_box004a.mdl"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item model system
    hook.Add("GetItemDropModel", "AdvancedItemModels", function(itemTable, self)
        -- Check for custom model in item data
        local customModel = self:getData("dropModel")
        if customModel then
            return customModel
        end

        -- Check for faction-specific models
        local char = self:getOwner()
        if char then
            local faction = char:getFaction()
            local factionModels = {
            ["police"] = {
                ["weapon_pistol"] = "models/weapons/w_pistol_police.mdl"
                },
                ["medic"] = {
                    ["medkit"] = "models/items/medkit_advanced.mdl"
                }
            }

            local factionModel = factionModels[faction] and factionModels[faction][itemTable.uniqueID]
            if factionModel then
                return factionModel
            end
        end

        -- Check for quality-based models
        local quality = self:getData("quality", "common")
        local qualityModels = {
        ["rare"] = itemTable.rareModel,
        ["epic"] = itemTable.epicModel,
        ["legendary"] = itemTable.legendaryModel
    }

    local qualityModel = qualityModels[quality]
    if qualityModel then
        return qualityModel
    end

    -- Return default model
    return itemTable.model or "models/props_junk/cardboard_box004a.mdl"
    end)
    ```
]]
function GetItemDropModel(itemTable, self)
end

--[[
    Purpose:
        Called to get item stack key
    When Called:
        When determining how items should be stacked together
    Parameters:
        item (Item) - The item to get stack key for
    Returns:
        string - The stack key for grouping items
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Use item ID as stack key
    hook.Add("GetItemStackKey", "MyAddon", function(item)
        return item.uniqueID
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Include item data in stack key
    hook.Add("GetItemStackKey", "ItemDataStacking", function(item)
        local key = item.uniqueID

        -- Include quality in stack key
        local quality = item:getData("quality", "common")
        if quality ~= "common" then
            key = key .. "_" .. quality
        end

        return key
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item stacking system
    hook.Add("GetItemStackKey", "AdvancedItemStacking", function(item)
        local key = item.uniqueID

        -- Include quality in stack key
        local quality = item:getData("quality", "common")
        if quality ~= "common" then
            key = key .. "_" .. quality
        end

        -- Include durability for stackable items
        local durability = item:getData("durability")
        if durability then
            local durabilityTier = math.floor(durability / 20) * 20
            key = key .. "_dur" .. durabilityTier
        end

        -- Include enchantments
        local enchantments = item:getData("enchantments", {})
        if #enchantments > 0 then
            table.sort(enchantments)
            key = key .. "_ench" .. table.concat(enchantments, "_")
        end

        -- Include custom data
        local customData = item:getData("stackData")
        if customData then
            key = key .. "_" .. customData
        end

        return key
    end)
    ```
]]
function GetItemStackKey(item)
end

--[[
    Purpose:
        Called to get item stacks in an inventory
    When Called:
        When retrieving stacked items from an inventory
    Parameters:
        inventory (Inventory) - The inventory to get stacks from
    Returns:
        table - Table of item stacks
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return empty stacks
    hook.Add("GetItemStacks", "MyAddon", function(inventory)
        return {}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Group items by ID
    hook.Add("GetItemStacks", "BasicStacking", function(inventory)
        local stacks = {}
        local items = inventory:getItems()

        for _, item in pairs(items) do
            local key = item.uniqueID
            if not stacks[key] then
                stacks[key] = {}
                end
                table.insert(stacks[key], item)
            end

            return stacks
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item stacking system
    hook.Add("GetItemStacks", "AdvancedStacking", function(inventory)
        local stacks = {}
        local items = inventory:getItems()

        for _, item in pairs(items) do
            -- Get stack key using the hook
            local key = hook.Run("GetItemStackKey", item) or item.uniqueID

            if not stacks[key] then
                stacks[key] = {
                    items = {},
                        count = 0,
                        totalWeight = 0,
                        stackData = {
                            uniqueID = item.uniqueID,
                            name = item.name,
                            model = item.model
                        }
                    }
                end

                table.insert(stacks[key].items, item)
                stacks[key].count = stacks[key].count + 1
                stacks[key].totalWeight = stacks[key].totalWeight + item:getWeight()
            end

            -- Sort stacks by count
            local sortedStacks = {}
            for key, stack in pairs(stacks) do
                table.insert(sortedStacks, {key = key, data = stack})
                end

                table.sort(sortedStacks, function(a, b)
                return a.data.count > b.data.count
            end)

            return sortedStacks
        end)
    ```
]]
function GetItemStacks(inventory)
end

--[[
    Purpose:
        Called to get maximum character count for a player
    When Called:
        When checking how many characters a player can have
    Parameters:
        client (Player) - The player to check character limit for
    Returns:
        number - The maximum number of characters allowed
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default limit
    hook.Add("GetMaxPlayerChar", "MyAddon", function(client)
        return 3
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different limits for different players
    hook.Add("GetMaxPlayerChar", "PlayerLimits", function(client)
        if client:IsAdmin() then
            return 10
            else
                return 3
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character limit system
    hook.Add("GetMaxPlayerChar", "AdvancedCharLimits", function(client)
        local baseLimit = 3

        -- Admin bonus
        if client:IsSuperAdmin() then
            baseLimit = baseLimit + 5
            elseif client:IsAdmin() then
                baseLimit = baseLimit + 2
            end

            -- Donator bonus
            local char = client:getChar()
            if char then
                local donatorLevel = char:getData("donatorLevel", 0)
                baseLimit = baseLimit + donatorLevel
            end

            -- Play time bonus
            local playTime = client:GetTotalPlayTime()
            local hours = playTime / 3600
            if hours >= 100 then
                baseLimit = baseLimit + 1
                elseif hours >= 500 then
                    baseLimit = baseLimit + 2
                    elseif hours >= 1000 then
                        baseLimit = baseLimit + 3
                    end

                    -- Faction bonus
                    if char then
                        local faction = char:getFaction()
                        local factionBonuses = {
                        ["police"] = 1,
                        ["medic"] = 1,
                        ["citizen"] = 0
                    }
                    baseLimit = baseLimit + (factionBonuses[faction] or 0)
                end

                return math.max(1, baseLimit)
            end)
    ```
]]
function GetMaxPlayerChar(client)
end

--[[
    Purpose:
        Called to get maximum skill points for a player
    When Called:
        When checking the maximum skill points a player can have
    Parameters:
        client (Player) - The player to check skill point limit for
    Returns:
        number - The maximum number of skill points allowed
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default skill points
    hook.Add("GetMaxSkillPoints", "MyAddon", function(client)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base skill points on level
    hook.Add("GetMaxSkillPoints", "LevelBasedPoints", function(client)
        local char = client:getChar()
        if not char then return 0 end

            local level = char:getData("level", 1)
            return level * 10
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex skill point system
    hook.Add("GetMaxSkillPoints", "AdvancedSkillPoints", function(client)
        local char = client:getChar()
        if not char then return 0 end

            local basePoints = 50

            -- Level bonus
            local level = char:getData("level", 1)
            local levelBonus = level * 5

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["police"] = 20,
            ["medic"] = 15,
            ["citizen"] = 10,
            ["criminal"] = 25
        }

        local factionBonus = factionBonuses[faction] or 10

        -- Donator bonus
        local donatorLevel = char:getData("donatorLevel", 0)
        local donatorBonus = donatorLevel * 5

        -- Achievement bonus
        local achievements = char:getData("achievements", {})
        local achievementBonus = #achievements * 2

        -- Play time bonus
        local playTime = client:GetTotalPlayTime()
        local hours = playTime / 3600
        local playTimeBonus = math.floor(hours / 100) * 5

        return basePoints + levelBonus + factionBonus + donatorBonus + achievementBonus + playTimeBonus
    end)
    ```
]]
--[[
    Purpose:
        Called to get maximum skill points for a player
    When Called:
        When calculating skill point limits
    Parameters:
        client (Player) - The player
    Returns:
        number - The maximum skill points
    Realm:
        Shared
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default max
    hook.Add("GetMaxSkillPoints", "MyAddon", function(client)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Level-based skill points
    hook.Add("GetMaxSkillPoints", "LevelSkillPoints", function(client)
        local char = client:getChar()
        if not char then return 100 end

            local level = char:getData("level", 1)
            return 50 + (level * 5)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex skill point system
    hook.Add("GetMaxSkillPoints", "AdvancedSkillPoints", function(client)
        local char = client:getChar()
        if not char then return 100 end

            -- Base points
            local basePoints = 50

            -- Level bonus
            local level = char:getData("level", 1)
            basePoints = basePoints + (level * 5)

            -- Faction bonus
            local faction = char:getFaction()
            if faction == "warrior" then
                basePoints = basePoints + 20
                elseif faction == "mage" then
                    basePoints = basePoints + 30
                end

                -- Donator bonus
                if client:getNetVar("donator", false) then
                    basePoints = basePoints + 25
                end

                return basePoints
            end)
    ```
]]
function GetMaxSkillPoints(client)
end

--[[
    Purpose:
        Called to get maximum starting attribute points
    When Called:
        During character creation
    Parameters:
        client (Player) - The player creating the character
        count (number) - The current count
    Returns:
        number - The maximum starting attribute points
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default count
    hook.Add("GetMaxStartingAttributePoints", "MyAddon", function(client, count)
        return 10
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Playtime-based points
    hook.Add("GetMaxStartingAttributePoints", "PlaytimePoints", function(client, count)
        local playTime = client:GetUTimeTotalTime()

        if playTime > 36000 then -- 10 hours
            return 15
        end

        return 10
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex starting points system
    hook.Add("GetMaxStartingAttributePoints", "AdvancedStartingPoints", function(client, count)
        local basePoints = 10

        -- Playtime bonus
        local playTime = client:GetUTimeTotalTime()
        if playTime > 36000 then
            basePoints = basePoints + 5
        end

        -- Donator bonus
        if client:getNetVar("donator", false) then
            basePoints = basePoints + 3
        end

        -- Achievement bonus
        local achievements = client:getNetVar("achievements", {})
        if #achievements >= 10 then
            basePoints = basePoints + 2
        end

        return basePoints
    end)
    ```
]]
function GetMaxStartingAttributePoints(client, count)
end

--[[
    Purpose:
        Called to get money model
    When Called:
        When spawning money entity
    Parameters:
        amount (number) - The money amount
    Returns:
        string - The model path
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default model
    hook.Add("GetMoneyModel", "MyAddon", function(amount)
        return "models/props_lab/box01a.mdl"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Amount-based models
    hook.Add("GetMoneyModel", "AmountBasedModels", function(amount)
        if amount >= 1000 then
            return "models/props/cs_office/briefcase.mdl"
            elseif amount >= 100 then
                return "models/props_lab/box01a.mdl"
            end

            return "models/props_junk/cardboard_box001a.mdl"
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex money model system
    hook.Add("GetMoneyModel", "AdvancedMoneyModels", function(amount)
        -- Different models based on amount tiers
        if amount >= 10000 then
            return "models/props/cs_office/briefcase.mdl"
            elseif amount >= 5000 then
                return "models/props_c17/suitcase001a.mdl"
                elseif amount >= 1000 then
                    return "models/props_lab/box01a.mdl"
                    elseif amount >= 100 then
                        return "models/props_junk/cardboard_box002a.mdl"
                        else
                            return "models/props_junk/cardboard_box001a.mdl"
                        end
                    end)
    ```
]]
function GetMoneyModel(amount)
end

--[[
    Purpose:
        Called to get OOC chat delay
    When Called:
        When checking OOC chat cooldown
    Parameters:
        speaker (Player) - The player speaking
    Returns:
        number - The delay in seconds
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default delay
    hook.Add("GetOOCDelay", "MyAddon", function(speaker)
        return 3
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Admin bypass
    hook.Add("GetOOCDelay", "AdminOOCBypass", function(speaker)
        if speaker:IsAdmin() then
            return 0
        end

        return 3
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex OOC delay system
    hook.Add("GetOOCDelay", "AdvancedOOCDelay", function(speaker)
        -- Admins have no delay
        if speaker:IsAdmin() then
            return 0
        end

        -- Donators have reduced delay
        if speaker:getNetVar("donator", false) then
            return 1
        end

        -- New players have longer delay
        local playTime = speaker:GetUTimeTotalTime()
        if playTime < 3600 then -- Less than 1 hour
            return 5
        end

        return 3
    end)
    ```
]]
function GetOOCDelay(speaker)
end

--[[
    Purpose:
        Called to get player playtime
    When Called:
        When retrieving player playtime
    Parameters:
        client (Player) - The player
    Returns:
        number - The playtime in seconds
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return UTime playtime
    hook.Add("GetPlayTime", "MyAddon", function(client)
        return client:GetUTimeTotalTime()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add session time
    hook.Add("GetPlayTime", "PlayTimeWithSession", function(client)
        local totalTime = client:GetUTimeTotalTime()
        local sessionTime = client:GetUTimeSessionTime()

        return totalTime + sessionTime
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex playtime tracking
    hook.Add("GetPlayTime", "AdvancedPlayTime", function(client)
        local char = client:getChar()
        if not char then
            return client:GetUTimeTotalTime()
        end

        -- Get character-specific playtime
        local charPlayTime = char:getData("playTime", 0)

        -- Add current session time
        local sessionStart = char:getData("sessionStart", os.time())
        local sessionTime = os.time() - sessionStart

        return charPlayTime + sessionTime
    end)
    ```
]]
function GetPlayTime(client)
end

--[[
    Purpose:
        Called to get player death sound
    When Called:
        When a player dies
    Parameters:
        client (Player) - The dying player
        isFemale (boolean) - Whether the player is female
    Returns:
        string - The death sound path
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default sound
    hook.Add("GetPlayerDeathSound", "MyAddon", function(client, isFemale)
        return "vo/npc/male01/pain09.wav"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Gender-based sounds
    hook.Add("GetPlayerDeathSound", "GenderDeathSounds", function(client, isFemale)
        if isFemale then
            return "vo/npc/female01/pain09.wav"
        end

        return "vo/npc/male01/pain09.wav"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex death sound system
    hook.Add("GetPlayerDeathSound", "AdvancedDeathSounds", function(client, isFemale)
        local char = client:getChar()
        if not char then
            return isFemale and "vo/npc/female01/pain09.wav" or "vo/npc/male01/pain09.wav"
        end

        -- Faction-specific sounds
        local faction = char:getFaction()
        if faction == "combine" then
            return "npc/combine_soldier/die" .. math.random(1, 3) .. ".wav"
            elseif faction == "zombie" then
                return "npc/zombie/zombie_die" .. math.random(1, 3) .. ".wav"
            end

            -- Gender-based sounds
            if isFemale then
                return "vo/npc/female01/pain0" .. math.random(7, 9) .. ".wav"
            end

            return "vo/npc/male01/pain0" .. math.random(7, 9) .. ".wav"
        end)
    ```
]]
function GetPlayerDeathSound(client, isFemale)
end

--[[
    Purpose:
        Called to get player pain sound
    When Called:
        When a player takes damage
    Parameters:
        client (Player) - The player taking damage
        paintype (number) - The type of pain
        isFemale (boolean) - Whether the player is female
    Returns:
        string - The pain sound path
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default sound
    hook.Add("GetPlayerPainSound", "MyAddon", function(client, paintype, isFemale)
        return "vo/npc/male01/pain01.wav"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Gender-based pain sounds
    hook.Add("GetPlayerPainSound", "GenderPainSounds", function(client, paintype, isFemale)
        if isFemale then
            return "vo/npc/female01/pain0" .. math.random(1, 6) .. ".wav"
        end

        return "vo/npc/male01/pain0" .. math.random(1, 6) .. ".wav"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex pain sound system
    hook.Add("GetPlayerPainSound", "AdvancedPainSounds", function(client, paintype, isFemale)
        local char = client:getChar()
        if not char then
            return isFemale and "vo/npc/female01/pain01.wav" or "vo/npc/male01/pain01.wav"
        end

        -- Faction-specific sounds
        local faction = char:getFaction()
        if faction == "combine" then
            return "npc/combine_soldier/pain" .. math.random(1, 3) .. ".wav"
            elseif faction == "zombie" then
                return "npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav"
            end

            -- Pain type-based sounds
            local soundNum = 1
            if paintype == 1 then -- Light damage
                soundNum = math.random(1, 3)
                elseif paintype == 2 then -- Medium damage
                    soundNum = math.random(4, 6)
                    else -- Heavy damage
                        soundNum = math.random(7, 9)
                    end

                    -- Gender-based sounds
                    if isFemale then
                        return "vo/npc/female01/pain0" .. soundNum .. ".wav"
                    end

                    return "vo/npc/male01/pain0" .. soundNum .. ".wav"
                end)
    ```
]]
function GetPlayerPainSound(client, paintype, isFemale)
end

--[[
    Purpose:
        Called to get player punch damage
    When Called:
        When calculating unarmed punch damage for a player
    Parameters:
        client (Player) - The player whose punch damage is being calculated
    Returns:
        number - The punch damage amount
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default punch damage
    hook.Add("GetPlayerPunchDamage", "MyAddon", function(client)
        return 10
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base damage on strength
    hook.Add("GetPlayerPunchDamage", "StrengthDamage", function(client)
        local char = client:getChar()
        if not char then return 10 end

            local str = char:getAttrib("str", 0)
            return 10 + (str * 2)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex punch damage system
    hook.Add("GetPlayerPunchDamage", "AdvancedPunchDamage", function(client)
        local char = client:getChar()
        if not char then return 10 end

            local baseDamage = 10

            -- Strength bonus
            local str = char:getAttrib("str", 0)
            local strBonus = str * 2

            -- Level bonus
            local level = char:getData("level", 1)
            local levelBonus = level * 0.5

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["athlete"] = 5,
            ["police"] = 2,
            ["citizen"] = 0
        }

        local factionBonus = factionBonuses[faction] or 0

        -- Equipment bonus
        local equipmentBonus = 0
        local inventory = char:getInv()
        if inventory then
            for _, item in pairs(inventory:getItems()) do
                if item:getData("equipped", false) then
                    if item.uniqueID == "boxing_gloves" then
                        equipmentBonus = equipmentBonus + 5
                        elseif item.uniqueID == "brass_knuckles" then
                            equipmentBonus = equipmentBonus + 8
                        end
                    end
                end
            end

            return baseDamage + strBonus + levelBonus + factionBonus + equipmentBonus
        end)
    ```
]]
function GetPlayerPunchDamage(client)
end

--[[
    Purpose:
        Called to get player punch ragdoll time
    When Called:
        When calculating how long a player stays ragdolled from a punch
    Parameters:
        client (Player) - The player being punched
    Returns:
        number - The ragdoll time in seconds
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default ragdoll time
    hook.Add("GetPlayerPunchRagdollTime", "MyAddon", function(client)
        return 3
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base time on constitution
    hook.Add("GetPlayerPunchRagdollTime", "ConstitutionRagdoll", function(client)
        local char = client:getChar()
        if not char then return 3 end

            local con = char:getAttrib("con", 0)
            return math.max(1, 3 - (con * 0.1))
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll time system
    hook.Add("GetPlayerPunchRagdollTime", "AdvancedRagdollTime", function(client)
        local char = client:getChar()
        if not char then return 3 end

            local baseTime = 3

            -- Constitution reduces ragdoll time
            local con = char:getAttrib("con", 0)
            local conReduction = con * 0.1

            -- Level reduces ragdoll time
            local level = char:getData("level", 1)
            local levelReduction = level * 0.05

            -- Faction affects ragdoll time
            local faction = char:getFaction()
            local factionModifiers = {
            ["athlete"] = -0.5,
            ["police"] = -0.2,
            ["citizen"] = 0,
            ["elderly"] = 0.5
        }

        local factionModifier = factionModifiers[faction] or 0

        -- Equipment affects ragdoll time
        local equipmentModifier = 0
        local inventory = char:getInv()
        if inventory then
            for _, item in pairs(inventory:getItems()) do
                if item:getData("equipped", false) then
                    if item.uniqueID == "armor_vest" then
                        equipmentModifier = equipmentModifier + 0.3
                        elseif item.uniqueID == "helmet" then
                            equipmentModifier = equipmentModifier + 0.2
                        end
                    end
                end
            end

            return math.max(0.5, baseTime - conReduction - levelReduction + factionModifier + equipmentModifier)
        end)
    ```
]]
function GetPlayerPunchRagdollTime(client)
end

--[[
    Purpose:
        Called to get price override for items
    When Called:
        When calculating item prices in vendors or trading
    Parameters:
        self (Entity) - The vendor or trading entity
        uniqueID (string) - The item unique ID
        price (number) - The base price
        isSellingToVendor (boolean) - Whether the player is selling to vendor
    Returns:
        number - The overridden price
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return original price
    hook.Add("GetPriceOverride", "MyAddon", function(self, uniqueID, price, isSellingToVendor)
        return price
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply faction discounts
    hook.Add("GetPriceOverride", "FactionDiscounts", function(self, uniqueID, price, isSellingToVendor)
        local client = self:getNetVar("client")
        if not client then return price end

            local char = client:getChar()
            if not char then return price end

                local faction = char:getFaction()
                if faction == "police" and uniqueID == "weapon_pistol" then
                    return price * 0.8 -- 20% discount
                end

                return price
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex price override system
    hook.Add("GetPriceOverride", "AdvancedPriceOverride", function(self, uniqueID, price, isSellingToVendor)
        local client = self:getNetVar("client")
        if not client then return price end

            local char = client:getChar()
            if not char then return price end

                local finalPrice = price

                -- Faction discounts
                local faction = char:getFaction()
                local factionDiscounts = {
                ["police"] = {
                    ["weapon_pistol"] = 0.8,
                    ["handcuffs"] = 0.5
                    },
                    ["medic"] = {
                        ["medkit"] = 0.7,
                        ["bandage"] = 0.6
                    }
                }

                local discounts = factionDiscounts[faction]
                if discounts and discounts[uniqueID] then
                    finalPrice = finalPrice * discounts[uniqueID]
                end

                -- Level discounts
                local level = char:getData("level", 1)
                if level >= 10 then
                    finalPrice = finalPrice * 0.95 -- 5% discount
                    elseif level >= 20 then
                        finalPrice = finalPrice * 0.9 -- 10% discount
                    end

                    -- Donator discounts
                    local donatorLevel = char:getData("donatorLevel", 0)
                    if donatorLevel > 0 then
                        finalPrice = finalPrice * (1 - (donatorLevel * 0.1))
                    end

                    -- Selling to vendor penalty
                    if isSellingToVendor then
                        finalPrice = finalPrice * 0.5 -- 50% of original price when selling
                    end

                    return math.max(1, finalPrice)
                end)
    ```
]]
function GetPriceOverride(self, uniqueID, price, isSellingToVendor)
end

--[[
    Purpose:
        Called to get ragdoll time
    When Called:
        When calculating how long an entity stays ragdolled
    Parameters:
        self (Entity) - The ragdoll entity
        time (number) - The base ragdoll time
    Returns:
        number - The modified ragdoll time
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return original time
    hook.Add("GetRagdollTime", "MyAddon", function(self, time)
        return time
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Extend ragdoll time for certain entities
    hook.Add("GetRagdollTime", "ExtendedRagdoll", function(self, time)
        if self:GetClass() == "prop_ragdoll" then
            return time * 1.5
        end
        return time
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll time system
    hook.Add("GetRagdollTime", "AdvancedRagdollTime", function(self, time)
        local finalTime = time

        -- Check if it's a player ragdoll
        local owner = self:getNetVar("owner")
        if owner then
            local ply = player.GetBySteamID(owner)
            if IsValid(ply) then
                local char = ply:getChar()
                if char then
                    -- Constitution affects ragdoll time
                    local con = char:getAttrib("con", 0)
                    finalTime = finalTime - (con * 0.1)

                    -- Level affects ragdoll time
                    local level = char:getData("level", 1)
                    finalTime = finalTime - (level * 0.05)

                    -- Faction affects ragdoll time
                    local faction = char:getFaction()
                    local factionModifiers = {
                    ["athlete"] = -0.5,
                    ["police"] = -0.2,
                    ["citizen"] = 0,
                    ["elderly"] = 0.5
                }

                local factionModifier = factionModifiers[faction] or 0
                finalTime = finalTime + factionModifier
            end
        end
    end

    -- Weather affects ragdoll time
    if GetConVar("sv_weather"):GetBool() then
        finalTime = finalTime * 1.2
    end

    return math.max(0.5, finalTime)
    end)
    ```
]]
function GetRagdollTime(self, time)
end

--[[
    Purpose:
        Called to get salary amount for a player
    When Called:
        When calculating salary payment for a player
    Parameters:
        client (Player) - The player receiving salary
        faction (string) - The player's faction
        class (string) - The player's class
    Returns:
        number - The salary amount
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return base salary
    hook.Add("GetSalaryAmount", "MyAddon", function(client, faction, class)
        return 100
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different salaries by faction
    hook.Add("GetSalaryAmount", "FactionSalaries", function(client, faction, class)
        local salaries = {
        ["police"] = 200,
        ["medic"] = 150,
        ["citizen"] = 50
    }
    return salaries[faction] or 50
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary system
    hook.Add("GetSalaryAmount", "AdvancedSalary", function(client, faction, class)
        local char = client:getChar()
        if not char then return 0 end

            local baseSalary = 50

            -- Faction base salaries
            local factionSalaries = {
            ["police"] = 200,
            ["medic"] = 150,
            ["citizen"] = 50,
            ["criminal"] = 0
        }

        baseSalary = factionSalaries[faction] or 50

        -- Class bonuses
        local classBonuses = {
        ["officer"] = 50,
        ["sergeant"] = 100,
        ["lieutenant"] = 150,
        ["nurse"] = 25,
        ["doctor"] = 75
    }

    local classBonus = classBonuses[class] or 0

    -- Level bonus
    local level = char:getData("level", 1)
    local levelBonus = level * 10

    -- Performance bonus
    local performance = char:getData("performance", 0)
    local performanceBonus = performance * 5

    -- Donator bonus
    local donatorLevel = char:getData("donatorLevel", 0)
    local donatorBonus = donatorLevel * 25

    return baseSalary + classBonus + levelBonus + performanceBonus + donatorBonus
    end)
    ```
]]
function GetSalaryAmount(client, faction, class)
end

--[[
    Purpose:
        Called to get tickets by requester
    When Called:
        When retrieving tickets created by a specific player
    Parameters:
        steamID (string) - The Steam ID of the requester
    Returns:
        table - Table of tickets created by the requester
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return empty tickets
    hook.Add("GetTicketsByRequester", "MyAddon", function(steamID)
        return {}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load tickets from database
    hook.Add("GetTicketsByRequester", "TicketLoading", function(steamID)
        local tickets = lia.db.query("SELECT * FROM tickets WHERE requester = ?", steamID)
        return tickets or {}
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket retrieval system
    hook.Add("GetTicketsByRequester", "AdvancedTicketRetrieval", function(steamID)
        -- Load tickets from database
        local tickets = lia.db.query("SELECT * FROM tickets WHERE requester = ? ORDER BY created_at DESC", steamID)

        if not tickets then return {} end

            -- Process tickets
            local processedTickets = {}
            for _, ticket in ipairs(tickets) do
                local processedTicket = {
                id = ticket.id,
                title = ticket.title,
                description = ticket.description,
                status = ticket.status,
                priority = ticket.priority,
                createdAt = ticket.created_at,
                updatedAt = ticket.updated_at,
                assignedTo = ticket.assigned_to
            }

            -- Add requester character info
            local requesterChar = lia.char.getByID(ticket.requester)
            if requesterChar then
                processedTicket.requesterName = requesterChar:getName()
                processedTicket.requesterFaction = requesterChar:getFaction()
            end

            -- Add assignee character info
            if ticket.assigned_to then
                local assigneeChar = lia.char.getByID(ticket.assigned_to)
                if assigneeChar then
                    processedTicket.assigneeName = assigneeChar:getName()
                end
            end

            table.insert(processedTickets, processedTicket)
        end

        return processedTickets
    end)
    ```
]]
function GetTicketsByRequester(steamID)
end

--[[
    Purpose:
        Called to get vendor sale scale
    When Called:
        When calculating the sale price multiplier for a vendor
    Parameters:
        self (Entity) - The vendor entity
    Returns:
        number - The sale scale multiplier
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default scale
    hook.Add("GetVendorSaleScale", "MyAddon", function(self)
        return 1.0
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Different scales for different vendors
    hook.Add("GetVendorSaleScale", "VendorScales", function(self)
        local vendorType = self:getNetVar("vendorType", "general")
        local scales = {
        ["weapon"] = 0.8,
        ["medical"] = 0.9,
        ["general"] = 1.0
    }
    return scales[vendorType] or 1.0
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor sale scale system
    hook.Add("GetVendorSaleScale", "AdvancedVendorScale", function(self)
        local baseScale = 1.0

        -- Vendor type affects scale
        local vendorType = self:getNetVar("vendorType", "general")
        local typeScales = {
        ["weapon"] = 0.8,
        ["medical"] = 0.9,
        ["food"] = 1.1,
        ["general"] = 1.0
    }

    baseScale = typeScales[vendorType] or 1.0

    -- Vendor level affects scale
    local vendorLevel = self:getNetVar("level", 1)
    local levelModifier = 1 + (vendorLevel * 0.1)

    -- Vendor reputation affects scale
    local reputation = self:getNetVar("reputation", 0)
    local reputationModifier = 1 + (reputation * 0.05)

    -- Time of day affects scale
    local hour = tonumber(os.date("%H"))
    local timeModifier = 1.0
    if hour >= 6 and hour <= 18 then
        timeModifier = 1.1 -- Daytime bonus
        else
            timeModifier = 0.9 -- Nighttime penalty
        end

        -- Server population affects scale
        local playerCount = #player.GetAll()
        local populationModifier = 1 + (playerCount * 0.01)

        return baseScale * levelModifier * reputationModifier * timeModifier * populationModifier
    end)
    ```
]]
function GetVendorSaleScale(self)
end

--[[
    Purpose:
        Called to get warnings for a character
    When Called:
        When retrieving warnings for a specific character
    Parameters:
        charID (number) - The character ID to get warnings for
    Returns:
        table - Table of warnings for the character
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return empty warnings
    hook.Add("GetWarnings", "MyAddon", function(charID)
        return {}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load warnings from database
    hook.Add("GetWarnings", "WarningLoading", function(charID)
        local warnings = lia.db.query("SELECT * FROM warnings WHERE char_id = ?", charID)
        return warnings or {}
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex warning retrieval system
    hook.Add("GetWarnings", "AdvancedWarningRetrieval", function(charID)
        -- Load warnings from database
        local warnings = lia.db.query("SELECT * FROM warnings WHERE char_id = ? ORDER BY created_at DESC", charID)

        if not warnings then return {} end

            -- Process warnings
            local processedWarnings = {}
            for _, warning in ipairs(warnings) do
                local processedWarning = {
                id = warning.id,
                charID = warning.char_id,
                warned = warning.warned,
                warnedSteamID = warning.warned_steamid,
                message = warning.message,
                warner = warning.warner,
                warnerSteamID = warning.warner_steamid,
                timestamp = warning.created_at,
                severity = warning.severity or "medium"
            }

            -- Add character names
            local warnedChar = lia.char.getByID(warning.char_id)
            if warnedChar then
                processedWarning.warnedName = warnedChar:getName()
            end

            local warnerChar = lia.char.getByID(warning.warner)
            if warnerChar then
                processedWarning.warnerName = warnerChar:getName()
            end

            table.insert(processedWarnings, processedWarning)
        end

        return processedWarnings
    end)
    ```
]]
function GetWarnings(charID)
end

--[[
    Purpose:
        Called to get warnings by issuer
    When Called:
        When retrieving warnings issued by a specific player
    Parameters:
        steamID (string) - The Steam ID of the issuer
    Returns:
        table - Table of warnings issued by the player
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return empty warnings
    hook.Add("GetWarningsByIssuer", "MyAddon", function(steamID)
        return {}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load warnings from database
    hook.Add("GetWarningsByIssuer", "IssuerWarnings", function(steamID)
        local warnings = lia.db.query("SELECT * FROM warnings WHERE warner_steamid = ?", steamID)
        return warnings or {}
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex warning retrieval by issuer
    hook.Add("GetWarningsByIssuer", "AdvancedIssuerWarnings", function(steamID)
        -- Load warnings from database
        local warnings = lia.db.query("SELECT * FROM warnings WHERE warner_steamid = ? ORDER BY created_at DESC", steamID)

        if not warnings then return {} end

            -- Process warnings
            local processedWarnings = {}
            for _, warning in ipairs(warnings) do
                local processedWarning = {
                id = warning.id,
                charID = warning.char_id,
                warned = warning.warned,
                warnedSteamID = warning.warned_steamid,
                message = warning.message,
                warner = warning.warner,
                warnerSteamID = warning.warner_steamid,
                timestamp = warning.created_at,
                severity = warning.severity or "medium"
            }

            -- Add character names
            local warnedChar = lia.char.getByID(warning.char_id)
            if warnedChar then
                processedWarning.warnedName = warnedChar:getName()
                processedWarning.warnedFaction = warnedChar:getFaction()
            end

            -- Add issuer character info
            local issuerChar = lia.char.getByID(warning.warner)
            if issuerChar then
                processedWarning.issuerName = issuerChar:getName()
                processedWarning.issuerFaction = issuerChar:getFaction()
            end

            table.insert(processedWarnings, processedWarning)
        end

        -- Calculate issuer statistics
        local stats = {
        totalWarnings = #processedWarnings,
        recentWarnings = 0,
        severityCounts = {}
        }

        local oneWeekAgo = os.time() - (7 * 24 * 60 * 60)
        for _, warning in ipairs(processedWarnings) do
            if warning.timestamp > oneWeekAgo then
                stats.recentWarnings = stats.recentWarnings + 1
            end

            stats.severityCounts[warning.severity] = (stats.severityCounts[warning.severity] or 0) + 1
        end

        return processedWarnings, stats
    end)
    ```
]]
function GetWarningsByIssuer(steamID)
end

--[[
    Purpose:
        Called to handle item transfer requests
    When Called:
        When a player requests to transfer an item
    Parameters:
        client (Player) - The player making the request
        itemID (string) - The ID of the item to transfer
        x (number) - The X position in the inventory
        y (number) - The Y position in the inventory
        invID (string) - The destination inventory ID
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log transfer request
    hook.Add("HandleItemTransferRequest", "MyAddon", function(client, itemID, x, y, invID)
        print(client:Name() .. " wants to transfer " .. itemID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate transfer request
    hook.Add("HandleItemTransferRequest", "TransferValidation", function(client, itemID, x, y, invID)
        local char = client:getChar()
        if not char then return end

            local item = lia.item.instance(itemID)
            if not item then
                client:ChatPrint("Invalid item")
                return
            end

            -- Check if player owns the item
            local inventory = char:getInv()
            if not inventory:hasItem(item) then
                client:ChatPrint("You don't own this item")
                return
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item transfer system
    hook.Add("HandleItemTransferRequest", "AdvancedItemTransfer", function(client, itemID, x, y, invID)
        local char = client:getChar()
        if not char then return end

            -- Get source inventory
            local sourceInventory = char:getInv()
            if not sourceInventory then return end

                -- Get destination inventory
                local destInventory = lia.inventory.getByID(invID)
                if not destInventory then
                    client:ChatPrint("Invalid destination inventory")
                    return
                end

                -- Get item
                local item = lia.item.instance(itemID)
                if not item then
                    client:ChatPrint("Invalid item")
                    return
                end

                -- Check if player owns the item
                if not sourceInventory:hasItem(item) then
                    client:ChatPrint("You don't own this item")
                    return
                end

                -- Check transfer permissions
                if not hook.Run("CanItemBeTransfered", item, sourceInventory, destInventory, client) then
                    return
                end

                -- Check destination space
                if not destInventory:canFit(item, x, y) then
                    client:ChatPrint("Not enough space in destination inventory")
                    return
                end

                -- Perform transfer
                sourceInventory:remove(item)
                destInventory:add(item, x, y)

                -- Log transfer
                lia.log.add(client, "item_transfer", itemID, "Transferred to inventory " .. invID)

                client:ChatPrint("Item transferred successfully")
            end)
    ```
]]
function HandleItemTransferRequest(client, itemID, x, y, invID)
end

--[[
    Purpose:
        Called to initialize storage
    When Called:
        When a storage entity is being initialized
    Parameters:
        entity (Entity) - The storage entity
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage initialization
    hook.Add("InitializeStorage", "MyAddon", function(entity)
        print("Initializing storage: " .. entity:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up basic storage data
    hook.Add("InitializeStorage", "StorageSetup", function(entity)
        entity:setNetVar("storageType", "general")
        entity:setNetVar("maxWeight", 100)
        entity:setNetVar("maxItems", 50)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage initialization system
    hook.Add("InitializeStorage", "AdvancedStorageInit", function(entity)
        -- Set storage type
        local storageType = entity:getNetVar("storageType", "general")

        -- Configure based on storage type
        local configs = {
        ["general"] = {maxWeight = 100, maxItems = 50, size = {w = 6, h = 4}},
            ["weapon"] = {maxWeight = 200, maxItems = 20, size = {w = 4, h = 5}},
                ["medical"] = {maxWeight = 50, maxItems = 30, size = {w = 5, h = 6}},
                    ["food"] = {maxWeight = 30, maxItems = 40, size = {w = 8, h = 5}}
                    }

                    local config = configs[storageType] or configs["general"]

                    -- Set storage properties
                    entity:setNetVar("maxWeight", config.maxWeight)
                    entity:setNetVar("maxItems", config.maxItems)
                    entity:setNetVar("inventorySize", config.size)

                    -- Set access permissions
                    local owner = entity:getNetVar("owner")
                    if owner then
                        entity:setNetVar("accessList", {owner})
                        end

                        -- Initialize inventory
                        local inventory = lia.inventory.new(entity:EntIndex(), "storage")
                        if inventory then
                            inventory:setSize(config.size.w, config.size.h)
                            inventory:setData("maxWeight", config.maxWeight)
                            inventory:setData("storageType", storageType)
                            entity:setNetVar("inventoryID", inventory:getID())
                        end

                        -- Set creation timestamp
                        entity:setNetVar("createdAt", os.time())

                        print("Storage initialized: " .. entity:EntIndex() .. " (Type: " .. storageType .. ")")
                    end)
    ```
]]
function InitializeStorage(entity)
end

--[[
    Purpose:
        Called when an inventory is deleted
    When Called:
        When an inventory is removed from the system
    Parameters:
        instance (Inventory) - The inventory being deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory deletion
    hook.Add("InventoryDeleted", "MyAddon", function(instance)
        print("Inventory deleted: " .. instance:getID())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up inventory data
    hook.Add("InventoryDeleted", "CleanupInventory", function(instance)
        -- Remove from cache
        lia.inventoryCache[instance:getID()] = nil

        print("Inventory deleted and cleaned up: " .. instance:getID())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory deletion handling
    hook.Add("InventoryDeleted", "AdvancedInventoryDeletion", function(instance)
        local invID = instance:getID()

        -- Archive inventory data
        lia.db.query("INSERT INTO inventory_archive SELECT * FROM inventories WHERE id = ?", invID)

        -- Clean up related data
        lia.db.query("DELETE FROM inventory_items WHERE invid = ?", invID)
        lia.db.query("DELETE FROM inventory_logs WHERE invid = ?", invID)

        -- Remove from cache
        lia.inventoryCache[invID] = nil

        -- Notify owner
        local owner = instance:getOwner()
        if IsValid(owner) then
            owner:ChatPrint("Your inventory has been deleted")
        end

        -- Log deletion
        print("Inventory deleted: " .. invID)
        lia.log.add("Inventory " .. invID .. " was deleted", "inventory")
    end)
    ```
]]
function InventoryDeleted(instance)
end

--[[
    Purpose:
        Called when an item is added to an inventory
    When Called:
        When an item is successfully added to any inventory
    Parameters:
        inventory (Inventory) - The inventory the item was added to
        item (Item) - The item that was added
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item additions
    hook.Add("InventoryItemAdded", "MyAddon", function(inventory, item)
        print("Item " .. item.uniqueID .. " added to inventory")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track inventory statistics
    hook.Add("InventoryItemAdded", "InventoryTracking", function(inventory, item)
        local invData = inventory:getData()
        invData.itemCount = (invData.itemCount or 0) + 1
        invData.lastItemAdded = os.time()
        inventory:setData(invData)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory management system
    hook.Add("InventoryItemAdded", "AdvancedInventory", function(inventory, item)
        local owner = inventory:getOwner()
        if not owner then return end

            local char = owner:getChar()
            if not char then return end

                -- Update inventory statistics
                local invData = inventory:getData()
                invData.itemCount = (invData.itemCount or 0) + 1
                invData.lastItemAdded = os.time()
                invData.totalValue = (invData.totalValue or 0) + (item:getData("value", 0))
                inventory:setData(invData)

                -- Check for inventory capacity
                local maxItems = inventory:getData("maxItems", 100)
                if invData.itemCount > maxItems then
                    owner:ChatPrint("Inventory is full!")
                    return false
                end

                -- Check for weight limits
                local itemWeight = item:getData("weight", 1)
                local currentWeight = inventory:getData("currentWeight", 0)
                local maxWeight = inventory:getData("maxWeight", 1000)

                if currentWeight + itemWeight > maxWeight then
                    owner:ChatPrint("Item too heavy for inventory!")
                    return false
                end

                -- Update weight
                inventory:setData("currentWeight", currentWeight + itemWeight)

                -- Check for special item effects
                if item.uniqueID == "health_potion" then
                    char:setData("healthBonus", (char:getData("healthBonus", 0) + 10))
                    elseif item.uniqueID == "stamina_boost" then
                        char:setData("staminaBonus", (char:getData("staminaBonus", 0) + 5))
                    end

                    -- Check for set bonuses
                    local items = inventory:getItems()
                    local setItems = {}
                    for _, invItem in pairs(items) do
                        local itemSet = invItem:getData("set")
                        if itemSet then
                            setItems[itemSet] = (setItems[itemSet] or 0) + 1
                        end
                    end

                    -- Apply set bonuses
                    for set, count in pairs(setItems) do
                        if count >= 3 then
                            char:setData("setBonus_" .. set, true)
                            owner:ChatPrint("Set bonus activated: " .. set)
                        end
                    end

                    -- Log item addition
                    print(string.format("Item %s added to inventory %s (Owner: %s)",
                    item.uniqueID, inventory:getID(), char:getName()))
                end)
    ```
]]
--[[
    Purpose:
        Called when an item is added to an inventory
    When Called:
        When an item is placed into an inventory
    Parameters:
        inventory (Inventory) - The inventory receiving the item
        item (Item) - The item being added
    Returns:
        None
    Realm:
        Shared
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item addition
    hook.Add("InventoryItemAdded", "MyAddon", function(inventory, item)
        print("Item added: " .. item.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update inventory weight
    hook.Add("InventoryItemAdded", "UpdateInventoryWeight", function(inventory, item)
        local currentWeight = inventory:getData("weight", 0)
        local itemWeight = item.weight or 1
        inventory:setData("weight", currentWeight + itemWeight)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item addition handling
    hook.Add("InventoryItemAdded", "AdvancedItemAddition", function(inventory, item)
        if SERVER then
            -- Update inventory weight
            local currentWeight = inventory:getData("weight", 0)
            local itemWeight = item.weight or 1
            inventory:setData("weight", currentWeight + itemWeight)

            -- Log to database
            lia.db.query("INSERT INTO inventory_logs (timestamp, invid, itemid, action) VALUES (?, ?, ?, ?)",
            os.time(), inventory:getID(), item:getID(), "added")

            -- Notify owner
            local owner = inventory:getOwner()
            if IsValid(owner) then
                owner:ChatPrint("Added " .. item.name .. " to inventory")
            end

            -- Check for set bonuses
            local items = inventory:getItems()
            local armorPieces = 0
            for _, invItem in pairs(items) do
                if string.find(invItem.uniqueID, "armor_") then
                    armorPieces = armorPieces + 1
                end
            end

            if armorPieces >= 3 and IsValid(owner) then
                local char = owner:getChar()
                if char then
                    char:setData("armorSetBonus", true)
                    owner:ChatPrint("Armor set bonus activated!")
                end
            end
        end
    end)
    ```
]]
function InventoryItemAdded(inventory, item)
end

--[[
    Purpose:
        Called when an item is removed from an inventory
    When Called:
        When an item is successfully removed from any inventory
    Parameters:
        self (Inventory) - The inventory the item was removed from
        instance (Item) - The item that was removed
        preserveItem (boolean) - Whether the item should be preserved
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item removals
    hook.Add("InventoryItemRemoved", "MyAddon", function(self, instance, preserveItem)
        print("Item " .. instance.uniqueID .. " removed from inventory")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track inventory statistics
    hook.Add("InventoryItemRemoved", "InventoryTracking", function(self, instance, preserveItem)
        local invData = self:getData()
        invData.itemCount = math.max((invData.itemCount or 1) - 1, 0)
        invData.lastItemRemoved = os.time()
        self:setData(invData)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory management system
    hook.Add("InventoryItemRemoved", "AdvancedInventory", function(self, instance, preserveItem)
        local owner = self:getOwner()
        if not owner then return end

            local char = owner:getChar()
            if not char then return end

                -- Update inventory statistics
                local invData = self:getData()
                invData.itemCount = math.max((invData.itemCount or 1) - 1, 0)
                invData.lastItemRemoved = os.time()
                invData.totalValue = math.max((invData.totalValue or 0) - (instance:getData("value", 0)), 0)
                self:setData(invData)

                -- Update weight
                local itemWeight = instance:getData("weight", 1)
                local currentWeight = self:getData("currentWeight", 0)
                self:setData("currentWeight", math.max(currentWeight - itemWeight, 0))

                -- Remove special item effects
                if instance.uniqueID == "health_potion" then
                    char:setData("healthBonus", math.max((char:getData("healthBonus", 0) - 10), 0))
                    elseif instance.uniqueID == "stamina_boost" then
                        char:setData("staminaBonus", math.max((char:getData("staminaBonus", 0) - 5), 0))
                    end

                    -- Check for set bonuses
                    local items = self:getItems()
                    local setItems = {}
                    for _, invItem in pairs(items) do
                        local itemSet = invItem:getData("set")
                        if itemSet then
                            setItems[itemSet] = (setItems[itemSet] or 0) + 1
                        end
                    end

                    -- Remove set bonuses if not enough items
                    for set, count in pairs(setItems) do
                        if count < 3 then
                            char:setData("setBonus_" .. set, false)
                            owner:ChatPrint("Set bonus deactivated: " .. set)
                        end
                    end

                    -- Check if item should be preserved
                    if preserveItem then
                        -- Create dropped item entity
                        local pos = owner:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0)
                        local ent = ents.Create("lia_item")
                        if IsValid(ent) then
                            ent:SetPos(pos)
                            ent:SetItem(instance)
                            ent:Spawn()
                        end
                    end

                    -- Log item removal
                    print(string.format("Item %s removed from inventory %s (Owner: %s, Preserved: %s)",
                    instance.uniqueID, self:getID(), char:getName(), tostring(preserveItem)))
                end)
    ```
]]
--[[
    Purpose:
        Called when an item is removed from an inventory
    When Called:
        When an item is taken out of an inventory
    Parameters:
        self (Item) - The item being removed
        instance (Inventory) - The inventory the item is being removed from
        preserveItem (boolean) - Whether to preserve the item after removal
    Returns:
        None
    Realm:
        Shared
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item removal
    hook.Add("InventoryItemRemoved", "MyAddon", function(self, instance, preserveItem)
        print("Item removed: " .. self.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update inventory weight
    hook.Add("InventoryItemRemoved", "UpdateWeightOnRemove", function(self, instance, preserveItem)
        local currentWeight = instance:getData("weight", 0)
        local itemWeight = self.weight or 1
        instance:setData("weight", math.max(0, currentWeight - itemWeight))
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item removal handling
    hook.Add("InventoryItemRemoved", "AdvancedItemRemoval", function(self, instance, preserveItem)
        if SERVER then
            -- Update inventory weight
            local currentWeight = instance:getData("weight", 0)
            local itemWeight = self.weight or 1
            instance:setData("weight", math.max(0, currentWeight - itemWeight))

            -- Log to database
            lia.db.query("INSERT INTO inventory_logs (timestamp, invid, itemid, action) VALUES (?, ?, ?, ?)",
            os.time(), instance:getID(), self:getID(), "removed")

            -- Notify owner
            local owner = instance:getOwner()
            if IsValid(owner) then
                owner:ChatPrint("Removed " .. self.name .. " from inventory")
            end

            -- Check for set bonus removal
            if string.find(self.uniqueID, "armor_") then
                local items = instance:getItems()
                local armorPieces = 0
                for _, invItem in pairs(items) do
                    if string.find(invItem.uniqueID, "armor_") and invItem ~= self then
                        armorPieces = armorPieces + 1
                    end
                end

                if armorPieces < 3 and IsValid(owner) then
                    local char = owner:getChar()
                    if char and char:getData("armorSetBonus", false) then
                        char:setData("armorSetBonus", false)
                        owner:ChatPrint("Armor set bonus deactivated")
                    end
                end
            end
        end
    end)
    ```
]]
function InventoryItemRemoved(self, instance, preserveItem)
end

--[[
    Purpose:
        Called to check if an entity is suitable for trunk storage
    When Called:
        When determining if an entity can be used as a trunk/storage
    Parameters:
        entity (Entity) - The entity being checked
    Returns:
        boolean - True if suitable, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Only vehicles are suitable
    hook.Add("IsSuitableForTrunk", "MyAddon", function(entity)
        return entity:IsVehicle()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Specific entity classes
    hook.Add("IsSuitableForTrunk", "TrunkEntityCheck", function(entity)
        local suitableClasses = {
        ["prop_vehicle_jeep"] = true,
        ["prop_vehicle_airboat"] = true,
        ["prop_physics"] = true
    }

    return suitableClasses[entity:GetClass()] or false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex trunk suitability system
    hook.Add("IsSuitableForTrunk", "AdvancedTrunkCheck", function(entity)
        if not IsValid(entity) then return false end

            -- Check entity class
            local suitableClasses = {
            ["prop_vehicle_jeep"] = true,
            ["prop_vehicle_airboat"] = true,
            ["prop_physics"] = true
        }

        if not suitableClasses[entity:GetClass()] then
            return false
        end

        -- Check if entity has trunk flag
        if entity:getNetVar("hasTrunk", false) == false then
            return false
        end

        -- Check entity size for props
        if entity:GetClass() == "prop_physics" then
            local mins, maxs = entity:GetCollisionBounds()
            local volume = (maxs.x - mins.x) * (maxs.y - mins.y) * (maxs.z - mins.z)

            if volume < 1000 then -- Too small
                return false
            end
        end

        -- Check if entity is locked
        if entity:getNetVar("locked", false) then
            return false
        end

        return true
    end)
    ```
]]
function IsSuitableForTrunk(entity)
end

--[[
    Purpose:
        Called when items are combined
    When Called:
        When a player attempts to combine two items
    Parameters:
        client (Player) - The player combining items
        item (Item) - The first item
        target (Item) - The second item being combined with
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all combinations
    hook.Add("ItemCombine", "MyAddon", function(client, item, target)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Specific item combinations
    hook.Add("ItemCombine", "ItemCombinations", function(client, item, target)
        -- Allow combining weapon parts
        if item.uniqueID == "weapon_part_a" and target.uniqueID == "weapon_part_b" then
            -- Create combined weapon
            local newItem = lia.item.instance("weapon_combined")
            if newItem then
                local char = client:getChar()
                if char then
                    char:getInv():add(newItem)
                    item:remove()
                    target:remove()
                    client:ChatPrint("Items combined successfully!")
                    return true
                end
            end
        end

        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item combination system
    hook.Add("ItemCombine", "AdvancedItemCombine", function(client, item, target)
        local char = client:getChar()
        if not char then return false end

            -- Define combination recipes
            local recipes = {
            {items = {"weapon_part_a", "weapon_part_b"}, result = "weapon_combined", skill = 5},
                {items = {"metal_ore", "metal_ore"}, result = "metal_bar", skill = 3},
                    {items = {"herb_a", "herb_b"}, result = "potion_health", skill = 7}
                    }

                    -- Check each recipe
                    for _, recipe in ipairs(recipes) do
                        local hasItems = (table.HasValue(recipe.items, item.uniqueID) and table.HasValue(recipe.items, target.uniqueID))

                        if hasItems then
                            -- Check skill requirement
                            local craftingSkill = char:getData("craftingSkill", 0)
                            if craftingSkill < recipe.skill then
                                client:ChatPrint("You need crafting skill level " .. recipe.skill .. " to combine these items")
                                return false
                            end

                            -- Create result item
                            local newItem = lia.item.instance(recipe.result)
                            if newItem then
                                char:getInv():add(newItem)
                                item:remove()
                                target:remove()

                                -- Grant experience
                                local currentSkill = char:getData("craftingSkill", 0)
                                char:setData("craftingSkill", currentSkill + 1)

                                client:ChatPrint("Items combined successfully! Crafting skill increased.")
                                return true
                            end
                        end
                    end

                    client:ChatPrint("These items cannot be combined")
                    return false
                end)
    ```
]]
function ItemCombine(client, item, target)
end

--[[
    Purpose:
        Called when an item is deleted
    When Called:
        When an item is removed from the system
    Parameters:
        instance (Item) - The item being deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item deletion
    hook.Add("ItemDeleted", "MyAddon", function(instance)
        print("Item deleted: " .. instance.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up item data
    hook.Add("ItemDeleted", "CleanupItemData", function(instance)
        -- Remove from cache
        lia.itemCache[instance:getID()] = nil

        print("Item deleted and cleaned up: " .. instance.name)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item deletion handling
    hook.Add("ItemDeleted", "AdvancedItemDeletion", function(instance)
        local itemID = instance:getID()

        -- Archive item data
        lia.db.query("INSERT INTO item_archive SELECT * FROM items WHERE id = ?", itemID)

        -- Clean up related data
        lia.db.query("DELETE FROM item_data WHERE itemid = ?", itemID)
        lia.db.query("DELETE FROM item_logs WHERE itemid = ?", itemID)

        -- Remove from cache
        lia.itemCache[itemID] = nil

        -- Notify owner
        local owner = instance:getOwner()
        if IsValid(owner) then
            owner:ChatPrint(instance.name .. " has been deleted")
        end

        -- Log deletion
        print("Item deleted: " .. instance.name .. " (ID: " .. itemID .. ")")
        lia.log.add("Item " .. instance.name .. " (" .. itemID .. ") was deleted", "item")
    end)
    ```
]]
function ItemDeleted(instance)
end

--[[
    Purpose:
        Called when an item is dragged out of inventory
    When Called:
        When a player drags an item outside the inventory panel
    Parameters:
        client (Player) - The player dragging the item
        item (Item) - The item being dragged
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all drags
    hook.Add("ItemDraggedOutOfInventory", "MyAddon", function(client, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Prevent dragging equipped items
    hook.Add("ItemDraggedOutOfInventory", "PreventEquippedDrag", function(client, item)
        if item:getData("equipped", false) then
            client:ChatPrint("Cannot drag equipped items")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex drag validation
    hook.Add("ItemDraggedOutOfInventory", "AdvancedDragValidation", function(client, item)
        local char = client:getChar()
        if not char then return false end

            -- Prevent dragging equipped items
            if item:getData("equipped", false) then
                client:ChatPrint("Cannot drag equipped items")
                return false
            end

            -- Prevent dragging bound items
            if item:getData("bound", false) then
                local boundTo = item:getData("boundTo")
                if boundTo == char:getID() then
                    client:ChatPrint("This item is bound to you and cannot be dropped")
                    return false
                end
            end

            -- Prevent dragging quest items
            if item:getData("questItem", false) then
                client:ChatPrint("Quest items cannot be dropped")
                return false
            end

            -- Check cooldown
            local lastDrag = char:getData("lastItemDrag", 0)
            if CurTime() - lastDrag < 1 then
                return false
            end

            char:setData("lastItemDrag", CurTime())
            return true
        end)
    ```
]]
function ItemDraggedOutOfInventory(client, item)
end

--[[
    Purpose:
        Called when an item function is called
    When Called:
        When a player uses an item function
    Parameters:
        self (Item) - The item whose function was called
        method (string) - The function name that was called
        client (Player) - The player calling the function
        entity (Entity) - The entity involved (if any)
        results (table) - The results from the function
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log function calls
    hook.Add("ItemFunctionCalled", "MyAddon", function(self, method, client, entity, results)
        print(client:Name() .. " used " .. method .. " on " .. self.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track function usage
    hook.Add("ItemFunctionCalled", "TrackItemUsage", function(self, method, client, entity, results)
        local char = client:getChar()
        if char then
            local usageCount = char:getData("itemUsage_" .. self.uniqueID, 0)
            char:setData("itemUsage_" .. self.uniqueID, usageCount + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex function tracking system
    hook.Add("ItemFunctionCalled", "AdvancedFunctionTracking", function(self, method, client, entity, results)
        local char = client:getChar()
        if not char then return end

            -- Log to database
            lia.db.query("INSERT INTO item_function_logs (timestamp, itemid, method, charid, steamid) VALUES (?, ?, ?, ?, ?)",
            os.time(), self:getID(), method, char:getID(), client:SteamID())

            -- Track usage statistics
            local usageCount = char:getData("itemUsage_" .. self.uniqueID, 0)
            char:setData("itemUsage_" .. self.uniqueID, usageCount + 1)

            -- Check for achievements
            if usageCount + 1 >= 100 then
                if not char:getData("achievement_itemMaster_" .. self.uniqueID, false) then
                    char:setData("achievement_itemMaster_" .. self.uniqueID, true)
                    client:ChatPrint("Achievement unlocked: Master of " .. self.name)
                end
            end

            -- Handle specific methods
            if method == "use" then
                -- Decrease durability
                local durability = self:getData("durability", 100)
                self:setData("durability", math.max(0, durability - 1))
            end

            -- Notify nearby players
            if method == "use" or method == "equip" then
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= client and ply:GetPos():Distance(client:GetPos()) < 500 then
                        ply:ChatPrint(client:Name() .. " used " .. self.name)
                    end
                end
            end
        end)
    ```
]]
function ItemFunctionCalled(self, method, client, entity, results)
end

--[[
    Purpose:
        Called when an item is transferred between inventories
    When Called:
        When an item is successfully moved from one inventory to another
    Parameters:
        context (table) - The transfer context containing source, destination, item, etc.
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item transfers
    hook.Add("ItemTransfered", "MyAddon", function(context)
        print("Item " .. context.item.uniqueID .. " transferred")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track transfer statistics
    hook.Add("ItemTransfered", "TransferTracking", function(context)
        local fromChar = context.fromChar
        local toChar = context.toChar

        if fromChar then
            fromChar:setData("itemsTransferredOut", (fromChar:getData("itemsTransferredOut", 0) + 1))
        end

        if toChar then
            toChar:setData("itemsTransferredIn", (toChar:getData("itemsTransferredIn", 0) + 1))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item transfer system
    hook.Add("ItemTransfered", "AdvancedTransfers", function(context)
        local fromChar = context.fromChar
        local toChar = context.toChar
        local item = context.item
        local fromInv = context.fromInventory
        local toInv = context.toInventory

        -- Update transfer statistics
        if fromChar then
            fromChar:setData("itemsTransferredOut", (fromChar:getData("itemsTransferredOut", 0) + 1))
            fromChar:setData("lastTransferOut", os.time())
        end

        if toChar then
            toChar:setData("itemsTransferredIn", (toChar:getData("itemsTransferredIn", 0) + 1))
            toChar:setData("lastTransferIn", os.time())
        end

        -- Check for transfer limits
        local transferLimit = 100 -- Max transfers per hour
        if fromChar then
            local transfersThisHour = fromChar:getData("transfersThisHour", 0)
            if transfersThisHour >= transferLimit then
                fromChar:getPlayer():ChatPrint("Transfer limit reached for this hour")
                return false
            end
            fromChar:setData("transfersThisHour", transfersThisHour + 1)
        end

        -- Check for valuable item transfers
        local itemValue = item:getData("value", 0)
        if itemValue > 1000 then
            -- Log valuable transfers
            print(string.format("Valuable item %s transferred from %s to %s (Value: $%d)",
            item.uniqueID, fromChar and fromChar:getName() or "Unknown",
            toChar and toChar:getName() or "Unknown", itemValue))
        end

        -- Check for faction restrictions
        if fromChar and toChar then
            local fromFaction = fromChar:getFaction()
            local toFaction = toChar:getFaction()

            if fromFaction == "police" and toFaction == "criminal" then
                -- Police transferring to criminals - log this
                print(string.format("Suspicious transfer: %s (Police) to %s (Criminal)",
                fromChar:getName(), toChar:getName()))
            end
        end

        -- Check for quest items
        if item:getData("questItem", false) then
            local questID = item:getData("questID")
            if questID and toChar then
                toChar:setData("questProgress", toChar:getData("questProgress", {})[questID] + 1)
                    toChar:getPlayer():ChatPrint("Quest progress updated!")
                end
            end

            -- Check for bound items
            if item:getData("bound", false) then
                local boundTo = item:getData("boundTo")
                if boundTo and toChar and boundTo ~= toChar:getID() then
                    toChar:getPlayer():ChatPrint("This item is bound to another character")
                    return false
                end
            end

            -- Log transfer
            print(string.format("Item %s transferred from %s to %s",
            item.uniqueID, fromChar and fromChar:getName() or "Unknown",
            toChar and toChar:getName() or "Unknown"))
        end)
    ```
]]
function ItemTransfered(context)
end

--[[
    Purpose:
        Called when a key locks an entity
    When Called:
        When a key is used to lock a door or entity
    Parameters:
        owner (Player) - The player using the key
        entity (Entity) - The entity being locked
        time (number) - The time taken to lock
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log key lock
    hook.Add("KeyLock", "MyAddon", function(owner, entity, time)
        print(owner:Name() .. " locked " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track lock usage
    hook.Add("KeyLock", "TrackLocks", function(owner, entity, time)
        local char = owner:getChar()
        if not char then return end

            local locks = char:getData("locksUsed", 0)
            char:setData("locksUsed", locks + 1)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex key lock system
    hook.Add("KeyLock", "AdvancedKeyLock", function(owner, entity, time)
        local char = owner:getChar()
        if not char then return end

            -- Update entity data
            entity:setNetVar("locked", true)
            entity:setNetVar("lockedBy", char:getID())
            entity:setNetVar("lockedAt", os.time())

            -- Log to database
            lia.db.query("INSERT INTO lock_logs (timestamp, steamid, entityid, action) VALUES (?, ?, ?, ?)",
            os.time(), owner:SteamID(), entity:EntIndex(), "locked")

            -- Update character stats
            local locks = char:getData("locksUsed", 0)
            char:setData("locksUsed", locks + 1)
            char:setData("lastLockTime", os.time())

            -- Notify nearby players
            local pos = entity:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(pos) < 500 and ply ~= owner then
                    ply:ChatPrint("You hear a lock clicking nearby")
                end
            end
        end)
    ```
]]
function KeyLock(owner, entity, time)
end

--[[
    Purpose:
        Called when a key unlocks an entity
    When Called:
        When a key is used to unlock a door or entity
    Parameters:
        owner (Player) - The player using the key
        entity (Entity) - The entity being unlocked
        time (number) - The time taken to unlock
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log key unlock
    hook.Add("KeyUnlock", "MyAddon", function(owner, entity, time)
        print(owner:Name() .. " unlocked " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track unlock usage
    hook.Add("KeyUnlock", "TrackUnlocks", function(owner, entity, time)
        local char = owner:getChar()
        if not char then return end

            local unlocks = char:getData("unlocksUsed", 0)
            char:setData("unlocksUsed", unlocks + 1)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex key unlock system
    hook.Add("KeyUnlock", "AdvancedKeyUnlock", function(owner, entity, time)
        local char = owner:getChar()
        if not char then return end

            -- Update entity data
            entity:setNetVar("locked", false)
            entity:setNetVar("unlockedBy", char:getID())
            entity:setNetVar("unlockedAt", os.time())

            -- Log to database
            lia.db.query("INSERT INTO lock_logs (timestamp, steamid, entityid, action) VALUES (?, ?, ?, ?)",
            os.time(), owner:SteamID(), entity:EntIndex(), "unlocked")

            -- Update character stats
            local unlocks = char:getData("unlocksUsed", 0)
            char:setData("unlocksUsed", unlocks + 1)
            char:setData("lastUnlockTime", os.time())

            -- Notify nearby players
            local pos = entity:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(pos) < 500 and ply ~= owner then
                    ply:ChatPrint("You hear a lock clicking nearby")
                end
            end
        end)
    ```
]]
function KeyUnlock(owner, entity, time)
end

--[[
    Purpose:
        Called when Lilia database tables are loaded
    When Called:
        After database tables are created/loaded
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log tables loaded
    hook.Add("LiliaTablesLoaded", "MyAddon", function()
        print("Lilia tables loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Create custom tables
    hook.Add("LiliaTablesLoaded", "CreateCustomTables", function()
        lia.db.query("CREATE TABLE IF NOT EXISTS my_table (id INTEGER PRIMARY KEY, data TEXT)")
        print("Custom tables created")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database initialization
    hook.Add("LiliaTablesLoaded", "AdvancedDatabaseInit", function()
        -- Create custom tables
        local tables = {
        "CREATE TABLE IF NOT EXISTS my_table (id INTEGER PRIMARY KEY, data TEXT)",
        "CREATE TABLE IF NOT EXISTS my_stats (charid INTEGER, stat TEXT, value INTEGER)",
        "CREATE TABLE IF NOT EXISTS my_logs (timestamp INTEGER, message TEXT)"
    }

    for _, query in ipairs(tables) do
        lia.db.query(query)
    end

    -- Create indexes
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_my_stats_charid ON my_stats(charid)")

    print("Custom database tables and indexes created")
    end)
    ```
]]
function LiliaTablesLoaded()
end

--[[
    Purpose:
        Called to load persistent data
    When Called:
        When data needs to be loaded from storage
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data load
    hook.Add("LoadData", "MyAddon", function()
        print("Loading data")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load custom data
    hook.Add("LoadData", "LoadCustomData", function()
        local data = lia.data.get("myAddonData", {})
        MyAddon.data = data
        print("Custom data loaded")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data loading system
    hook.Add("LoadData", "AdvancedDataLoad", function()
        -- Load custom data
        local data = lia.data.get("myAddonData", {})
        MyAddon.data = data

        -- Load from database
        lia.db.query("SELECT * FROM my_table", function(results)
        if results then
            for _, row in ipairs(results) do
                MyAddon.ProcessData(row)
            end
        end
    end)

    -- Initialize data structures
    MyAddon.playerData = MyAddon.playerData or {}
        MyAddon.sessionData = {}

            print("All data loaded successfully")
        end)
    ```
]]
function LoadData()
end

--[[
    Purpose:
        Called to modify a character's model
    When Called:
        When a character's model is being set
    Parameters:
        client (Player) - The player
        character (Character) - The character whose model is being modified
    Returns:
        string - The modified model path
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default model
    hook.Add("ModifyCharacterModel", "MyAddon", function(client, character)
        return character:getModel()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-based models
    hook.Add("ModifyCharacterModel", "FactionModels", function(client, character)
        local faction = character:getFaction()

        if faction == "police" then
            return "models/player/police.mdl"
            elseif faction == "medic" then
                return "models/player/medic.mdl"
            end

            return character:getModel()
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model modification system
    hook.Add("ModifyCharacterModel", "AdvancedModelModification", function(client, character)
        local baseModel = character:getModel()

        -- Check for outfit override
        local outfit = character:getData("outfit")
        if outfit then
            local outfitItem = lia.item.instances[outfit]
            if outfitItem and outfitItem.model then
                return outfitItem.model
            end
        end

        -- Check faction models
        local faction = lia.faction.indices[character:getFaction()]
        if faction and faction.models then
            local modelIndex = character:getData("modelIndex", 1)
            if faction.models[modelIndex] then
                return faction.models[modelIndex]
            end
        end

        -- Check for transformation effects
        if character:getData("transformed", false) then
            local transformModel = character:getData("transformModel")
            if transformModel then
                return transformModel
            end
        end

        return baseModel
    end)
    ```
]]
function ModifyCharacterModel(client, character)
end

--[[
    Purpose:
        Called when admin system is loaded
    When Called:
        After admin groups and privileges are initialized
    Parameters:
        groups (table) - The admin groups table
        privileges (table) - The privileges table
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log admin system load
    hook.Add("OnAdminSystemLoaded", "MyAddon", function(groups, privileges)
        print("Admin system loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom admin groups
    hook.Add("OnAdminSystemLoaded", "AddCustomAdminGroups", function(groups, privileges)
        groups["moderator"] = {
            name = "Moderator",
            immunity = 50
        }
        print("Custom admin groups added")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex admin system customization
    hook.Add("OnAdminSystemLoaded", "AdvancedAdminCustomization", function(groups, privileges)
        -- Add custom admin groups
        groups["moderator"] = {
            name = "Moderator",
            immunity = 50,
            color = Color(0, 200, 0)
        }

        groups["headAdmin"] = {
            name = "Head Admin",
            immunity = 90,
            color = Color(255, 0, 0)
        }

        -- Add custom privileges
        privileges["canManageEvents"] = {
            name = "Can Manage Events",
            description = "Allows managing server events"
        }

        privileges["canEditVendors"] = {
            name = "Can Edit Vendors",
            description = "Allows editing vendor inventories"
        }

        print("Admin system customized with new groups and privileges")
    end)
    ```
]]
function OnAdminSystemLoaded(groups, privileges)
end

--[[
    Purpose:
        Called when a backup is created
    When Called:
        After a data backup is successfully created
    Parameters:
        metadata (table) - The backup metadata
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log backup creation
    hook.Add("OnBackupCreated", "MyAddon", function(metadata)
        print("Backup created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Log backup details
    hook.Add("OnBackupCreated", "LogBackupDetails", function(metadata)
        print("Backup created: " .. metadata.filename)
        print("Size: " .. metadata.size .. " bytes")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex backup management
    hook.Add("OnBackupCreated", "AdvancedBackupManagement", function(metadata)
        -- Log backup creation
        print("Backup created: " .. metadata.filename)
        print("Size: " .. metadata.size .. " bytes")
        print("Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S", metadata.timestamp))

        -- Store backup metadata
        lia.db.query("INSERT INTO backups (timestamp, filename, size) VALUES (?, ?, ?)",
        metadata.timestamp, metadata.filename, metadata.size)

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[BACKUP] New backup created: " .. metadata.filename)
            end
        end

        -- Clean up old backups
        local maxBackups = 10
        lia.db.query("SELECT COUNT(*) as count FROM backups", function(results)
        if results and results[1] and results[1].count > maxBackups then
            lia.db.query("DELETE FROM backups WHERE id IN (SELECT id FROM backups ORDER BY timestamp ASC LIMIT 1)")
            print("Old backup deleted to maintain backup limit")
        end
    end)
    end)
    ```
]]
function OnBackupCreated(metadata)
end

--[[
    Purpose:
        Called when a character attribute is boosted
    When Called:
        When a character's attribute is increased
    Parameters:
        character (Character) - The character whose attribute was boosted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log attribute boost
    hook.Add("OnCharAttribBoosted", "MyAddon", function(character)
        print(character:getName() .. " boosted an attribute")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track attribute boosts
    hook.Add("OnCharAttribBoosted", "TrackAttributeBoosts", function(character)
        local boosts = character:getData("attributeBoosts", 0)
        character:setData("attributeBoosts", boosts + 1)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex attribute boost system
    hook.Add("OnCharAttribBoosted", "AdvancedAttributeBoost", function(character)
        local boosts = character:getData("attributeBoosts", 0)
        character:setData("attributeBoosts", boosts + 1)

        -- Log to database
        lia.db.query("INSERT INTO attribute_logs (timestamp, charid, action) VALUES (?, ?, ?)",
        os.time(), character:getID(), "boosted")

        -- Notify player
        local client = character:getPlayer()
        if IsValid(client) then
            client:ChatPrint("Attribute boosted! Total boosts: " .. (boosts + 1))
        end

        -- Check for achievements
        if boosts + 1 >= 50 then
            if not character:getData("achievement_attributeMaster", false) then
                character:setData("achievement_attributeMaster", true)
                if IsValid(client) then
                    client:ChatPrint("Achievement unlocked: Attribute Master!")
                end
            end
        end
    end)
    ```
]]
function OnCharAttribBoosted(character)
end

--[[
    Purpose:
        Called when a character attribute is updated
    When Called:
        When a character's attribute value changes
    Parameters:
        client (Player) - The player
        character (Character) - The character
        key (string) - The attribute key
        newValue (number) - The new attribute value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log attribute updates
    hook.Add("OnCharAttribUpdated", "MyAddon", function(client, character, key, newValue)
        print(character:getName() .. " " .. key .. " updated to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track attribute changes
    hook.Add("OnCharAttribUpdated", "TrackAttributeChanges", function(client, character, key, newValue)
        local changes = character:getData("attributeChanges", {})
        changes[key] = (changes[key] or 0) + 1
        character:setData("attributeChanges", changes)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex attribute tracking system
    hook.Add("OnCharAttribUpdated", "AdvancedAttributeTracking", function(client, character, key, newValue)
        -- Log to database
        lia.db.query("INSERT INTO attribute_logs (timestamp, charid, attribute, value) VALUES (?, ?, ?, ?)",
        os.time(), character:getID(), key, newValue)

        -- Track changes
        local changes = character:getData("attributeChanges", {})
        changes[key] = (changes[key] or 0) + 1
        character:setData("attributeChanges", changes)

        -- Notify player
        client:ChatPrint(key .. " updated to " .. newValue)

        -- Apply attribute effects
        if key == "str" then
            -- Strength affects melee damage
            local damageBonus = newValue * 0.5
            character:setData("meleeDamageBonus", damageBonus)
            elseif key == "end" then
                -- Endurance affects max health
                local healthBonus = newValue * 2
                client:SetMaxHealth(100 + healthBonus)
                elseif key == "agi" then
                    -- Agility affects movement speed
                    local speedBonus = 1 + (newValue * 0.01)
                    client:SetRunSpeed(250 * speedBonus)
                    client:SetWalkSpeed(100 * speedBonus)
                end
            end)
    ```
]]
function OnCharAttribUpdated(client, character, key, newValue)
end

--[[
    Purpose:
        Called when a character is created
    When Called:
        When a new character is successfully created
    Parameters:
        client (Player) - The player who created the character
        character (Character) - The character that was created
        originalData (table) - The original character data before any modifications
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character creation
    hook.Add("OnCharCreated", "MyAddon", function(client, character, originalData)
        print(client:Name() .. " created character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up new character bonuses
    hook.Add("OnCharCreated", "NewCharBonuses", function(client, character, originalData)
        -- Give starting money bonus
        local bonusMoney = 500
        character:setMoney(character:getMoney() + bonusMoney)

        -- Give starting items
        local startingItems = {"wallet", "phone", "id_card"}
        for _, itemID in ipairs(startingItems) do
            local item = lia.item.instance(itemID)
            if item then
                character:getInv():add(item)
            end
        end

        client:ChatPrint("Welcome! You received starting bonuses.")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation system
    hook.Add("OnCharCreated", "AdvancedCreation", function(client, character, originalData)
        local faction = character:getFaction()

        -- Set up faction-specific starting equipment
        local factionEquipment = {
        ["police"] = {
            items = {"police_badge", "handcuffs", "radio"},
                money = 1000,
                attributes = {str = 5, con = 4, dex = 3}
                    },
                    ["medic"] = {
                        items = {"medkit", "stethoscope", "bandage"},
                            money = 800,
                            attributes = {int = 6, wis = 5, con = 4}
                                },
                                ["citizen"] = {
                                    items = {"wallet", "phone"},
                                        money = 500,
                                        attributes = {str = 3, con = 3, dex = 3}
                                        }
                                    }

                                    local equipment = factionEquipment[faction]
                                    if equipment then
                                        -- Give faction-specific money
                                        character:setMoney(character:getMoney() + equipment.money)

                                        -- Give faction-specific items
                                        for _, itemID in ipairs(equipment.items) do
                                            local item = lia.item.instance(itemID)
                                            if item then
                                                character:getInv():add(item)
                                            end
                                        end

                                        -- Set faction-specific attributes
                                        for attr, value in pairs(equipment.attributes) do
                                            character:setAttrib(attr, value)
                                        end
                                    end

                                    -- Set up character data
                                    character:setData("creationTime", os.time())
                                    character:setData("creationIP", client:IPAddress())
                                    character:setData("level", 1)
                                    character:setData("experience", 0)

                                    -- Send welcome message
                                    client:ChatPrint("Character created successfully! Welcome to the server.")

                                    -- Log creation
                                    print(string.format("%s created %s character: %s",
                                    client:Name(), faction, character:getName()))
                                end)
    ```
]]
function OnCharCreated(client, character, originalData)
end

--[[
    Purpose:
        Called when a character is deleted
    When Called:
        When a character is successfully deleted
    Parameters:
        client (Player) - The player who deleted the character
        id (number) - The ID of the character that was deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character deletion
    hook.Add("OnCharDelete", "MyAddon", function(client, id)
        print(client:Name() .. " deleted character ID: " .. id)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track deletion statistics
    hook.Add("OnCharDelete", "DeletionTracking", function(client, id)
        local char = client:getChar()
        if char then
            char:setData("charactersDeleted", (char:getData("charactersDeleted", 0) + 1))
            char:setData("lastCharDelete", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character deletion system
    hook.Add("OnCharDelete", "AdvancedDeletion", function(client, id)
        local char = client:getChar()
        if not char then return end

            -- Update deletion statistics
            char:setData("charactersDeleted", (char:getData("charactersDeleted", 0) + 1))
            char:setData("lastCharDelete", os.time())

            -- Check for deletion cooldown
            local lastDelete = char:getData("lastCharDelete", 0)
            local deleteCooldown = 3600 -- 1 hour
            if os.time() - lastDelete < deleteCooldown then
                client:ChatPrint("You must wait before deleting another character")
                return false
            end

            -- Check for valuable items
            local charInv = char:getInv()
            local valuableItems = {}
            for _, item in pairs(charInv:getItems()) do
                if item:getData("value", 0) > 1000 then
                    table.insert(valuableItems, item)
                end
            end

            if #valuableItems > 0 then
                client:ChatPrint("Warning: You have valuable items. Are you sure you want to delete this character?")
                return false
            end

            -- Check for faction restrictions
            local faction = char:getFaction()
            if faction ~= "citizen" then
                client:ChatPrint("You must leave your faction before deleting this character")
                return false
            end

            -- Check for active quests
            local activeQuests = char:getData("activeQuests", {})
            if #activeQuests > 0 then
                client:ChatPrint("You have active quests. Complete them before deleting this character")
                return false
            end

            -- Log deletion
            print(string.format("%s deleted character ID %d (Faction: %s)",
            client:Name(), id, faction))

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() and ply ~= client then
                    ply:ChatPrint("[ADMIN] " .. client:Name() .. " deleted character ID " .. id)
                end
            end
        end)
    ```
]]
function OnCharDelete(client, id)
end

--[[
    Purpose:
        Called when a character disconnects
    When Called:
        When a player disconnects while having a character loaded
    Parameters:
        client (Player) - The player who disconnected
        character (Character) - The character that was loaded when disconnecting
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character disconnect
    hook.Add("OnCharDisconnect", "MyAddon", function(client, character)
        print(client:Name() .. " disconnected with character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save character data on disconnect
    hook.Add("OnCharDisconnect", "CharDisconnectSave", function(client, character)
        -- Save character position
        character:setData("lastPos", client:GetPos())
        character:setData("lastAng", client:GetAngles())

        -- Save character health and armor
        character:setData("lastHealth", client:Health())
        character:setData("lastArmor", client:Armor())

        -- Save disconnect time
        character:setData("lastDisconnect", os.time())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character disconnect system
    hook.Add("OnCharDisconnect", "AdvancedCharDisconnect", function(client, character)
        -- Save character state
        character:setData("lastPos", client:GetPos())
        character:setData("lastAng", client:GetAngles())
        character:setData("lastHealth", client:Health())
        character:setData("lastArmor", client:Armor())
        character:setData("lastDisconnect", os.time())

        -- Save inventory state
        local inventory = character:getInv()
        if inventory then
            character:setData("inventoryState", inventory:getData())
        end

        -- Save character money
        character:setData("lastMoney", character:getMoney())

        -- Save character attributes
        local attributes = character:getAttribs()
        character:setData("lastAttributes", attributes)

        -- Save character data
        local charData = character:getData()
        character:setData("lastCharData", charData)

        -- Check for active effects
        local activeEffects = character:getData("activeEffects", {})
        if #activeEffects > 0 then
            -- Pause active effects
            for _, effect in ipairs(activeEffects) do
                effect.paused = true
                effect.pauseTime = os.time()
            end
            character:setData("activeEffects", activeEffects)
        end

        -- Check for active quests
        local activeQuests = character:getData("activeQuests", {})
        if #activeQuests > 0 then
            -- Pause active quests
            for _, quest in ipairs(activeQuests) do
                quest.paused = true
                quest.pauseTime = os.time()
            end
            character:setData("activeQuests", activeQuests)
        end

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(character:getName() .. " has disconnected")
            end
        end

        -- Log disconnect
        print(string.format("%s disconnected with character %s (Faction: %s)",
        client:Name(), character:getName(), character:getFaction()))
    end)
    ```
]]
function OnCharDisconnect(client, character)
end

--[[
    Purpose:
        Called when a character falls over
    When Called:
        When a character's health reaches zero or they are knocked down
    Parameters:
        character (Character) - The character that fell over
        client (Player) - The player whose character fell over
        ragdoll (Entity) - The ragdoll entity created
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character fallover
    hook.Add("OnCharFallover", "MyAddon", function(character, client, ragdoll)
        print(character:getName() .. " fell over")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle fallover effects
    hook.Add("OnCharFallover", "FalloverEffects", function(character, client, ragdoll)
        -- Set character as unconscious
        character:setData("unconscious", true)
        character:setData("falloverTime", os.time())

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(client:GetPos()) < 500 then
                ply:ChatPrint(character:getName() .. " has fallen unconscious")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex fallover system
    hook.Add("OnCharFallover", "AdvancedFallover", function(character, client, ragdoll)
        -- Set character as unconscious
        character:setData("unconscious", true)
        character:setData("falloverTime", os.time())

        -- Set ragdoll data
        if IsValid(ragdoll) then
            ragdoll:setNetVar("charID", character:getID())
            ragdoll:setNetVar("charName", character:getName())
            ragdoll:setNetVar("faction", character:getFaction())
            ragdoll:setNetVar("falloverTime", os.time())
        end

        -- Check for faction-specific effects
        local faction = character:getFaction()
        if faction == "police" then
            -- Police get backup call
            for _, ply in ipairs(player.GetAll()) do
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == "police" then
                    ply:ChatPrint("[BACKUP] " .. character:getName() .. " is down! Location: " .. client:GetPos())
                end
            end
            elseif faction == "medic" then
                -- Medics get medical alert
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "medic" then
                        ply:ChatPrint("[MEDICAL] " .. character:getName() .. " needs help! Location: " .. client:GetPos())
                    end
                end
            end

            -- Check for active quests
            local activeQuests = character:getData("activeQuests", {})
            for _, quest in ipairs(activeQuests) do
                if quest.type == "survival" then
                    quest.failed = true
                    quest.failTime = os.time()
                end
            end

            -- Check for active effects
            local activeEffects = character:getData("activeEffects", {})
            for _, effect in ipairs(activeEffects) do
                if effect.type == "healing" then
                    effect.paused = true
                    effect.pauseTime = os.time()
                end
            end

            -- Set up revival timer
            local revivalTime = 300 -- 5 minutes
            character:setData("revivalTime", os.time() + revivalTime)

            -- Start revival timer
            timer.Simple(revivalTime, function()
            if IsValid(client) and character:getData("unconscious", false) then
                character:setData("unconscious", false)
                character:setData("revivalTime", nil)
                client:ChatPrint("You have regained consciousness")
            end
        end)

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(client:GetPos()) < 500 then
                ply:ChatPrint(character:getName() .. " has fallen unconscious")
            end
        end

        -- Log fallover
        print(string.format("%s fell over (Faction: %s, Health: %d)",
        character:getName(), faction, client:Health()))
    end)
    ```
]]
--[[
    Purpose:
        Called when a character falls over
    When Called:
        When a character is knocked down/ragdolled
    Parameters:
        character (Character) - The character falling over
        client (Player) - The player
        ragdoll (Entity) - The ragdoll entity created
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log fallover
    hook.Add("OnCharFallover", "MyAddon", function(character, client, ragdoll)
        print(character:getName() .. " fell over")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set ragdoll data
    hook.Add("OnCharFallover", "SetRagdollData", function(character, client, ragdoll)
        ragdoll:setNetVar("charID", character:getID())
        ragdoll:setNetVar("fallTime", os.time())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex fallover system
    hook.Add("OnCharFallover", "AdvancedFallover", function(character, client, ragdoll)
        -- Set ragdoll data
        ragdoll:setNetVar("charID", character:getID())
        ragdoll:setNetVar("fallTime", os.time())
        ragdoll:setNetVar("charName", character:getName())

        -- Track fallover count
        local fallCount = character:getData("fallCount", 0)
        character:setData("fallCount", fallCount + 1)

        -- Apply faction-specific effects
        local faction = character:getFaction()
        if faction == "police" then
            -- Police get up faster
            timer.Simple(5, function()
            if IsValid(ragdoll) and IsValid(client) then
                client:SetRagdolled(false)
            end
        end)
    end

    -- Notify nearby players
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= client and ply:GetPos():Distance(client:GetPos()) < 500 then
            ply:ChatPrint(character:getName() .. " fell over")
        end
    end
    end)
    ```
]]
function OnCharFallover(character, client, ragdoll)
end

--[[
    Purpose:
        Called when flags are given to a character
    When Called:
        When a character receives new flags
    Parameters:
        ply (Player) - The player receiving flags
        self (Character) - The character receiving flags
        addedFlags (string) - The flags that were added
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log flags given
    hook.Add("OnCharFlagsGiven", "MyAddon", function(ply, self, addedFlags)
        print(self:getName() .. " received flags: " .. addedFlags)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track flag changes
    hook.Add("OnCharFlagsGiven", "TrackFlagChanges", function(ply, self, addedFlags)
        local flagHistory = self:getData("flagHistory", {})
        table.insert(flagHistory, {action = "given", flags = addedFlags, time = os.time()})
            self:setData("flagHistory", flagHistory)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex flag management system
    hook.Add("OnCharFlagsGiven", "AdvancedFlagManagement", function(ply, self, addedFlags)
        -- Log to database
        lia.db.query("INSERT INTO flag_logs (timestamp, charid, action, flags) VALUES (?, ?, ?, ?)",
        os.time(), self:getID(), "given", addedFlags)

        -- Track flag history
        local flagHistory = self:getData("flagHistory", {})
        table.insert(flagHistory, {action = "given", flags = addedFlags, time = os.time()})
            self:setData("flagHistory", flagHistory)

            -- Notify player
            ply:ChatPrint("You received flags: " .. addedFlags)

            -- Apply flag-specific effects
            for i = 1, #addedFlags do
                local flag = addedFlags:sub(i, i)

                if flag == "v" then
                    -- VIP flag
                    ply:ChatPrint("You are now a VIP!")
                    elseif flag == "a" then
                        -- Admin flag
                        ply:ChatPrint("You now have admin privileges!")
                    end
                end

                -- Notify admins
                for _, admin in ipairs(player.GetAll()) do
                    if admin:IsAdmin() and admin ~= ply then
                        admin:ChatPrint("[FLAGS] " .. self:getName() .. " received flags: " .. addedFlags)
                    end
                end
            end)
    ```
]]
function OnCharFlagsGiven(ply, self, addedFlags)
end

--[[
    Purpose:
        Called when flags are taken from a character
    When Called:
        When a character loses flags
    Parameters:
        ply (Player) - The player losing flags
        self (Character) - The character losing flags
        removedFlags (string) - The flags that were removed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log flags taken
    hook.Add("OnCharFlagsTaken", "MyAddon", function(ply, self, removedFlags)
        print(self:getName() .. " lost flags: " .. removedFlags)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track flag removals
    hook.Add("OnCharFlagsTaken", "TrackFlagRemovals", function(ply, self, removedFlags)
        local flagHistory = self:getData("flagHistory", {})
        table.insert(flagHistory, {action = "taken", flags = removedFlags, time = os.time()})
            self:setData("flagHistory", flagHistory)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex flag removal system
    hook.Add("OnCharFlagsTaken", "AdvancedFlagRemoval", function(ply, self, removedFlags)
        -- Log to database
        lia.db.query("INSERT INTO flag_logs (timestamp, charid, action, flags) VALUES (?, ?, ?, ?)",
        os.time(), self:getID(), "taken", removedFlags)

        -- Track flag history
        local flagHistory = self:getData("flagHistory", {})
        table.insert(flagHistory, {action = "taken", flags = removedFlags, time = os.time()})
            self:setData("flagHistory", flagHistory)

            -- Notify player
            ply:ChatPrint("You lost flags: " .. removedFlags)

            -- Remove flag-specific effects
            for i = 1, #removedFlags do
                local flag = removedFlags:sub(i, i)

                if flag == "v" then
                    -- VIP flag removed
                    ply:ChatPrint("Your VIP status has been revoked")
                    elseif flag == "a" then
                        -- Admin flag removed
                        ply:ChatPrint("Your admin privileges have been revoked")
                    end
                end

                -- Notify admins
                for _, admin in ipairs(player.GetAll()) do
                    if admin:IsAdmin() and admin ~= ply then
                        admin:ChatPrint("[FLAGS] " .. self:getName() .. " lost flags: " .. removedFlags)
                    end
                end
            end)
    ```
]]
function OnCharFlagsTaken(ply, self, removedFlags)
end

--[[
    Purpose:
        Called when a character gets up from being unconscious
    When Called:
        When a character regains consciousness or is revived
    Parameters:
        target (Player) - The player whose character got up
        entity (Entity) - The ragdoll entity that was removed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character getup
    hook.Add("OnCharGetup", "MyAddon", function(target, entity)
        print(target:Name() .. " got up")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle getup effects
    hook.Add("OnCharGetup", "GetupEffects", function(target, entity)
        local char = target:getChar()
        if char then
            -- Clear unconscious status
            char:setData("unconscious", false)
            char:setData("getupTime", os.time())

            -- Restore some health
            local currentHealth = target:Health()
            local maxHealth = target:GetMaxHealth()
            target:SetHealth(math.min(currentHealth + 25, maxHealth))

            target:ChatPrint("You have regained consciousness")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex getup system
    hook.Add("OnCharGetup", "AdvancedGetup", function(target, entity)
        local char = target:getChar()
        if not char then return end

            -- Clear unconscious status
            char:setData("unconscious", false)
            char:setData("getupTime", os.time())
            char:setData("revivalTime", nil)

            -- Restore health based on faction
            local faction = char:getFaction()
            local healthRestore = {
            ["police"] = 50,
            ["medic"] = 75,
            ["citizen"] = 25
        }

        local restoreAmount = healthRestore[faction] or 25
        local currentHealth = target:Health()
        local maxHealth = target:GetMaxHealth()
        target:SetHealth(math.min(currentHealth + restoreAmount, maxHealth))

        -- Restore stamina
        local currentStamina = target:getNetVar("stamina", 100)
        target:setNetVar("stamina", math.min(currentStamina + 50, 100))

        -- Resume active effects
        local activeEffects = char:getData("activeEffects", {})
        for _, effect in ipairs(activeEffects) do
            if effect.paused then
                effect.paused = false
                effect.pauseTime = nil
            end
        end
        char:setData("activeEffects", activeEffects)

        -- Resume active quests
        local activeQuests = char:getData("activeQuests", {})
        for _, quest in ipairs(activeQuests) do
            if quest.paused then
                quest.paused = false
                quest.pauseTime = nil
            end
        end
        char:setData("activeQuests", activeQuests)

        -- Check for revival achievements
        local revivals = char:getData("revivals", 0) + 1
        char:setData("revivals", revivals)

        if revivals >= 10 and not char:getData("achievement_survivor", false) then
            char:setData("achievement_survivor", true)
            target:ChatPrint("Achievement unlocked: Survivor!")
        end

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(target:GetPos()) < 500 then
                ply:ChatPrint(char:getName() .. " has regained consciousness")
            end
        end

        -- Log getup
        print(string.format("%s got up (Faction: %s, Health: %d)",
        char:getName(), faction, target:Health()))
    end)
    ```
]]
function OnCharGetup(target, entity)
end

--[[
    Purpose:
        Called when a character is kicked
    When Called:
        When a character is kicked from the server
    Parameters:
        self (Character) - The character being kicked
        client (Player) - The player being kicked
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character kick
    hook.Add("OnCharKick", "MyAddon", function(self, client)
        print(self:getName() .. " was kicked")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle kick effects
    hook.Add("OnCharKick", "KickEffects", function(self, client)
        -- Save character data
        self:setData("lastKick", os.time())
        self:setData("kickCount", (self:getData("kickCount", 0) + 1))

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(self:getName() .. " was kicked from the server")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex kick system
    hook.Add("OnCharKick", "AdvancedKick", function(self, client)
        -- Save character data
        self:setData("lastKick", os.time())
        self:setData("kickCount", (self:getData("kickCount", 0) + 1))

        -- Save character state
        self:setData("lastPos", client:GetPos())
        self:setData("lastAng", client:GetAngles())
        self:setData("lastHealth", client:Health())
        self:setData("lastArmor", client:Armor())

        -- Save inventory state
        local inventory = self:getInv()
        if inventory then
            self:setData("inventoryState", inventory:getData())
        end

        -- Check for kick reasons
        local kickReason = client:getData("kickReason", "Unknown")
        self:setData("lastKickReason", kickReason)

        -- Check for faction-specific effects
        local faction = self:getFaction()
        if faction == "police" then
            -- Police get backup call
            for _, ply in ipairs(player.GetAll()) do
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == "police" then
                    ply:ChatPrint("[BACKUP] " .. self:getName() .. " was kicked! Reason: " .. kickReason)
                end
            end
            elseif faction == "medic" then
                -- Medics get medical alert
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "medic" then
                        ply:ChatPrint("[MEDICAL] " .. self:getName() .. " was kicked! Reason: " .. kickReason)
                    end
                end
            end

            -- Check for active quests
            local activeQuests = self:getData("activeQuests", {})
            for _, quest in ipairs(activeQuests) do
                if quest.type == "survival" then
                    quest.failed = true
                    quest.failTime = os.time()
                end
            end

            -- Check for active effects
            local activeEffects = self:getData("activeEffects", {})
            for _, effect in ipairs(activeEffects) do
                effect.paused = true
                effect.pauseTime = os.time()
            end

            -- Notify other players
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= client then
                    ply:ChatPrint(self:getName() .. " was kicked from the server")
                end
            end

            -- Log kick
            print(string.format("%s was kicked (Faction: %s, Reason: %s)",
            self:getName(), faction, kickReason))
        end)
    ```
]]
function OnCharKick(self, client)
end

--[[
    Purpose:
        Called when a character's network variable changes
    When Called:
        When a character's networked data is modified
    Parameters:
        character (Character) - The character whose variable changed
        key (string) - The name of the variable that changed
        oldVar (any) - The previous value of the variable
        value (any) - The new value of the variable
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log network variable changes
    hook.Add("OnCharNetVarChanged", "MyAddon", function(character, key, oldVar, value)
        print(character:getName() .. " netvar changed: " .. key .. " = " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track specific variable changes
    hook.Add("OnCharNetVarChanged", "NetVarTracking", function(character, key, oldVar, value)
        if key == "health" then
            local client = character:getPlayer()
            if client then
                client:ChatPrint("Health changed from " .. oldVar .. " to " .. value)
            end
            elseif key == "money" then
                local client = character:getPlayer()
                if client then
                    client:ChatPrint("Money changed from $" .. oldVar .. " to $" .. value)
                end
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex network variable system
    hook.Add("OnCharNetVarChanged", "AdvancedNetVar", function(character, key, oldVar, value)
        local client = character:getPlayer()
        if not client then return end

            -- Track variable change history
            local changeHistory = character:getData("netVarHistory", {})
            changeHistory[key] = changeHistory[key] or {}
                table.insert(changeHistory[key], {
                    oldValue = oldVar,
                    newValue = value,
                    timestamp = os.time()
                    })

                    -- Keep only last 10 changes per variable
                    if #changeHistory[key] > 10 then
                        table.remove(changeHistory[key], 1)
                    end

                    character:setData("netVarHistory", changeHistory)

                    -- Handle specific variable changes
                    if key == "health" then
                        -- Health change effects
                        if value <= 0 and oldVar > 0 then
                            -- Character died
                            hook.Run("OnCharacterDeath", character)
                            elseif value > 0 and oldVar <= 0 then
                                -- Character revived
                                hook.Run("OnCharacterRevive", character)
                            end

                            -- Notify nearby players of health change
                            for _, ply in ipairs(player.GetAll()) do
                                if ply:GetPos():Distance(client:GetPos()) < 500 then
                                    ply:ChatPrint(character:getName() .. "'s health: " .. value .. "/" .. client:GetMaxHealth())
                                end
                            end

                            elseif key == "money" then
                                -- Money change effects
                                local difference = value - oldVar
                                if difference > 0 then
                                    client:ChatPrint("You gained $" .. difference)
                                    elseif difference < 0 then
                                        client:ChatPrint("You lost $" .. math.abs(difference))
                                    end

                                    -- Check for money milestones
                                    if value >= 10000 and oldVar < 10000 then
                                        client:ChatPrint("Congratulations! You've reached $10,000!")
                                        elseif value >= 100000 and oldVar < 100000 then
                                            client:ChatPrint("Congratulations! You've reached $100,000!")
                                        end

                                        elseif key == "level" then
                                            -- Level change effects
                                            if value > oldVar then
                                                hook.Run("OnPlayerLevelUp", client, oldVar, value)
                                            end

                                            elseif key == "faction" then
                                                -- Faction change effects
                                                client:SetTeam(value)
                                                client:ChatPrint("Faction changed to: " .. value)

                                                -- Notify other players
                                                for _, ply in ipairs(player.GetAll()) do
                                                    if ply ~= client then
                                                        ply:ChatPrint(character:getName() .. " joined faction: " .. value)
                                                    end
                                                end
                                            end

                                            -- Log significant changes
                                            if math.abs(value - oldVar) > 100 or key == "faction" then
                                                print(string.format("%s netvar changed: %s from %s to %s",
                                                character:getName(), key, tostring(oldVar), tostring(value)))
                                            end
                                        end)
    ```
]]
function OnCharNetVarChanged(character, key, oldVar, value)
end

--[[
    Purpose:
        Called when a character is permanently killed
    When Called:
        When a character is permanently removed from the game
    Parameters:
        character (Character) - The character being permanently killed
        client (Player) - The player whose character was killed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log permanent character death
    hook.Add("OnCharPermakilled", "MyAddon", function(character, client)
        print(character:getName() .. " was permanently killed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle permanent death effects
    hook.Add("OnCharPermakilled", "PermaDeathEffects", function(character, client)
        -- Clear character data
        character:setData("permaKilled", true)
        character:setData("permaKillTime", os.time())

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(character:getName() .. " was permanently killed")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex permanent death system
    hook.Add("OnCharPermakilled", "AdvancedPermaDeath", function(character, client)
        -- Set permanent death data
        character:setData("permaKilled", true)
        character:setData("permaKillTime", os.time())
        character:setData("permaKillReason", "Unknown")

        -- Clear character inventory
        local inventory = character:getInv()
        if inventory then
            local items = inventory:getItems()
            for _, item in pairs(items) do
                inventory:remove(item)
            end
        end

        -- Clear character money
        character:setMoney(0)

        -- Clear character attributes
        local attributes = character:getAttribs()
        for attr, _ in pairs(attributes) do
            character:setAttrib(attr, 0)
        end

        -- Clear character data
        character:setData("level", 1)
        character:setData("experience", 0)
        character:setData("activeQuests", {})
            character:setData("activeEffects", {})

                -- Check for faction-specific effects
                local faction = character:getFaction()
                if faction == "police" then
                    -- Police get backup call
                    for _, ply in ipairs(player.GetAll()) do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == "police" then
                            ply:ChatPrint("[BACKUP] " .. character:getName() .. " was permanently killed!")
                        end
                    end
                    elseif faction == "medic" then
                        -- Medics get medical alert
                        for _, ply in ipairs(player.GetAll()) do
                            local plyChar = ply:getChar()
                            if plyChar and plyChar:getFaction() == "medic" then
                                ply:ChatPrint("[MEDICAL] " .. character:getName() .. " was permanently killed!")
                            end
                        end
                    end

                    -- Check for active quests
                    local activeQuests = character:getData("activeQuests", {})
                    for _, quest in ipairs(activeQuests) do
                        quest.failed = true
                        quest.failTime = os.time()
                        quest.failReason = "Character permanently killed"
                    end

                    -- Check for active effects
                    local activeEffects = character:getData("activeEffects", {})
                    for _, effect in ipairs(activeEffects) do
                        effect.paused = true
                        effect.pauseTime = os.time()
                    end

                    -- Notify other players
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client then
                            ply:ChatPrint(character:getName() .. " was permanently killed")
                        end
                    end

                    -- Log permanent death
                    print(string.format("%s was permanently killed (Faction: %s, Level: %d)",
                    character:getName(), faction, character:getData("level", 1)))
                end)
    ```
]]
function OnCharPermakilled(character, client)
end

--[[
    Purpose:
        Called when a character recognizes another character
    When Called:
        When a character successfully identifies another character
    Parameters:
        client (Player) - The player doing the recognizing
        target (Player) - The player being recognized
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character recognition
    hook.Add("OnCharRecognized", "MyAddon", function(client, target)
        print(client:Name() .. " recognized " .. target:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle recognition effects
    hook.Add("OnCharRecognized", "RecognitionEffects", function(client, target)
        local clientChar = client:getChar()
        local targetChar = target:getChar()

        if clientChar and targetChar then
            -- Add recognition data
            local recognitions = clientChar:getData("recognitions", {})
            recognitions[targetChar:getID()] = os.time()
            clientChar:setData("recognitions", recognitions)

            client:ChatPrint("You recognized " .. targetChar:getName())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex recognition system
    hook.Add("OnCharRecognized", "AdvancedRecognition", function(client, target)
        local clientChar = client:getChar()
        local targetChar = target:getChar()

        if not clientChar or not targetChar then return end

            -- Add recognition data
            local recognitions = clientChar:getData("recognitions", {})
            recognitions[targetChar:getID()] = {
                timestamp = os.time(),
                location = client:GetPos(),
                faction = targetChar:getFaction()
            }
            clientChar:setData("recognitions", recognitions)

            -- Check for faction-specific recognition
            local clientFaction = clientChar:getFaction()
            local targetFaction = targetChar:getFaction()

            if clientFaction == "police" and targetFaction == "criminal" then
                -- Police recognizing criminal
                client:ChatPrint("You recognized criminal: " .. targetChar:getName())

                -- Notify other police
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "police" and ply ~= client then
                        ply:ChatPrint("[POLICE] " .. clientChar:getName() .. " recognized criminal: " .. targetChar:getName())
                    end
                end
                elseif clientFaction == "criminal" and targetFaction == "police" then
                    -- Criminal recognizing police
                    client:ChatPrint("You recognized police officer: " .. targetChar:getName())

                    -- Notify other criminals
                    for _, ply in ipairs(player.GetAll()) do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == "criminal" and ply ~= client then
                            ply:ChatPrint("[CRIMINAL] " .. clientChar:getName() .. " recognized police: " .. targetChar:getName())
                        end
                    end
                    else
                        -- General recognition
                        client:ChatPrint("You recognized " .. targetChar:getName())
                    end

                    -- Check for recognition achievements
                    local recognitionCount = clientChar:getData("recognitionCount", 0) + 1
                    clientChar:setData("recognitionCount", recognitionCount)

                    if recognitionCount >= 50 and not clientChar:getData("achievement_recognizer", false) then
                        clientChar:setData("achievement_recognizer", true)
                        client:ChatPrint("Achievement unlocked: Recognizer!")
                    end

                    -- Check for faction recognition achievements
                    local factionRecognitions = clientChar:getData("factionRecognitions", {})
                    factionRecognitions[targetFaction] = (factionRecognitions[targetFaction] or 0) + 1
                    clientChar:setData("factionRecognitions", factionRecognitions)

                    if factionRecognitions[targetFaction] >= 10 and not clientChar:getData("achievement_faction_recognizer", false) then
                        clientChar:setData("achievement_faction_recognizer", true)
                        client:ChatPrint("Achievement unlocked: Faction Recognizer!")
                    end

                    -- Log recognition
                    print(string.format("%s recognized %s (Factions: %s -> %s)",
                    clientChar:getName(), targetChar:getName(), clientFaction, targetFaction))
                end)
    ```
]]
function OnCharRecognized(client, target)
end

--[[
    Purpose:
        Called when a character trades with a vendor
    When Called:
        When a character buys or sells items to/from a vendor
    Parameters:
        client (Player) - The player trading with the vendor
        vendor (Entity) - The vendor entity
        item (Item) - The item being traded
        isSellingToVendor (boolean) - True if selling to vendor, false if buying
        character (Character) - The character doing the trading
        itemType (string) - The type of item being traded
        isFailed (boolean) - Whether the trade failed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor trades
    hook.Add("OnCharTradeVendor", "MyAddon", function(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
        local action = isSellingToVendor and "sold" or "bought"
        print(character:getName() .. " " .. action .. " " .. item.uniqueID .. " from vendor")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track trade statistics
    hook.Add("OnCharTradeVendor", "TradeTracking", function(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
        if not isFailed then
            local trades = character:getData("vendorTrades", 0) + 1
            character:setData("vendorTrades", trades)

            local action = isSellingToVendor and "sold" or "bought"
            client:ChatPrint("You " .. action .. " " .. item.uniqueID .. " from vendor")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor trading system
    hook.Add("OnCharTradeVendor", "AdvancedVendorTrading", function(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
        if isFailed then
            client:ChatPrint("Trade failed!")
            return
        end

        -- Update trade statistics
        local trades = character:getData("vendorTrades", 0) + 1
        character:setData("vendorTrades", trades)

        -- Update vendor statistics
        local vendorData = vendor:getNetVar("vendorData", {})
        vendorData.tradeCount = (vendorData.tradeCount or 0) + 1
        vendorData.lastTrade = os.time()
        vendor:setNetVar("vendorData", vendorData)

        -- Check for trade achievements
        if trades >= 100 and not character:getData("achievement_trader", false) then
            character:setData("achievement_trader", true)
            client:ChatPrint("Achievement unlocked: Trader!")
        end

        -- Check for faction-specific trading
        local faction = character:getFaction()
        if faction == "police" and isSellingToVendor then
            -- Police selling items - check for contraband
            if itemType == "weapon" or itemType == "drug" then
                client:ChatPrint("Warning: Selling contraband as police officer!")

                -- Notify other police
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "police" and ply ~= client then
                        ply:ChatPrint("[POLICE] " .. character:getName() .. " sold contraband: " .. item.uniqueID)
                    end
                end
            end
            elseif faction == "criminal" and not isSellingToVendor then
                -- Criminal buying items - check for weapons
                if itemType == "weapon" then
                    client:ChatPrint("You purchased a weapon from the vendor")

                    -- Notify other criminals
                    for _, ply in ipairs(player.GetAll()) do
                        local plyChar = ply:getChar()
                        if plyChar and plyChar:getFaction() == "criminal" and ply ~= client then
                            ply:ChatPrint("[CRIMINAL] " .. character:getName() .. " bought weapon: " .. item.uniqueID)
                        end
                    end
                end
            end

            -- Check for bulk trading
            local recentTrades = character:getData("recentTrades", {})
            table.insert(recentTrades, os.time())

            -- Remove trades older than 1 hour
            local cutoff = os.time() - 3600
            for i = #recentTrades, 1, -1 do
                if recentTrades[i] < cutoff then
                    table.remove(recentTrades, i)
                end
            end

            character:setData("recentTrades", recentTrades)

            -- Check for bulk trading achievement
            if #recentTrades >= 20 and not character:getData("achievement_bulk_trader", false) then
                character:setData("achievement_bulk_trader", true)
                client:ChatPrint("Achievement unlocked: Bulk Trader!")
            end

            -- Log trade
            local action = isSellingToVendor and "sold" or "bought"
            print(string.format("%s %s %s from vendor %s (Faction: %s)",
            character:getName(), action, item.uniqueID, vendor:EntIndex(), faction))
        end)
    ```
]]
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
end

--[[
    Purpose:
        Called when a character's variable changes
    When Called:
        When a character's data variable is modified
    Parameters:
        character (Character) - The character whose variable changed
        varName (string) - The name of the variable that changed
        oldVar (any) - The previous value of the variable
        newVar (any) - The new value of the variable
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log variable changes
    hook.Add("OnCharVarChanged", "MyAddon", function(character, varName, oldVar, newVar)
        print(character:getName() .. " var changed: " .. varName .. " = " .. tostring(newVar))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track specific variable changes
    hook.Add("OnCharVarChanged", "VarTracking", function(character, varName, oldVar, newVar)
        if varName == "level" then
            local client = character:getPlayer()
            if client then
                client:ChatPrint("Level changed from " .. oldVar .. " to " .. newVar)
            end
            elseif varName == "money" then
                local client = character:getPlayer()
                if client then
                    local difference = newVar - oldVar
                    if difference > 0 then
                        client:ChatPrint("You gained $" .. difference)
                        elseif difference < 0 then
                            client:ChatPrint("You lost $" .. math.abs(difference))
                        end
                    end
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex variable change system
    hook.Add("OnCharVarChanged", "AdvancedVarChange", function(character, varName, oldVar, newVar)
        local client = character:getPlayer()
        if not client then return end

            -- Track variable change history
            local changeHistory = character:getData("varHistory", {})
            changeHistory[varName] = changeHistory[varName] or {}
                table.insert(changeHistory[varName], {
                    oldValue = oldVar,
                    newValue = newVar,
                    timestamp = os.time()
                    })

                    -- Keep only last 20 changes per variable
                    if #changeHistory[varName] > 20 then
                        table.remove(changeHistory[varName], 1)
                    end

                    character:setData("varHistory", changeHistory)

                    -- Handle specific variable changes
                    if varName == "level" then
                        -- Level change effects
                        if newVar > oldVar then
                            hook.Run("OnPlayerLevelUp", client, oldVar, newVar)
                        end

                        elseif varName == "money" then
                            -- Money change effects
                            local difference = newVar - oldVar
                            if difference > 0 then
                                client:ChatPrint("You gained $" .. difference)
                                elseif difference < 0 then
                                    client:ChatPrint("You lost $" .. math.abs(difference))
                                end

                                -- Check for money milestones
                                if newVar >= 10000 and oldVar < 10000 then
                                    client:ChatPrint("Congratulations! You've reached $10,000!")
                                    elseif newVar >= 100000 and oldVar < 100000 then
                                        client:ChatPrint("Congratulations! You've reached $100,000!")
                                    end

                                    elseif varName == "faction" then
                                        -- Faction change effects
                                        client:SetTeam(newVar)
                                        client:ChatPrint("Faction changed to: " .. newVar)

                                        -- Notify other players
                                        for _, ply in ipairs(player.GetAll()) do
                                            if ply ~= client then
                                                ply:ChatPrint(character:getName() .. " joined faction: " .. newVar)
                                            end
                                        end

                                        elseif varName == "health" then
                                            -- Health change effects
                                            if newVar <= 0 and oldVar > 0 then
                                                -- Character died
                                                hook.Run("OnCharacterDeath", character)
                                                elseif newVar > 0 and oldVar <= 0 then
                                                    -- Character revived
                                                    hook.Run("OnCharacterRevive", character)
                                                end

                                                elseif varName == "stamina" then
                                                    -- Stamina change effects
                                                    if newVar <= 0 and oldVar > 0 then
                                                        -- Stamina depleted
                                                        hook.Run("PlayerStaminaDepleted", client)
                                                        elseif newVar > 0 and oldVar <= 0 then
                                                            -- Stamina restored
                                                            hook.Run("PlayerStaminaGained", client)
                                                        end
                                                    end

                                                    -- Log significant changes
                                                    if math.abs(newVar - oldVar) > 100 or varName == "faction" or varName == "level" then
                                                        print(string.format("%s var changed: %s from %s to %s",
                                                        character:getName(), varName, tostring(oldVar), tostring(newVar)))
                                                    end
                                                end)
    ```
]]
function OnCharVarChanged(character, varName, oldVar, newVar)
end

--[[
    Purpose:
        Called when a new character is successfully created
    When Called:
        After a character is created and saved to the database
    Parameters:
        character (Character) - The newly created character
        client (Player) - The player who created the character
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character creation
    hook.Add("OnCharacterCreated", "MyAddon", function(character, client)
        print(client:Name() .. " created character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up new character bonuses
    hook.Add("OnCharacterCreated", "NewCharBonuses", function(character, client)
        -- Give starting money bonus
        local bonusMoney = 500
        character:setMoney(character:getMoney() + bonusMoney)

        -- Give starting items
        local startingItems = {"wallet", "phone", "id_card"}
        for _, itemID in ipairs(startingItems) do
            local item = lia.item.instance(itemID)
            if item then
                character:getInv():add(item)
            end
        end

        client:ChatPrint("Welcome! You received starting bonuses.")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation system
    hook.Add("OnCharacterCreated", "AdvancedCreation", function(character, client)
        local faction = character:getFaction()

        -- Set up faction-specific starting equipment
        local factionEquipment = {
        ["police"] = {
            items = {"police_badge", "handcuffs", "radio"},
                money = 1000,
                attributes = {str = 5, con = 4, dex = 3}
                    },
                    ["medic"] = {
                        items = {"medkit", "stethoscope", "bandage"},
                            money = 800,
                            attributes = {int = 6, wis = 5, con = 4}
                                },
                                ["citizen"] = {
                                    items = {"wallet", "phone"},
                                        money = 500,
                                        attributes = {str = 3, con = 3, dex = 3}
                                        }
                                    }

                                    local equipment = factionEquipment[faction]
                                    if equipment then
                                        -- Give faction-specific money
                                        character:setMoney(character:getMoney() + equipment.money)

                                        -- Give faction-specific items
                                        for _, itemID in ipairs(equipment.items) do
                                            local item = lia.item.instance(itemID)
                                            if item then
                                                character:getInv():add(item)
                                            end
                                        end

                                        -- Set faction-specific attributes
                                        for attr, value in pairs(equipment.attributes) do
                                            character:setAttrib(attr, value)
                                        end
                                    end

                                    -- Set up character data
                                    character:setData("creationTime", os.time())
                                    character:setData("creationIP", client:IPAddress())
                                    character:setData("level", 1)
                                    character:setData("experience", 0)

                                    -- Send welcome message
                                    client:ChatPrint("Character created successfully! Welcome to the server.")

                                    -- Log creation
                                    print(string.format("%s created %s character: %s",
                                    client:Name(), faction, character:getName()))
                                end)
    ```
]]
--[[
    Purpose:
        Called when a character is created
    When Called:
        When a new character is successfully created
    Parameters:
        character (Character) - The character that was created
        client (Player) - The player who created the character
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character creation
    hook.Add("OnCharacterCreated", "MyAddon", function(character, client)
        print(client:Name() .. " created character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up new character bonuses
    hook.Add("OnCharacterCreated", "NewCharBonuses", function(character, client)
        -- Give starting money bonus
        local bonusMoney = 500
        character:setMoney(character:getMoney() + bonusMoney)

        -- Give starting items
        local startingItems = {"wallet", "phone", "id_card"}
        for _, itemID in ipairs(startingItems) do
            local item = lia.item.instance(itemID)
            if item then
                character:getInv():add(item)
            end
        end

        client:ChatPrint("Welcome! You received starting bonuses.")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character creation system
    hook.Add("OnCharacterCreated", "AdvancedCreation", function(character, client)
        local faction = character:getFaction()

        -- Set up faction-specific starting equipment
        local factionEquipment = {
        ["police"] = {
            items = {"police_badge", "handcuffs", "radio"},
                money = 1000,
                attributes = {str = 5, con = 4, dex = 3}
                    },
                    ["medic"] = {
                        items = {"medkit", "stethoscope", "bandage"},
                            money = 800,
                            attributes = {int = 6, wis = 5, con = 4}
                                },
                                ["citizen"] = {
                                    items = {"wallet", "phone"},
                                        money = 500,
                                        attributes = {str = 3, con = 3, dex = 3}
                                        }
                                    }

                                    local equipment = factionEquipment[faction]
                                    if equipment then
                                        -- Give faction-specific money
                                        character:setMoney(character:getMoney() + equipment.money)

                                        -- Give faction-specific items
                                        for _, itemID in ipairs(equipment.items) do
                                            local item = lia.item.instance(itemID)
                                            if item then
                                                character:getInv():add(item)
                                            end
                                        end

                                        -- Set faction-specific attributes
                                        for attr, value in pairs(equipment.attributes) do
                                            character:setAttrib(attr, value)
                                        end
                                    end

                                    -- Set up character data
                                    character:setData("creationTime", os.time())
                                    character:setData("creationIP", client:IPAddress())
                                    character:setData("level", 1)
                                    character:setData("experience", 0)

                                    -- Send welcome message
                                    client:ChatPrint("Character created successfully! Welcome to the server.")

                                    -- Log creation
                                    print(string.format("%s created %s character: %s",
                                    client:Name(), faction, character:getName()))
                                end)
    ```
]]
function OnCharacterCreated(character, client)
end

--[[
    Purpose:
        Called when a character dies
    When Called:
        When a character's health reaches zero or they are killed
    Parameters:
        character (Character) - The character that died
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character death
    hook.Add("OnCharacterDeath", "MyAddon", function(character)
        print("Character " .. character:getName() .. " has died")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle death penalties
    hook.Add("OnCharacterDeath", "DeathPenalties", function(character)
        local client = character:getPlayer()
        if not IsValid(client) then return end

            -- Lose some money
            local moneyLoss = math.min(character:getMoney() * 0.1, 1000)
            character:setMoney(character:getMoney() - moneyLoss)

            -- Lose some experience
            local expLoss = math.min(character:getData("experience", 0) * 0.05, 100)
            character:setData("experience", character:getData("experience", 0) - expLoss)

            client:ChatPrint("You lost $" .. moneyLoss .. " and " .. expLoss .. " experience")
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex death system
    hook.Add("OnCharacterDeath", "AdvancedDeath", function(character)
        local client = character:getPlayer()
        if not IsValid(client) then return end

            local faction = character:getFaction()
            local deathTime = os.time()

            -- Set up respawn timer
            local respawnTime = 300 -- 5 minutes
            if faction == "police" then
                respawnTime = 180 -- 3 minutes for police
                elseif faction == "medic" then
                    respawnTime = 240 -- 4 minutes for medics
                end

                character:setData("deathTime", deathTime)
                character:setData("respawnTime", deathTime + respawnTime)

                -- Handle inventory
                local charInv = character:getInv()
                local items = charInv:getItems()

                -- Drop some items
                local dropChance = 0.3
                for _, item in pairs(items) do
                    if math.random() < dropChance then
                        charInv:remove(item)
                        -- Create dropped item entity
                        local pos = client:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0)
                        local ent = ents.Create("lia_item")
                        if IsValid(ent) then
                            ent:SetPos(pos)
                            ent:SetItem(item)
                            ent:Spawn()
                        end
                    end
                end

                -- Handle money loss
                local moneyLoss = math.min(character:getMoney() * 0.15, 2000)
                character:setMoney(character:getMoney() - moneyLoss)

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= client then
                        ply:ChatPrint(character:getName() .. " has died")
                    end
                end

                -- Log death
                print(string.format("%s (%s) died at %s",
                character:getName(), faction, os.date("%Y-%m-%d %H:%M:%S")))
            end)
    ```
]]
function OnCharacterDeath(character)
end

--[[
    Purpose:
        Called when a character is deleted
    When Called:
        When a character is successfully deleted from the database
    Parameters:
        charID (number) - The ID of the character that was deleted
        charName (string) - The name of the character that was deleted
        owner (Player) - The player who owned the character
        admin (Player) - The admin who deleted the character (if any)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character deletion
    hook.Add("OnCharacterDeleted", "MyAddon", function(charID, charName, owner, admin)
        print("Character " .. charName .. " (ID: " .. charID .. ") was deleted")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track deletion statistics
    hook.Add("OnCharacterDeleted", "DeletionTracking", function(charID, charName, owner, admin)
        if owner then
            local char = owner:getChar()
            if char then
                char:setData("charactersDeleted", (char:getData("charactersDeleted", 0) + 1))
                char:setData("lastCharDelete", os.time())
            end
        end

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= owner then
                ply:ChatPrint("Character " .. charName .. " was deleted")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character deletion system
    hook.Add("OnCharacterDeleted", "AdvancedDeletion", function(charID, charName, owner, admin)
        -- Update deletion statistics
        if owner then
            local char = owner:getChar()
            if char then
                char:setData("charactersDeleted", (char:getData("charactersDeleted", 0) + 1))
                char:setData("lastCharDelete", os.time())

                -- Check for deletion achievement
                local deletions = char:getData("charactersDeleted", 0)
                if deletions >= 5 and not char:getData("achievement_character_cleaner", false) then
                    char:setData("achievement_character_cleaner", true)
                    owner:ChatPrint("Achievement unlocked: Character Cleaner!")
                end
            end
        end

        -- Check for admin deletion
        if admin then
            -- Log admin deletion
            print(string.format("Admin %s deleted character %s (ID: %d) owned by %s",
            admin:Name(), charName, charID, owner and owner:Name() or "Unknown"))

            -- Notify other admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() and ply ~= admin then
                    ply:ChatPrint("[ADMIN] " .. admin:Name() .. " deleted character " .. charName)
                end
            end
            else
                -- Player self-deletion
                print(string.format("Player %s deleted character %s (ID: %d)",
                owner and owner:Name() or "Unknown", charName, charID))
            end

            -- Check for faction-specific effects
            if owner then
                local char = owner:getChar()
                if char then
                    local faction = char:getFaction()
                    if faction == "police" then
                        -- Police character deleted
                        for _, ply in ipairs(player.GetAll()) do
                            local plyChar = ply:getChar()
                            if plyChar and plyChar:getFaction() == "police" and ply ~= owner then
                                ply:ChatPrint("[POLICE] Character " .. charName .. " was deleted")
                            end
                        end
                        elseif faction == "medic" then
                            -- Medic character deleted
                            for _, ply in ipairs(player.GetAll()) do
                                local plyChar = ply:getChar()
                                if plyChar and plyChar:getFaction() == "medic" and ply ~= owner then
                                    ply:ChatPrint("[MEDICAL] Character " .. charName .. " was deleted")
                                end
                            end
                        end
                    end
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= owner then
                        ply:ChatPrint("Character " .. charName .. " was deleted")
                    end
                end

                -- Log deletion
                print(string.format("Character %s (ID: %d) was deleted by %s",
                charName, charID, admin and admin:Name() or (owner and owner:Name() or "Unknown")))
            end)
    ```
]]
function OnCharacterDeleted(charID, charName, owner, admin)
end

--[[
    Purpose:
        Called when character fields are updated
    When Called:
        When character field definitions are modified or updated
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log field updates
    hook.Add("OnCharacterFieldsUpdated", "MyAddon", function()
        print("Character fields have been updated")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Refresh character data
    hook.Add("OnCharacterFieldsUpdated", "FieldRefresh", function()
        -- Refresh all character data
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                char:sync()
            end
        end

        print("Character fields updated and synced to all players")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex field update system
    hook.Add("OnCharacterFieldsUpdated", "AdvancedFieldUpdate", function()
        -- Refresh all character data
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                char:sync()
            end
        end

        -- Update character field definitions
        local fieldDefinitions = lia.char.getFieldDefinitions()
        for fieldName, fieldData in pairs(fieldDefinitions) do
            -- Validate field data
            if not fieldData.type then
                print("Warning: Field " .. fieldName .. " missing type definition")
            end

            if not fieldData.default then
                print("Warning: Field " .. fieldName .. " missing default value")
            end
        end

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] Character fields have been updated")
            end
        end

        -- Log field update
        print("Character fields updated successfully")
    end)
    ```
]]
function OnCharacterFieldsUpdated()
end

--[[
    Purpose:
        Called when a character is loaded
    When Called:
        When a character is successfully loaded for a player
    Parameters:
        character (Character) - The character that was loaded
        client (Player) - The player whose character was loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character loading
    hook.Add("OnCharacterLoaded", "MyAddon", function(character, client)
        print(client:Name() .. " loaded character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up character data
    hook.Add("OnCharacterLoaded", "CharSetup", function(character, client)
        -- Set up character data
        character:setData("lastLoad", os.time())
        character:setData("loadCount", (character:getData("loadCount", 0) + 1))

        -- Set up player model
        local model = character:getModel()
        if model then
            client:SetModel(model)
        end

        client:ChatPrint("Character loaded: " .. character:getName())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character loading system
    hook.Add("OnCharacterLoaded", "AdvancedCharLoading", function(character, client)
        -- Set up character data
        character:setData("lastLoad", os.time())
        character:setData("loadCount", (character:getData("loadCount", 0) + 1))

        -- Set up player model
        local model = character:getModel()
        if model then
            client:SetModel(model)
        end

        -- Set up player skin
        local skin = character:getSkin()
        client:SetSkin(skin)

        -- Set up player bodygroups
        local bodygroups = character:getBodygroups()
        for group, value in pairs(bodygroups) do
            local index = tonumber(group)
            if index then
                client:SetBodygroup(index, value)
            end
        end

        -- Set up player team
        local faction = character:getFaction()
        client:SetTeam(faction)

        -- Set up player health and armor
        local health = character:getData("health", 100)
        local armor = character:getData("armor", 0)
        client:SetHealth(health)
        client:SetArmor(armor)

        -- Set up player stamina
        local stamina = character:getData("stamina", 100)
        client:setNetVar("stamina", stamina)

        -- Set up player money
        local money = character:getMoney()
        client:setNetVar("money", money)

        -- Set up player level
        local level = character:getData("level", 1)
        client:setNetVar("level", level)

        -- Set up player experience
        local experience = character:getData("experience", 0)
        client:setNetVar("experience", experience)

        -- Set up player attributes
        local attributes = character:getAttribs()
        for attr, value in pairs(attributes) do
            client:setNetVar("attr_" .. attr, value)
        end

        -- Check for returning player bonuses
        local lastLoad = character:getData("lastLoad", 0)
        local timeSinceLoad = os.time() - lastLoad
        if timeSinceLoad > 86400 then -- 24 hours
            character:setData("returningPlayerBonus", true)
            client:ChatPrint("Welcome back! You have a returning player bonus.")
        end

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(character:getName() .. " has joined the server")
            end
        end

        -- Log character load
        print(string.format("%s loaded character %s (Faction: %s, Level: %d)",
        client:Name(), character:getName(), faction, level))
    end)
    ```
]]
function OnCharacterLoaded(character, client)
end

--[[
    Purpose:
        Called when a character is revived
    When Called:
        When a character is brought back to life from unconsciousness
    Parameters:
        character (Character) - The character that was revived
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character revival
    hook.Add("OnCharacterRevive", "MyAddon", function(character)
        print(character:getName() .. " was revived")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle revival effects
    hook.Add("OnCharacterRevive", "RevivalEffects", function(character)
        local client = character:getPlayer()
        if client then
            -- Clear unconscious status
            character:setData("unconscious", false)
            character:setData("revivalTime", os.time())

            -- Restore some health
            local currentHealth = client:Health()
            local maxHealth = client:GetMaxHealth()
            client:SetHealth(math.min(currentHealth + 50, maxHealth))

            client:ChatPrint("You have been revived!")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex revival system
    hook.Add("OnCharacterRevive", "AdvancedRevival", function(character)
        local client = character:getPlayer()
        if not client then return end

            -- Clear unconscious status
            character:setData("unconscious", false)
            character:setData("revivalTime", os.time())

            -- Restore health based on faction
            local faction = character:getFaction()
            local healthRestore = {
            ["police"] = 75,
            ["medic"] = 100,
            ["citizen"] = 50
        }

        local restoreAmount = healthRestore[faction] or 50
        local currentHealth = client:Health()
        local maxHealth = client:GetMaxHealth()
        client:SetHealth(math.min(currentHealth + restoreAmount, maxHealth))

        -- Restore stamina
        local currentStamina = client:getNetVar("stamina", 100)
        client:setNetVar("stamina", math.min(currentStamina + 75, 100))

        -- Resume active effects
        local activeEffects = character:getData("activeEffects", {})
        for _, effect in ipairs(activeEffects) do
            if effect.paused then
                effect.paused = false
                effect.pauseTime = nil
            end
        end
        character:setData("activeEffects", activeEffects)

        -- Resume active quests
        local activeQuests = character:getData("activeQuests", {})
        for _, quest in ipairs(activeQuests) do
            if quest.paused then
                quest.paused = false
                quest.pauseTime = nil
            end
        end
        character:setData("activeQuests", activeQuests)

        -- Check for revival achievements
        local revivals = character:getData("revivals", 0) + 1
        character:setData("revivals", revivals)

        if revivals >= 5 and not character:getData("achievement_survivor", false) then
            character:setData("achievement_survivor", true)
            client:ChatPrint("Achievement unlocked: Survivor!")
        end

        -- Check for faction-specific revival effects
        if faction == "police" then
            -- Police get backup call
            for _, ply in ipairs(player.GetAll()) do
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == "police" then
                    ply:ChatPrint("[BACKUP] " .. character:getName() .. " has been revived!")
                end
            end
            elseif faction == "medic" then
                -- Medics get medical alert
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "medic" then
                        ply:ChatPrint("[MEDICAL] " .. character:getName() .. " has been revived!")
                    end
                end
            end

            -- Notify nearby players
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(client:GetPos()) < 500 then
                    ply:ChatPrint(character:getName() .. " has been revived!")
                end
            end

            -- Log revival
            print(string.format("%s was revived (Faction: %s, Health: %d)",
            character:getName(), faction, client:Health()))
        end)
    ```
]]
function OnCharacterRevive(character)
end

--[[
    Purpose:
        Called when character schema validation is completed
    When Called:
        When character schema validation finishes
    Parameters:
        validationResults (table) - The results of the schema validation
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log schema validation
    hook.Add("OnCharacterSchemaValidated", "MyAddon", function(validationResults)
        print("Character schema validation completed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle validation results
    hook.Add("OnCharacterSchemaValidated", "SchemaValidation", function(validationResults)
        if validationResults.valid then
            print("Character schema validation passed")
            else
                print("Character schema validation failed: " .. validationResults.error)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex schema validation system
    hook.Add("OnCharacterSchemaValidated", "AdvancedSchemaValidation", function(validationResults)
        if validationResults.valid then
            print("Character schema validation passed")

            -- Update character field definitions
            local fieldDefinitions = validationResults.fieldDefinitions
            for fieldName, fieldData in pairs(fieldDefinitions) do
                -- Validate field data
                if not fieldData.type then
                    print("Warning: Field " .. fieldName .. " missing type definition")
                end

                if not fieldData.default then
                    print("Warning: Field " .. fieldName .. " missing default value")
                end
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[ADMIN] Character schema validation passed")
                end
            end
            else
                print("Character schema validation failed: " .. validationResults.error)

                -- Notify admins of validation failure
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[ADMIN] Character schema validation failed: " .. validationResults.error)
                    end
                end
            end

            -- Log validation results
            print(string.format("Character schema validation completed: %s",
            validationResults.valid and "PASSED" or "FAILED"))
        end)
    ```
]]
function OnCharacterSchemaValidated(validationResults)
end

--[[
    Purpose:
        Called when a character is updated
    When Called:
        When a character's data is modified and saved
    Parameters:
        charID (number) - The ID of the character that was updated
        updateData (table) - The data that was updated
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character updates
    hook.Add("OnCharacterUpdated", "MyAddon", function(charID, updateData)
        print("Character " .. charID .. " was updated")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track update statistics
    hook.Add("OnCharacterUpdated", "UpdateTracking", function(charID, updateData)
        -- Track update count
        local updateCount = lia.char.getData("updateCount", 0) + 1
        lia.char.setData("updateCount", updateCount)

        -- Track last update time
        lia.char.setData("lastUpdate", os.time())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character update system
    hook.Add("OnCharacterUpdated", "AdvancedCharacterUpdate", function(charID, updateData)
        -- Get character
        local character = lia.char.getByID(charID)
        if not character then return end

            -- Track update count
            local updateCount = character:getData("updateCount", 0) + 1
            character:setData("updateCount", updateCount)

            -- Track last update time
            character:setData("lastUpdate", os.time())

            -- Track update history
            local updateHistory = character:getData("updateHistory", {})
            table.insert(updateHistory, {
                data = updateData,
                timestamp = os.time()
                })

                -- Keep only last 50 updates
                if #updateHistory > 50 then
                    table.remove(updateHistory, 1)
                end

                character:setData("updateHistory", updateHistory)

                -- Check for specific updates
                if updateData.level then
                    -- Level update
                    local oldLevel = character:getData("oldLevel", 1)
                    if updateData.level > oldLevel then
                        hook.Run("OnPlayerLevelUp", character:getPlayer(), oldLevel, updateData.level)
                    end
                    character:setData("oldLevel", updateData.level)
                end

                if updateData.money then
                    -- Money update
                    local oldMoney = character:getData("oldMoney", 0)
                    local difference = updateData.money - oldMoney
                    if difference > 0 then
                        character:getPlayer():ChatPrint("You gained $" .. difference)
                        elseif difference < 0 then
                            character:getPlayer():ChatPrint("You lost $" .. math.abs(difference))
                        end
                        character:setData("oldMoney", updateData.money)
                    end

                    if updateData.faction then
                        -- Faction update
                        local oldFaction = character:getData("oldFaction", "citizen")
                        if updateData.faction ~= oldFaction then
                            character:getPlayer():SetTeam(updateData.faction)
                            character:getPlayer():ChatPrint("Faction changed to: " .. updateData.faction)
                        end
                        character:setData("oldFaction", updateData.faction)
                    end

                    -- Check for update achievements
                    if updateCount >= 100 and not character:getData("achievement_updater", false) then
                        character:setData("achievement_updater", true)
                        character:getPlayer():ChatPrint("Achievement unlocked: Updater!")
                    end

                    -- Log update
                    print(string.format("Character %s (ID: %d) was updated",
                    character:getName(), charID))
                end)
    ```
]]
function OnCharacterUpdated(charID, updateData)
end

--[[
    Purpose:
        Called when characters are restored from backup
    When Called:
        When character data is restored from a backup
    Parameters:
        client (Player) - The player whose characters were restored
        characters (table) - The restored character data
        stats (table) - The restored character statistics
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character restoration
    hook.Add("OnCharactersRestored", "MyAddon", function(client, characters, stats)
        print(client:Name() .. " had " .. #characters .. " characters restored")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle restoration effects
    hook.Add("OnCharactersRestored", "RestorationEffects", function(client, characters, stats)
        -- Notify player
        client:ChatPrint("Your characters have been restored from backup")

        -- Update character list
        client.liaCharList = characters

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(client:Name() .. " had characters restored")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character restoration system
    hook.Add("OnCharactersRestored", "AdvancedCharacterRestoration", function(client, characters, stats)
        -- Update character list
        client.liaCharList = characters

        -- Update character statistics
        for charID, charStats in pairs(stats) do
            local character = lia.char.getByID(charID)
            if character then
                character:setData("restoredStats", charStats)
                character:setData("restorationTime", os.time())
            end
        end

        -- Check for restoration achievements
        local char = client:getChar()
        if char then
            local restorations = char:getData("restorations", 0) + 1
            char:setData("restorations", restorations)

            if restorations >= 5 and not char:getData("achievement_restorer", false) then
                char:setData("achievement_restorer", true)
                client:ChatPrint("Achievement unlocked: Restorer!")
            end
        end

        -- Check for faction-specific restoration
        local faction = char and char:getFaction()
        if faction == "police" then
            -- Police restoration
            for _, ply in ipairs(player.GetAll()) do
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == "police" and ply ~= client then
                    ply:ChatPrint("[POLICE] " .. client:Name() .. " had characters restored")
                end
            end
            elseif faction == "medic" then
                -- Medic restoration
                for _, ply in ipairs(player.GetAll()) do
                    local plyChar = ply:getChar()
                    if plyChar and plyChar:getFaction() == "medic" and ply ~= client then
                        ply:ChatPrint("[MEDICAL] " .. client:Name() .. " had characters restored")
                    end
                end
            end

            -- Notify player
            client:ChatPrint("Your characters have been restored from backup")

            -- Notify other players
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= client then
                    ply:ChatPrint(client:Name() .. " had characters restored")
                end
            end

            -- Log restoration
            print(string.format("%s had %d characters restored",
            client:Name(), #characters))
        end)
    ```
]]
function OnCharactersRestored(client, characters, stats)
end

--[[
    Purpose:
        Called when a cheater is caught
    When Called:
        When anti-cheat systems detect cheating behavior
    Parameters:
        client (Player) - The player who was caught cheating
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log cheater detection
    hook.Add("OnCheaterCaught", "MyAddon", function(client)
        print("Cheater caught: " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle cheater punishment
    hook.Add("OnCheaterCaught", "CheaterPunishment", function(client)
        -- Kick the cheater
        client:Kick("Cheating detected")

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] Cheater caught: " .. client:Name())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex anti-cheat system
    hook.Add("OnCheaterCaught", "AdvancedAntiCheat", function(client)
        -- Get cheater data
        local char = client:getChar()
        local steamID = client:SteamID()
        local ip = client:IPAddress()

        -- Log cheater information
        print(string.format("Cheater caught: %s (SteamID: %s, IP: %s)",
        client:Name(), steamID, ip))

        -- Add to cheater database
        local cheaterData = {
        name = client:Name(),
        steamID = steamID,
        ip = ip,
        timestamp = os.time(),
        charID = char and char:getID() or 0
    }

    -- Store cheater data
    lia.data.set("cheaters", steamID, cheaterData)

    -- Kick the cheater
    client:Kick("Cheating detected - You have been banned")

    -- Notify all admins
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("[ADMIN] Cheater caught: " .. client:Name())
            ply:ChatPrint("[ADMIN] SteamID: " .. steamID)
            ply:ChatPrint("[ADMIN] IP: " .. ip)
        end
    end

    -- Log to file
    local logFile = "cheaters.txt"
    local logData = string.format("[%s] %s (SteamID: %s, IP: %s)\n",
    os.date("%Y-%m-%d %H:%M:%S"), client:Name(), steamID, ip)

    -- Write to log file
    file.Append(logFile, logData)

    -- Check for repeat offenders
    local cheaterHistory = lia.data.get("cheaterHistory", {})
    cheaterHistory[steamID] = (cheaterHistory[steamID] or 0) + 1
    lia.data.set("cheaterHistory", cheaterHistory)

    if cheaterHistory[steamID] >= 3 then
        -- Repeat offender
        print(string.format("Repeat cheater: %s (SteamID: %s) - %d offenses",
        client:Name(), steamID, cheaterHistory[steamID]))
    end
    end)
    ```
]]
function OnCheaterCaught(client)
end

--[[
    Purpose:
        Called when a cheater's status changes
    When Called:
        When a player's cheater status is modified
    Parameters:
        client (Player) - The player whose status changed
        target (Player) - The target player (if applicable)
        status (string) - The new cheater status
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log cheater status changes
    hook.Add("OnCheaterStatusChanged", "MyAddon", function(client, target, status)
        print(client:Name() .. " cheater status changed to: " .. status)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle status change effects
    hook.Add("OnCheaterStatusChanged", "StatusChangeEffects", function(client, target, status)
        if status == "banned" then
            client:Kick("You have been banned for cheating")
            elseif status == "warned" then
                client:ChatPrint("Warning: Cheating behavior detected")
                elseif status == "cleared" then
                    client:ChatPrint("Your cheater status has been cleared")
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex cheater status system
    hook.Add("OnCheaterStatusChanged", "AdvancedCheaterStatus", function(client, target, status)
        local char = client:getChar()
        if not char then return end

            -- Update cheater status
            char:setData("cheaterStatus", status)
            char:setData("statusChangeTime", os.time())

            -- Handle status-specific effects
            if status == "banned" then
                -- Ban the player
                client:Kick("You have been banned for cheating")

                -- Add to ban database
                local banData = {
                steamID = client:SteamID(),
                name = client:Name(),
                reason = "Cheating",
                timestamp = os.time(),
                admin = target and target:Name() or "System"
            }

            lia.data.set("bans", client:SteamID(), banData)

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[ADMIN] " .. client:Name() .. " has been banned for cheating")
                end
            end

            elseif status == "warned" then
                -- Warn the player
                client:ChatPrint("Warning: Cheating behavior detected")

                -- Add warning to character
                local warnings = char:getData("warnings", 0) + 1
                char:setData("warnings", warnings)

                -- Check for warning limits
                if warnings >= 3 then
                    client:Kick("You have received too many warnings")
                end

                -- Notify admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[ADMIN] " .. client:Name() .. " has been warned for cheating")
                    end
                end

                elseif status == "cleared" then
                    -- Clear cheater status
                    client:ChatPrint("Your cheater status has been cleared")

                    -- Clear warnings
                    char:setData("warnings", 0)

                    -- Notify admins
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ply:ChatPrint("[ADMIN] " .. client:Name() .. " cheater status has been cleared")
                        end
                    end
                end

                -- Log status change
                print(string.format("Cheater status changed: %s -> %s (Admin: %s)",
                client:Name(), status, target and target:Name() or "System"))
            end)
    ```
]]
function OnCheaterStatusChanged(client, target, status)
end

--[[
    Purpose:
        Called when a database column is added
    When Called:
        When a new column is added to a database table
    Parameters:
        column (string) - The name of the column that was added
        data (table) - The column data and properties
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log column additions
    hook.Add("OnColumnAdded", "MyAddon", function(column, data)
        print("Column added: " .. column)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle column additions
    hook.Add("OnColumnAdded", "ColumnHandling", function(column, data)
        if column == "level" then
            print("Level column added to character table")
            elseif column == "money" then
                print("Money column added to character table")
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex column addition system
    hook.Add("OnColumnAdded", "AdvancedColumnAddition", function(column, data)
        -- Log column addition
        print(string.format("Column added: %s (Type: %s, Default: %s)",
        column, data.type or "unknown", tostring(data.default or "none")))

        -- Handle specific column types
        if data.type == "INTEGER" then
            -- Integer column
            print("Integer column added: " .. column)
            elseif data.type == "TEXT" then
                -- Text column
                print("Text column added: " .. column)
                elseif data.type == "BOOLEAN" then
                    -- Boolean column
                    print("Boolean column added: " .. column)
                end

                -- Check for required columns
                local requiredColumns = {"id", "name", "steamid", "faction"}
                if table.HasValue(requiredColumns, column) then
                    print("Required column added: " .. column)
                end

                -- Update column definitions
                local columnDefinitions = lia.data.get("columnDefinitions", {})
                columnDefinitions[column] = data
                lia.data.set("columnDefinitions", columnDefinitions)

                -- Notify admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[ADMIN] Database column added: " .. column)
                    end
                end
            end)
    ```
]]
function OnColumnAdded(column, data)
end

--[[
    Purpose:
        Called when a database column is removed
    When Called:
        When a column is removed from a database table
    Parameters:
        tableName (string) - The name of the table the column was removed from
        columnName (string) - The name of the column that was removed
        snapshot (table) - A snapshot of the data before removal
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log column removals
    hook.Add("OnColumnRemoved", "MyAddon", function(tableName, columnName, snapshot)
        print("Column removed: " .. columnName .. " from " .. tableName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle column removals
    hook.Add("OnColumnRemoved", "ColumnRemovalHandling", function(tableName, columnName, snapshot)
        if tableName == "characters" then
            print("Character column removed: " .. columnName)
            elseif tableName == "players" then
                print("Player column removed: " .. columnName)
            end

            -- Log snapshot data
            if snapshot then
                print("Snapshot contains " .. #snapshot .. " records")
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex column removal system
    hook.Add("OnColumnRemoved", "AdvancedColumnRemoval", function(tableName, columnName, snapshot)
        -- Log column removal
        print(string.format("Column removed: %s from %s (Snapshot: %s)",
        columnName, tableName, snapshot and "Yes" or "No"))

        -- Handle specific table removals
        if tableName == "characters" then
            print("Character table column removed: " .. columnName)

            -- Check if it's a critical column
            local criticalColumns = {"id", "name", "steamid"}
            if table.HasValue(criticalColumns, columnName) then
                print("WARNING: Critical column removed from characters table!")
            end
            elseif tableName == "players" then
                print("Player table column removed: " .. columnName)
            end

            -- Update column definitions
            local columnDefinitions = lia.data.get("columnDefinitions", {})
            if columnDefinitions[columnName] then
                columnDefinitions[columnName] = nil
                lia.data.set("columnDefinitions", columnDefinitions)
            end

            -- Handle snapshot data
            if snapshot then
                -- Store snapshot for potential restoration
                local snapshotData = {
                tableName = tableName,
                columnName = columnName,
                data = snapshot,
                timestamp = os.time()
            }

            lia.data.set("columnSnapshots", columnName, snapshotData)
            print("Snapshot stored for potential restoration")
        end

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] Database column removed: " .. columnName .. " from " .. tableName)
            end
        end
    end)
    ```
]]
function OnColumnRemoved(tableName, columnName, snapshot)
end

--[[
    Purpose:
        Called when a configuration is updated
    When Called:
        When a configuration value is changed
    Parameters:
        key (string) - The configuration key that was updated
        oldValue (any) - The previous value
        value (any) - The new value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log config updates
    hook.Add("OnConfigUpdated", "MyAddon", function(key, oldValue, value)
        print("Config updated: " .. key .. " = " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle specific config changes
    hook.Add("OnConfigUpdated", "ConfigHandling", function(key, oldValue, value)
        if key == "maxPlayers" then
            game.MaxPlayers = value
            elseif key == "serverName" then
                RunConsoleCommand("hostname", value)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex config update system
    hook.Add("OnConfigUpdated", "AdvancedConfigUpdate", function(key, oldValue, value)
        -- Log config change
        print(string.format("Config updated: %s from %s to %s",
        key, tostring(oldValue), tostring(value)))

        -- Handle specific config changes
        if key == "maxPlayers" then
            game.MaxPlayers = value
            print("Max players updated to: " .. value)
            elseif key == "serverName" then
                RunConsoleCommand("hostname", value)
                print("Server name updated to: " .. value)
                elseif key == "password" then
                    if value and value ~= "" then
                        RunConsoleCommand("sv_password", value)
                        print("Server password set")
                        else
                            RunConsoleCommand("sv_password", "")
                            print("Server password removed")
                        end
                    end

                    -- Update config cache
                    lia.configCache = lia.configCache or {}
                        lia.configCache[key] = {
                            value = value,
                            oldValue = oldValue,
                            timestamp = os.time()
                        }

                        -- Notify admins
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:IsAdmin() then
                                ply:ChatPrint("[CONFIG] " .. key .. " changed to: " .. tostring(value))
                            end
                        end
                    end)
    ```
]]
function OnConfigUpdated(key, oldValue, value)
end

--[[
    Purpose:
        Called when creating a player ragdoll
    When Called:
        When a player ragdoll is being created
    Parameters:
        self (Player) - The player whose ragdoll is being created
        entity (Entity) - The ragdoll entity
        isDead (boolean) - Whether the player is dead
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ragdoll creation
    hook.Add("OnCreatePlayerRagdoll", "MyAddon", function(self, entity, isDead)
        print(self:Name() .. " ragdoll created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up ragdoll data
    hook.Add("OnCreatePlayerRagdoll", "RagdollSetup", function(self, entity, isDead)
        entity:setNetVar("owner", self:SteamID())
        entity:setNetVar("isDead", isDead)
        entity:setNetVar("deathTime", os.time())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll creation system
    hook.Add("OnCreatePlayerRagdoll", "AdvancedRagdollCreation", function(self, entity, isDead)
        local char = self:getChar()
        if not char then return end

            -- Set up ragdoll data
            entity:setNetVar("owner", self:SteamID())
            entity:setNetVar("isDead", isDead)
            entity:setNetVar("deathTime", os.time())
            entity:setNetVar("charID", char:getID())
            entity:setNetVar("charName", char:getName())
            entity:setNetVar("faction", char:getFaction())

            -- Set up ragdoll appearance
            entity:SetModel(self:GetModel())
            entity:SetSkin(self:GetSkin())

            -- Set up bodygroups
            for i = 0, self:GetNumBodyGroups() - 1 do
                entity:SetBodygroup(i, self:GetBodygroup(i))
            end

            -- Set up ragdoll position and angles
            entity:SetPos(self:GetPos())
            entity:SetAngles(self:GetAngles())

            -- Apply faction-specific effects
            local faction = char:getFaction()
            if faction == "police" then
                entity:SetColor(Color(0, 0, 255, 200))
                elseif faction == "medic" then
                    entity:SetColor(Color(255, 255, 255, 200))
                end

                -- Set up ragdoll physics
                local phys = entity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(self:GetVelocity())
                end

                -- Log ragdoll creation
                print(string.format("Ragdoll created for %s (Faction: %s, Dead: %s)",
                self:Name(), faction, tostring(isDead)))
            end)
    ```
]]
function OnCreatePlayerRagdoll(self, entity, isDead)
end

--[[
    Purpose:
        Called when data is set
    When Called:
        When persistent data is being saved
    Parameters:
        key (string) - The data key
        value (any) - The data value
        gamemode (string) - The gamemode name
        map (string) - The map name
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data setting
    hook.Add("OnDataSet", "MyAddon", function(key, value, gamemode, map)
        print("Data set: " .. key .. " = " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate data before saving
    hook.Add("OnDataSet", "DataValidation", function(key, value, gamemode, map)
        if key == "playerMoney" and type(value) ~= "number" then
            print("Invalid money value: " .. tostring(value))
            return false
        end

        if key == "playerLevel" and (value < 1 or value > 100) then
            print("Invalid level value: " .. tostring(value))
            return false
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data management system
    hook.Add("OnDataSet", "AdvancedDataManagement", function(key, value, gamemode, map)
        -- Log data changes
        print(string.format("Data set: %s = %s (Gamemode: %s, Map: %s)",
        key, tostring(value), gamemode, map))

        -- Validate data types
        local dataTypes = {
        ["playerMoney"] = "number",
        ["playerLevel"] = "number",
        ["playerName"] = "string",
        ["playerFaction"] = "string"
    }

    local expectedType = dataTypes[key]
    if expectedType and type(value) ~= expectedType then
        print("Type mismatch for " .. key .. ": expected " .. expectedType .. ", got " .. type(value))
        return false
    end

    -- Validate value ranges
    if key == "playerMoney" and (value < 0 or value > 1000000) then
        print("Money value out of range: " .. value)
        return false
    end

    if key == "playerLevel" and (value < 1 or value > 100) then
        print("Level value out of range: " .. value)
        return false
    end

    -- Update data cache
    lia.dataCache = lia.dataCache or {}
        lia.dataCache[key] = {
            value = value,
            timestamp = os.time(),
            gamemode = gamemode,
            map = map
        }

        -- Notify admins of important changes
        local importantKeys = {"playerMoney", "playerLevel", "playerFaction"}
        if table.HasValue(importantKeys, key) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[DATA] " .. key .. " set to " .. tostring(value))
                end
            end
        end
    end)
    ```
]]
function OnDataSet(key, value, gamemode, map)
end

--[[
    Purpose:
        Called when database connection is established
    When Called:
        When the database connection is successfully made
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database connection
    hook.Add("OnDatabaseConnected", "MyAddon", function()
        print("Database connected successfully")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize database tables
    hook.Add("OnDatabaseConnected", "DatabaseInit", function()
        -- Create necessary tables
        lia.db.query("CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY, steamid TEXT, name TEXT)")
        lia.db.query("CREATE TABLE IF NOT EXISTS characters (id INTEGER PRIMARY KEY, playerid INTEGER, name TEXT)")

        print("Database connected and tables initialized")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database initialization system
    hook.Add("OnDatabaseConnected", "AdvancedDatabaseInit", function()
        -- Log connection
        print("Database connected successfully")

        -- Create core tables
        local tables = {
        players = "CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY, steamid TEXT UNIQUE, name TEXT, lastseen INTEGER)"
        characters = "CREATE TABLE IF NOT EXISTS characters (id INTEGER PRIMARY KEY, playerid INTEGER, name TEXT, faction TEXT, money INTEGER)"
        items = "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, charid INTEGER, itemid TEXT, data TEXT)"
        logs = "CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, timestamp INTEGER, type TEXT, message TEXT)"
    }

    for tableName, query in pairs(tables) do
        lia.db.query(query)
        print("Created table: " .. tableName)
    end

    -- Create indexes for performance
    local indexes = {
    "CREATE INDEX IF NOT EXISTS idx_players_steamid ON players(steamid)"
    "CREATE INDEX IF NOT EXISTS idx_characters_playerid ON characters(playerid)"
    "CREATE INDEX IF NOT EXISTS idx_items_charid ON items(charid)"
    "CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON logs(timestamp)"
    }

    for _, indexQuery in ipairs(indexes) do
        lia.db.query(indexQuery)
    end

    -- Initialize database statistics
    lia.data.set("dbStats", {
        connected = true,
        connectTime = os.time(),
        tablesCreated = #tables,
        indexesCreated = #indexes
        })

        -- Notify all players
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint("Database connected successfully")
        end

        print("Database initialization completed")
    end)
    ```
]]
function OnDatabaseConnected()
end

--[[
    Purpose:
        Called when the database is initialized
    When Called:
        After the database connection is established and tables are created
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database initialization
    hook.Add("OnDatabaseInitialized", "MyAddon", function()
        print("Database has been initialized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Setup custom tables
    hook.Add("OnDatabaseInitialized", "SetupCustomTables", function()
        lia.db.query("CREATE TABLE IF NOT EXISTS addon_data (id INT PRIMARY KEY, data TEXT)")
        print("Custom tables created")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database initialization
    hook.Add("OnDatabaseInitialized", "AdvancedDBInit", function()
        -- Create custom tables
        lia.db.query("CREATE TABLE IF NOT EXISTS player_stats (steamid VARCHAR(255) PRIMARY KEY, kills INT, deaths INT, playtime INT)")
        lia.db.query("CREATE TABLE IF NOT EXISTS server_logs (id INT PRIMARY KEY, player VARCHAR(255), action TEXT, timestamp INT)")

        -- Load initial data
        lia.data.get("serverConfig", {}, function(config)
            MyAddon.config = config
        end)

        -- Setup periodic cleanup
        timer.Create("DatabaseCleanup", 3600, 0, function()
        lia.db.query("DELETE FROM server_logs WHERE timestamp < ?", os.time() - 604800)
    end)

    print("Advanced database initialization complete")
    end)
    ```
]]
function OnDatabaseInitialized()
end

--[[
    Purpose:
        Called when the database has finished loading all data
    When Called:
        After all database operations and data loading is complete
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database loaded
    hook.Add("OnDatabaseLoaded", "MyAddon", function()
        print("Database loading complete")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize addon after DB load
    hook.Add("OnDatabaseLoaded", "InitAfterDB", function()
        MyAddon:Initialize()
        print("Addon initialized after database load")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex post-database initialization
    hook.Add("OnDatabaseLoaded", "AdvancedPostDBInit", function()
        -- Load all cached data
        lia.data.get("allData", {}, function(data)
            MyAddon.cache = data
        end)

        -- Initialize player statistics
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                char:loadStats()
            end
        end

        -- Start background processes
        timer.Create("DataSync", 300, 0, function()
        MyAddon:SyncData()
    end)

    print("All systems initialized after database load")
    end)
    ```
]]
function OnDatabaseLoaded()
end

--[[
    Purpose:
        Called when the database is reset
    When Called:
        When the database is reset to default state
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database reset
    hook.Add("OnDatabaseReset", "MyAddon", function()
        print("Database has been reset")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clear addon data
    hook.Add("OnDatabaseReset", "ClearAddonData", function()
        MyAddon.data = {}
            MyAddon.cache = {}
                print("Addon data cleared")
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database reset handling
    hook.Add("OnDatabaseReset", "AdvancedDBReset", function()
        -- Log database reset
        lia.log.write("database_reset", {
            timestamp = os.time(),
            admin = "System"
            })

            -- Clear all addon data
            lia.data.delete("addonData")
            lia.data.delete("playerStats")

            -- Reset all player data
            for _, ply in ipairs(player.GetAll()) do
                local char = ply:getChar()
                if char then
                    char:setData("stats", {})
                        char:setData("achievements", {})
                        end
                    end

                    -- Notify all players
                    for _, ply in ipairs(player.GetAll()) do
                        ply:ChatPrint("Server data has been reset")
                    end

                    print("Complete database reset performed")
                end)
    ```
]]
function OnDatabaseReset()
end

--[[
    Purpose:
        Called when the database is completely wiped
    When Called:
        When all database data is permanently deleted
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database wipe
    hook.Add("OnDatabaseWiped", "MyAddon", function()
        print("Database has been wiped")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Reset addon state
    hook.Add("OnDatabaseWiped", "ResetAddonState", function()
        MyAddon:Reset()
        print("Addon state reset after database wipe")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database wipe handling
    hook.Add("OnDatabaseWiped", "AdvancedDBWipe", function()
        -- Log database wipe
        lia.log.write("database_wiped", {
            timestamp = os.time(),
            admin = "System"
            })

            -- Clear all addon data
            MyAddon.data = {}
                MyAddon.cache = {}
                    MyAddon.playerStats = {}

                        -- Reset all player characters
                        for _, ply in ipairs(player.GetAll()) do
                            ply:Kick("Server data has been wiped")
                        end

                        -- Recreate essential tables
                        lia.db.query("CREATE TABLE IF NOT EXISTS lia_characters (id INTEGER PRIMARY KEY, steamid VARCHAR(255), name VARCHAR(255))")

                        print("Complete database wipe performed")
                    end)
    ```
]]
function OnDatabaseWiped()
end

--[[
    Purpose:
        Called when an entity is loaded from the database
    When Called:
        When an entity is restored from saved data
    Parameters:
        createdEnt (Entity) - The entity that was created
        data (table) - The saved entity data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log entity loading
    hook.Add("OnEntityLoaded", "MyAddon", function(createdEnt, data)
        print("Entity loaded: " .. tostring(createdEnt))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track loaded entities
    hook.Add("OnEntityLoaded", "TrackEntities", function(createdEnt, data)
        MyAddon.loadedEntities = MyAddon.loadedEntities or {}
            table.insert(MyAddon.loadedEntities, {
                entity = createdEnt,
                class = createdEnt:GetClass(),
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity loading handling
    hook.Add("OnEntityLoaded", "AdvancedEntityLoading", function(createdEnt, data)
        -- Log entity loading
        lia.log.write("entity_loaded", {
            class = createdEnt:GetClass(),
            position = createdEnt:GetPos(),
            timestamp = os.time()
            })

            -- Restore custom data
            if data.customData then
                createdEnt:SetCustomData(data.customData)
            end

            -- Setup entity-specific behavior
            if createdEnt:GetClass() == "lia_item" then
                createdEnt:SetupItemData(data.itemData)
            end

            -- Notify entity of loading
            if createdEnt.OnLoaded then
                createdEnt:OnLoaded(data)
            end
        end)
    ```
]]
function OnEntityLoaded(createdEnt, data)
end

--[[
    Purpose:
        Called when an entity's persistent data is updated
    When Called:
        When an entity's save data is modified
    Parameters:
        ent (Entity) - The entity being updated
        data (table) - The updated persistent data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log entity updates
    hook.Add("OnEntityPersistUpdated", "MyAddon", function(ent, data)
        print("Entity data updated: " .. tostring(ent))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track entity changes
    hook.Add("OnEntityPersistUpdated", "TrackEntityChanges", function(ent, data)
        MyAddon.entityChanges = MyAddon.entityChanges or {}
            table.insert(MyAddon.entityChanges, {
                entity = ent,
                data = data,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity update handling
    hook.Add("OnEntityPersistUpdated", "AdvancedEntityUpdate", function(ent, data)
        -- Log entity update
        lia.log.write("entity_persist_updated", {
            class = ent:GetClass(),
            position = ent:GetPos(),
            data = util.TableToJSON(data),
            timestamp = os.time()
            })

            -- Validate data integrity
            if data.position and not data.position.x then
                print("Warning: Invalid position data for entity " .. tostring(ent))
            end

            -- Update entity-specific data
            if ent.OnPersistDataUpdated then
                ent:OnPersistDataUpdated(data)
            end

            -- Sync to clients if needed
            if data.syncToClients then
                net.Start("liaEntityDataUpdate")
                net.WriteEntity(ent)
                net.WriteTable(data)
                net.Broadcast()
            end
        end)
    ```
]]
function OnEntityPersistUpdated(ent, data)
end

--[[
    Purpose:
        Called when an entity is persisted to the database
    When Called:
        When an entity's data is saved to the database
    Parameters:
        ent (Entity) - The entity being saved
        entData (table) - The entity data being saved
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log entity persistence
    hook.Add("OnEntityPersisted", "MyAddon", function(ent, entData)
        print("Entity persisted: " .. tostring(ent))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track entity saves
    hook.Add("OnEntityPersisted", "TrackEntitySaves", function(ent, entData)
        MyAddon.savedEntities = MyAddon.savedEntities or {}
            table.insert(MyAddon.savedEntities, {
                entity = ent,
                class = ent:GetClass(),
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity persistence handling
    hook.Add("OnEntityPersisted", "AdvancedEntityPersistence", function(ent, entData)
        -- Log entity persistence
        lia.log.write("entity_persisted", {
            class = ent:GetClass(),
            position = ent:GetPos(),
            data = util.TableToJSON(entData),
            timestamp = os.time()
            })

            -- Validate data before saving
            if not entData.position or not entData.angles then
                print("Warning: Incomplete entity data for " .. tostring(ent))
            end

            -- Add custom persistence data
            if ent.GetCustomPersistenceData then
                entData.customData = ent:GetCustomPersistenceData()
            end

            -- Update entity statistics
            local stats = lia.data.get("entityStats", {})
            stats[ent:GetClass()] = (stats[ent:GetClass()] or 0) + 1
            lia.data.set("entityStats", stats)
        end)
    ```
]]
function OnEntityPersisted(ent, entData)
end

--[[
    Purpose:
        Called when an item is added to an inventory
    When Called:
        When an item is successfully added to any inventory
    Parameters:
        owner (Player|Character) - The owner of the inventory
        item (Item) - The item that was added
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item additions
    hook.Add("OnItemAdded", "MyAddon", function(owner, item)
        print("Item " .. item.uniqueID .. " added to inventory")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle special item effects
    hook.Add("OnItemAdded", "ItemEffects", function(owner, item)
        local char = owner:getChar()
        if not char then return end

            if item.uniqueID == "health_potion" then
                char:setData("healthBonus", (char:getData("healthBonus", 0) + 10))
                elseif item.uniqueID == "stamina_boost" then
                    char:setData("staminaBonus", (char:getData("staminaBonus", 0) + 5))
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item management system
    hook.Add("OnItemAdded", "AdvancedItems", function(owner, item)
        local char = owner:getChar()
        if not char then return end

            local client = char:getPlayer()
            if not IsValid(client) then return end

                -- Check for set bonuses
                local inventory = char:getInv()
                local items = inventory:getItems()

                -- Check for armor set
                local armorPieces = 0
                for _, invItem in pairs(items) do
                    if string.find(invItem.uniqueID, "armor_") then
                        armorPieces = armorPieces + 1
                    end
                end

                if armorPieces >= 3 then
                    char:setData("armorSetBonus", true)
                    client:ChatPrint("Armor set bonus activated!")
                end

                -- Check for weapon upgrades
                if item.uniqueID == "weapon_upgrade" then
                    local weapon = inventory:hasItem("weapon_pistol")
                    if weapon then
                        weapon:setData("damage", (weapon:getData("damage", 10) + 5))
                        client:ChatPrint("Weapon upgraded!")
                    end
                end

                -- Check for quest items
                if item:getData("questItem", false) then
                    local questID = item:getData("questID")
                    if questID then
                        char:setData("questProgress", char:getData("questProgress", {})[questID] + 1)
                            client:ChatPrint("Quest progress updated!")
                        end
                    end

                    -- Update inventory weight
                    local itemWeight = item:getData("weight", 1)
                    local currentWeight = char:getData("currentWeight", 0)
                    char:setData("currentWeight", currentWeight + itemWeight)
                end)
    ```
]]
function OnItemAdded(owner, item)
end

--[[
    Purpose:
        Called when an item instance is created
    When Called:
        When a new item instance is created from an item table
    Parameters:
        itemTable (table) - The item table definition
        self (Item) - The item instance being created
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item creation
    hook.Add("OnItemCreated", "MyAddon", function(itemTable, self)
        print("Item created: " .. itemTable.uniqueID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up item-specific data
    hook.Add("OnItemCreated", "ItemSetup", function(itemTable, self)
        if itemTable.uniqueID == "weapon_pistol" then
            self:setData("ammo", 12)
            self:setData("damage", 25)
            elseif itemTable.uniqueID == "health_potion" then
                self:setData("healAmount", 50)
                self:setData("uses", 3)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item creation system
    hook.Add("OnItemCreated", "AdvancedItemCreation", function(itemTable, self)
        local char = self:getOwner()
        if not char then return end

            -- Set up item quality
            local quality = self:getData("quality", "common")
            local qualityMultipliers = {
            ["common"] = 1.0,
            ["uncommon"] = 1.2,
            ["rare"] = 1.5,
            ["epic"] = 2.0,
            ["legendary"] = 3.0
        }

        local multiplier = qualityMultipliers[quality] or 1.0

        -- Apply quality bonuses
        if itemTable.uniqueID == "weapon_pistol" then
            local baseDamage = 25
            self:setData("damage", math.floor(baseDamage * multiplier))
            self:setData("durability", math.floor(100 * multiplier))
            elseif itemTable.uniqueID == "armor_vest" then
                local baseProtection = 10
                self:setData("protection", math.floor(baseProtection * multiplier))
                self:setData("durability", math.floor(200 * multiplier))
            end

            -- Set up item level
            local itemLevel = self:getData("level", 1)
            if itemLevel > 1 then
                local levelBonus = (itemLevel - 1) * 0.1
                local currentValue = self:getData("value", 100)
                self:setData("value", math.floor(currentValue * (1 + levelBonus)))
            end

            -- Set up item enchantments
            local enchantments = self:getData("enchantments", {})
            if #enchantments > 0 then
                for _, enchant in ipairs(enchantments) do
                    if enchant.type == "fire" then
                        self:setData("fireDamage", (self:getData("fireDamage", 0) + enchant.value))
                        elseif enchant.type == "ice" then
                            self:setData("iceDamage", (self:getData("iceDamage", 0) + enchant.value))
                        end
                    end
                end

                -- Set up item binding
                if self:getData("bindOnPickup", false) then
                    self:setData("boundTo", char:getID())
                end
            end)
    ```
]]
function OnItemCreated(itemTable, self)
end

--[[
    Purpose:
        Called when an item entity is spawned in the world
    When Called:
        When an item is dropped or spawned as a world entity
    Parameters:
        self (Entity) - The item entity that was spawned
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item spawning
    hook.Add("OnItemSpawned", "MyAddon", function(self)
        print("Item spawned: " .. self:GetItem().uniqueID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set up item physics
    hook.Add("OnItemSpawned", "ItemPhysics", function(self)
        local item = self:GetItem()
        if item.uniqueID == "heavy_box" then
            self:SetPhysicsAttacker(self:GetOwner(), 10)
            self:GetPhysicsObject():SetMass(100)
            elseif item.uniqueID == "fragile_item" then
                self:SetPhysicsAttacker(self:GetOwner(), 5)
                self:GetPhysicsObject():SetMass(1)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item spawning system
    hook.Add("OnItemSpawned", "AdvancedItemSpawning", function(self)
        local item = self:GetItem()
        if not item then return end

            -- Set up item glow effects
            if item:getData("glow", false) then
                self:SetMaterial("models/effects/comball_tape")
                self:SetColor(Color(255, 255, 0, 255))
            end

            -- Set up item size
            local scale = item:getData("scale", 1.0)
            if scale ~= 1.0 then
                self:SetModelScale(scale)
            end

            -- Set up item physics
            local physics = self:GetPhysicsObject()
            if IsValid(physics) then
                local weight = item:getData("weight", 1)
                physics:SetMass(weight * 10)

                -- Set up friction
                local friction = item:getData("friction", 0.5)
                physics:SetMaterial("friction_" .. friction)
            end

            -- Set up item lifetime
            local lifetime = item:getData("lifetime", 0)
            if lifetime > 0 then
                timer.Simple(lifetime, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
        end

        -- Set up item protection
        if item:getData("protected", false) then
            self:SetCollisionGroup(COLLISION_GROUP_WORLD)
            self:SetSolid(SOLID_VPHYSICS)
        end

        -- Set up item sound
        local sound = item:getData("dropSound")
        if sound then
            self:EmitSound(sound)
        end
    end)
    ```
]]
function OnItemSpawned(self)
end

--[[
    Purpose:
        Called after items have been successfully transferred between characters
    When Called:
        After items are transferred from one character to another
    Parameters:
        fromChar (Character) - The character items were transferred from
        toChar (Character) - The character items were transferred to
        items (table) - Table of items that were transferred
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item transfers
    hook.Add("OnItemsTransferred", "MyAddon", function(fromChar, toChar, items)
        print(fromChar:getName() .. " transferred items to " .. toChar:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track transfer history
    hook.Add("OnItemsTransferred", "TrackTransfers", function(fromChar, toChar, items)
        local count = table.Count(items)
        local log = {
        from = fromChar:getID(),
        to = toChar:getID(),
        count = count,
        time = os.time()
    }

    fromChar:setData("lastTransferOut", log)
    toChar:setData("lastTransferIn", log)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer tracking and validation
    hook.Add("OnItemsTransferred", "AdvancedTransferTracking", function(fromChar, toChar, items)
        -- Log each item transferred
        for _, item in pairs(items) do
            lia.log.write("item_transfer", {
                from = fromChar:getID(),
                to = toChar:getID(),
                item = item.uniqueID,
                quantity = item:getQuantity(),
                timestamp = os.time()
                })
            end

            -- Update transfer statistics
            local fromStats = fromChar:getData("transferStats", {sent = 0, received = 0})
            fromStats.sent = fromStats.sent + table.Count(items)
            fromChar:setData("transferStats", fromStats)

            local toStats = toChar:getData("transferStats", {sent = 0, received = 0})
            toStats.received = toStats.received + table.Count(items)
            toChar:setData("transferStats", toStats)
        end)
    ```
]]
function OnItemsTransferred(fromChar, toChar, items)
end

--[[
    Purpose:
        Called when database tables are being loaded
    When Called:
        During database initialization when tables are loaded
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log table loading
    hook.Add("OnLoadTables", "MyAddon", function()
        print("Database tables are being loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize custom tables
    hook.Add("OnLoadTables", "InitCustomTables", function()
        lia.db.query("CREATE TABLE IF NOT EXISTS custom_data (id INT PRIMARY KEY, data TEXT)")
        print("Custom tables initialized")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex table initialization and migration
    hook.Add("OnLoadTables", "AdvancedTableSetup", function()
        -- Create custom tables
        lia.db.query("CREATE TABLE IF NOT EXISTS player_stats (steamid VARCHAR(255) PRIMARY KEY, kills INT, deaths INT, playtime INT)")

        -- Check for table migrations
        lia.db.query("SELECT * FROM information_schema.columns WHERE table_name = 'player_stats' AND column_name = 'score'", function(data)
        if not data or #data == 0 then
            lia.db.query("ALTER TABLE player_stats ADD COLUMN score INT DEFAULT 0")
            print("Migrated player_stats table")
        end
    end)
    end)
    ```
]]
function OnLoadTables()
end

--[[
    Purpose:
        Called when a player sends an OOC (Out of Character) message
    When Called:
        When a player sends a message in OOC chat
    Parameters:
        client (Player) - The player sending the message
        message (string) - The OOC message text
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log OOC messages
    hook.Add("OnOOCMessageSent", "MyAddon", function(client, message)
        print(client:Name() .. " sent OOC: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter OOC messages
    hook.Add("OnOOCMessageSent", "OOCFiltering", function(client, message)
        local char = client:getChar()
        if not char then
            client:ChatPrint("You need a character to use OOC chat")
            return false
        end

        -- Check if player is muted
        if char:getData("muted", false) then
            client:ChatPrint("You are muted and cannot send OOC messages")
            return false
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex OOC system
    hook.Add("OnOOCMessageSent", "AdvancedOOC", function(client, message)
        local char = client:getChar()
        if not char then
            client:ChatPrint("You need a character to use OOC chat")
            return false
        end

        -- Check if player is muted
        if char:getData("muted", false) then
            client:ChatPrint("You are muted and cannot send OOC messages")
            return false
        end

        -- Check if player is gagged
        if char:getData("gagged", false) then
            client:ChatPrint("You are gagged and cannot send OOC messages")
            return false
        end

        -- Check faction restrictions
        local faction = char:getFaction()
        if faction == "police" then
            client:ChatPrint("Police officers cannot use OOC chat")
            return false
        end

        -- Check for spam protection
        local lastOOC = char:getData("lastOOC", 0)
        local oocCooldown = 5 -- 5 second cooldown for OOC
        if os.time() - lastOOC < oocCooldown then
            client:ChatPrint("Please wait before sending another OOC message")
            return false
        end

        -- Check message length
        if string.len(message) > 200 then
            client:ChatPrint("OOC message too long (max 200 characters)")
            return false
        end

        -- Check for inappropriate content
        local bannedWords = {"spam", "hack", "cheat", "exploit"}
        for _, word in ipairs(bannedWords) do
            if string.find(string.lower(message), string.lower(word)) then
                client:ChatPrint("Your OOC message was blocked for inappropriate content")
                return false
            end
        end

        -- Update last OOC time
        char:setData("lastOOC", os.time())

        -- Check for admin commands
        if string.sub(message, 1, 1) == "!" then
            local command = string.sub(message, 2)
            if command == "admin" then
                -- Admin command
                client:ChatPrint("Admin command executed")
                return false
            end
        end

        -- Log OOC message
        print(string.format("[OOC] %s: %s", client:Name(), message))

        -- Notify admins of OOC usage
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() and ply ~= client then
                ply:ChatPrint("[OOC] " .. client:Name() .. ": " .. message)
            end
        end
    end)
    ```
]]
function OnOOCMessageSent(client, message)
end

--[[
    Purpose:
        Called when a PAC3 part is transferred
    When Called:
        When a PAC3 part is moved between players or inventories
    Parameters:
        part (table) - The PAC3 part data being transferred
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log PAC3 part transfer
    hook.Add("OnPAC3PartTransfered", "MyAddon", function(part)
        print("PAC3 part transferred: " .. (part.name or "Unknown"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track PAC3 transfers
    hook.Add("OnPAC3PartTransfered", "TrackPAC3Transfers", function(part)
        MyAddon.pac3Transfers = MyAddon.pac3Transfers or {}
            table.insert(MyAddon.pac3Transfers, {
                part = part,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex PAC3 part transfer handling
    hook.Add("OnPAC3PartTransfered", "AdvancedPAC3Transfer", function(part)
        -- Log PAC3 transfer
        lia.log.write("pac3_part_transferred", {
            partName = part.name,
            partID = part.id,
            timestamp = os.time()
            })

            -- Validate part data
            if not part.id or not part.name then
                print("Warning: Invalid PAC3 part data")
                return
            end

            -- Update part statistics
            local stats = lia.data.get("pac3Stats", {transfers = 0})
            stats.transfers = stats.transfers + 1
            lia.data.set("pac3Stats", stats)

            -- Notify relevant players
            for _, ply in ipairs(player.GetAll()) do
                if ply:HasPAC3Part(part.id) then
                    ply:ChatPrint("PAC3 part " .. part.name .. " has been transferred")
                end
            end
        end)
    ```
]]
function OnPAC3PartTransfered(part)
end

--[[
    Purpose:
        Called when a player picks up money
    When Called:
        When a player collects money from the ground
    Parameters:
        client (Player) - The player picking up money
        moneyEntity (Entity) - The money entity being picked up
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log money pickup
    hook.Add("OnPickupMoney", "MyAddon", function(client, moneyEntity)
        print(client:Name() .. " picked up money")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track money pickups
    hook.Add("OnPickupMoney", "TrackMoneyPickups", function(client, moneyEntity)
        local char = client:getChar()
        if char then
            local amount = moneyEntity:GetMoneyAmount()
            local pickups = char:getData("moneyPickups", 0)
            char:setData("moneyPickups", pickups + amount)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex money pickup handling
    hook.Add("OnPickupMoney", "AdvancedMoneyPickup", function(client, moneyEntity)
        local char = client:getChar()
        if not char then return end

            local amount = moneyEntity:GetMoneyAmount()

            -- Log money pickup
            lia.log.write("money_pickup", {
                player = client:SteamID(),
                amount = amount,
                position = moneyEntity:GetPos(),
                timestamp = os.time()
                })

                -- Update player statistics
                local stats = char:getData("moneyStats", {pickedUp = 0, totalAmount = 0})
                stats.pickedUp = stats.pickedUp + 1
                stats.totalAmount = stats.totalAmount + amount
                char:setData("moneyStats", stats)

                -- Check for achievement
                if stats.totalAmount >= 10000 then
                    hook.Run("PlayerEarnedAchievement", client, "money_collector")
                end

                -- Notify player
                client:ChatPrint("You picked up " .. lia.currency.get(amount))
            end)
    ```
]]
function OnPickupMoney(client, moneyEntity)
end

--[[
    Purpose:
        Called when a player drops a weapon
    When Called:
        When a player drops a weapon from their inventory
    Parameters:
        client (Player) - The player dropping the weapon
        weapon (Weapon) - The weapon being dropped
        entity (Entity) - The weapon entity created
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log weapon drops
    hook.Add("OnPlayerDropWeapon", "MyAddon", function(client, weapon, entity)
        print(client:Name() .. " dropped weapon: " .. weapon:GetClass())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track weapon drop statistics
    hook.Add("OnPlayerDropWeapon", "WeaponTracking", function(client, weapon, entity)
        local char = client:getChar()
        if char then
            char:setData("weaponsDropped", (char:getData("weaponsDropped", 0) + 1))
            char:setData("lastWeaponDrop", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon drop system
    hook.Add("OnPlayerDropWeapon", "AdvancedWeaponDrop", function(client, weapon, entity)
        local char = client:getChar()
        if not char then return end

            -- Check if weapon is bound
            if weapon:getData("bound", false) then
                local boundTo = weapon:getData("boundTo")
                if boundTo == char:getID() then
                    client:ChatPrint("This weapon is bound to you and cannot be dropped")
                    return false
                end
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction == "police" and weapon:GetClass() == "weapon_pistol" then
                client:ChatPrint("Police officers cannot drop their service weapon")
                return false
            end

            -- Check if weapon is valuable
            local weaponValue = weapon:getData("value", 0)
            if weaponValue > 1000 then
                -- Valuable weapon - require confirmation
                client:ChatPrint("Warning: This is a valuable weapon. Are you sure you want to drop it?")
            end

            -- Update weapon drop statistics
            char:setData("weaponsDropped", (char:getData("weaponsDropped", 0) + 1))
            char:setData("lastWeaponDrop", os.time())

            -- Set weapon entity data
            entity:setNetVar("droppedBy", char:getID())
            entity:setNetVar("droppedTime", os.time())
            entity:setNetVar("weaponClass", weapon:GetClass())

            -- Set weapon entity lifetime
            local lifetime = 600 -- 10 minutes
            entity:setNetVar("lifetime", lifetime)

            -- Start weapon cleanup timer
            timer.Simple(lifetime, function()
            if IsValid(entity) then
                entity:Remove()
            end
        end)

        -- Check for achievement
        local weaponsDropped = char:getData("weaponsDropped", 0)
        if weaponsDropped >= 50 and not char:getData("achievement_weapon_dropper", false) then
            char:setData("achievement_weapon_dropper", true)
            client:ChatPrint("Achievement unlocked: Weapon Dropper!")
        end

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(client:GetPos()) < 500 then
                ply:ChatPrint(client:Name() .. " dropped a weapon")
            end
        end

        -- Log weapon drop
        print(string.format("%s dropped weapon %s (Value: $%d)",
        client:Name(), weapon:GetClass(), weaponValue))
    end)
    ```
]]
function OnPlayerDropWeapon(client, weapon, entity)
end

--[[
    Purpose:
        Called when a player enters a sequence
    When Called:
        When a player starts a sequence (animation)
    Parameters:
        self (Player) - The player entering the sequence
        sequenceName (string) - The name of the sequence
        callback (function) - The callback function to call when sequence ends
        time (number) - The duration of the sequence
        noFreeze (boolean) - Whether the player should be frozen during sequence
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log sequence entry
    hook.Add("OnPlayerEnterSequence", "MyAddon", function(self, sequenceName, callback, time, noFreeze)
        print(self:Name() .. " entered sequence: " .. sequenceName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track sequence usage
    hook.Add("OnPlayerEnterSequence", "SequenceTracking", function(self, sequenceName, callback, time, noFreeze)
        local char = self:getChar()
        if char then
            char:setData("sequencesUsed", (char:getData("sequencesUsed", 0) + 1))
            char:setData("lastSequence", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex sequence system
    hook.Add("OnPlayerEnterSequence", "AdvancedSequence", function(self, sequenceName, callback, time, noFreeze)
        local char = self:getChar()
        if not char then return end

            -- Check if player is already in a sequence
            if char:getData("inSequence", false) then
                self:ChatPrint("You are already performing an action")
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            local restrictedSequences = {
            ["police"] = {"dance", "sit"},
                ["medic"] = {"dance"},
                    ["citizen"] = {}
                    }

                    local restricted = restrictedSequences[faction] or {}
                    if table.HasValue(restricted, sequenceName) then
                        self:ChatPrint("Your faction cannot perform this action")
                        return false
                    end

                    -- Check level requirements
                    local sequenceRequirements = {
                    ["dance"] = 5,
                    ["sit"] = 1,
                    ["wave"] = 1
                }

                local requiredLevel = sequenceRequirements[sequenceName]
                if requiredLevel then
                    local charLevel = char:getData("level", 1)
                    if charLevel < requiredLevel then
                        self:ChatPrint("You need to be level " .. requiredLevel .. " to perform this action")
                        return false
                    end
                end

                -- Set sequence data
                char:setData("inSequence", true)
                char:setData("currentSequence", sequenceName)
                char:setData("sequenceStartTime", os.time())

                -- Update sequence statistics
                char:setData("sequencesUsed", (char:getData("sequencesUsed", 0) + 1))
                char:setData("lastSequence", os.time())

                -- Check for achievement
                local sequencesUsed = char:getData("sequencesUsed", 0)
                if sequencesUsed >= 100 and not char:getData("achievement_performer", false) then
                    char:setData("achievement_performer", true)
                    self:ChatPrint("Achievement unlocked: Performer!")
                end

                -- Set up sequence end callback
                timer.Simple(time, function()
                if IsValid(self) and char:getData("inSequence", false) then
                    char:setData("inSequence", false)
                    char:setData("currentSequence", nil)

                    if callback then
                        callback()
                    end
                end
            end)

            -- Notify nearby players
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) < 500 then
                    ply:ChatPrint(self:Name() .. " is performing: " .. sequenceName)
                end
            end

            -- Log sequence entry
            print(string.format("%s entered sequence %s (Duration: %d seconds)",
            self:Name(), sequenceName, time))
        end)
    ```
]]
function OnPlayerEnterSequence(self, sequenceName, callback, time, noFreeze)
end

--[[
    Purpose:
        Called when a player interacts with an item
    When Called:
        When a player uses an item or performs an action on it
    Parameters:
        client (Player) - The player interacting with the item
        action (string) - The action being performed
        self (Item) - The item being interacted with
        result (any) - The result of the interaction
        data (table) - Additional data for the interaction
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item interactions
    hook.Add("OnPlayerInteractItem", "MyAddon", function(client, action, self, result, data)
        print(client:Name() .. " used " .. self.uniqueID .. " with action " .. action)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle special item effects
    hook.Add("OnPlayerInteractItem", "ItemEffects", function(client, action, self, result, data)
        if action == "use" then
            if self.uniqueID == "health_potion" then
                local healAmount = self:getData("healAmount", 50)
                client:SetHealth(math.min(client:Health() + healAmount, client:GetMaxHealth()))
                client:ChatPrint("You healed for " .. healAmount .. " HP")
                elseif self.uniqueID == "stamina_boost" then
                    local boostAmount = self:getData("boostAmount", 25)
                    local currentStamina = client:getNetVar("stamina", 100)
                    client:setNetVar("stamina", math.min(currentStamina + boostAmount, 100))
                    client:ChatPrint("You gained " .. boostAmount .. " stamina")
                end
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item interaction system
    hook.Add("OnPlayerInteractItem", "AdvancedItemInteractions", function(client, action, self, result, data)
        local char = client:getChar()
        if not char then return end

            if action == "use" then
                -- Handle consumable items
                if self.uniqueID == "health_potion" then
                    local healAmount = self:getData("healAmount", 50)
                    local charLevel = char:getData("level", 1)
                    healAmount = healAmount * (1 + charLevel * 0.1) -- 10% bonus per level

                    client:SetHealth(math.min(client:Health() + healAmount, client:GetMaxHealth()))
                    client:ChatPrint("You healed for " .. math.floor(healAmount) .. " HP")

                    -- Consume the item
                    local uses = self:getData("uses", 1) - 1
                    if uses <= 0 then
                        char:getInv():remove(self)
                        else
                            self:setData("uses", uses)
                        end

                        elseif self.uniqueID == "weapon_upgrade" then
                            -- Upgrade weapon
                            local weapon = char:getInv():hasItem("weapon_pistol")
                            if weapon then
                                local currentDamage = weapon:getData("damage", 25)
                                weapon:setData("damage", currentDamage + 5)
                                client:ChatPrint("Weapon upgraded! Damage increased by 5")
                                char:getInv():remove(self)
                                else
                                    client:ChatPrint("You need a weapon to upgrade")
                                end

                                elseif self.uniqueID == "teleport_scroll" then
                                    -- Teleport to spawn
                                    local spawns = lia.util.getSpawns()
                                    if #spawns > 0 then
                                        local spawn = spawns[math.random(#spawns)]
                                        client:SetPos(spawn.pos)
                                        client:SetAngles(spawn.ang)
                                        client:ChatPrint("You teleported to spawn")
                                        char:getInv():remove(self)
                                    end
                                end

                                elseif action == "examine" then
                                    -- Show item details
                                    local itemData = {
                                    name = self.name,
                                    description = self.description,
                                    value = self:getData("value", 0),
                                    weight = self:getData("weight", 1),
                                    durability = self:getData("durability", 100)
                                }

                                client:ChatPrint("Item: " .. itemData.name)
                                client:ChatPrint("Description: " .. itemData.description)
                                client:ChatPrint("Value: $" .. itemData.value)
                                client:ChatPrint("Weight: " .. itemData.weight .. "kg")
                                client:ChatPrint("Durability: " .. itemData.durability .. "%")

                                elseif action == "repair" then
                                    -- Repair item
                                    local currentDurability = self:getData("durability", 100)
                                    if currentDurability < 100 then
                                        local repairAmount = math.min(50, 100 - currentDurability)
                                        self:setData("durability", currentDurability + repairAmount)
                                        client:ChatPrint("Item repaired! Durability increased by " .. repairAmount .. "%")
                                        else
                                            client:ChatPrint("Item is already at full durability")
                                        end
                                    end
                                end)
    ```
]]
function OnPlayerInteractItem(client, action, self, result, data)
end

--[[
    Purpose:
        Called when a player joins a class
    When Called:
        When a player successfully joins a new class
    Parameters:
        client (Player) - The player joining the class
        class (string) - The class being joined
        oldClass (string) - The previous class (if any)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log class changes
    hook.Add("OnPlayerJoinClass", "MyAddon", function(client, class, oldClass)
        print(client:Name() .. " joined class: " .. class)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give class-specific bonuses
    hook.Add("OnPlayerJoinClass", "ClassBonuses", function(client, class, oldClass)
        local char = client:getChar()
        if not char then return end

            if class == "police_officer" then
                char:setData("authority", 5)
                char:setData("salary", 1000)
                elseif class == "medic" then
                    char:setData("healingBonus", 1.5)
                    char:setData("salary", 800)
                    elseif class == "citizen" then
                        char:setData("authority", 0)
                        char:setData("salary", 500)
                    end

                    client:ChatPrint("Class bonuses applied!")
                end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class system
    hook.Add("OnPlayerJoinClass", "AdvancedClasses", function(client, class, oldClass)
        local char = client:getChar()
        if not char then return end

            -- Remove old class bonuses
            if oldClass then
                local oldBonuses = {
                ["police_officer"] = {"authority", "salary"},
                    ["medic"] = {"healingBonus", "medicalKnowledge"},
                        ["engineer"] = {"repairBonus", "technicalSkill"}
                        }

                        local bonuses = oldBonuses[oldClass]
                        if bonuses then
                            for _, bonus in ipairs(bonuses) do
                                char:setData(bonus, 0)
                            end
                        end
                    end

                    -- Apply new class bonuses
                    local classBonuses = {
                    ["police_officer"] = {
                        authority = 5,
                        salary = 1000,
                        items = {"police_badge", "handcuffs", "radio"}
                            },
                            ["medic"] = {
                                healingBonus = 1.5,
                                medicalKnowledge = 10,
                                salary = 800,
                                items = {"medkit", "stethoscope", "bandage"}
                                    },
                                    ["engineer"] = {
                                        repairBonus = 2.0,
                                        technicalSkill = 15,
                                        salary = 900,
                                        items = {"wrench", "screwdriver", "multitool"}
                                        }
                                    }

                                    local bonuses = classBonuses[class]
                                    if bonuses then
                                        -- Apply stat bonuses
                                        for stat, value in pairs(bonuses) do
                                            if stat ~= "items" then
                                                char:setData(stat, value)
                                            end
                                        end

                                        -- Give class items
                                        if bonuses.items then
                                            local inventory = char:getInv()
                                            for _, itemID in ipairs(bonuses.items) do
                                                local item = lia.item.instance(itemID)
                                                if item then
                                                    inventory:add(item)
                                                end
                                            end
                                        end
                                    end

                                    -- Update character appearance
                                    hook.Run("SetupPlayerModel", client, char)

                                    -- Notify other players
                                    for _, ply in ipairs(player.GetAll()) do
                                        if ply ~= client then
                                            ply:ChatPrint(client:Name() .. " joined the " .. class .. " class")
                                        end
                                    end

                                    -- Log class change
                                    print(string.format("%s joined class %s (was %s)",
                                    client:Name(), class, oldClass or "none"))
                                end)
    ```
]]
function OnPlayerJoinClass(client, class, oldClass)
end

--[[
    Purpose:
        Called when a player leaves a sequence
    When Called:
        When a player finishes or exits a sequence
    Parameters:
        self (Player) - The player leaving the sequence
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log sequence exit
    hook.Add("OnPlayerLeaveSequence", "MyAddon", function(self)
        print(self:Name() .. " left sequence")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track sequence completion
    hook.Add("OnPlayerLeaveSequence", "SequenceTracking", function(self)
        local char = self:getChar()
        if char then
            char:setData("sequencesCompleted", (char:getData("sequencesCompleted", 0) + 1))
            char:setData("lastSequenceEnd", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex sequence exit system
    hook.Add("OnPlayerLeaveSequence", "AdvancedSequenceExit", function(self)
        local char = self:getChar()
        if not char then return end

            -- Get sequence data
            local currentSequence = char:getData("currentSequence")
            local sequenceStartTime = char:getData("sequenceStartTime", 0)
            local sequenceDuration = os.time() - sequenceStartTime

            -- Update sequence statistics
            char:setData("sequencesCompleted", (char:getData("sequencesCompleted", 0) + 1))
            char:setData("lastSequenceEnd", os.time())
            char:setData("totalSequenceTime", (char:getData("totalSequenceTime", 0) + sequenceDuration))

            -- Clear sequence data
            char:setData("inSequence", false)
            char:setData("currentSequence", nil)
            char:setData("sequenceStartTime", nil)

            -- Check for achievement
            local sequencesCompleted = char:getData("sequencesCompleted", 0)
            if sequencesCompleted >= 50 and not char:getData("achievement_sequence_master", false) then
                char:setData("achievement_sequence_master", true)
                self:ChatPrint("Achievement unlocked: Sequence Master!")
            end

            -- Check for sequence-specific achievements
            if currentSequence == "dance" then
                local danceCount = char:getData("danceCount", 0) + 1
                char:setData("danceCount", danceCount)

                if danceCount >= 20 and not char:getData("achievement_dancer", false) then
                    char:setData("achievement_dancer", true)
                    self:ChatPrint("Achievement unlocked: Dancer!")
                end
                elseif currentSequence == "sit" then
                    local sitCount = char:getData("sitCount", 0) + 1
                    char:setData("sitCount", sitCount)

                    if sitCount >= 10 and not char:getData("achievement_sitter", false) then
                        char:setData("achievement_sitter", true)
                        self:ChatPrint("Achievement unlocked: Sitter!")
                    end
                end

                -- Check for sequence duration achievements
                if sequenceDuration >= 60 then -- 1 minute
                    local longSequences = char:getData("longSequences", 0) + 1
                    char:setData("longSequences", longSequences)

                    if longSequences >= 10 and not char:getData("achievement_patient", false) then
                        char:setData("achievement_patient", true)
                        self:ChatPrint("Achievement unlocked: Patient!")
                    end
                end

                -- Notify nearby players
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(self:GetPos()) < 500 then
                        ply:ChatPrint(self:Name() .. " finished performing: " .. (currentSequence or "action"))
                    end
                end

                -- Log sequence exit
                print(string.format("%s left sequence %s (Duration: %d seconds)",
                self:Name(), currentSequence or "unknown", sequenceDuration))
            end)
    ```
]]
function OnPlayerLeaveSequence(self)
end

--[[
    Purpose:
        Called when a player levels up
    When Called:
        When a player's level increases
    Parameters:
        player (Player) - The player who leveled up
        oldValue (number) - The previous level
        newValue (number) - The new level
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log level ups
    hook.Add("OnPlayerLevelUp", "MyAddon", function(player, oldValue, newValue)
        print(player:Name() .. " leveled up from " .. oldValue .. " to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give level up bonuses
    hook.Add("OnPlayerLevelUp", "LevelBonuses", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            -- Give skill points
            local skillPoints = newValue - oldValue
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give money bonus
            local moneyBonus = newValue * 100
            char:setMoney(char:getMoney() + moneyBonus)

            player:ChatPrint("Level up! You gained " .. skillPoints .. " skill points and $" .. moneyBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex leveling system
    hook.Add("OnPlayerLevelUp", "AdvancedLeveling", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            local levelDiff = newValue - oldValue

            -- Give skill points based on level
            local skillPoints = levelDiff * 2
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give attribute points
            local attrPoints = levelDiff
            char:setData("attributePoints", char:getData("attributePoints", 0) + attrPoints)

            -- Give money bonus
            local moneyBonus = newValue * 150
            char:setMoney(char:getMoney() + moneyBonus)

            -- Check for milestone bonuses
            if newValue % 10 == 0 then
                -- Every 10 levels
                char:setData("milestoneBonus", true)
                char:setMoney(char:getMoney() + 1000)
                player:ChatPrint("Milestone reached! Bonus reward: $1000")
            end

            -- Check for level cap
            local maxLevel = 100
            if newValue >= maxLevel then
                char:setData("maxLevelReached", true)
                player:ChatPrint("Congratulations! You have reached the maximum level!")
            end

            -- Update character stats
            local faction = char:getFaction()
            if faction == "police" then
                char:setData("authority", char:getData("authority", 0) + levelDiff)
                elseif faction == "medic" then
                    char:setData("healingBonus", char:getData("healingBonus", 1.0) + (levelDiff * 0.1))
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= player then
                        ply:ChatPrint(player:Name() .. " reached level " .. newValue .. "!")
                    end
                end

                -- Log level up
                print(string.format("%s leveled up from %d to %d",
                player:Name(), oldValue, newValue))
            end)
    ```
]]
--[[
    Purpose:
        Called when a player levels up
    When Called:
        When a player's level increases
    Parameters:
        player (Player) - The player who leveled up
        oldValue (number) - The previous level
        newValue (number) - The new level
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log level ups
    hook.Add("OnPlayerLevelUp", "MyAddon", function(player, oldValue, newValue)
        print(player:Name() .. " leveled up from " .. oldValue .. " to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give level up bonuses
    hook.Add("OnPlayerLevelUp", "LevelBonuses", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            -- Give skill points
            local skillPoints = newValue - oldValue
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give money bonus
            local moneyBonus = newValue * 100
            char:setMoney(char:getMoney() + moneyBonus)

            player:ChatPrint("Level up! You gained " .. skillPoints .. " skill points and $" .. moneyBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex leveling system
    hook.Add("OnPlayerLevelUp", "AdvancedLeveling", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            local levelDiff = newValue - oldValue

            -- Give skill points based on level
            local skillPoints = levelDiff * 2
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give attribute points
            local attrPoints = levelDiff
            char:setData("attributePoints", char:getData("attributePoints", 0) + attrPoints)

            -- Give money bonus
            local moneyBonus = newValue * 150
            char:setMoney(char:getMoney() + moneyBonus)

            -- Check for milestone bonuses
            if newValue % 10 == 0 then
                -- Every 10 levels
                char:setData("milestoneBonus", true)
                char:setMoney(char:getMoney() + 1000)
                player:ChatPrint("Milestone reached! Bonus reward: $1000")
            end

            -- Check for level cap
            local maxLevel = 100
            if newValue >= maxLevel then
                char:setData("maxLevelReached", true)
                player:ChatPrint("Congratulations! You have reached the maximum level!")
            end

            -- Update character stats
            local faction = char:getFaction()
            if faction == "police" then
                char:setData("authority", char:getData("authority", 0) + levelDiff)
                elseif faction == "medic" then
                    char:setData("healingBonus", char:getData("healingBonus", 1.0) + (levelDiff * 0.1))
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= player then
                        ply:ChatPrint(player:Name() .. " reached level " .. newValue .. "!")
                    end
                end

                -- Log level up
                print(string.format("%s leveled up from %d to %d",
                player:Name(), oldValue, newValue))
            end)
    ```
]]
--[[
    Purpose:
        Called when a player levels up
    When Called:
        When a player's level increases
    Parameters:
        player (Player) - The player who leveled up
        oldValue (number) - The previous level
        newValue (number) - The new level
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log level ups
    hook.Add("OnPlayerLevelUp", "MyAddon", function(player, oldValue, newValue)
        print(player:Name() .. " leveled up from " .. oldValue .. " to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give level up bonuses
    hook.Add("OnPlayerLevelUp", "LevelBonuses", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            -- Give skill points
            local skillPoints = newValue - oldValue
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give money bonus
            local moneyBonus = newValue * 100
            char:setMoney(char:getMoney() + moneyBonus)

            player:ChatPrint("Level up! You gained " .. skillPoints .. " skill points and $" .. moneyBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex leveling system
    hook.Add("OnPlayerLevelUp", "AdvancedLeveling", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            local levelDiff = newValue - oldValue

            -- Give skill points based on level
            local skillPoints = levelDiff * 2
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give attribute points
            local attrPoints = levelDiff
            char:setData("attributePoints", char:getData("attributePoints", 0) + attrPoints)

            -- Give money bonus
            local moneyBonus = newValue * 150
            char:setMoney(char:getMoney() + moneyBonus)

            -- Check for milestone bonuses
            if newValue % 10 == 0 then
                -- Every 10 levels
                char:setData("milestoneBonus", true)
                char:setMoney(char:getMoney() + 1000)
                player:ChatPrint("Milestone reached! Bonus reward: $1000")
            end

            -- Check for level cap
            local maxLevel = 100
            if newValue >= maxLevel then
                char:setData("maxLevelReached", true)
                player:ChatPrint("Congratulations! You have reached the maximum level!")
            end

            -- Update character stats
            local faction = char:getFaction()
            if faction == "police" then
                char:setData("authority", char:getData("authority", 0) + levelDiff)
                elseif faction == "medic" then
                    char:setData("healingBonus", char:getData("healingBonus", 1.0) + (levelDiff * 0.1))
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= player then
                        ply:ChatPrint(player:Name() .. " reached level " .. newValue .. "!")
                    end
                end

                -- Log level up
                print(string.format("%s leveled up from %d to %d",
                player:Name(), oldValue, newValue))
            end)
    ```
]]
--[[
    Purpose:
        Called when a player levels up
    When Called:
        When a player's level increases
    Parameters:
        player (Player) - The player who leveled up
        oldValue (number) - The previous level
        newValue (number) - The new level
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log level ups
    hook.Add("OnPlayerLevelUp", "MyAddon", function(player, oldValue, newValue)
        print(player:Name() .. " leveled up from " .. oldValue .. " to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give level up bonuses
    hook.Add("OnPlayerLevelUp", "LevelBonuses", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            -- Give skill points
            local skillPoints = newValue - oldValue
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give money bonus
            local moneyBonus = newValue * 100
            char:setMoney(char:getMoney() + moneyBonus)

            player:ChatPrint("Level up! You gained " .. skillPoints .. " skill points and $" .. moneyBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex leveling system
    hook.Add("OnPlayerLevelUp", "AdvancedLeveling", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            local levelDiff = newValue - oldValue

            -- Give skill points based on level
            local skillPoints = levelDiff * 2
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give attribute points
            local attrPoints = levelDiff
            char:setData("attributePoints", char:getData("attributePoints", 0) + attrPoints)

            -- Give money bonus
            local moneyBonus = newValue * 150
            char:setMoney(char:getMoney() + moneyBonus)

            -- Check for milestone bonuses
            if newValue % 10 == 0 then
                -- Every 10 levels
                char:setData("milestoneBonus", true)
                char:setMoney(char:getMoney() + 1000)
                player:ChatPrint("Milestone reached! Bonus reward: $1000")
            end

            -- Check for level cap
            local maxLevel = 100
            if newValue >= maxLevel then
                char:setData("maxLevelReached", true)
                player:ChatPrint("Congratulations! You have reached the maximum level!")
            end

            -- Update character stats
            local faction = char:getFaction()
            if faction == "police" then
                char:setData("authority", char:getData("authority", 0) + levelDiff)
                elseif faction == "medic" then
                    char:setData("healingBonus", char:getData("healingBonus", 1.0) + (levelDiff * 0.1))
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= player then
                        ply:ChatPrint(player:Name() .. " reached level " .. newValue .. "!")
                    end
                end

                -- Log level up
                print(string.format("%s leveled up from %d to %d",
                player:Name(), oldValue, newValue))
            end)
    ```
]]
--[[
    Purpose:
        Called when a player levels up
    When Called:
        When a player's level increases
    Parameters:
        player (Player) - The player who leveled up
        oldValue (number) - The previous level
        newValue (number) - The new level
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log level ups
    hook.Add("OnPlayerLevelUp", "MyAddon", function(player, oldValue, newValue)
        print(player:Name() .. " leveled up from " .. oldValue .. " to " .. newValue)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give level up bonuses
    hook.Add("OnPlayerLevelUp", "LevelBonuses", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            -- Give skill points
            local skillPoints = newValue - oldValue
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give money bonus
            local moneyBonus = newValue * 100
            char:setMoney(char:getMoney() + moneyBonus)

            player:ChatPrint("Level up! You gained " .. skillPoints .. " skill points and $" .. moneyBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex leveling system
    hook.Add("OnPlayerLevelUp", "AdvancedLeveling", function(player, oldValue, newValue)
        local char = player:getChar()
        if not char then return end

            local levelDiff = newValue - oldValue

            -- Give skill points based on level
            local skillPoints = levelDiff * 2
            char:setData("skillPoints", char:getData("skillPoints", 0) + skillPoints)

            -- Give attribute points
            local attrPoints = levelDiff
            char:setData("attributePoints", char:getData("attributePoints", 0) + attrPoints)

            -- Give money bonus
            local moneyBonus = newValue * 150
            char:setMoney(char:getMoney() + moneyBonus)

            -- Check for milestone bonuses
            if newValue % 10 == 0 then
                -- Every 10 levels
                char:setData("milestoneBonus", true)
                char:setMoney(char:getMoney() + 1000)
                player:ChatPrint("Milestone reached! Bonus reward: $1000")
            end

            -- Check for level cap
            local maxLevel = 100
            if newValue >= maxLevel then
                char:setData("maxLevelReached", true)
                player:ChatPrint("Congratulations! You have reached the maximum level!")
            end

            -- Update character stats
            local faction = char:getFaction()
            if faction == "police" then
                char:setData("authority", char:getData("authority", 0) + levelDiff)
                elseif faction == "medic" then
                    char:setData("healingBonus", char:getData("healingBonus", 1.0) + (levelDiff * 0.1))
                end

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= player then
                        ply:ChatPrint(player:Name() .. " reached level " .. newValue .. "!")
                    end
                end

                -- Log level up
                print(string.format("%s leveled up from %d to %d",
                player:Name(), oldValue, newValue))
            end)
    ```
]]
function OnPlayerLevelUp(player, oldValue, newValue)
end

--[[
    Purpose:
        Called when a player loses a stack item
    When Called:
        When a player's stack item is removed or lost
    Parameters:
        itemTypeOrItem (string/Item) - The item type or item instance that was lost
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log stack item loss
    hook.Add("OnPlayerLostStackItem", "MyAddon", function(itemTypeOrItem)
        print("Player lost stack item: " .. tostring(itemTypeOrItem))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track stack item losses
    hook.Add("OnPlayerLostStackItem", "TrackStackLosses", function(itemTypeOrItem)
        MyAddon.stackLosses = MyAddon.stackLosses or {}
            local itemType = type(itemTypeOrItem) == "string" and itemTypeOrItem or itemTypeOrItem.uniqueID
            MyAddon.stackLosses[itemType] = (MyAddon.stackLosses[itemType] or 0) + 1
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex stack item loss handling
    hook.Add("OnPlayerLostStackItem", "AdvancedStackLoss", function(itemTypeOrItem)
        local itemType = type(itemTypeOrItem) == "string" and itemTypeOrItem or itemTypeOrItem.uniqueID

        -- Log stack item loss
        lia.log.write("stack_item_lost", {
            itemType = itemType,
            timestamp = os.time()
            })

            -- Find all players who had this item
            for _, ply in ipairs(player.GetAll()) do
                local char = ply:getChar()
                if char then
                    local inventory = char:getInv()
                    if inventory then
                        for _, item in pairs(inventory:getItems()) do
                            if item.uniqueID == itemType then
                                -- Notify player
                                ply:ChatPrint("You lost a stack item: " .. item.name)
                            end
                        end
                    end
                end
            end

            -- Update global statistics
            local stats = lia.data.get("stackStats", {lost = 0})
            stats.lost = stats.lost + 1
            lia.data.set("stackStats", stats)
        end)
    ```
]]
function OnPlayerLostStackItem(itemTypeOrItem)
end

--[[
    Purpose:
        Called when a player enters or exits observer mode
    When Called:
        When a player starts or stops observing
    Parameters:
        client (Player) - The player entering/exiting observer mode
        state (boolean) - True if entering observer mode, false if exiting
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log observer mode changes
    hook.Add("OnPlayerObserve", "MyAddon", function(client, state)
        if state then
            print(client:Name() .. " entered observer mode")
            else
                print(client:Name() .. " exited observer mode")
            end
        end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle observer mode restrictions
    hook.Add("OnPlayerObserve", "ObserverRestrictions", function(client, state)
        if state then
            -- Hide player when observing
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:SetMoveType(MOVETYPE_NOCLIP)

            -- Notify other players
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= client then
                    ply:ChatPrint(client:Name() .. " is now observing")
                end
            end
            else
                -- Restore player when exiting observer mode
                client:SetNoDraw(false)
                client:SetNotSolid(false)
                client:SetMoveType(MOVETYPE_WALK)

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= client then
                        ply:ChatPrint(client:Name() .. " is no longer observing")
                    end
                end
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex observer mode system
    hook.Add("OnPlayerObserve", "AdvancedObserver", function(client, state)
        local char = client:getChar()
        if not char then return end

            if state then
                -- Check if player has permission to observe
                if not client:IsAdmin() and not char:hasFlags("O") then
                    client:ChatPrint("You don't have permission to observe")
                    return
                end

                -- Store original position
                char:setData("observePos", client:GetPos())
                char:setData("observeAng", client:GetAngles())

                -- Set up observer mode
                client:SetNoDraw(true)
                client:SetNotSolid(true)
                client:SetMoveType(MOVETYPE_NOCLIP)
                client:SetHealth(1)
                client:SetMaxHealth(1)

                -- Set observer target
                local target = char:getData("observeTarget")
                if target and IsValid(target) then
                    client:SetObserverTarget(target)
                end

                -- Notify admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() and ply ~= client then
                        ply:ChatPrint("[ADMIN] " .. client:Name() .. " entered observer mode")
                    end
                end

                -- Log observer mode
                print(string.format("%s entered observer mode at %s",
                client:Name(), os.date("%Y-%m-%d %H:%M:%S")))
                else
                    -- Restore player
                    client:SetNoDraw(false)
                    client:SetNotSolid(false)
                    client:SetMoveType(MOVETYPE_WALK)
                    client:SetHealth(100)
                    client:SetMaxHealth(100)

                    -- Restore position if available
                    local observePos = char:getData("observePos")
                    local observeAng = char:getData("observeAng")
                    if observePos and observeAng then
                        client:SetPos(observePos)
                        client:SetAngles(observeAng)
                    end

                    -- Clear observer data
                    char:setData("observePos", nil)
                    char:setData("observeAng", nil)
                    char:setData("observeTarget", nil)

                    -- Notify admins
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() and ply ~= client then
                            ply:ChatPrint("[ADMIN] " .. client:Name() .. " exited observer mode")
                        end
                    end

                    -- Log observer mode exit
                    print(string.format("%s exited observer mode at %s",
                    client:Name(), os.date("%Y-%m-%d %H:%M:%S")))
                end
            end)
    ```
]]
function OnPlayerObserve(client, state)
end

--[[
    Purpose:
        Called when a player purchases a door
    When Called:
        When a player successfully buys a door
    Parameters:
        client (Player) - The player purchasing the door
        door (Entity) - The door being purchased
        price (number) - The price paid for the door
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door purchases
    hook.Add("OnPlayerPurchaseDoor", "MyAddon", function(client, door, price)
        print(client:Name() .. " purchased door for $" .. price)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle door purchase bonuses
    hook.Add("OnPlayerPurchaseDoor", "DoorBonuses", function(client, door, price)
        local char = client:getChar()
        if not char then return end

            -- Give purchase bonus
            local bonus = math.floor(price * 0.1) -- 10% bonus
            char:setMoney(char:getMoney() + bonus)

            -- Set door ownership
            door:setNetVar("owner", char:getID())
            door:setNetVar("purchaseTime", os.time())

            client:ChatPrint("Door purchased! You received a $" .. bonus .. " bonus")
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door purchase system
    hook.Add("OnPlayerPurchaseDoor", "AdvancedDoorPurchases", function(client, door, price)
        local char = client:getChar()
        if not char then return end

            -- Set up door ownership
            door:setNetVar("owner", char:getID())
            door:setNetVar("purchaseTime", os.time())
            door:setNetVar("purchasePrice", price)

            -- Give door key
            local key = lia.item.instance("door_key")
            if key then
                key:setData("doorID", door:EntIndex())
                key:setData("doorName", door:getNetVar("doorData", {}).title or "Door")
                    char:getInv():add(key)
                end

                -- Check for bulk purchase discount
                local ownedDoors = 0
                for _, ent in ipairs(ents.GetAll()) do
                    if IsValid(ent) and ent.IsDoor and ent:getNetVar("owner") == char:getID() then
                        ownedDoors = ownedDoors + 1
                    end
                end

                if ownedDoors >= 5 then
                    local discount = math.floor(price * 0.2) -- 20% discount
                    char:setMoney(char:getMoney() + discount)
                    client:ChatPrint("Bulk purchase discount: $" .. discount)
                end

                -- Update character statistics
                char:setData("doorsOwned", (char:getData("doorsOwned", 0) + 1))
                char:setData("totalSpent", (char:getData("totalSpent", 0) + price))

                -- Check for achievement
                if char:getData("doorsOwned", 0) >= 10 then
                    char:setData("achievement_landlord", true)
                    client:ChatPrint("Achievement unlocked: Landlord!")
                end

                -- Notify nearby players
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(door:GetPos()) < 500 then
                        ply:ChatPrint(client:Name() .. " purchased a door for $" .. price)
                    end
                end

                -- Log purchase
                print(string.format("%s purchased door %s for $%d",
                client:Name(), door:EntIndex(), price))
            end)
    ```
]]
function OnPlayerPurchaseDoor(client, door, price)
end

--[[
    Purpose:
        Called when a player ragdoll is created
    When Called:
        When a player's ragdoll is spawned (usually on death)
    Parameters:
        player (Player) - The player whose ragdoll was created
        ragdoll (Entity) - The ragdoll entity that was created
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ragdoll creation
    hook.Add("OnPlayerRagdollCreated", "MyAddon", function(player, ragdoll)
        print("Ragdoll created for " .. player:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize ragdoll appearance
    hook.Add("OnPlayerRagdollCreated", "RagdollCustomization", function(player, ragdoll)
        local char = player:getChar()
        if char then
            -- Set ragdoll model to character model
            local model = char:getModel()
            if model then
                ragdoll:SetModel(model)
            end

            -- Set ragdoll skin
            local skin = char:getSkin()
            ragdoll:SetSkin(skin)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll system
    hook.Add("OnPlayerRagdollCreated", "AdvancedRagdoll", function(player, ragdoll)
        local char = player:getChar()
        if not char then return end

            -- Set ragdoll model to character model
            local model = char:getModel()
            if model then
                ragdoll:SetModel(model)
            end

            -- Set ragdoll skin
            local skin = char:getSkin()
            ragdoll:SetSkin(skin)

            -- Set ragdoll bodygroups
            local bodygroups = char:getBodygroups()
            for group, value in pairs(bodygroups) do
                local index = tonumber(group)
                if index then
                    ragdoll:SetBodygroup(index, value)
                end
            end

            -- Set ragdoll position and angles
            ragdoll:SetPos(player:GetPos())
            ragdoll:SetAngles(player:GetAngles())

            -- Set ragdoll velocity
            ragdoll:SetVelocity(player:GetVelocity())

            -- Set ragdoll health
            ragdoll:SetHealth(player:Health())

            -- Set ragdoll armor
            ragdoll:SetArmor(player:Armor())

            -- Set ragdoll data
            ragdoll:setNetVar("playerID", player:UserID())
            ragdoll:setNetVar("charID", char:getID())
            ragdoll:setNetVar("charName", char:getName())
            ragdoll:setNetVar("faction", char:getFaction())

            -- Set ragdoll creation time
            ragdoll:setNetVar("creationTime", os.time())

            -- Set ragdoll lifetime
            local lifetime = 300 -- 5 minutes
            ragdoll:setNetVar("lifetime", lifetime)

            -- Start ragdoll cleanup timer
            timer.Simple(lifetime, function()
            if IsValid(ragdoll) then
                ragdoll:Remove()
            end
        end)

        -- Log ragdoll creation
        print(string.format("Ragdoll created for %s (Char: %s, Faction: %s)",
        player:Name(), char:getName(), char:getFaction()))
    end)
    ```
]]
function OnPlayerRagdollCreated(player, ragdoll)
end

--[[
    Purpose:
        Called when the player stats table is created
    When Called:
        When the player statistics table is initialized
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log table creation
    hook.Add("OnPlayerStatsTableCreated", "MyAddon", function()
        print("Player stats table created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom stats columns
    hook.Add("OnPlayerStatsTableCreated", "CustomStats", function()
        -- Add custom statistics columns
        lia.db.query("ALTER TABLE player_stats ADD COLUMN IF NOT EXISTS kills INTEGER DEFAULT 0")
        lia.db.query("ALTER TABLE player_stats ADD COLUMN IF NOT EXISTS deaths INTEGER DEFAULT 0")
        lia.db.query("ALTER TABLE player_stats ADD COLUMN IF NOT EXISTS playtime INTEGER DEFAULT 0")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex stats system
    hook.Add("OnPlayerStatsTableCreated", "AdvancedStats", function()
        -- Create comprehensive stats table
        local statsColumns = {
        "kills INTEGER DEFAULT 0",
        "deaths INTEGER DEFAULT 0",
        "playtime INTEGER DEFAULT 0",
        "money_earned INTEGER DEFAULT 0",
        "money_spent INTEGER DEFAULT 0",
        "items_crafted INTEGER DEFAULT 0",
        "doors_purchased INTEGER DEFAULT 0",
        "factions_joined INTEGER DEFAULT 0",
        "classes_joined INTEGER DEFAULT 0",
        "achievements_unlocked INTEGER DEFAULT 0",
        "quests_completed INTEGER DEFAULT 0",
        "pvp_wins INTEGER DEFAULT 0",
        "pvp_losses INTEGER DEFAULT 0",
        "admin_actions INTEGER DEFAULT 0",
        "warnings_received INTEGER DEFAULT 0",
        "last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    }

    for _, column in ipairs(statsColumns) do
        lia.db.query("ALTER TABLE player_stats ADD COLUMN IF NOT EXISTS " .. column)
    end

    -- Create indexes for better performance
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_player_stats_steamid ON player_stats(steamid)")
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_player_stats_playtime ON player_stats(playtime)")
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_player_stats_kills ON player_stats(kills)")

    -- Initialize default stats for existing players
    lia.db.query("INSERT OR IGNORE INTO player_stats (steamid, playtime, last_activity) SELECT steamid, 0, CURRENT_TIMESTAMP FROM characters WHERE steamid NOT IN (SELECT steamid FROM player_stats)")

    print("Advanced player stats system initialized")
    end)
    ```
]]
function OnPlayerStatsTableCreated()
end

--[[
    Purpose:
        Called when a player switches classes
    When Called:
        When a player successfully changes their class
    Parameters:
        client (Player) - The player switching classes
        class (string) - The new class being switched to
        oldClass (string) - The previous class
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log class switches
    hook.Add("OnPlayerSwitchClass", "MyAddon", function(client, class, oldClass)
        print(client:Name() .. " switched from " .. oldClass .. " to " .. class)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle class switch bonuses
    hook.Add("OnPlayerSwitchClass", "ClassSwitchBonuses", function(client, class, oldClass)
        local char = client:getChar()
        if not char then return end

            -- Give switch bonus
            local switchBonus = 100
            char:setMoney(char:getMoney() + switchBonus)

            client:ChatPrint("Class switch bonus: $" .. switchBonus)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class switching system
    hook.Add("OnPlayerSwitchClass", "AdvancedClassSwitching", function(client, class, oldClass)
        local char = client:getChar()
        if not char then return end

            -- Remove old class bonuses
            if oldClass then
                local oldBonuses = {
                ["police_officer"] = {"authority", "salary"},
                    ["medic"] = {"healingBonus", "medicalKnowledge"},
                        ["engineer"] = {"repairBonus", "technicalSkill"}
                        }

                        local bonuses = oldBonuses[oldClass]
                        if bonuses then
                            for _, bonus in ipairs(bonuses) do
                                char:setData(bonus, 0)
                            end
                        end
                    end

                    -- Apply new class bonuses
                    local classBonuses = {
                    ["police_officer"] = {
                        authority = 5,
                        salary = 1000,
                        items = {"police_badge", "handcuffs", "radio"}
                            },
                            ["medic"] = {
                                healingBonus = 1.5,
                                medicalKnowledge = 10,
                                salary = 800,
                                items = {"medkit", "stethoscope", "bandage"}
                                    },
                                    ["engineer"] = {
                                        repairBonus = 2.0,
                                        technicalSkill = 15,
                                        salary = 900,
                                        items = {"wrench", "screwdriver", "multitool"}
                                        }
                                    }

                                    local bonuses = classBonuses[class]
                                    if bonuses then
                                        -- Apply stat bonuses
                                        for stat, value in pairs(bonuses) do
                                            if stat ~= "items" then
                                                char:setData(stat, value)
                                            end
                                        end

                                        -- Give class items
                                        if bonuses.items then
                                            local inventory = char:getInv()
                                            for _, itemID in ipairs(bonuses.items) do
                                                local item = lia.item.instance(itemID)
                                                if item then
                                                    inventory:add(item)
                                                end
                                            end
                                        end
                                    end

                                    -- Update character appearance
                                    hook.Run("SetupPlayerModel", client, char)

                                    -- Check for class switch cooldown
                                    local lastSwitch = char:getData("lastClassSwitch", 0)
                                    local switchCooldown = 3600 -- 1 hour
                                    if os.time() - lastSwitch < switchCooldown then
                                        client:ChatPrint("You must wait before switching classes again")
                                        return false
                                    end

                                    -- Update switch time
                                    char:setData("lastClassSwitch", os.time())

                                    -- Check for achievement
                                    local classSwitches = char:getData("classSwitches", 0) + 1
                                    char:setData("classSwitches", classSwitches)

                                    if classSwitches >= 10 and not char:getData("achievement_class_hopper", false) then
                                        char:setData("achievement_class_hopper", true)
                                        client:ChatPrint("Achievement unlocked: Class Hopper!")
                                    end

                                    -- Notify other players
                                    for _, ply in ipairs(player.GetAll()) do
                                        if ply ~= client then
                                            ply:ChatPrint(client:Name() .. " switched to " .. class .. " class")
                                        end
                                    end

                                    -- Log class switch
                                    print(string.format("%s switched from %s to %s class",
                                    client:Name(), oldClass or "none", class))
                                end)
    ```
]]
function OnPlayerSwitchClass(client, class, oldClass)
end

--[[
    Purpose:
        Called when a player gains experience points
    When Called:
        When a player earns XP from any source
    Parameters:
        player (Player) - The player gaining XP
        gained (number) - The amount of XP gained
        reason (string) - The reason for gaining XP
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log XP gain
    hook.Add("OnPlayerXPGain", "MyAddon", function(player, gained, reason)
        print(player:Name() .. " gained " .. gained .. " XP for " .. reason)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply XP bonuses
    hook.Add("OnPlayerXPGain", "XPBonuses", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            -- Apply faction bonus
            local faction = char:getFaction()
            local factionMultiplier = 1.0
            if faction == "police" then
                factionMultiplier = 1.2
                elseif faction == "medic" then
                    factionMultiplier = 1.1
                end

                local bonusXP = math.floor(gained * factionMultiplier)
                char:setData("experience", char:getData("experience", 0) + bonusXP)

                player:ChatPrint("You gained " .. bonusXP .. " XP (with faction bonus)")
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex XP system
    hook.Add("OnPlayerXPGain", "AdvancedXP", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            local totalXP = char:getData("experience", 0)
            local currentLevel = char:getData("level", 1)

            -- Apply various bonuses
            local finalXP = gained

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["police"] = 1.2,
            ["medic"] = 1.1,
            ["engineer"] = 1.15,
            ["citizen"] = 1.0
        }
        finalXP = finalXP * (factionBonuses[faction] or 1.0)

        -- Activity bonus
        local activityBonuses = {
        ["combat"] = 1.5,
        ["roleplay"] = 1.3,
        ["exploration"] = 1.1,
        ["crafting"] = 1.2
    }
    finalXP = finalXP * (activityBonuses[reason] or 1.0)

    -- Time bonus (more XP during peak hours)
    local currentHour = tonumber(os.date("%H"))
    if currentHour >= 18 and currentHour <= 22 then
        finalXP = finalXP * 1.2 -- 20% bonus during peak hours
    end

    -- Apply final XP
    local newTotalXP = totalXP + math.floor(finalXP)
    char:setData("experience", newTotalXP)

    -- Check for level up
    local requiredXP = currentLevel * 1000
    if newTotalXP >= requiredXP then
        local newLevel = currentLevel + 1
        char:setData("level", newLevel)
        hook.Run("OnPlayerLevelUp", player, currentLevel, newLevel)
    end

    -- Track XP sources
    local xpSources = char:getData("xpSources", {})
    xpSources[reason] = (xpSources[reason] or 0) + math.floor(finalXP)
    char:setData("xpSources", xpSources)

    -- Notify player
    player:ChatPrint("You gained " .. math.floor(finalXP) .. " XP for " .. reason)

    -- Log XP gain
    print(string.format("%s gained %d XP for %s (Level %d)",
    player:Name(), math.floor(finalXP), reason, currentLevel))
    end)
    ```
]]
--[[
    Purpose:
        Called when a player gains experience points
    When Called:
        When a player earns XP from any source
    Parameters:
        player (Player) - The player gaining XP
        gained (number) - The amount of XP gained
        reason (string) - The reason for gaining XP
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log XP gain
    hook.Add("OnPlayerXPGain", "MyAddon", function(player, gained, reason)
        print(player:Name() .. " gained " .. gained .. " XP for " .. reason)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply XP bonuses
    hook.Add("OnPlayerXPGain", "XPBonuses", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            -- Apply faction bonus
            local faction = char:getFaction()
            local factionMultiplier = 1.0
            if faction == "police" then
                factionMultiplier = 1.2
                elseif faction == "medic" then
                    factionMultiplier = 1.1
                end

                local bonusXP = math.floor(gained * factionMultiplier)
                char:setData("experience", char:getData("experience", 0) + bonusXP)

                player:ChatPrint("You gained " .. bonusXP .. " XP (with faction bonus)")
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex XP system
    hook.Add("OnPlayerXPGain", "AdvancedXP", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            local totalXP = char:getData("experience", 0)
            local currentLevel = char:getData("level", 1)

            -- Apply various bonuses
            local finalXP = gained

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["police"] = 1.2,
            ["medic"] = 1.1,
            ["engineer"] = 1.15,
            ["citizen"] = 1.0
        }
        finalXP = finalXP * (factionBonuses[faction] or 1.0)

        -- Activity bonus
        local activityBonuses = {
        ["combat"] = 1.5,
        ["roleplay"] = 1.3,
        ["exploration"] = 1.1,
        ["crafting"] = 1.2
    }
    finalXP = finalXP * (activityBonuses[reason] or 1.0)

    -- Time bonus (more XP during peak hours)
    local currentHour = tonumber(os.date("%H"))
    if currentHour >= 18 and currentHour <= 22 then
        finalXP = finalXP * 1.2 -- 20% bonus during peak hours
    end

    -- Apply final XP
    local newTotalXP = totalXP + math.floor(finalXP)
    char:setData("experience", newTotalXP)

    -- Check for level up
    local requiredXP = currentLevel * 1000
    if newTotalXP >= requiredXP then
        local newLevel = currentLevel + 1
        char:setData("level", newLevel)
        hook.Run("OnPlayerLevelUp", player, currentLevel, newLevel)
    end

    -- Track XP sources
    local xpSources = char:getData("xpSources", {})
    xpSources[reason] = (xpSources[reason] or 0) + math.floor(finalXP)
    char:setData("xpSources", xpSources)

    -- Notify player
    player:ChatPrint("You gained " .. math.floor(finalXP) .. " XP for " .. reason)

    -- Log XP gain
    print(string.format("%s gained %d XP for %s (Level %d)",
    player:Name(), math.floor(finalXP), reason, currentLevel))
    end)
    ```
]]
--[[
    Purpose:
        Called when a player gains experience points
    When Called:
        When a player earns XP from any source
    Parameters:
        player (Player) - The player gaining XP
        gained (number) - The amount of XP gained
        reason (string) - The reason for gaining XP
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log XP gain
    hook.Add("OnPlayerXPGain", "MyAddon", function(player, gained, reason)
        print(player:Name() .. " gained " .. gained .. " XP for " .. reason)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply XP bonuses
    hook.Add("OnPlayerXPGain", "XPBonuses", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            -- Apply faction bonus
            local faction = char:getFaction()
            local factionMultiplier = 1.0
            if faction == "police" then
                factionMultiplier = 1.2
                elseif faction == "medic" then
                    factionMultiplier = 1.1
                end

                local bonusXP = math.floor(gained * factionMultiplier)
                char:setData("experience", char:getData("experience", 0) + bonusXP)

                player:ChatPrint("You gained " .. bonusXP .. " XP (with faction bonus)")
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex XP system
    hook.Add("OnPlayerXPGain", "AdvancedXP", function(player, gained, reason)
        local char = player:getChar()
        if not char then return end

            local totalXP = char:getData("experience", 0)
            local currentLevel = char:getData("level", 1)

            -- Apply various bonuses
            local finalXP = gained

            -- Faction bonus
            local faction = char:getFaction()
            local factionBonuses = {
            ["police"] = 1.2,
            ["medic"] = 1.1,
            ["engineer"] = 1.15,
            ["citizen"] = 1.0
        }
        finalXP = finalXP * (factionBonuses[faction] or 1.0)

        -- Activity bonus
        local activityBonuses = {
        ["combat"] = 1.5,
        ["roleplay"] = 1.3,
        ["exploration"] = 1.1,
        ["crafting"] = 1.2
    }
    finalXP = finalXP * (activityBonuses[reason] or 1.0)

    -- Time bonus (more XP during peak hours)
    local currentHour = tonumber(os.date("%H"))
    if currentHour >= 18 and currentHour <= 22 then
        finalXP = finalXP * 1.2 -- 20% bonus during peak hours
    end

    -- Apply final XP
    local newTotalXP = totalXP + math.floor(finalXP)
    char:setData("experience", newTotalXP)

    -- Check for level up
    local requiredXP = currentLevel * 1000
    if newTotalXP >= requiredXP then
        local newLevel = currentLevel + 1
        char:setData("level", newLevel)
        hook.Run("OnPlayerLevelUp", player, currentLevel, newLevel)
    end

    -- Track XP sources
    local xpSources = char:getData("xpSources", {})
    xpSources[reason] = (xpSources[reason] or 0) + math.floor(finalXP)
    char:setData("xpSources", xpSources)

    -- Notify player
    player:ChatPrint("You gained " .. math.floor(finalXP) .. " XP for " .. reason)

    -- Log XP gain
    print(string.format("%s gained %d XP for %s (Level %d)",
    player:Name(), math.floor(finalXP), reason, currentLevel))
    end)
    ```
]]
function OnPlayerXPGain(player, gained, reason)
end

--[[
    Purpose:
        Called when a database record is inserted or updated
    When Called:
        When a record is upserted in the database
    Parameters:
        dbTable (string) - The name of the database table
        data (table) - The data that was upserted
        action (string) - The action performed ("insert" or "update")
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log record upserts
    hook.Add("OnRecordUpserted", "MyAddon", function(dbTable, data, action)
        print("Record " .. action .. "ed in " .. dbTable)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track database changes
    hook.Add("OnRecordUpserted", "TrackDBChanges", function(dbTable, data, action)
        MyAddon.dbChanges = MyAddon.dbChanges or {}
            table.insert(MyAddon.dbChanges, {
                table = dbTable,
                action = action,
                timestamp = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database change tracking
    hook.Add("OnRecordUpserted", "AdvancedDBTracking", function(dbTable, data, action)
        -- Log database changes
        lia.log.write("db_upsert", {
            table = dbTable,
            action = action,
            data = util.TableToJSON(data),
            timestamp = os.time()
            })

            -- Trigger table-specific hooks
            if dbTable == "lia_characters" then
                hook.Run("OnCharacterRecordUpserted", data, action)
                elseif dbTable == "lia_inventories" then
                    hook.Run("OnInventoryRecordUpserted", data, action)
                end

                -- Notify admins of critical changes
                if action == "update" and dbTable == "lia_characters" then
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ply:ChatPrint("Character record updated: " .. (data.name or "Unknown"))
                        end
                    end
                end
            end)
    ```
]]
function OnRecordUpserted(dbTable, data, action)
end

--[[
    Purpose:
        Called when an item transfer is requested
    When Called:
        When a request is made to transfer an item to another inventory
    Parameters:
        item (Item) - The item being transferred
        targetInventory (Inventory) - The target inventory
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item transfer requests
    hook.Add("OnRequestItemTransfer", "MyAddon", function(item, targetInventory)
        print("Item transfer requested: " .. item.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track transfer requests
    hook.Add("OnRequestItemTransfer", "TrackTransferRequests", function(item, targetInventory)
        MyAddon.transferRequests = MyAddon.transferRequests or {}
            table.insert(MyAddon.transferRequests, {
                item = item.uniqueID,
                target = targetInventory:getID(),
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer request handling
    hook.Add("OnRequestItemTransfer", "AdvancedTransferRequest", function(item, targetInventory)
        -- Log transfer request
        lia.log.write("item_transfer_request", {
            item = item.uniqueID,
            from = item:getInventory():getID(),
            to = targetInventory:getID(),
            timestamp = os.time()
            })

            -- Check transfer restrictions
            local owner = item:getOwner()
            if owner then
                local char = owner:getChar()
                if char then
                    local transferCount = char:getData("transferCount", 0)
                    char:setData("transferCount", transferCount + 1)
                end
            end
        end)
    ```
]]
function OnRequestItemTransfer(item, targetInventory)
end

--[[
    Purpose:
        Called when a restore operation completes successfully
    When Called:
        After a successful database restore operation
    Parameters:
        restoreLog (table) - Information about the restore operation
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log restore completion
    hook.Add("OnRestoreCompleted", "MyAddon", function(restoreLog)
        print("Restore completed successfully")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins of restore
    hook.Add("OnRestoreCompleted", "NotifyRestore", function(restoreLog)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Database restore completed")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex restore completion handling
    hook.Add("OnRestoreCompleted", "AdvancedRestoreCompletion", function(restoreLog)
        -- Log restore details
        lia.log.write("restore_completed", {
            tables = restoreLog.tables or {},
                records = restoreLog.records or 0,
                timestamp = os.time()
                })

                -- Notify all players
                for _, ply in ipairs(player.GetAll()) do
                    ply:ChatPrint("Server data has been restored")
                end

                -- Reload characters
                for _, ply in ipairs(player.GetAll()) do
                    local char = ply:getChar()
                    if char then
                        char:sync()
                    end
                end
            end)
    ```
]]
function OnRestoreCompleted(restoreLog)
end

--[[
    Purpose:
        Called when a restore operation fails
    When Called:
        After a failed database restore operation
    Parameters:
        failedLog (table) - Information about the failed restore operation
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log restore failure
    hook.Add("OnRestoreFailed", "MyAddon", function(failedLog)
        print("Restore failed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins of failure
    hook.Add("OnRestoreFailed", "NotifyRestoreFailure", function(failedLog)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Database restore failed: " .. (failedLog.error or "Unknown error"))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex restore failure handling
    hook.Add("OnRestoreFailed", "AdvancedRestoreFailure", function(failedLog)
        -- Log failure details
        lia.log.write("restore_failed", {
            error = failedLog.error or "Unknown",
            tables = failedLog.tables or {},
                timestamp = os.time()
                })

                -- Notify admins with detailed error
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("Restore failed: " .. (failedLog.error or "Unknown error"))
                        if failedLog.tables then
                            ply:ChatPrint("Failed tables: " .. table.concat(failedLog.tables, ", "))
                        end
                    end
                end

                -- Attempt rollback
                if failedLog.backup then
                    lia.db.restore(failedLog.backup)
                end
            end)
    ```
]]
function OnRestoreFailed(failedLog)
end

--[[
    Purpose:
        Called when a player's salary is adjusted
    When Called:
        When a player's salary amount is modified
    Parameters:
        client (Player) - The player whose salary is being adjusted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log salary adjustments
    hook.Add("OnSalaryAdjust", "MyAddon", function(client)
        print(client:Name() .. "'s salary was adjusted")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track salary changes
    hook.Add("OnSalaryAdjust", "TrackSalaryChanges", function(client)
        local char = client:getChar()
        if char then
            local history = char:getData("salaryHistory", {})
            table.insert(history, {
                time = os.time(),
                action = "adjusted"
                })
                char:setData("salaryHistory", history)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary adjustment tracking
    hook.Add("OnSalaryAdjust", "AdvancedSalaryAdjustment", function(client)
        local char = client:getChar()
        if not char then return end

            -- Log salary adjustment
            lia.log.write("salary_adjust", {
                player = client:SteamID(),
                character = char:getID(),
                faction = char:getFaction(),
                class = char:getClass(),
                timestamp = os.time()
                })

                -- Update salary statistics
                local stats = char:getData("salaryStats", {adjustments = 0})
                stats.adjustments = stats.adjustments + 1
                stats.lastAdjustment = os.time()
                char:setData("salaryStats", stats)
            end)
    ```
]]
function OnSalaryAdjust(client)
end

--[[
    Purpose:
        Called when a player receives their salary
    When Called:
        When salary is paid to a player
    Parameters:
        client (Player) - The player receiving the salary
        char (Character) - The character receiving the salary
        pay (number) - The amount of salary paid
        faction (number) - The faction ID
        class (number) - The class ID
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log salary payments
    hook.Add("OnSalaryGiven", "MyAddon", function(client, char, pay, faction, class)
        print(client:Name() .. " received salary: " .. pay)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track salary payments
    hook.Add("OnSalaryGiven", "TrackSalaryPayments", function(client, char, pay, faction, class)
        local history = char:getData("salaryHistory", {})
        table.insert(history, {
            amount = pay,
            time = os.time(),
            faction = faction,
            class = class
            })
            char:setData("salaryHistory", history)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary payment tracking
    hook.Add("OnSalaryGiven", "AdvancedSalaryTracking", function(client, char, pay, faction, class)
        -- Log salary payment
        lia.log.write("salary_given", {
            player = client:SteamID(),
            character = char:getID(),
            amount = pay,
            faction = faction,
            class = class,
            timestamp = os.time()
            })

            -- Update salary statistics
            local stats = char:getData("salaryStats", {total = 0, count = 0})
            stats.total = stats.total + pay
            stats.count = stats.count + 1
            stats.lastPayment = os.time()
            char:setData("salaryStats", stats)

            -- Notify player
            client:ChatPrint("You received your salary: " .. lia.currency.get(pay))
        end)
    ```
]]
function OnSalaryGiven(client, char, pay, faction, class)
end

--[[
    Purpose:
        Called when saved items are loaded
    When Called:
        When items are loaded from the database
    Parameters:
        loadedItems (table) - Table of items that were loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log loaded items
    hook.Add("OnSavedItemLoaded", "MyAddon", function(loadedItems)
        print("Loaded " .. table.Count(loadedItems) .. " items")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track loaded items
    hook.Add("OnSavedItemLoaded", "TrackLoadedItems", function(loadedItems)
        MyAddon.loadedItems = MyAddon.loadedItems or {}
            for _, item in pairs(loadedItems) do
                table.insert(MyAddon.loadedItems, {
                    uniqueID = item.uniqueID,
                    loaded = os.time()
                    })
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item loading management
    hook.Add("OnSavedItemLoaded", "AdvancedItemLoading", function(loadedItems)
        -- Log item loading
        lia.log.write("items_loaded", {
            count = table.Count(loadedItems),
            timestamp = os.time()
            })

            -- Validate loaded items
            for _, item in pairs(loadedItems) do
                if not item:isValid() then
                    print("Warning: Invalid item loaded: " .. (item.uniqueID or "Unknown"))
                end
            end

            -- Update item statistics
            MyAddon.itemStats = MyAddon.itemStats or {}
                for _, item in pairs(loadedItems) do
                    MyAddon.itemStats[item.uniqueID] = (MyAddon.itemStats[item.uniqueID] or 0) + 1
                end
            end)
    ```
]]
function OnSavedItemLoaded(loadedItems)
end

--[[
    Purpose:
        Called when a server log entry is created
    When Called:
        When a log message is written to the server log
    Parameters:
        client (Player) - The player associated with the log (can be nil)
        logType (string) - The type of log entry
        logString (string) - The log message
        category (string) - The log category
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Print server logs
    hook.Add("OnServerLog", "MyAddon", function(client, logType, logString, category)
        print("[" .. logType .. "] " .. logString)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter and store logs
    hook.Add("OnServerLog", "FilterLogs", function(client, logType, logString, category)
        if category == "admin" then
            MyAddon.adminLogs = MyAddon.adminLogs or {}
                table.insert(MyAddon.adminLogs, {
                    type = logType,
                    message = logString,
                    player = client and client:SteamID() or "Server",
                    time = os.time()
                    })
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex log management
    hook.Add("OnServerLog", "AdvancedLogManagement", function(client, logType, logString, category)
        -- Store log in database
        lia.db.query("INSERT INTO server_logs (player, type, message, category, timestamp) VALUES (?, ?, ?, ?, ?)",
        client and client:SteamID() or "Server",
        logType,
        logString,
        category,
        os.time()
        )

        -- Send to external logging service
        if category == "critical" then
            http.Post("https://logging-service.com/api/log", {
                type = logType,
                message = logString,
                server = game.GetIPAddress()
                })
            end

            -- Notify admins of important logs
            if category == "admin" or category == "critical" then
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[LOG] " .. logString)
                    end
                end
            end
        end)
    ```
]]
function OnServerLog(client, logType, logString, category)
end

--[[
    Purpose:
        Called when a character's skills are changed
    When Called:
        When a character's skill values are modified
    Parameters:
        character (Character) - The character whose skills changed
        oldValue (table) - The old skill values
        value (table) - The new skill values
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log skill changes
    hook.Add("OnSkillsChanged", "MyAddon", function(character, oldValue, value)
        print(character:getName() .. "'s skills changed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track skill progression
    hook.Add("OnSkillsChanged", "TrackSkills", function(character, oldValue, value)
        local history = character:getData("skillHistory", {})
        table.insert(history, {
            old = oldValue,
            new = value,
            time = os.time()
            })
            character:setData("skillHistory", history)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex skill change tracking
    hook.Add("OnSkillsChanged", "AdvancedSkillTracking", function(character, oldValue, value)
        -- Log skill changes
        for skillName, newVal in pairs(value) do
            local oldVal = oldValue[skillName] or 0
            if newVal ~= oldVal then
                lia.log.write("skill_change", {
                    character = character:getID(),
                    skill = skillName,
                    old = oldVal,
                    new = newVal,
                    timestamp = os.time()
                    })
                end
            end

            -- Check for skill milestones
            for skillName, newVal in pairs(value) do
                if newVal >= 100 and (oldValue[skillName] or 0) < 100 then
                    local owner = character:getPlayer()
                    if IsValid(owner) then
                        owner:ChatPrint("You mastered " .. skillName .. "!")
                    end
                end
            end
        end)
    ```
]]
function OnSkillsChanged(character, oldValue, value)
end

--[[
    Purpose:
        Called when a database table is backed up
    When Called:
        After a database table backup is created
    Parameters:
        tableName (string) - The name of the table that was backed up
        snapshot (table) - The backup snapshot data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log table backups
    hook.Add("OnTableBackedUp", "MyAddon", function(tableName, snapshot)
        print("Table backed up: " .. tableName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track backups
    hook.Add("OnTableBackedUp", "TrackBackups", function(tableName, snapshot)
        MyAddon.backups = MyAddon.backups or {}
            MyAddon.backups[tableName] = {
                time = os.time(),
                records = #snapshot
            }
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex backup management
    hook.Add("OnTableBackedUp", "AdvancedBackupManagement", function(tableName, snapshot)
        -- Log backup details
        lia.log.write("table_backup", {
            table = tableName,
            records = #snapshot,
            timestamp = os.time()
            })

            -- Store backup metadata
            lia.data.get("backups", {}, function(data)
                data[tableName] = data[tableName] or {}
                    table.insert(data[tableName], {
                        time = os.time(),
                        records = #snapshot,
                        size = #util.TableToJSON(snapshot)
                        })
                        lia.data.set("backups", data)
                    end)

                    -- Notify admins
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ply:ChatPrint("Table " .. tableName .. " backed up (" .. #snapshot .. " records)")
                        end
                    end
                end)
    ```
]]
function OnTableBackedUp(tableName, snapshot)
end

--[[
    Purpose:
        Called when a database table is removed
    When Called:
        After a database table is deleted
    Parameters:
        tableName (string) - The name of the table that was removed
        snapshot (table) - The final snapshot of the table data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log table removal
    hook.Add("OnTableRemoved", "MyAddon", function(tableName, snapshot)
        print("Table removed: " .. tableName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Archive removed tables
    hook.Add("OnTableRemoved", "ArchiveRemovedTables", function(tableName, snapshot)
        MyAddon.archivedTables = MyAddon.archivedTables or {}
            MyAddon.archivedTables[tableName] = {
                data = snapshot,
                removed = os.time()
            }
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex table removal handling
    hook.Add("OnTableRemoved", "AdvancedTableRemoval", function(tableName, snapshot)
        -- Log table removal
        lia.log.write("table_removed", {
            table = tableName,
            records = #snapshot,
            timestamp = os.time()
            })

            -- Create final backup
            file.Write("lilia/backups/" .. tableName .. "_" .. os.time() .. ".json", util.TableToJSON(snapshot))

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Table " .. tableName .. " was removed (" .. #snapshot .. " records archived)")
                end
            end

            -- Clean up related data
            lia.data.delete("table_" .. tableName)
        end)
    ```
]]
function OnTableRemoved(tableName, snapshot)
end

--[[
    Purpose:
        Called when a database table is restored
    When Called:
        After a database table is restored from a backup
    Parameters:
        tableName (string) - The name of the table that was restored
        data (table) - The restored table data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log table restoration
    hook.Add("OnTableRestored", "MyAddon", function(tableName, data)
        print("Table restored: " .. tableName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track table restorations
    hook.Add("OnTableRestored", "TrackRestorations", function(tableName, data)
        MyAddon.restorations = MyAddon.restorations or {}
            table.insert(MyAddon.restorations, {
                table = tableName,
                records = #data,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex table restoration handling
    hook.Add("OnTableRestored", "AdvancedTableRestoration", function(tableName, data)
        -- Log restoration details
        lia.log.write("table_restored", {
            table = tableName,
            records = #data,
            timestamp = os.time()
            })

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Table " .. tableName .. " restored (" .. #data .. " records)")
                end
            end

            -- Reload affected systems
            if tableName == "lia_characters" then
                for _, ply in ipairs(player.GetAll()) do
                    local char = ply:getChar()
                    if char then
                        char:sync()
                    end
                end
            end
        end)
    ```
]]
function OnTableRestored(tableName, data)
end

--[[
    Purpose:
        Called when all database tables are ready
    When Called:
        After all database tables have been initialized and are ready for use
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log tables ready
    hook.Add("OnTablesReady", "MyAddon", function()
        print("Database tables are ready")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize data after tables are ready
    hook.Add("OnTablesReady", "InitData", function()
        lia.data.get("addonData", {}, function(data)
            MyAddon.data = data
            print("Addon data loaded")
        end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex initialization after tables are ready
    hook.Add("OnTablesReady", "AdvancedInit", function()
        -- Load custom data
        lia.db.query("SELECT * FROM custom_data", function(data)
        if data then
            for _, row in ipairs(data) do
                MyAddon.customData[row.id] = row.data
            end
        end
    end)

    -- Initialize caching
    MyAddon.cache = {}

        -- Setup periodic data sync
        timer.Create("MyAddonDataSync", 300, 0, function()
        lia.data.get("addonData", {}, function(data)
            MyAddon.data = data
        end)
    end)

    print("Advanced addon initialization complete")
    end)
    ```
]]
function OnTablesReady()
end

--[[
    Purpose:
        Called when a support ticket is claimed by an admin
    When Called:
        When an admin claims a support ticket
    Parameters:
        client (Player) - The admin claiming the ticket
        requester (Player) - The player who created the ticket
        ticketMessage (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket claims
    hook.Add("OnTicketClaimed", "MyAddon", function(client, requester, ticketMessage)
        print(client:Name() .. " claimed ticket from " .. requester:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track ticket claims
    hook.Add("OnTicketClaimed", "TrackTicketClaims", function(client, requester, ticketMessage)
        local char = client:getChar()
        if char then
            local claims = char:getData("ticketsClaimed", 0)
            char:setData("ticketsClaimed", claims + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket claim handling
    hook.Add("OnTicketClaimed", "AdvancedTicketClaim", function(client, requester, ticketMessage)
        -- Log ticket claim
        lia.log.write("ticket_claimed", {
            admin = client:SteamID(),
            requester = requester:SteamID(),
            message = ticketMessage,
            timestamp = os.time()
            })

            -- Notify both parties
            client:ChatPrint("You claimed the ticket from " .. requester:Name())
            requester:ChatPrint(client:Name() .. " is handling your ticket")

            -- Update ticket statistics
            local char = client:getChar()
            if char then
                local stats = char:getData("ticketStats", {claimed = 0, resolved = 0})
                stats.claimed = stats.claimed + 1
                char:setData("ticketStats", stats)
            end
        end)
    ```
]]
function OnTicketClaimed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a support ticket is closed
    When Called:
        When a support ticket is resolved and closed
    Parameters:
        client (Player) - The admin closing the ticket
        requester (Player) - The player who created the ticket
        ticketMessage (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket closures
    hook.Add("OnTicketClosed", "MyAddon", function(client, requester, ticketMessage)
        print(client:Name() .. " closed ticket from " .. requester:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track ticket resolutions
    hook.Add("OnTicketClosed", "TrackTicketClosures", function(client, requester, ticketMessage)
        local char = client:getChar()
        if char then
            local resolved = char:getData("ticketsResolved", 0)
            char:setData("ticketsResolved", resolved + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket closure handling
    hook.Add("OnTicketClosed", "AdvancedTicketClosure", function(client, requester, ticketMessage)
        -- Log ticket closure
        lia.log.write("ticket_closed", {
            admin = client:SteamID(),
            requester = requester:SteamID(),
            message = ticketMessage,
            timestamp = os.time()
            })

            -- Notify both parties
            client:ChatPrint("You closed the ticket from " .. requester:Name())
            requester:ChatPrint("Your ticket has been resolved by " .. client:Name())

            -- Update ticket statistics
            local char = client:getChar()
            if char then
                local stats = char:getData("ticketStats", {claimed = 0, resolved = 0})
                stats.resolved = stats.resolved + 1
                char:setData("ticketStats", stats)
            end
        end)
    ```
]]
function OnTicketClosed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a new support ticket is created
    When Called:
        When a player creates a support ticket
    Parameters:
        noob (Player) - The player creating the ticket
        message (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket creation
    hook.Add("OnTicketCreated", "MyAddon", function(noob, message)
        print(noob:Name() .. " created a ticket: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins of new tickets
    hook.Add("OnTicketCreated", "NotifyAdmins", function(noob, message)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("New ticket from " .. noob:Name() .. ": " .. message)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket creation handling
    hook.Add("OnTicketCreated", "AdvancedTicketCreation", function(noob, message)
        -- Log ticket creation
        lia.log.write("ticket_created", {
            player = noob:SteamID(),
            message = message,
            timestamp = os.time()
            })

            -- Store ticket in database
            lia.db.query("INSERT INTO tickets (player, message, status, created) VALUES (?, ?, ?, ?)",
            noob:SteamID(),
            message,
            "open",
            os.time()
            )

            -- Notify all admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[TICKET] " .. noob:Name() .. ": " .. message)
                    surface.PlaySound("buttons/button15.wav")
                end
            end

            -- Confirm to player
            noob:ChatPrint("Your ticket has been submitted. An admin will assist you shortly.")
        end)
    ```
]]
function OnTicketCreated(noob, message)
end

--[[
    Purpose:
        Called when an item transfer fails
    When Called:
        When an attempt to transfer items between characters fails
    Parameters:
        fromChar (Character) - The character items were being transferred from
        toChar (Character) - The character items were being transferred to
        items (table) - Table of items that failed to transfer
        err (string) - The error message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log transfer failures
    hook.Add("OnTransferFailed", "MyAddon", function(fromChar, toChar, items, err)
        print("Transfer failed: " .. err)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify players of failure
    hook.Add("OnTransferFailed", "NotifyTransferFailure", function(fromChar, toChar, items, err)
        local fromPlayer = fromChar:getPlayer()
        local toPlayer = toChar:getPlayer()

        if IsValid(fromPlayer) then
            fromPlayer:ChatPrint("Transfer failed: " .. err)
        end
        if IsValid(toPlayer) then
            toPlayer:ChatPrint("Transfer failed: " .. err)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer failure handling
    hook.Add("OnTransferFailed", "AdvancedTransferFailure", function(fromChar, toChar, items, err)
        -- Log transfer failure
        lia.log.write("transfer_failed", {
            from = fromChar:getID(),
            to = toChar:getID(),
            items = table.Count(items),
            error = err,
            timestamp = os.time()
            })

            -- Notify players
            local fromPlayer = fromChar:getPlayer()
            local toPlayer = toChar:getPlayer()

            if IsValid(fromPlayer) then
                fromPlayer:ChatPrint("Failed to transfer items: " .. err)
            end
            if IsValid(toPlayer) then
                toPlayer:ChatPrint("Failed to receive items: " .. err)
            end

            -- Track failure statistics
            local stats = fromChar:getData("transferStats", {failed = 0})
            stats.failed = (stats.failed or 0) + 1
            fromChar:setData("transferStats", stats)
        end)
    ```
]]
function OnTransferFailed(fromChar, toChar, items, err)
end

--[[
    Purpose:
        Called when a player is transferred
    When Called:
        When a player is successfully transferred
    Parameters:
        targetPlayer (Player) - The player who was transferred
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log player transfers
    hook.Add("OnTransferred", "MyAddon", function(targetPlayer)
        print(targetPlayer:Name() .. " was transferred")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track player transfers
    hook.Add("OnTransferred", "TrackTransfers", function(targetPlayer)
        local char = targetPlayer:getChar()
        if char then
            local transfers = char:getData("transfers", 0)
            char:setData("transfers", transfers + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex transfer handling
    hook.Add("OnTransferred", "AdvancedTransfer", function(targetPlayer)
        local char = targetPlayer:getChar()
        if not char then return end

            -- Log transfer
            lia.log.write("player_transferred", {
                player = targetPlayer:SteamID(),
                character = char:getID(),
                timestamp = os.time()
                })

                -- Update transfer statistics
                local stats = char:getData("transferStats", {count = 0})
                stats.count = stats.count + 1
                stats.lastTransfer = os.time()
                char:setData("transferStats", stats)

                -- Notify player
                targetPlayer:ChatPrint("You have been transferred")

                -- Sync character data
                char:sync()
            end)
    ```
]]
function OnTransferred(targetPlayer)
end

--[[
    Purpose:
        Called when a new usergroup is created
    When Called:
        When a usergroup is added to the system
    Parameters:
        groupName (string) - The name of the usergroup
        groupData (table) - The usergroup configuration data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log usergroup creation
    hook.Add("OnUsergroupCreated", "MyAddon", function(groupName, groupData)
        print("Usergroup created: " .. groupName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track usergroups
    hook.Add("OnUsergroupCreated", "TrackUsergroups", function(groupName, groupData)
        MyAddon.usergroups = MyAddon.usergroups or {}
            MyAddon.usergroups[groupName] = {
                data = groupData,
                created = os.time()
            }
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex usergroup creation handling
    hook.Add("OnUsergroupCreated", "AdvancedUsergroupCreation", function(groupName, groupData)
        -- Log usergroup creation
        lia.log.write("usergroup_created", {
            name = groupName,
            permissions = groupData.permissions or {},
                timestamp = os.time()
                })

                -- Store usergroup in database
                lia.db.query("INSERT INTO usergroups (name, data, created) VALUES (?, ?, ?)",
                groupName,
                util.TableToJSON(groupData),
                os.time()
                )

                -- Notify admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("New usergroup created: " .. groupName)
                    end
                end
            end)
    ```
]]
function OnUsergroupCreated(groupName, groupData)
end

--[[
    Purpose:
        Called when usergroup permissions are changed
    When Called:
        When a usergroup's permissions are modified
    Parameters:
        groupName (string) - The name of the usergroup
        permissions (table) - The new permissions table
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log permission changes
    hook.Add("OnUsergroupPermissionsChanged", "MyAddon", function(groupName, permissions)
        print("Permissions changed for: " .. groupName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track permission changes
    hook.Add("OnUsergroupPermissionsChanged", "TrackPermissionChanges", function(groupName, permissions)
        MyAddon.permissionHistory = MyAddon.permissionHistory or {}
            table.insert(MyAddon.permissionHistory, {
                group = groupName,
                permissions = permissions,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex permission change handling
    hook.Add("OnUsergroupPermissionsChanged", "AdvancedPermissionChange", function(groupName, permissions)
        -- Log permission changes
        lia.log.write("permissions_changed", {
            group = groupName,
            permissions = util.TableToJSON(permissions),
            timestamp = os.time()
            })

            -- Update database
            lia.db.query("UPDATE usergroups SET permissions = ? WHERE name = ?",
            util.TableToJSON(permissions),
            groupName
            )

            -- Notify affected players
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetUserGroup() == groupName then
                    ply:ChatPrint("Your usergroup permissions have been updated")
                end
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Permissions updated for " .. groupName)
                end
            end
        end)
    ```
]]
function OnUsergroupPermissionsChanged(groupName, permissions)
end

--[[
    Purpose:
        Called when a usergroup is removed
    When Called:
        When a usergroup is deleted from the system
    Parameters:
        groupName (string) - The name of the usergroup being removed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log usergroup removal
    hook.Add("OnUsergroupRemoved", "MyAddon", function(groupName)
        print("Usergroup removed: " .. groupName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up usergroup data
    hook.Add("OnUsergroupRemoved", "CleanupUsergroup", function(groupName)
        if MyAddon.usergroups and MyAddon.usergroups[groupName] then
            MyAddon.usergroups[groupName] = nil
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex usergroup removal handling
    hook.Add("OnUsergroupRemoved", "AdvancedUsergroupRemoval", function(groupName)
        -- Log usergroup removal
        lia.log.write("usergroup_removed", {
            name = groupName,
            timestamp = os.time()
            })

            -- Remove from database
            lia.db.query("DELETE FROM usergroups WHERE name = ?", groupName)

            -- Reassign affected players
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetUserGroup() == groupName then
                    ply:SetUserGroup("user")
                    ply:ChatPrint("Your usergroup has been removed. You have been reassigned to 'user'.")
                end
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Usergroup removed: " .. groupName)
                end
            end
        end)
    ```
]]
function OnUsergroupRemoved(groupName)
end

--[[
    Purpose:
        Called when a usergroup is renamed
    When Called:
        When a usergroup's name is changed
    Parameters:
        oldName (string) - The old name of the usergroup
        newName (string) - The new name of the usergroup
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log usergroup rename
    hook.Add("OnUsergroupRenamed", "MyAddon", function(oldName, newName)
        print("Usergroup renamed: " .. oldName .. " -> " .. newName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update usergroup tracking
    hook.Add("OnUsergroupRenamed", "UpdateUsergroupTracking", function(oldName, newName)
        if MyAddon.usergroups and MyAddon.usergroups[oldName] then
            MyAddon.usergroups[newName] = MyAddon.usergroups[oldName]
            MyAddon.usergroups[oldName] = nil
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex usergroup rename handling
    hook.Add("OnUsergroupRenamed", "AdvancedUsergroupRename", function(oldName, newName)
        -- Log usergroup rename
        lia.log.write("usergroup_renamed", {
            oldName = oldName,
            newName = newName,
            timestamp = os.time()
            })

            -- Update database
            lia.db.query("UPDATE usergroups SET name = ? WHERE name = ?", newName, oldName)

            -- Update all players in this usergroup
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetUserGroup() == oldName then
                    ply:SetUserGroup(newName)
                    ply:ChatPrint("Your usergroup has been renamed to: " .. newName)
                end
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Usergroup renamed: " .. oldName .. " -> " .. newName)
                end
            end
        end)
    ```
]]
function OnUsergroupRenamed(oldName, newName)
end

--[[
    Purpose:
        Called when a vendor is edited
    When Called:
        When a vendor's properties are modified
    Parameters:
        client (Player) - The player editing the vendor
        vendor (Entity) - The vendor entity being edited
        key (string) - The property being modified
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor edits
    hook.Add("OnVendorEdited", "MyAddon", function(client, vendor, key)
        print(client:Name() .. " edited vendor property: " .. key)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate vendor edits
    hook.Add("OnVendorEdited", "VendorValidation", function(client, vendor, key)
        if key == "price" then
            local newPrice = vendor:getNetVar("price", 0)
            if newPrice < 0 then
                client:ChatPrint("Price cannot be negative")
                return false
            end
            elseif key == "stock" then
                local newStock = vendor:getNetVar("stock", 0)
                if newStock < 0 then
                    client:ChatPrint("Stock cannot be negative")
                    return false
                end
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor editing system
    hook.Add("OnVendorEdited", "AdvancedVendorEditing", function(client, vendor, key)
        local char = client:getChar()
        if not char then return end

            -- Check if player has permission to edit vendors
            if not char:hasFlags("V") then
                client:ChatPrint("You don't have permission to edit vendors")
                return false
            end

            -- Validate specific properties
            if key == "price" then
                local newPrice = vendor:getNetVar("price", 0)
                if newPrice < 0 then
                    client:ChatPrint("Price cannot be negative")
                    return false
                end

                -- Check for price limits based on faction
                local faction = char:getFaction()
                local maxPrice = {
                ["police"] = 10000,
                ["medic"] = 8000,
                ["citizen"] = 5000
            }

            local limit = maxPrice[faction] or 5000
            if newPrice > limit then
                client:ChatPrint("Price exceeds your faction limit of $" .. limit)
                return false
            end

            elseif key == "stock" then
                local newStock = vendor:getNetVar("stock", 0)
                if newStock < 0 then
                    client:ChatPrint("Stock cannot be negative")
                    return false
                end

                -- Check for stock limits
                local maxStock = 1000
                if newStock > maxStock then
                    client:ChatPrint("Stock cannot exceed " .. maxStock)
                    return false
                end

                elseif key == "faction" then
                    local newFaction = vendor:getNetVar("faction", "citizen")
                    local allowedFactions = {"police", "medic", "citizen", "criminal"}
                    if not table.HasValue(allowedFactions, newFaction) then
                        client:ChatPrint("Invalid faction: " .. newFaction)
                        return false
                    end
                end

                -- Log the edit
                print(string.format("%s edited vendor %s property %s to %s",
                client:Name(), vendor:EntIndex(), key, tostring(vendor:getNetVar(key))))

                -- Notify other admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() and ply ~= client then
                        ply:ChatPrint("[ADMIN] " .. client:Name() .. " edited vendor " .. vendor:EntIndex() .. " (" .. key .. ")")
                    end
                end
            end)
    ```
]]
function OnVendorEdited(client, vendor, key)
end

--[[
    Purpose:
        Called when online staff data is received
    When Called:
        When the server receives updated staff information
    Parameters:
        staffData (table) - The staff data containing online staff information
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log staff data
    hook.Add("OnlineStaffDataReceived", "MyAddon", function(staffData)
        print("Received staff data for " .. table.Count(staffData) .. " staff members")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track online staff
    hook.Add("OnlineStaffDataReceived", "TrackStaff", function(staffData)
        MyAddon.onlineStaff = MyAddon.onlineStaff or {}
            for steamID, data in pairs(staffData) do
                MyAddon.onlineStaff[steamID] = {
                    name = data.name,
                    rank = data.rank,
                    lastSeen = os.time()
                }
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex staff management
    hook.Add("OnlineStaffDataReceived", "AdvancedStaffManagement", function(staffData)
        -- Log staff data update
        lia.log.write("staff_data_received", {
            count = table.Count(staffData),
            timestamp = os.time()
            })

            -- Update staff database
            for steamID, data in pairs(staffData) do
                lia.db.query("INSERT OR REPLACE INTO staff_data (steamid, name, rank, last_seen) VALUES (?, ?, ?, ?)",
                steamID,
                data.name,
                data.rank,
                os.time()
                )
            end

            -- Notify players of staff changes
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Staff data updated")
                end
            end
        end)
    ```
]]
function OnlineStaffDataReceived(staffData)
end

--[[
    Purpose:
        Called when a client option is received
    When Called:
        When the server receives an option setting from a client
    Parameters:
        client (Player) - The player who sent the option
        key (string) - The option key
        value (any) - The option value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log option changes
    hook.Add("OptionReceived", "MyAddon", function(client, key, value)
        print(client:Name() .. " changed option " .. key .. " to " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track option changes
    hook.Add("OptionReceived", "TrackOptions", function(client, key, value)
        local char = client:getChar()
        if char then
            local options = char:getData("options", {})
            options[key] = value
            char:setData("options", options)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex option handling
    hook.Add("OptionReceived", "AdvancedOptionHandling", function(client, key, value)
        -- Log option change
        lia.log.write("option_changed", {
            player = client:SteamID(),
            key = key,
            value = tostring(value),
            timestamp = os.time()
            })

            -- Validate option value
            if key == "volume" and (value < 0 or value > 1) then
                client:ChatPrint("Invalid volume value")
                return
            end

            -- Store option in character data
            local char = client:getChar()
            if char then
                local options = char:getData("options", {})
                options[key] = value
                char:setData("options", options)
            end
        end)
    ```
]]
function OptionReceived(client, key, value)
end

--[[
    Purpose:
        Called to override a player's respawn time
    When Called:
        When a player's respawn time needs to be modified
    Parameters:
        client (Player) - The player respawning
        respawnTime (number) - The current respawn time in seconds
    Returns:
        number - The overridden respawn time (or nil to use default)
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Reduce respawn time
    hook.Add("OverrideSpawnTime", "MyAddon", function(client, respawnTime)
        return respawnTime * 0.5
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Faction-based respawn times
    hook.Add("OverrideSpawnTime", "FactionRespawnTime", function(client, respawnTime)
        local char = client:getChar()
        if not char then return end

            local faction = char:getFaction()
            if faction == FACTION_POLICE then
                return 30
                elseif faction == FACTION_MEDIC then
                    return 20
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Dynamic respawn time system
    hook.Add("OverrideSpawnTime", "DynamicRespawnTime", function(client, respawnTime)
        local char = client:getChar()
        if not char then return end

            -- Check for respawn time reduction items
            local inventory = char:getInv()
            if inventory then
                for _, item in pairs(inventory:getItems()) do
                    if item.reduceRespawnTime then
                        respawnTime = respawnTime * 0.75
                    end
                end
            end

            -- Check for VIP status
            if client:IsUserGroup("vip") then
                respawnTime = respawnTime * 0.5
            end

            -- Check death count
            local deaths = char:getData("deaths", 0)
            if deaths > 5 then
                respawnTime = respawnTime + (deaths * 2)
            end

            return math.max(respawnTime, 5)
        end)
    ```
]]
function OverrideSpawnTime(client, respawnTime)
end

--[[
    Purpose:
        Called when a player accesses a vendor
    When Called:
        When a player interacts with a vendor entity
    Parameters:
        activator (Player) - The player accessing the vendor
        self (Entity) - The vendor entity
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor access
    hook.Add("PlayerAccessVendor", "MyAddon", function(activator, self)
        print(activator:Name() .. " accessed a vendor")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track vendor usage
    hook.Add("PlayerAccessVendor", "TrackVendorUsage", function(activator, self)
        local char = activator:getChar()
        if char then
            local vendorUses = char:getData("vendorUses", 0)
            char:setData("vendorUses", vendorUses + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor access tracking
    hook.Add("PlayerAccessVendor", "AdvancedVendorAccess", function(activator, self)
        local char = activator:getChar()
        if not char then return end

            -- Track vendor usage
            local vendorUses = char:getData("vendorUses", 0)
            char:setData("vendorUses", vendorUses + 1)

            -- Log to database
            local vendorID = self:getNetVar("vendorID", "unknown")
            lia.db.query("INSERT INTO vendor_logs (timestamp, charid, vendorid) VALUES (?, ?, ?)",
            os.time(), char:getID(), vendorID)

            -- Apply first-time bonus
            if vendorUses == 0 then
                activator:ChatPrint("First time using a vendor! Here's a discount.")
                self:setNetVar("discount_" .. char:getID(), 10)
            end

            -- Check for achievements
            if vendorUses + 1 >= 100 then
                if not char:getData("achievement_shopaholic", false) then
                    char:setData("achievement_shopaholic", true)
                    activator:ChatPrint("Achievement unlocked: Shopaholic!")
                end
            end
        end)
    ```
]]
function PlayerAccessVendor(activator, self)
end

--[[
    Purpose:
        Called when a player is detected cheating
    When Called:
        When anti-cheat systems detect suspicious behavior
    Parameters:
        client (Player) - The player who was detected cheating
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log cheat detection
    hook.Add("PlayerCheatDetected", "MyAddon", function(client)
        print("Cheat detected: " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle cheat detection
    hook.Add("PlayerCheatDetected", "HandleCheating", function(client)
        client:Kick("Cheating detected")

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Player " .. client:Name() .. " was kicked for cheating")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex cheat detection handling
    hook.Add("PlayerCheatDetected", "AdvancedCheatDetection", function(client)
        -- Log cheat detection
        lia.log.write("cheat_detected", {
            player = client:SteamID(),
            name = client:Name(),
            ip = client:IPAddress(),
            timestamp = os.time()
            })

            -- Record cheat attempt
            lia.db.query("INSERT INTO cheat_logs (steamid, name, ip, timestamp) VALUES (?, ?, ?, ?)",
            client:SteamID(),
            client:Name(),
            client:IPAddress(),
            os.time()
            )

            -- Apply punishment based on history
            local char = client:getChar()
            if char then
                local cheatCount = char:getData("cheatCount", 0) + 1
                char:setData("cheatCount", cheatCount)

                if cheatCount >= 3 then
                    client:Ban(0, "Multiple cheat violations")
                    else
                        client:Kick("Cheating detected (Warning " .. cheatCount .. "/3)")
                    end
                end

                -- Notify all admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[CHEAT] " .. client:Name() .. " detected and punished")
                    end
                end
            end)
    ```
]]
function PlayerCheatDetected(client)
end

--[[
    Purpose:
        Called when a player disconnects from the server
    When Called:
        When a player leaves the server
    Parameters:
        client (Player) - The player who disconnected
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log player disconnections
    hook.Add("PlayerDisconnect", "MyAddon", function(client)
        print(client:Name() .. " disconnected")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle player cleanup
    hook.Add("PlayerDisconnect", "PlayerCleanup", function(client)
        local char = client:getChar()
        if char then
            -- Save character data
            char:setData("lastDisconnect", os.time())
            char:setData("disconnectPos", client:GetPos())

            -- Clean up temporary data
            char:setData("tempData", nil)

            -- Notify other players
            for _, ply in ipairs(player.GetAll()) do
                ply:ChatPrint(client:Name() .. " has left the server")
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex player disconnect system
    hook.Add("PlayerDisconnect", "AdvancedDisconnect", function(client)
        local char = client:getChar()
        if not char then return end

            -- Save character state
            char:setData("lastDisconnect", os.time())
            char:setData("disconnectPos", client:GetPos())
            char:setData("disconnectAng", client:GetAngles())
            char:setData("disconnectHealth", client:Health())
            char:setData("disconnectArmor", client:Armor())

            -- Save inventory state
            local inventory = char:getInv()
            if inventory then
                char:setData("inventoryState", inventory:getData())
            end

            -- Clean up temporary data
            char:setData("tempData", nil)
            char:setData("activeEffects", nil)

            -- Handle faction-specific cleanup
            local faction = char:getFaction()
            if faction == "police" then
                -- Remove police authority
                char:setData("authority", 0)
                elseif faction == "medic" then
                    -- Remove medical equipment
                    local medItems = {"medkit", "stethoscope", "bandage"}
                    for _, itemID in ipairs(medItems) do
                        local item = inventory:hasItem(itemID)
                        if item then
                            inventory:remove(item)
                        end
                    end
                end

                -- Update player statistics
                local playTime = client:getData("playTime", 0)
                local sessionTime = os.time() - (client:getData("joinTime", os.time()))
                char:setData("totalPlayTime", char:getData("totalPlayTime", 0) + sessionTime)

                -- Notify other players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= client then
                        ply:ChatPrint(client:Name() .. " has left the server")
                    end
                end

                -- Log disconnect
                print(string.format("%s disconnected at %s (Play time: %d minutes)",
                client:Name(), os.date("%Y-%m-%d %H:%M:%S"), math.floor(sessionTime / 60)))
            end)
    ```
]]
--[[
    Purpose:
        Called when a player disconnects
    When Called:
        When a player leaves the server
    Parameters:
        client (Player) - The player disconnecting
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log disconnect
    hook.Add("PlayerDisconnect", "MyAddon", function(client)
        print(client:Name() .. " disconnected")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save player data on disconnect
    hook.Add("PlayerDisconnect", "SaveOnDisconnect", function(client)
        local char = client:getChar()
        if char then
            char:save()
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex disconnect handling
    hook.Add("PlayerDisconnect", "AdvancedDisconnect", function(client)
        local char = client:getChar()
        if char then
            -- Save character data
            char:save()

            -- Update playtime
            local sessionStart = char:getData("sessionStart", os.time())
            local sessionTime = os.time() - sessionStart
            local totalPlaytime = char:getData("playTime", 0)
            char:setData("playTime", totalPlaytime + sessionTime)

            -- Log disconnect
            lia.db.query("INSERT INTO disconnect_logs (timestamp, steamid, charid, playtime) VALUES (?, ?, ?, ?)",
            os.time(), client:SteamID(), char:getID(), sessionTime)
        end

        -- Notify other players
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                ply:ChatPrint(client:Name() .. " has disconnected")
            end
        end
    end)
    ```
]]
function PlayerDisconnect(client)
end

--[[
    Purpose:
        Called when a player is gagged
    When Called:
        When a player's voice chat is disabled
    Parameters:
        target (Player) - The player being gagged
        admin (Player) - The admin issuing the gag
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log gag
    hook.Add("PlayerGagged", "MyAddon", function(target, admin)
        print(target:Name() .. " was gagged by " .. admin:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track gag history
    hook.Add("PlayerGagged", "TrackGagHistory", function(target, admin)
        local char = target:getChar()
        if char then
            local gagHistory = char:getData("gagHistory", {})
            table.insert(gagHistory, {admin = admin:SteamID(), time = os.time()})
                char:setData("gagHistory", gagHistory)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex gag management
    hook.Add("PlayerGagged", "AdvancedGagManagement", function(target, admin)
        local char = target:getChar()
        if not char then return end

            -- Track gag history
            local gagHistory = char:getData("gagHistory", {})
            table.insert(gagHistory, {
                admin = admin:SteamID(),
                adminName = admin:Name(),
                time = os.time()
                })
                char:setData("gagHistory", gagHistory)

                -- Log to database
                lia.db.query("INSERT INTO gag_logs (timestamp, target_steamid, admin_steamid) VALUES (?, ?, ?)",
                os.time(), target:SteamID(), admin:SteamID())

                -- Notify player
                target:ChatPrint("You have been gagged by " .. admin:Name())

                -- Notify other admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() and ply ~= admin and ply ~= target then
                        ply:ChatPrint("[ADMIN] " .. admin:Name() .. " gagged " .. target:Name())
                    end
                end
            end)
    ```
]]
function PlayerGagged(target, admin)
end

--[[
    Purpose:
        Called when a player's Lilia data is loaded
    When Called:
        When a player's framework data has been loaded from the database
    Parameters:
        client (Player) - The player whose data was loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data loading
    hook.Add("PlayerLiliaDataLoaded", "MyAddon", function(client)
        print("Lilia data loaded for " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize player after data load
    hook.Add("PlayerLiliaDataLoaded", "InitPlayer", function(client)
        local char = client:getChar()
        if char then
            char:setData("addonInitialized", true)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data loading handling
    hook.Add("PlayerLiliaDataLoaded", "AdvancedDataLoading", function(client)
        local char = client:getChar()
        if not char then return end

            -- Log data loading
            lia.log.write("player_data_loaded", {
                player = client:SteamID(),
                character = char:getID(),
                timestamp = os.time()
                })

                -- Load custom player data
                lia.data.get("player_" .. client:SteamID(), {}, function(data)
                    client.customData = data
                end)

                -- Initialize player systems
                if MyAddon.playerSystems then
                    MyAddon.playerSystems:InitializePlayer(client)
                end

                -- Sync data to client
                net.Start("liaPlayerDataSync")
                net.WriteTable(client.customData or {})
                    net.Send(client)
                end)
    ```
]]
function PlayerLiliaDataLoaded(client)
end

--[[
    Purpose:
        Called when a player loads a character
    When Called:
        When a player successfully loads a character
    Parameters:
        client (Player) - The player loading the character
        character (Character) - The character being loaded
        currentChar (Character) - The previously loaded character (if any)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character loading
    hook.Add("PlayerLoadedChar", "MyAddon", function(client, character, currentChar)
        print(client:Name() .. " loaded character: " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Handle character switching
    hook.Add("PlayerLoadedChar", "CharSwitching", function(client, character, currentChar)
        if currentChar then
            -- Save previous character data
            currentChar:setData("lastSwitch", os.time())
            currentChar:setData("switchPos", client:GetPos())
        end

        -- Set up new character
        character:setData("lastLoad", os.time())
        character:setData("loadCount", (character:getData("loadCount", 0) + 1))

        client:ChatPrint("Character loaded: " .. character:getName())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character loading system
    hook.Add("PlayerLoadedChar", "AdvancedCharLoading", function(client, character, currentChar)
        -- Handle previous character cleanup
        if currentChar then
            currentChar:setData("lastSwitch", os.time())
            currentChar:setData("switchPos", client:GetPos())
            currentChar:setData("switchHealth", client:Health())
            currentChar:setData("switchArmor", client:Armor())
        end

        -- Set up new character
        character:setData("lastLoad", os.time())
        character:setData("loadCount", (character:getData("loadCount", 0) + 1))

        -- Apply faction bonuses
        local faction = character:getFaction()
        local factionBonuses = {
        ["police"] = {
            authority = 5,
            salary = 1000,
            items = {"police_badge", "handcuffs", "radio"}
                },
                ["medic"] = {
                    healingBonus = 1.5,
                    medicalKnowledge = 10,
                    salary = 800,
                    items = {"medkit", "stethoscope", "bandage"}
                        },
                        ["citizen"] = {
                            authority = 0,
                            salary = 500,
                            items = {"wallet", "phone"}
                            }
                        }

                        local bonuses = factionBonuses[faction]
                        if bonuses then
                            -- Apply stat bonuses
                            for stat, value in pairs(bonuses) do
                                if stat ~= "items" then
                                    character:setData(stat, value)
                                end
                            end

                            -- Give faction items
                            if bonuses.items then
                                local inventory = character:getInv()
                                for _, itemID in ipairs(bonuses.items) do
                                    local item = lia.item.instance(itemID)
                                    if item then
                                        inventory:add(item)
                                    end
                                end
                            end
                        end

                        -- Check for returning player bonuses
                        local lastLoad = character:getData("lastLoad", 0)
                        local timeSinceLoad = os.time() - lastLoad
                        if timeSinceLoad > 86400 then -- 24 hours
                            character:setData("returningPlayerBonus", true)
                            client:ChatPrint("Welcome back! You have a returning player bonus.")
                        end

                        -- Update character appearance
                        hook.Run("SetupPlayerModel", client, character)

                        -- Notify other players
                        for _, ply in ipairs(player.GetAll()) do
                            if ply ~= client then
                                ply:ChatPrint(client:Name() .. " is now playing as " .. character:getName())
                            end
                        end

                        -- Log character load
                        print(string.format("%s loaded character %s (Faction: %s)",
                        client:Name(), character:getName(), faction))
                    end)
    ```
]]
function PlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Called when a player sends a message
    When Called:
        When a player sends a chat message
    Parameters:
        speaker (Player) - The player sending the message
        chatType (string) - The type of chat message
        text (string) - The message text
        anonymous (boolean) - Whether the message is anonymous
        receivers (table) - List of players who will receive the message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log all messages
    hook.Add("PlayerMessageSend", "MyAddon", function(speaker, chatType, text, anonymous, receivers)
        print(speaker:Name() .. " said: " .. text)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter inappropriate messages
    hook.Add("PlayerMessageSend", "MessageFilter", function(speaker, chatType, text, anonymous, receivers)
        local bannedWords = {"spam", "hack", "cheat"}
        for _, word in ipairs(bannedWords) do
            if string.find(string.lower(text), string.lower(word)) then
                speaker:ChatPrint("Your message was blocked for inappropriate content")
                return false
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex message system
    hook.Add("PlayerMessageSend", "AdvancedMessages", function(speaker, chatType, text, anonymous, receivers)
        local char = speaker:getChar()
        if not char then return end

            -- Check if player is muted
            if char:getData("muted", false) then
                speaker:ChatPrint("You are muted and cannot send messages")
                return false
            end

            -- Check if player is gagged
            if char:getData("gagged", false) then
                speaker:ChatPrint("You are gagged and cannot send messages")
                return false
            end

            -- Check message length
            if string.len(text) > 200 then
                speaker:ChatPrint("Message too long (max 200 characters)")
                return false
            end

            -- Check for spam
            local lastMessage = char:getData("lastMessage", 0)
            local messageCooldown = 1 -- 1 second cooldown
            if os.time() - lastMessage < messageCooldown then
                speaker:ChatPrint("Please wait before sending another message")
                return false
            end

            -- Check for inappropriate content
            local bannedWords = {"spam", "hack", "cheat", "exploit"}
            for _, word in ipairs(bannedWords) do
                if string.find(string.lower(text), string.lower(word)) then
                    speaker:ChatPrint("Your message was blocked for inappropriate content")
                    return false
                end
            end

            -- Update last message time
            char:setData("lastMessage", os.time())

            -- Check for faction-specific restrictions
            local faction = char:getFaction()
            if faction == "police" and chatType == "ooc" then
                -- Police can't use OOC chat
                speaker:ChatPrint("Police officers cannot use OOC chat")
                return false
            end

            -- Check for admin commands
            if string.sub(text, 1, 1) == "!" then
                local command = string.sub(text, 2)
                if command == "admin" then
                    -- Admin command
                    speaker:ChatPrint("Admin command executed")
                    return false
                end
            end

            -- Log message
            print(string.format("[%s] %s: %s", chatType, speaker:Name(), text))
        end)
    ```
]]
--[[
    Purpose:
        Called when a player sends a message
    When Called:
        When a chat message is being sent
    Parameters:
        speaker (Player) - The player sending the message
        chatType (string) - The type of chat
        text (string) - The message text
        anonymous (boolean) - Whether the message is anonymous
        receivers (table) - The players receiving the message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log messages
    hook.Add("PlayerMessageSend", "MyAddon", function(speaker, chatType, text, anonymous, receivers)
        print(speaker:Name() .. " sent: " .. text)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter inappropriate messages
    hook.Add("PlayerMessageSend", "FilterMessages", function(speaker, chatType, text, anonymous, receivers)
        local bannedWords = {"spam", "hack"}
        for _, word in ipairs(bannedWords) do
            if string.find(string.lower(text), word) then
                speaker:ChatPrint("Your message was blocked")
                return false
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex message handling
    hook.Add("PlayerMessageSend", "AdvancedMessageHandling", function(speaker, chatType, text, anonymous, receivers)
        local char = speaker:getChar()
        if not char then return false end

            -- Filter inappropriate content
            local bannedWords = {"spam", "hack", "cheat"}
            for _, word in ipairs(bannedWords) do
                if string.find(string.lower(text), word) then
                    speaker:ChatPrint("Your message was blocked for inappropriate content")
                    return false
                end
            end

            -- Check spam protection
            local lastMessage = char:getData("lastMessage", 0)
            if os.time() - lastMessage < 1 then
                speaker:ChatPrint("Please wait before sending another message")
                return false
            end
            char:setData("lastMessage", os.time())

            -- Log to database
            lia.db.query("INSERT INTO chat_logs (timestamp, steamid, chattype, message) VALUES (?, ?, ?, ?)",
            os.time(), speaker:SteamID(), chatType, text)

            -- Track message count
            local messageCount = char:getData("messageCount", 0)
            char:setData("messageCount", messageCount + 1)
        end)
    ```
]]
function PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
end

--[[
    Purpose:
        Called when a player's model changes
    When Called:
        When a player's character model is changed
    Parameters:
        client (Player) - The player whose model changed
        value (string) - The new model path
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log model change
    hook.Add("PlayerModelChanged", "MyAddon", function(client, value)
        print(client:Name() .. " model changed to " .. value)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track model changes
    hook.Add("PlayerModelChanged", "TrackModelChanges", function(client, value)
        local char = client:getChar()
        if char then
            local modelHistory = char:getData("modelHistory", {})
            table.insert(modelHistory, {model = value, time = os.time()})
                char:setData("modelHistory", modelHistory)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model change tracking
    hook.Add("PlayerModelChanged", "AdvancedModelTracking", function(client, value)
        local char = client:getChar()
        if not char then return end

            -- Track model history
            local modelHistory = char:getData("modelHistory", {})
            table.insert(modelHistory, {model = value, time = os.time()})
                char:setData("modelHistory", modelHistory)

                -- Log to database
                lia.db.query("INSERT INTO model_logs (timestamp, charid, model) VALUES (?, ?, ?)",
                os.time(), char:getID(), value)

                -- Apply model-specific effects
                local gender = hook.Run("GetModelGender", value) or "male"
                char:setData("gender", gender)

                -- Notify nearby players
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= client and ply:GetPos():Distance(client:GetPos()) < 500 then
                        ply:ChatPrint(client:Name() .. " changed their appearance")
                    end
                end
            end)
    ```
]]
function PlayerModelChanged(client, value)
end

--[[
    Purpose:
        Called when a player is muted
    When Called:
        When a player's chat is disabled
    Parameters:
        target (Player) - The player being muted
        admin (Player) - The admin issuing the mute
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log mute
    hook.Add("PlayerMuted", "MyAddon", function(target, admin)
        print(target:Name() .. " was muted by " .. admin:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track mute history
    hook.Add("PlayerMuted", "TrackMuteHistory", function(target, admin)
        local char = target:getChar()
        if char then
            local muteHistory = char:getData("muteHistory", {})
            table.insert(muteHistory, {admin = admin:SteamID(), time = os.time()})
                char:setData("muteHistory", muteHistory)
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex mute management
    hook.Add("PlayerMuted", "AdvancedMuteManagement", function(target, admin)
        local char = target:getChar()
        if not char then return end

            -- Track mute history
            local muteHistory = char:getData("muteHistory", {})
            table.insert(muteHistory, {
                admin = admin:SteamID(),
                adminName = admin:Name(),
                time = os.time()
                })
                char:setData("muteHistory", muteHistory)

                -- Log to database
                lia.db.query("INSERT INTO mute_logs (timestamp, target_steamid, admin_steamid) VALUES (?, ?, ?)",
                os.time(), target:SteamID(), admin:SteamID())

                -- Notify player
                target:ChatPrint("You have been muted by " .. admin:Name())

                -- Notify other admins
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() and ply ~= admin and ply ~= target then
                        ply:ChatPrint("[ADMIN] " .. admin:Name() .. " muted " .. target:Name())
                    end
                end
            end)
    ```
]]
function PlayerMuted(target, admin)
end

--[[
    Purpose:
        Called to check if a player should perform an action
    When Called:
        When validating player actions
    Parameters:
        None
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always allow
    hook.Add("PlayerShouldAct", "MyAddon", function()
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check player state
    hook.Add("PlayerShouldAct", "CheckPlayerState", function()
        local client = LocalPlayer()
        if not IsValid(client) then return false end

            local char = client:getChar()
            return char ~= nil
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex action validation
    hook.Add("PlayerShouldAct", "AdvancedActionValidation", function()
        local client = LocalPlayer()
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check if player is tied
                if char:getData("tied", false) then
                    return false
                end

                -- Check if player is stunned
                if char:getData("stunned", false) then
                    return false
                end

                -- Check if player is in cutscene
                if char:getData("inCutscene", false) then
                    return false
                end

                return true
            end)
    ```
]]
function PlayerShouldAct()
end

--[[
    Purpose:
        Called to check if a player should be permakilled
    When Called:
        When a player dies and permakill is being considered
    Parameters:
        client (Player) - The dying player
        inflictor (Entity) - The entity that caused death
        attacker (Entity) - The attacker
    Returns:
        boolean - True to permakill, false otherwise
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Never permakill
    hook.Add("PlayerShouldPermaKill", "MyAddon", function(client, inflictor, attacker)
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Permakill on admin command
    hook.Add("PlayerShouldPermaKill", "AdminPermakill", function(client, inflictor, attacker)
        local char = client:getChar()
        if char and char:getData("markedForPK", false) then
            return true
        end
        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex permakill system
    hook.Add("PlayerShouldPermaKill", "AdvancedPermakill", function(client, inflictor, attacker)
        local char = client:getChar()
        if not char then return false end

            -- Check if marked for PK
            if char:getData("markedForPK", false) then
                return true
            end

            -- Check faction-specific rules
            local faction = char:getFaction()
            if faction == "police" then
                -- Police can only be PKed by admins
                if IsValid(attacker) and attacker:IsPlayer() and attacker:IsAdmin() then
                    return true
                end
                return false
            end

            -- Check death count
            local deathCount = char:getData("deathCount", 0)
            if deathCount >= 5 then
                -- Too many deaths, permakill
                return true
            end

            return false
        end)
    ```
]]
function PlayerShouldPermaKill(client, inflictor, attacker)
end

--[[
    Purpose:
        Called when a player spawn point is selected
    When Called:
        When determining where a player should spawn
    Parameters:
        client (Player) - The player spawning
        pos (Vector) - The spawn position
        ang (Angle) - The spawn angle
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log spawn point
    hook.Add("PlayerSpawnPointSelected", "MyAddon", function(client, pos, ang)
        print(client:Name() .. " spawning at " .. tostring(pos))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track spawn locations
    hook.Add("PlayerSpawnPointSelected", "TrackSpawnLocations", function(client, pos, ang)
        local char = client:getChar()
        if char then
            char:setData("lastSpawnPos", pos)
            char:setData("lastSpawnAng", ang)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex spawn tracking
    hook.Add("PlayerSpawnPointSelected", "AdvancedSpawnTracking", function(client, pos, ang)
        local char = client:getChar()
        if not char then return end

            -- Track spawn location
            char:setData("lastSpawnPos", pos)
            char:setData("lastSpawnAng", ang)
            char:setData("lastSpawnTime", os.time())

            -- Log to database
            lia.db.query("INSERT INTO spawn_logs (timestamp, charid, x, y, z) VALUES (?, ?, ?, ?, ?)",
            os.time(), char:getID(), pos.x, pos.y, pos.z)

            -- Track spawn count
            local spawnCount = char:getData("spawnCount", 0)
            char:setData("spawnCount", spawnCount + 1)

            -- Apply spawn effects
            client:SetHealth(100)
            client:SetArmor(0)
        end)
    ```
]]
function PlayerSpawnPointSelected(client, pos, ang)
end

--[[
    Purpose:
        Called when a player throws a punch
    When Called:
        When a player uses their fists to attack
    Parameters:
        client (Player) - The player throwing the punch
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log punch
    hook.Add("PlayerThrowPunch", "MyAddon", function(client)
        print(client:Name() .. " threw a punch")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track punch count
    hook.Add("PlayerThrowPunch", "TrackPunches", function(client)
        local char = client:getChar()
        if char then
            local punchCount = char:getData("punchCount", 0)
            char:setData("punchCount", punchCount + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex punch tracking system
    hook.Add("PlayerThrowPunch", "AdvancedPunchTracking", function(client)
        local char = client:getChar()
        if not char then return end

            -- Track punch count
            local punchCount = char:getData("punchCount", 0)
            char:setData("punchCount", punchCount + 1)

            -- Drain stamina
            local stamina = client:getNetVar("stamina", 100)
            client:setNetVar("stamina", math.max(0, stamina - 5))

            -- Check for achievements
            if punchCount + 1 >= 500 then
                if not char:getData("achievement_brawler", false) then
                    char:setData("achievement_brawler", true)
                    client:ChatPrint("Achievement unlocked: Brawler!")
                end
            end
        end)
    ```
]]
function PlayerThrowPunch(client)
end

--[[
    Purpose:
        Called when a player is ungagged
    When Called:
        When a player's voice chat is re-enabled
    Parameters:
        target (Player) - The player being ungagged
        admin (Player) - The admin removing the gag
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ungag
    hook.Add("PlayerUngagged", "MyAddon", function(target, admin)
        print(target:Name() .. " was ungagged by " .. admin:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify player
    hook.Add("PlayerUngagged", "NotifyUngag", function(target, admin)
        target:ChatPrint("You have been ungagged by " .. admin:Name())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ungag management
    hook.Add("PlayerUngagged", "AdvancedUngagManagement", function(target, admin)
        -- Log to database
        lia.db.query("INSERT INTO ungag_logs (timestamp, target_steamid, admin_steamid) VALUES (?, ?, ?)",
        os.time(), target:SteamID(), admin:SteamID())

        -- Notify player
        target:ChatPrint("You have been ungagged by " .. admin:Name())

        -- Notify other admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() and ply ~= admin and ply ~= target then
                ply:ChatPrint("[ADMIN] " .. admin:Name() .. " ungagged " .. target:Name())
            end
        end
    end)
    ```
]]
function PlayerUngagged(target, admin)
end

--[[
    Purpose:
        Called when a player is unmuted
    When Called:
        When a player's chat is re-enabled
    Parameters:
        target (Player) - The player being unmuted
        admin (Player) - The admin removing the mute
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log unmute
    hook.Add("PlayerUnmuted", "MyAddon", function(target, admin)
        print(target:Name() .. " was unmuted by " .. admin:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify player
    hook.Add("PlayerUnmuted", "NotifyUnmute", function(target, admin)
        target:ChatPrint("You have been unmuted by " .. admin:Name())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex unmute management
    hook.Add("PlayerUnmuted", "AdvancedUnmuteManagement", function(target, admin)
        -- Log to database
        lia.db.query("INSERT INTO unmute_logs (timestamp, target_steamid, admin_steamid) VALUES (?, ?, ?)",
        os.time(), target:SteamID(), admin:SteamID())

        -- Notify player
        target:ChatPrint("You have been unmuted by " .. admin:Name())

        -- Notify other admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() and ply ~= admin and ply ~= target then
                ply:ChatPrint("[ADMIN] " .. admin:Name() .. " unmuted " .. target:Name())
            end
        end
    end)
    ```
]]
function PlayerUnmuted(target, admin)
end

--[[
    Purpose:
        Called when a player uses a door
    When Called:
        When a player attempts to open/close a door
    Parameters:
        client (Player) - The player using the door
        door (Entity) - The door being used
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door usage
    hook.Add("PlayerUseDoor", "MyAddon", function(client, door)
        print(client:Name() .. " used door " .. door:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track door usage statistics
    hook.Add("PlayerUseDoor", "DoorUsageTracking", function(client, door)
        local doorData = door:getNetVar("doorData", {})
        doorData.useCount = (doorData.useCount or 0) + 1
        doorData.lastUsed = os.time()
        door:setNetVar("doorData", doorData)

        local char = client:getChar()
        if char then
            char:setData("doorsUsed", (char:getData("doorsUsed", 0) + 1))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door usage system
    hook.Add("PlayerUseDoor", "AdvancedDoorUsage", function(client, door)
        local char = client:getChar()
        if not char then return end

            -- Check if door is locked
            local doorData = door:getNetVar("doorData", {})
            if doorData.locked then
                local doorOwner = door:getNetVar("owner")
                if doorOwner and doorOwner ~= char:getID() then
                    client:ChatPrint("This door is locked")
                    return false
                end
            end

            -- Check faction restrictions
            local allowedFactions = doorData.allowedFactions
            if allowedFactions then
                local faction = char:getFaction()
                if not table.HasValue(allowedFactions, faction) then
                    client:ChatPrint("Your faction cannot use this door")
                    return false
                end
            end

            -- Check time restrictions
            local timeRestriction = doorData.timeRestriction
            if timeRestriction then
                local currentHour = tonumber(os.date("%H"))
                if currentHour < timeRestriction.start or currentHour > timeRestriction.end then
                    client:ChatPrint("This door is only accessible during " .. timeRestriction.start .. ":00-" .. timeRestriction.end .. ":00")
                    return false
                end
            end

            -- Check key requirements
            if doorData.requiredKey then
                local charInv = char:getInv()
                local hasKey = false
                for _, item in pairs(charInv:getItems()) do
                    if item.uniqueID == doorData.requiredKey then
                        hasKey = true
                        break
                    end
                end
                if not hasKey then
                    client:ChatPrint("You need a key to use this door")
                    return false
                end
            end

            -- Update door statistics
            doorData.useCount = (doorData.useCount or 0) + 1
            doorData.lastUsed = os.time()
            doorData.lastUsedBy = char:getID()
            door:setNetVar("doorData", doorData)

            -- Update character statistics
            char:setData("doorsUsed", (char:getData("doorsUsed", 0) + 1))

            -- Check for achievement
            local doorsUsed = char:getData("doorsUsed", 0)
            if doorsUsed >= 1000 and not char:getData("achievement_doorman", false) then
                char:setData("achievement_doorman", true)
                client:ChatPrint("Achievement unlocked: Doorman!")
            end

            -- Log door usage
            print(string.format("%s used door %s at %s",
            client:Name(), door:EntIndex(), os.date("%Y-%m-%d %H:%M:%S")))
        end)
    ```
]]
--[[
    Purpose:
        Called when a player uses a door
    When Called:
        When a player interacts with a door entity
    Parameters:
        client (Player) - The player using the door
        door (Entity) - The door entity
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door usage
    hook.Add("PlayerUseDoor", "MyAddon", function(client, door)
        print(client:Name() .. " used a door")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track door usage
    hook.Add("PlayerUseDoor", "TrackDoorUsage", function(client, door)
        local char = client:getChar()
        if char then
            local doorUses = char:getData("doorUses", 0)
            char:setData("doorUses", doorUses + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door usage tracking
    hook.Add("PlayerUseDoor", "AdvancedDoorUsage", function(client, door)
        local char = client:getChar()
        if not char then return end

            -- Track door usage
            local doorUses = char:getData("doorUses", 0)
            char:setData("doorUses", doorUses + 1)

            -- Log to database
            local doorID = door:MapCreationID()
            lia.db.query("INSERT INTO door_usage_logs (timestamp, charid, doorid) VALUES (?, ?, ?)",
            os.time(), char:getID(), doorID)

            -- Check for achievements
            if doorUses + 1 >= 1000 then
                if not char:getData("achievement_doorman", false) then
                    char:setData("achievement_doorman", true)
                    client:ChatPrint("Achievement unlocked: Doorman!")
                end
            end
        end)
    ```
]]
function PlayerUseDoor(client, door)
end

--[[
    Purpose:
        Called after door data is loaded
    When Called:
        After door configuration data is loaded from the database
    Parameters:
        ent (Entity) - The door entity
        doorData (table) - The door data that was loaded
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door data load
    hook.Add("PostDoorDataLoad", "MyAddon", function(ent, doorData)
        print("Door data loaded for entity " .. ent:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply custom door settings
    hook.Add("PostDoorDataLoad", "CustomDoorSettings", function(ent, doorData)
        if doorData.customLocked then
            ent:Fire("Lock")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door data processing
    hook.Add("PostDoorDataLoad", "AdvancedDoorDataProcessing", function(ent, doorData)
        if not IsValid(ent) or not doorData then return end

            -- Apply door settings
            if doorData.locked then
                ent:Fire("Lock")
                else
                    ent:Fire("Unlock")
                end

                -- Set door title
                if doorData.title then
                    ent:setNetVar("title", doorData.title)
                end

                -- Set door price
                if doorData.price then
                    ent:setNetVar("price", doorData.price)
                end

                -- Set door owner
                if doorData.owner then
                    ent:setNetVar("owner", doorData.owner)
                end

                -- Apply faction restrictions
                if doorData.allowedFactions then
                    ent:setNetVar("allowedFactions", doorData.allowedFactions)
                end

                -- Log door data load
                print(string.format("Door data loaded for entity %d: Title=%s, Price=%s, Owner=%s",
                ent:EntIndex(),
                doorData.title or "None",
                doorData.price or "None",
                doorData.owner or "None"))
            end)
    ```
]]
function PostDoorDataLoad(ent, doorData)
end

--[[
    Purpose:
        Called after data is loaded
    When Called:
        After all persistent data has been loaded
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data load completion
    hook.Add("PostLoadData", "MyAddon", function()
        print("Data loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize systems after data load
    hook.Add("PostLoadData", "InitializeSystems", function()
        MyAddon.Initialize()
        print("Systems initialized after data load")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex post-load initialization
    hook.Add("PostLoadData", "AdvancedPostLoadInit", function()
        -- Initialize custom systems
        MyAddon.Initialize()

        -- Validate loaded data
        local data = lia.data.get("myAddonData", {})
        if not data or table.IsEmpty(data) then
            print("Warning: No data found, using defaults")
            data = MyAddon.GetDefaultData()
            lia.data.set("myAddonData", data)
        end

        -- Set up timers
        timer.Create("MyAddonDataSave", 300, 0, function()
        MyAddon.SaveData()
    end)

    print("Post-load initialization completed")
    end)
    ```
]]
function PostLoadData()
end

--[[
    Purpose:
        Called after a player's initial spawn
    When Called:
        After a player has fully spawned for the first time
    Parameters:
        client (Player) - The player who spawned
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Welcome message
    hook.Add("PostPlayerInitialSpawn", "MyAddon", function(client)
        client:ChatPrint("Welcome to the server!")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give starting items
    hook.Add("PostPlayerInitialSpawn", "GiveStartingItems", function(client)
        timer.Simple(1, function()
        if IsValid(client) then
            local char = client:getChar()
            if char then
                local inv = char:getInv()
                if inv then
                    local item = lia.item.instance("item_bandage")
                    if item then
                        inv:add(item)
                    end
                end
            end
        end
    end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex spawn initialization
    hook.Add("PostPlayerInitialSpawn", "AdvancedSpawnInit", function(client)
        timer.Simple(1, function()
        if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

                -- Give starting items
                local inv = char:getInv()
                if inv then
                    local startingItems = {"item_bandage", "item_water", "item_food"}
                    for _, itemID in ipairs(startingItems) do
                        local item = lia.item.instance(itemID)
                        if item then
                            inv:add(item)
                        end
                    end
                end

                -- Set starting money
                if char:getMoney() == 0 then
                    char:giveMoney(500)
                    client:ChatPrint("You received $500 starting money")
                end

                -- Apply first-time bonuses
                local playTime = client:GetUTimeTotalTime()
                if playTime == 0 then
                    char:setData("firstTimeBonus", true)
                    client:ChatPrint("Welcome! You received a first-time bonus!")
                end
            end)
        end)
    ```
]]
function PostPlayerInitialSpawn(client)
end

--[[
    Purpose:
        Called after a player has loaded a character
    When Called:
        After a character has been fully loaded for a player
    Parameters:
        client (Player) - The player
        character (Character) - The character that was loaded
        currentChar (Character) - The previous character (if any)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Welcome message
    hook.Add("PostPlayerLoadedChar", "MyAddon", function(client, character, currentChar)
        client:ChatPrint("Welcome back, " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Restore character state
    hook.Add("PostPlayerLoadedChar", "RestoreCharState", function(client, character, currentChar)
        local health = character:getData("savedHealth", 100)
        client:SetHealth(health)

        local armor = character:getData("savedArmor", 0)
        client:SetArmor(armor)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character load handling
    hook.Add("PostPlayerLoadedChar", "AdvancedCharLoad", function(client, character, currentChar)
        -- Restore character state
        local health = character:getData("savedHealth", 100)
        client:SetHealth(health)

        local armor = character:getData("savedArmor", 0)
        client:SetArmor(armor)

        -- Restore position if saved
        local savedPos = character:getData("savedPosition")
        if savedPos then
            client:SetPos(savedPos)
        end

        -- Update session data
        character:setData("sessionStart", os.time())
        character:setData("lastLogin", os.time())

        -- Notify faction members
        local faction = character:getFaction()
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= client then
                local plyChar = ply:getChar()
                if plyChar and plyChar:getFaction() == faction then
                    ply:ChatPrint(character:getName() .. " has joined the server")
                end
            end
        end
    end)
    ```
]]
function PostPlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Called after a player's loadout is given
    When Called:
        After a player has received their weapons/equipment
    Parameters:
        client (Player) - The player who received loadout
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log loadout
    hook.Add("PostPlayerLoadout", "MyAddon", function(client)
        print(client:Name() .. " received loadout")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Give additional items
    hook.Add("PostPlayerLoadout", "GiveAdditionalItems", function(client)
        local char = client:getChar()
        if char and char:getData("vip", false) then
            client:Give("weapon_pistol")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex loadout system
    hook.Add("PostPlayerLoadout", "AdvancedLoadout", function(client)
        local char = client:getChar()
        if not char then return end

            -- Give faction-specific weapons
            local faction = char:getFaction()
            if faction == "police" then
                client:Give("weapon_pistol")
                client:Give("weapon_stunstick")
                elseif faction == "medic" then
                    client:Give("weapon_medkit")
                end

                -- Give VIP bonuses
                if char:getData("vip", false) then
                    client:SetMaxHealth(150)
                    client:SetHealth(150)
                    client:SetArmor(50)
                end

                -- Apply class bonuses
                local class = char:getData("class")
                if class == "warrior" then
                    client:SetMaxHealth(200)
                    client:SetHealth(200)
                    elseif class == "scout" then
                        client:SetRunSpeed(300)
                        client:SetWalkSpeed(150)
                    end
                end)
    ```
]]
function PostPlayerLoadout(client)
end

--[[
    Purpose:
        Called after a player says something in chat
    When Called:
        After a player's chat message is processed
    Parameters:
        client (Player) - The player who spoke
        message (string) - The message that was said
        chatType (string) - The type of chat message
        anonymous (boolean) - Whether the message was anonymous
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log player speech
    hook.Add("PostPlayerSay", "MyAddon", function(client, message, chatType, anonymous)
        print(client:Name() .. " said: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track speech statistics
    hook.Add("PostPlayerSay", "SpeechTracking", function(client, message, chatType, anonymous)
        local char = client:getChar()
        if char then
            char:setData("messagesSent", (char:getData("messagesSent", 0) + 1))
            char:setData("lastMessage", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex speech system
    hook.Add("PostPlayerSay", "AdvancedSpeech", function(client, message, chatType, anonymous)
        local char = client:getChar()
        if not char then return end

            -- Update speech statistics
            char:setData("messagesSent", (char:getData("messagesSent", 0) + 1))
            char:setData("lastMessage", os.time())

            -- Track chat type usage
            local chatTypes = char:getData("chatTypes", {})
            chatTypes[chatType] = (chatTypes[chatType] or 0) + 1
            char:setData("chatTypes", chatTypes)

            -- Check for achievement
            local messagesSent = char:getData("messagesSent", 0)
            if messagesSent >= 1000 and not char:getData("achievement_chatty", false) then
                char:setData("achievement_chatty", true)
                client:ChatPrint("Achievement unlocked: Chatty!")
            end

            -- Check for roleplay quality
            if chatType == "ic" then
                local roleplayScore = char:getData("roleplayScore", 0)
                local messageLength = string.len(message)

                -- Longer messages get higher roleplay scores
                if messageLength > 50 then
                    roleplayScore = roleplayScore + 1
                    elseif messageLength > 100 then
                        roleplayScore = roleplayScore + 2
                    end

                    char:setData("roleplayScore", roleplayScore)
                end

                -- Check for profanity
                local profanityWords = {"damn", "hell", "crap"}
                local hasProfanity = false
                for _, word in ipairs(profanityWords) do
                    if string.find(string.lower(message), string.lower(word)) then
                        hasProfanity = true
                        break
                    end
                end

                if hasProfanity then
                    char:setData("profanityCount", (char:getData("profanityCount", 0) + 1))

                    -- Warn player about profanity
                    if char:getData("profanityCount", 0) >= 5 then
                        client:ChatPrint("Please keep your language appropriate")
                    end
                end

                -- Log speech
                print(string.format("[%s] %s: %s", chatType, client:Name(), message))

                -- Notify admins of inappropriate speech
                if hasProfanity then
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() and ply ~= client then
                            ply:ChatPrint("[ADMIN] " .. client:Name() .. " used profanity: " .. message)
                        end
                    end
                end
            end)
    ```
]]
--[[
    Purpose:
        Called after a player says something in chat
    When Called:
        After a chat message has been processed and sent
    Parameters:
        client (Player) - The player who spoke
        message (string) - The message that was sent
        chatType (string) - The type of chat
        anonymous (boolean) - Whether the message was anonymous
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log chat messages
    hook.Add("PostPlayerSay", "MyAddon", function(client, message, chatType, anonymous)
        print(client:Name() .. " said: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track chat statistics
    hook.Add("PostPlayerSay", "TrackChatStats", function(client, message, chatType, anonymous)
        local char = client:getChar()
        if char then
            local messageCount = char:getData("messageCount", 0)
            char:setData("messageCount", messageCount + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat tracking system
    hook.Add("PostPlayerSay", "AdvancedChatTracking", function(client, message, chatType, anonymous)
        local char = client:getChar()
        if not char then return end

            -- Track message count
            local messageCount = char:getData("messageCount", 0)
            char:setData("messageCount", messageCount + 1)

            -- Log to database
            lia.db.query("INSERT INTO chat_logs (timestamp, charid, chattype, message, anonymous) VALUES (?, ?, ?, ?, ?)",
            os.time(), char:getID(), chatType, message, anonymous and 1 or 0)

            -- Check for achievements
            if messageCount + 1 >= 1000 then
                if not char:getData("achievement_chatty", false) then
                    char:setData("achievement_chatty", true)
                    client:ChatPrint("Achievement unlocked: Chatty!")
                end
            end
        end)
    ```
]]
function PostPlayerSay(client, message, chatType, anonymous)
end

--[[
    Purpose:
        Called after damage scaling is calculated
    When Called:
        After damage has been scaled but before it's applied
    Parameters:
        hitgroup (number) - The hitgroup that was hit
        dmgInfo (CTakeDamageInfo) - The damage info
        damageScale (number) - The calculated damage scale
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log damage scaling
    hook.Add("PostScaleDamage", "MyAddon", function(hitgroup, dmgInfo, damageScale)
        print("Damage scaled to: " .. damageScale)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply damage effects
    hook.Add("PostScaleDamage", "ApplyDamageEffects", function(hitgroup, dmgInfo, damageScale)
        local target = dmgInfo:GetAttacker()
        if IsValid(target) and target:IsPlayer() then
            local char = target:getChar()
            if char then
                local damage = dmgInfo:GetDamage() * damageScale
                char:setData("lastDamageTaken", damage)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex damage tracking system
    hook.Add("PostScaleDamage", "AdvancedDamageTracking", function(hitgroup, dmgInfo, damageScale)
        local target = dmgInfo:GetAttacker()
        local attacker = dmgInfo:GetAttacker()

        if not IsValid(target) or not IsValid(attacker) then return end

            local targetChar = target:getChar()
            local attackerChar = attacker:getChar()

            if not targetChar or not attackerChar then return end

                local damage = dmgInfo:GetDamage() * damageScale

                -- Log damage to database
                lia.db.query("INSERT INTO damage_logs (timestamp, target_charid, attacker_charid, damage, hitgroup) VALUES (?, ?, ?, ?, ?)",
                os.time(), targetChar:getID(), attackerChar:getID(), damage, hitgroup)

                -- Track damage statistics
                local damageDealt = attackerChar:getData("damageDealt", 0)
                attackerChar:setData("damageDealt", damageDealt + damage)

                local damageTaken = targetChar:getData("damageTaken", 0)
                targetChar:setData("damageTaken", damageTaken + damage)
            end)
    ```
]]
function PostScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Called before a character is deleted
    When Called:
        Before a character deletion is processed
    Parameters:
        id (number) - The character ID being deleted
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character deletion
    hook.Add("PreCharDelete", "MyAddon", function(id)
        print("Character " .. id .. " is being deleted")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Backup character data
    hook.Add("PreCharDelete", "BackupCharData", function(id)
        local char = lia.char.loaded[id]
        if char then
            -- Create backup
            lia.db.query("INSERT INTO char_backups SELECT * FROM characters WHERE id = ?", id)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character deletion preparation
    hook.Add("PreCharDelete", "AdvancedCharDeletePrep", function(id)
        local char = lia.char.loaded[id]
        if not char then return end

            -- Create comprehensive backup
            lia.db.query("INSERT INTO char_backups SELECT * FROM characters WHERE id = ?", id)
            lia.db.query("INSERT INTO char_items_backup SELECT * FROM char_items WHERE charid = ?", id)
            lia.db.query("INSERT INTO char_data_backup SELECT * FROM char_data WHERE charid = ?", id)

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("Character " .. char:getName() .. " (" .. id .. ") is being deleted")
                end
            end

            -- Log deletion
            lia.log.add("Character " .. char:getName() .. " (" .. id .. ") is being deleted", "character")
        end)
    ```
]]
function PreCharDelete(id)
end

--[[
    Purpose:
        Called before door data is saved
    When Called:
        Before door configuration data is saved to database
    Parameters:
        door (Entity) - The door entity
        doorData (table) - The door data being saved
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door save
    hook.Add("PreDoorDataSave", "MyAddon", function(door, doorData)
        print("Saving door data for entity " .. door:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate door data
    hook.Add("PreDoorDataSave", "ValidateDoorData", function(door, doorData)
        if doorData.price and doorData.price < 0 then
            doorData.price = 0
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door data validation
    hook.Add("PreDoorDataSave", "AdvancedDoorDataValidation", function(door, doorData)
        if not IsValid(door) then return end

            -- Validate price
            if doorData.price and doorData.price < 0 then
                doorData.price = 0
                elseif doorData.price and doorData.price > 100000 then
                    doorData.price = 100000
                end

                -- Validate title length
                if doorData.title and #doorData.title > 50 then
                    doorData.title = string.sub(doorData.title, 1, 50)
                end

                -- Add metadata
                doorData.lastSaved = os.time()
                doorData.map = game.GetMap()

                -- Log save
                print(string.format("Saving door data: Entity=%d, Title=%s, Price=%s",
                door:EntIndex(),
                doorData.title or "None",
                doorData.price or "None"))
            end)
    ```
]]
function PreDoorDataSave(door, doorData)
end

--[[
    Purpose:
        Called before a player interacts with an item
    When Called:
        Before an item interaction is processed
    Parameters:
        client (Player) - The player interacting
        action (string) - The action being performed
        self (Item) - The item being interacted with
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all interactions
    hook.Add("PrePlayerInteractItem", "MyAddon", function(client, action, self)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check cooldown
    hook.Add("PrePlayerInteractItem", "CheckCooldown", function(client, action, self)
        local char = client:getChar()
        if not char then return false end

            local lastUse = char:getData("lastItemUse", 0)
            if CurTime() - lastUse < 1 then
                return false
            end

            char:setData("lastItemUse", CurTime())
            return true
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item interaction validation
    hook.Add("PrePlayerInteractItem", "AdvancedItemInteraction", function(client, action, self)
        local char = client:getChar()
        if not char then return false end

            -- Check cooldown
            local lastUse = char:getData("lastItemUse", 0)
            if CurTime() - lastUse < 1 then
                client:ChatPrint("Please wait before using another item")
                return false
            end

            -- Check if item is broken
            local durability = self:getData("durability", 100)
            if durability <= 0 then
                client:ChatPrint("This item is broken and cannot be used")
                return false
            end

            -- Check faction restrictions
            local requiredFaction = self.requiredFaction
            if requiredFaction and char:getFaction() ~= requiredFaction then
                client:ChatPrint("Your faction cannot use this item")
                return false
            end

            char:setData("lastItemUse", CurTime())
            return true
        end)
    ```
]]
function PrePlayerInteractItem(client, action, self)
end

--[[
    Purpose:
        Called before a player loads a character
    When Called:
        Before a character is loaded for a player
    Parameters:
        client (Player) - The player
        character (Character) - The character being loaded
        currentChar (Character) - The current character (if any)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character load
    hook.Add("PrePlayerLoadedChar", "MyAddon", function(client, character, currentChar)
        print(client:Name() .. " is loading character " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save current character state
    hook.Add("PrePlayerLoadedChar", "SaveCurrentChar", function(client, character, currentChar)
        if currentChar then
            currentChar:setData("lastHealth", client:Health())
            currentChar:setData("lastArmor", client:Armor())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character load preparation
    hook.Add("PrePlayerLoadedChar", "AdvancedCharLoadPrep", function(client, character, currentChar)
        -- Save current character state
        if currentChar then
            currentChar:setData("lastHealth", client:Health())
            currentChar:setData("lastArmor", client:Armor())
            currentChar:setData("lastPosition", client:GetPos())
            currentChar:setData("lastAngles", client:GetAngles())
            currentChar:save()
        end

        -- Validate character data
        if not character:getData("validated", false) then
            character:setData("validated", true)
            character:setData("loadCount", (character:getData("loadCount", 0) + 1))
        end

        -- Log character load
        lia.db.query("INSERT INTO char_load_logs (timestamp, charid, steamid) VALUES (?, ?, ?)",
        os.time(), character:getID(), client:SteamID())
    end)
    ```
]]
function PrePlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Called before salary is given to a player
    When Called:
        Before salary payment is processed
    Parameters:
        client (Player) - The player receiving salary
        char (Character) - The character receiving salary
        pay (number) - The salary amount
        faction (string) - The faction name
        class (string) - The class name
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log salary
    hook.Add("PreSalaryGive", "MyAddon", function(client, char, pay, faction, class)
        print(client:Name() .. " is receiving $" .. pay .. " salary")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify salary amount
    hook.Add("PreSalaryGive", "ModifySalary", function(client, char, pay, faction, class)
        local char = client:getChar()
        if char then
            local level = char:getData("level", 1)
            pay = pay + (level * 10)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex salary calculation
    hook.Add("PreSalaryGive", "AdvancedSalaryCalculation", function(client, char, pay, faction, class)
        local char = client:getChar()
        if not char then return end

            -- Base salary modifications
            local level = char:getData("level", 1)
            pay = pay + (level * 10)

            -- Faction bonuses
            if faction == "police" then
                pay = pay * 1.2
                elseif faction == "medic" then
                    pay = pay * 1.1
                end

                -- Class bonuses
                if class == "officer" then
                    pay = pay + 50
                    elseif class == "doctor" then
                        pay = pay + 75
                    end

                    -- VIP bonus
                    if char:getData("vip", false) then
                        pay = pay * 1.5
                    end

                    -- Log salary calculation
                    lia.db.query("INSERT INTO salary_logs (timestamp, charid, amount, faction, class) VALUES (?, ?, ?, ?, ?)",
                    os.time(), char:getID(), pay, faction, class)
                end)
    ```
]]
function PreSalaryGive(client, char, pay, faction, class)
end

--[[
    Purpose:
        Called before damage scaling is calculated
    When Called:
        Before damage is scaled
    Parameters:
        hitgroup (number) - The hitgroup that was hit
        dmgInfo (CTakeDamageInfo) - The damage info
        damageScale (number) - The current damage scale
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log damage scaling
    hook.Add("PreScaleDamage", "MyAddon", function(hitgroup, dmgInfo, damageScale)
        print("Scaling damage for hitgroup " .. hitgroup)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify damage scale
    hook.Add("PreScaleDamage", "ModifyDamageScale", function(hitgroup, dmgInfo, damageScale)
        if hitgroup == HITGROUP_HEAD then
            damageScale = damageScale * 1.5
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex damage scaling system
    hook.Add("PreScaleDamage", "AdvancedDamageScaling", function(hitgroup, dmgInfo, damageScale)
        local target = dmgInfo:GetAttacker()
        local attacker = dmgInfo:GetAttacker()

        if not IsValid(target) or not IsValid(attacker) then return end

            local targetChar = target:getChar()
            local attackerChar = attacker:getChar()

            if not targetChar or not attackerChar then return end

                -- Faction damage modifiers
                local targetFaction = targetChar:getFaction()
                local attackerFaction = attackerChar:getFaction()

                if targetFaction == "police" and attackerFaction == "criminal" then
                    damageScale = damageScale * 1.2
                    elseif targetFaction == "criminal" and attackerFaction == "police" then
                        damageScale = damageScale * 0.8
                    end

                    -- Armor protection
                    local armor = target:getData("armor", 0)
                    if armor > 0 then
                        damageScale = damageScale * (1 - (armor / 200))
                    end
                end)
    ```
]]
function PreScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Called to register prepared SQL statements
    When Called:
        When setting up database prepared statements
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log statement registration
    hook.Add("RegisterPreparedStatements", "MyAddon", function()
        print("Registering prepared statements")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Register custom statements
    hook.Add("RegisterPreparedStatements", "RegisterCustomStatements", function()
        lia.db.prepare("my_query", "SELECT * FROM my_table WHERE id = ?")
        lia.db.prepare("my_insert", "INSERT INTO my_table (data) VALUES (?)")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex statement registration
    hook.Add("RegisterPreparedStatements", "AdvancedStatementRegistration", function()
        -- Register custom queries
        lia.db.prepare("get_player_stats", "SELECT * FROM player_stats WHERE steamid = ?")
        lia.db.prepare("update_player_stats", "UPDATE player_stats SET kills = ?, deaths = ? WHERE steamid = ?")
        lia.db.prepare("insert_player_stats", "INSERT INTO player_stats (steamid, kills, deaths) VALUES (?, ?, ?)")

        -- Register character queries
        lia.db.prepare("get_char_data", "SELECT * FROM char_data WHERE charid = ?")
        lia.db.prepare("update_char_data", "UPDATE char_data SET value = ? WHERE charid = ? AND key = ?")

        -- Register item queries
        lia.db.prepare("get_item_data", "SELECT * FROM item_data WHERE itemid = ?")
        lia.db.prepare("update_item_data", "UPDATE item_data SET value = ? WHERE itemid = ? AND key = ?")

        print("All prepared statements registered")
    end)
    ```
]]
function RegisterPreparedStatements()
end

--[[
    Purpose:
        Called when a warning is removed
    When Called:
        When a character warning is deleted
    Parameters:
        charID (number) - The character ID
        index (number) - The warning index
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log warning removal
    hook.Add("RemoveWarning", "MyAddon", function(charID, index)
        print("Warning " .. index .. " removed for character " .. charID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track warning removals
    hook.Add("RemoveWarning", "TrackWarningRemovals", function(charID, index)
        local char = lia.char.loaded[charID]
        if char then
            local warningRemovals = char:getData("warningRemovals", 0)
            char:setData("warningRemovals", warningRemovals + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex warning removal system
    hook.Add("RemoveWarning", "AdvancedWarningRemoval", function(charID, index)
        local char = lia.char.loaded[charID]
        if not char then return end

            -- Track warning removals
            local warningRemovals = char:getData("warningRemovals", 0)
            char:setData("warningRemovals", warningRemovals + 1)

            -- Log to database
            lia.db.query("INSERT INTO warning_logs (timestamp, charid, action, warning_index) VALUES (?, ?, ?, ?)",
            os.time(), charID, "removed", index)

            -- Notify character owner
            local client = char:getPlayer()
            if IsValid(client) then
                client:ChatPrint("Warning " .. index .. " has been removed")
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[ADMIN] Warning " .. index .. " removed for " .. char:getName())
                end
            end
        end)
    ```
]]
function RemoveWarning(charID, index)
end

--[[
    Purpose:
        Called when an admin system command is run
    When Called:
        When an admin command is executed
    Parameters:
        cmd (string) - The command name
        admin (Player) - The admin running the command
        victim (Player) - The target player (if any)
        dur (number) - The duration (if applicable)
        reason (string) - The reason (if applicable)
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log admin commands
    hook.Add("RunAdminSystemCommand", "MyAddon", function(cmd, admin, victim, dur, reason)
        print(admin:Name() .. " ran command: " .. cmd)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track command usage
    hook.Add("RunAdminSystemCommand", "TrackCommandUsage", function(cmd, admin, victim, dur, reason)
        local char = admin:getChar()
        if char then
            local commands = char:getData("commandsUsed", {})
            commands[cmd] = (commands[cmd] or 0) + 1
            char:setData("commandsUsed", commands)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex admin command tracking
    hook.Add("RunAdminSystemCommand", "AdvancedCommandTracking", function(cmd, admin, victim, dur, reason)
        local char = admin:getChar()
        if not char then return end

            -- Track command usage
            local commands = char:getData("commandsUsed", {})
            commands[cmd] = (commands[cmd] or 0) + 1
            char:setData("commandsUsed", commands)

            -- Log to database
            lia.db.query("INSERT INTO admin_logs (timestamp, admin_steamid, command, target_steamid, duration, reason) VALUES (?, ?, ?, ?, ?, ?)",
            os.time(), admin:SteamID(), cmd, victim and victim:SteamID() or "", dur or 0, reason or "")

            -- Notify other admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() and ply ~= admin then
                    local message = admin:Name() .. " used " .. cmd
                    if IsValid(victim) then
                        message = message .. " on " .. victim:Name()
                    end
                    ply:ChatPrint("[ADMIN] " .. message)
                end
            end
        end)
    ```
]]
function RunAdminSystemCommand(cmd, admin, victim, dur, reason)
end

--[[
    Purpose:
        Called to save persistent data
    When Called:
        When data needs to be saved to storage
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data save
    hook.Add("SaveData", "MyAddon", function()
        print("Saving data")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save custom data
    hook.Add("SaveData", "SaveCustomData", function()
        lia.data.set("myAddonData", MyAddon.data)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data saving system
    hook.Add("SaveData", "AdvancedDataSaving", function()
        -- Save custom data
        lia.data.set("myAddonData", MyAddon.data)

        -- Save player statistics
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:getChar()
            if char then
                local stats = char:getData("myAddonStats", {})
                lia.data.set("playerStats_" .. ply:SteamID(), stats)
            end
        end

        -- Save to database
        lia.db.query("INSERT INTO data_saves (timestamp, data) VALUES (?, ?)",
        os.time(), util.TableToJSON(MyAddon.data))

        print("All data saved successfully")
    end)
    ```
]]
function SaveData()
end

--[[
    Purpose:
        Called to send a popup message
    When Called:
        When displaying a popup to a player
    Parameters:
        noob (Player) - The player receiving the popup
        message (string) - The popup message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log popup
    hook.Add("SendPopup", "MyAddon", function(noob, message)
        print("Sending popup to " .. noob:Name() .. ": " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize popup message
    hook.Add("SendPopup", "CustomizePopup", function(noob, message)
        local char = noob:getChar()
        if char then
            local customMessage = "[" .. char:getFaction() .. "] " .. message
            noob:ChatPrint(customMessage)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex popup system
    hook.Add("SendPopup", "AdvancedPopupSystem", function(noob, message)
        local char = noob:getChar()
        if not char then return end

            -- Customize message based on faction
            local faction = char:getFaction()
            local factionPrefix = {
            ["police"] = "[POLICE]",
            ["medic"] = "[MEDICAL]",
            ["criminal"] = "[CRIMINAL]"
        }

        local prefix = factionPrefix[faction] or "[SYSTEM]"
        local customMessage = prefix .. " " .. message

        -- Send popup
        noob:ChatPrint(customMessage)

        -- Log popup
        lia.db.query("INSERT INTO popup_logs (timestamp, steamid, message) VALUES (?, ?, ?)",
        os.time(), noob:SteamID(), message)
    end)
    ```
]]
function SendPopup(noob, message)
end

--[[
    Purpose:
        Called to set up bag inventory access rules
    When Called:
        When configuring access rules for a bag inventory
    Parameters:
        inventory (Inventory) - The bag inventory
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log access rules setup
    hook.Add("SetupBagInventoryAccessRules", "MyAddon", function(inventory)
        print("Setting up bag access rules")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set basic access rules
    hook.Add("SetupBagInventoryAccessRules", "BasicAccessRules", function(inventory)
        inventory:setData("accessLevel", "owner")
        inventory:setData("allowTransfer", true)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex access rule system
    hook.Add("SetupBagInventoryAccessRules", "AdvancedAccessRules", function(inventory)
        -- Set access level
        inventory:setData("accessLevel", "owner")
        inventory:setData("allowTransfer", true)
        inventory:setData("allowView", true)

        -- Set faction restrictions
        local owner = inventory:getOwner()
        if IsValid(owner) then
            local char = owner:getChar()
            if char then
                local faction = char:getFaction()
                inventory:setData("allowedFactions", {faction})
                end
            end

            -- Set time restrictions
            inventory:setData("accessTime", os.time())
            inventory:setData("accessDuration", 3600) -- 1 hour
        end)
    ```
]]
function SetupBagInventoryAccessRules(inventory)
end

--[[
    Purpose:
        Called to set up a bot player
    When Called:
        When initializing a bot player
    Parameters:
        client (Player) - The bot player
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log bot setup
    hook.Add("SetupBotPlayer", "MyAddon", function(client)
        print("Setting up bot: " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Configure bot behavior
    hook.Add("SetupBotPlayer", "ConfigureBot", function(client)
        client:SetNetVar("isBot", true)
        client:SetNetVar("botType", "guard")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bot setup system
    hook.Add("SetupBotPlayer", "AdvancedBotSetup", function(client)
        -- Mark as bot
        client:SetNetVar("isBot", true)
        client:SetNetVar("botType", "guard")

        -- Set up bot AI
        client:SetNetVar("botState", "patrol")
        client:SetNetVar("botTarget", nil)

        -- Give bot equipment
        client:Give("weapon_pistol")
        client:SetArmor(100)

        -- Set up bot behavior
        timer.Create("BotAI_" .. client:EntIndex(), 1, 0, function()
        if IsValid(client) then
            hook.Run("BotAIUpdate", client)
        end
    end)
    end)
    ```
]]
function SetupBotPlayer(client)
end

--[[
    Purpose:
        Called to set up the database
    When Called:
        When initializing database connections and tables
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log database setup
    hook.Add("SetupDatabase", "MyAddon", function()
        print("Setting up database")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Create custom tables
    hook.Add("SetupDatabase", "CreateCustomTables", function()
        lia.db.query("CREATE TABLE IF NOT EXISTS my_table (id INTEGER PRIMARY KEY, data TEXT)")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex database setup
    hook.Add("SetupDatabase", "AdvancedDatabaseSetup", function()
        -- Create custom tables
        local tables = {
        "CREATE TABLE IF NOT EXISTS my_table (id INTEGER PRIMARY KEY, data TEXT)",
        "CREATE TABLE IF NOT EXISTS player_stats (steamid TEXT PRIMARY KEY, kills INTEGER, deaths INTEGER)",
        "CREATE TABLE IF NOT EXISTS achievements (id INTEGER PRIMARY KEY, name TEXT, description TEXT)"
    }

    for _, query in ipairs(tables) do
        lia.db.query(query)
    end

    -- Create indexes
    lia.db.query("CREATE INDEX IF NOT EXISTS idx_player_stats_steamid ON player_stats(steamid)")

    -- Set up prepared statements
    lia.db.prepare("get_player_stats", "SELECT * FROM player_stats WHERE steamid = ?")
    lia.db.prepare("update_player_stats", "UPDATE player_stats SET kills = ?, deaths = ? WHERE steamid = ?")
    end)
    ```
]]
function SetupDatabase()
end

--[[
    Purpose:
        Called to set up a player's model
    When Called:
        When configuring a player's character model
    Parameters:
        client (Player) - The player
        character (Character) - The character
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log model setup
    hook.Add("SetupPlayerModel", "MyAddon", function(client, character)
        print("Setting up model for " .. character:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set faction-based model
    hook.Add("SetupPlayerModel", "FactionModel", function(client, character)
        local faction = character:getFaction()
        local factionModels = {
        ["police"] = "models/player/police.mdl",
        ["medic"] = "models/player/medic.mdl"
    }

    local model = factionModels[faction]
    if model then
        client:SetModel(model)
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model setup system
    hook.Add("SetupPlayerModel", "AdvancedModelSetup", function(client, character)
        local faction = character:getFaction()
        local class = character:getData("class")

        -- Get model based on faction and class
        local model = character:getModel()

        -- Apply faction-specific model overrides
        local factionModels = lia.faction.indices[faction] and lia.faction.indices[faction].models
        if factionModels and factionModels[class] then
            model = factionModels[class]
        end

        -- Apply outfit model override
        local outfit = character:getData("outfit")
        if outfit then
            local outfitItem = lia.item.instances[outfit]
            if outfitItem and outfitItem.model then
                model = outfitItem.model
            end
        end

        -- Set model
        client:SetModel(model)

        -- Apply skin and bodygroups
        local skin = character:getData("skin", 0)
        client:SetSkin(skin)

        local bodygroups = character:getData("bodygroups", {})
        for i, group in ipairs(bodygroups) do
            client:SetBodygroup(i, group)
        end
    end)
    ```
]]
function SetupPlayerModel(client, character)
end

--[[
    Purpose:
        Called to check if data should be saved
    When Called:
        When determining if current data should be persisted
    Parameters:
        None
    Returns:
        boolean - True to save, false to skip
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always save data
    hook.Add("ShouldDataBeSaved", "MyAddon", function()
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check save conditions
    hook.Add("ShouldDataBeSaved", "CheckSaveConditions", function()
        local players = player.GetAll()
        return #players > 0
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex save validation
    hook.Add("ShouldDataBeSaved", "AdvancedSaveValidation", function()
        -- Don't save if no players
        local players = player.GetAll()
        if #players == 0 then
            return false
        end

        -- Don't save if server is shutting down
        if game.IsDedicated() and GetConVar("sv_shutdown"):GetBool() then
            return false
        end

        -- Don't save if too frequent
        local lastSave = lia.data.get("lastSave", 0)
        if os.time() - lastSave < 60 then
            return false
        end

        return true
    end)
    ```
]]
function ShouldDataBeSaved()
end

--[[
    Purpose:
        Called to check if saved items should be deleted
    When Called:
        When determining if old saved items should be cleaned up
    Parameters:
        None
    Returns:
        boolean - True to delete, false to keep
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Never delete saved items
    hook.Add("ShouldDeleteSavedItems", "MyAddon", function()
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Delete old items
    hook.Add("ShouldDeleteSavedItems", "DeleteOldItems", function()
        local lastCleanup = lia.data.get("lastItemCleanup", 0)
        return os.time() - lastCleanup > 86400 -- 24 hours
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item cleanup system
    hook.Add("ShouldDeleteSavedItems", "AdvancedItemCleanup", function()
        local lastCleanup = lia.data.get("lastItemCleanup", 0)
        local cleanupInterval = 86400 -- 24 hours

        -- Don't cleanup too frequently
        if os.time() - lastCleanup < cleanupInterval then
            return false
        end

        -- Check server load
        local serverLoad = GetConVar("sv_stats"):GetFloat()
        if serverLoad > 0.8 then
            return false
        end

        -- Check player count
        local players = player.GetAll()
        if #players > 20 then
            return false
        end

        return true
    end)
    ```
]]
function ShouldDeleteSavedItems()
end

--[[
    Purpose:
        Called to check if an item can be transferred to storage
    When Called:
        When attempting to transfer an item to storage
    Parameters:
        client (Player) - The player transferring the item
        storage (Entity) - The storage entity
        item (Item) - The item being transferred
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all transfers
    hook.Add("StorageCanTransferItem", "MyAddon", function(client, storage, item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check item restrictions
    hook.Add("StorageCanTransferItem", "ItemRestrictions", function(client, storage, item)
        local restrictedItems = {"weapon_crowbar", "weapon_stunstick"}
        return not table.HasValue(restrictedItems, item.uniqueID)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage transfer system
    hook.Add("StorageCanTransferItem", "AdvancedStorageTransfer", function(client, storage, item)
        if not IsValid(client) or not IsValid(storage) or not item then
            return false
        end

        local char = client:getChar()
        if not char then return false end

            -- Check storage capacity
            local storageInv = storage:getInv()
            if not storageInv then return false end

                local maxWeight = storageInv:getMaxWeight()
                local currentWeight = storageInv:getWeight()
                local itemWeight = item:getWeight()

                if currentWeight + itemWeight > maxWeight then
                    client:ChatPrint("Storage is full")
                    return false
                end

                -- Check item restrictions
                local restrictedItems = {
                ["weapon_crowbar"] = "Weapons not allowed in storage",
                ["weapon_stunstick"] = "Weapons not allowed in storage"
            }

            if restrictedItems[item.uniqueID] then
                client:ChatPrint(restrictedItems[item.uniqueID])
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            local storageFaction = storage:getNetVar("faction")
            if storageFaction and storageFaction ~= faction then
                client:ChatPrint("You cannot access this storage")
                return false
            end

            -- Check distance
            local distance = client:GetPos():Distance(storage:GetPos())
            if distance > 200 then
                client:ChatPrint("You are too far away from the storage")
                return false
            end

            -- Check if storage is locked
            if storage:getNetVar("locked", false) then
                client:ChatPrint("Storage is locked")
                return false
            end

            return true
        end)
    ```
]]
function StorageCanTransferItem(client, storage, item)
end

--[[
    Purpose:
        Called when a storage entity is removed
    When Called:
        When a storage entity is deleted or removed
    Parameters:
        self (Entity) - The storage entity being removed
        inventory (Inventory) - The inventory associated with the storage
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage removal
    hook.Add("StorageEntityRemoved", "MyAddon", function(self, inventory)
        print("Storage entity removed: " .. tostring(self))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up storage data
    hook.Add("StorageEntityRemoved", "CleanupStorage", function(self, inventory)
        if inventory then
            inventory:save()
        end

        -- Remove from storage list
        lia.storage.list[self] = nil
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage cleanup system
    hook.Add("StorageEntityRemoved", "AdvancedStorageCleanup", function(self, inventory)
        if not IsValid(self) then return end

            -- Save inventory data
            if inventory then
                inventory:save()

                -- Log inventory contents
                local items = inventory:getItems()
                local itemCount = 0
                for _, item in pairs(items) do
                    itemCount = itemCount + 1
                end

                print(string.format("Storage %s removed with %d items", self:EntIndex(), itemCount))
            end

            -- Remove from storage list
            lia.storage.list[self] = nil

            -- Notify nearby players
            local pos = self:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(pos) < 500 then
                    ply:ChatPrint("Storage has been removed")
                end
            end

            -- Log to database
            lia.db.query("INSERT INTO storage_logs (timestamp, entityid, action) VALUES (?, ?, ?)",
            os.time(), self:EntIndex(), "removed")

            -- Clean up any associated data
            local storageData = self:getNetVar("storageData", {})
            if storageData.owner then
                local ownerChar = lia.char.loaded[storageData.owner]
                if ownerChar then
                    ownerChar:setData("storageCount", (ownerChar:getData("storageCount", 0) - 1))
                end
            end
        end)
    ```
]]
function StorageEntityRemoved(self, inventory)
end

--[[
    Purpose:
        Called when a storage inventory is set
    When Called:
        When a storage entity gets its inventory assigned
    Parameters:
        entity (Entity) - The storage entity
        inventory (Inventory) - The inventory being set
        isCar (boolean) - Whether this is a car storage
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage inventory set
    hook.Add("StorageInventorySet", "MyAddon", function(entity, inventory, isCar)
        print("Storage inventory set for " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set storage properties
    hook.Add("StorageInventorySet", "SetStorageProperties", function(entity, inventory, isCar)
        if inventory then
            inventory:setMaxWeight(isCar and 1000 or 500)
            inventory:setMaxItems(isCar and 50 or 25)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage inventory system
    hook.Add("StorageInventorySet", "AdvancedStorageInventory", function(entity, inventory, isCar)
        if not IsValid(entity) or not inventory then return end

            -- Set storage properties based on type
            if isCar then
                inventory:setMaxWeight(1000)
                inventory:setMaxItems(50)
                inventory:setData("storageType", "car")
                else
                    inventory:setMaxWeight(500)
                    inventory:setMaxItems(25)
                    inventory:setData("storageType", "storage")
                end

                -- Set storage data
                entity:setNetVar("storageData", {
                    inventory = inventory:getID(),
                    isCar = isCar,
                    maxWeight = inventory:getMaxWeight(),
                    maxItems = inventory:getMaxItems()
                    })

                    -- Add to storage list
                    lia.storage.list[entity] = {
                        inventory = inventory,
                        isCar = isCar,
                        created = os.time()
                    }

                    -- Log to database
                    lia.db.query("INSERT INTO storage_logs (timestamp, entityid, action, isCar) VALUES (?, ?, ?, ?)",
                    os.time(), entity:EntIndex(), "inventory_set", isCar and 1 or 0)

                    -- Notify nearby players
                    local pos = entity:GetPos()
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():Distance(pos) < 300 then
                            ply:ChatPrint("Storage is now available")
                        end
                    end
                end)
    ```
]]
function StorageInventorySet(entity, inventory, isCar)
end

--[[
    Purpose:
        Called when an item is removed from storage
    When Called:
        When an item is removed from a storage inventory
    Parameters:
        None
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item removal
    hook.Add("StorageItemRemoved", "MyAddon", function()
        print("Item removed from storage")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update storage statistics
    hook.Add("StorageItemRemoved", "UpdateStats", function()
        local storageCount = 0
        for _, storage in pairs(lia.storage.list) do
            if storage.inventory then
                storageCount = storageCount + 1
            end
        end

        print("Active storages: " .. storageCount)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage item removal system
    hook.Add("StorageItemRemoved", "AdvancedStorageItemRemoval", function()
        -- Update storage statistics
        local totalItems = 0
        local totalWeight = 0

        for _, storage in pairs(lia.storage.list) do
            if storage.inventory then
                local items = storage.inventory:getItems()
                for _, item in pairs(items) do
                    totalItems = totalItems + 1
                    totalWeight = totalWeight + item:getWeight()
                end
            end
        end

        -- Log statistics
        print(string.format("Storage statistics: %d items, %.2f weight", totalItems, totalWeight))

        -- Update storage data
        for entity, storage in pairs(lia.storage.list) do
            if IsValid(entity) and storage.inventory then
                local items = storage.inventory:getItems()
                local itemCount = 0
                for _, item in pairs(items) do
                    itemCount = itemCount + 1
                end

                entity:setNetVar("itemCount", itemCount)
            end
        end

        -- Notify nearby players
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local char = ply:getChar()
                if char then
                    local pos = ply:GetPos()
                    for entity, storage in pairs(lia.storage.list) do
                        if IsValid(entity) and entity:GetPos():Distance(pos) < 300 then
                            ply:ChatPrint("Storage contents updated")
                        end
                    end
                end
            end
        end
    end)
    ```
]]
function StorageItemRemoved()
end

--[[
    Purpose:
        Called when storage is opened
    When Called:
        When a player opens a storage entity
    Parameters:
        storage (Entity) - The storage entity being opened
        isCar (boolean) - Whether this is a car storage
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage opening
    hook.Add("StorageOpen", "MyAddon", function(storage, isCar)
        print("Storage opened: " .. tostring(storage))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track storage usage
    hook.Add("StorageOpen", "TrackUsage", function(storage, isCar)
        local storageData = storage:getNetVar("storageData", {})
        storageData.openCount = (storageData.openCount or 0) + 1
        storageData.lastOpened = os.time()
        storage:setNetVar("storageData", storageData)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage opening system
    hook.Add("StorageOpen", "AdvancedStorageOpening", function(storage, isCar)
        if not IsValid(storage) then return end

            -- Update storage statistics
            local storageData = storage:getNetVar("storageData", {})
            storageData.openCount = (storageData.openCount or 0) + 1
            storageData.lastOpened = os.time()
            storage:setNetVar("storageData", storageData)

            -- Check storage capacity
            local inventory = storage:getInv()
            if inventory then
                local items = inventory:getItems()
                local itemCount = 0
                for _, item in pairs(items) do
                    itemCount = itemCount + 1
                end

                storage:setNetVar("itemCount", itemCount)
            end

            -- Log to database
            lia.db.query("INSERT INTO storage_logs (timestamp, entityid, action, isCar) VALUES (?, ?, ?, ?)",
            os.time(), storage:EntIndex(), "opened", isCar and 1 or 0)

            -- Notify nearby players
            local pos = storage:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(pos) < 500 then
                    ply:ChatPrint("Storage has been opened")
                end
            end

            -- Check for storage upgrades
            local openCount = storageData.openCount
            if openCount >= 100 and not storageData.upgraded then
                storageData.upgraded = true
                storage:setNetVar("storageData", storageData)

                -- Increase storage capacity
                if inventory then
                    inventory:setMaxWeight(inventory:getMaxWeight() * 1.5)
                    inventory:setMaxItems(inventory:getMaxItems() * 1.5)
                end
            end
        end)
    ```
]]
function StorageOpen(storage, isCar)
end

--[[
    Purpose:
        Called when storage is restored
    When Called:
        When a storage entity is restored from save data
    Parameters:
        ent (Entity) - The storage entity being restored
        inventory (Inventory) - The inventory being restored
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage restoration
    hook.Add("StorageRestored", "MyAddon", function(ent, inventory)
        print("Storage restored: " .. tostring(ent))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate storage data
    hook.Add("StorageRestored", "ValidateStorage", function(ent, inventory)
        if inventory then
            inventory:setMaxWeight(500)
            inventory:setMaxItems(25)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage restoration system
    hook.Add("StorageRestored", "AdvancedStorageRestoration", function(ent, inventory)
        if not IsValid(ent) or not inventory then return end

            -- Validate inventory data
            if inventory:getMaxWeight() <= 0 then
                inventory:setMaxWeight(500)
            end

            if inventory:getMaxItems() <= 0 then
                inventory:setMaxItems(25)
            end

            -- Set storage data
            ent:setNetVar("storageData", {
                inventory = inventory:getID(),
                restored = true,
                restoredAt = os.time()
                })

                -- Add to storage list
                lia.storage.list[ent] = {
                    inventory = inventory,
                    restored = true,
                    restoredAt = os.time()
                }

                -- Log to database
                lia.db.query("INSERT INTO storage_logs (timestamp, entityid, action) VALUES (?, ?, ?)",
                os.time(), ent:EntIndex(), "restored")

                -- Notify nearby players
                local pos = ent:GetPos()
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(pos) < 300 then
                        ply:ChatPrint("Storage has been restored")
                    end
                end

                -- Check for corrupted items
                local items = inventory:getItems()
                local corruptedItems = 0
                for _, item in pairs(items) do
                    if not item.uniqueID or not lia.item.list[item.uniqueID] then
                        corruptedItems = corruptedItems + 1
                    end
                end

                if corruptedItems > 0 then
                    print(string.format("Storage %s restored with %d corrupted items", ent:EntIndex(), corruptedItems))
                end
            end)
    ```
]]
function StorageRestored(ent, inventory)
end

--[[
    Purpose:
        Called to store spawn points
    When Called:
        When spawn points are being stored
    Parameters:
        spawns (table) - The spawn points to store
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log spawn storage
    hook.Add("StoreSpawns", "MyAddon", function(spawns)
        print("Storing " .. #spawns .. " spawn points")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate spawn points
    hook.Add("StoreSpawns", "ValidateSpawns", function(spawns)
        for i, spawn in ipairs(spawns) do
            if not spawn.pos or not spawn.ang then
                print("Invalid spawn point at index " .. i)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex spawn storage system
    hook.Add("StoreSpawns", "AdvancedSpawnStorage", function(spawns)
        if not spawns or #spawns == 0 then
            print("No spawn points to store")
            return
        end

        -- Validate spawn points
        local validSpawns = {}
        for i, spawn in ipairs(spawns) do
            if spawn.pos and spawn.ang then
                -- Check if spawn is valid
                local trace = util.TraceLine({
                start = spawn.pos,
                endpos = spawn.pos + Vector(0, 0, -100),
                mask = MASK_SOLID
                })

                if trace.Hit then
                    table.insert(validSpawns, spawn)
                    else
                        print("Spawn point " .. i .. " is not on solid ground")
                    end
                    else
                        print("Invalid spawn point at index " .. i)
                    end
                end

                -- Store valid spawns
                lia.spawns = validSpawns

                -- Log to database
                lia.db.query("DELETE FROM spawns")
                for _, spawn in ipairs(validSpawns) do
                    lia.db.query("INSERT INTO spawns (pos_x, pos_y, pos_z, ang_p, ang_y, ang_r) VALUES (?, ?, ?, ?, ?, ?)",
                    spawn.pos.x, spawn.pos.y, spawn.pos.z,
                    spawn.ang.p, spawn.ang.y, spawn.ang.r)
                end

                print(string.format("Stored %d valid spawn points", #validSpawns))
            end)
    ```
]]
function StoreSpawns(spawns)
end

--[[
    Purpose:
        Called to sync character list with client
    When Called:
        When character list needs to be synchronized
    Parameters:
        client (Player) - The client to sync with
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character list sync
    hook.Add("SyncCharList", "MyAddon", function(client)
        print("Syncing character list with " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate character data
    hook.Add("SyncCharList", "ValidateChars", function(client)
        local charList = client:getCharList()
        for _, char in ipairs(charList) do
            if not char.name or not char.faction then
                print("Invalid character data for " .. client:Name())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character list sync system
    hook.Add("SyncCharList", "AdvancedCharSync", function(client)
        if not IsValid(client) then return end

            local charList = client:getCharList()
            if not charList then
                print("No character list for " .. client:Name())
                return
            end

            -- Validate character data
            local validChars = {}
            for _, char in ipairs(charList) do
                if char.name and char.faction then
                    -- Check if character is valid
                    local faction = lia.faction.list[char.faction]
                    if faction then
                        table.insert(validChars, char)
                        else
                            print("Invalid faction for character " .. char.name)
                        end
                        else
                            print("Invalid character data for " .. client:Name())
                        end
                    end

                    -- Update client character list
                    client:setCharList(validChars)

                    -- Log to database
                    lia.db.query("UPDATE players SET char_list = ? WHERE steamid = ?",
                    util.TableToJSON(validChars), client:SteamID())

                    -- Notify client
                    net.Start("liaCharListUpdated")
                    net.WriteTable(validChars)
                    net.Send(client)

                    print(string.format("Synced %d characters for %s", #validChars, client:Name()))
                end)
    ```
]]
function SyncCharList(client)
end

--[[
    Purpose:
        Called when a ticket is claimed
    When Called:
        When a support ticket is claimed by an admin
    Parameters:
        client (Player) - The admin claiming the ticket
        requester (Player) - The player who requested the ticket
        ticketMessage (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket claim
    hook.Add("TicketSystemClaim", "MyAddon", function(client, requester, ticketMessage)
        print(client:Name() .. " claimed ticket from " .. requester:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify players
    hook.Add("TicketSystemClaim", "NotifyClaim", function(client, requester, ticketMessage)
        requester:ChatPrint("Your ticket has been claimed by " .. client:Name())

        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. client:Name() .. " claimed ticket from " .. requester:Name())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket claim system
    hook.Add("TicketSystemClaim", "AdvancedTicketClaim", function(client, requester, ticketMessage)
        if not IsValid(client) or not IsValid(requester) then return end

            -- Check if client is admin
            if not client:IsAdmin() then
                client:ChatPrint("You do not have permission to claim tickets")
                return
            end

            -- Update ticket status
            local ticketData = {
            claimed = true,
            claimedBy = client:SteamID(),
            claimedAt = os.time(),
            message = ticketMessage
        }

        requester:setData("ticketData", ticketData)

        -- Notify requester
        requester:ChatPrint("Your ticket has been claimed by " .. client:Name())

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. client:Name() .. " claimed ticket from " .. requester:Name())
            end
        end

        -- Log to database
        lia.db.query("INSERT INTO ticket_logs (timestamp, requester_steamid, claimer_steamid, message) VALUES (?, ?, ?, ?)",
        os.time(), requester:SteamID(), client:SteamID(), ticketMessage)

        -- Update client data
        local clientData = client:getData("ticketStats", {})
        clientData.claimed = (clientData.claimed or 0) + 1
        client:setData("ticketStats", clientData)
    end)
    ```
]]
function TicketSystemClaim(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a ticket is closed
    When Called:
        When a support ticket is closed
    Parameters:
        client (Player) - The admin closing the ticket
        requester (Player) - The player who requested the ticket
        ticketMessage (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket close
    hook.Add("TicketSystemClose", "MyAddon", function(client, requester, ticketMessage)
        print(client:Name() .. " closed ticket from " .. requester:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify players
    hook.Add("TicketSystemClose", "NotifyClose", function(client, requester, ticketMessage)
        requester:ChatPrint("Your ticket has been closed by " .. client:Name())

        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. client:Name() .. " closed ticket from " .. requester:Name())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket close system
    hook.Add("TicketSystemClose", "AdvancedTicketClose", function(client, requester, ticketMessage)
        if not IsValid(client) or not IsValid(requester) then return end

            -- Check if client is admin
            if not client:IsAdmin() then
                client:ChatPrint("You do not have permission to close tickets")
                return
            end

            -- Update ticket status
            local ticketData = requester:getData("ticketData", {})
            ticketData.closed = true
            ticketData.closedBy = client:SteamID()
            ticketData.closedAt = os.time()
            ticketData.closeMessage = ticketMessage

            requester:setData("ticketData", ticketData)

            -- Notify requester
            requester:ChatPrint("Your ticket has been closed by " .. client:Name())
            if ticketMessage and ticketMessage ~= "" then
                requester:ChatPrint("Reason: " .. ticketMessage)
            end

            -- Notify admins
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:ChatPrint("[ADMIN] " .. client:Name() .. " closed ticket from " .. requester:Name())
                end
            end

            -- Log to database
            lia.db.query("INSERT INTO ticket_logs (timestamp, requester_steamid, closer_steamid, message, action) VALUES (?, ?, ?, ?, ?)",
            os.time(), requester:SteamID(), client:SteamID(), ticketMessage, "closed")

            -- Update client data
            local clientData = client:getData("ticketStats", {})
            clientData.closed = (clientData.closed or 0) + 1
            client:setData("ticketStats", clientData)

            -- Clear ticket data after delay
            timer.Simple(60, function()
            if IsValid(requester) then
                requester:setData("ticketData", nil)
            end
        end)
    end)
    ```
]]
function TicketSystemClose(client, requester, ticketMessage)
end

--[[
    Purpose:
        Called when a ticket is created
    When Called:
        When a player creates a support ticket
    Parameters:
        noob (Player) - The player creating the ticket
        message (string) - The ticket message
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ticket creation
    hook.Add("TicketSystemCreated", "MyAddon", function(noob, message)
        print(noob:Name() .. " created a ticket: " .. message)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins
    hook.Add("TicketSystemCreated", "NotifyAdmins", function(noob, message)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[TICKET] " .. noob:Name() .. ": " .. message)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket creation system
    hook.Add("TicketSystemCreated", "AdvancedTicketCreation", function(noob, message)
        if not IsValid(noob) then return end

            -- Check if player already has an open ticket
            local ticketData = noob:getData("ticketData", {})
            if ticketData.open and not ticketData.closed then
                noob:ChatPrint("You already have an open ticket. Please wait for it to be resolved.")
                return
            end

            -- Validate message
            if not message or #message < 10 then
                noob:ChatPrint("Please provide a more detailed description of your issue.")
                return
            end

            -- Create ticket data
            local newTicketData = {
            open = true,
            closed = false,
            message = message,
            createdAt = os.time(),
            requester = noob:SteamID()
        }

        noob:setData("ticketData", newTicketData)

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[TICKET] " .. noob:Name() .. " created a new ticket")
                ply:ChatPrint("[TICKET] Message: " .. message)
            end
        end

        -- Log to database
        lia.db.query("INSERT INTO ticket_logs (timestamp, requester_steamid, message, action) VALUES (?, ?, ?, ?)",
        os.time(), noob:SteamID(), message, "created")

        -- Update player data
        local playerData = noob:getData("ticketStats", {})
        playerData.created = (playerData.created or 0) + 1
        noob:setData("ticketStats", playerData)

        -- Notify player
        noob:ChatPrint("Your ticket has been created. An admin will respond soon.")
    end)
    ```
]]
function TicketSystemCreated(noob, message)
end

--[[
    Purpose:
        Called when a door lock is toggled
    When Called:
        When a door is locked or unlocked
    Parameters:
        client (Player) - The player toggling the lock
        door (Entity) - The door entity
        state (boolean) - The new lock state
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door lock toggle
    hook.Add("ToggleLock", "MyAddon", function(client, door, state)
        print(client:Name() .. " " .. (state and "locked" or "unlocked") .. " door")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify nearby players
    hook.Add("ToggleLock", "NotifyToggle", function(client, door, state)
        local pos = door:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(pos) < 500 then
                ply:ChatPrint("A door has been " .. (state and "locked" or "unlocked"))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door lock system
    hook.Add("ToggleLock", "AdvancedDoorLock", function(client, door, state)
        if not IsValid(client) or not IsValid(door) then return end

            local char = client:getChar()
            if not char then return end

                -- Check permissions
                if not client:IsAdmin() then
                    local doorOwner = door:getNetVar("owner")
                    if doorOwner and doorOwner ~= char:getID() then
                        client:ChatPrint("You do not have permission to lock this door")
                        return
                    end
                end

                -- Update door data
                door:setNetVar("locked", state)
                door:setNetVar("lastLocked", os.time())
                door:setNetVar("lastLockedBy", client:SteamID())

                -- Log to database
                lia.db.query("INSERT INTO door_logs (timestamp, steamid, doorid, action) VALUES (?, ?, ?, ?)",
                os.time(), client:SteamID(), door:EntIndex(), state and "locked" or "unlocked")

                -- Notify nearby players
                local pos = door:GetPos()
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(pos) < 500 and ply ~= client then
                        ply:ChatPrint("A door has been " .. (state and "locked" or "unlocked"))
                    end
                end

                -- Update character stats
                local locks = char:getData("doorsLocked", 0)
                char:setData("doorsLocked", locks + 1)

                -- Check for door upgrades
                local lockCount = char:getData("doorsLocked", 0)
                if lockCount >= 10 and not char:getData("doorMaster", false) then
                    char:setData("doorMaster", true)
                    client:ChatPrint("You have mastered door locking!")
                end
            end)
    ```
]]
function ToggleLock(client, door, state)
end

--[[
    Purpose:
        Called to transfer an item
    When Called:
        When an item is being transferred
    Parameters:
        itemID (string) - The ID of the item being transferred
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item transfer
    hook.Add("TransferItem", "MyAddon", function(itemID)
        print("Item transferred: " .. itemID)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track item transfers
    hook.Add("TransferItem", "TrackTransfers", function(itemID)
        local item = lia.item.instances[itemID]
        if item then
            local transferCount = item:getData("transferCount", 0)
            item:setData("transferCount", transferCount + 1)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item transfer system
    hook.Add("TransferItem", "AdvancedItemTransfer", function(itemID)
        if not itemID then return end

            local item = lia.item.instances[itemID]
            if not item then return end

                -- Get item data
                local itemData = item:getData()
                local fromInventory = item:getInventory()
                local toInventory = item:getData("targetInventory")

                if not fromInventory or not toInventory then return end

                    -- Check transfer permissions
                    local fromOwner = fromInventory:getOwner()
                    local toOwner = toInventory:getOwner()

                    if fromOwner and toOwner and fromOwner ~= toOwner then
                        -- Check if transfer is allowed between different owners
                        local transferAllowed = item:getData("transferable", true)
                        if not transferAllowed then
                            print("Item " .. itemID .. " is not transferable")
                            return
                        end
                    end

                    -- Update item data
                    local transferCount = item:getData("transferCount", 0)
                    item:setData("transferCount", transferCount + 1)
                    item:setData("lastTransfer", os.time())

                    -- Log to database
                    lia.db.query("INSERT INTO item_transfer_logs (timestamp, itemid, from_inventory, to_inventory) VALUES (?, ?, ?, ?)",
                    os.time(), itemID, fromInventory:getID(), toInventory:getID())

                    -- Notify players
                    local fromChar = lia.char.loaded[fromOwner]
                    local toChar = lia.char.loaded[toOwner]

                    if fromChar and fromChar:getPlayer() then
                        fromChar:getPlayer():ChatPrint("Item transferred: " .. item:getName())
                    end

                    if toChar and toChar:getPlayer() and toChar:getPlayer() ~= fromChar:getPlayer() then
                        toChar:getPlayer():ChatPrint("Item received: " .. item:getName())
                    end

                    -- Check for item degradation
                    local durability = item:getData("durability", 100)
                    if durability > 0 then
                        local newDurability = math.max(0, durability - 1)
                        item:setData("durability", newDurability)

                        if newDurability <= 0 then
                            item:setData("broken", true)
                        end
                    end
                end)
    ```
]]
function TransferItem(itemID)
end

--[[
    Purpose:
        Called to update entity persistence
    When Called:
        When an entity's persistence data needs to be updated
    Parameters:
        ent (Entity) - The entity to update
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log entity persistence update
    hook.Add("UpdateEntityPersistence", "MyAddon", function(ent)
        print("Updating persistence for " .. tostring(ent))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update entity data
    hook.Add("UpdateEntityPersistence", "UpdateData", function(ent)
        if IsValid(ent) then
            ent:setData("lastUpdate", os.time())
            ent:setData("persistent", true)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity persistence system
    hook.Add("UpdateEntityPersistence", "AdvancedPersistence", function(ent)
        if not IsValid(ent) then return end

            -- Check if entity should be persistent
            local shouldPersist = hook.Run("CanPersistEntity", ent)
            if not shouldPersist then
                ent:setData("persistent", false)
                return
            end

            -- Update entity data
            local entityData = {
            class = ent:GetClass(),
            model = ent:GetModel(),
            pos = ent:GetPos(),
            ang = ent:GetAngles(),
            lastUpdate = os.time(),
            persistent = true
        }

        -- Save custom data
        local customData = ent:getData("customData", {})
        if customData and next(customData) then
            entityData.customData = customData
        end

        -- Save to database
        local entityID = ent:EntIndex()
        lia.db.query("INSERT OR REPLACE INTO persistent_entities (entityid, data, lastupdate) VALUES (?, ?, ?)",
        entityID, util.TableToJSON(entityData), os.time())

        -- Update entity
        ent:setData("persistent", true)
        ent:setData("lastUpdate", os.time())

        -- Notify nearby players
        local pos = ent:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(pos) < 500 then
                ply:ChatPrint("Entity persistence updated")
            end
        end

        -- Log to file
        lia.log.write("entity_persistence", {
            entityID = entityID,
            class = ent:GetClass(),
            timestamp = os.time()
            })
        end)
    ```
]]
function UpdateEntityPersistence(ent)
end

--[[
    Purpose:
        Called when a vendor class is updated
    When Called:
        When a vendor's allowed classes are modified
    Parameters:
        vendor (Entity) - The vendor entity
        id (string) - The class ID being updated
        allowed (boolean) - Whether the class is allowed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor class update
    hook.Add("VendorClassUpdated", "MyAddon", function(vendor, id, allowed)
        print("Vendor class " .. id .. " " .. (allowed and "allowed" or "denied"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify players
    hook.Add("VendorClassUpdated", "NotifyPlayers", function(vendor, id, allowed)
        local pos = vendor:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(pos) < 500 then
                ply:ChatPrint("Vendor class " .. id .. " " .. (allowed and "allowed" or "denied"))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor class system
    hook.Add("VendorClassUpdated", "AdvancedVendorClass", function(vendor, id, allowed)
        if not IsValid(vendor) then return end

            -- Update vendor data
            local vendorData = vendor:getNetVar("vendorData", {})
            vendorData.allowedClasses = vendorData.allowedClasses or {}
                vendorData.allowedClasses[id] = allowed
                vendor:setNetVar("vendorData", vendorData)

                -- Update vendor inventory
                local inventory = vendor:getInv()
                if inventory then
                    local items = inventory:getItems()
                    for _, item in pairs(items) do
                        if item.uniqueID == id then
                            item:setData("allowed", allowed)
                        end
                    end
                end

                -- Log to database
                lia.db.query("INSERT INTO vendor_class_logs (timestamp, vendorid, classid, allowed) VALUES (?, ?, ?, ?)",
                os.time(), vendor:EntIndex(), id, allowed and 1 or 0)

                -- Notify nearby players
                local pos = vendor:GetPos()
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(pos) < 500 then
                        local char = ply:getChar()
                        if char and char:getFaction() == id then
                            ply:ChatPrint("Vendor access " .. (allowed and "granted" or "revoked") .. " for your class")
                        end
                    end
                end

                -- Update vendor UI if open
                if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                    lia.gui.vendor:Populate()
                end
            end)
    ```
]]
function VendorClassUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        Called when a vendor is edited
    When Called:
        When a vendor's properties are modified
    Parameters:
        liaVendorEnt (Entity) - The vendor entity being edited
        key (string) - The property key being edited
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor edit
    hook.Add("VendorEdited", "MyAddon", function(liaVendorEnt, key)
        print("Vendor edited: " .. key)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate vendor edits
    hook.Add("VendorEdited", "ValidateEdits", function(liaVendorEnt, key)
        if key == "name" and liaVendorEnt:getNetVar("name") == "" then
            liaVendorEnt:setNetVar("name", "Unnamed Vendor")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor editing system
    hook.Add("VendorEdited", "AdvancedVendorEdit", function(liaVendorEnt, key)
        if not IsValid(liaVendorEnt) then return end

            -- Update vendor data
            local vendorData = liaVendorEnt:getNetVar("vendorData", {})
            vendorData.lastEdit = os.time()
            vendorData.editedBy = key
            liaVendorEnt:setNetVar("vendorData", vendorData)

            -- Validate specific properties
            if key == "name" then
                local name = liaVendorEnt:getNetVar("name", "")
                if name == "" then
                    liaVendorEnt:setNetVar("name", "Unnamed Vendor")
                    elseif #name > 50 then
                        liaVendorEnt:setNetVar("name", string.sub(name, 1, 50))
                    end
                    elseif key == "money" then
                        local money = liaVendorEnt:getNetVar("money", 0)
                        if money < 0 then
                            liaVendorEnt:setNetVar("money", 0)
                            elseif money > 1000000 then
                                liaVendorEnt:setNetVar("money", 1000000)
                            end
                        end

                        -- Log to database
                        lia.db.query("INSERT INTO vendor_edit_logs (timestamp, vendorid, property, value) VALUES (?, ?, ?, ?)",
                        os.time(), liaVendorEnt:EntIndex(), key, tostring(liaVendorEnt:getNetVar(key, "")))

                        -- Notify nearby players
                        local pos = liaVendorEnt:GetPos()
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(pos) < 500 then
                                ply:ChatPrint("Vendor " .. key .. " has been updated")
                            end
                        end

                        -- Update vendor UI if open
                        if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == liaVendorEnt then
                            lia.gui.vendor:Populate()
                        end
                    end)
    ```
]]
function VendorEdited(liaVendorEnt, key)
end

--[[
    Purpose:
        Called when a vendor faction is updated
    When Called:
        When a vendor's allowed factions are modified
    Parameters:
        vendor (Entity) - The vendor entity
        id (string) - The faction ID being updated
        allowed (boolean) - Whether the faction is allowed
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor faction update
    hook.Add("VendorFactionUpdated", "MyAddon", function(vendor, id, allowed)
        print("Vendor faction " .. id .. " " .. (allowed and "allowed" or "denied"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify players
    hook.Add("VendorFactionUpdated", "NotifyPlayers", function(vendor, id, allowed)
        local pos = vendor:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(pos) < 500 then
                local char = ply:getChar()
                if char and char:getFaction() == id then
                    ply:ChatPrint("Vendor access " .. (allowed and "granted" or "revoked") .. " for your faction")
                end
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor faction system
    hook.Add("VendorFactionUpdated", "AdvancedVendorFaction", function(vendor, id, allowed)
        if not IsValid(vendor) then return end

            -- Update vendor data
            local vendorData = vendor:getNetVar("vendorData", {})
            vendorData.allowedFactions = vendorData.allowedFactions or {}
                vendorData.allowedFactions[id] = allowed
                vendor:setNetVar("vendorData", vendorData)

                -- Update vendor inventory
                local inventory = vendor:getInv()
                if inventory then
                    local items = inventory:getItems()
                    for _, item in pairs(items) do
                        if item.faction == id then
                            item:setData("allowed", allowed)
                        end
                    end
                end

                -- Log to database
                lia.db.query("INSERT INTO vendor_faction_logs (timestamp, vendorid, factionid, allowed) VALUES (?, ?, ?, ?)",
                os.time(), vendor:EntIndex(), id, allowed and 1 or 0)

                -- Notify affected players
                local pos = vendor:GetPos()
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():Distance(pos) < 500 then
                        local char = ply:getChar()
                        if char and char:getFaction() == id then
                            ply:ChatPrint("Vendor access " .. (allowed and "granted" or "revoked") .. " for your faction")
                        end
                    end
                end

                -- Update vendor UI if open
                if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                    lia.gui.vendor:Populate()
                end

                -- Check for faction-specific items
                local factionItems = lia.item.getByFaction(id)
                for _, item in ipairs(factionItems) do
                    if allowed then
                        vendor:addItem(item.uniqueID, 1)
                        else
                            vendor:removeItem(item.uniqueID, 1)
                        end
                    end
                end)
    ```
]]
function VendorFactionUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        Called when a vendor item max stock is updated
    When Called:
        When a vendor item's maximum stock is modified
    Parameters:
        vendor (Entity) - The vendor entity
        itemType (string) - The item type being updated
        value (number) - The new maximum stock value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log max stock update
    hook.Add("VendorItemMaxStockUpdated", "MyAddon", function(vendor, itemType, value)
        print("Vendor item " .. itemType .. " max stock set to " .. value)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate max stock value
    hook.Add("VendorItemMaxStockUpdated", "ValidateMaxStock", function(vendor, itemType, value)
        if value < 0 then
            value = 0
            elseif value > 1000 then
                value = 1000
            end

            vendor:setNetVar("itemMaxStock_" .. itemType, value)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor max stock system
    hook.Add("VendorItemMaxStockUpdated", "AdvancedVendorMaxStock", function(vendor, itemType, value)
        if not IsValid(vendor) then return end

            -- Validate value
            if value < 0 then
                value = 0
                elseif value > 10000 then
                    value = 10000
                end

                -- Update vendor data
                local vendorData = vendor:getNetVar("vendorData", {})
                vendorData.itemMaxStock = vendorData.itemMaxStock or {}
                    vendorData.itemMaxStock[itemType] = value
                    vendor:setNetVar("vendorData", vendorData)

                    -- Update item in inventory
                    local inventory = vendor:getInv()
                    if inventory then
                        local items = inventory:getItems()
                        for _, item in pairs(items) do
                            if item.uniqueID == itemType then
                                item:setData("maxStock", value)

                                -- Adjust current stock if it exceeds max
                                local currentStock = item:getData("stock", 0)
                                if currentStock > value then
                                    item:setData("stock", value)
                                end
                            end
                        end
                    end

                    -- Log to database
                    lia.db.query("INSERT INTO vendor_item_logs (timestamp, vendorid, itemtype, property, value) VALUES (?, ?, ?, ?, ?)",
                    os.time(), vendor:EntIndex(), itemType, "maxStock", value)

                    -- Notify nearby players
                    local pos = vendor:GetPos()
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():Distance(pos) < 500 then
                            ply:ChatPrint("Vendor item " .. itemType .. " max stock updated to " .. value)
                        end
                    end

                    -- Update vendor UI if open
                    if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                        lia.gui.vendor:Populate()
                    end
                end)
    ```
]]
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when a vendor item mode is updated
    When Called:
        When a vendor item's mode is modified
    Parameters:
        vendor (Entity) - The vendor entity
        itemType (string) - The item type being updated
        value (string) - The new mode value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item mode update
    hook.Add("VendorItemModeUpdated", "MyAddon", function(vendor, itemType, value)
        print("Vendor item " .. itemType .. " mode set to " .. value)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate mode value
    hook.Add("VendorItemModeUpdated", "ValidateMode", function(vendor, itemType, value)
        local validModes = {"buy", "sell", "both"}
        if not table.HasValue(validModes, value) then
            value = "both"
        end

        vendor:setNetVar("itemMode_" .. itemType, value)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor item mode system
    hook.Add("VendorItemModeUpdated", "AdvancedVendorItemMode", function(vendor, itemType, value)
        if not IsValid(vendor) then return end

            -- Validate mode
            local validModes = {"buy", "sell", "both"}
            if not table.HasValue(validModes, value) then
                value = "both"
            end

            -- Update vendor data
            local vendorData = vendor:getNetVar("vendorData", {})
            vendorData.itemModes = vendorData.itemModes or {}
                vendorData.itemModes[itemType] = value
                vendor:setNetVar("vendorData", vendorData)

                -- Update item in inventory
                local inventory = vendor:getInv()
                if inventory then
                    local items = inventory:getItems()
                    for _, item in pairs(items) do
                        if item.uniqueID == itemType then
                            item:setData("mode", value)

                            -- Update item display based on mode
                            if value == "buy" then
                                item:setData("sellable", false)
                                item:setData("buyable", true)
                                elseif value == "sell" then
                                    item:setData("sellable", true)
                                    item:setData("buyable", false)
                                    else
                                        item:setData("sellable", true)
                                        item:setData("buyable", true)
                                    end
                                end
                            end
                        end

                        -- Log to database
                        lia.db.query("INSERT INTO vendor_item_logs (timestamp, vendorid, itemtype, property, value) VALUES (?, ?, ?, ?, ?)",
                        os.time(), vendor:EntIndex(), itemType, "mode", value)

                        -- Notify nearby players
                        local pos = vendor:GetPos()
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(pos) < 500 then
                                ply:ChatPrint("Vendor item " .. itemType .. " mode updated to " .. value)
                            end
                        end

                        -- Update vendor UI if open
                        if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                            lia.gui.vendor:Populate()
                        end
                    end)
    ```
]]
function VendorItemModeUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when a vendor item price is updated
    When Called:
        When a vendor item's price is modified
    Parameters:
        vendor (Entity) - The vendor entity
        itemType (string) - The item type being updated
        value (number) - The new price value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log price update
    hook.Add("VendorItemPriceUpdated", "MyAddon", function(vendor, itemType, value)
        print("Vendor item " .. itemType .. " price set to " .. value)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate price value
    hook.Add("VendorItemPriceUpdated", "ValidatePrice", function(vendor, itemType, value)
        if value < 0 then
            value = 0
            elseif value > 1000000 then
                value = 1000000
            end

            vendor:setNetVar("itemPrice_" .. itemType, value)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor price system
    hook.Add("VendorItemPriceUpdated", "AdvancedVendorPrice", function(vendor, itemType, value)
        if not IsValid(vendor) then return end

            -- Validate price
            if value < 0 then
                value = 0
                elseif value > 10000000 then
                    value = 10000000
                end

                -- Update vendor data
                local vendorData = vendor:getNetVar("vendorData", {})
                vendorData.itemPrices = vendorData.itemPrices or {}
                    vendorData.itemPrices[itemType] = value
                    vendor:setNetVar("vendorData", vendorData)

                    -- Update item in inventory
                    local inventory = vendor:getInv()
                    if inventory then
                        local items = inventory:getItems()
                        for _, item in pairs(items) do
                            if item.uniqueID == itemType then
                                item:setData("price", value)

                                -- Calculate profit margin
                                local basePrice = item:getData("basePrice", value)
                                local profitMargin = ((value - basePrice) / basePrice) * 100
                                item:setData("profitMargin", profitMargin)
                            end
                        end
                    end

                    -- Log to database
                    lia.db.query("INSERT INTO vendor_item_logs (timestamp, vendorid, itemtype, property, value) VALUES (?, ?, ?, ?, ?)",
                    os.time(), vendor:EntIndex(), itemType, "price", value)

                    -- Notify nearby players
                    local pos = vendor:GetPos()
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():Distance(pos) < 500 then
                            ply:ChatPrint("Vendor item " .. itemType .. " price updated to $" .. value)
                        end
                    end

                    -- Update vendor UI if open
                    if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                        lia.gui.vendor:Populate()
                    end

                    -- Check for price alerts
                    local priceAlerts = lia.config.get("priceAlerts", {})
                    for _, alert in ipairs(priceAlerts) do
                        if alert.itemType == itemType and alert.priceThreshold and value >= alert.priceThreshold then
                            for _, ply in ipairs(player.GetAll()) do
                                ply:ChatPrint("Price alert: " .. itemType .. " is now $" .. value)
                            end
                        end
                    end
                end)
    ```
]]
function VendorItemPriceUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when a vendor item stock is updated
    When Called:
        When a vendor item's stock is modified
    Parameters:
        vendor (Entity) - The vendor entity
        itemType (string) - The item type being updated
        value (number) - The new stock value
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log stock update
    hook.Add("VendorItemStockUpdated", "MyAddon", function(vendor, itemType, value)
        print("Vendor item " .. itemType .. " stock set to " .. value)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate stock value
    hook.Add("VendorItemStockUpdated", "ValidateStock", function(vendor, itemType, value)
        if value < 0 then
            value = 0
        end

        vendor:setNetVar("itemStock_" .. itemType, value)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor stock system
    hook.Add("VendorItemStockUpdated", "AdvancedVendorStock", function(vendor, itemType, value)
        if not IsValid(vendor) then return end

            -- Validate stock
            if value < 0 then
                value = 0
            end

            -- Get max stock
            local maxStock = vendor:getNetVar("itemMaxStock_" .. itemType, 100)
            if value > maxStock then
                value = maxStock
            end

            -- Update vendor data
            local vendorData = vendor:getNetVar("vendorData", {})
            vendorData.itemStocks = vendorData.itemStocks or {}
                vendorData.itemStocks[itemType] = value
                vendor:setNetVar("vendorData", vendorData)

                -- Update item in inventory
                local inventory = vendor:getInv()
                if inventory then
                    local items = inventory:getItems()
                    for _, item in pairs(items) do
                        if item.uniqueID == itemType then
                            item:setData("stock", value)

                            -- Check if item is out of stock
                            if value <= 0 then
                                item:setData("outOfStock", true)
                                else
                                    item:setData("outOfStock", false)
                                end
                            end
                        end
                    end

                    -- Log to database
                    lia.db.query("INSERT INTO vendor_item_logs (timestamp, vendorid, itemtype, property, value) VALUES (?, ?, ?, ?, ?)",
                    os.time(), vendor:EntIndex(), itemType, "stock", value)

                    -- Notify nearby players
                    local pos = vendor:GetPos()
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():Distance(pos) < 500 then
                            ply:ChatPrint("Vendor item " .. itemType .. " stock updated to " .. value)
                        end
                    end

                    -- Update vendor UI if open
                    if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                        lia.gui.vendor:Populate()
                    end

                    -- Check for low stock alerts
                    local lowStockThreshold = lia.config.get("lowStockThreshold", 10)
                    if value <= lowStockThreshold then
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:IsAdmin() then
                                ply:ChatPrint("Low stock alert: " .. itemType .. " has " .. value .. " left")
                            end
                        end
                    end
                end)
    ```
]]
function VendorItemStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Called when a vendor is opened by a player
    When Called:
        When a player successfully opens a vendor
    Parameters:
        vendor (Entity) - The vendor entity being opened
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor opening
    hook.Add("VendorOpened", "MyAddon", function(vendor)
        print("Vendor opened: " .. vendor:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track vendor usage
    hook.Add("VendorOpened", "VendorTracking", function(vendor)
        local vendorData = vendor:getNetVar("vendorData", {})
        vendorData.openCount = (vendorData.openCount or 0) + 1
        vendorData.lastOpened = os.time()
        vendor:setNetVar("vendorData", vendorData)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor opening system
    hook.Add("VendorOpened", "AdvancedVendorOpening", function(vendor)
        local char = vendor:getChar()
        if not char then return end

            -- Update vendor statistics
            local vendorData = vendor:getNetVar("vendorData", {})
            vendorData.openCount = (vendorData.openCount or 0) + 1
            vendorData.lastOpened = os.time()
            vendorData.totalRevenue = vendorData.totalRevenue or 0
            vendor:setNetVar("vendorData", vendorData)

            -- Check for vendor upgrades
            local openCount = vendorData.openCount
            if openCount >= 100 and not vendorData.upgraded then
                vendorData.upgraded = true
                vendor:setNetVar("vendorData", vendorData)
                char:getPlayer():ChatPrint("Vendor upgraded! Increased stock capacity.")
            end

            -- Apply faction bonuses
            local faction = char:getFaction()
            local bonuses = {
            ["police"] = {discount = 0.1, bonusStock = 50},
                ["medic"] = {discount = 0.05, bonusStock = 25},
                    ["citizen"] = {discount = 0.0, bonusStock = 0}
                    }

                    local bonus = bonuses[faction] or {discount = 0.0, bonusStock = 0}
                    vendor:setNetVar("factionDiscount", bonus.discount)
                    vendor:setNetVar("bonusStock", bonus.bonusStock)

                    -- Check for time-based events
                    local currentHour = tonumber(os.date("%H"))
                    if currentHour >= 18 and currentHour <= 22 then
                        -- Peak hours bonus
                        vendor:setNetVar("peakHoursBonus", 0.2)
                        else
                            vendor:setNetVar("peakHoursBonus", 0.0)
                        end

                        -- Log vendor opening
                        print(string.format("Vendor %s opened by %s (Faction: %s, Opens: %d)",
                        vendor:EntIndex(), char:getName(), faction, openCount))
                    end)
    ```
]]
function VendorOpened(vendor)
end

--[[
    Purpose:
        Called when a vendor trade event occurs
    When Called:
        When a player trades with a vendor
    Parameters:
        client (Player) - The player trading
        vendor (Entity) - The vendor entity
        itemType (string) - The type of item being traded
        isSellingToVendor (boolean) - Whether the player is selling to the vendor
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor trade
    hook.Add("VendorTradeEvent", "MyAddon", function(client, vendor, itemType, isSellingToVendor)
        print(client:Name() .. " traded " .. itemType)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track trade statistics
    hook.Add("VendorTradeEvent", "TrackTrades", function(client, vendor, itemType, isSellingToVendor)
        local char = client:getChar()
        if not char then return end

            local trades = char:getData("vendorTrades", 0)
            char:setData("vendorTrades", trades + 1)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor trade system
    hook.Add("VendorTradeEvent", "AdvancedVendorTrade", function(client, vendor, itemType, isSellingToVendor)
        local char = client:getChar()
        if not char then return end

            -- Update trade statistics
            local trades = char:getData("vendorTrades", 0)
            char:setData("vendorTrades", trades + 1)

            -- Track trade value
            local tradeValue = char:getData("tradeValue", 0)
            local itemPrice = lia.item.list[itemType] and lia.item.list[itemType].price or 0
            char:setData("tradeValue", tradeValue + itemPrice)

            -- Log to database
            lia.db.query("INSERT INTO trade_logs (timestamp, steamid, vendorid, itemtype, selling) VALUES (?, ?, ?, ?, ?)",
            os.time(), client:SteamID(), vendor:EntIndex(), itemType, isSellingToVendor and 1 or 0)

            -- Update vendor reputation
            local vendorID = vendor:EntIndex()
            local reputation = char:getData("vendorRep_" .. vendorID, 0)
            char:setData("vendorRep_" .. vendorID, reputation + 1)

            -- Notify nearby players
            local pos = vendor:GetPos()
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(pos) < 500 and ply ~= client then
                    ply:ChatPrint(client:Name() .. " traded with the vendor")
                end
            end
        end)
    ```
]]
function VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Called when a warning is issued
    When Called:
        When a player receives a warning
    Parameters:
        client (Player) - The player who issued the warning
        target (Player) - The player who received the warning
        reason (string) - The reason for the warning
        count (number) - The total warning count
        warnerSteamID (string) - The SteamID of the warner
        warnerName (string) - The name of the warner
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log warning
    hook.Add("WarningIssued", "MyAddon", function(client, target, reason, count, warnerSteamID, warnerName)
        print(target:Name() .. " was warned by " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins
    hook.Add("WarningIssued", "NotifyAdmins", function(client, target, reason, count, warnerSteamID, warnerName)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint(target:Name() .. " was warned for: " .. reason)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex warning system
    hook.Add("WarningIssued", "AdvancedWarningSystem", function(client, target, reason, count, warnerSteamID, warnerName)
        -- Log to database
        lia.db.query("INSERT INTO warning_logs (timestamp, warner_steamid, target_steamid, reason, count) VALUES (?, ?, ?, ?, ?)",
        os.time(), warnerSteamID, target:SteamID(), reason, count)

        -- Notify target
        target:ChatPrint("You have been warned by " .. warnerName .. " for: " .. reason)
        target:ChatPrint("Total warnings: " .. count)

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. target:Name() .. " was warned by " .. warnerName .. " for: " .. reason)
            end
        end

        -- Auto-kick if too many warnings
        if count >= 3 then
            target:Kick("Too many warnings (" .. count .. ")")
        end

        -- Update character data
        local char = target:getChar()
        if char then
            char:setData("totalWarnings", count)
            char:setData("lastWarning", os.time())
        end
    end)
    ```
]]
function WarningIssued(client, target, reason, count, warnerSteamID, warnerName)
end

--[[
    Purpose:
        Called when a warning is removed
    When Called:
        When a warning is removed from a player
    Parameters:
        client (Player) - The player who removed the warning
        targetClient (Player) - The player whose warning was removed
        reason (string) - The reason for the warning removal
        count (number) - The remaining warning count
        warnerSteamID (string) - The SteamID of the original warner
        warnerName (string) - The name of the original warner
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log warning removal
    hook.Add("WarningRemoved", "MyAddon", function(client, targetClient, reason, count, warnerSteamID, warnerName)
        print(targetClient:Name() .. "'s warning was removed by " .. client:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Notify admins
    hook.Add("WarningRemoved", "NotifyWarningRemoval", function(client, targetClient, reason, count, warnerSteamID, warnerName)
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint(targetClient:Name() .. "'s warning was removed by " .. client:Name())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex warning removal system
    hook.Add("WarningRemoved", "AdvancedWarningRemoval", function(client, targetClient, reason, count, warnerSteamID, warnerName)
        -- Log to database
        lia.db.query("INSERT INTO warning_removal_logs (timestamp, remover_steamid, target_steamid, reason, remaining_count) VALUES (?, ?, ?, ?, ?)",
        os.time(), client:SteamID(), targetClient:SteamID(), reason, count)

        -- Notify target
        targetClient:ChatPrint("One of your warnings has been removed by " .. client:Name())
        targetClient:ChatPrint("Remaining warnings: " .. count)

        -- Notify admins
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. client:Name() .. " removed a warning from " .. targetClient:Name())
                ply:ChatPrint("[ADMIN] Reason: " .. reason .. " | Remaining: " .. count)
            end
        end

        -- Update character data
        local char = targetClient:getChar()
        if char then
            char:setData("totalWarnings", count)
            char:setData("lastWarningRemoval", os.time())
        end
    end)
    ```
]]
function WarningRemoved(client, targetClient, reason, count, warnerSteamID, warnerName)
end

--[[
    Purpose:
        Called to set persistent data
    When Called:
        When setting global or character-specific data
    Parameters:
        value (any) - The value to set
        global (boolean) - Whether this is global data
        ignoreMap (boolean) - Whether to ignore map-specific data
    Returns:
        None
    Realm:
        Server
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data setting
    hook.Add("setData", "MyAddon", function(value, global, ignoreMap)
        print("Data set: " .. tostring(value))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Validate data before setting
    hook.Add("setData", "ValidateData", function(value, global, ignoreMap)
        if type(value) == "string" and #value > 1000 then
            print("Warning: Data value too long")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data validation system
    hook.Add("setData", "AdvancedDataValidation", function(value, global, ignoreMap)
        -- Validate data type and size
        if type(value) == "string" and #value > 1000 then
            print("Warning: Data value too long, truncating")
            value = string.sub(value, 1, 1000)
        end

        -- Validate global data
        if global and type(value) == "table" then
            -- Check for circular references
            local function hasCircularRef(obj, seen)
                seen = seen or {}
                    if type(obj) ~= "table" then return false end
                        if seen[obj] then return true end
                            seen[obj] = true
                            for k, v in pairs(obj) do
                                if hasCircularRef(v, seen) then return true end
                                end
                                return false
                            end

                            if hasCircularRef(value) then
                                print("Error: Circular reference detected in global data")
                                return false
                            end
                        end

                        -- Log data changes
                        lia.db.query("INSERT INTO data_logs (timestamp, global, value_type) VALUES (?, ?, ?)",
                        os.time(), global and 1 or 0, type(value))

                        return true
                    end)
    ```
]]
function setData(value, global, ignoreMap)
end
