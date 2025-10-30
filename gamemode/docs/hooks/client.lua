--[[
    Client-Side Hooks

    Client-side hook system for the Lilia framework.
    These hooks run on the client and are used for UI, rendering, and client-side logic.
]]
--[[
    Overview:
        Client-side hooks in the Lilia framework handle UI, rendering, input, and other client-specific functionality; they can be used to customize the user experience and can be overridden or extended by addons and modules.
]]
--[[
    Purpose:
        Adds a bar field to a character information section in the F1 menu
    When Called:
        When you want to add a progress bar field to display character statistics
    Parameters:
        sectionName (string) - The name of the section to add the field to
        fieldName (string) - Unique identifier for the field
        labelText (string) - Display text for the field label
        minFunc (function) - Function that returns the minimum value for the bar
        maxFunc (function) - Function that returns the maximum value for the bar
        valueFunc (function) - Function that returns the current value for the bar
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a health bar field
    hook.Run("AddBarField", "character", "health", "Health",
    function() return 0 end,
        function() return 100 end,
            function() return LocalPlayer():Health() end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add a stamina bar field with character data
    hook.Run("AddBarField", "character", "stamina", "Stamina",
    function() return 0 end,
        function() return 100 end,
            function()
                local char = LocalPlayer():getChar()
                return char and char:getAttrib("stm") or 0
            end)
    ```

    High Complexity:

    ```lua
    -- High: Add multiple attribute bars dynamically
    local attributes = {"str", "con", "dex", "int", "wis", "cha"}
    for _, attrId in ipairs(attributes) do
        local attr = lia.attribs.list[attrId]
        if attr then
            hook.Run("AddBarField", "attributes", attrId, attr.name,
            function() return attr.min or 0 end,
                function() return hook.Run("GetAttributeMax", LocalPlayer(), attrId) or attr.max or 100 end,
                    function()
                        local char = LocalPlayer():getChar()
                        return char and char:getAttrib(attrId) or 0
                    end)
                end
            end
    ```
]]
function AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
end

--[[
    Purpose:
        Adds a new section to the character information panel in the F1 menu
    When Called:
        When you want to create a new section for displaying character information
    Parameters:
        sectionName (string) - The name of the section to create
        color (Color) - The color for the section header (optional)
        priority (number) - Display priority, lower numbers appear first (optional)
        location (number) - Location of the section in the panel (optional)
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a basic section
    hook.Run("AddSection", "General Info", Color(255, 255, 255), 1, 1)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add a section with custom styling
    hook.Run("AddSection", "Character Stats", Color(100, 150, 200), 2, 1)
    ```

    High Complexity:

    ```lua
    -- High: Add multiple sections with conditional logic
    local sections = {
    {name = "Basic Info", color = Color(255, 255, 255), priority = 1},
        {name = "Attributes", color = Color(100, 200, 100), priority = 2},
            {name = "Skills", color = Color(200, 100, 100), priority = 3}
            }

            for _, section in ipairs(sections) do
                hook.Run("AddSection", section.name, section.color, section.priority, 1)
            end
    ```
]]
function AddSection(sectionName, color, priority, location)
end

--[[
    Purpose:
        Adds a text field to a character information section in the F1 menu
    When Called:
        When you want to add a text field to display character information
    Parameters:
        sectionName (string) - The name of the section to add the field to
        fieldName (string) - Unique identifier for the field
        labelText (string) - Display text for the field label
        valueFunc (function) - Function that returns the current value to display
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a character name field
    hook.Run("AddTextField", "General Info", "name", "Name",
    function() return LocalPlayer():Name() end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add a faction field with character data
    hook.Run("AddTextField", "General Info", "faction", "Faction",
    function()
        local char = LocalPlayer():getChar()
        return char and char:getFaction() and char:getFaction().name or "Unknown"
    end)
    ```

    High Complexity:

    ```lua
    -- High: Add multiple character info fields dynamically
    local infoFields = {
    {name = "name", label = "Name", func = function() return LocalPlayer():Name() end},
        {name = "desc", label = "Description", func = function()
            local char = LocalPlayer():getChar()
            return char and char:getDesc() or "No description"
            end},
            {name = "money", label = "Money", func = function()
                local char = LocalPlayer():getChar()
                return char and lia.currency.format(char:getMoney()) or "$0"
                end}
            }

            for _, field in ipairs(infoFields) do
                hook.Run("AddTextField", "General Info", field.name, field.label, field.func)
            end
    ```
]]
function AddTextField(sectionName, fieldName, labelText, valueFunc)
end

--[[
    Purpose:
        Adds information to the admin stick HUD display when looking at entities
    When Called:
        When an admin uses the admin stick and looks at an entity
    Parameters:
        client (Player) - The admin player using the admin stick
        target (Entity) - The entity being looked at
        information (table) - Table to add information strings to
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic entity information
    hook.Add("AddToAdminStickHUD", "MyAddon", function(client, target, information)
        if IsValid(target) then
            table.insert(information, "Entity: " .. target:GetClass())
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add vendor-specific information
    hook.Add("AddToAdminStickHUD", "VendorInfo", function(client, target, information)
        if IsValid(target) and target.IsVendor then
            local name = target:getName()
            if name and name ~= "" then
                table.insert(information, "Vendor Name: " .. name)
            end
            local animation = target:getNetVar("animation", "")
            if animation and animation ~= "" then
                table.insert(information, "Animation: " .. animation)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Add comprehensive entity information with validation
    hook.Add("AddToAdminStickHUD", "DetailedInfo", function(client, target, information)
        if not IsValid(target) then return end

            -- Basic entity info
            table.insert(information, "Class: " .. target:GetClass())
            table.insert(information, "Model: " .. target:GetModel())

            -- Position info
            local pos = target:GetPos()
            table.insert(information, string.format("Position: %.1f, %.1f, %.1f", pos.x, pos.y, pos.z))

            -- Custom entity data
            if target.IsVendor then
                local name = target:getName()
                if name and name ~= "" then
                    table.insert(information, "Vendor: " .. name)
                end
                elseif target.IsDoor then
                    local doorData = target:getNetVar("doorData")
                    if doorData then
                        table.insert(information, "Door Title: " .. (doorData.title or "Untitled"))
                        table.insert(information, "Door Price: $" .. (doorData.price or 0))
                    end
                end
            end)
    ```
]]
function AddToAdminStickHUD(client, target, information)
end

--[[
    Purpose:
        Allows modification of PAC3 part data before it's applied to a player
    When Called:
        When PAC3 parts are being attached to a player, allowing customization
    Parameters:
        wearer (Player) - The player who will wear the PAC3 part
        id (string) - The identifier of the PAC3 part
        data (table) - The PAC3 part data to be modified
    Returns:
        table|nil - Modified part data, or nil to use original data
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Modify part color
    hook.Add("AdjustPACPartData", "MyAddon", function(wearer, id, data)
        if id == "my_hat" then
            data.color = Color(255, 0, 0) -- Make hat red
            return data
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify part based on player faction
    hook.Add("AdjustPACPartData", "FactionPAC", function(wearer, id, data)
        local char = wearer:getChar()
        if not char then return end

            if id == "uniform" then
                local faction = char:getFaction()
                if faction == "police" then
                    data.color = Color(0, 0, 255) -- Blue for police
                    elseif faction == "medic" then
                        data.color = Color(255, 255, 255) -- White for medics
                    end
                    return data
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex PAC part modification system
    hook.Add("AdjustPACPartData", "AdvancedPAC", function(wearer, id, data)
        local char = wearer:getChar()
        if not char then return end

            -- Check if this is an item-based part
            local item = lia.item.list[id]
            if item and isfunction(item.pacAdjust) then
                local result = item:pacAdjust(data, wearer)
                if result ~= nil then return result end
                end

                -- Apply faction-specific modifications
                local faction = char:getFaction()
                local modifications = {
                ["police"] = {
                    ["badge"] = {scale = 1.2, color = Color(255, 215, 0)},
                        ["uniform"] = {color = Color(0, 0, 100)}
                            },
                            ["medic"] = {
                                ["uniform"] = {color = Color(255, 255, 255)},
                                    ["cross"] = {scale = 1.5, color = Color(255, 0, 0)}
                                    }
                                }

                                local factionMods = modifications[faction]
                                if factionMods and factionMods[id] then
                                    local mod = factionMods[id]
                                    for key, value in pairs(mod) do
                                        data[key] = value
                                    end
                                end

                                -- Apply character-specific modifications
                                local charData = char:getData()
                                if charData.rank and charData.rank == "officer" then
                                    data.scale = (data.scale or 1) * 1.1 -- Officers get slightly larger parts
                                end

                                return data
                            end)
    ```
]]
function AdjustPACPartData(wearer, id, data)
end

--[[
    Purpose:
        Attaches a PAC3 part to a player
    When Called:
        When a PAC3 part needs to be attached to a player
    Parameters:
        client (Player) - The player to attach the part to
        id (string) - The identifier of the PAC3 part to attach
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Attach a hat to a player
    hook.Run("AttachPart", client, "hat_01")
    ```

    Medium Complexity:

    ```lua
    -- Medium: Attach part with validation
    hook.Add("AttachPart", "MyAddon", function(client, id)
        if id == "special_hat" then
            local char = client:getChar()
            if char and char:getFaction() == "police" then
                -- Only police can wear this hat
                hook.Run("AttachPart", client, id)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex part attachment system
    hook.Add("AttachPart", "AdvancedPAC", function(client, id)
        local char = client:getChar()
        if not char then return end

            -- Check if player has permission for this part
            local partPermissions = {
            ["police_badge"] = {"police", "sheriff"},
                ["medic_cross"] = {"medic", "doctor"},
                    ["crown"] = {"mayor", "king"}
                    }

                    local allowedFactions = partPermissions[id]
                    if allowedFactions then
                        local faction = char:getFaction()
                        if not table.HasValue(allowedFactions, faction) then
                            client:ChatPrint("You don't have permission to wear this item!")
                            return
                        end
                    end

                    -- Check character level requirements
                    local levelRequirements = {
                    ["epic_armor"] = 10,
                    ["legendary_weapon"] = 20
                }

                local requiredLevel = levelRequirements[id]
                if requiredLevel then
                    local charLevel = char:getData("level", 1)
                    if charLevel < requiredLevel then
                        client:ChatPrint("You need to be level " .. requiredLevel .. " to wear this item!")
                        return
                    end
                end

                -- Attach the part
                hook.Run("AttachPart", client, id)

                -- Log the attachment
                print(client:Name() .. " attached PAC part: " .. id)
            end)
    ```
]]
function AttachPart(client, id)
end

--[[
    Purpose:
        Determines if character information should be displayed for a given name
    When Called:
        When displaying character information in UI elements
    Parameters:
        name (string) - The character name to check
    Returns:
        boolean - True if info should be displayed, false otherwise
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Display all character info
    hook.Add("CanDisplayCharInfo", "MyAddon", function(name)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide info for certain characters
    hook.Add("CanDisplayCharInfo", "PrivacyMode", function(name)
        local hiddenNames = {"admin", "moderator", "staff"}
        for _, hidden in ipairs(hiddenNames) do
            if string.find(string.lower(name), string.lower(hidden)) then
                return false
            end
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex privacy system
    hook.Add("CanDisplayCharInfo", "AdvancedPrivacy", function(name)
        local char = LocalPlayer():getChar()
        if not char then return true end

            -- Check if player has privacy mode enabled
            if char:getData("privacyMode", false) then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction == "police" then
                -- Police can see all info
                return true
                elseif faction == "citizen" then
                    -- Citizens can only see other citizens
                    local targetChar = lia.char.getCharacters()[name]
                    if targetChar and targetChar:getFaction() ~= "citizen" then
                        return false
                    end
                end

                return true
            end)
    ```
]]
function CanDisplayCharInfo(name)
end

--[[
    Purpose:
        Determines if a bag item's inventory panel can be opened
    When Called:
        When a player attempts to open a bag's inventory
    Parameters:
        item (Item) - The bag item being opened
    Returns:
        boolean - True if panel can be opened, false otherwise
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all bag panels to open
    hook.Add("CanOpenBagPanel", "MyAddon", function(item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if bag is locked
    hook.Add("CanOpenBagPanel", "LockedBags", function(item)
        if item:getData("locked", false) then
            LocalPlayer():ChatPrint("This bag is locked")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bag access system
    hook.Add("CanOpenBagPanel", "AdvancedBags", function(item)
        local char = LocalPlayer():getChar()
        if not char then return false end

            -- Check if bag requires key
            local requiredKey = item:getData("requiredKey")
            if requiredKey then
                local charInv = char:getInv()
                local hasKey = false
                for _, invItem in pairs(charInv:getItems()) do
                    if invItem.uniqueID == requiredKey then
                        hasKey = true
                        break
                    end
                end
                if not hasKey then
                    LocalPlayer():ChatPrint("You need the correct key to open this bag")
                    return false
                end
            end

            -- Check faction restrictions
            local allowedFactions = item:getData("allowedFactions")
            if allowedFactions then
                local faction = char:getFaction()
                if not table.HasValue(allowedFactions, faction) then
                    LocalPlayer():ChatPrint("Your faction cannot access this bag")
                    return false
                end
            end

            -- Check level requirements
            local requiredLevel = item:getData("requiredLevel", 1)
            local charLevel = char:getData("level", 1)
            if charLevel < requiredLevel then
                LocalPlayer():ChatPrint("You need to be level " .. requiredLevel .. " to open this bag")
                return false
            end

            return true
        end)
    ```
]]
--[[
    Purpose:
        Called to check if a bag panel can be opened
    When Called:
        When attempting to open a bag's inventory panel
    Parameters:
        item (Item) - The bag item being opened
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always allow
    hook.Add("CanOpenBagPanel", "MyAddon", function(item)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if bag is locked
    hook.Add("CanOpenBagPanel", "BagPanelCheck", function(item)
        if item:getData("locked", false) then
            LocalPlayer():ChatPrint("This bag is locked")
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bag access system
    hook.Add("CanOpenBagPanel", "AdvancedBagAccess", function(item)
        local char = LocalPlayer():getChar()
        if not char then return false end

            -- Check if bag is locked
            if item:getData("locked", false) then
                local hasKey = char:getInv():hasItem("bag_key_" .. item:getID())
                if not hasKey then
                    LocalPlayer():ChatPrint("This bag is locked and you don't have the key")
                    return false
                end
            end

            -- Check bag ownership
            local owner = item:getData("owner")
            if owner and owner ~= char:getID() then
                LocalPlayer():ChatPrint("This bag belongs to someone else")
                return false
            end

            return true
        end)
    ```
]]
function CanOpenBagPanel(item)
end

--[[
    Purpose:
        Called to modify character list columns
    When Called:
        When building the character list display
    Parameters:
        columns (table) - The columns to display in the character list
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add custom column
    hook.Add("CharListColumns", "MyAddon", function(columns)
        table.insert(columns, "Custom Column")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify existing columns
    hook.Add("CharListColumns", "ColumnModification", function(columns)
        -- Add custom columns
        table.insert(columns, "Level")
        table.insert(columns, "Faction")

        -- Remove default columns
        for i = #columns, 1, -1 do
            if columns[i] == "Unwanted Column" then
                table.remove(columns, i)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex column system
    hook.Add("CharListColumns", "AdvancedColumns", function(columns)
        -- Clear existing columns
        columns = {}

            -- Add custom columns
            table.insert(columns, "Name")
            table.insert(columns, "Level")
            table.insert(columns, "Faction")
            table.insert(columns, "Money")
            table.insert(columns, "Last Seen")

            -- Add faction-specific columns
            local char = LocalPlayer():getChar()
            if char then
                local faction = char:getFaction()
                if faction == "police" then
                    table.insert(columns, "Warnings")
                    table.insert(columns, "Arrests")
                    elseif faction == "medic" then
                        table.insert(columns, "Heals")
                        table.insert(columns, "Revives")
                    end
                end

                -- Add admin columns
                if LocalPlayer():IsAdmin() then
                    table.insert(columns, "SteamID")
                    table.insert(columns, "IP Address")
                end
            end)
    ```
]]
function CharListColumns(columns)
end

--[[
    Purpose:
        Called to modify character list entries
    When Called:
        When building each character list entry
    Parameters:
        entry (table) - The character data for this entry
        row (Panel) - The row panel being created
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add custom data to entry
    hook.Add("CharListEntry", "MyAddon", function(entry, row)
        entry.customData = "Custom Value"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify entry display
    hook.Add("CharListEntry", "EntryModification", function(entry, row)
        -- Add level data
        entry.level = entry.level or 1

        -- Add faction data
        entry.faction = entry.faction or "citizen"

        -- Add money data
        entry.money = entry.money or 0
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entry system
    hook.Add("CharListEntry", "AdvancedEntry", function(entry, row)
        -- Add level data
        entry.level = entry.level or 1

        -- Add faction data
        entry.faction = entry.faction or "citizen"

        -- Add money data
        entry.money = entry.money or 0

        -- Add last seen data
        entry.lastSeen = entry.lastSeen or "Never"

        -- Add faction-specific data
        if entry.faction == "police" then
            entry.warnings = entry.warnings or 0
            entry.arrests = entry.arrests or 0
            elseif entry.faction == "medic" then
                entry.heals = entry.heals or 0
                entry.revives = entry.revives or 0
            end

            -- Add admin data
            if LocalPlayer():IsAdmin() then
                entry.steamID = entry.steamID or "Unknown"
                entry.ipAddress = entry.ipAddress or "Unknown"
            end

            -- Add custom styling
            if entry.level >= 10 then
                entry.isHighLevel = true
            end

            if entry.money >= 10000 then
                entry.isRich = true
            end
        end)
    ```
]]
function CharListEntry(entry, row)
end

--[[
    Purpose:
        Called to add extra details to character list entries
    When Called:
        When building character list entries with additional information
    Parameters:
        client (Player) - The client viewing the character list
        entry (table) - The character data for this entry
        stored (table) - The stored character data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic extra details
    hook.Add("CharListExtraDetails", "MyAddon", function(client, entry, stored)
        entry.extraInfo = "Additional Information"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add faction-specific details
    hook.Add("CharListExtraDetails", "FactionDetails", function(client, entry, stored)
        local faction = entry.faction or "citizen"

        if faction == "police" then
            entry.extraInfo = "Police Officer"
            elseif faction == "medic" then
                entry.extraInfo = "Medical Staff"
                else
                    entry.extraInfo = "Civilian"
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex extra details system
    hook.Add("CharListExtraDetails", "AdvancedExtraDetails", function(client, entry, stored)
        -- Add basic extra details
        entry.extraInfo = "Additional Information"

        -- Add faction-specific details
        local faction = entry.faction or "citizen"
        if faction == "police" then
            entry.extraInfo = "Police Officer"
            entry.rank = entry.rank or "Officer"
            entry.badge = entry.badge or "0000"
            elseif faction == "medic" then
                entry.extraInfo = "Medical Staff"
                entry.rank = entry.rank or "Nurse"
                entry.license = entry.license or "N/A"
                else
                    entry.extraInfo = "Civilian"
                    entry.occupation = entry.occupation or "Unemployed"
                end

                -- Add level-based details
                local level = entry.level or 1
                if level >= 10 then
                    entry.extraInfo = entry.extraInfo .. " (High Level)"
                end

                -- Add money-based details
                local money = entry.money or 0
                if money >= 10000 then
                    entry.extraInfo = entry.extraInfo .. " (Rich)"
                end

                -- Add admin details
                if client:IsAdmin() then
                    entry.adminInfo = "Admin View"
                    entry.steamID = entry.steamID or "Unknown"
                    entry.ipAddress = entry.ipAddress or "Unknown"
                end
            end)
    ```
]]
function CharListExtraDetails(client, entry, stored)
end

--[[
    Purpose:
        Called when character list is loaded
    When Called:
        When the character list data is successfully loaded
    Parameters:
        newCharList (table) - The loaded character list data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character list loading
    hook.Add("CharListLoaded", "MyAddon", function(newCharList)
        print("Character list loaded with " .. #newCharList .. " characters")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Process character list data
    hook.Add("CharListLoaded", "CharListProcessing", function(newCharList)
        -- Count characters by faction
        local factionCount = {}
        for _, char in ipairs(newCharList) do
            local faction = char.faction or "citizen"
            factionCount[faction] = (factionCount[faction] or 0) + 1
        end

        -- Display faction counts
        for faction, count in pairs(factionCount) do
            print(faction .. ": " .. count .. " characters")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character list processing
    hook.Add("CharListLoaded", "AdvancedCharListProcessing", function(newCharList)
        -- Count characters by faction
        local factionCount = {}
        for _, char in ipairs(newCharList) do
            local faction = char.faction or "citizen"
            factionCount[faction] = (factionCount[faction] or 0) + 1
        end

        -- Display faction counts
        for faction, count in pairs(factionCount) do
            print(faction .. ": " .. count .. " characters")
        end

        -- Process character data
        for _, char in ipairs(newCharList) do
            -- Add level data
            char.level = char.level or 1

            -- Add faction data
            char.faction = char.faction or "citizen"

            -- Add money data
            char.money = char.money or 0

            -- Add last seen data
            char.lastSeen = char.lastSeen or "Never"

            -- Add faction-specific data
            if char.faction == "police" then
                char.warnings = char.warnings or 0
                char.arrests = char.arrests or 0
                elseif char.faction == "medic" then
                    char.heals = char.heals or 0
                    char.revives = char.revives or 0
                end
            end

            -- Sort characters by level
            table.sort(newCharList, function(a, b)
            return (a.level or 1) > (b.level or 1)
        end)

        print("Character list loaded and processed with " .. #newCharList .. " characters")
    end)
    ```
]]
function CharListLoaded(newCharList)
end

--[[
    Purpose:
        Called when character list is updated
    When Called:
        When the character list data is modified
    Parameters:
        oldCharList (table) - The previous character list data
        newCharList (table) - The updated character list data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character list updates
    hook.Add("CharListUpdated", "MyAddon", function(oldCharList, newCharList)
        print("Character list updated from " .. #oldCharList .. " to " .. #newCharList .. " characters")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track character changes
    hook.Add("CharListUpdated", "CharChangeTracking", function(oldCharList, newCharList)
        -- Find new characters
        for _, newChar in ipairs(newCharList) do
            local found = false
            for _, oldChar in ipairs(oldCharList) do
                if oldChar.id == newChar.id then
                    found = true
                    break
                end
            end
            if not found then
                print("New character: " .. newChar.name)
            end
        end

        -- Find removed characters
        for _, oldChar in ipairs(oldCharList) do
            local found = false
            for _, newChar in ipairs(newCharList) do
                if oldChar.id == newChar.id then
                    found = true
                    break
                end
            end
            if not found then
                print("Removed character: " .. oldChar.name)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character list update system
    hook.Add("CharListUpdated", "AdvancedCharListUpdate", function(oldCharList, newCharList)
        -- Create lookup tables for efficient comparison
        local oldChars = {}
        for _, char in ipairs(oldCharList) do
            oldChars[char.id] = char
        end

        local newChars = {}
        for _, char in ipairs(newCharList) do
            newChars[char.id] = char
        end

        -- Find new characters
        for _, newChar in ipairs(newCharList) do
            if not oldChars[newChar.id] then
                print("New character: " .. newChar.name .. " (ID: " .. newChar.id .. ")")
            end
        end

        -- Find removed characters
        for _, oldChar in ipairs(oldCharList) do
            if not newChars[oldChar.id] then
                print("Removed character: " .. oldChar.name .. " (ID: " .. oldChar.id .. ")")
            end
        end

        -- Find modified characters
        for _, newChar in ipairs(newCharList) do
            local oldChar = oldChars[newChar.id]
            if oldChar then
                -- Check for changes
                if oldChar.name ~= newChar.name then
                    print("Character name changed: " .. oldChar.name .. " -> " .. newChar.name)
                end
                if oldChar.faction ~= newChar.faction then
                    print("Character faction changed: " .. oldChar.name .. " " .. oldChar.faction .. " -> " .. newChar.faction)
                end
                if oldChar.level ~= newChar.level then
                    print("Character level changed: " .. newChar.name .. " " .. oldChar.level .. " -> " .. newChar.level)
                end
            end
        end

        -- Update character counts
        local oldCount = #oldCharList
        local newCount = #newCharList
        print("Character list updated: " .. oldCount .. " -> " .. newCount .. " characters")
    end)
    ```
]]
function CharListUpdated(oldCharList, newCharList)
end

--[[
    Purpose:
        Called when the character menu is closed
    When Called:
        When the character selection menu is closed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log menu closing
    hook.Add("CharMenuClosed", "MyAddon", function()
        print("Character menu closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up menu data
    hook.Add("CharMenuClosed", "MenuCleanup", function()
        -- Clear cached character data
        lia.charCache = nil
        print("Character menu closed and cache cleared")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu close handling
    hook.Add("CharMenuClosed", "AdvancedMenuClose", function()
        -- Clear cached character data
        lia.charCache = nil

        -- Reset menu state
        lia.menuState = nil

        -- Log menu close time
        local closeTime = os.time()
        lia.lastMenuClose = closeTime

        print("Character menu closed at " .. os.date("%H:%M:%S", closeTime))
    end)
    ```
]]
function CharMenuClosed()
end

--[[
    Purpose:
        Called when the character menu is opened
    When Called:
        When the character selection menu is opened
    Parameters:
        self (Panel) - The character menu panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log menu opening
    hook.Add("CharMenuOpened", "MyAddon", function(self)
        print("Character menu opened")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load character data
    hook.Add("CharMenuOpened", "MenuDataLoad", function(self)
        -- Load character list
        lia.charList = lia.char.getAll()
        print("Character menu opened with " .. #lia.charList .. " characters")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu open handling
    hook.Add("CharMenuOpened", "AdvancedMenuOpen", function(self)
        -- Load character list
        lia.charList = lia.char.getAll()

        -- Set menu state
        lia.menuState = "open"

        -- Log menu open time
        local openTime = os.time()
        lia.lastMenuOpen = openTime

        -- Apply custom styling
        if self then
            self:SetBackgroundColor(Color(0, 0, 0, 200))
        end

        print("Character menu opened at " .. os.date("%H:%M:%S", openTime))
    end)
    ```
]]
function CharMenuOpened(self)
end

--[[
    Purpose:
        Called to add text to the chat
    When Called:
        When text is being added to the chatbox
    Parameters:
        markup (table) - The markup table containing text formatting
        ... (vararg) - Additional arguments for the text
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log chat text
    hook.Add("ChatAddText", "MyAddon", function(markup, ...)
        print("Chat text added")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify chat text color
    hook.Add("ChatAddText", "ChatColorMod", function(markup, ...)
        -- Change text color based on content
        local args = {...}
        for i, arg in ipairs(args) do
            if isstring(arg) and string.find(arg, "important") then
                markup.color = Color(255, 0, 0)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat text processing
    hook.Add("ChatAddText", "AdvancedChatText", function(markup, ...)
        local args = {...}

        -- Process each argument
        for i, arg in ipairs(args) do
            if isstring(arg) then
                -- Highlight player names
                if string.find(arg, LocalPlayer():Name()) then
                    markup.color = Color(255, 255, 0)
                end

                -- Filter inappropriate content
                local bannedWords = {"spam", "hack"}
                for _, word in ipairs(bannedWords) do
                    if string.find(string.lower(arg), string.lower(word)) then
                        return false -- Block the message
                    end
                end
            end
        end
    end)
    ```
]]
function ChatAddText(markup, ...)
end

--[[
    Purpose:
        Called when the chatbox panel is created
    When Called:
        When the chatbox UI panel is initialized
    Parameters:
        panel (Panel) - The chatbox panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log panel creation
    hook.Add("ChatboxPanelCreated", "MyAddon", function(panel)
        print("Chatbox panel created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize chatbox appearance
    hook.Add("ChatboxPanelCreated", "ChatboxCustomize", function(panel)
        if panel then
            panel:SetBackgroundColor(Color(0, 0, 0, 200))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chatbox customization
    hook.Add("ChatboxPanelCreated", "AdvancedChatbox", function(panel)
        if not panel then return end

            -- Customize appearance
            panel:SetBackgroundColor(Color(0, 0, 0, 200))
            panel:SetSize(500, 300)

            -- Add custom buttons
            local closeBtn = panel:Add("DButton")
            closeBtn:SetText("X")
            closeBtn:SetSize(20, 20)
            closeBtn.DoClick = function()
            panel:SetVisible(false)
        end

        print("Chatbox panel created and customized")
    end)
    ```
]]
function ChatboxPanelCreated(panel)
end

--[[
    Purpose:
        Called when text is added to the chatbox
    When Called:
        When new text is displayed in the chatbox
    Parameters:
        ... (vararg) - Variable arguments containing the text data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log chatbox text
    hook.Add("ChatboxTextAdded", "MyAddon", function(...)
        print("Text added to chatbox")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Process chatbox text
    hook.Add("ChatboxTextAdded", "ChatboxProcess", function(...)
        local args = {...}
        for i, arg in ipairs(args) do
            if isstring(arg) then
                print("Chatbox text: " .. arg)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chatbox text handling
    hook.Add("ChatboxTextAdded", "AdvancedChatboxText", function(...)
        local args = {...}

        -- Process each argument
        for i, arg in ipairs(args) do
            if isstring(arg) then
                -- Highlight player mentions
                if string.find(arg, "@" .. LocalPlayer():Name()) then
                    surface.PlaySound("buttons/button15.wav")
                end

                -- Log important messages
                if string.find(arg, "[ADMIN]") or string.find(arg, "[SYSTEM]") then
                    lia.chatLog = lia.chatLog or {}
                        table.insert(lia.chatLog, {text = arg, time = os.time()})
                        end
                    end
                end
            end)
    ```
]]
function ChatboxTextAdded(...)
end

--[[
    Purpose:
        Called when a character is chosen
    When Called:
        When a player selects a character to play
    Parameters:
        id (number) - The ID of the character being chosen
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character choice
    hook.Add("ChooseCharacter", "MyAddon", function(id)
        print("Chose character ID: " .. id)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Cache character data
    hook.Add("ChooseCharacter", "CharacterCache", function(id)
        lia.selectedCharID = id
        print("Selected character: " .. id)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character selection
    hook.Add("ChooseCharacter", "AdvancedCharSelect", function(id)
        -- Cache character ID
        lia.selectedCharID = id

        -- Log selection time
        lia.charSelectTime = os.time()

        -- Play selection sound
        surface.PlaySound("buttons/button14.wav")

        -- Notify server
        net.Start("CharacterSelected")
        net.WriteUInt(id, 32)
        net.SendToServer()

        print("Selected character ID: " .. id .. " at " .. os.date("%H:%M:%S"))
    end)
    ```
]]
function ChooseCharacter(id)
end

--[[
    Purpose:
        Called when a configuration is updated
    When Called:
        When a config value is synchronized or updated
    Parameters:
        key (string) - The configuration key that was updated
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log config updates
    hook.Add("ConfigUpdated", "MyAddon", function(key)
        print("Config updated: " .. key)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Refresh UI on config update
    hook.Add("ConfigUpdated", "ConfigUIRefresh", function(key)
        if key == "theme" then
            -- Refresh UI theme
            lia.gui.refreshTheme()
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex config update handling
    hook.Add("ConfigUpdated", "AdvancedConfigUpdate", function(key)
        -- Handle specific config updates
        if key == "theme" then
            lia.gui.refreshTheme()
            elseif key == "language" then
                lia.lang.refresh()
                elseif key == "hud" then
                    lia.hud.refresh()
                end

                -- Cache updated config
                lia.configCache = lia.configCache or {}
                    lia.configCache[key] = lia.config.get(key)

                    print("Config " .. key .. " updated and cached")
                end)
    ```
]]
function ConfigUpdated(key)
end

--[[
    Purpose:
        Called to configure character creation steps
    When Called:
        When setting up the character creation process
    Parameters:
        self (Panel) - The character creation panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log creation step configuration
    hook.Add("ConfigureCharacterCreationSteps", "MyAddon", function(self)
        print("Configuring character creation steps")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom creation step
    hook.Add("ConfigureCharacterCreationSteps", "CustomStep", function(self)
        if self then
            self:AddStep("Custom", function(panel)
            -- Custom step UI
            local label = panel:Add("DLabel")
            label:SetText("Custom Step")
        end)
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex creation step configuration
    hook.Add("ConfigureCharacterCreationSteps", "AdvancedCreationSteps", function(self)
        if not self then return end

            -- Add custom background step
            self:AddStep("Background", function(panel)
            local label = panel:Add("DLabel")
            label:SetText("Select Background")
            label:Dock(TOP)

            local combo = panel:Add("DComboBox")
            combo:Dock(TOP)
            combo:AddChoice("Soldier")
            combo:AddChoice("Merchant")
            combo:AddChoice("Scholar")
        end)

        -- Add custom traits step
        self:AddStep("Traits", function(panel)
        local label = panel:Add("DLabel")
        label:SetText("Select Traits")
        label:Dock(TOP)

        for i = 1, 3 do
            local checkbox = panel:Add("DCheckBoxLabel")
            checkbox:SetText("Trait " .. i)
            checkbox:Dock(TOP)
        end
    end)

    print("Character creation steps configured")
    end)
    ```
]]
function ConfigureCharacterCreationSteps(self)
end

--[[
    Purpose:
        Called to create the chat interface
    When Called:
        When the chat UI is being initialized
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log chat creation
    hook.Add("CreateChat", "MyAddon", function()
        print("Chat interface created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize chat appearance
    hook.Add("CreateChat", "ChatCustomize", function()
        if lia.chat then
            lia.chat:SetBackgroundColor(Color(0, 0, 0, 200))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat customization
    hook.Add("CreateChat", "AdvancedChatSetup", function()
        if not lia.chat then return end

            -- Customize appearance
            lia.chat:SetBackgroundColor(Color(0, 0, 0, 200))
            lia.chat:SetSize(500, 300)

            -- Add custom chat tabs
            lia.chat:AddTab("Global", Color(255, 255, 255))
            lia.chat:AddTab("Local", Color(100, 200, 100))
            lia.chat:AddTab("Admin", Color(255, 0, 0))

            print("Chat interface created and customized")
        end)
    ```
]]
function CreateChat()
end

--[[
    Purpose:
        Called to create information buttons in the F1 menu
    When Called:
        When building the information panel buttons
    Parameters:
        pages (table) - The pages table to add buttons to
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a basic information button
    hook.Add("CreateInformationButtons", "MyAddon", function(pages)
        pages["Custom"] = function(panel)
        panel:Add("DLabel"):SetText("Custom Information")
    end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple information pages
    hook.Add("CreateInformationButtons", "InfoPages", function(pages)
        pages["Rules"] = function(panel)
        local label = panel:Add("DLabel")
        label:SetText("Server Rules")
        label:Dock(TOP)
    end

    pages["Commands"] = function(panel)
    local label = panel:Add("DLabel")
    label:SetText("Available Commands")
    label:Dock(TOP)
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex information pages
    hook.Add("CreateInformationButtons", "AdvancedInfoPages", function(pages)
        pages["Rules"] = function(panel)
        local scroll = panel:Add("DScrollPanel")
        scroll:Dock(FILL)

        local rules = {
        "1. No RDM",
        "2. No prop spam",
        "3. Respect staff"
    }

    for i, rule in ipairs(rules) do
        local label = scroll:Add("DLabel")
        label:SetText(rule)
        label:Dock(TOP)
    end
    end

    pages["Commands"] = function(panel)
    local scroll = panel:Add("DScrollPanel")
    scroll:Dock(FILL)

    for cmd, data in pairs(lia.command.list) do
        local label = scroll:Add("DLabel")
        label:SetText("/" .. cmd .. " - " .. (data.description or "No description"))
        label:Dock(TOP)
    end
    end
    end)
    ```
]]
function CreateInformationButtons(pages)
end

--[[
    Purpose:
        Called to create an inventory panel
    When Called:
        When an inventory UI panel needs to be created
    Parameters:
        inventory (Inventory) - The inventory to create a panel for
        parent (Panel) - The parent panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory panel creation
    hook.Add("CreateInventoryPanel", "MyAddon", function(inventory, parent)
        print("Creating inventory panel")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize inventory panel
    hook.Add("CreateInventoryPanel", "InventoryCustomize", function(inventory, parent)
        if parent then
            parent:SetBackgroundColor(Color(50, 50, 50, 200))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory panel customization
    hook.Add("CreateInventoryPanel", "AdvancedInventoryPanel", function(inventory, parent)
        if not parent then return end

            -- Customize appearance
            parent:SetBackgroundColor(Color(50, 50, 50, 200))

            -- Add weight display
            local weightLabel = parent:Add("DLabel")
            weightLabel:SetText("Weight: " .. inventory:getWeight() .. "/" .. inventory:getMaxWeight())
            weightLabel:Dock(BOTTOM)

            -- Add money display
            local char = LocalPlayer():getChar()
            if char then
                local moneyLabel = parent:Add("DLabel")
                moneyLabel:SetText("Money: $" .. char:getMoney())
                moneyLabel:Dock(BOTTOM)
            end

            print("Inventory panel created and customized")
        end)
    ```
]]
function CreateInventoryPanel(inventory, parent)
end

--[[
    Purpose:
        Called to create menu buttons
    When Called:
        When building the main menu button tabs
    Parameters:
        tabs (table) - The tabs table to add buttons to
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a basic menu button
    hook.Add("CreateMenuButtons", "MyAddon", function(tabs)
        tabs["Custom"] = function(panel)
        panel:Add("DLabel"):SetText("Custom Menu")
    end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple menu tabs
    hook.Add("CreateMenuButtons", "MenuTabs", function(tabs)
        tabs["Settings"] = function(panel)
        local label = panel:Add("DLabel")
        label:SetText("Settings")
        label:Dock(TOP)
    end

    tabs["Help"] = function(panel)
    local label = panel:Add("DLabel")
    label:SetText("Help & Support")
    label:Dock(TOP)
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu system
    hook.Add("CreateMenuButtons", "AdvancedMenu", function(tabs)
        tabs["Settings"] = function(panel)
        local scroll = panel:Add("DScrollPanel")
        scroll:Dock(FILL)

        -- Add settings options
        local options = {
        {name = "Volume", type = "slider"},
            {name = "FOV", type = "slider"},
                {name = "HUD Scale", type = "slider"}
                }

                for _, option in ipairs(options) do
                    local container = scroll:Add("DPanel")
                    container:Dock(TOP)
                    container:SetHeight(50)

                    local label = container:Add("DLabel")
                    label:SetText(option.name)
                    label:Dock(LEFT)

                    if option.type == "slider" then
                        local slider = container:Add("DNumSlider")
                        slider:Dock(FILL)
                    end
                end
            end
        end)
    ```
]]
function CreateMenuButtons(tabs)
end

--[[
    Purpose:
        Called when derma skin is changed
    When Called:
        When the UI skin is changed
    Parameters:
        newSkin (string) - The new skin name
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log skin change
    hook.Add("DermaSkinChanged", "MyAddon", function(newSkin)
        print("Skin changed to: " .. newSkin)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save skin preference
    hook.Add("DermaSkinChanged", "SkinPreference", function(newSkin)
        local char = LocalPlayer():getChar()
        if char then
            char:setData("preferredSkin", newSkin)
        end
        print("Skin changed to: " .. newSkin)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex skin management system
    hook.Add("DermaSkinChanged", "AdvancedSkinManagement", function(newSkin)
        local char = LocalPlayer():getChar()
        if char then
            char:setData("preferredSkin", newSkin)
        end

        -- Update UI elements
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(panel) and panel.UpdateSkin then
                panel:UpdateSkin(newSkin)
            end
        end

        -- Save to file
        file.Write("lilia_skin.txt", newSkin)

        print("Skin changed to: " .. newSkin .. " and saved")
    end)
    ```
]]
function DermaSkinChanged(newSkin)
end

--[[
    Purpose:
        Called to draw character information
    When Called:
        When character information needs to be rendered
    Parameters:
        client (Player) - The player whose character info is being drawn
        character (Character) - The character being displayed
        info (table) - The information table to populate
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic character info
    hook.Add("DrawCharInfo", "MyAddon", function(client, character, info)
        info["Name"] = character:getName()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple character details
    hook.Add("DrawCharInfo", "CharDetails", function(client, character, info)
        info["Name"] = character:getName()
        info["Faction"] = character:getFaction()
        info["Money"] = "$" .. character:getMoney()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character information display
    hook.Add("DrawCharInfo", "AdvancedCharInfo", function(client, character, info)
        -- Basic info
        info["Name"] = character:getName()
        info["Faction"] = character:getFaction()
        info["Money"] = "$" .. character:getMoney()

        -- Level and experience
        local level = character:getData("level", 1)
        local exp = character:getData("experience", 0)
        info["Level"] = level .. " (" .. exp .. " XP)"

        -- Attributes
        local attributes = character:getAttribs()
        for attr, value in pairs(attributes) do
            info["Attribute: " .. attr] = value
        end

        -- Play time
        local playTime = character:getData("playTime", 0)
        local hours = math.floor(playTime / 3600)
        local minutes = math.floor((playTime % 3600) / 60)
        info["Play Time"] = hours .. "h " .. minutes .. "m"
    end)
    ```
]]
function DrawCharInfo(client, character, info)
end

--[[
    Purpose:
        Called to draw door information box
    When Called:
        When rendering door information UI
    Parameters:
        entity (Entity) - The door entity
        infoTexts (table) - The information texts to display
        alphaOverride (number) - Alpha override value for transparency
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic door info
    hook.Add("DrawDoorInfoBox", "MyAddon", function(entity, infoTexts, alphaOverride)
        table.insert(infoTexts, "Door: " .. entity:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add door ownership info
    hook.Add("DrawDoorInfoBox", "DoorOwnership", function(entity, infoTexts, alphaOverride)
        local owner = entity:getNetVar("owner")
        if owner then
            table.insert(infoTexts, "Owner: " .. owner)
            else
                table.insert(infoTexts, "Unowned")
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door information display
    hook.Add("DrawDoorInfoBox", "AdvancedDoorInfo", function(entity, infoTexts, alphaOverride)
        -- Door title
        local title = entity:getNetVar("title", "Door")
        table.insert(infoTexts, "Title: " .. title)

        -- Owner info
        local owner = entity:getNetVar("owner")
        if owner then
            table.insert(infoTexts, "Owner: " .. owner)
            else
                table.insert(infoTexts, "Unowned")
            end

            -- Price info
            local price = entity:getNetVar("price", 0)
            if price > 0 then
                table.insert(infoTexts, "Price: $" .. price)
            end

            -- Lock status
            local locked = entity:getNetVar("locked", false)
            table.insert(infoTexts, "Status: " .. (locked and "Locked" or "Unlocked"))

            -- Faction restriction
            local faction = entity:getNetVar("faction")
            if faction then
                table.insert(infoTexts, "Faction: " .. faction)
            end
        end)
    ```
]]
function DrawDoorInfoBox(entity, infoTexts, alphaOverride)
end

--[[
    Purpose:
        Called to draw entity information
    When Called:
        When rendering entity information UI
    Parameters:
        entity (Entity) - The entity to draw information for
        alpha (number) - The alpha/transparency value
        position (Vector) - The position to draw at
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic entity info
    hook.Add("DrawEntityInfo", "MyAddon", function(entity, alpha, position)
        draw.SimpleText(entity:GetClass(), "Default", position.x, position.y, Color(255, 255, 255, alpha))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add entity details
    hook.Add("DrawEntityInfo", "EntityDetails", function(entity, alpha, position)
        local text = entity:GetClass()
        if entity:GetModel() then
            text = text .. "\n" .. entity:GetModel()
        end
        draw.SimpleText(text, "Default", position.x, position.y, Color(255, 255, 255, alpha))
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity information display
    hook.Add("DrawEntityInfo", "AdvancedEntityInfo", function(entity, alpha, position)
        local y = position.y

        -- Entity class
        draw.SimpleText("Class: " .. entity:GetClass(), "Default", position.x, y, Color(255, 255, 255, alpha))
        y = y + 15

        -- Entity model
        if entity:GetModel() then
            draw.SimpleText("Model: " .. entity:GetModel(), "Default", position.x, y, Color(200, 200, 200, alpha))
            y = y + 15
        end

        -- Entity health
        if entity:Health() > 0 then
            draw.SimpleText("Health: " .. entity:Health(), "Default", position.x, y, Color(100, 255, 100, alpha))
            y = y + 15
        end

        -- Custom entity data
        if entity.getName then
            local name = entity:getName()
            if name and name ~= "" then
                draw.SimpleText("Name: " .. name, "Default", position.x, y, Color(255, 255, 100, alpha))
            end
        end
    end)
    ```
]]
function DrawEntityInfo(entity, alpha, position)
end

--[[
    Purpose:
        Called to draw Lilia model view
    When Called:
        When rendering a model view panel
    Parameters:
        self (Panel) - The model view panel
        ent (Entity) - The entity being displayed
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log model view drawing
    hook.Add("DrawLiliaModelView", "MyAddon", function(self, ent)
        print("Drawing model view")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize model view
    hook.Add("DrawLiliaModelView", "ModelViewCustomize", function(self, ent)
        if ent then
            ent:SetAngles(Angle(0, 45, 0))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model view customization
    hook.Add("DrawLiliaModelView", "AdvancedModelView", function(self, ent)
        if not ent then return end

            -- Rotate model
            local ang = ent:GetAngles()
            ang.y = ang.y + FrameTime() * 30
            ent:SetAngles(ang)

            -- Apply lighting
            local lightPos = ent:GetPos() + Vector(0, 0, 50)
            render.SetLightingOrigin(lightPos)

            -- Draw model with custom material
            if ent.customMaterial then
                ent:SetMaterial(ent.customMaterial)
            end
        end)
    ```
]]
function DrawLiliaModelView(self, ent)
end

--[[
    Purpose:
        Called to draw a player's ragdoll
    When Called:
        When rendering a player ragdoll entity
    Parameters:
        entity (Entity) - The ragdoll entity
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log ragdoll drawing
    hook.Add("DrawPlayerRagdoll", "MyAddon", function(entity)
        print("Drawing ragdoll: " .. entity:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize ragdoll appearance
    hook.Add("DrawPlayerRagdoll", "RagdollCustomize", function(entity)
        if entity:GetModel() then
            entity:SetColor(Color(255, 200, 200))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll rendering
    hook.Add("DrawPlayerRagdoll", "AdvancedRagdoll", function(entity)
        if not IsValid(entity) then return end

            -- Apply custom material
            local owner = entity:getNetVar("owner")
            if owner then
                local ply = player.GetBySteamID(owner)
                if IsValid(ply) then
                    local char = ply:getChar()
                    if char then
                        -- Apply faction-based coloring
                        local faction = char:getFaction()
                        local colors = {
                        ["police"] = Color(0, 0, 255),
                        ["medic"] = Color(255, 255, 255),
                        ["citizen"] = Color(200, 200, 200)
                    }

                    local color = colors[faction] or Color(255, 255, 255)
                    entity:SetColor(color)
                end
            end
        end

        -- Draw death time
        local deathTime = entity:getNetVar("deathTime", 0)
        if deathTime > 0 then
            local timeSinceDeath = CurTime() - deathTime
            local pos = entity:GetPos() + Vector(0, 0, 50)
            local ang = LocalPlayer():EyeAngles()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)

            cam.Start3D2D(pos, ang, 0.1)
            draw.SimpleText("Dead for: " .. math.floor(timeSinceDeath) .. "s", "Default", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end)
    ```
]]
function DrawPlayerRagdoll(entity)
end

--[[
    Purpose:
        Called when exiting storage
    When Called:
        When a player closes a storage container
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage exit
    hook.Add("ExitStorage", "MyAddon", function()
        print("Exited storage")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up storage UI
    hook.Add("ExitStorage", "StorageCleanup", function()
        if lia.storagePanel then
            lia.storagePanel:Remove()
            lia.storagePanel = nil
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage exit handling
    hook.Add("ExitStorage", "AdvancedStorageExit", function()
        -- Clean up storage UI
        if lia.storagePanel then
            lia.storagePanel:Remove()
            lia.storagePanel = nil
        end

        -- Clear storage cache
        lia.currentStorage = nil

        -- Log storage exit time
        local exitTime = os.time()
        lia.lastStorageExit = exitTime

        -- Calculate storage session duration
        if lia.storageEnterTime then
            local duration = exitTime - lia.storageEnterTime
            print("Storage session duration: " .. duration .. " seconds")
            lia.storageEnterTime = nil
        end

        -- Notify server
        net.Start("StorageExited")
        net.SendToServer()
    end)
    ```
]]
function ExitStorage()
end

--[[
    Purpose:
        Called when the F1 menu is closed
    When Called:
        When the F1 character information menu is closed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log F1 menu closing
    hook.Add("F1MenuClosed", "MyAddon", function()
        print("F1 menu closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up F1 menu data
    hook.Add("F1MenuClosed", "F1MenuCleanup", function()
        lia.f1MenuOpen = false
        print("F1 menu closed and state updated")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex F1 menu close handling
    hook.Add("F1MenuClosed", "AdvancedF1Close", function()
        -- Update menu state
        lia.f1MenuOpen = false

        -- Log menu close time
        local closeTime = os.time()
        lia.lastF1Close = closeTime

        -- Calculate menu session duration
        if lia.f1OpenTime then
            local duration = closeTime - lia.f1OpenTime
            print("F1 menu session duration: " .. duration .. " seconds")
            lia.f1OpenTime = nil
        end

        -- Clear cached character data
        lia.f1CharCache = nil

        print("F1 menu closed at " .. os.date("%H:%M:%S", closeTime))
    end)
    ```
]]
function F1MenuClosed()
end

--[[
    Purpose:
        Called when the F1 menu is opened
    When Called:
        When the F1 character information menu is opened
    Parameters:
        self (Panel) - The F1 menu panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log F1 menu opening
    hook.Add("F1MenuOpened", "MyAddon", function(self)
        print("F1 menu opened")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update F1 menu state
    hook.Add("F1MenuOpened", "F1MenuState", function(self)
        lia.f1MenuOpen = true
        lia.f1OpenTime = os.time()
        print("F1 menu opened")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex F1 menu open handling
    hook.Add("F1MenuOpened", "AdvancedF1Open", function(self)
        -- Update menu state
        lia.f1MenuOpen = true

        -- Log menu open time
        local openTime = os.time()
        lia.f1OpenTime = openTime

        -- Cache character data
        local char = LocalPlayer():getChar()
        if char then
            lia.f1CharCache = {
                name = char:getName(),
                faction = char:getFaction(),
                money = char:getMoney(),
                level = char:getData("level", 1)
            }
        end

        -- Customize panel appearance
        if self then
            self:SetBackgroundColor(Color(0, 0, 0, 200))
        end

        print("F1 menu opened at " .. os.date("%H:%M:%S", openTime))
    end)
    ```
]]
function F1MenuOpened(self)
end

--[[
    Purpose:
        Called to filter character models
    When Called:
        When character models need to be filtered or restricted
    Parameters:
        models (table) - The table of available models to filter
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log model filtering
    hook.Add("FilterCharModels", "MyAddon", function(models)
        print("Filtering " .. #models .. " character models")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Remove specific models
    hook.Add("FilterCharModels", "ModelRestriction", function(models)
        local bannedModels = {
        "models/player/combine_soldier.mdl",
        "models/player/combine_super_soldier.mdl"
    }

    for i = #models, 1, -1 do
        if table.HasValue(bannedModels, models[i]) then
            table.remove(models, i)
        end
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model filtering system
    hook.Add("FilterCharModels", "AdvancedModelFilter", function(models)
        local char = LocalPlayer():getChar()
        if not char then return end

            local faction = char:getFaction()

            -- Faction-specific model restrictions
            local factionModels = {
            ["police"] = {
                allowed = {"models/player/police.mdl", "models/player/cop.mdl"},
                    banned = {"models/player/criminal.mdl"}
                        },
                        ["criminal"] = {
                            allowed = {"models/player/criminal.mdl", "models/player/thug.mdl"},
                                banned = {"models/player/police.mdl"}
                                }
                            }

                            local restrictions = factionModels[faction]
                            if restrictions then
                                for i = #models, 1, -1 do
                                    local model = models[i]

                                    -- Check if model is banned
                                    if table.HasValue(restrictions.banned, model) then
                                        table.remove(models, i)

                                        -- Check if only specific models are allowed
                                        elseif restrictions.allowed and #restrictions.allowed > 0 then
                                            if not table.HasValue(restrictions.allowed, model) then
                                                table.remove(models, i)
                                            end
                                        end
                                    end
                                end

                                print("Filtered models for " .. faction .. ": " .. #models .. " remaining")
                            end)
    ```
]]
function FilterCharModels(models)
end

--[[
    Purpose:
        Called to filter door information
    When Called:
        When door information is being displayed
    Parameters:
        entity (Entity) - The door entity
        doorData (table) - The door data
        doorInfo (table) - The door information to filter
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door info filtering
    hook.Add("FilterDoorInfo", "MyAddon", function(entity, doorData, doorInfo)
        print("Filtering door info for " .. entity:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide sensitive door information
    hook.Add("FilterDoorInfo", "DoorInfoSecurity", function(entity, doorData, doorInfo)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Hide owner info for non-owners
            local owner = entity:getNetVar("owner")
            if owner and owner ~= char:getID() then
                doorInfo.owner = "Hidden"
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door information filtering
    hook.Add("FilterDoorInfo", "AdvancedDoorInfoFilter", function(entity, doorData, doorInfo)
        local char = LocalPlayer():getChar()
        if not char then return end

            local faction = char:getFaction()
            local owner = entity:getNetVar("owner")
            local isOwner = owner and owner == char:getID()

            -- Filter based on ownership
            if not isOwner then
                -- Hide sensitive information from non-owners
                doorInfo.owner = "Private"
                doorInfo.price = "Hidden"
                doorInfo.sharedWith = nil
            end

            -- Filter based on faction
            if faction == "police" then
                -- Police can see more information
                doorInfo.locked = entity:getNetVar("locked", false)
                doorInfo.faction = entity:getNetVar("faction")
                elseif faction == "criminal" then
                    -- Criminals see limited information
                    doorInfo.owner = "Unknown"
                    doorInfo.price = "Unknown"
                end

                -- Add faction-specific warnings
                local doorFaction = entity:getNetVar("faction")
                if doorFaction and doorFaction ~= faction then
                    doorInfo.warning = "Restricted Access"
                end
            end)
    ```
]]
function FilterDoorInfo(entity, doorData, doorInfo)
end

--[[
    Purpose:
        Called to get adjusted PAC part data
    When Called:
        When retrieving PAC part data with adjustments applied
    Parameters:
        wearer (Player) - The player wearing the part
        id (string) - The part ID
    Returns:
        table - The adjusted part data
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return basic part data
    hook.Add("GetAdjustedPartData", "MyAddon", function(wearer, id)
        return {scale = 1, color = Color(255, 255, 255)}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply basic adjustments
    hook.Add("GetAdjustedPartData", "PartAdjustments", function(wearer, id)
        local char = wearer:getChar()
        if not char then return {} end

            local data = {scale = 1, color = Color(255, 255, 255)}

            -- Apply faction-based adjustments
            local faction = char:getFaction()
            if faction == "police" then
                data.color = Color(0, 0, 255)
                elseif faction == "medic" then
                    data.color = Color(255, 255, 255)
                end

                return data
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex part data adjustment system
    hook.Add("GetAdjustedPartData", "AdvancedPartData", function(wearer, id)
        local char = wearer:getChar()
        if not char then return {} end

            local data = {scale = 1, color = Color(255, 255, 255)}

            -- Apply faction-based adjustments
            local faction = char:getFaction()
            local factionMods = {
            ["police"] = {color = Color(0, 0, 255), scale = 1.1},
                ["medic"] = {color = Color(255, 255, 255), scale = 1.0},
                    ["criminal"] = {color = Color(255, 0, 0), scale = 0.9}
                    }

                    local mod = factionMods[faction]
                    if mod then
                        data.color = mod.color
                        data.scale = mod.scale
                    end

                    -- Apply level-based adjustments
                    local level = char:getData("level", 1)
                    if level >= 10 then
                        data.scale = data.scale * 1.2
                    end

                    -- Apply character-specific data
                    local charData = char:getData("partMods", {})
                    if charData[id] then
                        for key, value in pairs(charData[id]) do
                            data[key] = value
                        end
                    end

                    return data
                end)
    ```
]]
function GetAdjustedPartData(wearer, id)
end

--[[
    Purpose:
        Called to get door information for admin stick
    When Called:
        When displaying door information in the admin stick HUD
    Parameters:
        target (Entity) - The door entity
        extraInfo (table) - Additional information to add
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic door info
    hook.Add("GetDoorInfoForAdminStick", "MyAddon", function(target, extraInfo)
        table.insert(extraInfo, "Door: " .. target:EntIndex())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add door ownership info
    hook.Add("GetDoorInfoForAdminStick", "DoorOwnership", function(target, extraInfo)
        local owner = target:getNetVar("owner")
        if owner then
            table.insert(extraInfo, "Owner: " .. owner)
            else
                table.insert(extraInfo, "Unowned")
            end

            local locked = target:getNetVar("locked", false)
            table.insert(extraInfo, "Status: " .. (locked and "Locked" or "Unlocked"))
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door information display
    hook.Add("GetDoorInfoForAdminStick", "AdvancedDoorInfo", function(target, extraInfo)
        -- Door title
        local title = target:getNetVar("title", "Door")
        table.insert(extraInfo, "Title: " .. title)

        -- Owner information
        local owner = target:getNetVar("owner")
        if owner then
            local ownerChar = lia.char.getByID(owner)
            if ownerChar then
                table.insert(extraInfo, "Owner: " .. ownerChar:getName() .. " (ID: " .. owner .. ")")
                else
                    table.insert(extraInfo, "Owner: " .. owner)
                end
                else
                    table.insert(extraInfo, "Unowned")
                end

                -- Price information
                local price = target:getNetVar("price", 0)
                if price > 0 then
                    table.insert(extraInfo, "Price: $" .. price)
                end

                -- Lock status
                local locked = target:getNetVar("locked", false)
                table.insert(extraInfo, "Status: " .. (locked and "Locked" or "Unlocked"))

                -- Faction restriction
                local faction = target:getNetVar("faction")
                if faction then
                    table.insert(extraInfo, "Faction: " .. faction)
                end

                -- Shared with information
                local sharedWith = target:getNetVar("sharedWith", {})
                if #sharedWith > 0 then
                    table.insert(extraInfo, "Shared with: " .. #sharedWith .. " players")
                end
            end)
    ```
]]
function GetDoorInfoForAdminStick(target, extraInfo)
end

--[[
    Purpose:
        Called to get injured text
    When Called:
        When displaying injury status text
    Parameters:
        c (Character) - The character to get injury text for
    Returns:
        string - The injury text to display
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return basic injury text
    hook.Add("GetInjuredText", "MyAddon", function(c)
        return "Injured"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Base text on health level
    hook.Add("GetInjuredText", "HealthBasedText", function(c)
        local health = c:getData("health", 100)
        if health <= 0 then
            return "Dead"
            elseif health <= 25 then
                return "Critically Injured"
                elseif health <= 50 then
                    return "Badly Injured"
                    elseif health <= 75 then
                        return "Slightly Injured"
                        else
                            return "Healthy"
                        end
                    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex injury text system
    hook.Add("GetInjuredText", "AdvancedInjuryText", function(c)
        local health = c:getData("health", 100)
        local maxHealth = c:getData("maxHealth", 100)
        local healthPercent = (health / maxHealth) * 100

        local injuryText = ""

        -- Health status
        if health <= 0 then
            injuryText = "Dead"
            elseif healthPercent <= 10 then
                injuryText = "Critically Injured"
                elseif healthPercent <= 25 then
                    injuryText = "Badly Injured"
                    elseif healthPercent <= 50 then
                        injuryText = "Injured"
                        elseif healthPercent <= 75 then
                            injuryText = "Slightly Injured"
                            else
                                injuryText = "Healthy"
                            end

                            -- Add specific injury types
                            local injuries = c:getData("injuries", {})
                            if #injuries > 0 then
                                injuryText = injuryText .. " (" .. table.concat(injuries, ", ") .. ")"
                            end

                            -- Add bleeding status
                            if c:getData("bleeding", false) then
                                injuryText = injuryText .. " [BLEEDING]"
                            end

                            -- Add unconscious status
                            if c:getData("unconscious", false) then
                                injuryText = "Unconscious"
                            end

                            return injuryText
                        end)
    ```
]]
function GetInjuredText(c)
end

--[[
    Purpose:
        Allows modification of the voice indicator text displayed when a player is speaking
    When Called:
        When the voice indicator is being drawn during voice chat
    Parameters:
        client (Player) - The LocalPlayer() who is currently speaking
        voiceText (string) - The current voice indicator text (e.g., "You are talking - 3 people can hear you")
        voiceType (string) - The voice type string (e.g., "talking", "whispering", "yelling")
    Returns:
        string|nil - Return a string to replace the voice text, or return nil/false to keep the original text
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add emojis to voice indicator
    hook.Add("ModifyVoiceIndicatorText", "AddVoiceEmojis", function(client, voiceText, voiceType)
        if voiceType == L("whispering") then
            return "🔇 " .. voiceText .. " 🔇"
            elseif voiceType == L("yelling") then
                return "📢 " .. voiceText .. " 📢"
                elseif voiceType == L("talking") then
                    return "💬 " .. voiceText .. " 💬"
                end
                return nil -- Keep original text
            end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Custom formatting based on voice type
    hook.Add("ModifyVoiceIndicatorText", "CustomVoiceFormat", function(client, voiceText, voiceType)
        local char = client:getChar()
        if not char then return nil end
            local name = char:getName()
            if voiceType == L("whispering") then
                return name .. " is whispering quietly..."
                elseif voiceType == L("yelling") then
                    return name .. " is YELLING LOUDLY!"
                    elseif voiceType == L("talking") then
                        return name .. " is speaking normally"
                    end
                    return nil -- Keep original text
                end)
    ```

    High Complexity:

    ```lua
    -- High: Advanced voice indicator with listener count calculation
    hook.Add("ModifyVoiceIndicatorText", "AdvancedVoiceIndicator", function(client, voiceText, voiceType)
        local char = client:getChar()
        if not char then return nil end

            -- Extract listener count if voice range is enabled
            local listenerCount = 0
            if lia.option.get("voiceRange", false) then
                local match = voiceText:match("(%d+) people can hear you")
                if match then
                    listenerCount = tonumber(match)
                end
            end

            -- Custom formatting with color codes
            local prefix = ""
            local suffix = ""

            if voiceType == L("whispering") then
                prefix = "[QUIET] "
                suffix = " whispers softly"
                elseif voiceType == L("yelling") then
                    prefix = "[LOUD] "
                    suffix = " YELLS LOUDLY"
                    elseif voiceType == L("talking") then
                        prefix = "[NORMAL] "
                        suffix = " speaks"
                    end

                    local result = prefix .. voiceText:gsub("You are ", ""):gsub(" - %d+ people can hear you", "") .. suffix

                    -- Add listener count back if it was present
                    if listenerCount > 0 then
                        result = result .. " - " .. listenerCount .. " people can hear you"
                    end

                    return result
                end)
    ```
]]
function ModifyVoiceIndicatorText(client, voiceText, voiceType)
end

--[[
    Purpose:
        Called to get main menu position
    When Called:
        When positioning the main menu UI
    Parameters:
        character (Character) - The character to position menu for
    Returns:
        table - Position data for the menu
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default position
    hook.Add("GetMainMenuPosition", "MyAddon", function(character)
        return {x = 100, y = 100}
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Position based on screen size
    hook.Add("GetMainMenuPosition", "ScreenBasedPosition", function(character)
        local w, h = ScrW(), ScrH()
        return {
        x = w * 0.1,
        y = h * 0.1,
        w = w * 0.8,
        h = h * 0.8
    }
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu positioning system
    hook.Add("GetMainMenuPosition", "AdvancedMenuPosition", function(character)
        local w, h = ScrW(), ScrH()

        -- Get character-specific settings
        local charData = character:getData("menuSettings", {})
        local savedPos = charData.position

        if savedPos then
            -- Use saved position
            return {
            x = savedPos.x,
            y = savedPos.y,
            w = savedPos.w or w * 0.8,
            h = savedPos.h or h * 0.8
        }
    end

    -- Default positioning based on faction
    local faction = character:getFaction()
    local positions = {
    ["police"] = {x = w * 0.05, y = h * 0.05},
        ["medic"] = {x = w * 0.1, y = h * 0.1},
            ["citizen"] = {x = w * 0.15, y = h * 0.15}
            }

            local pos = positions[faction] or {x = w * 0.1, y = h * 0.1}

            return {
            x = pos.x,
            y = pos.y,
            w = w * 0.8,
            h = h * 0.8
        }
    end)
    ```
]]
function GetMainMenuPosition(character)
end

--[[
    Purpose:
        Called to get weapon name
    When Called:
        When displaying the name of a weapon
    Parameters:
        weapon (Weapon) - The weapon entity
    Returns:
        string - The display name of the weapon
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return weapon class name
    hook.Add("GetWeaponName", "MyAddon", function(weapon)
        return weapon:GetClass()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Use weapon print name
    hook.Add("GetWeaponName", "WeaponPrintName", function(weapon)
        return weapon:GetPrintName() or weapon:GetClass()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon naming system
    hook.Add("GetWeaponName", "AdvancedWeaponNaming", function(weapon)
        local baseName = weapon:GetPrintName() or weapon:GetClass()

        -- Check for custom weapon data
        local weaponData = weapon:getNetVar("weaponData", {})
        if weaponData.customName then
            baseName = weaponData.customName
        end

        -- Add quality prefix
        local quality = weaponData.quality or "common"
        local qualityPrefixes = {
        ["common"] = "",
        ["uncommon"] = "[Uncommon] ",
        ["rare"] = "[Rare] ",
        ["epic"] = "[Epic] ",
        ["legendary"] = "[Legendary] "
    }

    local qualityPrefix = qualityPrefixes[quality] or ""

    -- Add enchantment suffix
    local enchantments = weaponData.enchantments or {}
    local enchantmentSuffix = ""
    if #enchantments > 0 then
        enchantmentSuffix = " of " .. table.concat(enchantments, ", ")
    end

    -- Add durability suffix
    local durability = weaponData.durability
    local maxDurability = weaponData.maxDurability
    if durability and maxDurability then
        local durabilityPercent = (durability / maxDurability) * 100
        if durabilityPercent < 25 then
            enchantmentSuffix = enchantmentSuffix .. " (Damaged)"
            elseif durabilityPercent < 50 then
                enchantmentSuffix = enchantmentSuffix .. " (Worn)"
            end
        end

        return qualityPrefix .. baseName .. enchantmentSuffix
    end)
    ```
]]
function GetWeaponName(weapon)
end

--[[
    Purpose:
        Called to display player HUD information, primarily for admin tools
    When Called:
        Every frame during HUD rendering to allow modules to add custom HUD information
    Parameters:
        client (Player) - The local player
        hudInfos (table) - Array of HUD information objects to display, each containing text, position, color, and font properties
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic player health info
    hook.Add("DisplayPlayerHUDInformation", "BasicHUDInfo", function(client, hudInfos)
        table.insert(hudInfos, {
            text = "Health: " .. client:Health(),
            position = Vector(10, 10),
            color = Color(255, 0, 0)
            })
        end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add character and faction info
    hook.Add("DisplayPlayerHUDInformation", "CharacterHUDInfo", function(client, hudInfos)
        local char = client:getChar()
        if char then
            table.insert(hudInfos, {
                text = "Name: " .. char:getName(),
                position = Vector(10, 30),
                color = Color(255, 255, 255)
                })

                local faction = lia.faction.indices[client:Team()]
                if faction then
                    table.insert(hudInfos, {
                        text = "Faction: " .. faction.name,
                        position = Vector(10, 50),
                        color = faction.color or Color(100, 100, 100)
                        })
                    end
                end
            end)
    ```

    High Complexity:

    ```lua
    -- High: Advanced admin HUD with multiple info panels
    hook.Add("DisplayPlayerHUDInformation", "AdvancedAdminHUD", function(client, hudInfos)
        if not client:IsAdmin() then return end

            -- Player count info
            local playerCount = #player.GetAll()
            table.insert(hudInfos, {
                text = "Players: " .. playerCount,
                position = Vector(ScrW() - 200, 10),
                color = Color(0, 255, 0),
                font = "liaMediumFont"
                })

                -- Server time
                local time = os.date("%H:%M:%S")
                table.insert(hudInfos, {
                    text = "Server Time: " .. time,
                    position = Vector(ScrW() - 200, 30),
                    color = Color(255, 255, 0)
                    })

                    -- Performance info
                    local fps = 1 / FrameTime()
                    table.insert(hudInfos, {
                        text = string.format("FPS: %.0f", fps),
                        position = Vector(ScrW() - 200, 50),
                        color = fps > 30 and Color(0, 255, 0) or Color(255, 0, 0)
                        })

                        -- Character info if available
                        local char = client:getChar()
                        if char then
                            local money = char:getMoney()
                            table.insert(hudInfos, {
                                text = "Money: " .. lia.currency.format(money),
                                position = Vector(ScrW() - 200, 70),
                                color = Color(0, 255, 255)
                                })
                            end
                        end)
    ```
]]
function DisplayPlayerHUDInformation(client, hudInfos)
end

--[[
    Purpose:
        Called when HUD visibility changes
    When Called:
        When the HUD is shown or hidden
    Parameters:
        visible (boolean) - Whether the HUD is visible
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log visibility change
    hook.Add("HUDVisibilityChanged", "MyAddon", function(visible)
        print("HUD visibility: " .. tostring(visible))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Toggle custom UI elements
    hook.Add("HUDVisibilityChanged", "CustomUIToggle", function(visible)
        if IsValid(MyCustomPanel) then
            MyCustomPanel:SetVisible(visible)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex HUD visibility management
    hook.Add("HUDVisibilityChanged", "AdvancedHUDManagement", function(visible)
        -- Toggle all custom UI elements
        local customPanels = {"MyCustomPanel", "MyInventoryPanel", "MyStatsPanel"}

        for _, panelName in ipairs(customPanels) do
            local panel = _G[panelName]
            if IsValid(panel) then
                panel:SetVisible(visible)
            end
        end

        -- Save visibility state
        local char = LocalPlayer():getChar()
        if char then
            char:setData("hudVisible", visible)
        end

        -- Trigger custom events
        if visible then
            hook.Run("CustomHUDShown")
            else
                hook.Run("CustomHUDHidden")
            end
        end)
    ```
]]
function HUDVisibilityChanged(visible)
end

--[[
    Purpose:
        Called when keybinds are initialized
    When Called:
        When the keybind system has finished loading
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log keybind initialization
    hook.Add("InitializedKeybinds", "MyAddon", function()
        print("Keybinds initialized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Register custom keybinds
    hook.Add("InitializedKeybinds", "CustomKeybinds", function()
        lia.keybind.add("my_action", "My Action", KEY_F1, function()
        print("My action triggered!")
    end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex keybind initialization system
    hook.Add("InitializedKeybinds", "AdvancedKeybindInit", function()
        -- Register custom keybinds
        local keybinds = {
        {
            key = "my_action",
            name = "My Action",
            keyCode = KEY_F1,
            callback = function()
            print("My action triggered!")
        end
        },
        {
            key = "my_other_action",
            name = "My Other Action",
            keyCode = KEY_F2,
            callback = function()
            print("My other action triggered!")
        end
    }
    }

    for _, keybind in ipairs(keybinds) do
        lia.keybind.add(keybind.key, keybind.name, keybind.keyCode, keybind.callback)
    end

    -- Set up keybind categories
    lia.keybind.addCategory("My Addon", "Custom keybinds for my addon")

    -- Load saved keybind settings
    local savedKeybinds = lia.data.get("myAddonKeybinds", {})
    for key, keyCode in pairs(savedKeybinds) do
        lia.keybind.setKey(key, keyCode)
    end

    print("Keybind system initialized with " .. #keybinds .. " custom keybinds")
    end)
    ```
]]
function InitializedKeybinds()
end

--[[
    Purpose:
        Called when options are initialized
    When Called:
        When the option system has finished loading
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log option initialization
    hook.Add("InitializedOptions", "MyAddon", function()
        print("Options initialized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Register custom options
    hook.Add("InitializedOptions", "CustomOptions", function()
        lia.option.add("myOption", "My Option", "A custom option", true)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex option initialization system
    hook.Add("InitializedOptions", "AdvancedOptionInit", function()
        -- Register custom options
        local options = {
        {
            key = "myOption",
            name = "My Option",
            description = "A custom option",
            default = true,
            type = "boolean"
            },
            {
                key = "myValue",
                name = "My Value",
                description = "A custom value",
                default = 100,
                type = "number",
                min = 0,
                max = 1000
                },
                {
                    key = "myString",
                    name = "My String",
                    description = "A custom string",
                    default = "default",
                    type = "string"
                }
            }

            for _, option in ipairs(options) do
                lia.option.add(option.key, option.name, option.description, option.default)
            end

            -- Set up option callbacks
            lia.option.addCallback("myOption", function(value)
            print("My option changed: " .. tostring(value))
        end)

        -- Load saved options
        local savedOptions = lia.data.get("myAddonOptions", {})
        for key, value in pairs(savedOptions) do
            lia.option.set(key, value)
        end

        print("Option system initialized with " .. #options .. " custom options")
    end)
    ```
]]
function InitializedOptions()
end

--[[
    Purpose:
        Called when the interaction menu is closed
    When Called:
        When the interaction menu UI is closed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log menu closing
    hook.Add("InteractionMenuClosed", "MyAddon", function()
        print("Interaction menu closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up menu data
    hook.Add("InteractionMenuClosed", "MenuCleanup", function()
        lia.interactionMenuOpen = false
        lia.currentInteractionTarget = nil
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex interaction menu close handling
    hook.Add("InteractionMenuClosed", "AdvancedMenuClose", function()
        -- Update menu state
        lia.interactionMenuOpen = false

        -- Clear interaction target
        lia.currentInteractionTarget = nil

        -- Log menu close time
        local closeTime = os.time()
        lia.lastInteractionMenuClose = closeTime

        -- Calculate menu session duration
        if lia.interactionMenuOpenTime then
            local duration = closeTime - lia.interactionMenuOpenTime
            print("Interaction menu session duration: " .. duration .. " seconds")
            lia.interactionMenuOpenTime = nil
        end

        -- Clear cached interaction data
        lia.interactionCache = nil

        print("Interaction menu closed at " .. os.date("%H:%M:%S", closeTime))
    end)
    ```
]]
function InteractionMenuClosed()
end

--[[
    Purpose:
        Called when the interaction menu is opened
    When Called:
        When the interaction menu UI is opened
    Parameters:
        frame (Panel) - The interaction menu frame
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log menu opening
    hook.Add("InteractionMenuOpened", "MyAddon", function(frame)
        print("Interaction menu opened")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update menu state
    hook.Add("InteractionMenuOpened", "MenuState", function(frame)
        lia.interactionMenuOpen = true
        lia.interactionMenuOpenTime = os.time()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex interaction menu open handling
    hook.Add("InteractionMenuOpened", "AdvancedMenuOpen", function(frame)
        -- Update menu state
        lia.interactionMenuOpen = true

        -- Log menu open time
        local openTime = os.time()
        lia.interactionMenuOpenTime = openTime

        -- Cache interaction target
        local target = lia.util.getEntityInDirection(LocalPlayer())
        if IsValid(target) then
            lia.currentInteractionTarget = target

            -- Cache interaction data
            lia.interactionCache = {
                entity = target,
                class = target:GetClass(),
                model = target:GetModel(),
                position = target:GetPos()
            }
        end

        -- Customize frame appearance
        if frame then
            frame:SetBackgroundColor(Color(0, 0, 0, 200))
            frame:SetSize(300, 400)
        end

        print("Interaction menu opened at " .. os.date("%H:%M:%S", openTime))
    end)
    ```
]]
function InteractionMenuOpened(frame)
end

--[[
    Purpose:
        Called when an item icon is clicked
    When Called:
        When a player clicks on an item icon in inventory
    Parameters:
        self (Panel) - The inventory panel
        itemIcon (Panel) - The item icon that was clicked
        keyCode (number) - The mouse button code
    Returns:
        boolean - True to intercept, false to allow
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log item clicks
    hook.Add("InterceptClickItemIcon", "MyAddon", function(self, itemIcon, keyCode)
        print("Item clicked: " .. (itemIcon.item and itemIcon.item.name or "Unknown"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Custom right-click menu
    hook.Add("InterceptClickItemIcon", "CustomItemMenu", function(self, itemIcon, keyCode)
        if keyCode == MOUSE_RIGHT then
            local menu = DermaMenu()
            menu:AddOption("Use", function()
            itemIcon.item:use()
        end)
        menu:AddOption("Drop", function()
        itemIcon.item:drop()
    end)
    menu:Open()
    return true
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item interaction system
    hook.Add("InterceptClickItemIcon", "AdvancedItemInteraction", function(self, itemIcon, keyCode)
        if not itemIcon.item then return end

            local item = itemIcon.item
            local char = LocalPlayer():getChar()
            if not char then return end

                -- Right-click for context menu
                if keyCode == MOUSE_RIGHT then
                    local menu = DermaMenu()

                    -- Add use option
                    menu:AddOption("Use", function()
                    item:use()
                end)

                -- Add drop option if not equipped
                if not item:getData("equipped", false) then
                    menu:AddOption("Drop", function()
                    item:drop()
                end)
            end

            -- Add equip/unequip option
            if item:getData("equipped", false) then
                menu:AddOption("Unequip", function()
                item:unequip()
            end)
            else
                menu:AddOption("Equip", function()
                item:equip()
            end)
        end

        -- Add examine option
        menu:AddOption("Examine", function()
        item:examine()
    end)

    menu:Open()
    return true
    end

    -- Middle-click for quick use
    if keyCode == MOUSE_MIDDLE then
        item:use()
        return true
    end
    end)
    ```
]]
function InterceptClickItemIcon(self, itemIcon, keyCode)
end

--[[
    Purpose:
        Called when an inventory is closed
    When Called:
        When a player closes an inventory panel
    Parameters:
        self (Panel) - The inventory panel
        inventory (Inventory) - The inventory that was closed
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory close
    hook.Add("InventoryClosed", "MyAddon", function(self, inventory)
        print("Inventory closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save inventory state
    hook.Add("InventoryClosed", "SaveInventoryState", function(self, inventory)
        local char = LocalPlayer():getChar()
        if char then
            char:setData("lastInventoryClose", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory close handling
    hook.Add("InventoryClosed", "AdvancedInventoryClose", function(self, inventory)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Save inventory state
            char:setData("lastInventoryClose", os.time())

            -- Check for unsaved changes
            if inventory:hasUnsavedChanges() then
                Derma_Query(
                "You have unsaved changes. Save before closing?",
                "Unsaved Changes",
                "Save",
                function()
                    inventory:save()
                    end,
                    "Don't Save",
                    function()
                        inventory:revert()
                    end
                    )
                end

                -- Clear selection
                inventory:clearSelection()

                -- Trigger custom event
                hook.Run("CustomInventoryClosed", inventory)
            end)
    ```
]]
function InventoryClosed(self, inventory)
end

--[[
    Purpose:
        Called when an inventory item icon is created
    When Called:
        When building the visual icon for an item in inventory
    Parameters:
        icon (Panel) - The icon panel being created
        item (Item) - The item the icon represents
        self (Panel) - The inventory panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log icon creation
    hook.Add("InventoryItemIconCreated", "MyAddon", function(icon, item, self)
        print("Item icon created: " .. item.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize icon appearance
    hook.Add("InventoryItemIconCreated", "CustomizeItemIcon", function(icon, item, self)
        -- Set icon size
        icon:SetSize(64, 64)

        -- Add quality border
        local quality = item:getData("quality", "common")
        if quality == "rare" then
            icon:SetBorderColor(Color(0, 100, 255))
            elseif quality == "epic" then
                icon:SetBorderColor(Color(150, 0, 255))
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item icon customization
    hook.Add("InventoryItemIconCreated", "AdvancedItemIcon", function(icon, item, self)
        -- Set icon size
        icon:SetSize(64, 64)

        -- Add quality border
        local quality = item:getData("quality", "common")
        local borderColors = {
        ["common"] = Color(150, 150, 150),
        ["uncommon"] = Color(0, 200, 0),
        ["rare"] = Color(0, 100, 255),
        ["epic"] = Color(150, 0, 255),
        ["legendary"] = Color(255, 200, 0)
    }
    icon:SetBorderColor(borderColors[quality] or Color(150, 150, 150))

    -- Add durability bar
    local durability = item:getData("durability")
    if durability then
        local durabilityBar = icon:Add("DPanel")
        durabilityBar:SetSize(icon:GetWide(), 5)
        durabilityBar:SetPos(0, icon:GetTall() - 5)

        local durabilityPercent = durability / 100
        local barColor = Color(255 * (1 - durabilityPercent), 255 * durabilityPercent, 0)
        durabilityBar:SetBackgroundColor(barColor)
    end

    -- Add quantity label
    local quantity = item:getData("quantity", 1)
    if quantity > 1 then
        local quantityLabel = icon:Add("DLabel")
        quantityLabel:SetText("x" .. quantity)
        quantityLabel:SetFont("DermaDefaultBold")
        quantityLabel:SetTextColor(Color(255, 255, 255))
        quantityLabel:SizeToContents()
        quantityLabel:SetPos(icon:GetWide() - quantityLabel:GetWide() - 5, 5)
    end

    -- Add equipped indicator
    if item:getData("equipped", false) then
        local equippedIcon = icon:Add("DLabel")
        equippedIcon:SetText("E")
        equippedIcon:SetFont("DermaDefaultBold")
        equippedIcon:SetTextColor(Color(0, 255, 0))
        equippedIcon:SizeToContents()
        equippedIcon:SetPos(5, 5)
    end
    end)
    ```
]]
function InventoryItemIconCreated(icon, item, self)
end

--[[
    Purpose:
        Called when an inventory is opened
    When Called:
        When a player opens an inventory panel
    Parameters:
        panel (Panel) - The inventory panel
        inventory (Inventory) - The inventory being opened
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory open
    hook.Add("InventoryOpened", "MyAddon", function(panel, inventory)
        print("Inventory opened")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Save open state
    hook.Add("InventoryOpened", "SaveInventoryOpen", function(panel, inventory)
        local char = LocalPlayer():getChar()
        if char then
            char:setData("lastInventoryOpen", os.time())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory open handling
    hook.Add("InventoryOpened", "AdvancedInventoryOpen", function(panel, inventory)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Save open state
            char:setData("lastInventoryOpen", os.time())

            -- Customize panel appearance
            panel:SetBackgroundColor(Color(50, 50, 50, 200))
            panel:SetSize(600, 400)
            panel:Center()

            -- Add custom title
            local title = panel:Add("DLabel")
            title:SetText("Inventory - " .. char:getName())
            title:SetFont("DermaLarge")
            title:Dock(TOP)
            title:SetHeight(30)

            -- Add weight display
            local weight = inventory:getData("weight", 0)
            local maxWeight = inventory:getData("maxWeight", 100)
            local weightLabel = panel:Add("DLabel")
            weightLabel:SetText(string.format("Weight: %d / %d", weight, maxWeight))
            weightLabel:Dock(BOTTOM)
            weightLabel:SetHeight(20)

            -- Trigger custom event
            hook.Run("CustomInventoryOpened", inventory)
        end)
    ```
]]
function InventoryOpened(panel, inventory)
end

--[[
    Purpose:
        Called when an inventory panel is created
    When Called:
        When building an inventory UI panel
    Parameters:
        panel (Panel) - The inventory panel being created
        inventory (Inventory) - The inventory the panel represents
        parent (Panel) - The parent panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log panel creation
    hook.Add("InventoryPanelCreated", "MyAddon", function(panel, inventory, parent)
        print("Inventory panel created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize panel appearance
    hook.Add("InventoryPanelCreated", "CustomizeInventoryPanel", function(panel, inventory, parent)
        panel:SetBackgroundColor(Color(50, 50, 50, 200))
        panel:SetSize(500, 350)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory panel customization
    hook.Add("InventoryPanelCreated", "AdvancedInventoryPanel", function(panel, inventory, parent)
        -- Customize appearance
        panel:SetBackgroundColor(Color(50, 50, 50, 200))
        panel:SetSize(600, 400)

        -- Add title bar
        local titleBar = panel:Add("DPanel")
        titleBar:Dock(TOP)
        titleBar:SetHeight(30)
        titleBar:SetBackgroundColor(Color(30, 30, 30, 255))

        local title = titleBar:Add("DLabel")
        title:SetText("Inventory")
        title:SetFont("DermaLarge")
        title:Dock(FILL)
        title:SetContentAlignment(5)

        -- Add close button
        local closeBtn = titleBar:Add("DButton")
        closeBtn:SetText("X")
        closeBtn:Dock(RIGHT)
        closeBtn:SetWidth(30)
        closeBtn.DoClick = function()
        panel:Close()
    end

    -- Add weight bar
    local weight = inventory:getData("weight", 0)
    local maxWeight = inventory:getData("maxWeight", 100)

    local weightBar = panel:Add("DPanel")
    weightBar:Dock(BOTTOM)
    weightBar:SetHeight(25)
    weightBar:SetBackgroundColor(Color(30, 30, 30, 255))

    local weightLabel = weightBar:Add("DLabel")
    weightLabel:SetText(string.format("Weight: %d / %d (%.1f%%)", weight, maxWeight, (weight / maxWeight) * 100))
    weightLabel:Dock(FILL)
    weightLabel:SetContentAlignment(5)

    -- Add filter buttons
    local filterPanel = panel:Add("DPanel")
    filterPanel:Dock(TOP)
    filterPanel:SetHeight(30)
    filterPanel:SetBackgroundColor(Color(40, 40, 40, 255))

    local filterAll = filterPanel:Add("DButton")
    filterAll:SetText("All")
    filterAll:Dock(LEFT)
    filterAll:SetWidth(60)
    filterAll.DoClick = function()
    inventory:setFilter(nil)
    end

    local filterWeapons = filterPanel:Add("DButton")
    filterWeapons:SetText("Weapons")
    filterWeapons:Dock(LEFT)
    filterWeapons:SetWidth(80)
    filterWeapons.DoClick = function()
    inventory:setFilter("weapon")
    end

    local filterArmor = filterPanel:Add("DButton")
    filterArmor:SetText("Armor")
    filterArmor:Dock(LEFT)
    filterArmor:SetWidth(70)
    filterArmor.DoClick = function()
    inventory:setFilter("armor")
    end
    end)
    ```
]]
function InventoryPanelCreated(panel, inventory, parent)
end

--[[
    Purpose:
        Called to paint over an item icon
    When Called:
        When rendering additional graphics on an item icon
    Parameters:
        self (Panel) - The item icon panel
        itemTable (table) - The item data table
        w (number) - The width of the icon
        h (number) - The height of the icon
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Draw item name
    hook.Add("ItemPaintOver", "MyAddon", function(self, itemTable, w, h)
        draw.SimpleText(itemTable.name, "DermaDefault", w / 2, h - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Draw durability bar
    hook.Add("ItemPaintOver", "DrawDurabilityBar", function(self, itemTable, w, h)
        local item = self.item
        if not item then return end

            local durability = item:getData("durability", 100)
            local barWidth = (w - 4) * (durability / 100)

            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(2, h - 8, w - 4, 6)

            local barColor = Color(255 * (1 - durability / 100), 255 * (durability / 100), 0)
            surface.SetDrawColor(barColor)
            surface.DrawRect(2, h - 8, barWidth, 6)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item icon overlay
    hook.Add("ItemPaintOver", "AdvancedItemOverlay", function(self, itemTable, w, h)
        local item = self.item
        if not item then return end

            -- Draw durability bar
            local durability = item:getData("durability", 100)
            if durability < 100 then
                local barWidth = (w - 4) * (durability / 100)

                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(2, h - 8, w - 4, 6)

                local barColor = Color(255 * (1 - durability / 100), 255 * (durability / 100), 0)
                surface.SetDrawColor(barColor)
                surface.DrawRect(2, h - 8, barWidth, 6)
            end

            -- Draw quantity
            local quantity = item:getData("quantity", 1)
            if quantity > 1 then
                draw.SimpleText("x" .. quantity, "DermaDefaultBold", w - 5, 5, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
            end

            -- Draw equipped indicator
            if item:getData("equipped", false) then
                draw.SimpleText("E", "DermaDefaultBold", 5, 5, Color(0, 255, 0))
            end

            -- Draw quality border
            local quality = item:getData("quality", "common")
            local borderColors = {
            ["common"] = Color(150, 150, 150),
            ["uncommon"] = Color(0, 200, 0),
            ["rare"] = Color(0, 100, 255),
            ["epic"] = Color(150, 0, 255),
            ["legendary"] = Color(255, 200, 0)
        }

        local borderColor = borderColors[quality] or Color(150, 150, 150)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end)
    ```
]]
function ItemPaintOver(self, itemTable, w, h)
end

--[[
    Purpose:
        Called to show entity menu for an item
    When Called:
        When displaying the interaction menu for an item entity
    Parameters:
        entity (Entity) - The item entity
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log entity menu display
    hook.Add("ItemShowEntityMenu", "MyAddon", function(entity)
        print("Showing menu for: " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom menu options
    hook.Add("ItemShowEntityMenu", "CustomEntityMenu", function(entity)
        local item = entity:getNetVar("item")
        if not item then return end

            local menu = DermaMenu()
            menu:AddOption("Examine", function()
            chat.AddText("You examine the " .. item.name)
        end)
        menu:Open()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity menu system
    hook.Add("ItemShowEntityMenu", "AdvancedEntityMenu", function(entity)
        if not IsValid(entity) then return end

            local item = entity:getNetVar("item")
            if not item then return end

                local client = LocalPlayer()
                local char = client:getChar()
                if not char then return end

                    -- Create menu
                    local menu = DermaMenu()

                    -- Add examine option
                    menu:AddOption("Examine", function()
                    local desc = item.desc or "No description"
                    chat.AddText(Color(255, 255, 255), "You examine the ", Color(100, 200, 255), item.name, Color(255, 255, 255), ": " .. desc)
                end)

                -- Add pickup option if close enough
                local distance = client:GetPos():Distance(entity:GetPos())
                if distance < 100 then
                    menu:AddOption("Pick Up", function()
                    net.Start("liaItemPickup")
                    net.WriteEntity(entity)
                    net.SendToServer()
                end)
                else
                    local option = menu:AddOption("Pick Up (Too Far)")
                    option:SetEnabled(false)
                end

                -- Add custom options based on item type
                if item.category == "weapons" then
                    menu:AddOption("Inspect Weapon", function()
                    chat.AddText("This weapon has " .. (item:getData("ammo", 0)) .. " rounds")
                end)
            end

            menu:Open()
        end)
    ```
]]
function ItemShowEntityMenu(entity)
end

--[[
    Purpose:
        Called when keybinds are loaded
    When Called:
        After all keybinds have been initialized
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log keybinds loaded
    hook.Add("KeybindsLoaded", "MyAddon", function()
        print("Keybinds have been loaded")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Setup custom keybinds
    hook.Add("KeybindsLoaded", "SetupCustomKeybinds", function()
        -- Register custom keybind
        lia.keybind.register("customAction", KEY_F, function()
        print("Custom action triggered")
        end, "Custom Action")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex keybind system
    hook.Add("KeybindsLoaded", "AdvancedKeybinds", function()
        -- Load saved keybinds from data
        local savedBinds = lia.data.get("customKeybinds", {})

        -- Register custom keybinds
        for action, key in pairs(savedBinds) do
            lia.keybind.register(action, key, function()
            net.Start("liaCustomAction")
            net.WriteString(action)
            net.SendToServer()
            end, action)
        end

        -- Setup keybind categories
        local categories = {
        ["Movement"] = {"forward", "backward", "left", "right"},
            ["Actions"] = {"use", "attack", "reload"},
                ["Menu"] = {"inventory", "character", "scoreboard"}
                }

                -- Create keybind menu
                concommand.Add("lia_keybinds", function()
                local frame = vgui.Create("DFrame")
                frame:SetSize(600, 400)
                frame:Center()
                frame:MakePopup()
                frame:SetTitle("Keybind Settings")

                local list = vgui.Create("DScrollPanel", frame)
                list:Dock(FILL)

                for category, binds in pairs(categories) do
                    local label = list:Add("DLabel")
                    label:SetText(category)
                    label:Dock(TOP)
                end
            end)
        end)
    ```
]]
function KeybindsLoaded()
end

--[[
    Purpose:
        Called when a player is kicked from a character
    When Called:
        When a player is forcibly removed from their character
    Parameters:
        id (number) - The character ID
        isCurrentChar (boolean) - Whether this is the current character
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character kick
    hook.Add("KickedFromChar", "MyAddon", function(id, isCurrentChar)
        print("Kicked from character: " .. id)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Show notification
    hook.Add("KickedFromChar", "NotifyCharKick", function(id, isCurrentChar)
        if isCurrentChar then
            lia.util.notify("You have been kicked from your character")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character kick handling
    hook.Add("KickedFromChar", "AdvancedCharKick", function(id, isCurrentChar)
        -- Show notification
        if isCurrentChar then
            lia.util.notify("You have been kicked from your character", 4)

            -- Clear character-specific UI
            if IsValid(lia.gui.charInfo) then
                lia.gui.charInfo:Remove()
            end

            if IsValid(lia.gui.inventory) then
                lia.gui.inventory:Remove()
            end

            -- Log the kick
            lia.log.write("client_char_kick", {
                charID = id,
                timestamp = os.time()
                })

                -- Save any pending data
                net.Start("liaSaveCharData")
                net.WriteUInt(id, 32)
                net.SendToServer()

                -- Return to character selection
                timer.Simple(1, function()
                vgui.Create("liaCharacterMenu")
            end)
            else
                -- Just log if not current character
                print("Character " .. id .. " was kicked")
            end
        end)
    ```
]]
function KickedFromChar(id, isCurrentChar)
end

--[[
    Purpose:
        Called to load character information
    When Called:
        When character data needs to be loaded
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log character info load
    hook.Add("LoadCharInformation", "MyAddon", function()
        print("Loading character information")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Load custom character data
    hook.Add("LoadCharInformation", "LoadCustomCharData", function()
        local char = LocalPlayer():getChar()
        if char then
            -- Request custom data from server
            netstream.Start("RequestCustomCharData", char:getID())
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex character data loading
    hook.Add("LoadCharInformation", "AdvancedCharDataLoad", function()
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Request custom data from server
            netstream.Start("RequestCustomCharData", char:getID())

            -- Initialize client-side character systems
            MyAddon.InitializeCharacter(char)

            -- Load character preferences
            local prefs = char:getData("preferences", {})
            for key, value in pairs(prefs) do
                MyAddon.SetPreference(key, value)
            end

            print("Character information loaded for " .. char:getName())
        end)
    ```
]]
function LoadCharInformation()
end

--[[
    Purpose:
        Called to load main menu information
    When Called:
        When building the main menu character information
    Parameters:
        info (table) - The information table to populate
        character (Character) - The character being displayed
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic info
    hook.Add("LoadMainMenuInformation", "MyAddon", function(info, character)
        info["Level"] = character:getData("level", 1)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple info fields
    hook.Add("LoadMainMenuInformation", "AddCharacterInfo", function(info, character)
        info["Level"] = character:getData("level", 1)
        info["Experience"] = character:getData("exp", 0)
        info["Money"] = lia.currency.get(character:getMoney())
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu information system
    hook.Add("LoadMainMenuInformation", "AdvancedMenuInfo", function(info, character)
        -- Basic info
        info["Level"] = character:getData("level", 1)
        info["Experience"] = character:getData("exp", 0) .. " / " .. character:getData("expNeeded", 100)
        info["Money"] = lia.currency.get(character:getMoney())

        -- Faction info
        local faction = lia.faction.indices[character:getFaction()]
        if faction then
            info["Faction"] = faction.name
            info["Rank"] = character:getData("rankName", "Recruit")
        end

        -- Stats
        info["Health"] = character:getData("health", 100)
        info["Armor"] = character:getData("armor", 0)

        -- Playtime
        local playTime = character:getData("playTime", 0)
        local hours = math.floor(playTime / 3600)
        local minutes = math.floor((playTime % 3600) / 60)
        info["Playtime"] = string.format("%dh %dm", hours, minutes)
    end)
    ```
]]
function LoadMainMenuInformation(info, character)
end

--[[
    Purpose:
        Called to modify a player's model on the scoreboard
    When Called:
        When rendering a player's model in the scoreboard
    Parameters:
        client (Player) - The viewing player
        ply (Player) - The player whose model is being displayed
    Returns:
        string - The modified model path
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return player model
    hook.Add("ModifyScoreboardModel", "MyAddon", function(client, ply)
        return ply:GetModel()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Show faction models
    hook.Add("ModifyScoreboardModel", "ScoreboardFactionModels", function(client, ply)
        local char = ply:getChar()
        if char then
            return char:getModel()
        end
        return ply:GetModel()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard model system
    hook.Add("ModifyScoreboardModel", "AdvancedScoreboardModel", function(client, ply)
        local char = ply:getChar()
        if not char then return ply:GetModel() end

            -- Show outfit model if equipped
            local outfit = char:getData("outfit")
            if outfit then
                local outfitItem = lia.item.instances[outfit]
                if outfitItem and outfitItem.model then
                    return outfitItem.model
                end
            end

            -- Show character model
            return char:getModel()
        end)
    ```
]]
function ModifyScoreboardModel(client, ply)
end

--[[
    Purpose:
        Called when admin stick menu is closed
    When Called:
        When the admin stick context menu is closed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log menu close
    hook.Add("OnAdminStickMenuClosed", "MyAddon", function()
        print("Admin stick menu closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up menu state
    hook.Add("OnAdminStickMenuClosed", "CleanupAdminMenu", function()
        MyAddon.selectedEntity = nil
        MyAddon.menuOpen = false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex menu cleanup
    hook.Add("OnAdminStickMenuClosed", "AdvancedMenuCleanup", function()
        -- Clear selection
        MyAddon.selectedEntity = nil
        MyAddon.menuOpen = false

        -- Save menu state
        local char = LocalPlayer():getChar()
        if char then
            char:setData("lastAdminMenuClose", os.time())
        end

        -- Clean up temporary data
        MyAddon.tempData = {}

            print("Admin stick menu closed and cleaned up")
        end)
    ```
]]
function OnAdminStickMenuClosed()
end

--[[
    Purpose:
        Called when a chat message is received
    When Called:
        When a player receives a chat message
    Parameters:
        client (Player) - The player receiving the message
        chatType (string) - The type of chat message
        text (string) - The message text
        anonymous (boolean) - Whether the message is anonymous
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log received messages
    hook.Add("OnChatReceived", "MyAddon", function(client, chatType, text, anonymous)
        print("Received " .. chatType .. " message: " .. text)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter messages based on type
    hook.Add("OnChatReceived", "MessageFiltering", function(client, chatType, text, anonymous)
        if chatType == "ooc" then
            -- OOC messages are always visible
            return true
            elseif chatType == "ic" then
                -- IC messages only if player has character
                local char = client:getChar()
                return char ~= nil
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat system
    hook.Add("OnChatReceived", "AdvancedChat", function(client, chatType, text, anonymous)
        local char = client:getChar()
        if not char then return end

            -- Check if player is muted
            if char:getData("muted", false) then
                client:ChatPrint("You are muted and cannot receive messages")
                return false
            end

            -- Check if player is gagged
            if char:getData("gagged", false) then
                client:ChatPrint("You are gagged and cannot receive messages")
                return false
            end

            -- Check message type restrictions
            local faction = char:getFaction()
            if chatType == "ooc" and faction == "police" then
                client:ChatPrint("Police officers cannot use OOC chat")
                return false
            end

            -- Check for spam protection
            local lastMessage = char:getData("lastMessage", 0)
            local messageCooldown = 1 -- 1 second cooldown
            if os.time() - lastMessage < messageCooldown then
                client:ChatPrint("Please wait before sending another message")
                return false
            end

            -- Check for inappropriate content
            local bannedWords = {"spam", "hack", "cheat", "exploit"}
            for _, word in ipairs(bannedWords) do
                if string.find(string.lower(text), string.lower(word)) then
                    client:ChatPrint("Your message was blocked for inappropriate content")
                    return false
                end
            end

            -- Update last message time
            char:setData("lastMessage", os.time())

            -- Check for admin commands
            if string.sub(text, 1, 1) == "!" then
                local command = string.sub(text, 2)
                if command == "admin" then
                    -- Admin command
                    client:ChatPrint("Admin command executed")
                    return false
                end
            end

            -- Log message
            print(string.format("[%s] %s: %s", chatType, client:Name(), text))
        end)
    ```
]]
--[[
    Purpose:
        Called when a chat message is received
    When Called:
        When a player receives a chat message
    Parameters:
        client (Player) - The player receiving the message
        chatType (string) - The type of chat message
        text (string) - The message text
        anonymous (boolean) - Whether the message is anonymous
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log received messages
    hook.Add("OnChatReceived", "MyAddon", function(client, chatType, text, anonymous)
        print("Received " .. chatType .. " message: " .. text)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter messages based on type
    hook.Add("OnChatReceived", "MessageFiltering", function(client, chatType, text, anonymous)
        if chatType == "ooc" then
            -- OOC messages are always visible
            return true
            elseif chatType == "ic" then
                -- IC messages only if player has character
                local char = client:getChar()
                return char ~= nil
            end
            return false
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat system
    hook.Add("OnChatReceived", "AdvancedChat", function(client, chatType, text, anonymous)
        local char = client:getChar()
        if not char then return end

            -- Check if player is muted
            if char:getData("muted", false) then
                client:ChatPrint("You are muted and cannot receive messages")
                return false
            end

            -- Check if player is gagged
            if char:getData("gagged", false) then
                client:ChatPrint("You are gagged and cannot receive messages")
                return false
            end

            -- Check message type restrictions
            local faction = char:getFaction()
            if chatType == "ooc" and faction == "police" then
                client:ChatPrint("Police officers cannot use OOC chat")
                return false
            end

            -- Check for spam protection
            local lastMessage = char:getData("lastMessage", 0)
            local messageCooldown = 1 -- 1 second cooldown
            if os.time() - lastMessage < messageCooldown then
                client:ChatPrint("Please wait before sending another message")
                return false
            end

            -- Check for inappropriate content
            local bannedWords = {"spam", "hack", "cheat", "exploit"}
            for _, word in ipairs(bannedWords) do
                if string.find(string.lower(text), string.lower(word)) then
                    client:ChatPrint("Your message was blocked for inappropriate content")
                    return false
                end
            end

            -- Update last message time
            char:setData("lastMessage", os.time())

            -- Check for admin commands
            if string.sub(text, 1, 1) == "!" then
                local command = string.sub(text, 2)
                if command == "admin" then
                    -- Admin command
                    client:ChatPrint("Admin command executed")
                    return false
                end
            end

            -- Log message
            print(string.format("[%s] %s: %s", chatType, client:Name(), text))
        end)
    ```
]]
function OnChatReceived(client, chatType, text, anonymous)
end

--[[
    Purpose:
        Called when creating an item interaction menu
    When Called:
        When building the context menu for an item
    Parameters:
        self (Item) - The item instance
        menu (Menu) - The menu being created
        itemTable (table) - The item table data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic menu option
    hook.Add("OnCreateItemInteractionMenu", "MyAddon", function(self, menu, itemTable)
        menu:AddOption("Use Item", function()
        print("Used item: " .. itemTable.name)
    end)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add conditional menu options
    hook.Add("OnCreateItemInteractionMenu", "ItemMenuOptions", function(self, menu, itemTable)
        -- Always add use option
        menu:AddOption("Use", function()
        self:use()
    end)

    -- Add drop option if not equipped
    if not self:getData("equipped", false) then
        menu:AddOption("Drop", function()
        self:drop()
    end)
    end

    -- Add examine option
    menu:AddOption("Examine", function()
    self:examine()
    end)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item interaction menu system
    hook.Add("OnCreateItemInteractionMenu", "AdvancedItemMenu", function(self, menu, itemTable)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Basic options
            menu:AddOption("Use", function()
            self:use()
        end)

        -- Conditional options based on item state
        if not self:getData("equipped", false) then
            menu:AddOption("Equip", function()
            self:equip()
        end)

        menu:AddOption("Drop", function()
        self:drop()
    end)
    else
        menu:AddOption("Unequip", function()
        self:unequip()
    end)
    end

    -- Examine option
    menu:AddOption("Examine", function()
    self:examine()
    end)

    -- Admin options
    if LocalPlayer():IsAdmin() then
        menu:AddSpacer()
        menu:AddOption("Admin: Delete", function()
        self:remove()
    end)

    menu:AddOption("Admin: Duplicate", function()
    local newItem = lia.item.instance(itemTable.uniqueID)
    if newItem then
        char:getInv():add(newItem)
    end
    end)
    end

    -- Faction-specific options
    local faction = char:getFaction()
    if faction == "police" and itemTable.uniqueID == "weapon_pistol" then
        menu:AddOption("Police: Check Ammo", function()
        local ammo = self:getData("ammo", 0)
        LocalPlayer():ChatPrint("Ammo: " .. ammo)
    end)
    end
    end)
    ```
]]
function OnCreateItemInteractionMenu(self, menu, itemTable)
end

--[[
    Purpose:
        Called when creating a storage panel
    When Called:
        When building the storage UI panel
    Parameters:
        localInvPanel (Panel) - The local inventory panel
        storageInvPanel (Panel) - The storage inventory panel
        storage (Entity) - The storage entity
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log storage panel creation
    hook.Add("OnCreateStoragePanel", "MyAddon", function(localInvPanel, storageInvPanel, storage)
        print("Storage panel created")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize storage panel appearance
    hook.Add("OnCreateStoragePanel", "StoragePanelCustomize", function(localInvPanel, storageInvPanel, storage)
        if localInvPanel then
            localInvPanel:SetBackgroundColor(Color(50, 50, 50, 200))
        end

        if storageInvPanel then
            storageInvPanel:SetBackgroundColor(Color(100, 50, 50, 200))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage panel system
    hook.Add("OnCreateStoragePanel", "AdvancedStoragePanel", function(localInvPanel, storageInvPanel, storage)
        if not IsValid(storage) then return end

            -- Customize local inventory panel
            if localInvPanel then
                localInvPanel:SetBackgroundColor(Color(50, 50, 50, 200))
                localInvPanel:SetSize(400, 300)

                -- Add title
                local title = localInvPanel:Add("DLabel")
                title:SetText("Your Inventory")
                title:SetFont("DermaDefault")
                title:Dock(TOP)
                title:SetHeight(25)
            end

            -- Customize storage inventory panel
            if storageInvPanel then
                storageInvPanel:SetBackgroundColor(Color(100, 50, 50, 200))
                storageInvPanel:SetSize(400, 300)

                -- Add title
                local title = storageInvPanel:Add("DLabel")
                title:SetText("Storage")
                title:SetFont("DermaDefault")
                title:Dock(TOP)
                title:SetHeight(25)
            end

            -- Add storage info
            local storageType = storage:getNetVar("storageType", "general")
            local maxWeight = storage:getNetVar("maxWeight", 100)
            local maxItems = storage:getNetVar("maxItems", 50)

            -- Add info labels
            if storageInvPanel then
                local infoLabel = storageInvPanel:Add("DLabel")
                infoLabel:SetText(string.format("Type: %s | Weight: %d | Items: %d",
                storageType, maxWeight, maxItems))
                infoLabel:SetFont("DermaDefault")
                infoLabel:Dock(TOP)
                infoLabel:SetHeight(20)
            end

            print("Storage panel created for " .. storageType .. " storage")
        end)
    ```
]]
function OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
end

--[[
    Purpose:
        Called when a death sound is played
    When Called:
        When a player death sound is triggered
    Parameters:
        client (Player) - The player who died
        deathSound (string) - The sound file that was played
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log death sounds
    hook.Add("OnDeathSoundPlayed", "MyAddon", function(client, deathSound)
        print("Death sound played: " .. deathSound)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track death sounds
    hook.Add("OnDeathSoundPlayed", "TrackDeathSounds", function(client, deathSound)
        MyAddon.deathSounds = MyAddon.deathSounds or {}
            table.insert(MyAddon.deathSounds, {
                player = client:Name(),
                sound = deathSound,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex death sound handling
    hook.Add("OnDeathSoundPlayed", "AdvancedDeathSound", function(client, deathSound)
        -- Log death sound
        lia.log.write("death_sound_played", {
            player = client:SteamID(),
            sound = deathSound,
            timestamp = os.time()
            })

            -- Check for custom death sounds
            local char = client:getChar()
            if char then
                local customSound = char:getData("customDeathSound")
                if customSound and customSound ~= deathSound then
                    client:EmitSound(customSound)
                end
            end

            -- Add death sound to statistics
            local stats = client:getData("deathStats", {sounds = {}})
            stats.sounds[deathSound] = (stats.sounds[deathSound] or 0) + 1
            client:setData("deathStats", stats)
        end)
    ```
]]
function OnDeathSoundPlayed(client, deathSound)
end

--[[
    Purpose:
        Called when fonts are refreshed
    When Called:
        When the font system is reloaded or updated
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log font refresh
    hook.Add("OnFontsRefreshed", "MyAddon", function()
        print("Fonts have been refreshed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Reload custom fonts
    hook.Add("OnFontsRefreshed", "ReloadCustomFonts", function()
        surface.CreateFont("MyAddonFont", {
            font = "Arial",
            size = 24,
            weight = 500
            })
            print("Custom fonts reloaded")
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex font refresh handling
    hook.Add("OnFontsRefreshed", "AdvancedFontRefresh", function()
        -- Clear existing fonts
        MyAddon.fonts = {}

            -- Create custom font set
            local fontSizes = {12, 16, 20, 24, 32, 48}
            for _, size in ipairs(fontSizes) do
                surface.CreateFont("MyAddonFont" .. size, {
                    font = "Arial",
                    size = size,
                    weight = 500,
                    antialias = true
                    })
                end

                -- Update UI elements
                if IsValid(MyAddon.mainPanel) then
                    MyAddon.mainPanel:UpdateFonts()
                end

                print("Advanced font system refreshed")
            end)
    ```
]]
function OnFontsRefreshed()
end

--[[
    Purpose:
        Called when a vendor menu is opened
    When Called:
        When a player opens a vendor's trading interface
    Parameters:
        self (Entity) - The vendor entity
        vendor (table) - The vendor data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor menu opening
    hook.Add("OnOpenVendorMenu", "MyAddon", function(self, vendor)
        print("Vendor menu opened: " .. vendor.name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize vendor menu appearance
    hook.Add("OnOpenVendorMenu", "VendorCustomization", function(self, vendor)
        if vendor.faction == "police" then
            -- Police vendors have special styling
            self:SetColor(Color(0, 0, 255, 255))
            elseif vendor.faction == "medic" then
                -- Medic vendors have different styling
                self:SetColor(Color(255, 255, 255, 255))
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor menu system
    hook.Add("OnOpenVendorMenu", "AdvancedVendorMenu", function(self, vendor)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Check faction restrictions
            local allowedFactions = vendor.allowedFactions
            if allowedFactions and not table.HasValue(allowedFactions, char:getFaction()) then
                LocalPlayer():ChatPrint("Your faction cannot access this vendor")
                return false
            end

            -- Check level requirements
            local requiredLevel = vendor.requiredLevel
            if requiredLevel then
                local charLevel = char:getData("level", 1)
                if charLevel < requiredLevel then
                    LocalPlayer():ChatPrint("You need to be level " .. requiredLevel .. " to access this vendor")
                    return false
                end
            end

            -- Check time restrictions
            local timeRestriction = vendor.timeRestriction
            if timeRestriction then
                local currentHour = tonumber(os.date("%H"))
                if currentHour < timeRestriction.start or currentHour > timeRestriction.end then
                    LocalPlayer():ChatPrint("This vendor is only open from " .. timeRestriction.start .. ":00 to " .. timeRestriction.end .. ":00")
                    return false
                end
            end

            -- Apply faction-specific discounts
            local faction = char:getFaction()
            local discounts = {
            ["police"] = 0.1, -- 10% discount
            ["medic"] = 0.05, -- 5% discount
            ["citizen"] = 0.0  -- No discount
        }

        local discount = discounts[faction] or 0
        vendor.discount = discount

        -- Update vendor appearance based on faction
        if faction == "police" then
            self:SetColor(Color(0, 0, 255, 255))
            elseif faction == "medic" then
                self:SetColor(Color(255, 255, 255, 255))
                else
                    self:SetColor(Color(255, 255, 255, 255))
                end

                -- Log vendor access
                print(string.format("%s accessed vendor %s (Faction: %s)",
                LocalPlayer():Name(), vendor.name, faction))
            end)
    ```
]]
function OnOpenVendorMenu(self, vendor)
end

--[[
    Purpose:
        Called when a pain sound is played
    When Called:
        When a player pain sound is triggered
    Parameters:
        client (Player) - The player who is in pain
        painSound (string) - The sound file that was played
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log pain sounds
    hook.Add("OnPainSoundPlayed", "MyAddon", function(client, painSound)
        print("Pain sound played: " .. painSound)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track pain sounds
    hook.Add("OnPainSoundPlayed", "TrackPainSounds", function(client, painSound)
        MyAddon.painSounds = MyAddon.painSounds or {}
            table.insert(MyAddon.painSounds, {
                player = client:Name(),
                sound = painSound,
                time = os.time()
                })
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex pain sound handling
    hook.Add("OnPainSoundPlayed", "AdvancedPainSound", function(client, painSound)
        -- Log pain sound
        lia.log.write("pain_sound_played", {
            player = client:SteamID(),
            sound = painSound,
            timestamp = os.time()
            })

            -- Check for custom pain sounds
            local char = client:getChar()
            if char then
                local customSound = char:getData("customPainSound")
                if customSound and customSound ~= painSound then
                    client:EmitSound(customSound)
                end
            end

            -- Add pain sound to statistics
            local stats = client:getData("painStats", {sounds = {}})
            stats.sounds[painSound] = (stats.sounds[painSound] or 0) + 1
            client:setData("painStats", stats)
        end)
    ```
]]
function OnPainSoundPlayed(client, painSound)
end

--[[
    Purpose:
        Called when player data is synchronized
    When Called:
        When player data is synced between client and server
    Parameters:
        player (Player) - The player whose data was synced
        lastID (number) - The last character ID that was synced
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log data sync
    hook.Add("OnPlayerDataSynced", "MyAddon", function(player, lastID)
        print("Player data synced for " .. player:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update UI after sync
    hook.Add("OnPlayerDataSynced", "UISync", function(player, lastID)
        if player == LocalPlayer() then
            -- Update character information
            local char = player:getChar()
            if char then
                -- Update character display
                hook.Run("CharLoaded", char:getID())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex data sync system
    hook.Add("OnPlayerDataSynced", "AdvancedDataSync", function(player, lastID)
        if player == LocalPlayer() then
            local char = player:getChar()
            if not char then return end

                -- Update character information
                local charData = char:getData()

                -- Update UI elements
                if IsValid(lia.gui.info) then
                    lia.gui.info:updateCharacterInfo()
                end

                -- Update inventory display
                if IsValid(lia.gui.inv1) then
                    lia.gui.inv1:updateInventory()
                end

                -- Update faction display
                local faction = char:getFaction()
                if faction then
                    player:SetTeam(faction)
                end

                -- Update character model
                local model = char:getModel()
                if model then
                    player:SetModel(model)
                end

                -- Update character attributes
                local attributes = char:getAttribs()
                for attr, value in pairs(attributes) do
                    player:setNetVar("attr_" .. attr, value)
                end

                -- Update character money
                local money = char:getMoney()
                player:setNetVar("money", money)

                -- Update character level
                local level = char:getData("level", 1)
                player:setNetVar("level", level)

                -- Update character experience
                local experience = char:getData("experience", 0)
                player:setNetVar("experience", experience)

                -- Update character health
                local health = char:getData("health", 100)
                player:SetHealth(health)

                -- Update character armor
                local armor = char:getData("armor", 0)
                player:SetArmor(armor)

                -- Update character stamina
                local stamina = char:getData("stamina", 100)
                player:setNetVar("stamina", stamina)

                -- Notify other systems
                hook.Run("CharLoaded", char:getID())

                -- Log sync
                print("Player data synced for " .. player:Name() .. " (Char ID: " .. lastID .. ")")
            end
        end)
    ```
]]
function OnPlayerDataSynced(player, lastID)
end

--[[
    Purpose:
        Called when the UI theme is changed
    When Called:
        When the active theme is switched
    Parameters:
        themeName (string) - The name of the new theme
        themeData (table) - The theme configuration data
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log theme changes
    hook.Add("OnThemeChanged", "MyAddon", function(themeName, themeData)
        print("Theme changed to: " .. themeName)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update UI colors
    hook.Add("OnThemeChanged", "UpdateUIColors", function(themeName, themeData)
        if themeData.colors then
            MyAddon.primaryColor = themeData.colors.primary
            MyAddon.secondaryColor = themeData.colors.secondary
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex theme change handling
    hook.Add("OnThemeChanged", "AdvancedThemeChange", function(themeName, themeData)
        -- Update all UI elements
        if IsValid(MyAddon.mainPanel) then
            MyAddon.mainPanel:SetBackgroundColor(themeData.colors.background)
        end

        -- Reload custom fonts
        if themeData.fonts then
            for fontName, fontData in pairs(themeData.fonts) do
                surface.CreateFont(fontName, fontData)
            end
        end

        -- Save theme preference
        lia.data.set("preferredTheme", themeName)

        -- Notify user
        lia.util.notify("Theme changed to " .. themeName)
    end)
    ```
]]
function OnThemeChanged(themeName, themeData)
end

--[[
    Purpose:
        Called when the admin stick UI is opened
    When Called:
        When an admin opens the admin stick interface
    Parameters:
        tgt (Entity) - The target entity being examined
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log admin stick usage
    hook.Add("OpenAdminStickUI", "MyAddon", function(tgt)
        print("Admin stick UI opened for " .. tostring(tgt))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize admin stick display
    hook.Add("OpenAdminStickUI", "CustomAdminStick", function(tgt)
        if IsValid(tgt) and tgt:IsPlayer() then
            local char = tgt:getChar()
            if char then
                print("Examining player: " .. char:getName())
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex admin stick functionality
    hook.Add("OpenAdminStickUI", "AdvancedAdminStick", function(tgt)
        if not IsValid(tgt) then return end

            -- Store target for later use
            MyAddon.currentTarget = tgt

            -- Add custom information to admin stick
            if tgt:IsPlayer() then
                local char = tgt:getChar()
                if char then
                    hook.Run("AddToAdminStickHUD", LocalPlayer(), tgt, {
                        "Character: " .. char:getName(),
                        "Faction: " .. char:getFaction(),
                        "Class: " .. char:getClass()
                        })
                    end
                end

                -- Log admin stick usage
                lia.log.write("admin_stick_opened", {
                    admin = LocalPlayer():SteamID(),
                    target = IsValid(tgt) and tgt:EntIndex() or "Invalid",
                    timestamp = os.time()
                    })
                end)
    ```
]]
function OpenAdminStickUI(tgt)
end

--[[
    Purpose:
        Called to paint/render an item
    When Called:
        When an item needs custom rendering
    Parameters:
        item (Item) - The item being painted
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Draw item name
    hook.Add("PaintItem", "MyAddon", function(item)
        draw.SimpleText(item.name, "DermaDefault", 10, 10, Color(255, 255, 255))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Draw item with quality color
    hook.Add("PaintItem", "PaintItemQuality", function(item)
        local quality = item:getData("quality", "common")
        local color = Color(255, 255, 255)

        if quality == "rare" then
            color = Color(0, 100, 255)
            elseif quality == "epic" then
                color = Color(150, 0, 255)
            end

            draw.SimpleText(item.name, "DermaDefault", 10, 10, color)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex item rendering
    hook.Add("PaintItem", "AdvancedItemPaint", function(item)
        local x, y = 10, 10

        -- Draw item name with quality color
        local quality = item:getData("quality", "common")
        local qualityColors = {
        ["common"] = Color(150, 150, 150),
        ["uncommon"] = Color(0, 200, 0),
        ["rare"] = Color(0, 100, 255),
        ["epic"] = Color(150, 0, 255),
        ["legendary"] = Color(255, 200, 0)
    }

    local color = qualityColors[quality] or Color(255, 255, 255)
    draw.SimpleText(item.name, "DermaDefaultBold", x, y, color)

    -- Draw durability
    local durability = item:getData("durability", 100)
    y = y + 20
    draw.SimpleText("Durability: " .. durability .. "%", "DermaDefault", x, y, Color(255, 255, 255))

    -- Draw quantity
    local quantity = item:getData("quantity", 1)
    if quantity > 1 then
        y = y + 15
        draw.SimpleText("Quantity: x" .. quantity, "DermaDefault", x, y, Color(255, 255, 255))
    end
    end)
    ```
]]
function PaintItem(item)
end

--[[
    Purpose:
        Called to populate the admin stick menu
    When Called:
        When building the admin stick context menu
    Parameters:
        tempMenu (Menu) - The menu being populated
        tgt (Entity) - The target entity
        stores (table) - A table containing references to existing submenu categories
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic option
    hook.Add("PopulateAdminStick", "MyAddon", function(tempMenu, tgt, stores)
        tempMenu:AddOption("Custom Action", function()
        print("Custom action performed")
    end)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add conditional options
    hook.Add("PopulateAdminStick", "ConditionalAdminOptions", function(tempMenu, tgt, stores)
        if IsValid(tgt) and tgt:IsPlayer() then
            tempMenu:AddOption("Teleport To", function()
            RunConsoleCommand("lia_plyteleporttome", tgt:SteamID())
        end)
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex admin stick menu
    hook.Add("PopulateAdminStick", "AdvancedAdminStick", function(tempMenu, tgt, stores)
        if not IsValid(tgt) then return end

            -- Player options
            if tgt:IsPlayer() then
                tempMenu:AddOption("Teleport To", function()
                RunConsoleCommand("lia_plyteleporttome", tgt:SteamID())
            end)

            tempMenu:AddOption("Kick", function()
            RunConsoleCommand("lia_kick", tgt:SteamID())
        end)

        tempMenu:AddOption("Ban", function()
        RunConsoleCommand("lia_ban", tgt:SteamID())
    end)
    end

    -- Entity options
    tempMenu:AddOption("Remove", function()
    RunConsoleCommand("lia_removeentity", tgt:EntIndex())
    end)

    tempMenu:AddOption("Copy Model", function()
    SetClipboardText(tgt:GetModel())
    end)
    end)
    ```

    Using Stores to Add to Existing Categories:
    ```lua
    -- Add to existing submenu categories
    hook.Add("PopulateAdminStick", "AddToExistingMenus", function(tempMenu, tgt, stores)
        -- Add to existing teleportation submenu
        if stores and stores["teleportation"] and IsValid(stores["teleportation"]) then
            stores["teleportation"]:AddOption("Custom Teleport", function()
            RunConsoleCommand("lia_customteleport", tgt:SteamID())
        end)
    end

    -- Add to existing utility commands submenu
    if stores and stores["utility_commands"] and IsValid(stores["utility_commands"]) then
        stores["utility_commands"]:AddOption("Custom Utility", function()
        print("Custom utility command")
    end)
    end
    end)
    ```
]]
function PopulateAdminStick(tempMenu, tgt, stores)
end

--[[
    Purpose:
        Called to add custom list options to the admin stick menu
    When Called:
        When building the admin stick context menu, before it's populated
    Parameters:
        tgt (Entity) - The target entity
        lists (table) - The table to populate with list data
    Returns:
        None (modified by reference)
    Realm:
        Client
    List Data Structure:
        Each entry in lists should be a table with:
        - name (string) - The display name of the list
        - category (string) - The category key (e.g., "characterManagement", "utility")
        - subcategory (string) - The subcategory key within the category
        - items (table) - Array of items to display

        Each item in items should be a table with:
        - name (string) - The display name of the option
        - callback (function) - Function to execute when clicked (receives target and item as parameters)
        - icon (string, optional) - Icon path to display
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a list of custom options
    hook.Add("GetAdminStickLists", "MyAddon", function(tgt, lists)
        table.insert(lists, {
            name = "Custom Weapons",
            category = "characterManagement",
            subcategory = "items",
            items = {
                { name = "Gun 1", callback = function(target, item) RunConsoleCommand("say", "/give", target:SteamID(), "weapon_pistol") end },
                    { name = "Gun 2", callback = function(target, item) RunConsoleCommand("say", "/give", target:SteamID(), "weapon_rifle") end }
                    }
                    })
                end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add conditional list based on target
    hook.Add("GetAdminStickLists", "ConditionalLists", function(tgt, lists)
        if tgt:IsPlayer() and tgt:getChar() then
            table.insert(lists, {
                name = "Quick Factions",
                category = "characterManagement",
                subcategory = "factions",
                items = {
                    {
                        name = "Police",
                        icon = "icon16/user_police.png",
                        callback = function(target, item)
                        RunConsoleCommand("say", "/setfaction", target:SteamID(), "police")
                    end
                    },
                    {
                        name = "Medic",
                        icon = "icon16/user_medical.png",
                        callback = function(target, item)
                        RunConsoleCommand("say", "/setfaction", target:SteamID(), "medic")
                    end
                }
            }
            })
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Add multiple lists with dynamic data
    hook.Add("GetAdminStickLists", "AdvancedLists", function(tgt, lists)
        if not IsValid(tgt) or not tgt:IsPlayer() then return end

            -- Add available ranks based on target's class
            local targetChar = tgt:getChar()
            if targetChar then
                local targetClass = targetChar:getClass()
                local ranks = lia.ranking.rankTable[targetClass]
                if ranks then
                    local rankItems = {}
                    for rankKey, rankData in pairs(ranks) do
                        table.insert(rankItems, {
                            name = rankData.RankName or rankKey,
                            icon = "icon16/user_green.png",
                            callback = function(target, item)
                            local cmd = 'say /setrank ' .. QuoteArgs(GetIdentifier(target), rankKey)
                            LocalPlayer():ConCommand(cmd)
                        end
                        })
                    end

                    table.insert(lists, {
                        name = "Ranks",
                        category = "characterManagement",
                        subcategory = "ranking",
                        items = rankItems
                        })
                    end
                end
            end)
    ```
]]
function GetAdminStickLists(tgt, lists)
end

--[[
    Purpose:
        Called to register custom subcategories for admin stick menu categories
    When Called:
        During admin stick menu generation, before menu population
    Parameters:
        categories (table) - The categories table to modify by reference
    Returns:
        None (modified by reference)
    Realm:
        Client
    Category Structure:
        categories[categoryKey] should be a table with:
        - name (string) - Display name of the category
        - icon (string) - Icon path for the category
        - subcategories (table) - Table of subcategories

        Each subcategory in subcategories[subKey] should be a table with:
        - name (string) - Display name of the subcategory
        - icon (string) - Icon path for the subcategory
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a single subcategory to an existing category
    hook.Add("RegisterAdminStickSubcategories", "MyAddonSubcategories", function(categories)
        if categories.characterManagement then
            categories.characterManagement.subcategories = categories.characterManagement.subcategories or {}
                categories.characterManagement.subcategories.myAddon = {
                    name = "My Addon Tools",
                    icon = "icon16/plugin.png"
                }
            end
        end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple subcategories and ensure category exists
    hook.Add("RegisterAdminStickSubcategories", "BankingSubcategories", function(categories)
        -- Ensure banking category exists
        categories.banking = categories.banking or {
            name = "Banking",
            icon = "icon16/money.png",
            subcategories = {}
            }

            -- Add subcategories
            categories.banking.subcategories.admin = {
                name = "Admin Banking",
                icon = "icon16/shield.png"
            }
            categories.banking.subcategories.player = {
                name = "Player Banking",
                icon = "icon16/user_green.png"
            }
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex addon with multiple categories and subcategories
    hook.Add("RegisterAdminStickSubcategories", "ComplexAddon", function(categories)
        -- Create main category
        categories.myComplexAddon = {
            name = "My Complex Addon",
            icon = "icon16/application.png",
            subcategories = {
                management = {
                    name = "Management",
                    icon = "icon16/cog.png"
                    },
                    statistics = {
                        name = "Statistics",
                        icon = "icon16/chart_bar.png"
                        },
                        maintenance = {
                            name = "Maintenance",
                            icon = "icon16/wrench.png"
                        }
                    }
                }

                -- Add to existing category
                if categories.characterManagement then
                    categories.characterManagement.subcategories.myAddon = {
                        name = "My Addon Integration",
                        icon = "icon16/plugin_add.png"
                    }
                end
            end)
    ```
]]
function RegisterAdminStickSubcategories(categories)
end

--[[
    Purpose:
        Called to populate admin tabs
    When Called:
        When building the admin panel tabs
    Parameters:
        adminPages (table) - The admin pages table
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic tab
    hook.Add("PopulateAdminTabs", "MyAddon", function(adminPages)
        adminPages["Custom"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        return panel
    end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add tab with content
    hook.Add("PopulateAdminTabs", "CustomAdminTab", function(adminPages)
        adminPages["Custom Tools"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)

        local button = panel:Add("DButton")
        button:SetText("Custom Action")
        button:Dock(TOP)
        button.DoClick = function()
        RunConsoleCommand("lia_customaction")
    end

    return panel
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex admin tab system
    hook.Add("PopulateAdminTabs", "AdvancedAdminTabs", function(adminPages)
        adminPages["Custom Management"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        panel:SetBackgroundColor(Color(50, 50, 50))

        -- Add title
        local title = panel:Add("DLabel")
        title:SetText("Custom Management Tools")
        title:SetFont("DermaLarge")
        title:Dock(TOP)
        title:SetHeight(30)

        -- Add buttons
        local btnPanel = panel:Add("DPanel")
        btnPanel:Dock(TOP)
        btnPanel:SetHeight(200)

        local teleportBtn = btnPanel:Add("DButton")
        teleportBtn:SetText("Teleport All Players")
        teleportBtn:Dock(TOP)
        teleportBtn:SetHeight(30)
        teleportBtn.DoClick = function()
        RunConsoleCommand("lia_teleportall")
    end

    local healBtn = btnPanel:Add("DButton")
    healBtn:SetText("Heal All Players")
    healBtn:Dock(TOP)
    healBtn:SetHeight(30)
    healBtn.DoClick = function()
    RunConsoleCommand("lia_healall")
    end

    return panel
    end
    end)
    ```
]]
function PopulateAdminTabs(adminPages)
end

--[[
    Purpose:
        Called to populate configuration buttons
    When Called:
        When building the configuration menu
    Parameters:
        pages (table) - The configuration pages table
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic config page
    hook.Add("PopulateConfigurationButtons", "MyAddon", function(pages)
        pages["Custom"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        return panel
    end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add config page with options
    hook.Add("PopulateConfigurationButtons", "CustomConfigPage", function(pages)
        pages["My Settings"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)

        local checkbox = panel:Add("DCheckBoxLabel")
        checkbox:SetText("Enable Feature")
        checkbox:Dock(TOP)
        checkbox:SetValue(GetConVar("myfeature_enabled"):GetBool())
        checkbox.OnChange = function(self, val)
        RunConsoleCommand("myfeature_enabled", val and "1" or "0")
    end

    return panel
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex configuration system
    hook.Add("PopulateConfigurationButtons", "AdvancedConfigSystem", function(pages)
        pages["Advanced Settings"] = function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        panel:SetBackgroundColor(Color(50, 50, 50))

        -- Add title
        local title = panel:Add("DLabel")
        title:SetText("Advanced Configuration")
        title:SetFont("DermaLarge")
        title:Dock(TOP)
        title:SetHeight(30)

        -- Add settings
        local settingsPanel = panel:Add("DPanel")
        settingsPanel:Dock(FILL)

        -- Enable feature checkbox
        local enableCheckbox = settingsPanel:Add("DCheckBoxLabel")
        enableCheckbox:SetText("Enable Advanced Features")
        enableCheckbox:Dock(TOP)
        enableCheckbox:SetValue(GetConVar("advanced_enabled"):GetBool())
        enableCheckbox.OnChange = function(self, val)
        RunConsoleCommand("advanced_enabled", val and "1" or "0")
    end

    -- Slider for value
    local slider = settingsPanel:Add("DNumSlider")
    slider:SetText("Feature Intensity")
    slider:Dock(TOP)
    slider:SetMin(0)
    slider:SetMax(100)
    slider:SetValue(GetConVar("advanced_intensity"):GetInt())
    slider.OnValueChanged = function(self, val)
    RunConsoleCommand("advanced_intensity", tostring(math.floor(val)))
    end

    return panel
    end
    end)
    ```
]]
function PopulateConfigurationButtons(pages)
end

--[[
    Purpose:
        Called to populate inventory items
    When Called:
        When building the inventory item list
    Parameters:
        pnlContent (Panel) - The content panel
        tree (Panel) - The tree view panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic category
    hook.Add("PopulateInventoryItems", "MyAddon", function(pnlContent, tree)
        local node = tree:AddNode("Custom Items")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add category with items
    hook.Add("PopulateInventoryItems", "CustomInventoryItems", function(pnlContent, tree)
        local node = tree:AddNode("Custom Items")

        for _, item in pairs(lia.item.list) do
            if item.category == "custom" then
                local itemNode = node:AddNode(item.name)
                itemNode.DoClick = function()
                -- Show item details
            end
        end
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory population
    hook.Add("PopulateInventoryItems", "AdvancedInventoryPopulation", function(pnlContent, tree)
        -- Group items by custom category
        local categories = {}
        for _, item in pairs(lia.item.list) do
            local category = item.customCategory or "Other"
            categories[category] = categories[category] or {}
                table.insert(categories[category], item)
            end

            -- Create nodes for each category
            for category, items in pairs(categories) do
                local categoryNode = tree:AddNode(category)
                categoryNode:SetIcon("icon16/folder.png")

                -- Add items to category
                for _, item in ipairs(items) do
                    local itemNode = categoryNode:AddNode(item.name)
                    itemNode:SetIcon("icon16/box.png")
                    itemNode.DoClick = function()
                    -- Show item details in content panel
                    pnlContent:Clear()

                    local itemPanel = pnlContent:Add("DPanel")
                    itemPanel:Dock(FILL)

                    local nameLabel = itemPanel:Add("DLabel")
                    nameLabel:SetText(item.name)
                    nameLabel:SetFont("DermaLarge")
                    nameLabel:Dock(TOP)

                    local descLabel = itemPanel:Add("DLabel")
                    descLabel:SetText(item.desc or "No description")
                    descLabel:Dock(TOP)
                end
            end
        end
    end)
    ```
]]
function PopulateInventoryItems(pnlContent, tree)
end

--[[
    Purpose:
        Called after drawing the inventory
    When Called:
        After the inventory UI has been rendered
    Parameters:
        mainPanel (Panel) - The main inventory panel
        parentPanel (Panel) - The parent panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log inventory draw
    hook.Add("PostDrawInventory", "MyAddon", function(mainPanel, parentPanel)
        print("Inventory drawn")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom UI elements
    hook.Add("PostDrawInventory", "CustomInventoryUI", function(mainPanel, parentPanel)
        if IsValid(mainPanel) then
            local label = mainPanel:Add("DLabel")
            label:SetText("Custom Inventory")
            label:Dock(BOTTOM)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex inventory UI customization
    hook.Add("PostDrawInventory", "AdvancedInventoryUI", function(mainPanel, parentPanel)
        if not IsValid(mainPanel) then return end

            local char = LocalPlayer():getChar()
            if not char then return end

                -- Add weight display
                local inventory = char:getInv()
                if inventory then
                    local weight = inventory:getData("weight", 0)
                    local maxWeight = inventory:getData("maxWeight", 100)

                    local weightLabel = mainPanel:Add("DLabel")
                    weightLabel:SetText(string.format("Weight: %d / %d", weight, maxWeight))
                    weightLabel:Dock(BOTTOM)
                    weightLabel:SetHeight(20)
                end
            end)
    ```
]]
function PostDrawInventory(mainPanel, parentPanel)
end

--[[
    Purpose:
        Called after fonts are loaded
    When Called:
        After the font system has been initialized
    Parameters:
        mainFont (string) - The main font name
        configuredFont (string) - The configured font name
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log font load
    hook.Add("PostLoadFonts", "MyAddon", function(mainFont, configuredFont)
        print("Fonts loaded: " .. mainFont)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Create custom fonts
    hook.Add("PostLoadFonts", "CreateCustomFonts", function(mainFont, configuredFont)
        surface.CreateFont("MyCustomFont", {
            font = mainFont,
            size = 24,
            weight = 500
            })
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex font system
    hook.Add("PostLoadFonts", "AdvancedFontSystem", function(mainFont, configuredFont)
        -- Create custom fonts
        local fontSizes = {16, 20, 24, 28, 32}
        for _, size in ipairs(fontSizes) do
            surface.CreateFont("MyCustomFont_" .. size, {
                font = mainFont,
                size = size,
                weight = 500,
                antialias = true
                })
            end

            -- Create bold variants
            for _, size in ipairs(fontSizes) do
                surface.CreateFont("MyCustomFontBold_" .. size, {
                    font = mainFont,
                    size = size,
                    weight = 700,
                    antialias = true
                    })
                end

                print("Custom fonts created")
            end)
    ```
]]
function PostLoadFonts(mainFont, configuredFont)
end

--[[
    Purpose:
        Called before drawing the physgun beam
    When Called:
        Before the physgun beam is rendered
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log physgun beam
    hook.Add("PreDrawPhysgunBeam", "MyAddon", function()
        print("Drawing physgun beam")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize beam appearance
    hook.Add("PreDrawPhysgunBeam", "CustomizeBeam", function()
        local client = LocalPlayer()
        if IsValid(client) and client:GetActiveWeapon():GetClass() == "weapon_physgun" then
            -- Custom beam color
            render.SetColorMaterial()
            render.DrawBeam(client:GetShootPos(), client:GetEyeTrace().HitPos, 8, 0, 1, Color(255, 0, 0, 255))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex physgun beam system
    hook.Add("PreDrawPhysgunBeam", "AdvancedPhysgunBeam", function()
        local client = LocalPlayer()
        if not IsValid(client) then return end

            local weapon = client:GetActiveWeapon()
            if not IsValid(weapon) or weapon:GetClass() ~= "weapon_physgun" then return end

                local trace = client:GetEyeTrace()
                if not trace.Hit then return end

                    local target = trace.Entity
                    if not IsValid(target) then return end

                        -- Different colors for different entities
                        local color = Color(255, 255, 255, 255)
                        if target:IsPlayer() then
                            color = Color(255, 0, 0, 255)
                            elseif target:IsVehicle() then
                                color = Color(0, 255, 0, 255)
                                elseif target:GetClass():find("prop_") then
                                    color = Color(0, 0, 255, 255)
                                end

                                -- Draw custom beam
                                render.SetColorMaterial()
                                render.DrawBeam(client:GetShootPos(), trace.HitPos, 8, 0, 1, color)
                            end)
    ```
]]
function PreDrawPhysgunBeam()
end

--[[
    Purpose:
        Called to refresh fonts
    When Called:
        When the font system needs to be refreshed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log font refresh
    hook.Add("RefreshFonts", "MyAddon", function()
        print("Fonts refreshed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Recreate custom fonts
    hook.Add("RefreshFonts", "RecreateCustomFonts", function()
        surface.CreateFont("MyCustomFont", {
            font = "Arial",
            size = 24,
            weight = 500
            })
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex font refresh system
    hook.Add("RefreshFonts", "AdvancedFontRefresh", function()
        -- Clear existing fonts
        for k, v in pairs(surface.GetFonts()) do
            if string.find(k, "MyCustom") then
                surface.CreateFont(k, {
                    font = "Arial",
                    size = 24,
                    weight = 500
                    })
                end
            end

            -- Create new fonts with current settings
            local mainFont = GetConVar("lia_font"):GetString()
            for i = 16, 32, 4 do
                surface.CreateFont("MyCustomFont_" .. i, {
                    font = mainFont,
                    size = i,
                    weight = 500,
                    antialias = true
                    })
                end
            end)
    ```
]]
function RefreshFonts()
end

--[[
    Purpose:
        Called when a PAC3 part is removed
    When Called:
        When a PAC3 part is detached from a player
    Parameters:
        client (Player) - The player losing the part
        id (string) - The part ID
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log part removal
    hook.Add("RemovePart", "MyAddon", function(client, id)
        print(client:Name() .. " removed part: " .. id)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track part usage
    hook.Add("RemovePart", "TrackPartUsage", function(client, id)
        local char = client:getChar()
        if char then
            local partsUsed = char:getData("partsUsed", {})
            partsUsed[id] = (partsUsed[id] or 0) + 1
            char:setData("partsUsed", partsUsed)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex part removal system
    hook.Add("RemovePart", "AdvancedPartRemoval", function(client, id)
        local char = client:getChar()
        if not char then return end

            -- Track part usage
            local partsUsed = char:getData("partsUsed", {})
            partsUsed[id] = (partsUsed[id] or 0) + 1
            char:setData("partsUsed", partsUsed)

            -- Log to database
            lia.db.query("INSERT INTO part_logs (timestamp, charid, partid, action) VALUES (?, ?, ?, ?)",
            os.time(), char:getID(), id, "removed")

            -- Notify nearby players
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= client and ply:GetPos():Distance(client:GetPos()) < 500 then
                    ply:ChatPrint(client:Name() .. " removed a part")
                end
            end
        end)
    ```
]]
function RemovePart(client, id)
end

--[[
    Purpose:
        Called to reset the character panel
    When Called:
        When the character panel needs to be refreshed
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log panel reset
    hook.Add("ResetCharacterPanel", "MyAddon", function()
        print("Character panel reset")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clear custom data
    hook.Add("ResetCharacterPanel", "ClearCustomData", function()
        MyAddon.selectedCharacter = nil
        MyAddon.panelData = {}
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex panel reset system
    hook.Add("ResetCharacterPanel", "AdvancedPanelReset", function()
        -- Clear custom data
        MyAddon.selectedCharacter = nil
        MyAddon.panelData = {}
            MyAddon.customButtons = {}

                -- Reset UI state
                if IsValid(MyAddon.customPanel) then
                    MyAddon.customPanel:Remove()
                    MyAddon.customPanel = nil
                end

                -- Rebuild panel
                timer.Simple(0.1, function()
                MyAddon.RebuildPanel()
            end)
        end)
    ```
]]
function ResetCharacterPanel()
end

--[[
    Purpose:
        Called when the scoreboard is closed
    When Called:
        When the scoreboard UI is closed
    Parameters:
        self (Panel) - The scoreboard panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log scoreboard close
    hook.Add("ScoreboardClosed", "MyAddon", function(self)
        print("Scoreboard closed")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up scoreboard data
    hook.Add("ScoreboardClosed", "CleanupScoreboard", function(self)
        MyAddon.scoreboardData = {}
            MyAddon.selectedPlayer = nil
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard cleanup
    hook.Add("ScoreboardClosed", "AdvancedScoreboardCleanup", function(self)
        -- Clean up data
        MyAddon.scoreboardData = {}
            MyAddon.selectedPlayer = nil
            MyAddon.customPanels = {}

                -- Save scoreboard state
                local char = LocalPlayer():getChar()
                if char then
                    char:setData("lastScoreboardClose", os.time())
                end

                -- Notify other systems
                hook.Run("CustomScoreboardClosed", self)
            end)
    ```
]]
function ScoreboardClosed(self)
end

--[[
    Purpose:
        Called when the scoreboard is opened
    When Called:
        When the scoreboard UI is displayed
    Parameters:
        self (Panel) - The scoreboard panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log scoreboard open
    hook.Add("ScoreboardOpened", "MyAddon", function(self)
        print("Scoreboard opened")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Initialize scoreboard data
    hook.Add("ScoreboardOpened", "InitializeScoreboard", function(self)
        MyAddon.scoreboardData = {
            players = player.GetAll(),
            lastUpdate = os.time()
        }
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard initialization
    hook.Add("ScoreboardOpened", "AdvancedScoreboardInit", function(self)
        -- Initialize data
        MyAddon.scoreboardData = {
            players = player.GetAll(),
            lastUpdate = os.time(),
            customData = {}
            }

            -- Load custom panels
            MyAddon.customPanels = {}

                -- Add custom buttons
                local customBtn = self:Add("DButton")
                customBtn:SetText("Custom Action")
                customBtn:Dock(TOP)
                customBtn.DoClick = function()
                hook.Run("CustomScoreboardAction")
            end

            -- Notify other systems
            hook.Run("CustomScoreboardOpened", self)
        end)
    ```
]]
function ScoreboardOpened(self)
end

--[[
    Purpose:
        Called when a scoreboard row is created
    When Called:
        When a player row is added to the scoreboard
    Parameters:
        slot (Panel) - The row panel
        ply (Player) - The player for the row
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log row creation
    hook.Add("ScoreboardRowCreated", "MyAddon", function(slot, ply)
        print("Scoreboard row created for " .. ply:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Customize row appearance
    hook.Add("ScoreboardRowCreated", "CustomizeRow", function(slot, ply)
        local char = ply:getChar()
        if char then
            local faction = char:getFaction()
            if faction == "police" then
                slot:SetBackgroundColor(Color(0, 0, 255, 50))
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard row customization
    hook.Add("ScoreboardRowCreated", "AdvancedRowCustomization", function(slot, ply)
        local char = ply:getChar()
        if not char then return end

            -- Faction-based coloring
            local faction = char:getFaction()
            local factionColors = {
            ["police"] = Color(0, 0, 255, 50),
            ["medic"] = Color(0, 255, 0, 50),
            ["criminal"] = Color(255, 0, 0, 50)
        }

        local color = factionColors[faction] or Color(255, 255, 255, 50)
        slot:SetBackgroundColor(color)

        -- Add custom elements
        local customLabel = slot:Add("DLabel")
        customLabel:SetText("[" .. faction .. "]")
        customLabel:Dock(RIGHT)
        customLabel:SetTextColor(Color(255, 255, 255))
    end)
    ```
]]
function ScoreboardRowCreated(slot, ply)
end

--[[
    Purpose:
        Called when a scoreboard row is removed
    When Called:
        When a player row is removed from the scoreboard
    Parameters:
        self (Panel) - The scoreboard panel
        ply (Player) - The player whose row was removed
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log row removal
    hook.Add("ScoreboardRowRemoved", "MyAddon", function(self, ply)
        print("Scoreboard row removed for " .. ply:Name())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up row data
    hook.Add("ScoreboardRowRemoved", "CleanupRowData", function(self, ply)
        MyAddon.playerData[ply:SteamID()] = nil
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex row cleanup
    hook.Add("ScoreboardRowRemoved", "AdvancedRowCleanup", function(self, ply)
        -- Clean up player data
        MyAddon.playerData[ply:SteamID()] = nil

        -- Remove custom elements
        if IsValid(MyAddon.customElements[ply:SteamID()]) then
            MyAddon.customElements[ply:SteamID()]:Remove()
            MyAddon.customElements[ply:SteamID()] = nil
        end

        -- Update scoreboard statistics
        MyAddon.UpdateStats()
    end)
    ```
]]
function ScoreboardRowRemoved(self, ply)
end

--[[
    Purpose:
        Called to set up PAC3 data from items
    When Called:
        When configuring PAC3 data based on equipped items
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log PAC3 setup
    hook.Add("SetupPACDataFromItems", "MyAddon", function()
        print("Setting up PAC3 data from items")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Apply item-based PAC3 data
    hook.Add("SetupPACDataFromItems", "ApplyItemPAC3", function()
        local char = LocalPlayer():getChar()
        if char then
            local inv = char:getInv()
            if inv then
                for _, item in pairs(inv:getItems()) do
                    if item:getData("equipped", false) and item.pacData then
                        hook.Run("AttachPart", LocalPlayer(), item.pacData)
                    end
                end
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex PAC3 item system
    hook.Add("SetupPACDataFromItems", "AdvancedPAC3Items", function()
        local char = LocalPlayer():getChar()
        if not char then return end

            local inv = char:getInv()
            if not inv then return end

                -- Clear existing PAC3 data
                hook.Run("RemoveAllParts", LocalPlayer())

                -- Apply item-based PAC3 data
                for _, item in pairs(inv:getItems()) do
                    if item:getData("equipped", false) then
                        local pacData = item:getData("pacData")
                        if pacData then
                            hook.Run("AttachPart", LocalPlayer(), pacData)
                        end

                        -- Apply item-specific PAC3 effects
                        if item.pacEffects then
                            for _, effect in ipairs(item.pacEffects) do
                                hook.Run("ApplyPACEffect", LocalPlayer(), effect)
                            end
                        end
                    end
                end

                -- Apply faction-specific PAC3 data
                local faction = char:getFaction()
                local factionPAC = lia.faction.indices[faction] and lia.faction.indices[faction].pacData
                if factionPAC then
                    hook.Run("AttachPart", LocalPlayer(), factionPAC)
                end
            end)
    ```
]]
function SetupPACDataFromItems()
end

--[[
    Purpose:
        Called to determine if the quick menu should be shown when the context menu opens
    When Called:
        When the context menu (right-click menu) is opened
    Parameters:
        None
    Returns:
        boolean - Return false to prevent the quick menu from opening, return nil or true to allow it
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Disable quick menu completely
    hook.Add("ShouldShowQuickMenu", "DisableQuickMenu", function()
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Disable quick menu for specific players
    hook.Add("ShouldShowQuickMenu", "RestrictQuickMenu", function()
        if LocalPlayer():GetUserGroup() == "user" then
            return false
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Conditional quick menu based on game state
    hook.Add("ShouldShowQuickMenu", "ConditionalQuickMenu", function()
        local char = LocalPlayer():getChar()
        if not char then return false end

    -- Only show for certain factions
    local allowedFactions = {"police", "medic"}
    return table.HasValue(allowedFactions, char:getFaction())
    end)
    ```

    -- Note: The radio module automatically prevents the quick menu when holding a radio (radio or hololink_radio weapons)
]]
function ShouldShowQuickMenu()
end

--[[
    Purpose:
        Called to set up the quick menu
    When Called:
        When initializing the quick access menu
    Parameters:
        self (Panel) - The quick menu panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log quick menu setup
    hook.Add("SetupQuickMenu", "MyAddon", function(self)
        print("Setting up quick menu")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add custom buttons
    hook.Add("SetupQuickMenu", "AddCustomButtons", function(self)
        local customBtn = self:Add("DButton")
        customBtn:SetText("Custom Action")
        customBtn:Dock(TOP)
        customBtn.DoClick = function()
        print("Custom action clicked")
    end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex quick menu system
    hook.Add("SetupQuickMenu", "AdvancedQuickMenu", function(self)
        local char = LocalPlayer():getChar()
        if not char then return end

            -- Add faction-specific buttons
            local faction = char:getFaction()
            if faction == "police" then
                local arrestBtn = self:Add("DButton")
                arrestBtn:SetText("Arrest")
                arrestBtn:Dock(TOP)
                arrestBtn.DoClick = function()
                RunConsoleCommand("lia_arrest")
            end
            elseif faction == "medic" then
                local healBtn = self:Add("DButton")
                healBtn:SetText("Heal")
                healBtn:Dock(TOP)
                healBtn.DoClick = function()
                RunConsoleCommand("lia_heal")
            end
        end

        -- Add universal buttons
        local inventoryBtn = self:Add("DButton")
        inventoryBtn:SetText("Inventory")
        inventoryBtn:Dock(TOP)
        inventoryBtn.DoClick = function()
        RunConsoleCommand("lia_inventory")
    end
    end)
    ```
]]
function SetupQuickMenu(self)
end

--[[
    Purpose:
        Called to check if scoreboard override should be allowed
    When Called:
        When determining if a player can override scoreboard behavior
    Parameters:
        ply (Player) - The player
        override (string) - The override type
    Returns:
        boolean - True to allow, false to deny
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Allow all overrides
    hook.Add("ShouldAllowScoreboardOverride", "MyAddon", function(ply, override)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check admin status
    hook.Add("ShouldAllowScoreboardOverride", "AdminOverride", function(ply, override)
        return ply:IsAdmin()
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex override system
    hook.Add("ShouldAllowScoreboardOverride", "AdvancedOverride", function(ply, override)
        -- Admins can always override
        if ply:IsAdmin() then return true end

            -- Check specific override types
            if override == "customization" then
                return ply:getNetVar("canCustomizeScoreboard", false)
                elseif override == "sorting" then
                    return ply:getNetVar("canSortScoreboard", false)
                end

                return false
            end)
    ```
]]
function ShouldAllowScoreboardOverride(ply, override)
end

--[[
    Purpose:
        Determines if a bar should be drawn on the HUD
    When Called:
        When the bar system is rendering bars
    Parameters:
        bar (table) - The bar object to check
    Returns:
        boolean - True if the bar should be drawn, false otherwise
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Draw all bars
    hook.Add("ShouldBarDraw", "MyAddon", function(bar)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide certain bars based on conditions
    hook.Add("ShouldBarDraw", "BarVisibility", function(bar)
        if bar.identifier == "health" then
            local char = LocalPlayer():getChar()
            if char and char:getData("hideHealth", false) then
                return false
            end
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bar visibility system
    hook.Add("ShouldBarDraw", "AdvancedBarVisibility", function(bar)
        local char = LocalPlayer():getChar()
        if not char then return false end

            -- Check if HUD is hidden
            if hook.Run("ShouldHideBars") then
                return false
            end

            -- Check bar-specific conditions
            if bar.identifier == "health" then
                -- Only show health if below 90%
                local health = LocalPlayer():Health()
                local maxHealth = LocalPlayer():GetMaxHealth()
                return (health / maxHealth) < 0.9
                elseif bar.identifier == "armor" then
                    -- Only show armor if above 0
                    return LocalPlayer():Armor() > 0
                    elseif bar.identifier == "stamina" then
                        -- Only show stamina if below 100%
                        local stamina = LocalPlayer():getNetVar("stamina", 100)
                        return stamina < 100
                    end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    local restrictedBars = {
                    ["police"] = {"stamina"}, -- Police don't see stamina bar
                        ["medic"] = {"armor"} -- Medics don't see armor bar
                        }

                        local restricted = restrictedBars[faction]
                        if restricted and table.HasValue(restricted, bar.identifier) then
                            return false
                        end

                        -- Check level requirements
                        local requiredLevel = bar.requiredLevel
                        if requiredLevel then
                            local charLevel = char:getData("level", 1)
                            if charLevel < requiredLevel then
                                return false
                            end
                        end

                        -- Check time restrictions
                        local timeRestriction = bar.timeRestriction
                        if timeRestriction then
                            local currentHour = tonumber(os.date("%H"))
                            if currentHour < timeRestriction.start or currentHour > timeRestriction.end then
                                return false
                            end
                        end

                        return true
                    end)
    ```
]]
--[[
    Purpose:
        Called to check if a bar should be drawn
    When Called:
        When determining if a UI bar should be rendered
    Parameters:
        bar (table) - The bar data
    Returns:
        boolean - True to draw, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always draw bars
    hook.Add("ShouldBarDraw", "MyAddon", function(bar)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide specific bars
    hook.Add("ShouldBarDraw", "HideSpecificBars", function(bar)
        if bar.name == "health" and LocalPlayer():Health() >= 100 then
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bar visibility system
    hook.Add("ShouldBarDraw", "AdvancedBarVisibility", function(bar)
        local char = LocalPlayer():getChar()
        if not char then return false end

            -- Hide bars for specific factions
            local faction = char:getFaction()
            if faction == "ghost" and bar.name ~= "stamina" then
                return false
            end

            -- Hide bars when in cutscene
            if char:getData("inCutscene", false) then
                return false
            end

            -- Hide bars when dead
            if LocalPlayer():Health() <= 0 then
                return false
            end

            return true
        end)
    ```
]]
function ShouldBarDraw(bar)
end

--[[
    Purpose:
        Called to check if thirdperson should be disabled
    When Called:
        When determining if thirdperson view should be blocked
    Parameters:
        self (Player) - The player
    Returns:
        boolean - True to disable, false to allow
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Never disable thirdperson
    hook.Add("ShouldDisableThirdperson", "MyAddon", function(self)
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Disable in specific areas
    hook.Add("ShouldDisableThirdperson", "DisableInAreas", function(self)
        local pos = self:GetPos()
        local restrictedAreas = {
        Vector(0, 0, 0), -- Example restricted area
    }

    for _, area in ipairs(restrictedAreas) do
        if pos:Distance(area) < 500 then
            return true
        end
    end

    return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex thirdperson restrictions
    hook.Add("ShouldDisableThirdperson", "AdvancedThirdpersonRestrictions", function(self)
        local char = self:getChar()
        if not char then return false end

            -- Disable for specific factions
            local faction = char:getFaction()
            if faction == "ghost" then
                return true
            end

            -- Disable in vehicles
            if self:InVehicle() then
                return true
            end

            -- Disable when tied
            if char:getData("tied", false) then
                return true
            end

            -- Disable in restricted areas
            local pos = self:GetPos()
            local restrictedAreas = lia.data.get("restrictedAreas", {})
            for _, area in ipairs(restrictedAreas) do
                if pos:Distance(area.pos) < area.radius then
                    return true
                end
            end

            return false
        end)
    ```
]]
function ShouldDisableThirdperson(self)
end

--[[
    Purpose:
        Called to check if ammo should be drawn
    When Called:
        When determining if weapon ammo should be displayed
    Parameters:
        wpn (Weapon) - The weapon
    Returns:
        boolean - True to draw, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always draw ammo
    hook.Add("ShouldDrawAmmo", "MyAddon", function(wpn)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide ammo for specific weapons
    hook.Add("ShouldDrawAmmo", "HideSpecificAmmo", function(wpn)
        local weaponClass = wpn:GetClass()
        local hideAmmoWeapons = {"weapon_crowbar", "weapon_stunstick"}

        return not table.HasValue(hideAmmoWeapons, weaponClass)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ammo display system
    hook.Add("ShouldDrawAmmo", "AdvancedAmmoDisplay", function(wpn)
        local char = LocalPlayer():getChar()
        if not char then return false end

            -- Hide ammo for melee weapons
            local weaponClass = wpn:GetClass()
            local meleeWeapons = {"weapon_crowbar", "weapon_stunstick", "weapon_knife"}
            if table.HasValue(meleeWeapons, weaponClass) then
                return false
            end

            -- Hide ammo when in cutscene
            if char:getData("inCutscene", false) then
                return false
            end

            -- Hide ammo for specific factions
            local faction = char:getFaction()
            if faction == "ghost" then
                return false
            end

            -- Check weapon ammo type
            local ammoType = wpn:GetPrimaryAmmoType()
            if ammoType == -1 then
                return false
            end

            return true
        end)
    ```
]]
function ShouldDrawAmmo(wpn)
end

--[[
    Purpose:
        Called to check if entity info should be drawn
    When Called:
        When determining if entity information should be displayed
    Parameters:
        e (Entity) - The entity
    Returns:
        boolean - True to draw, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always draw entity info
    hook.Add("ShouldDrawEntityInfo", "MyAddon", function(e)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide info for specific entities
    hook.Add("ShouldDrawEntityInfo", "HideSpecificInfo", function(e)
        local class = e:GetClass()
        local hideClasses = {"prop_physics", "prop_dynamic"}

        return not table.HasValue(hideClasses, class)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex entity info system
    hook.Add("ShouldDrawEntityInfo", "AdvancedEntityInfo", function(e)
        if not IsValid(e) then return false end

            local char = LocalPlayer():getChar()
            if not char then return false end

                -- Hide info when in cutscene
                if char:getData("inCutscene", false) then
                    return false
                end

                -- Hide info for specific entity types
                local class = e:GetClass()
                local hideClasses = {
                "prop_physics",
                "prop_dynamic",
                "func_door",
                "func_button"
            }

            if table.HasValue(hideClasses, class) then
                return false
            end

            -- Show info for players
            if e:IsPlayer() then
                return true
            end

            -- Show info for vehicles
            if e:IsVehicle() then
                return true
            end

            -- Show info for NPCs
            if e:IsNPC() then
                return true
            end

            return false
        end)
    ```
]]
function ShouldDrawEntityInfo(e)
end

--[[
    Purpose:
        Determines if player information should be drawn
    When Called:
        When deciding whether to draw player info above a player
    Parameters:
        e (Entity) - The entity to check
    Returns:
        boolean - True if player info should be drawn, false otherwise
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Draw all player info
    hook.Add("ShouldDrawPlayerInfo", "MyAddon", function(e)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide info for certain players
    hook.Add("ShouldDrawPlayerInfo", "PlayerInfoVisibility", function(e)
        if not e:IsPlayer() then return false end

            local char = e:getChar()
            if not char then return false end

                -- Hide info for hidden players
                if char:getData("hidden", false) then
                    return false
                end

                return true
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex player info visibility system
    hook.Add("ShouldDrawPlayerInfo", "AdvancedPlayerInfo", function(e)
        if not e:IsPlayer() then return false end

            local ply = LocalPlayer()
            local char = ply:getChar()
            if not char then return false end

                local targetChar = e:getChar()
                if not targetChar then return false end

                    -- Don't draw info for self
                    if e == ply then return false end

                        -- Check distance
                        local distance = ply:GetPos():Distance(e:GetPos())
                        if distance > 500 then return false end

                            -- Check if target is hidden
                            if targetChar:getData("hidden", false) then
                                return false
                            end

                            -- Check if target is in stealth mode
                            if targetChar:getData("stealth", false) then
                                return false
                            end

                            -- Check faction visibility
                            local plyFaction = char:getFaction()
                            local targetFaction = targetChar:getFaction()

                            if plyFaction == "police" and targetFaction == "criminal" then
                                -- Police can always see criminals
                                return true
                                elseif plyFaction == "criminal" and targetFaction == "police" then
                                    -- Criminals can see police
                                    return true
                                    elseif plyFaction == targetFaction then
                                        -- Same faction can see each other
                                        return true
                                    end

                                    -- Check if player has recognition
                                    if targetChar:isRecognized(ply) then
                                        return true
                                    end

                                    -- Check if target is in same group
                                    local plyGroup = char:getData("group")
                                    local targetGroup = targetChar:getData("group")
                                    if plyGroup and plyGroup == targetGroup then
                                        return true
                                    end

                                    -- Check if target is in same team
                                    if ply:Team() == e:Team() then
                                        return true
                                    end

                                    return false
                                end)
    ```
]]
function ShouldDrawPlayerInfo(e)
end

--[[
    Purpose:
        Called to determine if weapon selection should be drawn
    When Called:
        When the system checks if weapon selection UI should be displayed
    Parameters:
        client (Player) - The player to check for
    Returns:
        boolean - Whether to draw weapon selection (true) or not (false)
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always show weapon selection
    hook.Add("ShouldDrawWepSelect", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Conditional weapon selection
    hook.Add("ShouldDrawWepSelect", "ConditionalWepSelect", function(client)
        local char = client:getChar()
        if char and char:getData("hideWeaponSelect", false) then
            return false
        end
        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon selection logic
    hook.Add("ShouldDrawWepSelect", "AdvancedWepSelect", function(client)
        -- Check if player is in a vehicle
        if client:InVehicle() then
            return false
        end

        -- Check if player is typing
        if client:IsTyping() then
            return false
        end

        -- Check custom conditions
        local char = client:getChar()
        if char then
            local faction = char:getFaction()
            if faction == FACTION_CITIZEN then
                return true
                elseif faction == FACTION_POLICE then
                    return char:getData("showWeaponSelect", true)
                end
            end

            -- Check admin status
            if client:IsAdmin() then
                return true
            end

            return false
        end)
    ```
]]
function ShouldDrawWepSelect(client)
end

--[[
    Purpose:
        Determines if all bars should be hidden
    When Called:
        When the bar system is about to render
    Parameters:
        None
    Returns:
        boolean - True if bars should be hidden, false otherwise
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Never hide bars
    hook.Add("ShouldHideBars", "MyAddon", function()
        return false
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide bars in certain situations
    hook.Add("ShouldHideBars", "BarHiding", function()
        local ply = LocalPlayer()

        -- Hide bars when dead
        if not ply:Alive() then
            return true
        end

        -- Hide bars when in vehicle
        if ply:InVehicle() then
            return true
        end

        return false
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex bar hiding system
    hook.Add("ShouldHideBars", "AdvancedBarHiding", function()
        local ply = LocalPlayer()
        local char = ply:getChar()

        if not char then return true end

            -- Hide bars when dead
            if not ply:Alive() then
                return true
            end

            -- Hide bars when in vehicle
            if ply:InVehicle() then
                return true
            end

            -- Hide bars when in menu
            if IsValid(lia.gui.menu) and lia.gui.menu:IsVisible() then
                return true
            end

            -- Hide bars when in character creation
            if IsValid(lia.gui.charCreate) and lia.gui.charCreate:IsVisible() then
                return true
            end

            -- Hide bars when in inventory
            if IsValid(lia.gui.inv1) and lia.gui.inv1:IsVisible() then
                return true
            end

            -- Hide bars when in third person
            if ply:GetViewEntity() ~= ply then
                return true
            end

            -- Hide bars when in cinematic mode
            if char:getData("cinematicMode", false) then
                return true
            end

            -- Hide bars when in spectator mode
            if ply:GetObserverMode() ~= OBS_MODE_NONE then
                return true
            end

            -- Hide bars when HUD is disabled
            if not ply:ShouldDrawLocalPlayer() then
                return true
            end

            -- Hide bars when in admin mode
            if ply:IsAdmin() and ply:getData("adminMode", false) then
                return true
            end

            return false
        end)
    ```
]]
function ShouldHideBars()
end

--[[
    Purpose:
        Called to check if a menu button should be shown
    When Called:
        When displaying menu buttons
    Parameters:
        button (string) - The button identifier
    Returns:
        boolean - True to show, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Show all buttons
    hook.Add("ShouldMenuButtonShow", "MyAddon", function(button)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide specific buttons
    hook.Add("ShouldMenuButtonShow", "HideButtons", function(button)
        local hiddenButtons = {"admin", "debug"}
        return not table.HasValue(hiddenButtons, button)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex button visibility system
    hook.Add("ShouldMenuButtonShow", "AdvancedButtonVisibility", function(button)
        local client = LocalPlayer()
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check permissions
                local permissions = {
                ["admin"] = client:IsAdmin(),
                ["moderator"] = client:IsAdmin() or client:IsSuperAdmin(),
                ["character"] = true,
                ["inventory"] = true,
                ["settings"] = true
            }

            -- Check faction restrictions
            local faction = char:getFaction()
            if button == "faction" and faction == "ghost" then
                return false
            end

            -- Check character level
            local level = char:getData("level", 1)
            if button == "advanced" and level < 10 then
                return false
            end

            return permissions[button] or false
        end)
    ```
]]
function ShouldMenuButtonShow(button)
end

--[[
    Purpose:
        Called to check if a death sound should be played
    When Called:
        When a player dies
    Parameters:
        client (Player) - The player who died
        deathSound (string) - The death sound to play
    Returns:
        boolean - True to play, false to suppress
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Play all death sounds
    hook.Add("ShouldPlayDeathSound", "MyAddon", function(client, deathSound)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Suppress specific sounds
    hook.Add("ShouldPlayDeathSound", "SuppressSounds", function(client, deathSound)
        local suppressedSounds = {"vo/npc/male01/pain01.wav"}
        return not table.HasValue(suppressedSounds, deathSound)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex death sound system
    hook.Add("ShouldPlayDeathSound", "AdvancedDeathSound", function(client, deathSound)
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return true end

                -- Check if sounds are enabled
                local soundEnabled = lia.config.get("deathSounds", true)
                if not soundEnabled then return false end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    if faction == "ghost" then
                        return false
                    end

                    -- Check death type
                    local deathType = char:getData("deathType", "normal")
                    if deathType == "silent" then
                        return false
                    end

                    -- Check distance to other players
                    local pos = client:GetPos()
                    local nearbyPlayers = 0
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client and ply:GetPos():Distance(pos) < 500 then
                            nearbyPlayers = nearbyPlayers + 1
                        end
                    end

                    -- Only play if other players are nearby
                    return nearbyPlayers > 0
                end)
    ```
]]
function ShouldPlayDeathSound(client, deathSound)
end

--[[
    Purpose:
        Called to check if a pain sound should be played
    When Called:
        When a player takes damage
    Parameters:
        client (Player) - The player taking damage
        painSound (string) - The pain sound to play
    Returns:
        boolean - True to play, false to suppress
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Play all pain sounds
    hook.Add("ShouldPlayPainSound", "MyAddon", function(client, painSound)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Suppress specific sounds
    hook.Add("ShouldPlayPainSound", "SuppressPainSounds", function(client, painSound)
        local suppressedSounds = {"vo/npc/male01/pain01.wav"}
        return not table.HasValue(suppressedSounds, painSound)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex pain sound system
    hook.Add("ShouldPlayPainSound", "AdvancedPainSound", function(client, painSound)
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return true end

                -- Check if sounds are enabled
                local soundEnabled = lia.config.get("painSounds", true)
                if not soundEnabled then return false end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    if faction == "ghost" then
                        return false
                    end

                    -- Check pain threshold
                    local health = client:Health()
                    local maxHealth = client:GetMaxHealth()
                    local healthPercent = health / maxHealth

                    if healthPercent > 0.8 then
                        return false
                    end

                    -- Check damage type
                    local damageType = char:getData("lastDamageType", "generic")
                    if damageType == "silent" then
                        return false
                    end

                    -- Check distance to other players
                    local pos = client:GetPos()
                    local nearbyPlayers = 0
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client and ply:GetPos():Distance(pos) < 300 then
                            nearbyPlayers = nearbyPlayers + 1
                        end
                    end

                    -- Only play if other players are nearby
                    return nearbyPlayers > 0
                end)
    ```
]]
function ShouldPlayPainSound(client, painSound)
end

--[[
    Purpose:
        Called to check if the respawn screen should appear
    When Called:
        When a player dies
    Parameters:
        None
    Returns:
        boolean - True to show respawn screen, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always show respawn screen
    hook.Add("ShouldRespawnScreenAppear", "MyAddon", function()
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide respawn screen for specific factions
    hook.Add("ShouldRespawnScreenAppear", "HideForFactions", function()
        local char = LocalPlayer():getChar()
        if not char then return true end

            local faction = char:getFaction()
            local hiddenFactions = {"ghost", "spectator"}
            return not table.HasValue(hiddenFactions, faction)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex respawn screen system
    hook.Add("ShouldRespawnScreenAppear", "AdvancedRespawnScreen", function()
        local client = LocalPlayer()
        if not IsValid(client) then return true end

            local char = client:getChar()
            if not char then return true end

                -- Check if respawn screen is enabled
                local respawnEnabled = lia.config.get("respawnScreen", true)
                if not respawnEnabled then return false end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    if faction == "ghost" then
                        return false
                    end

                    -- Check death type
                    local deathType = char:getData("deathType", "normal")
                    if deathType == "instant" then
                        return false
                    end

                    -- Check if player has respawn tokens
                    local respawnTokens = char:getData("respawnTokens", 0)
                    if respawnTokens <= 0 then
                        return false
                    end

                    -- Check time restrictions
                    local lastDeath = char:getData("lastDeath", 0)
                    local timeSinceDeath = CurTime() - lastDeath
                    if timeSinceDeath < 5 then
                        return false
                    end

                    return true
                end)
    ```
]]
function ShouldRespawnScreenAppear()
end

--[[
    Purpose:
        Called to check if a class should be shown on the scoreboard
    When Called:
        When displaying the scoreboard
    Parameters:
        clsData (table) - The class data
    Returns:
        boolean - True to show, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Show all classes
    hook.Add("ShouldShowClassOnScoreboard", "MyAddon", function(clsData)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide specific classes
    hook.Add("ShouldShowClassOnScoreboard", "HideClasses", function(clsData)
        local hiddenClasses = {"admin", "debug"}
        return not table.HasValue(hiddenClasses, clsData.uniqueID)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex class visibility system
    hook.Add("ShouldShowClassOnScoreboard", "AdvancedClassVisibility", function(clsData)
        local client = LocalPlayer()
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

                -- Check if scoreboard is enabled
                local scoreboardEnabled = lia.config.get("scoreboard", true)
                if not scoreboardEnabled then return false end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    if clsData.faction and clsData.faction ~= faction then
                        return false
                    end

                    -- Check level requirements
                    local level = char:getData("level", 1)
                    if clsData.minLevel and level < clsData.minLevel then
                        return false
                    end

                    -- Check permissions
                    if clsData.adminOnly and not client:IsAdmin() then
                        return false
                    end

                    -- Check if class is active
                    if clsData.disabled then
                        return false
                    end

                    return true
                end)
    ```
]]
function ShouldShowClassOnScoreboard(clsData)
end

--[[
    Purpose:
        Called to check if a faction should be shown on the scoreboard
    When Called:
        When displaying the scoreboard
    Parameters:
        ply (Player) - The player whose faction is being checked
    Returns:
        boolean - True to show, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Show all factions
    hook.Add("ShouldShowFactionOnScoreboard", "MyAddon", function(ply)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide specific factions
    hook.Add("ShouldShowFactionOnScoreboard", "HideFactions", function(ply)
        local char = ply:getChar()
        if not char then return false end

            local faction = char:getFaction()
            local hiddenFactions = {"ghost", "spectator"}
            return not table.HasValue(hiddenFactions, faction)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex faction visibility system
    hook.Add("ShouldShowFactionOnScoreboard", "AdvancedFactionVisibility", function(ply)
        if not IsValid(ply) then return false end

            local char = ply:getChar()
            if not char then return false end

                local client = LocalPlayer()
                if not IsValid(client) then return false end

                    -- Check if scoreboard is enabled
                    local scoreboardEnabled = lia.config.get("scoreboard", true)
                    if not scoreboardEnabled then return false end

                        -- Check faction restrictions
                        local faction = char:getFaction()
                        if faction == "ghost" then
                            return false
                        end

                        -- Check if player is recognized
                        local clientChar = client:getChar()
                        if clientChar then
                            local isRecognized = clientChar:isRecognized(ply)
                            if not isRecognized then
                                return false
                            end
                        end

                        -- Check distance
                        local distance = client:GetPos():Distance(ply:GetPos())
                        if distance > 1000 then
                            return false
                        end

                        -- Check if faction is public
                        local factionData = lia.faction.list[faction]
                        if factionData and factionData.hidden then
                            return false
                        end

                        return true
                    end)
    ```
]]
function ShouldShowFactionOnScoreboard(ply)
end

--[[
    Purpose:
        Called to check if a player should be shown on the scoreboard
    When Called:
        When displaying the scoreboard
    Parameters:
        ply (Player) - The player to check
    Returns:
        boolean - True to show, false to hide
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Show all players
    hook.Add("ShouldShowPlayerOnScoreboard", "MyAddon", function(ply)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide specific players
    hook.Add("ShouldShowPlayerOnScoreboard", "HidePlayers", function(ply)
        local char = ply:getChar()
        if not char then return false end

            local faction = char:getFaction()
            local hiddenFactions = {"ghost", "spectator"}
            return not table.HasValue(hiddenFactions, faction)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex player visibility system
    hook.Add("ShouldShowPlayerOnScoreboard", "AdvancedPlayerVisibility", function(ply)
        if not IsValid(ply) then return false end

            local char = ply:getChar()
            if not char then return false end

                local client = LocalPlayer()
                if not IsValid(client) then return false end

                    -- Check if scoreboard is enabled
                    local scoreboardEnabled = lia.config.get("scoreboard", true)
                    if not scoreboardEnabled then return false end

                        -- Check faction restrictions
                        local faction = char:getFaction()
                        if faction == "ghost" then
                            return false
                        end

                        -- Check if player is recognized
                        local clientChar = client:getChar()
                        if clientChar then
                            local isRecognized = clientChar:isRecognized(ply)
                            if not isRecognized then
                                return false
                            end
                        end

                        -- Check distance
                        local distance = client:GetPos():Distance(ply:GetPos())
                        if distance > 1000 then
                            return false
                        end

                        -- Check if player is online
                        if not ply:IsValid() or not ply:IsConnected() then
                            return false
                        end

                        -- Check if player is in same area
                        local area = char:getData("area", "unknown")
                        local clientArea = clientChar and clientChar:getData("area", "unknown") or "unknown"
                        if area ~= clientArea then
                            return false
                        end

                        return true
                    end)
    ```
]]
function ShouldShowPlayerOnScoreboard(ply)
end

--[[
    Purpose:
        Called to check if a client ragdoll should be spawned
    When Called:
        When a player dies
    Parameters:
        client (Player) - The player who died
    Returns:
        boolean - True to spawn, false to suppress
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Spawn all ragdolls
    hook.Add("ShouldSpawnClientRagdoll", "MyAddon", function(client)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Suppress ragdolls for specific factions
    hook.Add("ShouldSpawnClientRagdoll", "SuppressRagdolls", function(client)
        local char = client:getChar()
        if not char then return true end

            local faction = char:getFaction()
            local suppressedFactions = {"ghost", "spectator"}
            return not table.HasValue(suppressedFactions, faction)
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ragdoll spawning system
    hook.Add("ShouldSpawnClientRagdoll", "AdvancedRagdollSpawning", function(client)
        if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return true end

                -- Check if ragdolls are enabled
                local ragdollsEnabled = lia.config.get("ragdolls", true)
                if not ragdollsEnabled then return false end

                    -- Check faction restrictions
                    local faction = char:getFaction()
                    if faction == "ghost" then
                        return false
                    end

                    -- Check death type
                    local deathType = char:getData("deathType", "normal")
                    if deathType == "disintegrate" then
                        return false
                    end

                    -- Check if player has ragdoll tokens
                    local ragdollTokens = char:getData("ragdollTokens", 0)
                    if ragdollTokens <= 0 then
                        return false
                    end

                    -- Check performance
                    local ragdollCount = 0
                    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
                        ragdollCount = ragdollCount + 1
                    end

                    if ragdollCount > 10 then
                        return false
                    end

                    -- Check distance to other players
                    local pos = client:GetPos()
                    local nearbyPlayers = 0
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client and ply:GetPos():Distance(pos) < 500 then
                            nearbyPlayers = nearbyPlayers + 1
                        end
                    end

                    -- Only spawn if other players are nearby
                    return nearbyPlayers > 0
                end)
    ```
]]
function ShouldSpawnClientRagdoll(client)
end

--[[
    Purpose:
        Called to show player options menu
    When Called:
        When displaying player options
    Parameters:
        ply (Player) - The player to show options for
        initialOpts (table) - Initial options table
    Returns:
        table - Modified options table
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add basic options
    hook.Add("ShowPlayerOptions", "MyAddon", function(ply, initialOpts)
        table.insert(initialOpts, {"Examine", function() print("Examining " .. ply:Name()) end})
            return initialOpts
        end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add faction-specific options
    hook.Add("ShowPlayerOptions", "FactionOptions", function(ply, initialOpts)
        local char = ply:getChar()
        if not char then return initialOpts end

            local faction = char:getFaction()
            if faction == "police" then
                table.insert(initialOpts, {"Arrest", function() print("Arresting " .. ply:Name()) end})
                end

                return initialOpts
            end)
    ```

    High Complexity:

    ```lua
    -- High: Complex player options system
    hook.Add("ShowPlayerOptions", "AdvancedPlayerOptions", function(ply, initialOpts)
        if not IsValid(ply) then return initialOpts end

            local char = ply:getChar()
            if not char then return initialOpts end

                local client = LocalPlayer()
                if not IsValid(client) then return initialOpts end

                    local clientChar = client:getChar()
                    if not clientChar then return initialOpts end

                        -- Check if player is recognized
                        local isRecognized = clientChar:isRecognized(ply)
                        if not isRecognized then
                            table.insert(initialOpts, {"Recognize", function()
                                net.Start("liaRecognizePlayer")
                                net.WriteEntity(ply)
                                net.SendToServer()
                                end})
                            end

                            -- Check faction permissions
                            local faction = char:getFaction()
                            local clientFaction = clientChar:getFaction()

                            if clientFaction == "police" then
                                table.insert(initialOpts, {"Arrest", function()
                                    net.Start("liaArrestPlayer")
                                    net.WriteEntity(ply)
                                    net.SendToServer()
                                    end})

                                    table.insert(initialOpts, {"Search", function()
                                        net.Start("liaSearchPlayer")
                                        net.WriteEntity(ply)
                                        net.SendToServer()
                                        end})
                                    end

                                    if clientFaction == "medic" then
                                        table.insert(initialOpts, {"Heal", function()
                                            net.Start("liaHealPlayer")
                                            net.WriteEntity(ply)
                                            net.SendToServer()
                                            end})
                                        end

                                        -- Check admin permissions
                                        if client:IsAdmin() then
                                            table.insert(initialOpts, {"Admin Options", function()
                                                local menu = DermaMenu()
                                                menu:AddOption("Kick", function() ply:Kick("Kicked by admin") end)
                                                menu:AddOption("Ban", function() ply:Ban(0, "Banned by admin") end)
                                                menu:Open()
                                                end})
                                            end

                                            return initialOpts
                                        end)
    ```
]]
function ShowPlayerOptions(ply, initialOpts)
end

--[[
    Purpose:
        Called when storage unlock prompt is shown
    When Called:
        When a player attempts to unlock a locked storage
    Parameters:
        entity (Entity) - The storage entity being unlocked
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log unlock prompt
    hook.Add("StorageUnlockPrompt", "MyAddon", function(entity)
        print("Storage unlock prompt shown for " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Show custom unlock message
    hook.Add("StorageUnlockPrompt", "CustomMessage", function(entity)
        lia.util.notify("This storage is locked. You need a key to open it.")
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex storage unlock system
    hook.Add("StorageUnlockPrompt", "AdvancedStorageUnlock", function(entity)
        if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

                local char = client:getChar()
                if not char then return end

                    -- Check if player has key
                    local inventory = char:getInv()
                    if inventory then
                        local hasKey = false
                        for _, item in pairs(inventory:getItems()) do
                            if item.uniqueID == "storage_key" then
                                hasKey = true
                                break
                            end
                        end

                        if hasKey then
                            lia.util.notify("You have a key for this storage. Press E to unlock.")
                            else
                                lia.util.notify("This storage is locked. You need a storage key to open it.")
                            end
                        end

                        -- Check storage type
                        local storageType = entity:getNetVar("storageType", "normal")
                        if storageType == "vault" then
                            lia.util.notify("This is a vault. You need a vault key to open it.")
                            elseif storageType == "safe" then
                                lia.util.notify("This is a safe. You need a safe key to open it.")
                            end

                            -- Check if storage is owned
                            local owner = entity:getNetVar("owner")
                            if owner and owner ~= char:getID() then
                                lia.util.notify("This storage belongs to someone else.")
                            end

                            -- Show unlock options
                            local menu = DermaMenu()
                            menu:AddOption("Try to unlock", function()
                            net.Start("liaStorageUnlock")
                            net.WriteEntity(entity)
                            net.SendToServer()
                        end)
                        menu:AddOption("Cancel", function() end)
                        menu:Open()
                    end)
    ```
]]
function StorageUnlockPrompt(entity)
end

--[[
    Purpose:
        Called when third person is toggled
    When Called:
        When third person view is enabled or disabled
    Parameters:
        newValue (boolean) - The new third person state
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log third person toggle
    hook.Add("ThirdPersonToggled", "MyAddon", function(newValue)
        print("Third person " .. (newValue and "enabled" or "disabled"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Show notification
    hook.Add("ThirdPersonToggled", "NotifyToggle", function(newValue)
        lia.util.notify("Third person " .. (newValue and "enabled" or "disabled"))
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex third person system
    hook.Add("ThirdPersonToggled", "AdvancedThirdPerson", function(newValue)
        local client = LocalPlayer()
        if not IsValid(client) then return end

            -- Update UI
            if IsValid(lia.gui.thirdPersonSettings) then
                lia.gui.thirdPersonSettings:SetEnabled(newValue)
            end

            -- Save setting
            lia.data.set("thirdPerson", newValue)

            -- Notify player
            lia.util.notify("Third person " .. (newValue and "enabled" or "disabled"), 3)

            -- Update camera
            if newValue then
                client:SetViewEntity(client)
                else
                    client:SetViewEntity(client)
                end

                -- Log the change
                lia.log.write("third_person_toggle", {
                    enabled = newValue,
                    timestamp = os.time()
                    })

                    -- Update character model visibility
                    local char = client:getChar()
                    if char then
                        char:setData("thirdPerson", newValue)
                    end
                end)
    ```
]]
function ThirdPersonToggled(newValue)
end

--[[
    Purpose:
        Called to create a ticket frame
    When Called:
        When displaying a support ticket
    Parameters:
        requester (Player) - The player who requested the ticket
        message (string) - The ticket message
        claimed (boolean) - Whether the ticket is claimed
    Returns:
        Panel - The ticket frame panel
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Create basic ticket frame
    hook.Add("TicketFrame", "MyAddon", function(requester, message, claimed)
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 300)
        frame:Center()
        frame:SetTitle("Support Ticket")
        frame:MakePopup()
        return frame
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Create styled ticket frame
    hook.Add("TicketFrame", "StyledTicket", function(requester, message, claimed)
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 400)
        frame:Center()
        frame:SetTitle("Support Ticket - " .. (claimed and "Claimed" or "Open"))
        frame:MakePopup()

        local label = vgui.Create("DLabel", frame)
        label:SetText("Requester: " .. requester:Name())
        label:Dock(TOP)

        local text = vgui.Create("DTextEntry", frame)
        text:SetText(message)
        text:SetMultiline(true)
        text:Dock(FILL)

        return frame
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex ticket frame system
    hook.Add("TicketFrame", "AdvancedTicketFrame", function(requester, message, claimed)
        local frame = vgui.Create("DFrame")
        frame:SetSize(600, 500)
        frame:Center()
        frame:SetTitle("Support Ticket - " .. (claimed and "Claimed" or "Open"))
        frame:MakePopup()

        -- Header
        local header = vgui.Create("DPanel", frame)
        header:Dock(TOP)
        header:SetHeight(50)

        local requesterLabel = vgui.Create("DLabel", header)
        requesterLabel:SetText("Requester: " .. requester:Name())
        requesterLabel:Dock(LEFT)

        local statusLabel = vgui.Create("DLabel", header)
        statusLabel:SetText("Status: " .. (claimed and "Claimed" or "Open"))
        statusLabel:Dock(RIGHT)

        -- Message area
        local messageArea = vgui.Create("DTextEntry", frame)
        messageArea:SetText(message)
        messageArea:SetMultiline(true)
        messageArea:SetEditable(false)
        messageArea:Dock(FILL)

        -- Buttons
        local buttonPanel = vgui.Create("DPanel", frame)
        buttonPanel:Dock(BOTTOM)
        buttonPanel:SetHeight(40)

        local claimButton = vgui.Create("DButton", buttonPanel)
        claimButton:SetText("Claim Ticket")
        claimButton:Dock(LEFT)
        claimButton:SetWide(100)
        claimButton.DoClick = function()
        net.Start("liaClaimTicket")
        net.WriteEntity(requester)
        net.SendToServer()
    end

    local closeButton = vgui.Create("DButton", buttonPanel)
    closeButton:SetText("Close")
    closeButton:Dock(RIGHT)
    closeButton:SetWide(100)
    closeButton.DoClick = function()
    frame:Close()
    end

    return frame
    end)
    ```
]]
function TicketFrame(requester, message, claimed)
end

--[[
    Purpose:
        Called to initialize a tooltip
    When Called:
        When a tooltip is being created
    Parameters:
        self (Panel) - The tooltip panel
        panel (Panel) - The parent panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Set basic tooltip properties
    hook.Add("TooltipInitialize", "MyAddon", function(self, panel)
        self:SetText("Tooltip")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set tooltip based on panel
    hook.Add("TooltipInitialize", "PanelTooltip", function(self, panel)
        if panel:GetClassName() == "DButton" then
            self:SetText("Click me!")
            elseif panel:GetClassName() == "DTextEntry" then
                self:SetText("Enter text here")
            end
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex tooltip system
    hook.Add("TooltipInitialize", "AdvancedTooltip", function(self, panel)
        if not IsValid(self) or not IsValid(panel) then return end

            -- Set tooltip properties
            self:SetText("")
            self:SetFont("DermaDefault")
            self:SetTextColor(Color(255, 255, 255))

            -- Get panel information
            local panelClass = panel:GetClassName()
            local panelText = panel:GetText() or ""

            -- Set tooltip based on panel type
            if panelClass == "DButton" then
                if panelText == "Close" then
                    self:SetText("Close this window")
                    elseif panelText == "Save" then
                        self:SetText("Save your changes")
                        else
                            self:SetText("Click to interact")
                        end
                        elseif panelClass == "DTextEntry" then
                            self:SetText("Enter text in this field")
                            elseif panelClass == "DCheckBox" then
                                self:SetText("Toggle this option")
                                elseif panelClass == "DComboBox" then
                                    self:SetText("Select an option from the dropdown")
                                end

                                -- Set tooltip position
                                self:SetPos(panel:GetPos())
                                self:SetSize(200, 20)

                                -- Set tooltip delay
                                self:SetDelay(0.5)
                            end)
    ```
]]
function TooltipInitialize(self, panel)
end

--[[
    Purpose:
        Called to layout a tooltip
    When Called:
        When a tooltip needs to be laid out
    Parameters:
        self (Panel) - The tooltip panel
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Set basic layout
    hook.Add("TooltipLayout", "MyAddon", function(self)
        self:SizeToContents()
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set layout with constraints
    hook.Add("TooltipLayout", "ConstrainedLayout", function(self)
        self:SizeToContents()

        local w, h = self:GetSize()
        if w > 300 then
            self:SetWide(300)
        end
        if h > 100 then
            self:SetTall(100)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex tooltip layout system
    hook.Add("TooltipLayout", "AdvancedTooltipLayout", function(self)
        if not IsValid(self) then return end

            -- Get text size
            self:SizeToContents()

            local w, h = self:GetSize()
            local maxWidth = 400
            local maxHeight = 200

            -- Constrain width
            if w > maxWidth then
                self:SetWide(maxWidth)
                self:SetWrap(true)
            end

            -- Constrain height
            if h > maxHeight then
                self:SetTall(maxHeight)
                self:SetScrollable(true)
            end

            -- Position tooltip
            local x, y = gui.MousePos()
            local screenW, screenH = ScrW(), ScrH()

            -- Adjust position if tooltip goes off screen
            if x + w > screenW then
                x = screenW - w - 10
            end
            if y + h > screenH then
                y = screenH - h - 10
            end

            self:SetPos(x + 10, y + 10)

            -- Set z position
            self:SetZPos(1000)

            -- Set background
            self:SetBackgroundColor(Color(0, 0, 0, 200))
            self:SetBorderColor(Color(100, 100, 100))
        end)
    ```
]]
function TooltipLayout(self)
end

--[[
    Purpose:
        Called to paint a tooltip
    When Called:
        When a tooltip is being painted
    Parameters:
        self (Panel) - The tooltip panel
        w (number) - The width of the tooltip
        h (number) - The height of the tooltip
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Draw basic background
    hook.Add("TooltipPaint", "MyAddon", function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Draw styled tooltip
    hook.Add("TooltipPaint", "StyledTooltip", function(self, w, h)
        -- Background
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))

        -- Border
        draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))

        -- Text
        draw.SimpleText(self:GetText(), "DermaDefault", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex tooltip painting system
    hook.Add("TooltipPaint", "AdvancedTooltipPaint", function(self, w, h)
        if not IsValid(self) then return end

            -- Get tooltip data
            local text = self:GetText() or ""
            local textColor = self:GetTextColor() or Color(255, 255, 255)
            local bgColor = self:GetBackgroundColor() or Color(0, 0, 0, 200)
            local borderColor = self:GetBorderColor() or Color(100, 100, 100)

            -- Draw background with gradient
            local gradient = Material("gui/gradient_up")
            surface.SetMaterial(gradient)
            surface.SetDrawColor(bgColor)
            surface.DrawTexturedRect(0, 0, w, h)

            -- Draw border
            draw.RoundedBox(4, 0, 0, w, h, borderColor)

            -- Draw inner background
            draw.RoundedBox(4, 1, 1, w-2, h-2, Color(bgColor.r, bgColor.g, bgColor.b, bgColor.a * 0.8))

            -- Draw text with shadow
            local textX, textY = w/2, h/2

            -- Shadow
            draw.SimpleText(text, "DermaDefault", textX+1, textY+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Main text
            draw.SimpleText(text, "DermaDefault", textX, textY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Draw icon if available
            local icon = self:GetIcon()
            if icon then
                surface.SetMaterial(icon)
                surface.SetDrawColor(Color(255, 255, 255, 200))
                surface.DrawTexturedRect(5, 5, 16, 16)
            end
        end)
    ```
]]
function TooltipPaint(self, w, h)
end

--[[
    Purpose:
        Called to try to view a model
    When Called:
        When attempting to view an entity model
    Parameters:
        entity (Entity) - The entity to view
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log model view attempt
    hook.Add("TryViewModel", "MyAddon", function(entity)
        print("Trying to view model: " .. tostring(entity))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check if entity is valid
    hook.Add("TryViewModel", "ValidateEntity", function(entity)
        if IsValid(entity) then
            local model = entity:GetModel()
            if model and model ~= "" then
                print("Viewing model: " .. model)
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model viewing system
    hook.Add("TryViewModel", "AdvancedModelView", function(entity)
        if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

                -- Check if entity is viewable
                local model = entity:GetModel()
                if not model or model == "" then
                    client:ChatPrint("This entity has no model")
                    return
                end

                -- Check distance
                local distance = client:GetPos():Distance(entity:GetPos())
                if distance > 200 then
                    client:ChatPrint("You are too far away to view this model")
                    return
                end

                -- Check if entity is owned
                local owner = entity:getNetVar("owner")
                if owner then
                    local char = client:getChar()
                    if char and owner ~= char:getID() then
                        client:ChatPrint("This entity belongs to someone else")
                        return
                    end
                end

                -- Create model view panel
                local frame = vgui.Create("DFrame")
                frame:SetSize(400, 300)
                frame:Center()
                frame:SetTitle("Model Viewer - " .. entity:GetClass())
                frame:MakePopup()

                local modelPanel = vgui.Create("DModelPanel", frame)
                modelPanel:Dock(FILL)
                modelPanel:SetModel(model)

                -- Set up model panel
                local ent = modelPanel:GetEntity()
                if ent then
                    ent:SetPos(Vector(0, 0, 0))
                    ent:SetAngles(Angle(0, 0, 0))
                end

                -- Add controls
                local controlPanel = vgui.Create("DPanel", frame)
                controlPanel:Dock(BOTTOM)
                controlPanel:SetHeight(50)

                local rotateButton = vgui.Create("DButton", controlPanel)
                rotateButton:SetText("Rotate")
                rotateButton:Dock(LEFT)
                rotateButton:SetWide(100)
                rotateButton.DoClick = function()
                if ent then
                    ent:SetAngles(ent:GetAngles() + Angle(0, 45, 0))
                end
            end

            local closeButton = vgui.Create("DButton", controlPanel)
            closeButton:SetText("Close")
            closeButton:Dock(RIGHT)
            closeButton:SetWide(100)
            closeButton.DoClick = function()
            frame:Close()
        end
    end)
    ```
]]
function TryViewModel(entity)
end

--[[
    Purpose:
        Called to update scoreboard colors
    When Called:
        When scoreboard colors need to be updated
    Parameters:
        teamColors (table) - The team colors table
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log color update
    hook.Add("UpdateScoreboardColors", "MyAddon", function(teamColors)
        print("Updating scoreboard colors")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Set custom colors
    hook.Add("UpdateScoreboardColors", "CustomColors", function(teamColors)
        teamColors[1] = Color(255, 0, 0) -- Red
        teamColors[2] = Color(0, 255, 0) -- Green
        teamColors[3] = Color(0, 0, 255) -- Blue
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex scoreboard color system
    hook.Add("UpdateScoreboardColors", "AdvancedScoreboardColors", function(teamColors)
        if not teamColors then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

                local char = client:getChar()
                if not char then return end

                    -- Get faction colors
                    local faction = char:getFaction()
                    local factionColors = {
                    ["police"] = Color(0, 100, 255),
                    ["medic"] = Color(0, 255, 100),
                    ["citizen"] = Color(255, 255, 255),
                    ["criminal"] = Color(255, 100, 100)
                }

                -- Set faction color
                local factionColor = factionColors[faction] or Color(255, 255, 255)
                teamColors[1] = factionColor

                -- Set other team colors
                teamColors[2] = Color(100, 100, 100) -- Spectators
                teamColors[3] = Color(200, 200, 200) -- Admins

                -- Apply color scheme
                local colorScheme = lia.config.get("scoreboardColorScheme", "default")
                if colorScheme == "dark" then
                    for i, color in ipairs(teamColors) do
                        teamColors[i] = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
                    end
                    elseif colorScheme == "bright" then
                        for i, color in ipairs(teamColors) do
                            teamColors[i] = Color(math.min(255, color.r * 1.5), math.min(255, color.g * 1.5), math.min(255, color.b * 1.5))
                        end
                    end

                    -- Update scoreboard panel if it exists
                    if IsValid(lia.gui.scoreboard) then
                        lia.gui.scoreboard:UpdateColors(teamColors)
                    end
                end)
    ```
]]
function UpdateScoreboardColors(teamColors)
end

--[[
    Purpose:
        Called when a vendor is exited
    When Called:
        When a player closes a vendor
    Parameters:
        None
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor exit
    hook.Add("VendorExited", "MyAddon", function()
        print("Vendor exited")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Clean up vendor data
    hook.Add("VendorExited", "CleanupVendor", function()
        lia.vendor.current = nil
        lia.vendor.cache = {}
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor exit system
    hook.Add("VendorExited", "AdvancedVendorExit", function()
        local client = LocalPlayer()
        if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

                -- Clean up vendor data
                lia.vendor.current = nil
                lia.vendor.cache = {}

                    -- Save vendor interaction data
                    local vendorData = char:getData("vendorData", {})
                    vendorData.lastInteraction = os.time()
                    vendorData.totalInteractions = (vendorData.totalInteractions or 0) + 1
                    char:setData("vendorData", vendorData)

                    -- Close vendor UI
                    if IsValid(lia.gui.vendor) then
                        lia.gui.vendor:Close()
                    end

                    -- Notify player
                    lia.util.notify("Vendor closed", 2)

                    -- Log to database
                    lia.log.write("vendor_exit", {
                        steamid = client:SteamID(),
                        timestamp = os.time()
                        })

                        -- Update character stats
                        local vendorStats = char:getData("vendorStats", {})
                        vendorStats.exits = (vendorStats.exits or 0) + 1
                        char:setData("vendorStats", vendorStats)
                    end)
    ```
]]
function VendorExited()
end

--[[
    Purpose:
        Called when a vendor is synchronized
    When Called:
        When vendor data is synced between client and server
    Parameters:
        vendor (Entity) - The vendor entity
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log vendor sync
    hook.Add("VendorSynchronized", "MyAddon", function(vendor)
        print("Vendor synchronized: " .. tostring(vendor))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update vendor UI
    hook.Add("VendorSynchronized", "UpdateVendorUI", function(vendor)
        if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
            lia.gui.vendor:Populate()
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex vendor sync system
    hook.Add("VendorSynchronized", "AdvancedVendorSync", function(vendor)
        if not IsValid(vendor) then return end

            -- Update local vendor cache
            local vendorID = vendor:EntIndex()
            lia.vendor.cache = lia.vendor.cache or {}
                lia.vendor.cache[vendorID] = {
                    name = vendor:getNetVar("name", "Vendor"),
                    items = vendor:getNetVar("items", {}),
                        money = vendor:getNetVar("money", 0),
                        lastSync = CurTime()
                    }

                    -- Update UI if vendor panel is open
                    if IsValid(lia.gui.vendor) and lia.gui.vendor.vendor == vendor then
                        lia.gui.vendor:Populate()
                        lia.gui.vendor:UpdateMoney()
                    end

                    -- Notify player
                    local client = LocalPlayer()
                    if client:GetPos():Distance(vendor:GetPos()) < 200 then
                        lia.util.notify("Vendor inventory updated")
                    end
                end)
    ```
]]
function VendorSynchronized(vendor)
end

--[[
    Purpose:
        Called when voice chat is toggled
    When Called:
        When voice chat is enabled or disabled
    Parameters:
        enabled (boolean) - Whether voice chat is enabled
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log voice toggle
    hook.Add("VoiceToggled", "MyAddon", function(enabled)
        print("Voice chat " .. (enabled and "enabled" or "disabled"))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Show notification
    hook.Add("VoiceToggled", "NotifyVoiceToggle", function(enabled)
        lia.util.notify("Voice chat " .. (enabled and "enabled" or "disabled"))
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex voice toggle system
    hook.Add("VoiceToggled", "AdvancedVoiceToggle", function(enabled)
        -- Update UI
        if IsValid(lia.gui.voiceSettings) then
            lia.gui.voiceSettings:SetEnabled(enabled)
        end

        -- Save setting
        lia.data.set("voiceEnabled", enabled)

        -- Notify player
        lia.util.notify("Voice chat " .. (enabled and "enabled" or "disabled"), 3)

        -- Update voice icon
        if IsValid(lia.gui.voiceIcon) then
            lia.gui.voiceIcon:SetVisible(enabled)
        end

        -- Log the change
        lia.log.write("voice_toggle", {
            enabled = enabled,
            timestamp = os.time()
            })
        end)
    ```
]]
function VoiceToggled(enabled)
end

--[[
    Purpose:
        Called to get the weapon cycle sound
    When Called:
        When cycling through weapons
    Parameters:
        None
    Returns:
        string - The sound path
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default sound
    hook.Add("WeaponCycleSound", "MyAddon", function()
        return "common/wpn_select.wav"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Return custom sound based on settings
    hook.Add("WeaponCycleSound", "CustomCycleSound", function()
        local soundEnabled = lia.config.get("weaponSounds", true)
        if not soundEnabled then return "" end
            return "common/wpn_select.wav"
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon cycle sound system
    hook.Add("WeaponCycleSound", "AdvancedCycleSound", function()
        local client = LocalPlayer()
        if not IsValid(client) then return "common/wpn_select.wav" end

            -- Check if sounds are enabled
            local soundEnabled = lia.config.get("weaponSounds", true)
            if not soundEnabled then return "" end

                -- Get character-specific sound
                local char = client:getChar()
                if char then
                    local faction = char:getFaction()
                    local factionSounds = {
                    ["police"] = "hl1/fvox/blip.wav",
                    ["military"] = "buttons/button14.wav",
                    ["citizen"] = "common/wpn_select.wav"
                }
                return factionSounds[faction] or "common/wpn_select.wav"
            end

            return "common/wpn_select.wav"
        end)
    ```
]]
function WeaponCycleSound()
end

--[[
    Purpose:
        Called to get the weapon select sound
    When Called:
        When selecting a weapon
    Parameters:
        None
    Returns:
        string - The sound path
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return default sound
    hook.Add("WeaponSelectSound", "MyAddon", function()
        return "common/wpn_hudoff.wav"
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Return custom sound based on settings
    hook.Add("WeaponSelectSound", "CustomSelectSound", function()
        local soundEnabled = lia.config.get("weaponSounds", true)
        if not soundEnabled then return "" end
            return "common/wpn_hudoff.wav"
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex weapon select sound system
    hook.Add("WeaponSelectSound", "AdvancedSelectSound", function()
        local client = LocalPlayer()
        if not IsValid(client) then return "common/wpn_hudoff.wav" end

            -- Check if sounds are enabled
            local soundEnabled = lia.config.get("weaponSounds", true)
            if not soundEnabled then return "" end

                -- Get character-specific sound
                local char = client:getChar()
                if char then
                    local faction = char:getFaction()
                    local factionSounds = {
                    ["police"] = "hl1/fvox/activated.wav",
                    ["military"] = "buttons/button15.wav",
                    ["citizen"] = "common/wpn_hudoff.wav"
                }
                return factionSounds[faction] or "common/wpn_hudoff.wav"
            end

            return "common/wpn_hudoff.wav"
        end)
    ```
]]
function WeaponSelectSound()
end

--[[
    Purpose:
        Called when a web image is downloaded
    When Called:
        When an image from a URL is successfully downloaded
    Parameters:
        url (string) - The URL of the image
        material (Material) - The downloaded material
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log image download
    hook.Add("WebImageDownloaded", "MyAddon", function(url, material)
        print("Image downloaded: " .. url)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Cache downloaded images
    hook.Add("WebImageDownloaded", "CacheImages", function(url, material)
        lia.webImage.cache = lia.webImage.cache or {}
            lia.webImage.cache[url] = material
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex web image system
    hook.Add("WebImageDownloaded", "AdvancedWebImage", function(url, material)
        -- Cache the material
        lia.webImage.cache = lia.webImage.cache or {}
            lia.webImage.cache[url] = material

            -- Update any panels waiting for this image
            for _, panel in ipairs(lia.webImage.waiting[url] or {}) do
                if IsValid(panel) then
                    panel:SetMaterial(material)
                    panel:InvalidateLayout()
                end
            end

            -- Clear waiting list
            lia.webImage.waiting[url] = nil

            -- Log download
            lia.log.write("web_image_download", {
                url = url,
                timestamp = os.time()
                })

                -- Notify completion
                hook.Run("OnWebImageReady", url, material)
            end)
    ```
]]
function WebImageDownloaded(url, material)
end

--[[
    Purpose:
        Called when a web sound is downloaded
    When Called:
        When a sound from a URL is successfully downloaded
    Parameters:
        name (string) - The name of the sound
        path (string) - The path to the downloaded sound
    Returns:
        None
    Realm:
        Client
    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log sound download
    hook.Add("WebSoundDownloaded", "MyAddon", function(name, path)
        print("Sound downloaded: " .. name)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Cache downloaded sounds
    hook.Add("WebSoundDownloaded", "CacheSounds", function(name, path)
        lia.webSound.cache = lia.webSound.cache or {}
            lia.webSound.cache[name] = path
        end)
    ```

    High Complexity:

    ```lua
    -- High: Complex web sound system
    hook.Add("WebSoundDownloaded", "AdvancedWebSound", function(name, path)
        -- Cache the sound
        lia.webSound.cache = lia.webSound.cache or {}
            lia.webSound.cache[name] = path

            -- Update any sounds waiting for this file
            for _, soundData in ipairs(lia.webSound.waiting[name] or {}) do
                if soundData.callback then
                    soundData.callback(path)
                end
            end

            -- Clear waiting list
            lia.webSound.waiting[name] = nil

            -- Log download
            lia.log.write("web_sound_download", {
                name = name,
                path = path,
                timestamp = os.time()
                })

                -- Notify completion
                hook.Run("OnWebSoundReady", name, path)
            end)
    ```
]]
function WebSoundDownloaded(name, path)
end
