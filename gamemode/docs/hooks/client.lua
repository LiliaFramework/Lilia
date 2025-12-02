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
        Allows adding custom fields to the HUD bars system.

    When Called:
        When the HUD bars are being initialized or updated.

    Parameters:
        sectionName (string)
            The name of the section to add the field to.
        fieldName (string)
            The unique name of the field.
        labelText (string)
            The display text for the field.
        minFunc (function)
            Function that returns the minimum value.
        maxFunc (function)
            Function that returns the maximum value.
        valueFunc (function)
            Function that returns the current value.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a basic health bar field
        hook.Add("InitializedModules", "AddHealthBar", function()
            hook.Run("AddBarField", "Stats", "health", "Health",
                function() return 0 end,
                function() return 100 end,
                function() return LocalPlayer():Health() end)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add a stamina field with character validation
        hook.Add("InitializedModules", "AddStaminaBar", function()
            hook.Run("AddBarField", "Stats", "stamina", "Stamina",
                function() return 0 end,
                function() return 100 end,
                function()
                    local char = LocalPlayer():getChar()
                    return char and char:getStamina() or 0
                end)
        end)
        ```

    High Complexity:
        ```lua
        -- High: Add multiple dynamic fields with configuration checks
        hook.Add("InitializedModules", "AddCustomBars", function()
            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return end

            -- Add hunger bar if food system is enabled
            if lia.config.get("HungerSystem") then
                hook.Run("AddBarField", "Needs", "hunger", "Hunger",
                    function() return 0 end,
                    function() return 100 end,
                    function() return client:getHunger() or 0 end)
            end

            -- Add thirst bar with dynamic max based on character
            hook.Run("AddBarField", "Needs", "thirst", "Thirst",
                function() return 0 end,
                function() return char:getMaxThirst() or 100 end,
                function() return client:getThirst() or 0 end)
        end)
        ```
]]
function AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
end

--[[
    Purpose:
        Allows adding custom sections to the HUD bars system.

    When Called:
        When the HUD bars are being initialized.

    Parameters:
        sectionName (string)
            The unique name of the section.
        color (Color)
            The color of the section.
        priority (number)
            The display priority/order of the section.
        location (string)
            The location where the section should be displayed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a basic stats section
        hook.Add("InitializedModules", "AddStatsSection", function()
            hook.Run("AddSection", "Stats", Color(50, 50, 50), 1, 1)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add a colored section with specific priority
        hook.Add("InitializedModules", "AddHealthSection", function()
            hook.Run("AddSection", "Health", Color(255, 0, 0), 2, 1)

            -- Add a field to the section
            hook.Run("AddBarField", "Health", "hp", "Health",
                function() return 0 end,
                function() return 100 end,
                function() return LocalPlayer():Health() end)
        end)
        ```

    High Complexity:
        ```lua
        -- High: Add multiple sections with dynamic colors and priorities
        hook.Add("InitializedModules", "AddDynamicSections", function()
            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return end

            -- Primary stats section with high priority
            hook.Run("AddSection", "Primary Stats", Color(34, 139, 34), 1, 1)

            -- Secondary stats section with lower priority
            hook.Run("AddSection", "Secondary Stats", Color(70, 130, 180), 3, 1)

            -- Add fields based on character class or faction
            local faction = char:getFaction()
            if faction == FACTION_MEDIC then
                hook.Run("AddSection", "Medical Stats", Color(255, 20, 147), 2, 1)
            elseif faction == FACTION_POLICE then
                hook.Run("AddSection", "Law Stats", Color(0, 0, 139), 2, 1)
            end
        end)
        ```
]]
function AddSection(sectionName, color, priority, location)
end

--[[
    Purpose:
        Allows adding custom text fields to the HUD bars system.

    When Called:
        When the HUD bars are being initialized or updated.

    Parameters:
        sectionName (string)
            The name of the section to add the field to.
        fieldName (string)
            The unique name of the field.
        labelText (string)
            The display text for the field.
        valueFunc (function)
            Function that returns the current value.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a basic name field
        hook.Add("LoadCharInformation", "AddNameField", function()
            hook.Run("AddTextField", "Info", "characterName", "Name", function()
                local char = LocalPlayer():getChar()
                return char and char:getName() or "Unknown"
            end)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted money display
        hook.Add("LoadCharInformation", "AddMoneyField", function()
            hook.Run("AddTextField", "Info", "wallet", "Money", function()
                local client = LocalPlayer()
                local char = client:getChar()
                if not char then return "$0" end

                local money = char:getMoney()
                return lia.currency.get(money)
            end)
        end)
        ```

    High Complexity:
        ```lua
        -- High: Add multiple dynamic fields with conditional display
        hook.Add("LoadCharInformation", "AddCharacterStats", function()
            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return end

            -- Basic info fields
            hook.Run("AddTextField", "Character", "name", "Full Name", function()
                return char:getName()
            end)

            hook.Run("AddTextField", "Character", "description", "Description", function()
                return char:getDesc():sub(1, 50) .. (char:getDesc():len() > 50 and "..." or "")
            end)

            -- Play time with formatting
            hook.Run("AddTextField", "Statistics", "playtime", "Play Time", function()
                return lia.time.formatDHM(client:getPlayTime())
            end)

            -- Faction-specific field
            local faction = lia.faction.get(char:getFaction())
            if faction then
                hook.Run("AddTextField", "Character", "faction", "Faction", function()
                    return L(faction.name)
                end)
            end

            -- Class information if available
            local classID = char:getClass()
            if classID and classID > 0 then
                local classData = lia.class.get(classID)
                if classData then
                    hook.Run("AddTextField", "Character", "class", "Class", function()
                        return L(classData.name)
                    end)
                end
            end
        end)
        ```
]]
function AddTextField(sectionName, fieldName, labelText, valueFunc)
end

--[[
    Purpose:
        Adds information to the admin stick HUD display for a target player.

    When Called:
        When displaying admin stick information for a player.

    Parameters:
        client (Player)
            The admin viewing the information.
        target (Player)
            The player being viewed.
        information (table)
            Table containing information to display.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic player information
        function MODULE:AddToAdminStickHUD(client, target, information)
            if not target:IsPlayer() then return end

            local char = target:getChar()
            if char then
                table.insert(information, "Character: " .. char:getName())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted player stats
        function MODULE:AddToAdminStickHUD(client, target, information)
            if not target:IsPlayer() then return end

            local char = target:getChar()
            if char then
                table.insert(information, "Name: " .. char:getName())
                table.insert(information, "Faction: " .. (lia.faction.get(char:getFaction()) and lia.faction.get(char:getFaction()).name or "Unknown"))
                table.insert(information, "Money: " .. lia.currency.get(char:getMoney()))
                table.insert(information, "Health: " .. target:Health() .. "/" .. target:GetMaxHealth())
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Add comprehensive entity information with conditional data
        function MODULE:AddToAdminStickHUD(client, target, information)
            -- Handle players
            if target:IsPlayer() then
                local char = target:getChar()
                if char then
                    table.insert(information, "=== PLAYER INFO ===")
                    table.insert(information, "SteamID: " .. target:SteamID())
                    table.insert(information, "Character: " .. char:getName())
                    table.insert(information, "Faction: " .. (lia.faction.get(char:getFaction()) and lia.faction.get(char:getFaction()).name or "Unknown"))

                    local classID = char:getClass()
                    if classID and classID > 0 then
                        local classData = lia.class.get(classID)
                        if classData then
                            table.insert(information, "Class: " .. classData.name)
                        end
                    end

                    table.insert(information, "Money: " .. lia.currency.get(char:getMoney()))
                    table.insert(information, "Play Time: " .. lia.time.formatDHM(target:getPlayTime()))
                end
            -- Handle vendors
            elseif target.IsVendor then
                table.insert(information, "=== VENDOR INFO ===")
                local name = target:getName()
                if name and name ~= "" then
                    table.insert(information, "Name: " .. name)
                end

                local itemCount = 0
                if target.items then
                    for _, itemData in pairs(target.items) do
                        if itemData[1] and itemData[1] > 0 then -- VENDOR_STOCK
                            itemCount = itemCount + 1
                        end
                    end
                end
                table.insert(information, "Items in stock: " .. itemCount)
            -- Handle doors
            elseif target:isDoor() then
                table.insert(information, "=== DOOR INFO ===")
                local doorData = target:lia.doors.getData(target)
                if doorData.name and doorData.name ~= "" then
                    table.insert(information, "Name: " .. doorData.name)
                end
                table.insert(information, "Price: " .. lia.currency.get(doorData.price or 0))
                table.insert(information, "Locked: " .. (doorData.locked and "Yes" or "No"))
            end
        end
        ```
]]
function AddToAdminStickHUD(client, target, information)
end

--[[
    Purpose:
        Handles attaching PAC3 parts to players.

    When Called:
        When a PAC3 part is being attached to a player.

    Parameters:
        client (Player)
            The player attaching the part.
        id (string)
            The PAC3 part ID.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic PAC part attachment with logging
        function MODULE:AttachPart(client, id)
            print("Attaching PAC part " .. id .. " to " .. client:Name())

            -- Default PAC attachment would happen here
            -- This is called after GetAdjustedPartData modifications
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Custom attachment logic with validation
        function MODULE:AttachPart(client, id)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Check if player has permission for this part
            local item = lia.item.list[id]
            if item and item.pacRequiredFlag then
                if not char:hasFlags(item.pacRequiredFlag) then
                    client:notify("You don't have permission to equip this item!")
                    return
                end
            end

            -- Log attachment for admins
            if lia.config.get("LogPACAttachments") then
                lia.log.add(client:Name() .. " equipped PAC part: " .. id, FLAG_NORMAL)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced attachment system with effects and restrictions
        function MODULE:AttachPart(client, id)
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            local item = lia.item.list[id]
            if not item then return end

            -- Faction/class restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.restrictedPAC then
                if table.HasValue(faction.restrictedPAC, id) then
                    client:notify("Your faction cannot equip this item!")
                    return
                end
            end

            -- Class restrictions
            local classID = char:getClass()
            if classID then
                local class = lia.class.get(classID)
                if class and class.restrictedPAC and table.HasValue(class.restrictedPAC, id) then
                    client:notify("Your class cannot equip this item!")
                    return
                end
            end

            -- Check PAC part limit
            local currentParts = client:getParts()
            local maxParts = lia.config.get("MaxPACParts", 10)
            if table.Count(currentParts) >= maxParts then
                client:notify("You have reached the maximum number of PAC parts!")
                return
            end

            -- Seasonal restrictions
            local currentDate = os.date("*t")
            if item.seasonal and item.seasonal ~= currentDate.month then
                client:notify("This item is not available during this season!")
                return
            end

            -- Apply attachment effects
            if item.onPACAttach then
                item:onPACAttach(client)
            end

            -- Play attachment sound
            if item.attachSound then
                client:EmitSound(item.attachSound)
            end

            -- Visual effects
            if item.attachEffect then
                local effect = EffectData()
                effect:SetEntity(client)
                effect:SetOrigin(client:GetPos())
                util.Effect(item.attachEffect, effect)
            end

            -- Notify nearby players
            if lia.config.get("AnnouncePACAttachments") then
                for _, ply in player.Iterator() do
                    if ply:GetPos():Distance(client:GetPos()) <= 500 and ply ~= client then
                        ply:notify(client:Name() .. " equipped " .. (item.name or id))
                    end
                end
            end

            -- Update player appearance cache
            client.liaLastPACUpdate = CurTime()

            -- Log detailed attachment info
            lia.log.add(string.format("PAC Attachment: %s equipped %s (Faction: %s, Class: %s)",
                client:Name(), id,
                faction and faction.name or "Unknown",
                class and class.name or "None"), FLAG_NORMAL)
        end
        ```
]]
function AttachPart(client, id)
end

--[[
    Purpose:
        Determines if the bag inventory panel can be opened.

    When Called:
        When a player attempts to open a bag inventory.

    Parameters:
        item (Item)
            The bag item.

    Returns:
        boolean
            Whether the bag panel can be opened.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic bag panel check
        function MODULE:CanOpenBagPanel(item)
            if not item then return false end

            local client = LocalPlayer()
            local char = client:getChar()
            return char ~= nil -- Allow opening if player has a character
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Distance and ownership checks
        function MODULE:CanOpenBagPanel(item)
            if not item then return false end

            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return false end

            -- Check if bag belongs to player
            local bagOwner = item:getOwner()
            if bagOwner and bagOwner ~= client then
                return false -- Can't open someone else's bag
            end

            -- Check distance to bag
            local bagEntity = item:getEntity()
            if IsValid(bagEntity) then
                local maxDistance = 200
                if client:GetPos():Distance(bagEntity:GetPos()) > maxDistance then
                    return false -- Too far from bag
                end
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced bag access with multiple restrictions
        function MODULE:CanOpenBagPanel(item)
            if not item then return false end

            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false
            end

            -- Check bag ownership
            local bagOwner = item:getOwner()
            if bagOwner then
                if bagOwner ~= client then
                    -- Check if player can access others' bags (admin, etc.)
                    if not client:hasPrivilege("Staff Permissions") then
                        -- Check if it's a shared bag (party, faction, etc.)
                        local bagAccess = item:getData("sharedAccess", {})
                        if not table.HasValue(bagAccess, char:getID()) and
                           not table.HasValue(bagAccess, char:getFaction()) then
                            return false
                        end
                    end
                end
            end

            -- Check bag entity validity and distance
            local bagEntity = item:getEntity()
            if IsValid(bagEntity) then
                local maxDistance = lia.config.get("bagOpenDistance", 200)
                local distance = client:GetPos():Distance(bagEntity:GetPos())

                if distance > maxDistance then
                    return false
                end

                -- Check line of sight
                if lia.config.get("bagRequireLineOfSight", true) then
                    local trace = util.TraceLine({
                        start = client:EyePos(),
                        endpos = bagEntity:EyePos(),
                        filter = {client, bagEntity}
                    })

                    if trace.Hit then
                        return false -- No line of sight
                    end
                end

                -- Check if bag is locked
                if bagEntity:getNetVar("locked", false) then
                    -- Check if player has key or can lockpick
                    if not item:getData("hasKey", false) and not char:hasFlags("L") then -- Lockpick flag
                        return false
                    end
                end
            end

            -- Check wanted status
            if char:getData("wanted", false) and lia.config.get("wantedCantOpenBags") then
                return false
            end

            -- Check faction restrictions
            local bagFaction = item:getData("faction")
            if bagFaction and bagFaction ~= char:getFaction() then
                return false
            end

            -- Check bag durability/health
            local bagHealth = item:getData("health", 100)
            if bagHealth <= 0 then
                return false -- Bag is destroyed
            end

            -- Check time restrictions
            local timeRestriction = item:getData("timeRestriction")
            if timeRestriction then
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < timeRestriction.start or currentMinutes > timeRestriction.end then
                    return false
                end
            end

            -- Check if bag is in use by someone else
            if item:getData("inUse", false) then
                local inUseBy = item:getData("inUseBy")
                if inUseBy and inUseBy ~= client then
                    return false
                end
            end

            -- Mark bag as in use
            item:setData("inUse", true)
            item:setData("inUseBy", client)

            -- Log bag access
            lia.log.add(client:Name() .. " opened bag: " .. item.name, FLAG_NORMAL)

            return true
        end
        ```
]]
function CanOpenBagPanel(item)
end

--[[
    Purpose:
        Handles drawing character information on the screen.

    When Called:
        When character information needs to be drawn.

    Parameters:
        player (Player)
            The player whose character info to draw.
        character (Character)
            The character data.
        info (table)
            Information to display.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw basic character name
        function MODULE:DrawCharInfo(player, character, info)
            draw.SimpleText(character:getName(), "LiliaFont.20", 10, 10, color_white)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw character info with faction and class
        function MODULE:DrawCharInfo(player, character, info)
            local name = character:getName()
            local faction = lia.faction.get(character:getFaction())
            local class = lia.class.get(character:getClass())

            draw.SimpleText(name, "LiliaFont.20", 10, 10, color_white)
            if faction then
                draw.SimpleText(faction.name, "LiliaFont.17", 10, 30, faction.color or color_white)
            end
            if class then
                draw.SimpleText(class.name, "LiliaFont.17", 10, 50, color_white)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character info display with custom formatting
        function MODULE:DrawCharInfo(player, character, info)
            if not IsValid(player) or not character then return end

            local pos = player:GetPos() + Vector(0, 0, 80)
            local screenPos = pos:ToScreen()
            if not screenPos.visible then return end

            local name = character:getName()
            local faction = lia.faction.get(character:getFaction())
            local class = lia.class.get(character:getClass())
            local money = character:getMoney()

            -- Custom background panel
            local bgAlpha = 200
            draw.RoundedBox(4, screenPos.x - 100, screenPos.y - 40, 200, 80, Color(0, 0, 0, bgAlpha))

            -- Name with title if available
            local displayName = name
            if character:getData("title") then
                displayName = character:getData("title") .. " " .. name
            end
            draw.SimpleTextOutlined(displayName, "LiliaFont.20", screenPos.x, screenPos.y - 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

            -- Faction and class info
            local yOffset = 10
            if faction then
                draw.SimpleTextOutlined(faction.name, "LiliaFont.17", screenPos.x, screenPos.y - 10, faction.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                yOffset = yOffset + 15
            end
            if class then
                draw.SimpleTextOutlined(class.name, "LiliaFont.17", screenPos.x, screenPos.y + yOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
            end

            -- Custom info from hook data
            if info and info.custom then
                for i, customInfo in ipairs(info.custom) do
                    draw.SimpleTextOutlined(customInfo.text, "LiliaFont.17", screenPos.x, screenPos.y + yOffset + (i * 15), customInfo.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                end
            end
        end
        ```
]]
function DrawCharInfo(player, character, info)
end

--[[
    Purpose:
        Handles drawing door information boxes.

    When Called:
        When door information needs to be displayed.

    Parameters:
        entity (Entity)
            The door entity.
        infoTexts (table)
            Table of information text to display.
        alphaOverride (number)
            Optional alpha override value.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom text to door info
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            table.insert(infoTexts, "Custom Door Information")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted door information
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            local doorData = lia.doors.getData(entity)
            if doorData then
                if doorData.title then
                    table.insert(infoTexts, "Title: " .. doorData.title)
                end
                if doorData.owner then
                    table.insert(infoTexts, "Owner: " .. doorData.owner)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door info display with custom styling
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            if not IsValid(entity) then return end

            local doorData = lia.doors.getData(entity)
            local alpha = alphaOverride or 255

            -- Add door title if available
            if doorData and doorData.title then
                table.insert(infoTexts, {
                    text = doorData.title,
                    color = Color(255, 255, 0, alpha),
                    font = "LiliaFont.20"
                })
            end

            -- Add ownership info
            if doorData and doorData.owner then
                local owner = player.GetBySteamID(doorData.owner)
                if IsValid(owner) then
                    local char = owner:getChar()
                    if char then
                        table.insert(infoTexts, {
                            text = "Owner: " .. char:getName(),
                            color = Color(200, 200, 200, alpha),
                            font = "LiliaFont.17"
                        })
                    end
                end
            end

            -- Add lock status
            if entity:getNetVar("locked", false) then
                table.insert(infoTexts, {
                    text = "Locked",
                    color = Color(255, 0, 0, alpha),
                    font = "LiliaFont.17"
                })
            else
                table.insert(infoTexts, {
                    text = "Unlocked",
                    color = Color(0, 255, 0, alpha),
                    font = "LiliaFont.17"
                })
            end
        end
        ```
]]
function DrawDoorInfoBox(entity, infoTexts, alphaOverride)
end

--[[
    Purpose:
        Handles drawing entity information overlays.

    When Called:
        When entity information should be drawn.

    Parameters:
        entity (Entity)
            The entity to draw info for.
        alpha (number)
            The alpha/transparency value.
        position (Vector)
            The position to draw at.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw basic entity name
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if IsValid(entity) then
                draw.SimpleText(entity:GetClass(), "LiliaFont.17", position.x, position.y, Color(255, 255, 255, alpha))
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw entity info with custom formatting
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if not IsValid(entity) then return end

            local screenPos = position:ToScreen()
            if not screenPos.visible then return end

            local name = entity:GetClass()
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    name = char:getName()
                end
            end

            draw.SimpleTextOutlined(name, "LiliaFont.17", screenPos.x, screenPos.y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced entity info display with multiple data points
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if not IsValid(entity) then return end

            local screenPos = position:ToScreen()
            if not screenPos.visible then return end

            local yOffset = 0
            local infoColor = Color(255, 255, 255, alpha)

            -- Draw entity class/name
            local displayName = entity:GetClass()
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    displayName = char:getName()
                    local faction = lia.faction.get(char:getFaction())
                    if faction then
                        infoColor = faction.color or infoColor
                    end
                end
            elseif entity:IsVehicle() then
                displayName = entity:GetDisplayName() or entity:GetClass()
            end

            draw.SimpleTextOutlined(displayName, "LiliaFont.20", screenPos.x, screenPos.y + yOffset, infoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            yOffset = yOffset + 20

            -- Draw health if applicable
            if entity:Health() and entity:GetMaxHealth() and entity:GetMaxHealth() > 0 then
                local healthPercent = math.Clamp(entity:Health() / entity:GetMaxHealth(), 0, 1)
                local healthColor = Color(255 * (1 - healthPercent), 255 * healthPercent, 0, alpha)
                draw.SimpleTextOutlined("HP: " .. entity:Health() .. "/" .. entity:GetMaxHealth(), "LiliaFont.17", screenPos.x, screenPos.y + yOffset, healthColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
                yOffset = yOffset + 15
            end

            -- Draw custom entity data
            local customData = entity:getNetVar("customInfo")
            if customData then
                for i, data in ipairs(customData) do
                    draw.SimpleTextOutlined(data.text, "LiliaFont.17", screenPos.x, screenPos.y + yOffset, data.color or infoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
                    yOffset = yOffset + 15
                end
            end
        end
        ```
]]
function DrawEntityInfo(entity, alpha, position)
end

--[[
    Purpose:
        Handles drawing the Lilia model view in UI panels.

    When Called:
        When a model view needs to be drawn in a panel.

    Parameters:
        panel (Panel)
            The panel containing the model view.
        entity (Entity)
            The entity being displayed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom lighting to model view
        function MODULE:DrawLiliaModelView(panel, entity)
            if IsValid(entity) then
                render.SetLightingMode(1)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply custom materials and effects
        function MODULE:DrawLiliaModelView(panel, entity)
            if not IsValid(entity) then return end

            -- Apply character-specific material if available
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    local outfit = char:getData("outfit")
                    if outfit and outfit.material then
                        entity:SetMaterial(outfit.material)
                    end
                end
            end

            -- Set custom lighting
            render.SetLightingMode(1)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model view with animations and effects
        function MODULE:DrawLiliaModelView(panel, entity)
            if not IsValid(entity) or not IsValid(panel) then return end

            -- Store original entity state
            local originalPos = entity:GetPos()
            local originalAng = entity:GetAngles()
            local originalSequence = entity:GetSequence()

            -- Apply character customization
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    -- Apply outfit
                    local outfit = char:getData("outfit")
                    if outfit then
                        if outfit.material then
                            entity:SetMaterial(outfit.material)
                        end
                        if outfit.color then
                            entity:SetColor(outfit.color)
                        end
                    end

                    -- Apply PAC parts
                    local pacData = char:getData("pacData")
                    if pacData then
                        for _, part in ipairs(pacData) do
                            hook.Run("AttachPart", entity, part.id)
                        end
                    end

                    -- Set animation
                    if outfit and outfit.sequence then
                        entity:SetSequence(outfit.sequence)
                    end
                end
            end

            -- Custom lighting setup
            render.SetLightingMode(1)
            local lightPos = entity:GetPos() + Vector(0, 0, 50)
            render.SetLightPosition(lightPos)
            render.SetLightColor(Vector(1, 1, 1))

            -- Draw the model
            entity:DrawModel()

            -- Restore original state
            entity:SetPos(originalPos)
            entity:SetAngles(originalAng)
            if originalSequence then
                entity:SetSequence(originalSequence)
            end
        end
        ```
]]
function DrawLiliaModelView(panel, entity)
end

--[[
    Purpose:
        Handles drawing player ragdolls.

    When Called:
        When a player ragdoll needs to be rendered.

    Parameters:
        entity (Entity)
            The ragdoll entity.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw ragdoll normally
        function MODULE:DrawPlayerRagdoll(entity)
            if IsValid(entity) then
                entity:DrawModel()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw ragdoll with custom rendering
        function MODULE:DrawPlayerRagdoll(entity)
            if not IsValid(entity) then return end

            -- Apply custom material if available
            if entity:getNetVar("customMaterial") then
                entity:SetMaterial(entity:getNetVar("customMaterial"))
            end

            entity:DrawModel()

            -- Draw blood decals
            if entity:getNetVar("hasBlood") then
                render.SetMaterial(Material("decals/blood1"))
                render.DrawDecal(entity:GetPos(), entity:GetAngles(), "blood", 64, 64)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ragdoll rendering with effects
        function MODULE:DrawPlayerRagdoll(entity)
            if not IsValid(entity) then return end

            local owner = entity:GetRagdollOwner()
            if not IsValid(owner) then
                owner = entity:getNetVar("player")
            end

            if not IsValid(owner) then
                entity:DrawModel()
                return
            end

            -- Get character data
            local character = owner:getChar()
            if not character then
                entity:DrawModel()
                return
            end

            -- Apply character-specific materials
            local outfit = character:getData("outfit")
            if outfit and outfit.material then
                entity:SetMaterial(outfit.material)
            end

            -- Draw base model
            entity:DrawModel()

            -- Draw PAC attachments if available
            if character:getData("pacData") then
                local pacData = character:getData("pacData")
                for _, part in ipairs(pacData) do
                    if part.model then
                        render.SetMaterial(Material(part.model))
                        render.DrawQuadEasy(
                            entity:GetPos() + part.position,
                            part.angle:Forward(),
                            part.size or 1,
                            part.size or 1,
                            part.color or color_white
                        )
                    end
                end
            end

            -- Draw death effects
            local deathTime = entity:getNetVar("deathTime", 0)
            if deathTime > 0 then
                local timeSinceDeath = CurTime() - deathTime
                if timeSinceDeath < 5 then
                    -- Fade out effect
                    local alpha = math.Clamp(255 * (1 - (timeSinceDeath / 5)), 0, 255)
                    render.SetBlend(alpha / 255)
                    entity:DrawModel()
                    render.SetBlend(1)
                end

                -- Draw blood pool
                if timeSinceDeath < 10 then
                    render.SetMaterial(Material("effects/blood_pool"))
                    render.DrawQuadEasy(
                        entity:GetPos() - Vector(0, 0, 50),
                        Vector(0, 0, 1),
                        64,
                        64,
                        Color(150, 0, 0, 200 * (1 - (timeSinceDeath / 10)))
                    )
                end
            end

            -- Draw identification tag
            if character:getData("showID") then
                local pos = entity:GetPos() + Vector(0, 0, 10)
                local screenPos = pos:ToScreen()
                if screenPos.visible then
                    draw.SimpleTextOutlined(character:getName(), "LiliaFont.17", screenPos.x, screenPos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                end
            end
        end
        ```
]]
function DrawPlayerRagdoll(entity)
end

--[[
    Purpose:
        Handles displaying player HUD information.

    When Called:
        When player HUD information needs to be updated.

    Parameters:
        client (Player)
            The player whose HUD to update.
        hudInfos (table)
            Table of HUD information to display.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log HUD information display
        function MODULE:DisplayPlayerHUDInformation(client, hudInfos)
            print("Displaying HUD info for " .. client:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic HUD information processing
        function MODULE:DisplayPlayerHUDInformation(client, hudInfos)
            -- Process health information
            if hudInfos.health then
                self:UpdateHealthDisplay(client, hudInfos.health)
            end

            -- Process armor information
            if hudInfos.armor then
                self:UpdateArmorDisplay(client, hudInfos.armor)
            end

            -- Process stamina information
            if hudInfos.stamina then
                self:UpdateStaminaDisplay(client, hudInfos.stamina)
            end

            -- Log HUD update
            lia.log.add("HUD information updated for " .. client:Name(), FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced HUD information management and customization
        function MODULE:DisplayPlayerHUDInformation(client, hudInfos)
            -- Validate HUD information
            if not self:ValidateHUDInfo(hudInfos) then
                lia.log.add("Invalid HUD information provided", FLAG_WARNING)
                return
            end

            -- Process character-specific information
            local character = client:getChar()
            if character then
                hudInfos = self:EnhanceHUDWithCharacterInfo(client, character, hudInfos)
            end

            -- Apply faction-specific HUD modifications
            if character and character:getFaction() then
                hudInfos = self:ApplyFactionHUDMods(character:getFaction(), hudInfos)
            end

            -- Handle class-specific HUD elements
            if character and character:getClass() then
                hudInfos = self:ApplyClassHUDMods(character:getClass(), hudInfos)
            end

            -- Process equipment-based HUD modifications
            hudInfos = self:ApplyEquipmentHUDMods(client, hudInfos)

            -- Update custom HUD elements
            self:UpdateCustomHUDElements(client, hudInfos)

            -- Handle HUD animations and transitions
            self:ProcessHUDTransitions(client, hudInfos)

            -- Update minimap and radar information
            self:UpdateMinimapData(client, hudInfos)

            -- Process status effect indicators
            self:UpdateStatusEffects(client, hudInfos)

            -- Handle HUD visibility settings
            self:ApplyHUDVisibilitySettings(client, hudInfos)

            -- Update HUD layout based on preferences
            self:ApplyHUDLayoutPreferences(client, hudInfos)

            -- Process real-time information updates
            self:ProcessRealtimeHUDUpdates(client, hudInfos)

            -- Log comprehensive HUD update
            self:LogHUDUpdate(client, hudInfos)

            -- Trigger post-HUD update hooks
            hook.Run("OnHUDInformationDisplayed", client, hudInfos)
        end

        -- Helper function to validate HUD info
        function MODULE:ValidateHUDInfo(hudInfos)
            if not hudInfos then return false end

            -- Check for required fields
            if hudInfos.health and (not isnumber(hudInfos.health) or hudInfos.health < 0) then
                return false
            end

            return true
        end

        -- Helper function to enhance HUD with character info
        function MODULE:EnhanceHUDWithCharacterInfo(client, character, hudInfos)
            -- Add character name
            hudInfos.characterName = character:getName()

            -- Add faction information
            hudInfos.faction = character:getFaction()

            -- Add class information
            hudInfos.class = character:getClass()

            -- Add money information
            hudInfos.money = character:getMoney()

            return hudInfos
        end
        ```
]]
function DisplayPlayerHUDInformation(client, hudInfos)
end

--[[
    Purpose:
        Handles drawing the physgun beam.

    When Called:
        Before the physgun beam is drawn.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Customize beam color
        function MODULE:PreDrawPhysgunBeam()
            local weapon = LocalPlayer():GetActiveWeapon()
            if IsValid(weapon) and weapon:GetClass() == "weapon_physgun" then
                render.SetColorModulation(1, 0, 0) -- Red beam
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Custom beam appearance based on player
        function MODULE:PreDrawPhysgunBeam()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local weapon = client:GetActiveWeapon()
            if not IsValid(weapon) or weapon:GetClass() ~= "weapon_physgun" then return end

            local character = client:getChar()
            if not character then return end

            local faction = lia.faction.get(character:getFaction())
            if faction and faction.color then
                local color = faction.color
                render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced beam customization with effects
        function MODULE:PreDrawPhysgunBeam()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local weapon = client:GetActiveWeapon()
            if not IsValid(weapon) or weapon:GetClass() ~= "weapon_physgun" then return end

            local character = client:getChar()
            if not character then return end

            -- Get beam color from character/faction
            local beamColor = Color(255, 255, 255)
            local faction = lia.faction.get(character:getFaction())
            if faction and faction.color then
                beamColor = faction.color
            end

            -- Apply custom color modulation
            render.SetColorModulation(beamColor.r / 255, beamColor.g / 255, beamColor.b / 255)

            -- Apply custom material if available
            local customBeam = character:getData("customPhysgunBeam")
            if customBeam and customBeam.material then
                render.SetMaterial(Material(customBeam.material))
            end

            -- Add trail effect
            if character:getData("physgunTrail") then
                local tr = util.TraceLine({
                    start = client:GetShootPos(),
                    endpos = client:GetShootPos() + client:GetAimVector() * 4096,
                    filter = client
                })

                if tr.Hit then
                    local effectData = EffectData()
                    effectData:SetOrigin(tr.HitPos)
                    effectData:SetNormal(tr.HitNormal)
                    effectData:SetColor(beamColor.r, beamColor.g, beamColor.b)
                    util.Effect("physgun_trail", effectData)
                end
            end

            -- Apply beam width modification
            local beamWidth = character:getData("physgunBeamWidth", 1)
            if beamWidth ~= 1 then
                render.SetBlend(beamWidth)
            end
        end
        ```
]]
function PreDrawPhysgunBeam()
end

--[[
    Purpose:
        Determines if a player can open the scoreboard.

    When Called:
        When a player attempts to open the scoreboard.

    Parameters:
        client (Player)
            The player attempting to open the scoreboard.

    Returns:
        boolean
            Whether the scoreboard can be opened.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow scoreboard
        function MODULE:CanPlayerOpenScoreboard(client)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restrict during certain game modes
        function MODULE:CanPlayerOpenScoreboard(client)
            -- Don't allow scoreboard during cinematic scenes
            if lia.config.get("cinematicMode", false) then
                return false
            end

            -- Don't allow during combat
            if client:getNetVar("inCombat", false) then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced scoreboard access control
        function MODULE:CanPlayerOpenScoreboard(client)
            if not IsValid(client) then return false end

            -- Check if player has a character
            local char = client:getChar()
            if not char then return false end

            -- Check wanted status (wanted players might have restricted access)
            if char:getData("wanted", false) then
                return false
            end

            -- Check if player is in a restricted area
            local pos = client:GetPos()
            if lia.config.get("scoreboardRestrictedZones") then
                for _, zone in ipairs(lia.config.get("scoreboardRestrictedZones")) do
                    if pos:WithinAABox(zone.min, zone.max) then
                        return false
                    end
                end
            end

            -- Check faction restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.restrictScoreboard then
                return false
            end

            -- Check time restrictions (during events, etc.)
            if lia.config.get("scoreboardTimeRestrictions") then
                local restrictions = lia.config.get("scoreboardTimeRestrictions")
                local currentTime = os.date("*t")
                local currentMinutes = currentTime.hour * 60 + currentTime.min

                if currentMinutes < restrictions.start or currentMinutes > restrictions.end then
                    return false
                end
            end

            -- Check if player is in a vehicle (optional restriction)
            if client:InVehicle() and lia.config.get("restrictScoreboardInVehicle", false) then
                return false
            end

            -- Check if player has required permission flag
            if lia.config.get("scoreboardRequiresFlag") then
                local requiredFlag = lia.config.get("scoreboardFlag", "S")
                if not char:hasFlags(requiredFlag) then
                    return false
                end
            end

            -- Check scoreboard cooldown
            local lastOpened = client:getData("lastScoreboardOpen", 0)
            local cooldown = lia.config.get("scoreboardCooldown", 0)

            if cooldown > 0 and (CurTime() - lastOpened) < cooldown then
                return false
            end

            -- Update last opened timestamp
            client:setData("lastScoreboardOpen", CurTime())

            return true
        end
        ```
]]
function CanPlayerOpenScoreboard(client)
end

--[[
    Purpose:
        Determines if a player can view their inventory.

    When Called:
        When attempting to display inventory UI.

    Parameters:
        client (Player)
            The player attempting to view inventory.

    Returns:
        boolean
            Whether the inventory can be viewed.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always allow inventory viewing
        function MODULE:CanPlayerViewInventory(client)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Basic restrictions on inventory viewing
        function MODULE:CanPlayerViewInventory(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Don't allow during combat
            if client:getNetVar("inCombat", false) then
                return false
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted players can't access inventory
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory viewing controls with security and roleplay restrictions
        function MODULE:CanPlayerViewInventory(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if player is alive
            if not client:Alive() then
                return false -- Dead players can't view inventory
            end

            -- Check if player is restrained/handcuffed
            if char:getData("restrained", false) or char:getData("handcuffed", false) then
                return false -- Restrained players can't access inventory
            end

            -- Check wanted status
            if char:getData("wanted", false) then
                return false -- Wanted criminals can't access inventory
            end

            -- Check if player is frozen/stunned
            if client:IsFrozen() or char:getData("stunned", false) then
                return false -- Incapacitated players can't access inventory
            end

            -- Check if player is in a vehicle
            if client:InVehicle() and lia.config.get("restrictInventoryInVehicle", false) then
                return false -- Can't access inventory while driving
            end

            -- Check combat status
            if char:getData("inCombat", false) then
                return false -- Can't access inventory during combat
            end

            -- Check location restrictions
            local pos = client:GetPos()
            local restrictedZones = lia.config.get("inventoryRestrictedZones", {})

            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return false -- Cannot access inventory in restricted zones
                end
            end

            -- Check faction restrictions
            local faction = lia.faction.get(char:getFaction())
            if faction and faction.restrictInventory then
                return false -- Faction cannot access inventory
            end

            -- Check class restrictions
            local classID = char:getClass()
            if classID then
                local class = lia.class.get(classID)
                if class and class.restrictInventory then
                    return false -- Class cannot access inventory
                end
            end

            -- Check flag restrictions
            if char:hasFlags("I") then -- Inventory restriction flag
                return false
            end

            -- Check level requirements
            local minLevel = lia.config.get("inventoryMinLevel", 0)
            local playerLevel = char:getLevel and char:getLevel() or 1

            if playerLevel < minLevel then
                return false -- Insufficient level
            end

            -- Check reputation requirements
            local minRep = lia.config.get("inventoryMinReputation", -10000)
            local playerRep = char:getData("reputation", 0)

            if playerRep < minRep then
                return false -- Insufficient reputation
            end

            -- Check time restrictions (inventory access during certain hours)
            local currentTime = os.date("*t")
            local timeRestrictions = lia.config.get("inventoryTimeRestrictions")

            if timeRestrictions then
                local currentMinutes = currentTime.hour * 60 + currentTime.min
                if currentMinutes < timeRestrictions.start or currentMinutes > timeRestrictions.end then
                    return false -- Outside allowed hours
                end
            end

            -- Check inventory viewing cooldown
            local lastViewed = char:getData("lastInventoryView", 0)
            local cooldown = lia.config.get("inventoryViewCooldown", 0)

            if cooldown > 0 and (CurTime() - lastViewed) < cooldown then
                return false -- Inventory on cooldown
            end

            -- Check if player has required permission flag
            local requiredFlag = lia.config.get("inventoryRequiredFlag")
            if requiredFlag and not char:hasFlags(requiredFlag) then
                return false
            end

            -- Check if player is in a cinematic or cutscene
            if lia.config.get("cinematicMode", false) then
                return false -- Can't access inventory during cinematic
            end

            -- Check if player is performing an action that prevents inventory access
            local blockedActions = {"castingSpell", "performingRitual", "inAnimation"}
            for _, action in ipairs(blockedActions) do
                if char:getData(action, false) then
                    return false -- Currently performing action that blocks inventory
                end
            end

            -- Check environmental restrictions
            if client:WaterLevel() > 0 and lia.config.get("restrictInventoryUnderwater", false) then
                return false -- Can't access inventory underwater
            end

            -- Check if inventory is locked (due to curse, etc.)
            if char:getData("inventoryLocked", false) then
                return false -- Inventory is locked
            end

            -- Update inventory view timestamp
            char:setData("lastInventoryView", CurTime())
            char:setData("inventoryViewCount", char:getData("inventoryViewCount", 0) + 1)

            -- Log inventory access for security
            lia.log.add(client:Name() .. " viewed inventory", FLAG_NORMAL)

            return true
        end
        ```
]]
function CanPlayerViewInventory(client)
end

--[[
    Purpose:
        Called when the character menu is closed.

    When Called:
        When the character selection menu is closed.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when character menu is closed
        function MODULE:CharMenuClosed()
            print("Character menu closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up temporary data and reset states
        function MODULE:CharMenuClosed()
            -- Clear any cached character data
            self.cachedCharacters = nil

            -- Reset character selection state
            self.selectedCharacter = nil

            -- Hide any character preview models
            if self.characterPreviewPanel then
                self.characterPreviewPanel:Remove()
                self.characterPreviewPanel = nil
            end

            -- Reset any active timers
            if self.characterMenuTimer then
                timer.Remove(self.characterMenuTimer)
                self.characterMenuTimer = nil
            end

            -- Log menu closure
            lia.log.add("Character menu closed by player", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced cleanup with analytics and state management
        function MODULE:CharMenuClosed()
            local currentTime = CurTime()

            -- Track session duration
            if self.menuOpenTime then
                local sessionDuration = currentTime - self.menuOpenTime
                self:TrackMenuSession(sessionDuration)
                self.menuOpenTime = nil
            end

            -- Save user preferences
            self:SaveCharacterMenuPreferences()

            -- Clean up character preview system
            self:CleanupCharacterPreviews()

            -- Reset all menu-related states
            self.characterList = nil
            self.selectedCharacterID = nil
            self.characterSearchFilter = nil
            self.sortByPreference = nil

            -- Cancel any pending character operations
            self:CancelPendingCharacterOperations()

            -- Update player activity data
            local activityData = {
                lastMenuClose = currentTime,
                totalMenuSessions = (self.activityData.totalMenuSessions or 0) + 1,
                lastSelectedCharacter = self.selectedCharacterID
            }
            self.activityData = activityData

            -- Send analytics data to server
            net.Start("CharacterMenuAnalytics")
                net.WriteTable(activityData)
            net.SendToServer()

            -- Clean up any temporary panels
            self:CleanupTemporaryPanels()

            -- Reset camera/view states
            self:ResetCameraState()

            -- Clear any cached textures/models
            self:ClearCharacterCache()

            -- Notify other systems of menu closure
            hook.Run("CharacterMenuClosedComplete")

            -- Log detailed closure information
            lia.log.add(string.format("Character menu closed - Session: %.2fs, Characters viewed: %d",
                sessionDuration or 0, self.charactersViewed or 0), FLAG_NORMAL)

            -- Reset session counters
            self.charactersViewed = 0
            self.menuInteractions = 0
        end

        -- Helper function to track menu session analytics
        function MODULE:TrackMenuSession(duration)
            -- Store session data for analytics
            local sessionData = {
                duration = duration,
                timestamp = os.time(),
                charactersViewed = self.charactersViewed or 0,
                interactions = self.menuInteractions or 0
            }

            -- Add to local session history
            self.sessionHistory = self.sessionHistory or {}
            table.insert(self.sessionHistory, sessionData)

            -- Keep only last 10 sessions
            if #self.sessionHistory > 10 then
                table.remove(self.sessionHistory, 1)
            end
        end

        -- Helper function to save user preferences
        function MODULE:SaveCharacterMenuPreferences()
            local preferences = {
                sortBy = self.sortByPreference or "name",
                filter = self.characterSearchFilter or "",
                viewMode = self.viewMode or "list",
                showOffline = self.showOfflineCharacters or false
            }

            -- Save to local storage
            file.Write("lilia/character_menu_prefs.json", util.TableToJSON(preferences))
        end

        -- Helper function to clean up character previews
        function MODULE:CleanupCharacterPreviews()
            if self.previewPanels then
                for _, panel in ipairs(self.previewPanels) do
                    if IsValid(panel) then
                        panel:Remove()
                    end
                end
                self.previewPanels = nil
            end

            -- Stop any preview animations
            if self.previewAnimationTimer then
                timer.Remove(self.previewAnimationTimer)
                self.previewAnimationTimer = nil
            end
        end

        -- Helper function to cancel pending operations
        function MODULE:CancelPendingCharacterOperations()
            -- Cancel any pending character creation
            if self.pendingCharacterCreation then
                net.Start("CancelCharacterCreation")
                net.SendToServer()
                self.pendingCharacterCreation = false
            end

            -- Cancel any pending character deletion
            if self.pendingCharacterDeletion then
                self:CancelCharacterDeletion()
            end

            -- Cancel any pending character transfers
            if self.pendingCharacterTransfer then
                self:CancelCharacterTransfer()
            end
        end

        -- Helper function to clean up temporary panels
        function MODULE:CleanupTemporaryPanels()
            -- Remove any tooltip panels
            if self.tooltipPanel and IsValid(self.tooltipPanel) then
                self.tooltipPanel:Remove()
                self.tooltipPanel = nil
            end

            -- Remove any context menu panels
            if self.contextMenu and IsValid(self.contextMenu) then
                self.contextMenu:Remove()
                self.contextMenu = nil
            end

            -- Remove any search/filter panels
            if self.searchPanel and IsValid(self.searchPanel) then
                self.searchPanel:Remove()
                self.searchPanel = nil
            end
        end

        -- Helper function to reset camera state
        function MODULE:ResetCameraState()
            -- Reset any custom camera positions
            if self.customCameraPos then
                self.customCameraPos = nil
            end

            -- Reset camera angles
            if self.customCameraAng then
                self.customCameraAng = nil
            end

            -- Re-enable default camera controls
            self.cameraLocked = false
        end

        -- Helper function to clear character cache
        function MODULE:ClearCharacterCache()
            -- Clear cached character models
            if self.characterModelCache then
                for model, _ in pairs(self.characterModelCache) do
                    if self.characterModelCache[model] then
                        self.characterModelCache[model] = nil
                    end
                end
                self.characterModelCache = {}
            end

            -- Clear cached character data
            if self.characterDataCache then
                self.characterDataCache = {}
            end

            -- Force garbage collection if cache was large
            if self.cacheSize and self.cacheSize > 100 then
                collectgarbage("collect")
            end

            self.cacheSize = 0
        end
        ```
]]
function CharMenuClosed()
end

--[[
    Purpose:
        Called when the character menu is opened.

    When Called:
        When the character selection menu is opened.

    Parameters:
        panel (Panel)
            The character menu panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when character menu is opened
        function MODULE:CharMenuOpened(panel)
            print("Character menu opened")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize menu state and load preferences
        function MODULE:CharMenuOpened(panel)
            -- Set menu open timestamp
            self.menuOpenTime = CurTime()

            -- Load user preferences
            self:LoadCharacterMenuPreferences()

            -- Initialize character list
            self:InitializeCharacterList(panel)

            -- Set up event handlers
            panel.OnClose = function()
                hook.Run("CharMenuClosed")
            end

            -- Log menu opening
            lia.log.add("Character menu opened by player", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced initialization with analytics and dynamic content
        function MODULE:CharMenuOpened(panel)
            local currentTime = CurTime()

            -- Record session start
            self.menuOpenTime = currentTime
            self.charactersViewed = 0
            self.menuInteractions = 0

            -- Load and apply user preferences
            self:LoadCharacterMenuPreferences()
            self:ApplyMenuPreferences(panel)

            -- Initialize character data
            self:InitializeCharacterData()

            -- Set up advanced UI components
            self:SetupAdvancedUI(panel)

            -- Initialize analytics tracking
            self:InitializeAnalyticsTracking()

            -- Set up keyboard shortcuts
            self:SetupKeyboardShortcuts(panel)

            -- Initialize character preview system
            self:InitializeCharacterPreviews(panel)

            -- Set up real-time updates
            self:SetupRealTimeUpdates(panel)

            -- Initialize accessibility features
            self:SetupAccessibilityFeatures(panel)

            -- Set up custom event handlers
            self:SetupCustomEventHandlers(panel)

            -- Load and apply themes
            self:ApplyMenuTheme(panel)

            -- Initialize sound effects
            self:InitializeMenuSounds()

            -- Set up auto-save functionality
            self:SetupAutoSave(panel)

            -- Log detailed opening information
            lia.log.add(string.format("Character menu opened - Characters: %d, Preferences loaded: %s",
                #self.characterList or 0, self.preferencesLoaded and "Yes" or "No"), FLAG_NORMAL)

            -- Send opening analytics to server
            net.Start("CharacterMenuOpened")
                net.WriteFloat(currentTime)
            net.SendToServer()

            -- Trigger custom initialization hooks
            hook.Run("CharacterMenuOpenedComplete", panel)
        end

        -- Helper function to load menu preferences
        function MODULE:LoadCharacterMenuPreferences()
            if file.Exists("lilia/character_menu_prefs.json", "DATA") then
                local prefsJson = file.Read("lilia/character_menu_prefs.json", "DATA")
                self.preferences = util.JSONToTable(prefsJson) or {}
                self.preferencesLoaded = true
            else
                self.preferences = self:GetDefaultPreferences()
                self.preferencesLoaded = false
            end
        end

        -- Helper function to apply menu preferences
        function MODULE:ApplyMenuPreferences(panel)
            if self.preferences.viewMode == "grid" then
                self:SetGridView(panel)
            else
                self:SetListView(panel)
            end

            if self.preferences.showOffline then
                self:ShowOfflineCharacters(panel)
            end

            self:ApplySortingPreference(panel)
        end

        -- Helper function to initialize character data
        function MODULE:InitializeCharacterData()
            -- Request fresh character data from server
            net.Start("RequestCharacterList")
            net.SendToServer()

            -- Set up callback for when data arrives
            net.Receive("CharacterListReceived", function()
                self.characterList = net.ReadTable()
                self:RefreshCharacterDisplay()
            end)
        end

        -- Helper function to set up advanced UI
        function MODULE:SetupAdvancedUI(panel)
            -- Add search functionality
            self:AddSearchBar(panel)

            -- Add filter options
            self:AddFilterOptions(panel)

            -- Add sorting options
            self:AddSortingOptions(panel)

            -- Add character statistics panel
            self:AddStatisticsPanel(panel)

            -- Add quick action buttons
            self:AddQuickActionButtons(panel)
        end

        -- Helper function to initialize analytics
        function MODULE:InitializeAnalyticsTracking()
            self.analytics = {
                startTime = CurTime(),
                interactions = 0,
                charactersViewed = 0,
                searchesPerformed = 0,
                filtersApplied = 0
            }
        end

        -- Helper function to set up keyboard shortcuts
        function MODULE:SetupKeyboardShortcuts(panel)
            -- ESC to close
            panel.OnKeyCodePressed = function(_, keyCode)
                if keyCode == KEY_ESCAPE then
                    panel:Close()
                    return true
                end

                -- F to toggle filters
                if keyCode == KEY_F then
                    self:ToggleFilters(panel)
                    return true
                end

                -- S to focus search
                if keyCode == KEY_S and input.IsKeyDown(KEY_LCONTROL) then
                    self:FocusSearchBar(panel)
                    return true
                end
            end
        end

        -- Helper function to initialize character previews
        function MODULE:InitializeCharacterPreviews(panel)
            -- Create preview panel
            self.previewPanel = vgui.Create("DPanel", panel)
            self.previewPanel:SetSize(200, 300)
            self.previewPanel:SetPos(panel:GetWide() - 210, 50)

            -- Set up preview model display
            self.previewModel = vgui.Create("DModelPanel", self.previewPanel)
            self.previewModel:Dock(FILL)

            -- Set up hover effects for character selection
            self:SetupPreviewHoverEffects()
        end

        -- Helper function to set up real-time updates
        function MODULE:SetupRealTimeUpdates(panel)
            -- Update online status every 30 seconds
            timer.Create("CharacterMenuOnlineUpdate", 30, 0, function()
                if IsValid(panel) then
                    self:UpdateOnlineStatus()
                end
            end)

            -- Update character statistics every minute
            timer.Create("CharacterMenuStatsUpdate", 60, 0, function()
                if IsValid(panel) then
                    self:UpdateCharacterStats()
                end
            end)
        end

        -- Helper function to set up accessibility features
        function MODULE:SetupAccessibilityFeatures(panel)
            -- Add screen reader support
            self:SetupScreenReaderSupport(panel)

            -- Add high contrast mode
            if self.preferences.highContrast then
                self:EnableHighContrastMode(panel)
            end

            -- Add keyboard navigation
            self:SetupKeyboardNavigation(panel)

            -- Add text-to-speech for character descriptions
            self:SetupTextToSpeech(panel)
        end

        -- Helper function to set up custom event handlers
        function MODULE:SetupCustomEventHandlers(panel)
            -- Handle character selection
            panel.OnCharacterSelected = function(characterID)
                self:HandleCharacterSelection(characterID)
                self.analytics.charactersViewed = self.analytics.charactersViewed + 1
            end

            -- Handle search queries
            panel.OnSearchPerformed = function(query)
                self:HandleSearchQuery(query)
                self.analytics.searchesPerformed = self.analytics.searchesPerformed + 1
            end

            -- Handle filter changes
            panel.OnFilterChanged = function(filterType, value)
                self:HandleFilterChange(filterType, value)
                self.analytics.filtersApplied = self.analytics.filtersApplied + 1
            end
        end

        -- Helper function to apply menu theme
        function MODULE:ApplyMenuTheme(panel)
            local theme = self.preferences.theme or "default"

            if theme == "dark" then
                panel:SetBackgroundColor(Color(40, 40, 40))
            elseif theme == "light" then
                panel:SetBackgroundColor(Color(240, 240, 240))
            elseif theme == "custom" then
                panel:SetBackgroundColor(self.preferences.customBackgroundColor or Color(60, 60, 60))
            end

            self:ApplyThemeToChildElements(panel)
        end

        -- Helper function to initialize menu sounds
        function MODULE:InitializeMenuSounds()
            -- Load menu sound effects
            self.menuSounds = {
                open = "ui/menu_open.wav",
                close = "ui/menu_close.wav",
                select = "ui/button_click.wav",
                hover = "ui/button_hover.wav"
            }

            -- Preload sounds if enabled
            if self.preferences.enableSounds then
                for _, soundPath in pairs(self.menuSounds) do
                    util.PrecacheSound(soundPath)
                end
            end
        end

        -- Helper function to set up auto-save
        function MODULE:SetupAutoSave(panel)
            -- Auto-save preferences every 5 minutes
            timer.Create("CharacterMenuAutoSave", 300, 0, function()
                if IsValid(panel) then
                    self:SaveCharacterMenuPreferences()
                end
            end)

            -- Save on menu close
            panel.OnClose = function()
                self:SaveCharacterMenuPreferences()
                hook.Run("CharMenuClosed")
            end
        end
        ```
]]
function CharListLoaded(newCharList)
end

--[[
    Purpose:
        Called when the character list has been loaded and is ready for display.

    When Called:
        After character data is received from the server and processed.

    Parameters:
        newCharList (table)
            The loaded character list data.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when character list is loaded
        function MODULE:CharListLoaded(newCharList)
            print("Character list loaded with " .. #newCharList .. " characters")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize character list UI and setup event handlers
        function MODULE:CharListLoaded(newCharList)
            -- Store character list for later use
            self.characterList = newCharList

            -- Initialize character selection UI
            self:InitializeCharacterSelection()

            -- Set up character list refresh timer
            timer.Create("CharacterListRefresh", 300, 0, function()
                self:RefreshCharacterList()
            end)

            -- Log character list loading
            lia.log.add("Character list loaded for player", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character list processing with caching and validation
        function MODULE:CharListLoaded(newCharList)
            -- Validate character data
            local validCharacters = {}
            for _, charData in ipairs(newCharList) do
                if self:ValidateCharacterData(charData) then
                    table.insert(validCharacters, charData)
                else
                    lia.log.add("Invalid character data found: " .. tostring(charData.id), FLAG_WARNING)
                end
            end

            -- Cache character data
            self.characterList = validCharacters
            self:CacheCharacterData(validCharacters)

            -- Initialize advanced UI components
            self:InitializeAdvancedCharacterUI()

            -- Set up real-time character status updates
            self:SetupCharacterStatusUpdates()

            -- Initialize character analytics
            self:InitializeCharacterAnalytics()

            -- Load character-specific preferences
            self:LoadCharacterPreferences()

            -- Set up character list sorting and filtering
            self:SetupCharacterListSorting()

            -- Log detailed loading information
            lia.log.add("Character list loaded: " .. #validCharacters .. " valid characters", FLAG_NORMAL)
        end

        -- Helper function to validate character data
        function MODULE:ValidateCharacterData(charData)
            return charData and charData.id and charData.name and charData.faction
        end
        ```
]]
function CharListUpdated(oldCharList, newCharList)
end

--[[
    Purpose:
        Called when the character list has been updated with new data.

    When Called:
        When character data is updated after the initial load (e.g., when a character is created, deleted, or modified).

    Parameters:
        oldCharList (table)
            The previous character list data.
        newCharList (table)
            The updated character list data.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log character list updates
        function MODULE:CharListUpdated(oldCharList, newCharList)
            print("Character list updated from " .. #oldCharList .. " to " .. #newCharList .. " characters")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update UI when character list changes
        function MODULE:CharListUpdated(oldCharList, newCharList)
            -- Check if characters were added or removed
            local added = #newCharList - #oldCharList
            if added > 0 then
                lia.log.add(added .. " character(s) added to list", FLAG_NORMAL)
            elseif added < 0 then
                lia.log.add(math.abs(added) .. " character(s) removed from list", FLAG_NORMAL)
            end

            -- Refresh character selection UI
            self:RefreshCharacterSelection()

            -- Update character count display
            self:UpdateCharacterCountDisplay(newCharList)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character list diffing and synchronization
        function MODULE:CharListUpdated(oldCharList, newCharList)
            -- Perform detailed diff analysis
            local changes = self:AnalyzeCharacterListChanges(oldCharList, newCharList)

            -- Log detailed changes
            for changeType, charIDs in pairs(changes) do
                if #charIDs > 0 then
                    lia.log.add("Character list " .. changeType .. ": " .. table.concat(charIDs, ", "), FLAG_NORMAL)
                end
            end

            -- Update cached character data
            self:UpdateCachedCharacterData(changes)

            -- Synchronize with server state
            self:SynchronizeCharacterState(newCharList)

            -- Refresh all character-related UI components
            self:RefreshAllCharacterUI()

            -- Update character analytics
            self:UpdateCharacterAnalytics(changes)

            -- Handle special cases (e.g., current character deleted)
            self:HandleSpecialCharacterUpdates(changes)

            -- Notify other modules of changes
            hook.Run("OnCharacterListChanged", changes)
        end

        -- Helper function to analyze changes
        function MODULE:AnalyzeCharacterListChanges(oldList, newList)
            local changes = {added = {}, removed = {}, modified = {}}

            -- Find added characters
            for _, charID in ipairs(newList) do
                if not table.HasValue(oldList, charID) then
                    table.insert(changes.added, charID)
                end
            end

            -- Find removed characters
            for _, charID in ipairs(oldList) do
                if not table.HasValue(newList, charID) then
                    table.insert(changes.removed, charID)
                end
            end

            return changes
        end
        ```
]]
function CharMenuOpened(panel)
end

--[[
    Purpose:
        Called when the chatbox panel is created.

    When Called:
        When the chatbox UI is initialized.

    Parameters:
        panel (Panel)
            The chatbox panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log chatbox creation
        function MODULE:ChatboxPanelCreated(panel)
            print("Chatbox panel created")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize chatbox settings
        function MODULE:ChatboxPanelCreated(panel)
            -- Set default chat settings
            self.chatSettings = self.chatSettings or {
                showTimestamps = true,
                maxMessages = 100,
                fontSize = "LiliaFont.14"
            }

            -- Apply settings to panel
            panel:SetFont(self.chatSettings.fontSize)
            panel:SetMaxMessages(self.chatSettings.maxMessages)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced chatbox customization and integration
        function MODULE:ChatboxPanelCreated(panel)
            -- Store reference for other modules
            self.chatPanel = panel

            -- Initialize chat filtering system
            self:InitializeChatFilters(panel)

            -- Set up custom chat commands
            self:SetupCustomChatCommands(panel)

            -- Integrate with notification system
            self:SetupChatNotifications(panel)

            -- Add chat analytics tracking
            self:SetupChatAnalytics(panel)

            -- Load user chat preferences
            self:LoadChatPreferences(panel)

            -- Initialize chat themes
            self:InitializeChatThemes(panel)

            -- Set up auto-scroll and history
            self:SetupChatHistory(panel)

            -- Add accessibility features
            self:AddChatAccessibility(panel)

            -- Log chatbox initialization
            lia.log.add("Advanced chatbox initialized with full feature set", FLAG_NORMAL)
        end

        -- Helper function to initialize chat filters
        function MODULE:InitializeChatFilters(panel)
            panel.filterSettings = {
                blockedWords = self:GetBlockedWords(),
                allowedChannels = self:GetAllowedChannels(),
                spamProtection = true
            }
        end
        ```
]]
function ChatboxPanelCreated(panel)
end

--[[
    Purpose:
        Called when text is added to the chat system.

    When Called:
        When chat messages are processed and added to the chatbox.

    Parameters:
        markup (table)
            The markup object containing chat text data.
        ... (varargs)
            Additional arguments for chat formatting.

    Returns:
        table
            Modified markup object (return nil to cancel).

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log chat messages
        function MODULE:ChatAddText(markup, ...)
            print("Chat message added: " .. markup:GetText())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Filter chat messages
        function MODULE:ChatAddText(markup, ...)
            local text = markup:GetText()

            -- Remove bad words
            text = string.gsub(text, "badword", "***")

            -- Update markup
            markup:SetText(text)

            return markup
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced chat processing with filtering, logging, and analytics
        function MODULE:ChatAddText(markup, ...)
            local text = markup:GetText()
            local originalText = text
            local client = LocalPlayer()

            -- Apply chat filters
            local filterResult = self:ApplyChatFilters(text, markup)
            if filterResult.blocked then
                return nil -- Block the message
            end
            text = filterResult.text

            -- Process chat commands
            if self:IsChatCommand(text) then
                self:ProcessChatCommand(text, client)
                return nil -- Don't display command messages
            end

            -- Apply chat formatting
            text = self:ApplyChatFormatting(text, markup)

            -- Add timestamps if enabled
            if self.chatSettings.showTimestamps then
                text = self:AddTimestamp(text)
            end

            -- Update markup with processed text
            markup:SetText(text)

            -- Log chat message for analytics
            self:LogChatMessage(client, originalText, text, markup)

            -- Check for spam
            if self:IsSpam(text, client) then
                client:ChatPrint("Please wait before sending another message.")
                return nil
            end

            -- Apply chat themes
            self:ApplyChatTheme(markup, client)

            -- Add message to history
            self:AddToChatHistory(markup, client)

            -- Trigger chat events
            hook.Run("OnChatMessageProcessed", client, markup, originalText)

            return markup
        end

        -- Helper function to apply chat filters
        function MODULE:ApplyChatFilters(text, markup)
            -- Remove blocked words
            for _, word in ipairs(self.blockedWords) do
                text = string.gsub(text, word, string.rep("*", #word))
            end

            -- Check for spam patterns
            if self:ContainsSpamPatterns(text) then
                return {blocked = true, text = text}
            end

            return {blocked = false, text = text}
        end
        ```
]]
function ChatAddText(markup, ...)
end

--[[
    Purpose:
        Handles configuring character creation steps.

    When Called:
        When setting up the character creation UI.

    Parameters:
        panel (Panel)
            The character creation panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a basic custom step
        function MODULE:ConfigureCharacterCreationSteps(panel)
            -- Add a simple info step
            panel:AddStep("Welcome", function(stepPanel)
                local label = vgui.Create("DLabel", stepPanel)
                label:SetText("Welcome to character creation!")
                label:SetFont("LiliaFont.36")
                label:SizeToContents()
                label:Center()
            end)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom steps with validation
        function MODULE:ConfigureCharacterCreationSteps(panel)
            -- Add background selection step
            panel:AddStep("Background", function(stepPanel)
                local backgroundLabel = vgui.Create("DLabel", stepPanel)
                backgroundLabel:SetText("Choose your character's background:")
                backgroundLabel:SetFont("LiliaFont.25")
                backgroundLabel:SetPos(10, 10)
                backgroundLabel:SizeToContents()

                local backgroundCombo = vgui.Create("DComboBox", stepPanel)
                backgroundCombo:SetPos(10, 40)
                backgroundCombo:SetSize(200, 25)
                backgroundCombo:SetValue("Select Background")

                backgroundCombo:AddChoice("Street Kid")
                backgroundCombo:AddChoice("Corporate")
                backgroundCombo:AddChoice("Military")
                backgroundCombo:AddChoice("Criminal")

                -- Store selection for later use
                backgroundCombo.OnSelect = function(_, _, value)
                    panel.characterData = panel.characterData or {}
                    panel.characterData.background = value
                end

                -- Validation
                stepPanel.Validate = function()
                    return panel.characterData and panel.characterData.background
                end
            end)

            -- Add traits selection step
            panel:AddStep("Traits", function(stepPanel)
                local traitsLabel = vgui.Create("DLabel", stepPanel)
                traitsLabel:SetText("Select up to 2 traits:")
                traitsLabel:SetFont("LiliaFont.25")
                traitsLabel:SetPos(10, 10)
                traitsLabel:SizeToContents()

                local availableTraits = {"Lucky", "Tough", "Smart", "Charismatic", "Athletic", "Creative"}
                local selectedTraits = {}

                local yPos = 40
                for _, trait in ipairs(availableTraits) do
                    local traitCheckbox = vgui.Create("DCheckBoxLabel", stepPanel)
                    traitCheckbox:SetText(trait)
                    traitCheckbox:SetPos(10, yPos)
                    traitCheckbox:SetSize(150, 20)

                    traitCheckbox.OnChange = function(_, checked)
                        if checked and #selectedTraits < 2 then
                            table.insert(selectedTraits, trait)
                        elseif not checked then
                            table.RemoveByValue(selectedTraits, trait)
                        else
                            traitCheckbox:SetChecked(false)
                        end

                        panel.characterData = panel.characterData or {}
                        panel.characterData.traits = selectedTraits
                    end

                    yPos = yPos + 25
                end
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character creation with dynamic steps and complex validation
        function MODULE:ConfigureCharacterCreationSteps(panel)
            -- Initialize character creation data
            panel.characterData = panel.characterData or {}
            panel.creationSteps = panel.creationSteps or {}

            -- Add faction-specific steps
            panel:AddStep("Faction Details", function(stepPanel)
                self:CreateFactionSpecificStep(stepPanel, panel)
            end)

            -- Add appearance customization step
            panel:AddStep("Appearance", function(stepPanel)
                self:CreateAppearanceStep(stepPanel, panel)
            end)

            -- Add background story step
            panel:AddStep("Background Story", function(stepPanel)
                self:CreateBackgroundStoryStep(stepPanel, panel)
            end)

            -- Add skills allocation step
            panel:AddStep("Skills", function(stepPanel)
                self:CreateSkillsStep(stepPanel, panel)
            end)

            -- Add equipment selection step
            panel:AddStep("Starting Equipment", function(stepPanel)
                self:CreateEquipmentStep(stepPanel, panel)
            end)

            -- Add review and confirmation step
            panel:AddStep("Review", function(stepPanel)
                self:CreateReviewStep(stepPanel, panel)
            end)

            -- Set up step navigation with validation
            self:SetupStepNavigation(panel)

            -- Add real-time preview
            self:SetupCharacterPreview(panel)
        end

        -- Helper function to create faction-specific step
        function MODULE:CreateFactionSpecificStep(stepPanel, mainPanel)
            local faction = mainPanel.selectedFaction
            if not faction then return end

            local factionData = lia.faction.get(faction)
            if not factionData then return end

            -- Create faction-specific questions/fields
            if factionData.creationQuestions then
                local yPos = 10
                for _, question in ipairs(factionData.creationQuestions) do
                    local questionLabel = vgui.Create("DLabel", stepPanel)
                    questionLabel:SetText(question.text)
                    questionLabel:SetPos(10, yPos)
                    questionLabel:SizeToContents()
                    yPos = yPos + 25

                    if question.type == "text" then
                        local textEntry = vgui.Create("DTextEntry", stepPanel)
                        textEntry:SetPos(10, yPos)
                        textEntry:SetSize(300, 25)
                        textEntry:SetPlaceholderText(question.placeholder or "")

                        textEntry.OnChange = function()
                            mainPanel.characterData.factionAnswers = mainPanel.characterData.factionAnswers or {}
                            mainPanel.characterData.factionAnswers[question.id] = textEntry:GetValue()
                        end

                        yPos = yPos + 35
                    elseif question.type == "choice" then
                        local comboBox = vgui.Create("DComboBox", stepPanel)
                        comboBox:SetPos(10, yPos)
                        comboBox:SetSize(300, 25)
                        comboBox:SetValue(question.placeholder or "Select...")

                        for _, choice in ipairs(question.choices) do
                            comboBox:AddChoice(choice)
                        end

                        comboBox.OnSelect = function(_, _, value)
                            mainPanel.characterData.factionAnswers = mainPanel.characterData.factionAnswers or {}
                            mainPanel.characterData.factionAnswers[question.id] = value
                        end

                        yPos = yPos + 35
                    end
                end
            end

            -- Add faction description
            local descLabel = vgui.Create("DLabel", stepPanel)
            descLabel:SetText(factionData.description or "No description available.")
            descLabel:SetPos(10, yPos + 20)
            descLabel:SetSize(350, 100)
            descLabel:SetWrap(true)
            descLabel:SetAutoStretchVertical(true)
        end

        -- Helper function to create appearance step
        function MODULE:CreateAppearanceStep(stepPanel, mainPanel)
            -- Model selection
            local modelLabel = vgui.Create("DLabel", stepPanel)
            modelLabel:SetText("Choose your appearance:")
            modelLabel:SetPos(10, 10)
            modelLabel:SizeToContents()

            local modelList = vgui.Create("DListView", stepPanel)
            modelList:SetPos(10, 40)
            modelList:SetSize(150, 200)
            modelList:AddColumn("Available Models")

            -- Get faction-appropriate models
            local faction = mainPanel.selectedFaction
            local models = self:GetFactionModels(faction)

            for _, modelData in ipairs(models) do
                local line = modelList:AddLine(modelData.name)
                line.modelPath = modelData.path
            end

            modelList.OnRowSelected = function(_, _, line)
                mainPanel.characterData.model = line.modelPath
                self:UpdateCharacterPreview(mainPanel, line.modelPath)
            end

            -- Color customization
            local colorLabel = vgui.Create("DLabel", stepPanel)
            colorLabel:SetText("Skin Color:")
            colorLabel:SetPos(180, 40)
            colorLabel:SizeToContents()

            local colorMixer = vgui.Create("DColorMixer", stepPanel)
            colorMixer:SetPos(180, 70)
            colorMixer:SetSize(200, 150)
            colorMixer:SetPalette(true)
            colorMixer:SetAlphaBar(false)
            colorMixer:SetWangs(true)

            colorMixer.ValueChanged = function()
                local color = colorMixer:GetColor()
                mainPanel.characterData.skinColor = color
                self:UpdateCharacterPreview(mainPanel)
            end
        end

        -- Helper function to create background story step
        function MODULE:CreateBackgroundStoryStep(stepPanel, mainPanel)
            local storyLabel = vgui.Create("DLabel", stepPanel)
            storyLabel:SetText("Write a brief background story for your character:")
            storyLabel:SetPos(10, 10)
            storyLabel:SizeToContents()

            local storyEntry = vgui.Create("DTextEntry", stepPanel)
            storyEntry:SetPos(10, 40)
            storyEntry:SetSize(380, 150)
            storyEntry:SetMultiline(true)
            storyEntry:SetPlaceholderText("Enter your character's background story here...")

            -- Character counter
            local charCounter = vgui.Create("DLabel", stepPanel)
            charCounter:SetPos(10, 200)
            charCounter:SetText("Characters: 0/500")
            charCounter:SizeToContents()

            storyEntry.OnChange = function()
                local text = storyEntry:GetValue()
                local length = #text

                charCounter:SetText("Characters: " .. length .. "/500")

                if length > 500 then
                    charCounter:SetTextColor(Color(255, 0, 0))
                    storyEntry:SetText(text:sub(1, 500))
                else
                    charCounter:SetTextColor(Color(0, 0, 0))
                end

                mainPanel.characterData.backgroundStory = text:sub(1, 500)
            end

            -- Add story prompts
            local promptsLabel = vgui.Create("DLabel", stepPanel)
            promptsLabel:SetText("Story Prompts:")
            promptsLabel:SetPos(10, 230)
            promptsLabel:SizeToContents()

            local prompts = {
                "How did you end up in this city?",
                "What is your character's greatest strength?",
                "What motivates your character?",
                "What is your character's biggest secret?"
            }

            local yPos = 250
            for _, prompt in ipairs(prompts) do
                local promptLabel = vgui.Create("DLabel", stepPanel)
                promptLabel:SetText("• " .. prompt)
                promptLabel:SetPos(20, yPos)
                promptLabel:SetSize(350, 20)
                promptLabel:SetWrap(true)
                yPos = yPos + 25
            end
        end

        -- Helper function to create skills step
        function MODULE:CreateSkillsStep(stepPanel, mainPanel)
            local skillPoints = 20 -- Available skill points
            local allocatedPoints = 0

            local pointsLabel = vgui.Create("DLabel", stepPanel)
            pointsLabel:SetText("Skill Points Available: " .. skillPoints)
            pointsLabel:SetPos(10, 10)
            pointsLabel:SizeToContents()

            local skills = {
                {name = "Strength", desc = "Physical power and combat ability"},
                {name = "Intelligence", desc = "Knowledge and problem-solving"},
                {name = "Charisma", desc = "Social skills and persuasion"},
                {name = "Agility", desc = "Speed and dexterity"},
                {name = "Endurance", desc = "Stamina and resilience"}
            }

            mainPanel.characterData.skills = mainPanel.characterData.skills or {}
            local skillSliders = {}

            local yPos = 40
            for _, skill in ipairs(skills) do
                -- Skill name and description
                local nameLabel = vgui.Create("DLabel", stepPanel)
                nameLabel:SetText(skill.name)
                nameLabel:SetPos(10, yPos)
                nameLabel:SizeToContents()

                local descLabel = vgui.Create("DLabel", stepPanel)
                descLabel:SetText(skill.desc)
                descLabel:SetPos(200, yPos)
                descLabel:SetSize(200, 20)
                descLabel:SetWrap(true)

                -- Skill slider
                local slider = vgui.Create("DNumSlider", stepPanel)
                slider:SetPos(10, yPos + 25)
                slider:SetSize(300, 25)
                slider:SetText("")
                slider:SetMin(1)
                slider:SetMax(10)
                slider:SetValue(1)
                slider:SetDecimals(0)

                slider.OnValueChanged = function(_, value)
                    mainPanel.characterData.skills[skill.name] = value

                    -- Recalculate total points
                    allocatedPoints = 0
                    for _, s in ipairs(skills) do
                        allocatedPoints = allocatedPoints + (mainPanel.characterData.skills[s.name] or 1)
                    end

                    pointsLabel:SetText("Skill Points Available: " .. (skillPoints - allocatedPoints + #skills))
                end

                skillSliders[skill.name] = slider
                yPos = yPos + 60
            end

            -- Validate step
            stepPanel.Validate = function()
                local totalPoints = 0
                for _, skill in ipairs(skills) do
                    totalPoints = totalPoints + (mainPanel.characterData.skills[skill.name] or 1)
                end
                return totalPoints <= skillPoints
            end
        end

        -- Helper function to create equipment step
        function MODULE:CreateEquipmentStep(stepPanel, mainPanel)
            local equipmentLabel = vgui.Create("DLabel", stepPanel)
            equipmentLabel:SetText("Choose your starting equipment:")
            equipmentLabel:SetPos(10, 10)
            equipmentLabel:SizeToContents()

            -- Get faction-appropriate starting equipment
            local faction = mainPanel.selectedFaction
            local equipmentOptions = self:GetStartingEquipment(faction)

            mainPanel.characterData.startingEquipment = mainPanel.characterData.startingEquipment or {}

            local yPos = 40
            for _, equipment in ipairs(equipmentOptions) do
                local equipCheckbox = vgui.Create("DCheckBoxLabel", stepPanel)
                equipCheckbox:SetText(equipment.name .. " (" .. equipment.description .. ")")
                equipCheckbox:SetPos(10, yPos)
                equipCheckbox:SetSize(350, 20)

                equipCheckbox.OnChange = function(_, checked)
                    if checked then
                        table.insert(mainPanel.characterData.startingEquipment, equipment.id)
                    else
                        table.RemoveByValue(mainPanel.characterData.startingEquipment, equipment.id)
                    end
                end

                yPos = yPos + 25
            end
        end

        -- Helper function to create review step
        function MODULE:CreateReviewStep(stepPanel, mainPanel)
            local reviewLabel = vgui.Create("DLabel", stepPanel)
            reviewLabel:SetText("Review your character:")
            reviewLabel:SetFont("LiliaFont.36")
            reviewLabel:SetPos(10, 10)
            reviewLabel:SizeToContents()

            -- Character summary
            local summaryPanel = vgui.Create("DPanel", stepPanel)
            summaryPanel:SetPos(10, 40)
            summaryPanel:SetSize(380, 200)
            summaryPanel:SetBackgroundColor(Color(240, 240, 240))

            local yPos = 10
            local function addSummaryLine(text)
                local label = vgui.Create("DLabel", summaryPanel)
                label:SetText(text)
                label:SetPos(10, yPos)
                label:SetSize(360, 20)
                label:SetWrap(true)
                label:SetAutoStretchVertical(true)
                yPos = yPos + label:GetTall() + 5
            end

            -- Basic info
            addSummaryLine("Name: " .. (mainPanel.characterData.name or "Not set"))
            addSummaryLine("Faction: " .. (mainPanel.selectedFaction or "Not set"))
            addSummaryLine("Model: " .. (mainPanel.characterData.model or "Not set"))

            -- Background and traits
            if mainPanel.characterData.background then
                addSummaryLine("Background: " .. mainPanel.characterData.background)
            end

            if mainPanel.characterData.traits and #mainPanel.characterData.traits > 0 then
                addSummaryLine("Traits: " .. table.concat(mainPanel.characterData.traits, ", "))
            end

            -- Skills
            if mainPanel.characterData.skills then
                local skillText = "Skills: "
                for skill, value in pairs(mainPanel.characterData.skills) do
                    skillText = skillText .. skill .. "(" .. value .. ") "
                end
                addSummaryLine(skillText)
            end

            -- Equipment
            if mainPanel.characterData.startingEquipment and #mainPanel.characterData.startingEquipment > 0 then
                addSummaryLine("Starting Equipment: " .. #mainPanel.characterData.startingEquipment .. " items")
            end

            -- Validation status
            local validationLabel = vgui.Create("DLabel", stepPanel)
            validationLabel:SetPos(10, 250)
            validationLabel:SetSize(380, 40)
            validationLabel:SetWrap(true)

            local function updateValidation()
                local isValid = self:ValidateCharacterCreation(mainPanel.characterData)
                if isValid then
                    validationLabel:SetText("Character creation is ready!")
                    validationLabel:SetTextColor(Color(0, 150, 0))
                else
                    validationLabel:SetText("Please complete all required fields before proceeding.")
                    validationLabel:SetTextColor(Color(150, 0, 0))
                end
            end

            updateValidation()

            -- Update validation when data changes
            timer.Create("CharacterCreationValidation", 1, 0, function()
                if IsValid(stepPanel) then
                    updateValidation()
                else
                    timer.Remove("CharacterCreationValidation")
                end
            end)
        end

        -- Helper function to set up step navigation
        function MODULE:SetupStepNavigation(panel)
            -- Override next/back buttons to include validation
            local oldNext = panel.NextStep
            panel.NextStep = function()
                local currentStep = panel:GetCurrentStep()
                if currentStep and currentStep.Validate and not currentStep:Validate() then
                    surface.PlaySound("buttons/button10.wav")
                    return false
                end
                return oldNext(panel)
            end
        end

        -- Helper function to set up character preview
        function MODULE:SetupCharacterPreview(panel)
            panel.previewPanel = vgui.Create("DModelPanel", panel)
            panel.previewPanel:SetSize(200, 300)
            panel.previewPanel:SetPos(panel:GetWide() - 210, 50)
            panel.previewPanel:SetModel("models/player/group01/male_01.mdl")
        end

        -- Helper functions for data retrieval
        function MODULE:GetFactionModels(faction)
            -- Return faction-appropriate models
            return {
                {name = "Male 01", path = "models/player/group01/male_01.mdl"},
                {name = "Male 02", path = "models/player/group01/male_02.mdl"},
                {name = "Female 01", path = "models/player/group01/female_01.mdl"}
            }
        end

        function MODULE:GetStartingEquipment(faction)
            -- Return faction-appropriate starting equipment
            return {
                {id = "flashlight", name = "Flashlight", description = "A basic flashlight"},
                {id = "wallet", name = "Wallet", description = "A simple wallet"},
                {id = "watch", name = "Watch", description = "A basic wristwatch"}
            }
        end

        function MODULE:ValidateCharacterCreation(data)
            return data.name and data.faction and data.model
        end

        function MODULE:UpdateCharacterPreview(panel, model)
            if panel.previewPanel then
                if model then
                    panel.previewPanel:SetModel(model)
                end

                -- Apply skin color if set
                if panel.characterData.skinColor then
                    panel.previewPanel:GetEntity():SetColor(panel.characterData.skinColor)
                end
            end
        end
        ```
]]
function ConfigureCharacterCreationSteps(panel)
end

--[[
    Purpose:
        Handles creating the chat system.

    When Called:
        When the chat system is initialized.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic chat panel
        function MODULE:CreateChat()
            if IsValid(self.panel) then return end

            self.panel = vgui.Create("liaChatBox")
            self.panel:Dock(BOTTOM)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create chat with positioning and settings
        function MODULE:CreateChat()
            if IsValid(self.panel) then return end

            -- Create the chat panel
            self.panel = vgui.Create("liaChatBox")
            self.panel:SetSize(ScrW() * 0.4, ScrH() * 0.3)
            self.panel:SetPos(10, ScrH() - self.panel:GetTall() - 10)

            -- Set chat settings
            self.panel:SetFont("LiliaFont.14")
            self.panel:SetMaxMessages(100)
            self.panel:SetFadeTime(15)

            -- Add close button
            local closeButton = vgui.Create("DButton", self.panel)
            closeButton:SetText("X")
            closeButton:SetSize(20, 20)
            closeButton:SetPos(self.panel:GetWide() - 25, 5)
            closeButton.DoClick = function()
                self.panel:SetVisible(false)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced chat system with multiple panels and features
        function MODULE:CreateChat()
            if IsValid(self.panel) then return end

            -- Create main chat panel
            self.panel = vgui.Create("liaChatBox")
            self.panel:SetSize(ScrW() * 0.5, ScrH() * 0.35)
            self.panel:SetPos(15, ScrH() - self.panel:GetTall() - 15)

            -- Create secondary chat panel for system messages
            self.systemPanel = vgui.Create("liaChatBox")
            self.systemPanel:SetSize(ScrW() * 0.25, ScrH() * 0.2)
            self.systemPanel:SetPos(ScrW() - self.systemPanel:GetWide() - 15, ScrH() - self.systemPanel:GetTall() - 15)
            self.systemPanel:SetTitle("System Messages")

            -- Configure main chat
            self:ConfigureMainChatPanel(self.panel)

            -- Configure system chat
            self:ConfigureSystemChatPanel(self.systemPanel)

            -- Set up chat tabs
            self:CreateChatTabs()

            -- Initialize chat commands
            self:InitializeChatCommands()

            -- Set up message filtering
            self:SetupMessageFilters()

            -- Create chat settings panel
            self:CreateChatSettingsPanel()

            -- Initialize chat history
            self:LoadChatHistory()

            -- Set up auto-save for chat settings
            self:SetupChatAutoSave()

            -- Log chat system initialization
            lia.log.add("Advanced chat system initialized with dual panels", FLAG_NORMAL)
        end

        -- Helper function to configure main chat panel
        function MODULE:ConfigureMainChatPanel(panel)
            panel:SetFont(self.chatSettings.font or "LiliaFont.14")
            panel:SetMaxMessages(self.chatSettings.maxMessages or 150)
            panel:SetFadeTime(self.chatSettings.fadeTime or 20)

            -- Add custom styling
            panel.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
                draw.RoundedBox(8, 2, 2, w-4, h-4, Color(20, 20, 20, 255))
            end
        end
        ```
]]
function CreateChat()
end

--[[
    Purpose:
        Handles creating information buttons.

    When Called:
        When setting up information UI buttons.

    Parameters:
        pages (table)
            Table of page information.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic information buttons
        function MODULE:CreateInformationButtons(pages)
            for _, page in ipairs(pages) do
                local button = vgui.Create("DButton")
                button:SetText(page.title or "Info")
                button:SetSize(100, 30)
                -- Position and setup button functionality
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create information buttons with categories
        function MODULE:CreateInformationButtons(pages)
            local categories = {}

            -- Group pages by category
            for _, page in ipairs(pages) do
                local category = page.category or "General"
                categories[category] = categories[category] or {}
                table.insert(categories[category], page)
            end

            -- Create buttons for each category
            local yOffset = 0
            for categoryName, categoryPages in pairs(categories) do
                -- Create category header
                local header = vgui.Create("DLabel")
                header:SetText(categoryName)
                header:SetPos(10, yOffset)
                header:SizeToContents()
                yOffset = yOffset + 25

                -- Create buttons for this category
                for _, page in ipairs(categoryPages) do
                    local button = vgui.Create("DButton")
                    button:SetText(page.title)
                    button:SetSize(200, 30)
                    button:SetPos(20, yOffset)
                    button.DoClick = function()
                        self:ShowInformationPage(page)
                    end
                    yOffset = yOffset + 35
                end

                yOffset = yOffset + 10 -- Spacing between categories
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced information system with search and filtering
        function MODULE:CreateInformationButtons(pages)
            -- Create main container
            self.infoContainer = vgui.Create("DPanel")
            self.infoContainer:Dock(FILL)

            -- Create search bar
            self:CreateSearchBar(self.infoContainer)

            -- Create category tabs
            self:CreateCategoryTabs(self.infoContainer, pages)

            -- Create button grid with advanced layout
            self:CreateButtonGrid(self.infoContainer, pages)

            -- Set up filtering system
            self:SetupButtonFiltering(pages)

            -- Add sorting options
            self:AddSortingOptions(self.infoContainer)

            -- Initialize button interactions
            self:InitializeButtonInteractions()

            -- Set up accessibility features
            self:SetupAccessibilityFeatures()

            -- Log information system creation
            lia.log.add("Advanced information button system created with " .. #pages .. " pages", FLAG_NORMAL)
        end

        -- Helper function to create search bar
        function MODULE:CreateSearchBar(parent)
            local searchBar = vgui.Create("DTextEntry", parent)
            searchBar:Dock(TOP)
            searchBar:SetPlaceholderText("Search information...")
            searchBar:SetTall(30)
            searchBar:SetFont("LiliaFont.25")

            searchBar.OnChange = function(s)
                self:FilterButtons(s:GetValue())
            end

            self.searchBar = searchBar
        end

        -- Helper function to create category tabs
        function MODULE:CreateCategoryTabs(parent, pages)
            local categories = self:GetUniqueCategories(pages)
            local tabSheet = vgui.Create("DPropertySheet", parent)
            tabSheet:Dock(TOP)
            tabSheet:SetTall(400)

            for _, category in ipairs(categories) do
                local categoryPanel = vgui.Create("DPanel")
                categoryPanel:Dock(FILL)

                local categoryPages = self:GetPagesByCategory(pages, category)
                self:CreateButtonGrid(categoryPanel, categoryPages)

                tabSheet:AddSheet(category, categoryPanel)
            end

            self.tabSheet = tabSheet
        end
        ```
]]
function CreateInformationButtons(pages)
end

--[[
    Purpose:
        Handles creating inventory panels.

    When Called:
        When inventory UI needs to be created.

    Parameters:
        inventory (Inventory)
            The inventory to display.
        parent (Panel)
            The parent panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic inventory panel
        function MODULE:CreateInventoryPanel(inventory, parent)
            local panel = vgui.Create("liaInventory", parent)
            panel:SetInventory(inventory)
            panel:Dock(FILL)
            return panel
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create inventory panel with custom styling
        function MODULE:CreateInventoryPanel(inventory, parent)
            local panel = vgui.Create("liaInventory", parent)
            panel:SetInventory(inventory)
            panel:Dock(FILL)

            -- Add custom background
            panel.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 240))
                draw.RoundedBox(8, 2, 2, w-4, h-4, Color(30, 30, 30, 255))
            end

            -- Add close button
            local closeBtn = vgui.Create("DButton", panel)
            closeBtn:SetText("X")
            closeBtn:SetSize(25, 25)
            closeBtn:SetPos(panel:GetWide() - 30, 5)
            closeBtn.DoClick = function()
                panel:Remove()
            end

            return panel
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory panel with features
        function MODULE:CreateInventoryPanel(inventory, parent)
            -- Create main panel
            local panel = vgui.Create("DPanel", parent)
            panel:Dock(FILL)
            panel:DockMargin(10, 10, 10, 10)

            -- Create title bar
            local titleBar = vgui.Create("DPanel", panel)
            titleBar:Dock(TOP)
            titleBar:SetTall(40)
            titleBar:DockMargin(0, 0, 0, 5)

            local title = vgui.Create("DLabel", titleBar)
            title:SetText("Inventory - " .. inventory:getName())
            title:SetFont("LiliaFont.36")
            title:Dock(LEFT)
            title:DockMargin(10, 0, 0, 0)
            title:SizeToContents()

            -- Search bar
            local searchBar = vgui.Create("DTextEntry", titleBar)
            searchBar:SetPlaceholderText("Search items...")
            searchBar:Dock(RIGHT)
            searchBar:SetWide(200)
            searchBar:DockMargin(0, 5, 5, 5)

            -- Create inventory grid
            local inventoryGrid = vgui.Create("DIconLayout", panel)
            inventoryGrid:Dock(FILL)
            inventoryGrid:DockMargin(5, 5, 5, 5)
            inventoryGrid:SetSpaceX(5)
            inventoryGrid:SetSpaceY(5)

            -- Populate inventory items
            for _, item in pairs(inventory:getItems()) do
                local itemIcon = vgui.Create("liaItemIcon", inventoryGrid)
                itemIcon:SetItem(item)
                itemIcon:SetSize(64, 64)

                -- Add tooltip
                itemIcon:SetTooltip(item:getName() .. "\n" .. item:getDesc())
            end

            -- Handle search
            searchBar.OnChange = function(s)
                local searchText = s:GetValue():lower()
                for _, child in pairs(inventoryGrid:GetChildren()) do
                    if IsValid(child) and child.item then
                        local itemName = child.item:getName():lower()
                        child:SetVisible(itemName:find(searchText, 1, true) ~= nil)
                    end
                end
                inventoryGrid:Layout()
            end

            return panel
        end
        ```
]]
function CreateInventoryPanel(inventory, parent)
end

--[[
    Purpose:
        Handles creating menu buttons.

    When Called:
        When setting up menu UI buttons.

    Parameters:
        tabs (table)
            Table of tab information.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic menu buttons
        function MODULE:CreateMenuButtons(tabs)
            for _, tab in ipairs(tabs) do
                local button = vgui.Create("DButton")
                button:SetText(tab.name or "Tab")
                button:SetSize(100, 40)
                -- Position buttons horizontally
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create tab buttons with click handlers
        function MODULE:CreateMenuButtons(tabs)
            local xOffset = 10

            for i, tab in ipairs(tabs) do
                local button = vgui.Create("DButton")
                button:SetText(tab.name or "Tab " .. i)
                button:SetSize(120, 40)
                button:SetPos(xOffset, 10)

                -- Style the button
                button:SetFont("LiliaFont.25")
                button.Paint = function(s, w, h)
                    local color = s:IsHovered() and Color(70, 130, 180) or Color(50, 50, 50)
                    draw.RoundedBox(6, 0, 0, w, h, color)
                end

                -- Handle click
                button.DoClick = function()
                    if tab.callback then
                        tab.callback()
                    end
                    -- Switch to this tab
                    self:SwitchToTab(i)
                end

                xOffset = xOffset + 130
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu system with categories and permissions
        function MODULE:CreateMenuButtons(tabs)
            -- Create main menu container
            local menuBar = vgui.Create("DPanel")
            menuBar:Dock(TOP)
            menuBar:SetTall(50)
            menuBar:DockMargin(0, 0, 0, 5)

            -- Style the menu bar
            menuBar.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35, 240))
                draw.RoundedBox(8, 2, 2, w-4, h-4, Color(25, 25, 25, 255))
            end

            -- Group tabs by category
            local categories = {}
            for _, tab in ipairs(tabs) do
                local category = tab.category or "General"
                categories[category] = categories[category] or {}
                table.insert(categories[category], tab)
            end

            -- Create category sections
            local currentX = 15
            for categoryName, categoryTabs in pairs(categories) do
                -- Category label
                local categoryLabel = vgui.Create("DLabel", menuBar)
                categoryLabel:SetText(categoryName .. ":")
                categoryLabel:SetFont("LiliaFont.17")
                categoryLabel:SetTextColor(Color(200, 200, 200))
                categoryLabel:SetPos(currentX, 5)
                categoryLabel:SizeToContents()

                currentX = currentX + categoryLabel:GetWide() + 10

                -- Create buttons for this category
                for _, tab in ipairs(categoryTabs) do
                    -- Check permissions
                    if not tab.permission or self:HasPermission(tab.permission) then
                        local button = vgui.Create("DButton", menuBar)
                        button:SetText(tab.name)
                        button:SetSize(math.max(80, tab.name:len() * 8), 35)
                        button:SetPos(currentX, 7)

                        -- Advanced button styling
                        button:SetFont("LiliaFont.25")
                        button.normalColor = tab.color or Color(60, 60, 60)
                        button.hoverColor = Color(
                            math.min(button.normalColor.r + 20, 255),
                            math.min(button.normalColor.g + 20, 255),
                            math.min(button.normalColor.b + 20, 255)
                        )

                        button.Paint = function(s, w, h)
                            local color = s:IsHovered() and s.hoverColor or s.normalColor
                            draw.RoundedBox(6, 0, 0, w, h, color)

                            if s:IsDown() then
                                draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 100))
                            end
                        end

                        -- Handle click with animations
                        button.DoClick = function()
                            surface.PlaySound("ui/buttonclick.wav")

                            -- Call tab callback
                            if tab.callback then
                                tab.callback()
                            end

                            -- Switch to tab
                            self:SwitchToTab(tab.id)

                            -- Update button states
                            self:UpdateMenuButtonStates(tab.id)
                        end

                        -- Add tooltip
                        if tab.tooltip then
                            button:SetTooltip(tab.tooltip)
                        end

                        -- Add notification indicator if needed
                        if tab.hasNotification then
                            local indicator = vgui.Create("DPanel", button)
                            indicator:SetSize(8, 8)
                            indicator:SetPos(button:GetWide() - 12, 4)
                            indicator.Paint = function(s, w, h)
                                draw.RoundedBox(4, 0, 0, w, h, Color(255, 100, 100))
                            end
                        end

                        currentX = currentX + button:GetWide() + 8
                    end
                end

                currentX = currentX + 20 -- Spacing between categories
            end

            -- Store menu bar reference
            self.menuBar = menuBar

            return menuBar
        end
        ```
]]
function CreateMenuButtons(tabs)
end

--[[
    Purpose:
        Called when the Derma skin is changed.

    When Called:
        When the UI skin is changed.

    Parameters:
        newSkin (string)
            The new skin name.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log skin change
        function MODULE:DermaSkinChanged(newSkin)
            print("Derma skin changed to: " .. newSkin)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update UI elements for new skin
        function MODULE:DermaSkinChanged(newSkin)
            -- Store the new skin preference
            self.currentSkin = newSkin

            -- Update custom UI elements
            self:RefreshCustomUIElements()

            -- Save skin preference
            if LocalPlayer() then
                LocalPlayer():SetPData("lia_skin", newSkin)
            end

            -- Log the change
            lia.log.add("UI skin changed to: " .. newSkin, FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive skin change handling with theme updates
        function MODULE:DermaSkinChanged(newSkin)
            -- Validate skin
            if not self:IsValidSkin(newSkin) then
                lia.log.add("Invalid skin attempted: " .. newSkin, FLAG_WARNING)
                return
            end

            -- Store previous skin for transition effects
            local oldSkin = self.currentSkin
            self.currentSkin = newSkin

            -- Save skin preference to database
            self:SaveSkinPreference(newSkin)

            -- Update all registered UI panels
            self:UpdateAllPanelsForSkin(newSkin)

            -- Apply skin-specific settings
            self:ApplySkinSettings(newSkin)

            -- Update theme colors
            self:UpdateThemeColors(newSkin)

            -- Handle skin transition effects
            if oldSkin and oldSkin ~= newSkin then
                self:PlaySkinTransitionEffect(oldSkin, newSkin)
            end

            -- Update custom UI components
            self:RefreshCustomComponents()

            -- Notify other modules of skin change
            hook.Run("SkinChanged", newSkin, oldSkin)

            -- Update player settings
            if LocalPlayer() then
                LocalPlayer():setClientNetVar("skin_preference", newSkin)
            end

            -- Log comprehensive skin change
            lia.log.add(string.format("Derma skin changed from '%s' to '%s'",
                oldSkin or "none", newSkin), FLAG_NORMAL)

            -- Schedule cleanup of old skin resources
            timer.Simple(0.1, function()
                self:CleanupOldSkinResources(oldSkin)
            end)
        end

        -- Helper function to validate skin
        function MODULE:IsValidSkin(skinName)
            local validSkins = {
                "Default", "Dark", "Light", "Blue", "Green", "Purple"
            }

            for _, skin in ipairs(validSkins) do
                if skin == skinName then
                    return true
                end
            end

            -- Check for custom skins
            return self.customSkins and self.customSkins[skinName] ~= nil
        end

        -- Helper function to save skin preference
        function MODULE:SaveSkinPreference(skinName)
            if LocalPlayer() then
                LocalPlayer():SetPData("lia_ui_skin", skinName)

                -- Also save to server
                net.Start("SaveSkinPreference")
                    net.WriteString(skinName)
                net.SendToServer()
            end
        end
        ```
]]
function DermaSkinChanged(newSkin)
end

--[[
    Purpose:
        Handles drawing character information on the screen.

    When Called:
        When character information needs to be drawn.

    Parameters:
        player (Player)
            The player whose character info to draw.
        character (Character)
            The character data.
        info (table)
            Information to display.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw basic character name
        function MODULE:DrawCharInfo(player, character, info)
            draw.SimpleText(character:getName(), "LiliaFont.20", 10, 10, color_white)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw character info with faction and class
        function MODULE:DrawCharInfo(player, character, info)
            local name = character:getName()
            local faction = lia.faction.get(character:getFaction())
            local class = lia.class.get(character:getClass())

            draw.SimpleText(name, "LiliaFont.20", 10, 10, color_white)
            if faction then
                draw.SimpleText(faction.name, "LiliaFont.17", 10, 30, faction.color or color_white)
            end
            if class then
                draw.SimpleText(class.name, "LiliaFont.17", 10, 50, color_white)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character info display with custom formatting
        function MODULE:DrawCharInfo(player, character, info)
            if not IsValid(player) or not character then return end

            local pos = player:GetPos() + Vector(0, 0, 80)
            local screenPos = pos:ToScreen()
            if not screenPos.visible then return end

            local name = character:getName()
            local faction = lia.faction.get(character:getFaction())
            local class = lia.class.get(character:getClass())
            local money = character:getMoney()

            -- Custom background panel
            local bgAlpha = 200
            draw.RoundedBox(4, screenPos.x - 100, screenPos.y - 40, 200, 80, Color(0, 0, 0, bgAlpha))

            -- Name with title if available
            local displayName = name
            if character:getData("title") then
                displayName = character:getData("title") .. " " .. name
            end
            draw.SimpleTextOutlined(displayName, "LiliaFont.20", screenPos.x, screenPos.y - 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

            -- Faction and class info
            local yOffset = 10
            if faction then
                draw.SimpleTextOutlined(faction.name, "LiliaFont.17", screenPos.x, screenPos.y - 10, faction.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                yOffset = yOffset + 15
            end
            if class then
                draw.SimpleTextOutlined(class.name, "LiliaFont.17", screenPos.x, screenPos.y + yOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
            end

            -- Custom info from hook data
            if info and info.custom then
                for i, customInfo in ipairs(info.custom) do
                    draw.SimpleTextOutlined(customInfo.text, "LiliaFont.17", screenPos.x, screenPos.y + yOffset + (i * 15), customInfo.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                end
            end
        end
        ```
]]
function DrawCharInfo(player, character, info)
end

--[[
    Purpose:
        Handles drawing door information boxes.

    When Called:
        When door information needs to be displayed.

    Parameters:
        entity (Entity)
            The door entity.
        infoTexts (table)
            Table of information text to display.
        alphaOverride (number)
            Optional alpha override value.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom text to door info
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            table.insert(infoTexts, "Custom Door Information")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add formatted door information
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            local doorData = lia.doors.getData(entity)
            if doorData then
                if doorData.title then
                    table.insert(infoTexts, "Title: " .. doorData.title)
                end
                if doorData.owner then
                    table.insert(infoTexts, "Owner: " .. doorData.owner)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door info display with custom styling
        function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
            if not IsValid(entity) then return end

            local doorData = lia.doors.getData(entity)
            local alpha = alphaOverride or 255

            -- Add door title if available
            if doorData and doorData.title then
                table.insert(infoTexts, {
                    text = doorData.title,
                    color = Color(255, 255, 0, alpha),
                    font = "LiliaFont.20"
                })
            end

            -- Add ownership info
            if doorData and doorData.owner then
                local owner = player.GetBySteamID(doorData.owner)
                if IsValid(owner) then
                    local char = owner:getChar()
                    if char then
                        table.insert(infoTexts, {
                            text = "Owner: " .. char:getName(),
                            color = Color(200, 200, 200, alpha),
                            font = "LiliaFont.17"
                        })
                    end
                end
            end

            -- Add lock status
            if entity:getNetVar("locked", false) then
                table.insert(infoTexts, {
                    text = "Locked",
                    color = Color(255, 0, 0, alpha),
                    font = "LiliaFont.17"
                })
            else
                table.insert(infoTexts, {
                    text = "Unlocked",
                    color = Color(0, 255, 0, alpha),
                    font = "LiliaFont.17"
                })
            end
        end
        ```
]]
function DrawDoorInfoBox(entity, infoTexts, alphaOverride)
end

--[[
    Purpose:
        Handles drawing entity information overlays.

    When Called:
        When entity information should be drawn.

    Parameters:
        entity (Entity)
            The entity to draw info for.
        alpha (number)
            The alpha/transparency value.
        position (Vector)
            The position to draw at.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw basic entity name
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if IsValid(entity) then
                draw.SimpleText(entity:GetClass(), "LiliaFont.17", position.x, position.y, Color(255, 255, 255, alpha))
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw entity info with custom formatting
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if not IsValid(entity) then return end

            local screenPos = position:ToScreen()
            if not screenPos.visible then return end

            local name = entity:GetClass()
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    name = char:getName()
                end
            end

            draw.SimpleTextOutlined(name, "LiliaFont.17", screenPos.x, screenPos.y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced entity info display with multiple data points
        function MODULE:DrawEntityInfo(entity, alpha, position)
            if not IsValid(entity) then return end

            local screenPos = position:ToScreen()
            if not screenPos.visible then return end

            local yOffset = 0
            local infoColor = Color(255, 255, 255, alpha)

            -- Draw entity class/name
            local displayName = entity:GetClass()
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    displayName = char:getName()
                    local faction = lia.faction.get(char:getFaction())
                    if faction then
                        infoColor = faction.color or infoColor
                    end
                end
            elseif entity:IsVehicle() then
                displayName = entity:GetDisplayName() or entity:GetClass()
            end

            draw.SimpleTextOutlined(displayName, "LiliaFont.20", screenPos.x, screenPos.y + yOffset, infoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            yOffset = yOffset + 20

            -- Draw health if applicable
            if entity:Health() and entity:GetMaxHealth() and entity:GetMaxHealth() > 0 then
                local healthPercent = math.Clamp(entity:Health() / entity:GetMaxHealth(), 0, 1)
                local healthColor = Color(255 * (1 - healthPercent), 255 * healthPercent, 0, alpha)
                draw.SimpleTextOutlined("HP: " .. entity:Health() .. "/" .. entity:GetMaxHealth(), "LiliaFont.17", screenPos.x, screenPos.y + yOffset, healthColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
                yOffset = yOffset + 15
            end

            -- Draw custom entity data
            local customData = entity:getNetVar("customInfo")
            if customData then
                for i, data in ipairs(customData) do
                    draw.SimpleTextOutlined(data.text, "LiliaFont.17", screenPos.x, screenPos.y + yOffset, data.color or infoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
                    yOffset = yOffset + 15
                end
            end
        end
        ```
]]
function DrawEntityInfo(entity, alpha, position)
end

--[[
    Purpose:
        Handles drawing the Lilia model view in UI panels.

    When Called:
        When a model view needs to be drawn in a panel.

    Parameters:
        panel (Panel)
            The panel containing the model view.
        entity (Entity)
            The entity being displayed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom lighting to model view
        function MODULE:DrawLiliaModelView(panel, entity)
            if IsValid(entity) then
                render.SetLightingMode(1)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply custom materials and effects
        function MODULE:DrawLiliaModelView(panel, entity)
            if not IsValid(entity) then return end

            -- Apply character-specific material if available
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    local outfit = char:getData("outfit")
                    if outfit and outfit.material then
                        entity:SetMaterial(outfit.material)
                    end
                end
            end

            -- Set custom lighting
            render.SetLightingMode(1)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model view with animations and effects
        function MODULE:DrawLiliaModelView(panel, entity)
            if not IsValid(entity) or not IsValid(panel) then return end

            -- Store original entity state
            local originalPos = entity:GetPos()
            local originalAng = entity:GetAngles()
            local originalSequence = entity:GetSequence()

            -- Apply character customization
            if entity:IsPlayer() then
                local char = entity:getChar()
                if char then
                    -- Apply outfit
                    local outfit = char:getData("outfit")
                    if outfit then
                        if outfit.material then
                            entity:SetMaterial(outfit.material)
                        end
                        if outfit.color then
                            entity:SetColor(outfit.color)
                        end
                    end

                    -- Apply PAC parts
                    local pacData = char:getData("pacData")
                    if pacData then
                        for _, part in ipairs(pacData) do
                            hook.Run("AttachPart", entity, part.id)
                        end
                    end

                    -- Set animation
                    if outfit and outfit.sequence then
                        entity:SetSequence(outfit.sequence)
                    end
                end
            end

            -- Custom lighting setup
            render.SetLightingMode(1)
            local lightPos = entity:GetPos() + Vector(0, 0, 50)
            render.SetLightPosition(lightPos)
            render.SetLightColor(Vector(1, 1, 1))

            -- Draw the model
            entity:DrawModel()

            -- Restore original state
            entity:SetPos(originalPos)
            entity:SetAngles(originalAng)
            if originalSequence then
                entity:SetSequence(originalSequence)
            end
        end
        ```
]]
function DrawLiliaModelView(panel, entity)
end

--[[
    Purpose:
        Handles drawing player ragdolls.

    When Called:
        When a player ragdoll needs to be rendered.

    Parameters:
        entity (Entity)
            The ragdoll entity.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ragdoll drawing
        function MODULE:DrawPlayerRagdoll(entity)
            if IsValid(entity) then
                entity:DrawModel()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw ragdoll with character information
        function MODULE:DrawPlayerRagdoll(entity)
            if not IsValid(entity) then return end

            -- Draw the ragdoll model
            entity:DrawModel()

            -- Draw character name above ragdoll
            local character = entity:getNetVar("char")
            if character then
                local pos = entity:GetPos() + Vector(0, 0, 10)
                local screenPos = pos:ToScreen()
                if screenPos.visible then
                    draw.SimpleText(character.name, "LiliaFont.17", screenPos.x, screenPos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ragdoll rendering with effects and information
        function MODULE:DrawPlayerRagdoll(entity)
            if not IsValid(entity) then return end

            -- Draw the ragdoll model
            entity:DrawModel()

            -- Get character data
            local character = entity:getNetVar("char")
            if not character then return end

            -- Calculate time since death
            local deathTime = entity:getNetVar("deathTime", 0)
            local timeSinceDeath = CurTime() - deathTime

            -- Draw death effects
            if timeSinceDeath < 10 then
                local alpha = 1 - (timeSinceDeath / 10)
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(
                    entity:GetPos() - Vector(0, 0, 50),
                    64,
                    64,
                    Color(150, 0, 0, 200 * alpha)
                )
            end

            -- Draw identification tag
            if character:getData("showID") then
                local pos = entity:GetPos() + Vector(0, 0, 10)
                local screenPos = pos:ToScreen()
                if screenPos.visible then
                    draw.SimpleTextOutlined(character:getName(), "LiliaFont.17", screenPos.x, screenPos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                end
            end
        end
        ```
]]
function DrawPlayerRagdoll(entity)
end

--[[
    Purpose:
        Called when exiting storage.

    When Called:
        When a player exits a storage container.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log storage exit
        function MODULE:ExitStorage()
            print("Storage closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up storage UI and notify
        function MODULE:ExitStorage()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Clear any storage-related UI elements
            if IsValid(self.storagePanel) then
                self.storagePanel:Remove()
                self.storagePanel = nil
            end

            -- Notify player
            client:notify("Storage closed")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced storage cleanup with validation
        function MODULE:ExitStorage()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Close all storage-related panels
            if IsValid(self.storagePanel) then
                self.storagePanel:Remove()
                self.storagePanel = nil
            end

            if IsValid(self.storageInventoryPanel) then
                self.storageInventoryPanel:Remove()
                self.storageInventoryPanel = nil
            end

            -- Save any pending changes
            if self.storagePendingChanges then
                hook.Run("OnRequestItemTransfer", self.storagePanel, self.storagePendingChanges.itemID, self.storagePendingChanges.inventoryID, self.storagePendingChanges.x, self.storagePendingChanges.y)
                self.storagePendingChanges = nil
            end

            -- Clear storage references
            self.storageEntity = nil
            self.storageInventory = nil

            -- Reset UI state
            gui.EnableScreenClicker(false)

            -- Notify with sound
            surface.PlaySound("ui/buttonclickrelease.wav")
            client:notify("Storage closed")

            -- Log storage access
            lia.log.add(client:Name() .. " closed storage", FLAG_NORMAL)
        end
        ```
]]
function ExitStorage()
end

--[[
    Purpose:
        Called when the F1 menu is closed.

    When Called:
        When the F1 help menu is closed.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log menu close
        function MODULE:F1MenuClosed()
            print("F1 menu closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up menu resources
        function MODULE:F1MenuClosed()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Clear menu references
            if IsValid(self.f1MenuPanel) then
                self.f1MenuPanel = nil
            end

            -- Reset UI state
            gui.EnableScreenClicker(false)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu cleanup with state management
        function MODULE:F1MenuClosed()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Clear all menu panels
            if IsValid(self.f1MenuPanel) then
                self.f1MenuPanel:Remove()
                self.f1MenuPanel = nil
            end

            if IsValid(self.f1CharacterPanel) then
                self.f1CharacterPanel:Remove()
                self.f1CharacterPanel = nil
            end

            if IsValid(self.f1InfoPanel) then
                self.f1InfoPanel:Remove()
                self.f1InfoPanel = nil
            end

            -- Save any pending changes
            if self.f1MenuPendingChanges then
                for _, change in ipairs(self.f1MenuPendingChanges) do
                    hook.Run("OnF1MenuChangeApplied", change)
                end
                self.f1MenuPendingChanges = {}
            end

            -- Reset UI state
            gui.EnableScreenClicker(false)
            self.f1MenuOpen = false

            -- Clear any open submenus
            for _, panel in pairs(self.f1SubMenus or {}) do
                if IsValid(panel) then
                    panel:Remove()
                end
            end
            self.f1SubMenus = {}

            -- Play close sound
            surface.PlaySound("ui/buttonclickrelease.wav")

            -- Notify other systems
            hook.Run("OnF1MenuStateChanged", false)
        end
        ```
]]
function F1MenuClosed()
end

--[[
    Purpose:
        Called when the F1 menu is opened.

    When Called:
        When the F1 help menu is opened.

    Parameters:
        menuPanel (Panel)
            The F1 menu panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log menu open
        function MODULE:F1MenuOpened(menuPanel)
            print("F1 menu opened")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize menu state
        function MODULE:F1MenuOpened(menuPanel)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            self.f1MenuPanel = menuPanel
            self.f1MenuOpen = true
            gui.EnableScreenClicker(true)

            -- Add custom menu buttons
            hook.Run("CreateMenuButtons", {
                {name = "Custom", icon = "icon16/star.png", callback = function()
                    client:notify("Custom menu clicked")
                end}
            })
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu initialization with custom tabs
        function MODULE:F1MenuOpened(menuPanel)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Store menu reference
            self.f1MenuPanel = menuPanel
            self.f1MenuOpen = true
            gui.EnableScreenClicker(true)

            -- Initialize menu state
            self.f1SubMenus = {}
            self.f1MenuPendingChanges = {}

            -- Add custom tabs based on character
            local tabs = {
                {name = "Character", icon = "icon16/user.png"},
                {name = "Inventory", icon = "icon16/box.png"},
                {name = "Settings", icon = "icon16/cog.png"}
            }

            local faction = lia.faction.get(character:getFaction())
            if faction and faction.uniqueID == FACTION_POLICE then
                table.insert(tabs, {name = "Police", icon = "icon16/shield.png"})
            end

            -- Create tabs
            for i, tab in ipairs(tabs) do
                local tabButton = menuPanel:AddTab(tab.name, tab.icon)
                tabButton.DoClick = function()
                    self:OpenF1Tab(tab.name)
                end
            end

            -- Load character information
            hook.Run("LoadMainMenuInformation", {}, character)

            -- Play open sound
            surface.PlaySound("ui/buttonclick.wav")

            -- Notify other systems
            hook.Run("OnF1MenuStateChanged", true)
        end
        ```
]]
function F1MenuOpened(menuPanel)
end

--[[
    Purpose:
        Handles filtering door information for display.

    When Called:
        When door information is being prepared for display.

    Parameters:
        entity (Entity)
            The door entity.
        doorData (table)
            The door data.
        doorInfo (table)
            The door information to filter.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic door name
        function MODULE:FilterDoorInfo(entity, doorData, doorInfo)
            if doorData.name then
                table.insert(doorInfo, {text = doorData.name, color = color_white})
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Filter door info with ownership display
        function MODULE:FilterDoorInfo(entity, doorData, doorInfo)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Door name
            if doorData.name then
                table.insert(doorInfo, {text = doorData.name, color = color_white})
            end

            -- Ownership info
            if doorData.ownable then
                if doorData.owner then
                    table.insert(doorInfo, {text = "Owner: " .. doorData.owner, color = Color(100, 200, 100)})
                else
                    table.insert(doorInfo, {text = "Unowned", color = Color(200, 200, 100)})
                end
            end

            -- Lock status
            if doorData.locked then
                table.insert(doorInfo, {text = "Locked", color = Color(255, 100, 100)})
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced door info filtering with access control
        function MODULE:FilterDoorInfo(entity, doorData, doorInfo)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Door name
            if doorData.name then
                table.insert(doorInfo, {text = doorData.name, color = color_white})
            end

            -- Ownership information
            if doorData.ownable then
                if doorData.owner then
                    local ownerName = doorData.owner
                    if doorData.ownerChar then
                        ownerName = doorData.ownerChar:getName()
                    end
                    table.insert(doorInfo, {text = "Owner: " .. ownerName, color = Color(100, 200, 100)})
                else
                    if doorData.price and doorData.price > 0 then
                        table.insert(doorInfo, {text = "For Sale: " .. lia.currency.plural(doorData.price), color = Color(200, 200, 100)})
                    else
                        table.insert(doorInfo, {text = "Unowned", color = Color(200, 200, 100)})
                    end
                end
            end

            -- Lock status with access info
            if doorData.locked then
                local canAccess = hook.Run("CanPlayerAccessDoor", client, entity, DOOR_ACCESS_USE) or false
                if canAccess then
                    table.insert(doorInfo, {text = "Locked (You have access)", color = Color(255, 200, 100)})
                else
                    table.insert(doorInfo, {text = "Locked", color = Color(255, 100, 100)})
                end
            else
                table.insert(doorInfo, {text = "Unlocked", color = Color(100, 255, 100)})
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
                    table.insert(doorInfo, {text = "Restricted Access", color = Color(255, 150, 150)})
                end
            end

            -- Custom door data
            if doorData.customInfo then
                for _, info in ipairs(doorData.customInfo) do
                    table.insert(doorInfo, {text = info.text, color = info.color or color_white})
                end
            end
        end
        ```
]]
function FilterDoorInfo(entity, doorData, doorInfo)
end

--[[
    Purpose:
        Gets the main menu position for a character.

    When Called:
        When determining where to position the main menu.

    Parameters:
        character (Character)
            The character.

    Returns:
        Vector
            The position for the main menu.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Return default position
        function MODULE:GetMainMenuPosition(character)
            return Vector(0, 0, 0)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Position based on character spawn
        function MODULE:GetMainMenuPosition(character)
            local client = LocalPlayer()
            if not IsValid(client) then return Vector(0, 0, 0) end

            -- Get character spawn position
            local spawnPos = character:getData("spawnPos")
            if spawnPos then
                return spawnPos
            end

            return client:GetPos()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced position calculation with faction/class preferences
        function MODULE:GetMainMenuPosition(character)
            if not character then return Vector(0, 0, 0) end

            local client = LocalPlayer()
            if not IsValid(client) then return Vector(0, 0, 0) end

            -- Check for custom position in character data
            local customPos = character:getData("menuPosition")
            if customPos then
                return customPos
            end

            -- Get faction-specific spawn position
            local faction = lia.faction.get(character:getFaction())
            if faction and faction.spawnPositions then
                local spawns = faction.spawnPositions
                if #spawns > 0 then
                    -- Use last spawn position or random
                    local spawnIndex = character:getData("lastSpawnIndex", 1)
                    if spawnIndex > #spawns then spawnIndex = 1 end
                    return spawns[spawnIndex]
                end
            end

            -- Get class-specific position
            local class = lia.class.get(character:getClass())
            if class and class.spawnPos then
                return class.spawnPos
            end

            -- Default to current position or spawn point
            local spawnPos = character:getData("spawnPos")
            if spawnPos then
                return spawnPos
            end

            -- Fallback to player position
            return client:GetPos()
        end
        ```
]]
function GetMainMenuPosition(character)
end

--[[
    Purpose:
        Called when the interaction menu is closed.

    When Called:
        When the interaction menu is closed.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log menu close
        function MODULE:InteractionMenuClosed()
            print("Interaction menu closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up interaction menu
        function MODULE:InteractionMenuClosed()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            if IsValid(self.interactionMenu) then
                self.interactionMenu:Remove()
                self.interactionMenu = nil
            end

            gui.EnableScreenClicker(false)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced cleanup with state management
        function MODULE:InteractionMenuClosed()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Remove all interaction menu panels
            if IsValid(self.interactionMenu) then
                self.interactionMenu:Remove()
                self.interactionMenu = nil
            end

            if IsValid(self.interactionOptions) then
                self.interactionOptions:Remove()
                self.interactionOptions = nil
            end

            -- Clear interaction target
            self.interactionTarget = nil
            self.interactionEntity = nil

            -- Reset UI state
            gui.EnableScreenClicker(false)
            self.interactionMenuOpen = false

            -- Save any pending interaction data
            if self.interactionPendingData then
                hook.Run("OnInteractionDataSaved", self.interactionPendingData)
                self.interactionPendingData = nil
            end

            -- Play close sound
            surface.PlaySound("ui/buttonclickrelease.wav")

            -- Notify other systems
            hook.Run("OnInteractionMenuStateChanged", false)
        end
        ```
]]
function InteractionMenuClosed()
end

--[[
    Purpose:
        Called when the interaction menu is opened.

    When Called:
        When the interaction menu is opened.

    Parameters:
        frame (Panel)
            The interaction menu frame.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Store menu reference
        function MODULE:InteractionMenuOpened(frame)
            self.interactionMenu = frame
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize interaction menu
        function MODULE:InteractionMenuOpened(frame)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            self.interactionMenu = frame
            self.interactionMenuOpen = true
            gui.EnableScreenClicker(true)

            -- Add default options
            hook.Run("ShowPlayerOptions", client, {})
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu initialization with custom options
        function MODULE:InteractionMenuOpened(frame)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Store menu reference
            self.interactionMenu = frame
            self.interactionMenuOpen = true
            gui.EnableScreenClicker(true)

            -- Get interaction target
            local target = self.interactionTarget or client
            local entity = self.interactionEntity

            -- Build options based on target
            local options = {}

            if IsValid(target) and target:IsPlayer() then
                -- Player interaction options
                table.insert(options, {
                    name = "Talk",
                    icon = "icon16/user.png",
                    callback = function()
                        hook.Run("OnPlayerInteraction", "talk", target)
                    end
                })

                if character:hasFlags("T") then -- Trade flag
                    table.insert(options, {
                        name = "Trade",
                        icon = "icon16/cart.png",
                        callback = function()
                            hook.Run("OnPlayerInteraction", "trade", target)
                        end
                    })
                end
            elseif IsValid(entity) then
                -- Entity interaction options
                if entity:getClass() == "lia_storage" then
                    table.insert(options, {
                        name = "Open Storage",
                        icon = "icon16/box.png",
                        callback = function()
                            hook.Run("OnEntityInteraction", "storage", entity)
                        end
                    })
                end

                if entity:getClass() == "lia_vendor" then
                    table.insert(options, {
                        name = "Buy Items",
                        icon = "icon16/cart_add.png",
                        callback = function()
                            hook.Run("OnEntityInteraction", "vendor", entity)
                        end
                    })
                end
            end

            -- Add custom options from other hooks
            hook.Run("PopulateInteractionOptions", options, target, entity)

            -- Create options menu
            hook.Run("ShowPlayerOptions", target, options)

            -- Play open sound
            surface.PlaySound("ui/buttonclick.wav")

            -- Notify other systems
            hook.Run("OnInteractionMenuStateChanged", true)
        end
        ```
]]
function InteractionMenuOpened(frame)
end

--[[
    Purpose:
        Intercepts clicks on item icons.

    When Called:
        When an item icon is clicked.

    Parameters:
        panel (Panel)
            The panel containing the icon.
        itemIcon (Panel)
            The item icon panel.
        keyCode (number)
            The key code of the click.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item icon click
        function MODULE:InterceptClickItemIcon(panel, itemIcon, keyCode)
            print("Item icon clicked with key: " .. keyCode)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Handle right-click context menu
        function MODULE:InterceptClickItemIcon(panel, itemIcon, keyCode)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            if keyCode == MOUSE_RIGHT then
                local item = itemIcon:GetItem()
                if item then
                    -- Show context menu
                    local menu = DermaMenu()
                    menu:AddOption("Use", function()
                        item:use()
                    end)
                    menu:AddOption("Drop", function()
                        item:drop()
                    end)
                    menu:Open()
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item interaction with validation
        function MODULE:InterceptClickItemIcon(panel, itemIcon, keyCode)
            if not IsValid(panel) or not IsValid(itemIcon) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            local item = itemIcon:GetItem()
            if not item then return end

            -- Left click - use item
            if keyCode == MOUSE_LEFT then
                -- Check if item can be used
                if hook.Run("CanPlayerInteractItem", client, "use", item) then
                    item:use()
                    surface.PlaySound("ui/buttonclick.wav")
                else
                    client:notify("You cannot use this item")
                    surface.PlaySound("buttons/button10.wav")
                end

            -- Right click - context menu
            elseif keyCode == MOUSE_RIGHT then
                local menu = DermaMenu()

                -- Use option
                if hook.Run("CanPlayerInteractItem", client, "use", item) then
                    menu:AddOption("Use", function()
                        item:use()
                    end):SetIcon("icon16/arrow_right.png")
                end

                -- Drop option
                if hook.Run("CanPlayerDropItem", client, item) then
                    menu:AddOption("Drop", function()
                        item:drop()
                    end):SetIcon("icon16/delete.png")
                end

                -- Custom item actions
                local actions = item.functions or {}
                for actionName, actionData in pairs(actions) do
                    if actionData.onRun then
                        menu:AddOption(actionData.name or actionName, function()
                            actionData.onRun(client, item)
                        end)
                    end
                end

                -- Admin options
                if client:hasPrivilege("Staff Permissions") then
                    menu:AddSpacer()
                    menu:AddOption("Delete Item", function()
                        item:remove()
                    end):SetIcon("icon16/cross.png")
                end

                menu:Open()
            end

            -- Middle click - examine
            if keyCode == MOUSE_MIDDLE then
                hook.Run("OnItemExamined", client, item)
            end
        end
        ```
]]
function InterceptClickItemIcon(panel, itemIcon, keyCode)
end

--[[
    Purpose:
        Called when an inventory panel is closed.

    When Called:
        When an inventory UI is closed.

    Parameters:
        panel (Panel)
            The inventory panel.
        inventory (Inventory)
            The inventory.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log inventory close
        function MODULE:InventoryClosed(panel, inventory)
            print("Inventory closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up inventory UI
        function MODULE:InventoryClosed(panel, inventory)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            if IsValid(panel) then
                panel:Remove()
            end

            gui.EnableScreenClicker(false)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory cleanup with state management
        function MODULE:InventoryClosed(panel, inventory)
            if not IsValid(panel) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Save any pending item transfers
            if self.inventoryPendingTransfers then
                for _, transfer in ipairs(self.inventoryPendingTransfers) do
                    hook.Run("OnRequestItemTransfer", panel, transfer.itemID, transfer.inventoryID, transfer.x, transfer.y)
                end
                self.inventoryPendingTransfers = {}
            end

            -- Remove all inventory-related panels
            if IsValid(self.inventoryPanel) then
                self.inventoryPanel:Remove()
                self.inventoryPanel = nil
            end

            if IsValid(self.storagePanel) then
                self.storagePanel:Remove()
                self.storagePanel = nil
            end

            -- Clear inventory references
            self.currentInventory = nil
            self.storageInventory = nil

            -- Reset UI state
            gui.EnableScreenClicker(false)
            self.inventoryOpen = false

            -- Save inventory state
            if inventory then
                inventory:save()
                hook.Run("OnInventorySaved", inventory)
            end

            -- Play close sound
            surface.PlaySound("ui/buttonclickrelease.wav")

            -- Notify other systems
            hook.Run("OnInventoryStateChanged", false, inventory)
        end
        ```
]]
function InventoryClosed(panel, inventory)
end

--[[
    Purpose:
        Called when an inventory item icon is created.

    When Called:
        When creating inventory item icons.

    Parameters:
        icon (Panel)
            The icon panel.
        item (Item)
            The item.
        panel (Panel)
            The parent panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set icon tooltip
        function MODULE:InventoryItemIconCreated(icon, item, panel)
            if item then
                icon:SetTooltip(item:getName())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize icon appearance
        function MODULE:InventoryItemIconCreated(icon, item, panel)
            if not item then return end

            -- Set tooltip with item description
            local tooltip = item:getName()
            if item:getDesc() then
                tooltip = tooltip .. "\n" .. item:getDesc()
            end
            icon:SetTooltip(tooltip)

            -- Color code based on rarity
            if item:getData("rarity") then
                local rarity = item:getData("rarity")
                local colors = {
                    common = Color(200, 200, 200),
                    uncommon = Color(100, 200, 100),
                    rare = Color(100, 150, 255),
                    epic = Color(200, 100, 255),
                    legendary = Color(255, 200, 100)
                }
                if colors[rarity] then
                    icon:SetColor(colors[rarity])
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced icon customization with validation
        function MODULE:InventoryItemIconCreated(icon, item, panel)
            if not IsValid(icon) or not item then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Build comprehensive tooltip
            local tooltip = item:getName()
            if item:getDesc() then
                tooltip = tooltip .. "\n" .. item:getDesc()
            end

            -- Add item stats
            if item:getData("stats") then
                tooltip = tooltip .. "\n\nStats:"
                for stat, value in pairs(item:getData("stats")) do
                    tooltip = tooltip .. "\n" .. stat .. ": " .. value
                end
            end

            -- Add durability if applicable
            if item:getData("durability") then
                local durability = item:getData("durability")
                local maxDurability = item:getData("maxDurability", 100)
                local percent = math.Round((durability / maxDurability) * 100)
                tooltip = tooltip .. "\n\nDurability: " .. percent .. "%"
            end

            icon:SetTooltip(tooltip)

            -- Apply rarity coloring
            if item:getData("rarity") then
                local rarity = item:getData("rarity")
                local rarityColors = {
                    common = Color(200, 200, 200),
                    uncommon = Color(100, 200, 100),
                    rare = Color(100, 150, 255),
                    epic = Color(200, 100, 255),
                    legendary = Color(255, 200, 100)
                }
                if rarityColors[rarity] then
                    icon:SetColor(rarityColors[rarity])
                end
            end

            -- Add quantity display for stackable items
            if item:getData("quantity") and item:getData("quantity") > 1 then
                icon:SetQuantity(item:getData("quantity"))
            end

            -- Add custom overlay for special items
            if item:getData("special") then
                icon:AddOverlay("special", Material("icon16/star.png"))
            end

            -- Hook click events
            icon.DoClick = function()
                hook.Run("InterceptClickItemIcon", panel, icon, MOUSE_LEFT)
            end

            icon.DoRightClick = function()
                hook.Run("InterceptClickItemIcon", panel, icon, MOUSE_RIGHT)
            end
        end
        ```
]]
function InventoryItemIconCreated(icon, item, panel)
end

--[[
    Purpose:
        Called when an inventory is opened.

    When Called:
        When an inventory UI is opened.

    Parameters:
        panel (Panel)
            The inventory panel.
        inventory (Inventory)
            The inventory.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Store panel reference
        function MODULE:InventoryOpened(panel, inventory)
            self.inventoryPanel = panel
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize inventory UI
        function MODULE:InventoryOpened(panel, inventory)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            self.inventoryPanel = panel
            self.currentInventory = inventory
            self.inventoryOpen = true
            gui.EnableScreenClicker(true)

            -- Play open sound
            surface.PlaySound("ui/buttonclick.wav")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory initialization with validation
        function MODULE:InventoryOpened(panel, inventory)
            if not IsValid(panel) or not inventory then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Store references
            self.inventoryPanel = panel
            self.currentInventory = inventory
            self.inventoryOpen = true
            gui.EnableScreenClicker(true)

            -- Initialize inventory state
            self.inventoryPendingTransfers = {}

            -- Validate inventory access
            if not hook.Run("CanPlayerViewInventory", client) then
                panel:Close()
                client:notify("You cannot access this inventory")
                return
            end

            -- Load inventory items
            inventory:sync(function()
                -- Refresh UI after sync
                hook.Run("PopulateInventoryItems", panel, inventory)
            end)

            -- Add custom inventory buttons
            local buttons = panel:GetButtons()
            if buttons then
                buttons:AddButton("Sort", function()
                    hook.Run("OnInventorySortRequested", inventory)
                end):SetIcon("icon16/arrow_up_down.png")

                buttons:AddButton("Search", function()
                    hook.Run("OnInventorySearchRequested", panel)
                end):SetIcon("icon16/magnifier.png")
            end

            -- Play open sound
            surface.PlaySound("ui/buttonclick.wav")

            -- Notify other systems
            hook.Run("OnInventoryStateChanged", true, inventory)
        end
        ```
]]
function InventoryOpened(panel, inventory)
end

--[[
    Purpose:
        Called when an inventory panel is created.

    When Called:
        When creating inventory UI panels.

    Parameters:
        panel (Panel)
            The inventory panel.
        inventory (Inventory)
            The inventory.
        parent (Panel)
            The parent panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set panel title
        function MODULE:InventoryPanelCreated(panel, inventory, parent)
            if inventory then
                panel:SetTitle(inventory:getName() or "Inventory")
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize panel appearance
        function MODULE:InventoryPanelCreated(panel, inventory, parent)
            if not IsValid(panel) then return end

            -- Set panel properties
            panel:SetSize(500, 400)
            panel:Center()

            if inventory then
                panel:SetTitle(inventory:getName() or "Inventory")
            end

            -- Add close button
            panel:SetCloseButton(true)

            -- Set panel color based on inventory type
            if inventory:getType() == "character" then
                panel:SetBackgroundColor(Color(50, 50, 50, 255))
            elseif inventory:getType() == "storage" then
                panel:SetBackgroundColor(Color(40, 40, 60, 255))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced panel setup with custom features
        function MODULE:InventoryPanelCreated(panel, inventory, parent)
            if not IsValid(panel) or not inventory then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            -- Configure panel size and position
            panel:SetSize(600, 500)
            panel:Center()
            panel:MakePopup()

            -- Set title with inventory info
            local title = inventory:getName() or "Inventory"
            if inventory:getType() == "character" then
                title = character:getName() .. "'s Inventory"
            elseif inventory:getType() == "storage" then
                title = "Storage: " .. title
            end
            panel:SetTitle(title)

            -- Add header with inventory stats
            local header = panel:Add("DPanel")
            header:SetTall(30)
            header:Dock(TOP)
            header.Paint = function(self, w, h)
                local itemCount = inventory:getItemCount()
                local maxItems = inventory:getMaxItems() or 0
                draw.SimpleText("Items: " .. itemCount .. " / " .. maxItems, "LiliaFont.17", 10, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            -- Add toolbar with buttons
            local toolbar = panel:Add("DPanel")
            toolbar:SetTall(35)
            toolbar:Dock(TOP)
            toolbar.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 255))
            end

            -- Sort button
            local sortBtn = toolbar:Add("DButton")
            sortBtn:SetText("Sort")
            sortBtn:SetSize(60, 25)
            sortBtn:SetPos(5, 5)
            sortBtn.DoClick = function()
                hook.Run("OnInventorySortRequested", inventory)
            end

            -- Search button
            local searchBtn = toolbar:Add("DButton")
            searchBtn:SetText("Search")
            searchBtn:SetSize(60, 25)
            searchBtn:SetPos(70, 5)
            searchBtn.DoClick = function()
                hook.Run("OnInventorySearchRequested", panel)
            end

            -- Set panel styling
            panel:SetBackgroundColor(Color(50, 50, 50, 255))
            panel:SetCloseButton(true)

            -- Store panel reference
            self.inventoryPanel = panel
        end
        ```
]]
function InventoryPanelCreated(panel, inventory, parent)
end

--[[
    Purpose:
        Called when an item is dragged out of inventory.

    When Called:
        When dragging items from inventory UI.

    Parameters:
        client (Player)
            The player dragging the item.
        item (Item)
            The item being dragged.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log item drag
        function MODULE:ItemDraggedOutOfInventory(client, item)
            print("Item dragged: " .. item:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate drag operation
        function MODULE:ItemDraggedOutOfInventory(client, item)
            if not IsValid(client) or not item then return end

            local character = client:getChar()
            if not character then return end

            -- Check if item can be dragged
            if item:getData("locked") then
                client:notify("This item cannot be moved")
                return false
            end

            -- Start drag operation
            self.draggedItem = item
            self.dragStartTime = CurTime()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced drag handling with validation
        function MODULE:ItemDraggedOutOfInventory(client, item)
            if not IsValid(client) or not item then return end

            local character = client:getChar()
            if not character then return end

            -- Validate item ownership
            if item:getOwner() ~= character then
                client:notify("You don't own this item")
                return false
            end

            -- Check if item is locked
            if item:getData("locked") then
                client:notify("This item is locked and cannot be moved")
                return false
            end

            -- Check if item is equipped
            if item:getData("equipped") then
                local unequip = hook.Run("CanPlayerUnequipItem", client, item)
                if not unequip then
                    client:notify("You must unequip this item first")
                    return false
                end
                item:unequip()
            end

            -- Check weight restrictions
            local weight = item:getWeight() or 0
            if weight > 0 then
                local currentWeight = character:getInv():getWeight()
                local maxWeight = character:getInv():getMaxWeight()
                if currentWeight + weight > maxWeight then
                    client:notify("Cannot drag: inventory would be too heavy")
                    return false
                end
            end

            -- Start drag operation
            self.draggedItem = item
            self.dragStartTime = CurTime()
            self.dragStartPos = item:getPos()

            -- Create drag preview
            self.dragPreview = item:getModel()
            if self.dragPreview then
                surface.PlaySound("ui/buttonclick.wav")
            end

            -- Notify other systems
            hook.Run("OnItemDragStarted", client, item)
        end
        ```
]]
function ItemDraggedOutOfInventory(client, item)
end

--[[
    Purpose:
        Called when an item is painted over in UI.

    When Called:
        When rendering item overlays in the UI.

    Parameters:
        panel (Panel)
            The panel being painted.
        itemTable (table)
            The item table.
        width (number)
            The panel width.
        height (number)
            The panel height.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw item name
        function MODULE:ItemPaintOver(panel, itemTable, width, height)
            if itemTable then
                draw.SimpleText(itemTable.name or "Item", "LiliaFont.17", 5, 5, color_white)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Draw item info overlay
        function MODULE:ItemPaintOver(panel, itemTable, width, height)
            if not itemTable then return end

            -- Draw item name
            draw.SimpleTextOutlined(itemTable.name or "Item", "LiliaFont.17", 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)

            -- Draw quantity if stackable
            if itemTable.quantity and itemTable.quantity > 1 then
                draw.SimpleTextOutlined("x" .. itemTable.quantity, "LiliaFont.12", width - 5, height - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item overlay with multiple data points
        function MODULE:ItemPaintOver(panel, itemTable, width, height)
            if not itemTable then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Draw item name with rarity color
            local nameColor = color_white
            if itemTable.rarity then
                local rarityColors = {
                    common = Color(200, 200, 200),
                    uncommon = Color(100, 200, 100),
                    rare = Color(100, 150, 255),
                    epic = Color(200, 100, 255),
                    legendary = Color(255, 200, 100)
                }
                nameColor = rarityColors[itemTable.rarity] or nameColor
            end

            draw.SimpleTextOutlined(itemTable.name or "Item", "LiliaFont.17", 5, 5, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)

            -- Draw quantity badge
            if itemTable.quantity and itemTable.quantity > 1 then
                local badgeWidth = 30
                local badgeHeight = 15
                draw.RoundedBox(4, width - badgeWidth - 5, height - badgeHeight - 5, badgeWidth, badgeHeight, Color(100, 100, 100, 200))
                draw.SimpleText("x" .. itemTable.quantity, "LiliaFont.12", width - badgeWidth/2 - 5, height - badgeHeight/2 - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Draw durability bar
            if itemTable.durability and itemTable.maxDurability then
                local durability = itemTable.durability
                local maxDurability = itemTable.maxDurability
                local percent = durability / maxDurability

                local barWidth = width - 10
                local barHeight = 3
                local barX = 5
                local barY = height - barHeight - 5

                -- Background
                draw.RoundedBox(0, barX, barY, barWidth, barHeight, Color(50, 50, 50, 255))

                -- Durability bar
                local barColor = percent > 0.5 and Color(100, 255, 100) or (percent > 0.25 and Color(255, 200, 100) or Color(255, 100, 100))
                draw.RoundedBox(0, barX, barY, barWidth * percent, barHeight, barColor)
            end

            -- Draw special indicator
            if itemTable.special then
                surface.SetDrawColor(255, 200, 0, 255)
                surface.SetMaterial(Material("icon16/star.png"))
                surface.DrawTexturedRect(width - 20, 5, 15, 15)
            end

            -- Draw equipped indicator
            if itemTable.equipped then
                draw.SimpleTextOutlined("EQUIPPED", "LiliaFont.12", width/2, height - 10, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
            end
        end
        ```
]]
function ItemPaintOver(panel, itemTable, width, height)
end

--[[
    Purpose:
        Called when an item entity menu should be shown.

    When Called:
        When right-clicking on item entities.

    Parameters:
        entity (Entity)
            The item entity.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Show basic item menu
        function MODULE:ItemShowEntityMenu(entity)
            local menu = DermaMenu()
            menu:AddOption("Pick Up", function()
                entity:Use()
            end)
            menu:Open()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show item menu with options
        function MODULE:ItemShowEntityMenu(entity)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local item = entity:getItem()
            if not item then return end

            local menu = DermaMenu()
            menu:AddOption("Pick Up", function()
                entity:Use()
            end):SetIcon("icon16/arrow_down.png")

            menu:AddOption("Examine", function()
                client:notify(item:getDesc() or "No description")
            end):SetIcon("icon16/eye.png")

            menu:Open()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item menu with validation
        function MODULE:ItemShowEntityMenu(entity)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local character = client:getChar()
            if not character then return end

            local item = entity:getItem()
            if not item then return end

            local menu = DermaMenu()

            -- Pick up option
            if hook.Run("CanPlayerPickupItem", client, item) then
                menu:AddOption("Pick Up", function()
                    entity:Use()
                end):SetIcon("icon16/arrow_down.png")
            end

            -- Examine option
            menu:AddOption("Examine", function()
                local desc = item:getDesc() or "No description available"
                local itemInfo = item:getName() .. "\n\n" .. desc

                if item:getData("stats") then
                    itemInfo = itemInfo .. "\n\nStats:"
                    for stat, value in pairs(item:getData("stats")) do
                        itemInfo = itemInfo .. "\n" .. stat .. ": " .. value
                    end
                end

                Derma_Message(itemInfo, "Item Information", "OK")
            end):SetIcon("icon16/eye.png")

            -- Admin options
            if client:hasPrivilege("Staff Permissions") then
                menu:AddSpacer()
                menu:AddOption("Delete Item", function()
                    entity:Remove()
                end):SetIcon("icon16/cross.png")

                menu:AddOption("Teleport To", function()
                    client:SetPos(entity:GetPos())
                end):SetIcon("icon16/arrow_up.png")
            end

            -- Custom item actions
            if item.functions then
                for actionName, actionData in pairs(item.functions) do
                    if actionData.onRun then
                        menu:AddOption(actionData.name or actionName, function()
                            actionData.onRun(client, item)
                        end)
                    end
                end
            end

            menu:Open()
        end
        ```
]]
function ItemShowEntityMenu(entity)
end

--[[
    Purpose:
        Called when the admin stick menu is closed.

    When Called:
        When the admin stick UI is closed.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log menu closure
        function MODULE:OnAdminStickMenuClosed()
            print("Admin stick menu closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up menu resources
        function MODULE:OnAdminStickMenuClosed()
            -- Remove menu references
            self.adminStickMenu = nil

            -- Reset any menu-related states
            self.menuOpen = false

            -- Log closure
            lia.log.add("Admin stick menu closed", FLAG_NORMAL)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu cleanup with state management
        function MODULE:OnAdminStickMenuClosed()
            -- Clean up menu references
            if IsValid(self.adminStickMenu) then
                self.adminStickMenu:Remove()
                self.adminStickMenu = nil
            end

            -- Reset menu state
            self.menuOpen = false
            self.selectedTarget = nil

            -- Save menu preferences
            if self.menuPreferences then
                self:SaveMenuPreferences(self.menuPreferences)
            end

            -- Notify other systems
            hook.Run("OnAdminMenuClosed", "stick")

            -- Log closure with details
            lia.log.add("Admin stick menu closed", FLAG_NORMAL)
        end
        ```
]]
function OnAdminStickMenuClosed()
end

--[[
    Purpose:
        Loads character information for display.

    When Called:
        When loading character info for the UI.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load basic character info
        function MODULE:LoadCharInformation()
            local char = LocalPlayer():getChar()
            if char then
                print("Character: " .. char:getName())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load and display character information
        function MODULE:LoadCharInformation()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Load character data
            self.charInfo = {
                name = char:getName(),
                faction = char:getFaction(),
                money = char:getMoney(),
                level = char:getData("level", 1)
            }

            -- Update UI
            hook.Run("UpdateCharInfoUI", self.charInfo)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced character information loading with caching
        function MODULE:LoadCharInformation()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Load comprehensive character data
            self.charInfo = {
                name = char:getName(),
                desc = char:getDesc(),
                faction = char:getFaction(),
                class = char:getClass(),
                money = char:getMoney(),
                level = char:getData("level", 1),
                playTime = char:getData("playTime", 0),
                attributes = char:getAttribs(),
                inventory = self:GetCharInventoryInfo(char),
                flags = char:getFlags(),
                data = char:getData()
            }

            -- Cache character information
            self:CacheCharInfo(char:getID(), self.charInfo)

            -- Update UI elements
            hook.Run("UpdateCharInfoUI", self.charInfo)
            hook.Run("UpdateCharAttributesUI", self.charInfo.attributes)
            hook.Run("UpdateCharInventoryUI", self.charInfo.inventory)

            -- Log load
            lia.log.add("Character information loaded: " .. char:getName(), FLAG_NORMAL)
        end
        ```
]]
function LoadCharInformation()
end

--[[
    Purpose:
        Loads main menu information.

    When Called:
        When loading main menu data.

    Parameters:
        info (table)
            The information table.
        character (Character)
            The character.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic character info
        function MODULE:LoadMainMenuInformation(info, character)
            if character then
                info.name = character:getName()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load character and player info
        function MODULE:LoadMainMenuInformation(info, character)
            if character then
                info.name = character:getName()
                info.faction = character:getFaction()
                info.money = character:getMoney()
                info.playTime = character:getData("playTime", 0)
            end

            local client = LocalPlayer()
            if IsValid(client) then
                info.steamID = client:SteamID()
                info.ping = client:Ping()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced main menu information loading
        function MODULE:LoadMainMenuInformation(info, character)
            if character then
                -- Character data
                info.name = character:getName()
                info.desc = character:getDesc()
                info.faction = character:getFaction()
                info.class = character:getClass()
                info.money = character:getMoney()
                info.playTime = character:getData("playTime", 0)
                info.level = character:getData("level", 1)
                info.attributes = character:getAttribs()

                -- Character statistics
                info.stats = {
                    deaths = character:getData("deaths", 0),
                    kills = character:getData("kills", 0),
                    itemsCrafted = character:getData("itemsCrafted", 0)
                }
            end

            -- Player data
            local client = LocalPlayer()
            if IsValid(client) then
                info.steamID = client:SteamID()
                info.ping = client:Ping()
                info.fps = math.floor(1 / FrameTime())
                info.serverName = GetHostName()
            end

            -- Server information
            info.serverData = {
                players = #player.GetAll(),
                maxPlayers = game.MaxPlayers(),
                map = game.GetMap()
            }

            -- Cache information
            self.mainMenuInfo = info
        end
        ```
]]
function LoadMainMenuInformation(info, character)
end

--[[
    Purpose:
        Modifies the character model for rendering.

    When Called:
        When rendering character models.

    Parameters:
        entity (Entity)
            The entity being rendered.
        character (Character)
            The character.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Apply model modification
        function MODULE:ModifyCharacterModel(entity, character)
            if IsValid(entity) and character then
                entity:SetModel(character:getModel())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Modify model with character-specific settings
        function MODULE:ModifyCharacterModel(entity, character)
            if not IsValid(entity) or not character then return end

            -- Set model
            entity:SetModel(character:getModel())

            -- Apply character-specific skin
            local skin = character:getData("skin", 0)
            if skin > 0 then
                entity:SetSkin(skin)
            end

            -- Apply bodygroups
            local bodygroups = character:getData("bodygroups", {})
            for group, value in pairs(bodygroups) do
                entity:SetBodygroup(group, value)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model modification with validation and effects
        function MODULE:ModifyCharacterModel(entity, character)
            if not IsValid(entity) or not character then return end

            -- Validate model
            local model = character:getModel()
            if not util.IsValidModel(model) then
                model = "models/player/Group01/male_01.mdl"
            end

            -- Set model
            entity:SetModel(model)

            -- Apply character-specific modifications
            local skin = character:getData("skin", 0)
            if skin >= 0 and skin < entity:SkinCount() then
                entity:SetSkin(skin)
            end

            -- Apply bodygroups
            local bodygroups = character:getData("bodygroups", {})
            for group, value in pairs(bodygroups) do
                if group >= 0 and group < entity:GetBodygroupCount() then
                    entity:SetBodygroup(group, value)
                end
            end

            -- Apply custom materials
            local materials = character:getData("materials", {})
            for materialPath, materialID in pairs(materials) do
                entity:SetSubMaterial(materialID, materialPath)
            end

            -- Apply color modifications
            local color = character:getData("color", Color(255, 255, 255))
            entity:SetColor(color)

            -- Apply effects
            hook.Run("OnCharacterModelModified", entity, character)
        end
        ```
]]
function ModifyCharacterModel(entity, character)
end

--[[
    Purpose:
        Modifies the scoreboard model display.

    When Called:
        When rendering player models on the scoreboard.

    Parameters:
        entity (Entity)
            The entity being rendered.
        player (Player)
            The player.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic scoreboard model modification
        function MODULE:ModifyScoreboardModel(entity, player)
            if IsValid(entity) and IsValid(player) then
                entity:SetModel(player:GetModel())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Modify scoreboard model with player data
        function MODULE:ModifyScoreboardModel(entity, player)
            if not IsValid(entity) or not IsValid(player) then return end

            -- Set model
            entity:SetModel(player:GetModel())

            -- Apply player color
            local color = team.GetColor(player:Team())
            entity:SetColor(color)

            -- Apply skin if available
            local skin = player:GetInfoNum("cl_playerskin", 0)
            if skin > 0 then
                entity:SetSkin(skin)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced scoreboard model modification with character data
        function MODULE:ModifyScoreboardModel(entity, player)
            if not IsValid(entity) or not IsValid(player) then return end

            -- Get character data
            local char = player:getChar()
            if char then
                -- Set character model
                local model = char:getModel()
                if util.IsValidModel(model) then
                    entity:SetModel(model)
                else
                    entity:SetModel(player:GetModel())
                end

                -- Apply character-specific modifications
                local skin = char:getData("skin", 0)
                if skin >= 0 and skin < entity:SkinCount() then
                    entity:SetSkin(skin)
                end

                -- Apply bodygroups
                local bodygroups = char:getData("bodygroups", {})
                for group, value in pairs(bodygroups) do
                    if group >= 0 and group < entity:GetBodygroupCount() then
                        entity:SetBodygroup(group, value)
                    end
                end
            else
                -- Default player model
                entity:SetModel(player:GetModel())
            end

            -- Apply team color
            local color = team.GetColor(player:Team())
            entity:SetColor(color)

            -- Apply admin status indicator
            if player:IsAdmin() then
                entity:SetMaterial("models/debug/debugwhite")
            end
        end
        ```
]]
function ModifyScoreboardModel(entity, player)
end

--[[
    Purpose:
        Modifies voice indicator text.

    When Called:
        When displaying voice chat indicators.

    Parameters:
        client (Player)
            The speaking player.
        voiceText (string)
            The voice text.
        voiceType (string)
            The voice type.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Modify voice indicator text
        function MODULE:ModifyVoiceIndicatorText(client, voiceText, voiceType)
            return "Speaking"
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize voice text based on type
        function MODULE:ModifyVoiceIndicatorText(client, voiceText, voiceType)
            if voiceType == "whisper" then
                return "Whispering"
            elseif voiceType == "yell" then
                return "Yelling"
            end
            return voiceText
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced voice indicator with roleplay context
        function MODULE:ModifyVoiceIndicatorText(client, voiceText, voiceType)
            if not IsValid(client) then return voiceText end

            local char = client:getChar()
            if not char then return voiceText end

            -- Customize based on voice type
            local customText = voiceText
            if voiceType == "whisper" then
                customText = "Whispering"
            elseif voiceType == "yell" then
                customText = "Yelling"
            elseif voiceType == "radio" then
                customText = "Radio: " .. char:getName()
            end

            -- Add roleplay context
            if char:getData("roleplayMode") then
                customText = "[RP] " .. customText
            end

            -- Check if player is muted
            if char:getData("muted", false) then
                customText = "Muted"
            end

            return customText
        end
        ```
]]
function ModifyVoiceIndicatorText(client, voiceText, voiceType)
end

--[[
    Purpose:
        Called when creating an item interaction menu.

    When Called:
        When an item interaction menu is being created.

    Parameters:
        panel (Panel)
            The parent panel.
        menu (Panel)
            The menu panel.
        itemTable (table)
            The item table.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom menu button
        function MODULE:OnCreateItemInteractionMenu(panel, menu, itemTable)
            menu:AddOption("Custom Action", function()
                print("Custom action clicked")
            end)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add conditional menu options
        function MODULE:OnCreateItemInteractionMenu(panel, menu, itemTable)
            -- Add custom option for specific items
            if itemTable.uniqueID == "custom_item" then
                menu:AddOption("Special Action", function()
                    LocalPlayer():notify("Special action performed!")
                end)
            end

            -- Add option based on item data
            if itemTable.data and itemTable.data.customData then
                menu:AddOption("View Custom Data", function()
                    print("Custom data: " .. tostring(itemTable.data.customData))
                end)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced menu customization with validation and integration
        function MODULE:OnCreateItemInteractionMenu(panel, menu, itemTable)
            if not panel or not menu or not itemTable then return end

            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return end

            -- Add custom options based on item type
            if itemTable.category == "weapon" then
                menu:AddOption("Inspect Weapon", function()
                    hook.Run("OpenItemInspection", itemTable)
                end):SetImage("icon16/eye.png")
            end

            -- Add admin-only options
            if client:IsAdmin() then
                menu:AddSpacer()
                menu:AddOption("Admin: Edit Item", function()
                    hook.Run("OpenItemEditor", itemTable)
                end):SetImage("icon16/wrench.png")
            end

            -- Add faction-specific options
            local faction = char:getFaction()
            if faction and faction.uniqueID == "police" and itemTable.category == "evidence" then
                menu:AddOption("Tag as Evidence", function()
                    hook.Run("TagItemEvidence", itemTable)
                end):SetImage("icon16/tag_blue.png")
            end

            -- Add options based on item data
            if itemTable.data and itemTable.data.customOptions then
                for _, option in ipairs(itemTable.data.customOptions) do
                    menu:AddOption(option.name, option.callback)
                end
            end
        end
        ```
]]
function OnCreateItemInteractionMenu(panel, menu, itemTable)
end

--[[
    Purpose:
        Called when creating a storage panel.

    When Called:
        When storage UI panels are created.

    Parameters:
        localInvPanel (Panel)
            The local inventory panel.
        storageInvPanel (Panel)
            The storage inventory panel.
        storage (table)
            The storage data.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Customize storage panel appearance
        function MODULE:OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
            storageInvPanel:SetBackgroundColor(Color(50, 50, 50))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom buttons to storage panel
        function MODULE:OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
            local button = vgui.Create("DButton", storageInvPanel)
            button:SetText("Sort")
            button:SetPos(10, 10)
            button:SetSize(100, 30)
            button.DoClick = function()
                -- Sort items logic
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced storage panel customization with validation
        function MODULE:OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
            if not IsValid(localInvPanel) or not IsValid(storageInvPanel) then return end

            -- Customize panel appearance
            storageInvPanel:SetBackgroundColor(Color(40, 40, 50))
            storageInvPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 200))
            end

            -- Add custom header
            local header = vgui.Create("DPanel", storageInvPanel)
            header:SetPos(0, 0)
            header:SetSize(storageInvPanel:GetWide(), 40)
            header.Paint = function(self, w, h)
                draw.SimpleText(storage.name or "Storage", "LiliaFont.36", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Add sort button
            local sortBtn = vgui.Create("DButton", storageInvPanel)
            sortBtn:SetText("Sort Items")
            sortBtn:SetPos(10, 50)
            sortBtn:SetSize(100, 30)
            sortBtn.DoClick = function()
                hook.Run("SortInventory", storageInvPanel)
            end

            -- Add search box
            local searchBox = vgui.Create("DTextEntry", storageInvPanel)
            searchBox:SetPos(120, 50)
            searchBox:SetSize(200, 30)
            searchBox:SetPlaceholderText("Search items...")
            searchBox.OnTextChanged = function(self)
                hook.Run("FilterInventory", storageInvPanel, self:GetValue())
            end
        end
        ```
]]
function OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
end

--[[
    Purpose:
        Called when a death sound is played.

    When Called:
        After a death sound is played for feedback.

    Parameters:
        client (Player)
            The player who died.
        deathSound (string)
            The death sound played.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log death sound
        function MODULE:OnDeathSoundPlayed(client, deathSound)
            print(client:Name() .. " death sound: " .. deathSound)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track death sounds
        function MODULE:OnDeathSoundPlayed(client, deathSound)
            if IsValid(client) and client == LocalPlayer() then
                -- Play additional effect
                surface.PlaySound("buttons/button15.wav")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced death sound system with effects
        function MODULE:OnDeathSoundPlayed(client, deathSound)
            if not IsValid(client) then return end

            -- Custom death effects for local player
            if client == LocalPlayer() then
                -- Screen shake
                local shake = math.random(5, 10)
                util.ScreenShake(Vector(0, 0, 0), shake, shake, 0.5, 0)

                -- Color overlay
                hook.Add("RenderScreenspaceEffects", "DeathEffect", function()
                    DrawColorModify({
                        ["$pp_colour_addr"] = 0.1,
                        ["$pp_colour_addg"] = 0,
                        ["$pp_colour_addb"] = 0,
                        ["$pp_colour_mulr"] = 0.8,
                        ["$pp_colour_mulg"] = 0.8,
                        ["$pp_colour_mulb"] = 0.8
                    })
                end)

                -- Remove effect after delay
                timer.Simple(2, function()
                    hook.Remove("RenderScreenspaceEffects", "DeathEffect")
                end)
            end

            -- Track death statistics
            local char = client:getChar()
            if char then
                local deathStats = char:getData("deathStats", {})
                deathStats.total = (deathStats.total or 0) + 1
                deathStats.lastSound = deathSound
                deathStats.lastDeath = os.time()
                char:setData("deathStats", deathStats)
            end
        end
        ```
]]
function OnDeathSoundPlayed(client, deathSound)
end

--[[
    Purpose:
        Called when opening a vendor menu.

    When Called:
        When a vendor interface is opened.

    Parameters:
        panel (Panel)
            The vendor panel.
        vendor (Entity)
            The vendor entity.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Customize vendor panel
        function MODULE:OnOpenVendorMenu(panel, vendor)
            panel:SetBackgroundColor(Color(60, 60, 70))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add vendor info
        function MODULE:OnOpenVendorMenu(panel, vendor)
            if IsValid(vendor) then
                local vendorData = vendor:getNetVar("vendorData")
                if vendorData then
                    -- Display vendor name
                    local label = vgui.Create("DLabel", panel)
                    label:SetText(vendorData.name or "Vendor")
                    label:SetPos(10, 10)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced vendor menu with customization
        function MODULE:OnOpenVendorMenu(panel, vendor)
            if not IsValid(panel) or not IsValid(vendor) then return end

            -- Get vendor data
            local vendorData = vendor:getNetVar("vendorData")
            if not vendorData then return end

            -- Customize panel
            panel:SetBackgroundColor(Color(50, 50, 60))
            panel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50, 240))
            end

            -- Add vendor header
            local header = vgui.Create("DPanel", panel)
            header:SetPos(0, 0)
            header:SetSize(panel:GetWide(), 50)
            header.Paint = function(self, w, h)
                draw.SimpleText(vendorData.name or "Vendor", "LiliaFont.36", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Add vendor info panel
            if vendorData.description then
                local infoPanel = vgui.Create("DPanel", panel)
                infoPanel:SetPos(10, 60)
                infoPanel:SetSize(panel:GetWide() - 20, 60)
                infoPanel.Paint = function(self, w, h)
                    draw.SimpleText(vendorData.description, "LiliaFont.25", 5, 5, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end

            -- Add custom buttons
            if vendorData.customButtons then
                for i, buttonData in ipairs(vendorData.customButtons) do
                    local btn = vgui.Create("DButton", panel)
                    btn:SetText(buttonData.text)
                    btn:SetPos(10, 130 + (i * 35))
                    btn:SetSize(200, 30)
                    btn.DoClick = function()
                        if buttonData.command then
                            LocalPlayer():ConCommand(buttonData.command)
                        end
                    end
                end
            end
        end
        ```
]]
function OnOpenVendorMenu(panel, vendor)
end

--[[
    Purpose:
        Called when a pain sound is played.

    When Called:
        After a pain sound is played for feedback.

    Parameters:
        client (Player)
            The player who was hurt.
        painSound (string)
            The pain sound played.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log pain sound
        function MODULE:OnPainSoundPlayed(client, painSound)
            if client == LocalPlayer() then
                print("Pain sound: " .. painSound)
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add visual feedback
        function MODULE:OnPainSoundPlayed(client, painSound)
            if IsValid(client) and client == LocalPlayer() then
                -- Flash screen red
                hook.Add("HUDPaint", "PainFlash", function()
                    surface.SetDrawColor(255, 0, 0, 100)
                    surface.DrawRect(0, 0, ScrW(), ScrH())
                end)
                timer.Simple(0.2, function()
                    hook.Remove("HUDPaint", "PainFlash")
                end)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced pain system with effects and tracking
        function MODULE:OnPainSoundPlayed(client, painSound)
            if not IsValid(client) then return end

            -- Local player effects
            if client == LocalPlayer() then
                -- Screen flash
                local flash = math.random(80, 120)
                hook.Add("HUDPaint", "PainFlash", function()
                    surface.SetDrawColor(255, 0, 0, flash)
                    surface.DrawRect(0, 0, ScrW(), ScrH())
                end)
                timer.Simple(0.3, function()
                    hook.Remove("HUDPaint", "PainFlash")
                end)

                -- Screen shake
                local shake = math.random(2, 5)
                util.ScreenShake(Vector(0, 0, 0), shake, shake, 0.3, 0)

                -- Blood particles
                local effectData = EffectData()
                effectData:SetOrigin(LocalPlayer():GetPos())
                util.Effect("bloodimpact", effectData)
            end

            -- Track pain statistics
            local char = client:getChar()
            if char then
                local painStats = char:getData("painStats", {})
                painStats.total = (painStats.total or 0) + 1
                painStats.lastSound = painSound
                painStats.lastPain = os.time()
                char:setData("painStats", painStats)
            end
        end
        ```
]]
function OnPainSoundPlayed(client, painSound)
end

--[[
    Purpose:
        Called when requesting item transfer in UI.

    When Called:
        When item transfers are requested through the UI.

    Parameters:
        panel (Panel)
            The UI panel.
        itemID (number)
            The item ID.
        inventoryID (number)
            The destination inventory ID.
        x (number)
            The X position.
        y (number)
            The Y position.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log transfer request
        function MODULE:OnRequestItemTransfer(panel, itemID, inventoryID, x, y)
            print("Transfer requested: Item " .. itemID .. " to inventory " .. inventoryID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate transfer
        function MODULE:OnRequestItemTransfer(panel, itemID, inventoryID, x, y)
            local item = lia.item.instances[itemID]
            if item then
                -- Check if item can be transferred
                if item:getData("restricted", false) then
                    LocalPlayer():notify("This item cannot be transferred.")
                    return false
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer system with validation and tracking
        function MODULE:OnRequestItemTransfer(panel, itemID, inventoryID, x, y)
            if not itemID or not inventoryID then return end

            local item = lia.item.instances[itemID]
            if not item then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Validate transfer
            if item:getData("restricted", false) then
                client:notify("This item cannot be transferred.")
                return false
            end

            -- Check cooldown
            local lastTransfer = item:getData("lastTransfer", 0)
            local cooldown = item:getData("transferCooldown", 0)
            if cooldown > 0 and (os.time() - lastTransfer) < cooldown then
                local remaining = cooldown - (os.time() - lastTransfer)
                client:notify("Transfer cooldown: " .. remaining .. " seconds")
                return false
            end

            -- Validate position
            if x < 0 or y < 0 then
                client:notify("Invalid transfer position.")
                return false
            end

            -- Track transfer request
            local char = client:getChar()
            if char then
                local transferStats = char:getData("transferStats", {})
                transferStats.total = (transferStats.total or 0) + 1
                transferStats.lastTransfer = os.time()
                char:setData("transferStats", transferStats)
            end

            -- Log transfer
            lia.log.add(string.format("%s (%s) requested transfer of item %d to inventory %d",
                client:Name(),
                client:SteamID(),
                itemID,
                inventoryID),
                FLAG_NORMAL)
        end
        ```
]]
function OnRequestItemTransfer(panel, itemID, inventoryID, x, y)
end

--[[
    Purpose:
        Called when theme is changed.

    When Called:
        When UI themes are switched.

    Parameters:
        themeName (string)
            The new theme name.
        useTransition (boolean)
            Whether to use transition effects.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log theme change
        function MODULE:OnThemeChanged(themeName, useTransition)
            print("Theme changed to: " .. themeName)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply theme settings
        function MODULE:OnThemeChanged(themeName, useTransition)
            if themeName == "dark" then
                lia.config.set("themeColor", Color(30, 30, 30))
            elseif themeName == "light" then
                lia.config.set("themeColor", Color(240, 240, 240))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced theme system with transitions and persistence
        function MODULE:OnThemeChanged(themeName, useTransition)
            if not themeName then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Store theme preference
            local char = client:getChar()
            if char then
                char:setData("preferredTheme", themeName)
                char:save()
            end

            -- Apply theme with transition
            if useTransition then
                -- Fade out current UI
                hook.Add("HUDPaint", "ThemeTransition", function()
                    local alpha = 0
                    timer.Simple(0.5, function()
                        -- Apply new theme
                        lia.theme.set(themeName)

                        -- Fade in new UI
                        timer.Simple(0.5, function()
                            hook.Remove("HUDPaint", "ThemeTransition")
                        end)
                    end)
                end)
            else
                -- Immediate theme change
                lia.theme.set(themeName)
            end

            -- Update all panels
            for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
                if IsValid(panel) and panel.OnThemeChanged then
                    panel:OnThemeChanged(themeName)
                end
            end

            -- Log theme change
            lia.log.add(string.format("%s (%s) changed theme to %s",
                client:Name(),
                client:SteamID(),
                themeName),
                FLAG_NORMAL)
        end
        ```
]]
function OnThemeChanged(themeName, useTransition)
end

--[[
    Purpose:
        Called when online staff data is received.

    When Called:
        When staff status information is received.

    Parameters:
        staffData (table)
            The staff data.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Display staff data
        function MODULE:OnlineStaffDataReceived(staffData)
            print("Staff online: " .. table.Count(staffData))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update staff list UI
        function MODULE:OnlineStaffDataReceived(staffData)
            if IsValid(lia.gui.staffList) then
                lia.gui.staffList:UpdateStaff(staffData)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced staff tracking with UI updates
        function MODULE:OnlineStaffDataReceived(staffData)
            if not staffData then return end

            -- Store staff data
            MODULE.staffData = staffData

            -- Update staff list panel
            if IsValid(lia.gui.staffList) then
                lia.gui.staffList:Clear()

                for steamID, data in pairs(staffData) do
                    local row = lia.gui.staffList:Add("DButton")
                    row:SetText(data.name .. " - " .. data.rank)
                    row:SetTall(30)
                    row.DoClick = function()
                        -- Open staff menu
                        hook.Run("OpenStaffMenu", steamID, data)
                    end
                end
            end

            -- Update staff count display
            local staffCount = table.Count(staffData)
            if IsValid(lia.gui.staffCount) then
                lia.gui.staffCount:SetText("Staff Online: " .. staffCount)
            end

            -- Notify if new staff joined
            if MODULE.lastStaffCount and staffCount > MODULE.lastStaffCount then
                LocalPlayer():notify("A staff member has joined the server.")
            end

            MODULE.lastStaffCount = staffCount
        end
        ```
]]
function OnlineStaffDataReceived(staffData)
end

--[[
    Purpose:
        Called to open admin stick UI.

    When Called:
        When admin tools UI needs to be opened.

    Parameters:
        target (Player)
            The target player.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Open admin UI
        function MODULE:OpenAdminStickUI(target)
            if IsValid(target) then
                print("Opening admin UI for: " .. target:Name())
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize admin UI
        function MODULE:OpenAdminStickUI(target)
            if IsValid(target) then
                local panel = vgui.Create("liaAdminStick")
                panel:SetTarget(target)
                panel:MakePopup()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced admin UI with validation and customization
        function MODULE:OpenAdminStickUI(target)
            if not IsValid(target) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Check permissions
            if not client:IsAdmin() then
                client:notify("You don't have permission to use admin tools.")
                return
            end

            -- Close existing admin UI
            if IsValid(lia.gui.adminStick) then
                lia.gui.adminStick:Remove()
            end

            -- Create admin stick panel
            local panel = vgui.Create("liaAdminStick")
            panel:SetTarget(target)
            panel:SetPos(ScrW()/2 - 300, ScrH()/2 - 200)
            panel:SetSize(600, 400)
            panel:MakePopup()

            -- Store reference
            lia.gui.adminStick = panel

            -- Log admin UI open
            lia.log.add(string.format("%s (%s) opened admin stick for %s (%s)",
                client:Name(),
                client:SteamID(),
                target:Name(),
                target:SteamID()),
                FLAG_NORMAL)
        end
        ```
]]
function OpenAdminStickUI(target)
end

--[[
    Purpose:
        Called when an option is received from server.

    When Called:
        When client receives option values.

    Parameters:
        client (Player)
            The receiving player.
        key (string)
            The option key.
        value (any)
            The option value.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log option received
        function MODULE:OptionReceived(client, key, value)
            print("Option received: " .. key .. " = " .. tostring(value))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply option value
        function MODULE:OptionReceived(client, key, value)
            if client == LocalPlayer() then
                lia.config.set(key, value)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced option system with validation and UI updates
        function MODULE:OptionReceived(client, key, value)
            if not IsValid(client) or client ~= LocalPlayer() then return end
            if not key then return end

            -- Validate option
            local option = lia.config.getOption(key)
            if not option then
                lia.log.add(string.format("Received invalid option: %s", key), FLAG_WARNING)
                return
            end

            -- Validate value type
            if type(value) ~= option.dataType then
                lia.log.add(string.format("Invalid value type for option %s: expected %s, got %s",
                    key,
                    option.dataType,
                    type(value)),
                    FLAG_WARNING)
                return
            end

            -- Apply option
            lia.config.set(key, value)

            -- Update UI if option panel is open
            if IsValid(lia.gui.optionPanel) then
                lia.gui.optionPanel:UpdateOption(key, value)
            end

            -- Trigger option change hook
            hook.Run("OptionChanged", key, value)

            -- Save to client settings
            file.Write("lilia_client_options.txt", util.TableToJSON(lia.config.client))
        end
        ```
]]
function OptionReceived(client, key, value)
end

--[[
    Purpose:
        Called to paint items in UI.

    When Called:
        When item UI elements need to be rendered.

    Parameters:
        item (Item)
            The item to paint.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Paint item with default style
        function MODULE:PaintItem(item)
            draw.SimpleText(item.name, "LiliaFont.25", 10, 10, color_white)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Custom item painting
        function MODULE:PaintItem(item)
            if item:getData("rare", false) then
                draw.RoundedBox(4, 0, 0, 100, 100, Color(255, 215, 0, 100))
            end

            draw.SimpleText(item.name, "LiliaFont.25", 10, 10, color_white)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced item painting with effects
        function MODULE:PaintItem(item)
            if not item then return end

            local w, h = 100, 100
            local x, y = 0, 0

            -- Paint background based on rarity
            local rarity = item:getData("rarity", "common")
            local rarityColors = {
                common = Color(150, 150, 150),
                uncommon = Color(0, 255, 0),
                rare = Color(0, 100, 255),
                epic = Color(150, 0, 255),
                legendary = Color(255, 215, 0)
            }

            draw.RoundedBox(4, x, y, w, h, rarityColors[rarity] or rarityColors.common)

            -- Paint item icon
            if item.icon then
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(item.icon)
                surface.DrawTexturedRect(x + 10, y + 10, w - 20, h - 40)
            end

            -- Paint item name
            draw.SimpleText(item.name, "LiliaFont.25", x + w/2, y + h - 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Paint quantity if stackable
            if item.isStackable and item:getData("quantity", 1) > 1 then
                draw.SimpleText("x" .. item:getData("quantity", 1), "LiliaFont.17", x + w - 10, y + 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end

            -- Paint glow effect for rare items
            if rarity == "legendary" then
                local time = CurTime() * 2
                local alpha = math.sin(time) * 50 + 100
                draw.RoundedBox(4, x, y, w, h, Color(255, 215, 0, alpha))
            end
        end
        ```
]]
function PaintItem(item)
end

--[[
    Purpose:
        Called to populate admin stick UI.

    When Called:
        When admin stick menus need to be populated.

    Parameters:
        currentMenu (Panel)
            The current menu.
        currentTarget (Player)
            The target player.
        currentStores (table)
            The current stores.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom button
        function MODULE:PopulateAdminStick(currentMenu, currentTarget, currentStores)
            local btn = vgui.Create("DButton", currentMenu)
            btn:SetText("Custom Action")
            btn:SetSize(100, 30)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom admin actions
        function MODULE:PopulateAdminStick(currentMenu, currentTarget, currentStores)
            if IsValid(currentTarget) then
                local btn = vgui.Create("DButton", currentMenu)
                btn:SetText("Teleport To")
                btn:SetSize(150, 30)
                btn.DoClick = function()
                    LocalPlayer():SetPos(currentTarget:GetPos())
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced admin stick with multiple actions
        function MODULE:PopulateAdminStick(currentMenu, currentTarget, currentStores)
            if not IsValid(currentMenu) or not IsValid(currentTarget) then return end

            local client = LocalPlayer()
            if not IsValid(client) or not client:IsAdmin() then return end

            -- Get target character
            local targetChar = currentTarget:getChar()
            if not targetChar then return end

            -- Add custom admin actions
            local actions = {
                {
                    name = "Teleport To",
                    icon = "icon16/arrow_right.png",
                    action = function()
                        client:SetPos(currentTarget:GetPos())
                    end
                },
                {
                    name = "Teleport Here",
                    icon = "icon16/arrow_left.png",
                    action = function()
                        currentTarget:SetPos(client:GetPos())
                    end
                },
                {
                    name = "View Inventory",
                    icon = "icon16/box.png",
                    action = function()
                        hook.Run("ViewPlayerInventory", currentTarget)
                    end
                }
            }

            for i, actionData in ipairs(actions) do
                local btn = vgui.Create("DButton", currentMenu)
                btn:SetText(actionData.name)
                btn:SetImage(actionData.icon)
                btn:SetPos(10, 50 + (i * 35))
                btn:SetSize(200, 30)
                btn.DoClick = actionData.action
            end

            -- Add target info panel
            local infoPanel = vgui.Create("DPanel", currentMenu)
            infoPanel:SetPos(10, 200)
            infoPanel:SetSize(200, 100)
            infoPanel.Paint = function(self, w, h)
                draw.SimpleText("Target: " .. targetChar:getName(), "LiliaFont.25", 5, 5, color_white)
                draw.SimpleText("Health: " .. currentTarget:Health(), "LiliaFont.17", 5, 25, color_white)
                draw.SimpleText("Armor: " .. currentTarget:Armor(), "LiliaFont.17", 5, 40, color_white)
            end
        end
        ```
]]
function PopulateAdminStick(currentMenu, currentTarget, currentStores)
end

--[[
    Purpose:
        Called to populate admin tabs.

    When Called:
        When admin UI tabs need to be populated.

    Parameters:
        adminPages (table)
            The admin pages.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom tab
        function MODULE:PopulateAdminTabs(adminPages)
            table.insert(adminPages, {name = "Custom", icon = "icon16/star.png"})
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom admin pages
        function MODULE:PopulateAdminTabs(adminPages)
            table.insert(adminPages, {
                name = "Custom Tools",
                icon = "icon16/wrench.png",
                func = function(panel)
                    panel:Add("DLabel"):SetText("Custom Admin Tools")
                end
            })
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced admin tabs with permissions
        function MODULE:PopulateAdminTabs(adminPages)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Add custom admin tabs
            local customTabs = {
                {
                    name = "Custom Tools",
                    icon = "icon16/wrench.png",
                    permission = "customtools",
                    func = function(panel)
                        local label = panel:Add("DLabel")
                        label:SetText("Custom Admin Tools")
                        label:SetFont("LiliaFont.36")

                        local btn = panel:Add("DButton")
                        btn:SetText("Custom Action")
                        btn:SetSize(200, 30)
                        btn.DoClick = function()
                            client:notify("Custom action executed!")
                        end
                    end
                },
                {
                    name = "Statistics",
                    icon = "icon16/chart_line.png",
                    permission = "statistics",
                    func = function(panel)
                        -- Display server statistics
                        local stats = hook.Run("GetServerStats")
                        if stats then
                            for key, value in pairs(stats) do
                                local label = panel:Add("DLabel")
                                label:SetText(key .. ": " .. tostring(value))
                            end
                        end
                    end
                }
            }

            for _, tabData in ipairs(customTabs) do
                -- Check permissions
                if client:HasPrivilege(tabData.permission) then
                    table.insert(adminPages, tabData)
                end
            end
        end
        ```
]]
function PopulateAdminTabs(adminPages)
end

--[[
    Purpose:
        Called to populate configuration buttons.

    When Called:
        When configuration UI buttons need to be populated.

    Parameters:
        pages (table)
            The pages table.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom config button
        function MODULE:PopulateConfigurationButtons(pages)
            table.insert(pages, {name = "Custom", button = "CustomConfig"})
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add multiple config buttons
        function MODULE:PopulateConfigurationButtons(pages)
            table.insert(pages, {
                name = "Custom Settings",
                button = "CustomConfig",
                icon = "icon16/cog.png"
            })
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced configuration system with categories
        function MODULE:PopulateConfigurationButtons(pages)
            -- Add custom configuration pages
            local customPages = {
                {
                    name = "Custom Settings",
                    button = "CustomConfig",
                    icon = "icon16/cog.png",
                    category = "general",
                    func = function(panel)
                        -- Add custom settings controls
                        local checkbox = panel:Add("DCheckBoxLabel")
                        checkbox:SetText("Enable Custom Feature")
                        checkbox:SetValue(lia.config.get("customFeature", false))
                        checkbox.OnChange = function(self, val)
                            lia.config.set("customFeature", val)
                        end
                    end
                },
                {
                    name = "Advanced Settings",
                    button = "AdvancedConfig",
                    icon = "icon16/wrench.png",
                    category = "advanced",
                    permission = "advancedconfig",
                    func = function(panel)
                        -- Add advanced settings
                        local slider = panel:Add("DNumSlider")
                        slider:SetText("Custom Value")
                        slider:SetMin(0)
                        slider:SetMax(100)
                        slider:SetValue(lia.config.get("customValue", 50))
                        slider.OnValueChanged = function(self, val)
                            lia.config.set("customValue", val)
                        end
                    end
                }
            }

            for _, pageData in ipairs(customPages) do
                -- Check permissions if required
                if not pageData.permission or LocalPlayer():HasPrivilege(pageData.permission) then
                    table.insert(pages, pageData)
                end
            end
        end
        ```
]]
function PopulateConfigurationButtons(pages)
end

--[[
    Purpose:
        Called to populate inventory items.

    When Called:
        When inventory UI items need to be populated.

    Parameters:
        pnlContent (Panel)
            The content panel.
        tree (Panel)
            The tree panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add custom inventory filter
        function MODULE:PopulateInventoryItems(pnlContent, tree)
            local filterBtn = vgui.Create("DButton", pnlContent)
            filterBtn:SetText("Filter")
            filterBtn:SetSize(100, 30)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add sorting options
        function MODULE:PopulateInventoryItems(pnlContent, tree)
            local sortBtn = vgui.Create("DButton", pnlContent)
            sortBtn:SetText("Sort Items")
            sortBtn:SetSize(100, 30)
            sortBtn.DoClick = function()
                hook.Run("SortInventoryItems", pnlContent)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory UI with filters and search
        function MODULE:PopulateInventoryItems(pnlContent, tree)
            if not IsValid(pnlContent) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            local inv = char:getInv()
            if not inv then return end

            -- Add search box
            local searchBox = vgui.Create("DTextEntry", pnlContent)
            searchBox:SetPos(10, 10)
            searchBox:SetSize(200, 30)
            searchBox:SetPlaceholderText("Search items...")
            searchBox.OnTextChanged = function(self)
                local searchText = string.lower(self:GetValue())
                hook.Run("FilterInventoryItems", pnlContent, searchText)
            end

            -- Add sort button
            local sortBtn = vgui.Create("DButton", pnlContent)
            sortBtn:SetText("Sort")
            sortBtn:SetPos(220, 10)
            sortBtn:SetSize(80, 30)
            sortBtn.DoClick = function()
                hook.Run("SortInventoryItems", pnlContent, "name")
            end

            -- Add filter dropdown
            local filterCombo = vgui.Create("DComboBox", pnlContent)
            filterCombo:SetPos(310, 10)
            filterCombo:SetSize(150, 30)
            filterCombo:SetValue("All Items")
            filterCombo:AddChoice("All Items")
            filterCombo:AddChoice("Weapons")
            filterCombo:AddChoice("Items")
            filterCombo:AddChoice("Consumables")
            filterCombo.OnSelect = function(self, index, value)
                hook.Run("FilterInventoryByType", pnlContent, value)
            end

            -- Add item count display
            local countLabel = vgui.Create("DLabel", pnlContent)
            countLabel:SetPos(470, 10)
            countLabel:SetSize(100, 30)
            countLabel:SetText("Items: " .. table.Count(inv:getItems()))
        end
        ```
]]
function PopulateInventoryItems(pnlContent, tree)
end

--[[
    Purpose:
        Called after drawing inventory UI.

    When Called:
        After inventory panels are drawn.

    Parameters:
        mainPanel (Panel)
            The main inventory panel.
        parentPanel (Panel)
            The parent panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add overlay after inventory draw
        function MODULE:PostDrawInventory(mainPanel, parentPanel)
            draw.SimpleText("Inventory", "LiliaFont.36", 10, 10, color_white)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom decorations
        function MODULE:PostDrawInventory(mainPanel, parentPanel)
            if IsValid(mainPanel) then
                local w, h = mainPanel:GetSize()
                draw.RoundedBox(4, w - 100, 10, 90, 30, Color(50, 50, 50, 200))
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced inventory overlay with stats
        function MODULE:PostDrawInventory(mainPanel, parentPanel)
            if not IsValid(mainPanel) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            local inv = char:getInv()
            if not inv then return end

            local w, h = mainPanel:GetSize()

            -- Draw inventory stats overlay
            local statsPanel = vgui.Create("DPanel", mainPanel)
            statsPanel:SetPos(w - 200, 10)
            statsPanel:SetSize(190, 100)
            statsPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 240))

                local items = inv:getItems()
                draw.SimpleText("Items: " .. table.Count(items), "LiliaFont.25", 5, 5, color_white)

                local weight = 0
                for _, item in pairs(items) do
                    weight = weight + (item.weight or 0) * (item:getData("quantity", 1) or 1)
                end
                draw.SimpleText("Weight: " .. weight .. "kg", "LiliaFont.25", 5, 25, color_white)

                local maxWeight = inv:getData("maxWeight", 100)
                local weightPercent = (weight / maxWeight) * 100
                draw.SimpleText("Capacity: " .. math.Round(weightPercent) .. "%", "LiliaFont.25", 5, 45, color_white)

                -- Draw weight bar
                local barWidth = w - 10
                local barHeight = 10
                local barX = 5
                local barY = 70

                draw.RoundedBox(2, barX, barY, barWidth, barHeight, Color(50, 50, 50))
                draw.RoundedBox(2, barX, barY, barWidth * (weightPercent / 100), barHeight, Color(0, 255, 0))
            end
        end
        ```
]]
function PostDrawInventory(mainPanel, parentPanel)
end

--[[
    Purpose:
        Called after fonts are loaded.

    When Called:
        After font loading is complete.

    Parameters:
        mainFont (string)
            The main font.
        configuredFont (string)
            The configured font.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log font loading
        function MODULE:PostLoadFonts(mainFont, configuredFont)
            print("Fonts loaded: " .. mainFont .. ", " .. configuredFont)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create custom fonts
        function MODULE:PostLoadFonts(mainFont, configuredFont)
            -- liaCustomFont replaced with LiliaFont.24
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced font system with fallbacks
        function MODULE:PostLoadFonts(mainFont, configuredFont)
            local fontToUse = configuredFont or mainFont or "Arial"

            -- Create font family with multiple sizes
            local fontSizes = {12, 16, 20, 24, 32, 48, 64}
            for _, size in ipairs(fontSizes) do
                surface.CreateFont("liaFont" .. size, {
                    font = fontToUse,
                    size = size,
                    weight = 500,
                    antialias = true,
                    extended = true
                })

                surface.CreateFont("liaFont" .. size .. "Bold", {
                    font = fontToUse,
                    size = size,
                    weight = 700,
                    antialias = true,
                    extended = true
                })
            end

            -- Create icon font
            -- liaIconFont replaced with LiliaFont.16

            -- Validate fonts
            for _, size in ipairs(fontSizes) do
                if not surface.GetFontID("liaFont" .. size) then
                    lia.log.add(string.format("Failed to create font: liaFont%d", size), FLAG_WARNING)
                end
            end

            -- Log font loading
            lia.log.add(string.format("Fonts loaded successfully: %s (config: %s)",
                mainFont,
                configuredFont),
                FLAG_NORMAL)
        end
        ```
]]
function PostLoadFonts(mainFont, configuredFont)
end

--[[
    Purpose:
        Called when physgun beam is about to be drawn.

    When Called:
        Before physgun beam rendering.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic physgun beam modification
        function MODULE:PreDrawPhysgunBeam()
            -- Custom beam color
            render.SetColorModulation(1, 0, 0) -- Red beam
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Modify beam with player data
        function MODULE:PreDrawPhysgunBeam()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if char then
                -- Get character-specific beam color
                local beamColor = char:getData("physgunBeamColor", Color(255, 255, 255))
                render.SetColorModulation(beamColor.r / 255, beamColor.g / 255, beamColor.b / 255)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced physgun beam modification with effects
        function MODULE:PreDrawPhysgunBeam()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Get beam color from character data
            local beamColor = char:getData("physgunBeamColor", Color(255, 255, 255))
            render.SetColorModulation(beamColor.r / 255, beamColor.g / 255, beamColor.b / 255)

            -- Apply beam width modification
            local beamWidth = char:getData("physgunBeamWidth", 1)
            if beamWidth ~= 1 then
                render.SetBlend(beamWidth)
            end

            -- Add trail effects
            if char:getData("physgunTrail", false) then
                local tr = util.TraceLine({
                    start = client:GetShootPos(),
                    endpos = client:GetShootPos() + client:GetAimVector() * 10000,
                    filter = client
                })

                if tr.Hit then
                    local effectData = EffectData()
                    effectData:SetOrigin(tr.HitPos)
                    effectData:SetNormal(tr.HitNormal)
                    effectData:SetColor(beamColor.r, beamColor.g, beamColor.b)
                    util.Effect("physgun_trail", effectData)
                end
            end
        end
        ```
]]
function PreDrawPhysgunBeam()
end

--[[
    Purpose:
        Called to refresh fonts.

    When Called:
        When font system needs refreshing.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Refresh fonts
        function MODULE:RefreshFonts()
            surface.SetFont("LiliaFont.16")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Rebuild font cache
        function MODULE:RefreshFonts()
            -- Force font recreation
            hook.Run("CreateFonts")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced font management with fallbacks
        function MODULE:RefreshFonts()
            local fontSizes = {12, 14, 16, 18, 20, 24, 32, 48}
            local fontFamilies = {"LiliaFont.16", "LiliaFont.25", "LiliaFont.36"}

            -- Recreate all fonts with current configuration
            for _, family in ipairs(fontFamilies) do
                for _, size in ipairs(fontSizes) do
                    local fontName = family .. size

                    -- Check if font exists, recreate if needed
                    if not surface.GetFontID(fontName) then
                        surface.CreateFont(fontName, {
                            font = lia.config.get("fontFamily", "Arial"),
                            size = size,
                            weight = family:find("Bold") and 700 or 500,
                            antialias = true,
                            extended = true
                        })

                        lia.log.add("Recreated font: " .. fontName, FLAG_NORMAL)
                    end
                end
            end

            -- Update UI elements that use these fonts
            hook.Run("FontsRefreshed")
        end
        ```
]]
function RefreshFonts()
end

--[[
    Purpose:
        Called to remove PAC parts.

    When Called:
        When PAC parts are removed from players.

    Parameters:
        client (Player)
            The player removing the part.
        partID (string)
            The PAC part ID.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log part removal
        function MODULE:RemovePart(client, partID)
            print(client:Name() .. " removed PAC part: " .. partID)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Track part removals
        function MODULE:RemovePart(client, partID)
            if IsValid(client) then
                local char = client:getChar()
                if char then
                    local removedParts = char:getData("removedParts", {})
                    removedParts[partID] = os.time()
                    char:setData("removedParts", removedParts)
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced PAC part management with validation
        function MODULE:RemovePart(client, partID)
            if not IsValid(client) or not partID then return end

            local char = client:getChar()
            if not char then return end

            -- Check if part exists
            local pacData = char:getData("pacData", {})
            if not pacData.parts or not pacData.parts[partID] then
                client:notify("PAC part not found: " .. partID)
                return
            end

            -- Log part removal
            lia.log.add(string.format("%s (%s) removed PAC part: %s",
                client:Name(),
                client:SteamID(),
                partID),
                FLAG_NORMAL)

            -- Remove part data
            pacData.parts[partID] = nil
            char:setData("pacData", pacData)

            -- Track removal history
            local removalHistory = char:getData("pacRemovalHistory", {})
            table.insert(removalHistory, {
                partID = partID,
                removedAt = os.time(),
                removedBy = client:SteamID()
            })

            -- Keep only last 50 removals
            if #removalHistory > 50 then
                table.remove(removalHistory, 1)
            end

            char:setData("pacRemovalHistory", removalHistory)

            -- Notify other modules
            hook.Run("PACPartRemoved", client, partID)
        end
        ```
]]
function RemovePart(client, partID)
end

--[[
    Purpose:
        Called to reset character panel.

    When Called:
        When character selection UI needs resetting.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Clear panel
        function MODULE:ResetCharacterPanel()
            if IsValid(lia.gui.charCreate) then
                lia.gui.charCreate:Clear()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Reset to default state
        function MODULE:ResetCharacterPanel()
            if IsValid(lia.gui.charCreate) then
                -- Reset all controls to default values
                hook.Run("ResetCharacterCreation")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive panel reset with validation
        function MODULE:ResetCharacterPanel()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Close character creation panel
            if IsValid(lia.gui.charCreate) then
                lia.gui.charCreate:Remove()
                lia.gui.charCreate = nil
            end

            -- Reset character creation data
            MODULE.charCreationData = {
                name = "",
                description = "",
                model = "models/player.mdl",
                faction = nil,
                class = nil,
                attributes = {},
                customData = {}
            }

            -- Reset any active character preview
            if MODULE.previewModel then
                MODULE.previewModel:Remove()
                MODULE.previewModel = nil
            end

            -- Clear any cached character data
            MODULE.cachedCharacters = nil

            -- Reset UI state
            MODULE.creationStep = 1
            MODULE.selectedFaction = nil
            MODULE.selectedClass = nil

            -- Notify modules
            hook.Run("CharacterPanelReset")

            -- Log reset
            lia.log.add(client:Name() .. " reset character creation panel", FLAG_NORMAL)
        end
        ```
]]
function ResetCharacterPanel()
end

--[[
    Purpose:
        Called when scoreboard is closed.

    When Called:
        When scoreboard UI is closed.

    Parameters:
        panel (Panel)
            The scoreboard panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log scoreboard close
        function MODULE:ScoreboardClosed(panel)
            print("Scoreboard closed")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up scoreboard data
        function MODULE:ScoreboardClosed(panel)
            -- Clear any cached player data
            MODULE.cachedPlayerData = nil
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced scoreboard cleanup with analytics
        function MODULE:ScoreboardClosed(panel)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Track scoreboard usage time
            if MODULE.scoreboardOpenTime then
                local usageTime = os.time() - MODULE.scoreboardOpenTime
                local char = client:getChar()
                if char then
                    local scoreboardStats = char:getData("scoreboardStats", {})
                    scoreboardStats.totalTime = (scoreboardStats.totalTime or 0) + usageTime
                    scoreboardStats.sessions = (scoreboardStats.sessions or 0) + 1
                    char:setData("scoreboardStats", scoreboardStats)
                end

                MODULE.scoreboardOpenTime = nil
            end

            -- Clean up any custom scoreboard elements
            if MODULE.customScoreboardElements then
                for _, element in ipairs(MODULE.customScoreboardElements) do
                    if IsValid(element) then
                        element:Remove()
                    end
                end
                MODULE.customScoreboardElements = nil
            end

            -- Clear cached player information
            MODULE.cachedPlayers = nil
            MODULE.playerSortMode = nil

            -- Notify modules
            hook.Run("ScoreboardClosed", panel)
        end
        ```
]]
function ScoreboardClosed(panel)
end

--[[
    Purpose:
        Called when scoreboard is opened.

    When Called:
        When scoreboard UI is opened.

    Parameters:
        panel (Panel)
            The scoreboard panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log scoreboard open
        function MODULE:ScoreboardOpened(panel)
            print("Scoreboard opened")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Initialize scoreboard data
        function MODULE:ScoreboardOpened(panel)
            -- Cache current player data
            MODULE.cachedPlayers = player.GetAll()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced scoreboard initialization with sorting
        function MODULE:ScoreboardOpened(panel)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Track scoreboard open time
            MODULE.scoreboardOpenTime = os.time()

            -- Cache and sort player data
            MODULE.cachedPlayers = player.GetAll()
            MODULE.playerSortMode = "name" -- name, ping, score, etc.

            -- Sort players by name initially
            table.sort(MODULE.cachedPlayers, function(a, b)
                return a:Name() < b:Name()
            end)

            -- Initialize custom scoreboard elements
            MODULE.customScoreboardElements = {}

            -- Create custom header if needed
            if lia.config.get("CustomScoreboardHeader") then
                local header = vgui.Create("DPanel", panel)
                header:SetSize(panel:GetWide(), 40)
                header:SetPos(0, 0)
                header.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 200))
                    draw.SimpleText("Custom Server Scoreboard", "LiliaFont.36", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                table.insert(MODULE.customScoreboardElements, header)
            end

            -- Update player statistics
            local char = client:getChar()
            if char then
                local scoreboardStats = char:getData("scoreboardStats", {})
                scoreboardStats.opens = (scoreboardStats.opens or 0) + 1
                scoreboardStats.lastOpened = os.time()
                char:setData("scoreboardStats", scoreboardStats)
            end

            -- Notify modules
            hook.Run("ScoreboardOpened", panel)
        end
        ```
]]
function ScoreboardOpened(panel)
end

--[[
    Purpose:
        Called when scoreboard rows are created.

    When Called:
        When scoreboard player rows are created.

    Parameters:
        slot (number)
            The row slot.
        player (Player)
            The player for the row.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log row creation
        function MODULE:ScoreboardRowCreated(slot, player)
            print("Created row for: " .. player:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Customize row appearance
        function MODULE:ScoreboardRowCreated(slot, player)
            -- Row customization logic would go here
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced row customization with player data
        function MODULE:ScoreboardRowCreated(slot, player)
            if not IsValid(player) then return end

            -- Get row panel (this would be passed or accessible)
            local rowPanel = MODULE.scoreboardRows and MODULE.scoreboardRows[slot]
            if not IsValid(rowPanel) then return end

            -- Add custom player information
            local char = player:getChar()
            if char then
                -- Add faction/class display
                local faction = char:getFaction()
                if faction then
                    local factionLabel = vgui.Create("DLabel", rowPanel)
                    factionLabel:SetText(faction.name)
                    factionLabel:SetFont("LiliaFont.17")
                    factionLabel:SetColor(faction.color or color_white)
                    factionLabel:SizeToContents()
                    factionLabel:SetPos(rowPanel:GetWide() - factionLabel:GetWide() - 10, 5)
                end

                -- Add custom status indicators
                local statusIndicators = char:getData("statusIndicators", {})
                for i, indicator in ipairs(statusIndicators) do
                    local indicatorPanel = vgui.Create("DPanel", rowPanel)
                    indicatorPanel:SetSize(16, 16)
                    indicatorPanel:SetPos(10 + (i * 18), rowPanel:GetTall() - 20)
                    indicatorPanel.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, indicator.color or Color(255, 255, 255))
                        if indicator.icon then
                            surface.SetMaterial(indicator.icon)
                            surface.DrawTexturedRect(2, 2, w-4, h-4)
                        end
                    end
                end
            end

            -- Add ping display
            local ping = player:Ping()
            local pingColor = ping < 50 and Color(0, 255, 0) or ping < 100 and Color(255, 255, 0) or Color(255, 0, 0)
            local pingLabel = vgui.Create("DLabel", rowPanel)
            pingLabel:SetText(ping .. "ms")
            pingLabel:SetFont("LiliaFont.17")
            pingLabel:SetColor(pingColor)
            pingLabel:SizeToContents()
            pingLabel:SetPos(rowPanel:GetWide() - pingLabel:GetWide() - 10, rowPanel:GetTall() - pingLabel:GetTall() - 5)
        end
        ```
]]
function ScoreboardRowCreated(slot, player)
end

--[[
    Purpose:
        Called when scoreboard rows are removed.

    When Called:
        When scoreboard player rows are removed.

    Parameters:
        panel (Panel)
            The scoreboard panel.
        player (Player)
            The player whose row was removed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log row removal
        function MODULE:ScoreboardRowRemoved(panel, player)
            print("Removed row for: " .. player:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up row data
        function MODULE:ScoreboardRowRemoved(panel, player)
            -- Clean up any custom elements for this row
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced row cleanup with data management
        function MODULE:ScoreboardRowRemoved(panel, player)
            if not IsValid(panel) or not IsValid(player) then return end

            -- Clean up custom row elements
            if MODULE.scoreboardRows and MODULE.scoreboardRows[player] then
                local rowElements = MODULE.scoreboardRows[player].customElements
                if rowElements then
                    for _, element in ipairs(rowElements) do
                        if IsValid(element) then
                            element:Remove()
                        end
                    end
                end
                MODULE.scoreboardRows[player] = nil
            end

            -- Remove from cached player data
            if MODULE.cachedPlayers then
                for i, cachedPlayer in ipairs(MODULE.cachedPlayers) do
                    if cachedPlayer == player then
                        table.remove(MODULE.cachedPlayers, i)
                        break
                    end
                end
            end

            -- Update player count display
            if MODULE.playerCountLabel and IsValid(MODULE.playerCountLabel) then
                MODULE.playerCountLabel:SetText("Players: " .. #player.GetAll())
            end

            -- Log player disconnection
            lia.log.add("Player left scoreboard: " .. player:Name() .. " (" .. player:SteamID() .. ")", FLAG_NORMAL)

            -- Notify modules
            hook.Run("ScoreboardPlayerRemoved", panel, player)
        end
        ```
]]
function ScoreboardRowRemoved(panel, player)
end

--[[
    Purpose:
        Called to setup quick menu.

    When Called:
        When quick menu UI is initialized.

    Parameters:
        panel (Panel)
            The quick menu panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic button
        function MODULE:SetupQuickMenu(panel)
            local btn = vgui.Create("DButton", panel)
            btn:SetText("Quick Action")
            btn:SetSize(100, 30)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add multiple quick actions
        function MODULE:SetupQuickMenu(panel)
            local actions = {"Inventory", "Character", "Settings"}
            for i, action in ipairs(actions) do
                local btn = vgui.Create("DButton", panel)
                btn:SetText(action)
                btn:SetPos(0, (i-1) * 35)
                btn:SetSize(150, 30)
                btn.DoClick = function()
                    -- Action logic
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced quick menu with dynamic content and permissions
        function MODULE:SetupQuickMenu(panel)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Clear existing buttons
            panel:Clear()

            -- Create button container
            local buttonContainer = vgui.Create("DPanel", panel)
            buttonContainer:SetSize(panel:GetWide() - 20, panel:GetTall() - 20)
            buttonContainer:SetPos(10, 10)

            -- Define quick actions based on character and permissions
            local quickActions = {}

            -- Always available actions
            table.insert(quickActions, {
                name = "Inventory",
                icon = "icon16/box.png",
                permission = nil,
                action = function() hook.Run("OpenInventory") end
            })

            table.insert(quickActions, {
                name = "Character",
                icon = "icon16/user.png",
                permission = nil,
                action = function() hook.Run("OpenCharacterMenu") end
            })

            -- Faction-specific actions
            local faction = char:getFaction()
            if faction then
                if faction.uniqueID == "police" then
                    table.insert(quickActions, {
                        name = "Police Menu",
                        icon = "icon16/shield.png",
                        permission = "police",
                        action = function() hook.Run("OpenPoliceMenu") end
                    })
                elseif faction.uniqueID == "medic" then
                    table.insert(quickActions, {
                        name = "Medical Menu",
                        icon = "icon16/heart.png",
                        permission = "medic",
                        action = function() hook.Run("OpenMedicalMenu") end
                    })
                end
            end

            -- Admin actions
            if client:IsAdmin() then
                table.insert(quickActions, {
                    name = "Admin Menu",
                    icon = "icon16/shield.png",
                    permission = "admin",
                    action = function() hook.Run("OpenAdminMenu") end
                })
            end

            -- Create buttons
            local buttonHeight = 35
            local buttonSpacing = 5
            for i, actionData in ipairs(quickActions) do
                -- Check permissions
                if not actionData.permission or client:HasPrivilege(actionData.permission) then
                    local btn = vgui.Create("DButton", buttonContainer)
                    btn:SetText(actionData.name)
                    btn:SetSize(buttonContainer:GetWide(), buttonHeight)
                    btn:SetPos(0, (i-1) * (buttonHeight + buttonSpacing))
                    btn:SetImage(actionData.icon)

                    btn.DoClick = actionData.action

                    -- Style button
                    btn.Paint = function(self, w, h)
                        local color = self:IsHovered() and Color(60, 60, 70) or Color(40, 40, 50)
                        draw.RoundedBox(4, 0, 0, w, h, color)
                        draw.SimpleText(actionData.name, "LiliaFont.25", 35, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                end
            end

            -- Add close button
            local closeBtn = vgui.Create("DButton", panel)
            closeBtn:SetText("Close")
            closeBtn:SetSize(80, 30)
            closeBtn:SetPos(panel:GetWide() - 90, panel:GetTall() - 40)
            closeBtn.DoClick = function()
                panel:SetVisible(false)
            end
        end
        ```
]]
function SetupQuickMenu(panel)
end

--[[
    Purpose:
        Determines if scoreboard override is allowed.

    When Called:
        When checking if scoreboard modifications are permitted.

    Parameters:
        player (Player)
            The player viewing the scoreboard.
        overrideType (string)
            The type of override requested.

    Returns:
        boolean
            Whether the override is allowed.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Allow all overrides
        function MODULE:ShouldAllowScoreboardOverride(player, overrideType)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Allow overrides for admins only
        function MODULE:ShouldAllowScoreboardOverride(player, overrideType)
            return player:IsAdmin()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced override permissions based on type and player
        function MODULE:ShouldAllowScoreboardOverride(player, overrideType)
            if not IsValid(player) then return false end

            -- Check admin permissions
            if overrideType == "admin" and not player:IsAdmin() then
                return false
            end

            -- Check moderator permissions
            if overrideType == "moderator" and not (player:IsAdmin() or player:IsUserGroup("moderator")) then
                return false
            end

            -- Check VIP permissions
            if overrideType == "vip" then
                local char = player:getChar()
                if not char or not char:getData("vip", false) then
                    return false
                end
            end

            -- Check faction-specific permissions
            if overrideType == "faction" then
                local char = player:getChar()
                if char then
                    local faction = char:getFaction()
                    if faction and faction.scoreboardOverride then
                        return faction.scoreboardOverride(player, char)
                    end
                end
                return false
            end

            return true
        end
        ```
]]
function ShouldAllowScoreboardOverride(player, overrideType)
end

--[[
    Purpose:
        Determines if a HUD bar should be drawn.

    When Called:
        When deciding whether to render HUD bars.

    Parameters:
        bar (table)
            The bar data.

    Returns:
        boolean
            Whether the bar should be drawn.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw all bars
        function MODULE:ShouldBarDraw(bar)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide specific bars
        function MODULE:ShouldBarDraw(bar)
            if bar.name == "health" and lia.config.get("HideHealthBar") then
                return false
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced bar visibility based on conditions
        function MODULE:ShouldBarDraw(bar)
            if not bar or not bar.name then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Hide bars based on configuration
            if lia.config.get("HideHealthBar") and bar.name == "health" then
                return false
            end

            if lia.config.get("HideArmorBar") and bar.name == "armor" then
                return false
            end

            -- Hide bars during certain sequences
            if char:getData("currentSequence") and bar.name == "stamina" then
                return false
            end

            -- Hide bars for specific factions/classes
            local faction = char:getFaction()
            if faction and faction.hiddenBars and table.HasValue(faction.hiddenBars, bar.name) then
                return false
            end

            local class = char:getClass()
            if class and class.hiddenBars and table.HasValue(class.hiddenBars, bar.name) then
                return false
            end

            -- Hide bars when unconscious
            if char:getData("unconscious", false) and bar.name ~= "health" then
                return false
            end

            return true
        end
        ```
]]
function ShouldBarDraw(bar)
end

--[[
    Purpose:
        Determines if third person should be disabled.

    When Called:
        When checking third person camera restrictions.

    Parameters:
        player (Player)
            The player.

    Returns:
        boolean
            Whether third person should be disabled.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Never disable third person
        function MODULE:ShouldDisableThirdperson(player)
            return false
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Disable in certain areas
        function MODULE:ShouldDisableThirdperson(player)
            local pos = player:GetPos()
            -- Disable in restricted areas
            if pos.z < 0 then -- Underground
                return true
            end
            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced third person restrictions
        function MODULE:ShouldDisableThirdperson(player)
            if not IsValid(player) then return true end

            local char = player:getChar()
            if not char then return true end

            -- Disable for certain factions
            local faction = char:getFaction()
            if faction and faction.disableThirdPerson then
                return true
            end

            -- Disable during certain activities
            if char:getData("inVehicle", false) then
                return true
            end

            if char:getData("currentSequence") then
                return true
            end

            -- Disable in restricted zones
            local pos = player:GetPos()
            local restrictedZones = lia.config.get("ThirdPersonRestrictedZones", {})
            for _, zone in ipairs(restrictedZones) do
                if pos:WithinAABox(zone.min, zone.max) then
                    return true
                end
            end

            -- Disable when unconscious
            if char:getData("unconscious", false) then
                return true
            end

            -- Check admin permissions
            if lia.config.get("ThirdPersonAdminOnly") and not player:IsAdmin() then
                return true
            end

            return false
        end
        ```
]]
function ShouldDisableThirdperson(player)
end

--[[
    Purpose:
        Determines if ammo should be drawn.

    When Called:
        When deciding whether to show ammo UI.

    Parameters:
        weapon (Entity)
            The weapon.

    Returns:
        boolean
            Whether ammo should be drawn.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show ammo
        function MODULE:ShouldDrawAmmo(weapon)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide ammo for certain weapons
        function MODULE:ShouldDrawAmmo(weapon)
            if IsValid(weapon) and weapon:GetClass() == "weapon_fists" then
                return false
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ammo display logic
        function MODULE:ShouldDrawAmmo(weapon)
            if not IsValid(weapon) then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Hide ammo for melee weapons
            if weapon:GetClass():find("fists") or weapon:GetClass():find("crowbar") then
                return false
            end

            -- Hide ammo during certain sequences
            if char:getData("currentSequence") then
                return false
            end

            -- Hide ammo when unconscious
            if char:getData("unconscious", false) then
                return false
            end

            -- Check weapon-specific settings
            local weaponData = lia.item.weaponData[weapon:GetClass()]
            if weaponData and weaponData.hideAmmo then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction and faction.hideAmmo then
                return false
            end

            -- Check configuration
            if lia.config.get("HideAmmoDisplay") then
                return false
            end

            return true
        end
        ```
]]
function ShouldDrawAmmo(weapon)
end

--[[
    Purpose:
        Determines if entity info should be drawn.

    When Called:
        When deciding whether to show entity information overlays.

    Parameters:
        entity (Entity)
            The entity.

    Returns:
        boolean
            Whether entity info should be drawn.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Show info for all entities
        function MODULE:ShouldDrawEntityInfo(entity)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show info based on entity type
        function MODULE:ShouldDrawEntityInfo(entity)
            if IsValid(entity) and entity:IsPlayer() then
                return true
            end
            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced entity info visibility with distance and permissions
        function MODULE:ShouldDrawEntityInfo(entity)
            if not IsValid(entity) then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check distance
            local dist = client:GetPos():Distance(entity:GetPos())
            if dist > 500 then return false end

            -- Show for players
            if entity:IsPlayer() then
                local targetChar = entity:getChar()
                if targetChar then
                    -- Hide if target is in stealth mode
                    if targetChar:getData("stealth", false) then
                        return false
                    end

                    -- Check faction visibility
                    local clientFaction = char:getFaction()
                    local targetFaction = targetChar:getFaction()
                    if clientFaction and targetFaction then
                        if clientFaction.uniqueID == targetFaction.uniqueID then
                            return true -- Same faction, always show
                        elseif clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, targetFaction.uniqueID) then
                            return client:IsAdmin() -- Hostile faction, admin only
                        end
                    end

                    return true
                end
            end

            -- Show for items
            if entity:GetClass() == "lia_item" then
                return true
            end

            -- Show for doors with special permissions
            if entity:GetClass() == "lia_door" then
                local doorData = lia.doors.getData(entity)
                if doorData and doorData.owner then
                    return doorData.owner == char:getID() or client:IsAdmin()
                end
            end

            return false
        end
        ```
]]
function ShouldDrawEntityInfo(entity)
end

--[[
    Purpose:
        Determines if player info should be drawn.

    When Called:
        When deciding whether to show player information overlays.

    Parameters:
        player (Player)
            The player.

    Returns:
        boolean
            Whether player info should be drawn.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Show info for all players
        function MODULE:ShouldDrawPlayerInfo(player)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide info for far players
        function MODULE:ShouldDrawPlayerInfo(player)
            if IsValid(player) then
                local dist = LocalPlayer():GetPos():Distance(player:GetPos())
                return dist <= 300
            end
            return false
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced player info visibility with recognition system
        function MODULE:ShouldDrawPlayerInfo(player)
            if not IsValid(player) then return false end

            local client = LocalPlayer()
            if not IsValid(client) or player == client then return false end

            local char = client:getChar()
            if not char then return false end

            local targetChar = player:getChar()
            if not targetChar then return false end

            -- Check distance
            local dist = client:GetPos():Distance(player:GetPos())
            if dist > 400 then return false end

            -- Check recognition
            if not char:doesRecognize(targetChar:getID()) then
                return false -- Don't show info for unrecognized players
            end

            -- Check stealth
            if targetChar:getData("stealth", false) then
                return client:IsAdmin() -- Only admins see stealth players
            end

            -- Check faction visibility
            local clientFaction = char:getFaction()
            local targetFaction = targetChar:getFaction()
            if clientFaction and targetFaction then
                if clientFaction.uniqueID == targetFaction.uniqueID then
                    return true -- Same faction
                end

                -- Check if faction allows seeing other factions
                if clientFaction.canSeeOtherFactions then
                    return true
                end

                -- Hostile factions only visible to admins
                if clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, targetFaction.uniqueID) then
                    return client:IsAdmin()
                end
            end

            -- Default to showing for recognized players within range
            return true
        end
        ```
]]
function ShouldDrawPlayerInfo(player)
end

--[[
    Purpose:
        Determines if weapon selection should be drawn.

    When Called:
        When deciding whether to show weapon selection UI.

    Parameters:
        client (Player)
            The player.

    Returns:
        boolean
            Whether weapon selection should be drawn.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show weapon selection
        function MODULE:ShouldDrawWepSelect(client)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide during combat
        function MODULE:ShouldDrawWepSelect(client)
            if IsValid(client) then
                return not client:IsInCombat()
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced weapon selection visibility with faction restrictions
        function MODULE:ShouldDrawWepSelect(client)
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Hide during sequences
            if char:getData("currentSequence") then
                return false
            end

            -- Hide when unconscious
            if char:getData("unconscious", false) then
                return false
            end

            -- Hide when restrained
            if char:getData("restrained", false) then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction and faction.disableWeaponSelect then
                return false
            end

            -- Check class restrictions
            local class = char:getClass()
            if class and class.disableWeaponSelect then
                return false
            end

            -- Check configuration
            if lia.config.get("DisableWeaponSelect") then
                return false
            end

            -- Check weapon count - hide if no weapons
            if table.Count(client:GetWeapons()) <= 1 then
                return false -- Don't show selector for single weapon
            end

            return true
        end
        ```
]]
function ShouldDrawWepSelect(client)
end

--[[
    Purpose:
        Determines if HUD bars should be hidden.

    When Called:
        When deciding whether to hide all HUD bars.

    Parameters:
        None

    Returns:
        boolean
            Whether bars should be hidden.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Never hide bars
        function MODULE:ShouldHideBars()
            return false
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide during screenshots
        function MODULE:ShouldHideBars()
            return gui.IsTakingScreenshot()
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced bar hiding with multiple conditions
        function MODULE:ShouldHideBars()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Hide during screenshots
            if gui.IsTakingScreenshot() then
                return true
            end

            -- Hide in photo mode
            if char:getData("photoMode", false) then
                return true
            end

            -- Hide during certain sequences
            if char:getData("currentSequence") then
                return true
            end

            -- Hide when unconscious (bars handled separately)
            if char:getData("unconscious", false) then
                return true
            end

            -- Hide for specific factions/classes
            local faction = char:getFaction()
            if faction and faction.hideHUD then
                return true
            end

            local class = char:getClass()
            if class and class.hideHUD then
                return true
            end

            -- Hide in cinematic mode
            if char:getData("cinematic", false) then
                return true
            end

            -- Admin override
            if client:IsAdmin() and char:getData("hideHUD", false) then
                return true
            end

            -- Check configuration
            if lia.config.get("HideHUD") then
                return true
            end

            return false
        end
        ```
]]
function ShouldHideBars()
end

--[[
    Purpose:
        Determines if menu buttons should be shown.

    When Called:
        When deciding whether to display menu buttons.

    Parameters:
        buttonType (string)
            The button type.

    Returns:
        boolean
            Whether the button should be shown.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Show all buttons
        function MODULE:ShouldMenuButtonShow(buttonType)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide specific button types
        function MODULE:ShouldMenuButtonShow(buttonType)
            if buttonType == "admin" then
                return LocalPlayer():IsAdmin()
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced button visibility with permissions and conditions
        function MODULE:ShouldMenuButtonShow(buttonType)
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Admin buttons
            if buttonType == "admin" or buttonType == "moderation" then
                if buttonType == "admin" and not client:IsAdmin() then
                    return false
                end
                if buttonType == "moderation" and not (client:IsAdmin() or client:IsUserGroup("moderator")) then
                    return false
                end
            end

            -- Character creation buttons
            if buttonType == "char_create" then
                -- Hide if character limit reached
                local maxChars = lia.config.get("MaxCharacters", 5)
                if table.Count(client:getCharacters()) >= maxChars then
                    return false
                end
            end

            -- Faction-specific buttons
            if buttonType:find("faction_") then
                local factionID = buttonType:gsub("faction_", "")
                local faction = char:getFaction()
                if faction and faction.uniqueID == factionID then
                    return true
                end
                return false
            end

            -- Class-specific buttons
            if buttonType:find("class_") then
                local classID = buttonType:gsub("class_", "")
                local class = char:getClass()
                if class and class.uniqueID == classID then
                    return true
                end
                return false
            end

            -- Context-sensitive buttons
            if buttonType == "vehicle" then
                return char:getData("inVehicle", false)
            end

            if buttonType == "trade" then
                -- Only show when looking at another player
                local trace = client:GetEyeTrace()
                if trace.Entity and trace.Entity:IsPlayer() then
                    local distance = client:GetPos():Distance(trace.Entity:GetPos())
                    return distance <= 100
                end
                return false
            end

            -- VIP-only buttons
            if buttonType:find("_vip") and not char:getData("vip", false) then
                return false
            end

            return true
        end
        ```
]]
function ShouldMenuButtonShow(buttonType)
end

--[[
    Purpose:
        Determines if death sound should be played.

    When Called:
        When deciding whether to play death audio.

    Parameters:
        client (Player)
            The dying player.
        deathSound (string)
            The death sound.

    Returns:
        boolean
            Whether the sound should be played.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always play death sounds
        function MODULE:ShouldPlayDeathSound(client, deathSound)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Mute death sounds in certain areas
        function MODULE:ShouldPlayDeathSound(client, deathSound)
            if IsValid(client) then
                -- Don't play sounds in quiet zones
                local pos = client:GetPos()
                if pos.z < 0 then -- Underground
                    return false
                end
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced death sound control with preferences and conditions
        function MODULE:ShouldPlayDeathSound(client, deathSound)
            if not IsValid(client) then return false end

            local localPlayer = LocalPlayer()
            if not IsValid(localPlayer) then return false end

            local char = localPlayer:getChar()
            if not char then return false end

            -- Don't play own death sound (handled separately)
            if client == localPlayer then
                return false
            end

            -- Check distance - don't play distant death sounds
            local dist = localPlayer:GetPos():Distance(client:GetPos())
            if dist > 800 then
                return false
            end

            -- Check player preferences
            if char:getData("muteDeathSounds", false) then
                return false
            end

            -- Check faction-specific sound rules
            local clientChar = client:getChar()
            if clientChar then
                local clientFaction = clientChar:getFaction()
                local localFaction = char:getFaction()

                if clientFaction and localFaction then
                    -- Don't play sounds for hostile faction deaths
                    if clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, localFaction.uniqueID) then
                        return false
                    end

                    -- Custom faction sound rules
                    if clientFaction.muteDeathSounds then
                        return false
                    end
                end
            end

            -- Check configuration
            if lia.config.get("MuteDeathSounds") then
                return false
            end

            -- Check for repeated deaths (spam prevention)
            if MODULE.lastDeathSound and (CurTime() - MODULE.lastDeathSound) < 1 then
                return false -- Prevent sound spam
            end

            MODULE.lastDeathSound = CurTime()

            return true
        end
        ```
]]
function ShouldPlayDeathSound(client, deathSound)
end

--[[
    Purpose:
        Determines if pain sound should be played.

    When Called:
        When deciding whether to play pain audio.

    Parameters:
        client (Player)
            The injured player.
        painSound (string)
            The pain sound.

    Returns:
        boolean
            Whether the sound should be played.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always play pain sounds
        function MODULE:ShouldPlayPainSound(client, painSound)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Mute pain sounds for certain players
        function MODULE:ShouldPlayPainSound(client, painSound)
            if IsValid(client) and client:IsAdmin() then
                return false -- Mute admin pain sounds
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced pain sound control with preferences and faction rules
        function MODULE:ShouldPlayPainSound(client, painSound)
            if not IsValid(client) then return false end

            local localPlayer = LocalPlayer()
            if not IsValid(localPlayer) then return false end

            local char = localPlayer:getChar()
            if not char then return false end

            -- Don't play own pain sound (handled separately)
            if client == localPlayer then
                return false
            end

            -- Check distance - don't play distant pain sounds
            local dist = localPlayer:GetPos():Distance(client:GetPos())
            if dist > 600 then
                return false
            end

            -- Check player preferences
            if char:getData("mutePainSounds", false) then
                return false
            end

            -- Check faction-specific sound rules
            local clientChar = client:getChar()
            if clientChar then
                local clientFaction = clientChar:getFaction()
                local localFaction = char:getFaction()

                if clientFaction and localFaction then
                    -- Don't play sounds for hostile faction pain
                    if clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, localFaction.uniqueID) then
                        return false
                    end

                    -- Custom faction sound rules
                    if clientFaction.mutePainSounds then
                        return false
                    end
                end
            end

            -- Check configuration
            if lia.config.get("MutePainSounds") then
                return false
            end

            -- Check for repeated pain sounds (spam prevention)
            if MODULE.lastPainSound and (CurTime() - MODULE.lastPainSound) < 0.5 then
                return false -- Prevent sound spam
            end

            MODULE.lastPainSound = CurTime()

            -- Check pain intensity - don't play minor pain sounds
            if painSound and painSound:find("minor") then
                return dist <= 300 -- Only play minor sounds for close players
            end

            return true
        end
        ```
]]
function ShouldPlayPainSound(client, painSound)
end

--[[
    Purpose:
        Determines if respawn screen should appear.

    When Called:
        When deciding whether to show respawn UI.

    Parameters:
        None

    Returns:
        boolean
            Whether respawn screen should appear.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show respawn screen
        function MODULE:ShouldRespawnScreenAppear()
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show respawn screen based on player state
        function MODULE:ShouldRespawnScreenAppear()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            -- Don't show if player is alive
            if client:Alive() then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced respawn screen control with game mode checks
        function MODULE:ShouldRespawnScreenAppear()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Don't show if player is alive
            if client:Alive() then
                return false
            end

            -- Check if respawn is allowed
            if GetGlobalBool("DisableRespawn", false) then
                return false
            end

            -- Check game mode specific rules
            local gameMode = engine.ActiveGamemode()
            if gameMode == "sandbox" and lia.config.get("SandboxNoRespawnScreen", false) then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction and faction.noRespawnScreen then
                return false
            end

            -- Check admin override
            if client:IsAdmin() and GetGlobalBool("AdminNoRespawnScreen", false) then
                return false
            end

            -- Check time-based restrictions
            local deathTime = client:getNetVar("DeathTime", 0)
            local respawnDelay = lia.config.get("RespawnDelay", 5)

            if (CurTime() - deathTime) < respawnDelay then
                return false -- Too soon after death
            end

            -- Check for custom respawn conditions
            if hook.Run("CanPlayerRespawn", client) == false then
                return false
            end

            return true
        end
        ```
]]
function ShouldRespawnScreenAppear()
end

--[[
    Purpose:
        Determines if class should be shown on scoreboard.

    When Called:
        When deciding whether to display class on scoreboard.

    Parameters:
        clsData (table)
            The class data.

    Returns:
        boolean
            Whether class should be shown.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show classes
        function MODULE:ShouldShowClassOnScoreboard(clsData)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show classes based on visibility setting
        function MODULE:ShouldShowClassOnScoreboard(clsData)
            if clsData and clsData.hideOnScoreboard then
                return false
            end
            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced class display with permission and faction checks
        function MODULE:ShouldShowClassOnScoreboard(clsData)
            if not clsData then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Check if class is hidden by default
            if clsData.hideOnScoreboard then
                return false
            end

            -- Check faction visibility
            if clsData.faction and clsData.faction ~= char:getFaction().uniqueID then
                -- Only show classes from same faction unless admin
                if not client:IsAdmin() then
                    return false
                end
            end

            -- Check class restrictions
            if clsData.restricted and not client:IsAdmin() then
                return false
            end

            -- Check gamemode specific rules
            if clsData.gamemodeOnly then
                if not table.HasValue(clsData.gamemodeOnly, engine.ActiveGamemode()) then
                    return false
                end
            end

            -- Check player permissions
            if clsData.adminOnly and not client:IsAdmin() then
                return false
            end

            -- Check team visibility
            if clsData.teamOnly then
                if client:Team() ~= clsData.teamOnly then
                    return false
                end
            end

            return true
        end
        ```
]]
function ShouldShowClassOnScoreboard(clsData)
end

--[[
    Purpose:
        Determines if faction should be shown on scoreboard.

    When Called:
        When deciding whether to display faction on scoreboard.

    Parameters:
        player (Player)
            The player.

    Returns:
        boolean
            Whether faction should be shown.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show factions
        function MODULE:ShouldShowFactionOnScoreboard(player)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show factions based on visibility settings
        function MODULE:ShouldShowFactionOnScoreboard(player)
            if not IsValid(player) then return false end

            local char = player:getChar()
            if not char then return false end

            local faction = char:getFaction()
            if faction and faction.hideOnScoreboard then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced faction display with permission and relationship checks
        function MODULE:ShouldShowFactionOnScoreboard(player)
            if not IsValid(player) then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = player:getChar()
            if not char then return false end

            local clientChar = client:getChar()
            if not clientChar then return false end

            local faction = char:getFaction()
            if not faction then return false end

            -- Check if faction is hidden by default
            if faction.hideOnScoreboard then
                return false
            end

            -- Check admin visibility
            if faction.adminOnly and not client:IsAdmin() then
                return false
            end

            -- Check faction relationships
            local clientFaction = clientChar:getFaction()
            if clientFaction then
                -- Hide enemy factions unless admin
                if clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, faction.uniqueID) then
                    if not client:IsAdmin() then
                        return false
                    end
                end

                -- Show allied factions
                if clientFaction.alliedFactions and table.HasValue(clientFaction.alliedFactions, faction.uniqueID) then
                    return true
                end
            end

            -- Check gamemode restrictions
            if faction.gamemodeOnly then
                if not table.HasValue(faction.gamemodeOnly, engine.ActiveGamemode()) then
                    return false
                end
            end

            -- Check team restrictions
            if faction.teamOnly then
                if client:Team() ~= faction.teamOnly then
                    return false
                end
            end

            -- Check distance-based visibility
            if faction.localOnly then
                local dist = client:GetPos():Distance(player:GetPos())
                if dist > 1000 then -- 1000 units = ~30 meters
                    return false
                end
            end

            return true
        end
        ```
]]
function ShouldShowFactionOnScoreboard(player)
end

--[[
    Purpose:
        Determines if player should be shown on scoreboard.

    When Called:
        When deciding whether to display player on scoreboard.

    Parameters:
        player (Player)
            The player.

    Returns:
        boolean
            Whether player should be shown.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show players
        function MODULE:ShouldShowPlayerOnScoreboard(player)
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show players based on visibility settings
        function MODULE:ShouldShowPlayerOnScoreboard(player)
            if not IsValid(player) then return false end

            -- Don't show spectators
            if player:GetObserverMode() ~= OBS_MODE_NONE then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced player visibility with permission and distance checks
        function MODULE:ShouldShowPlayerOnScoreboard(player)
            if not IsValid(player) then return false end

            local client = LocalPlayer()
            if not IsValid(client) then return false end

            -- Don't show self (usually handled elsewhere, but good practice)
            if player == client then
                return true
            end

            -- Check if player has character
            local char = player:getChar()
            if not char then return false end

            -- Check admin visibility
            if player:IsAdmin() and not client:IsAdmin() then
                -- Hide admins from non-admins
                if lia.config.get("HideAdminsOnScoreboard", false) then
                    return false
                end
            end

            -- Check distance-based visibility
            if lia.config.get("LocalScoreboardOnly", false) then
                local dist = client:GetPos():Distance(player:GetPos())
                if dist > 2000 then -- ~60 meters
                    return false
                end
            end

            -- Check team restrictions
            if lia.config.get("TeamOnlyScoreboard", false) then
                if client:Team() ~= player:Team() then
                    return false
                end
            end

            -- Check faction restrictions
            local clientChar = client:getChar()
            if clientChar then
                local clientFaction = clientChar:getFaction()
                local playerFaction = char:getFaction()

                if clientFaction and playerFaction then
                    -- Hide enemy factions
                    if clientFaction.hostileFactions and table.HasValue(clientFaction.hostileFactions, playerFaction.uniqueID) then
                        if not client:IsAdmin() then
                            return false
                        end
                    end
                end
            end

            -- Check observer mode
            if player:GetObserverMode() ~= OBS_MODE_NONE then
                if not lia.config.get("ShowSpectatorsOnScoreboard", true) then
                    return false
                end
            end

            -- Check player state
            if player:IsDormant() and not lia.config.get("ShowDormantPlayers", false) then
                return false
            end

            return true
        end
        ```
]]
function ShouldShowPlayerOnScoreboard(player)
end

--[[
    Purpose:
        Determines if quick menu should be shown.

    When Called:
        When deciding whether to display quick menu.

    Parameters:
        None

    Returns:
        boolean
            Whether quick menu should be shown.

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Always show quick menu
        function MODULE:ShouldShowQuickMenu()
            return true
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show quick menu based on player state
        function MODULE:ShouldShowQuickMenu()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            -- Don't show if player is dead
            if not client:Alive() then
                return false
            end

            return true
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced quick menu control with permissions and context checks
        function MODULE:ShouldShowQuickMenu()
            local client = LocalPlayer()
            if not IsValid(client) then return false end

            local char = client:getChar()
            if not char then return false end

            -- Don't show if player is dead
            if not client:Alive() then
                return false
            end

            -- Check admin restrictions
            if client:IsAdmin() and lia.config.get("DisableQuickMenuForAdmins", false) then
                return false
            end

            -- Check gamemode restrictions
            if lia.config.get("DisableQuickMenu", false) then
                return false
            end

            -- Check faction restrictions
            local faction = char:getFaction()
            if faction and faction.disableQuickMenu then
                return false
            end

            -- Check class restrictions
            local class = char:getClass()
            if class and class.disableQuickMenu then
                return false
            end

            -- Check for open menus that might conflict
            if lia.gui.characterMenu and lia.gui.characterMenu:IsVisible() then
                return false
            end

            if lia.gui.inventory and lia.gui.inventory:IsVisible() then
                return false
            end

            -- Check console commands
            if lia.config.get("QuickMenuConsoleCommand", "") ~= "" then
                -- Only show if command was used recently
                if not MODULE.lastQuickMenuCommand or (CurTime() - MODULE.lastQuickMenuCommand) > 30 then
                    return false
                end
            end

            -- Check distance from spawn
            local spawnPos = MODULE.GetNearestSpawnPoint(client:GetPos())
            if spawnPos then
                local dist = client:GetPos():Distance(spawnPos)
                if dist > 500 and lia.config.get("QuickMenuNearSpawnOnly", false) then
                    return false
                end
            end

            return true
        end
        ```
]]
function ShouldShowQuickMenu()
end

--[[
    Purpose:
        Called to show player options menu.

    When Called:
        When displaying player interaction options.

    Parameters:
        player (Player)
            The target player.
        initialOptions (table)
            The initial options.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic interaction option
        function MODULE:ShowPlayerOptions(player, initialOptions)
            table.insert(initialOptions, {
                name = "Wave",
                icon = "icon16/wave.png",
                callback = function()
                    RunConsoleCommand("act", "wave")
                end
            })
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add multiple interaction options based on player state
        function MODULE:ShowPlayerOptions(player, initialOptions)
            local client = LocalPlayer()

            -- Add trade option if players are close
            if client:GetPos():Distance(player:GetPos()) < 200 then
                table.insert(initialOptions, {
                    name = "Trade",
                    icon = "icon16/money.png",
                    callback = function()
                        lia.command.run("trade", player:Name())
                    end
                })
            end

            -- Add whisper option
            table.insert(initialOptions, {
                name = "Whisper",
                icon = "icon16/comments.png",
                callback = function()
                    Derma_StringRequest("Whisper to " .. player:Name(),
                        "Enter your message:", "", function(text)
                        lia.command.run("whisper", player:Name(), text)
                    end)
                end
            })
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced player options with permissions and context checks
        function MODULE:ShowPlayerOptions(player, initialOptions)
            if not IsValid(player) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local clientChar = client:getChar()
            local targetChar = player:getChar()

            if not clientChar or not targetChar then return end

            -- Check distance
            local dist = client:GetPos():Distance(player:GetPos())
            local maxDist = lia.config.get("MaxInteractionDistance", 150)

            if dist > maxDist then
                return -- Too far away
            end

            -- Add basic interaction options
            if dist < 100 then
                table.insert(initialOptions, {
                    name = "Examine",
                    icon = "icon16/eye.png",
                    callback = function()
                        lia.command.run("roll", "examines " .. player:Name())
                    end
                })

                -- Add trade option if both have inventories
                if clientChar:getInv() and targetChar:getInv() then
                    table.insert(initialOptions, {
                        name = "Trade",
                        icon = "icon16/money.png",
                        callback = function()
                            lia.command.run("trade", player:Name())
                        end
                    })
                end
            end

            -- Add communication options
            table.insert(initialOptions, {
                name = "Whisper",
                icon = "icon16/comments.png",
                callback = function()
                    Derma_StringRequest("Whisper to " .. player:Name(),
                        "Enter your message:", "", function(text)
                        lia.command.run("whisper", player:Name(), text)
                    end)
                end
            })

            -- Add admin options for admins
            if client:IsAdmin() then
                table.insert(initialOptions, {
                    name = "Admin Menu",
                    icon = "icon16/shield.png",
                    callback = function()
                        local menu = DermaMenu()

                        menu:AddOption("Kick", function()
                            Derma_StringRequest("Kick Reason", "Enter kick reason:",
                                "Violation of server rules", function(reason)
                                RunConsoleCommand("kickid", player:UserID(), reason)
                            end)
                        end)

                        menu:AddOption("Ban", function()
                            local banMenu = DermaMenu()
                            banMenu:AddOption("1 Hour", function()
                                RunConsoleCommand("banid", player:UserID(), "60", "Admin ban")
                            end)
                            banMenu:AddOption("1 Day", function()
                                RunConsoleCommand("banid", player:UserID(), "1440", "Admin ban")
                            end)
                            banMenu:AddOption("Permanent", function()
                                RunConsoleCommand("banid", player:UserID(), "0", "Admin ban")
                            end)
                            banMenu:Open()
                        end)

                        menu:AddOption("Freeze", function()
                            RunConsoleCommand("freeze", player:Name())
                        end)

                        menu:Open()
                    end
                })
            end

            -- Add faction-specific options
            local clientFaction = clientChar:getFaction()
            local targetFaction = targetChar:getFaction()

            if clientFaction and targetFaction then
                -- Add alliance options for allied factions
                if clientFaction.alliedFactions and table.HasValue(clientFaction.alliedFactions, targetFaction.uniqueID) then
                    table.insert(initialOptions, {
                        name = "Alliance Chat",
                        icon = "icon16/group.png",
                        callback = function()
                            Derma_StringRequest("Alliance Message",
                                "Send message to " .. targetFaction.name .. " alliance:", "",
                                function(text)
                                lia.chat.send(client, "alliance", text, targetFaction.uniqueID)
                            end)
                        end
                    })
                end
            end

            -- Add business options if applicable
            if targetChar:getData("business", false) then
                table.insert(initialOptions, {
                    name = "Business",
                    icon = "icon16/briefcase.png",
                    callback = function()
                        lia.command.run("business", player:Name())
                    end
                })
            end

            -- Add medical options if player is injured
            if player:Health() < player:GetMaxHealth() * 0.5 then
                local hasMedical = false
                for _, item in pairs(clientChar:getInv():getItems()) do
                    if item.medical then
                        hasMedical = true
                        break
                    end
                end

                if hasMedical then
                    table.insert(initialOptions, {
                        name = "Offer Medical Aid",
                        icon = "icon16/heart.png",
                        callback = function()
                            lia.command.run("medical", player:Name())
                        end
                    })
                end
            end
        end
        ```
]]
function ShowPlayerOptions(player, initialOptions)
end

--[[
    Purpose:
        Called when storage unlock prompt is needed.

    When Called:
        When prompting for storage unlock.

    Parameters:
        entity (Entity)
            The storage entity.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic unlock prompt
        function MODULE:StorageUnlockPrompt(entity)
            -- Show a simple unlock prompt
            Derma_Message("This storage is locked. Unlock it?", "Storage Unlock",
                "Yes", function() MODULE.UnlockStorage(entity) end,
                "No", function() end)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Unlock prompt with password input
        function MODULE:StorageUnlockPrompt(entity)
            if not IsValid(entity) then return end

            Derma_StringRequest("Storage Unlock",
                "Enter the unlock code for this storage:",
                "", function(code)
                    MODULE.AttemptStorageUnlock(entity, code)
                end, function()
                    -- Cancelled
                end, "Unlock", "Cancel")
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced unlock prompt with multiple authentication methods
        function MODULE:StorageUnlockPrompt(entity)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Check if player already has access
            if MODULE.PlayerHasStorageAccess(client, entity) then
                MODULE.OpenStorageDirectly(entity)
                return
            end

            -- Get storage information
            local storageName = entity:getNetVar("storageName", "Storage")
            local storageType = entity:getNetVar("storageType", "container")
            local ownerName = entity:getNetVar("ownerName", "Unknown")

            -- Create advanced unlock menu
            local frame = vgui.Create("DFrame")
            frame:SetSize(400, 300)
            frame:SetTitle("Unlock " .. storageName)
            frame:Center()
            frame:MakePopup()

            local infoLabel = vgui.Create("DLabel", frame)
            infoLabel:SetPos(10, 30)
            infoLabel:SetSize(380, 40)
            infoLabel:SetText(string.format("This %s belongs to %s.\nChoose an unlock method:", storageType, ownerName))
            infoLabel:SetWrap(true)

            -- Password unlock option
            local passButton = vgui.Create("DButton", frame)
            passButton:SetPos(10, 80)
            passButton:SetSize(380, 30)
            passButton:SetText("Enter Password")
            passButton.DoClick = function()
                frame:Close()
                Derma_StringRequest("Password Unlock",
                    "Enter the password for this storage:",
                    "", function(password)
                        MODULE.AttemptPasswordUnlock(entity, password)
                    end)
            end

            -- Key item unlock option
            local keyButton = vgui.Create("DButton", frame)
            keyButton:SetPos(10, 120)
            keyButton:SetSize(380, 30)
            keyButton:SetText("Use Key Item")
            keyButton.DoClick = function()
                frame:Close()
                MODULE.ShowKeySelectionMenu(entity)
            end

            -- Biometric unlock option
            local bioButton = vgui.Create("DButton", frame)
            bioButton:SetPos(10, 160)
            bioButton:SetSize(380, 30)
            bioButton:SetText("Biometric Scan")
            bioButton.DoClick = function()
                frame:Close()
                MODULE.AttemptBiometricUnlock(entity, client)
            end

            -- Admin override (for admins only)
            if client:IsAdmin() then
                local adminButton = vgui.Create("DButton", frame)
                adminButton:SetPos(10, 200)
                adminButton:SetSize(380, 30)
                adminButton:SetText("Admin Override")
                adminButton:SetTextColor(Color(255, 0, 0))
                adminButton.DoClick = function()
                    frame:Close()
                    Derma_StringRequest("Admin Override",
                        "Confirm admin override:",
                        "ADMIN_UNLOCK", function(confirm)
                            if confirm == "ADMIN_UNLOCK" then
                                MODULE.AdminUnlockStorage(entity, client)
                            end
                        end)
                end
            end

            -- Cancel button
            local cancelButton = vgui.Create("DButton", frame)
            cancelButton:SetPos(10, 240)
            cancelButton:SetSize(380, 30)
            cancelButton:SetText("Cancel")
            cancelButton.DoClick = function()
                frame:Close()
            end

            -- Show lockpick option if player has lockpicks
            if MODULE.PlayerHasLockpicks(client) then
                local lockpickButton = vgui.Create("DButton", frame)
                lockpickButton:SetPos(10, 280)
                lockpickButton:SetSize(380, 30)
                lockpickButton:SetText("Attempt Lockpicking")
                lockpickButton:SetTextColor(Color(255, 165, 0))
                lockpickButton.DoClick = function()
                    frame:Close()
                    MODULE.StartLockpicking(entity)
                end
            end

            -- Log unlock attempt
            MODULE.LogUnlockAttempt(entity, client, "prompt_shown")

            -- Auto-close timer for security
            timer.Simple(30, function()
                if IsValid(frame) then
                    frame:Close()
                end
            end)
        end
        ```
]]
function StorageUnlockPrompt(entity)
end

--[[
    Purpose:
        Called when third person is toggled.

    When Called:
        When third person camera mode changes.

    Parameters:
        newValue (boolean)
            The new third person state.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic third person toggle logging
        function MODULE:ThirdPersonToggled(newValue)
            -- Log the camera mode change
            print("Third person toggled:", newValue)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Adjust HUD elements for third person
        function MODULE:ThirdPersonToggled(newValue)
            if newValue then
                -- Hide certain HUD elements in third person
                if lia.gui.crosshair then
                    lia.gui.crosshair:SetVisible(false)
                end
                -- Adjust weapon view model
                LocalPlayer():setClientNetVar("ThirdPerson", true)
            else
                -- Show HUD elements in first person
                if lia.gui.crosshair then
                    lia.gui.crosshair:SetVisible(true)
                end
                LocalPlayer():setClientNetVar("ThirdPerson", false)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive third person mode management
        function MODULE:ThirdPersonToggled(newValue)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()
            if not char then return end

            -- Log the toggle with detailed information
            lia.log.add(string.format("Third person %s for %s (%s)",
                newValue and "enabled" or "disabled",
                char:getName(), client:Name()), FLAG_NORMAL)

            -- Update client settings
            char:setData("thirdPerson", newValue)

            -- Adjust camera settings
            if newValue then
                -- Third person mode
                client:setClientNetVar("ThirdPerson", true)

                -- Adjust camera distance based on character
                local cameraDistance = MODULE.GetThirdPersonDistance(char)
                client:setClientNetVar("ThirdPersonDistance", cameraDistance)

                -- Hide first person elements
                MODULE.HideFirstPersonElements()

                -- Adjust weapon positioning
                MODULE.AdjustWeaponForThirdPerson()

                -- Update player model visibility
                if client:GetViewEntity() ~= client then
                    client:SetRenderMode(RENDERMODE_TRANSALPHA)
                    client:SetColor(Color(255, 255, 255, 255))
                end

                -- Play toggle sound
                surface.PlaySound("buttons/button9.wav")

            else
                -- First person mode
                client:setClientNetVar("ThirdPerson", false)
                client:setClientNetVar("ThirdPersonDistance", 0)

                -- Show first person elements
                MODULE.ShowFirstPersonElements()

                -- Reset weapon positioning
                MODULE.ResetWeaponPosition()

                -- Reset player model visibility
                client:SetRenderMode(RENDERMODE_NORMAL)

                -- Play toggle sound
                surface.PlaySound("buttons/button9.wav")
            end

            -- Update minimap or radar if applicable
            MODULE.UpdateMinimapForCameraMode(newValue)

            -- Adjust crosshair
            if lia.gui.crosshair then
                lia.gui.crosshair:SetVisible(not newValue)
            end

            -- Update third person indicator
            MODULE.UpdateThirdPersonIndicator(newValue)

            -- Check faction/class restrictions
            local faction = char:getFaction()
            if faction and faction.thirdPersonRestricted and newValue then
                client:notify("Your faction restricts third person view!")
                -- Optionally force back to first person
                timer.Simple(0.1, function()
                    if IsValid(client) then
                        RunConsoleCommand("thirdperson_toggle")
                    end
                end)
            end

            -- Update server with new setting
            net.Start("ThirdPersonToggled")
                net.WriteBool(newValue)
            net.SendToServer()

            -- Trigger camera smoothing
            MODULE.SmoothCameraTransition(newValue)

            -- Update any active vehicle handling
            if client:InVehicle() then
                MODULE.UpdateVehicleCameraForThirdPerson(client:GetVehicle(), newValue)
            end

            -- Handle special character abilities
            if char:getData("specialVision") then
                MODULE.ToggleSpecialVision(newValue)
            end

            -- Update lighting/shadows for third person
            MODULE.UpdateLightingForCameraMode(newValue)

            -- Send analytics data
            MODULE.TrackCameraModeUsage(char, newValue)

            -- Check for conflicts with other systems
            MODULE.CheckCameraModeConflicts(newValue)

            -- Update weapon selection UI
            if lia.gui.weaponSelect then
                lia.gui.weaponSelect:UpdateForCameraMode(newValue)
            end

            -- Handle ragdoll visibility
            MODULE.UpdateRagdollVisibility(client, newValue)

            -- Update any active effects
            MODULE.UpdateEffectsForCameraMode(newValue)

            -- Trigger custom events
            hook.Run("PostThirdPersonToggle", client, newValue)
        end
        ```
]]
function ThirdPersonToggled(newValue)
end

--[[
    Purpose:
        Called when ticket frame is displayed.

    When Called:
        When showing support ticket UI.

    Parameters:
        requester (Player)
            The ticket requester.
        message (string)
            The ticket message.
        claimed (boolean)
            Whether the ticket is claimed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic ticket frame display
        function MODULE:TicketFrame(requester, message, claimed)
            -- Create a simple notification
            chat.AddText(Color(255, 0, 0), "[TICKET] ", requester:Name(), ": ", message)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create ticket UI panel
        function MODULE:TicketFrame(requester, message, claimed)
            if not IsValid(requester) then return end

            local frame = vgui.Create("DFrame")
            frame:SetSize(300, 200)
            frame:SetTitle(claimed and "Claimed Ticket" or "New Ticket")
            frame:Center()
            frame:MakePopup()

            local info = vgui.Create("DLabel", frame)
            info:SetPos(10, 30)
            info:SetSize(280, 60)
            info:SetText(string.format("From: %s\nMessage: %s\nStatus: %s",
                requester:Name(), message, claimed and "Claimed" or "Unclaimed"))
            info:SetWrap(true)

            if not claimed then
                local claimBtn = vgui.Create("DButton", frame)
                claimBtn:SetPos(10, 100)
                claimBtn:SetSize(280, 30)
                claimBtn:SetText("Claim Ticket")
                claimBtn.DoClick = function()
                    MODULE.ClaimTicket(requester)
                    frame:Close()
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced ticket management system with full UI
        function MODULE:TicketFrame(requester, message, claimed)
            if not IsValid(requester) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Check if player has permission to view tickets
            if not MODULE.CanViewTickets(client) then
                client:notify("You don't have permission to view support tickets!")
                return
            end

            -- Create main ticket frame
            local frame = vgui.Create("DFrame")
            frame:SetSize(500, 400)
            frame:SetTitle(string.format("Support Ticket - %s", claimed and "Claimed" or "Unclaimed"))
            frame:SetDraggable(true)
            frame:Center()
            frame:MakePopup()

            -- Header information
            local headerPanel = vgui.Create("DPanel", frame)
            headerPanel:SetPos(10, 30)
            headerPanel:SetSize(480, 80)
            headerPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50))
            end

            local requesterLabel = vgui.Create("DLabel", headerPanel)
            requesterLabel:SetPos(10, 5)
            requesterLabel:SetText("Requester: " .. requester:Name())
            requesterLabel:SetFont("LiliaFont.17")
            requesterLabel:SizeToContents()

            local steamIDLabel = vgui.Create("DLabel", headerPanel)
            steamIDLabel:SetPos(10, 25)
            steamIDLabel:SetText("Steam ID: " .. requester:SteamID())
            steamIDLabel:SetFont("LiliaFont.17")
            steamIDLabel:SizeToContents()

            local statusLabel = vgui.Create("DLabel", headerPanel)
            statusLabel:SetPos(10, 45)
            statusLabel:SetText("Status: " .. (claimed and "Claimed" or "Unclaimed"))
            statusLabel:SetFont("LiliaFont.17")
            statusLabel:SetColor(claimed and Color(0, 255, 0) or Color(255, 255, 0))
            statusLabel:SizeToContents()

            -- Message display
            local messagePanel = vgui.Create("DPanel", frame)
            messagePanel:SetPos(10, 120)
            messagePanel:SetSize(480, 150)
            messagePanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40))
            end

            local messageLabel = vgui.Create("DLabel", messagePanel)
            messageLabel:SetPos(10, 10)
            messageLabel:SetSize(460, 130)
            messageLabel:SetText("Message:\n" .. message)
            messageLabel:SetWrap(true)
            messageLabel:SetFont("LiliaFont.17")

            -- Action buttons
            local buttonY = 280
            local buttonWidth = 150
            local buttonHeight = 30

            if not claimed and MODULE.CanClaimTickets(client) then
                local claimBtn = vgui.Create("DButton", frame)
                claimBtn:SetPos(10, buttonY)
                claimBtn:SetSize(buttonWidth, buttonHeight)
                claimBtn:SetText("Claim Ticket")
                claimBtn:SetTextColor(Color(0, 150, 0))
                claimBtn.DoClick = function()
                    MODULE.ClaimTicket(requester)
                    frame:Close()
                    client:notify("Ticket claimed successfully!")
                end

                local gotoBtn = vgui.Create("DButton", frame)
                gotoBtn:SetPos(170, buttonY)
                gotoBtn:SetSize(buttonWidth, buttonHeight)
                gotoBtn:SetText("Go to Player")
                gotoBtn.DoClick = function()
                    MODULE.GoToPlayer(requester)
                end

                local bringBtn = vgui.Create("DButton", frame)
                bringBtn:SetPos(330, buttonY)
                bringBtn:SetSize(buttonWidth, buttonHeight)
                bringBtn:SetText("Bring Player")
                bringBtn.DoClick = function()
                    MODULE.BringPlayer(requester)
                end

                buttonY = buttonY + 35
            elseif claimed and MODULE.IsTicketClaimedBy(client, requester) then
                local closeBtn = vgui.Create("DButton", frame)
                closeBtn:SetPos(10, buttonY)
                closeBtn:SetSize(buttonWidth, buttonHeight)
                closeBtn:SetText("Close Ticket")
                closeBtn:SetTextColor(Color(150, 0, 0))
                closeBtn.DoClick = function()
                    Derma_StringRequest("Close Ticket", "Resolution notes:", "",
                        function(notes)
                            MODULE.CloseTicket(requester, notes)
                            frame:Close()
                        end)
                end

                local respondBtn = vgui.Create("DButton", frame)
                respondBtn:SetPos(170, buttonY)
                respondBtn:SetSize(buttonWidth, buttonHeight)
                respondBtn:SetText("Respond")
                respondBtn.DoClick = function()
                    Derma_StringRequest("Respond to Ticket", "Your response:", "",
                        function(response)
                            MODULE.RespondToTicket(requester, response)
                        end)
                end
            end

            -- Admin actions (for high-level admins)
            if MODULE.IsHighLevelAdmin(client) then
                local adminBtn = vgui.Create("DButton", frame)
                adminBtn:SetPos(10, buttonY + 35)
                adminBtn:SetSize(150, 25)
                adminBtn:SetText("Admin Actions")
                adminBtn:SetTextColor(Color(255, 0, 0))
                adminBtn.DoClick = function()
                    MODULE.ShowAdminTicketActions(frame, requester)
                end
            end

            -- Log ticket view
            MODULE.LogTicketView(client, requester, message)

            -- Auto-refresh ticket status
            timer.Create("ticket_refresh_" .. requester:UserID(), 5, 0, function()
                if IsValid(frame) and IsValid(requester) then
                    MODULE.UpdateTicketStatus(frame, requester)
                else
                    timer.Remove("ticket_refresh_" .. requester:UserID())
                end
            end)

            -- Cleanup on frame close
            frame.OnClose = function()
                timer.Remove("ticket_refresh_" .. requester:UserID())
                MODULE.OnTicketFrameClosed(requester)
            end

            -- Play notification sound
            surface.PlaySound("ui/hint.wav")

            -- Send ticket viewed notification to server
            net.Start("TicketViewed")
                net.WriteEntity(requester)
            net.SendToServer()
        end
        ```
]]
function TicketFrame(requester, message, claimed)
end

--[[
    Purpose:
        Called to initialize tooltips.

    When Called:
        When tooltip panels are created.

    Parameters:
        tooltipPanel (Panel)
            The tooltip panel.
        panel (Panel)
            The parent panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic tooltip setup
        function MODULE:TooltipInitialize(tooltipPanel, panel)
            tooltipPanel:SetText("Tooltip")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add basic styling
        function MODULE:TooltipInitialize(tooltipPanel, panel)
            if not IsValid(tooltipPanel) then return end

            tooltipPanel:SetFont("LiliaFont.17")
            tooltipPanel:SetTextColor(color_white)
            tooltipPanel:SetContentAlignment(5) -- Center
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced tooltip with dynamic content
        function MODULE:TooltipInitialize(tooltipPanel, panel)
            if not IsValid(tooltipPanel) or not IsValid(panel) then return end

            -- Get panel data
            local panelData = panel:GetTable()
            local tooltipText = panelData.tooltipText or "No information available"

            -- Set up tooltip appearance
            tooltipPanel:SetFont("LiliaFont.17")
            tooltipPanel:SetTextColor(color_white)
            tooltipPanel:SetContentAlignment(5)
            tooltipPanel:SetText(tooltipText)

            -- Add background
            tooltipPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 255))
            end

            -- Add icon if available
            if panelData.tooltipIcon then
                local icon = vgui.Create("DImage", tooltipPanel)
                icon:SetSize(16, 16)
                icon:SetPos(5, 5)
                icon:SetImage(panelData.tooltipIcon)
            end
        end
        ```
]]
function TooltipInitialize(tooltipPanel, panel)
end

--[[
    Purpose:
        Called to layout tooltips.

    When Called:
        When tooltip panels are positioned.

    Parameters:
        tooltipPanel (Panel)
            The tooltip panel.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic layout
        function MODULE:TooltipLayout(tooltipPanel)
            tooltipPanel:SizeToContents()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Position tooltip
        function MODULE:TooltipLayout(tooltipPanel)
            if not IsValid(tooltipPanel) then return end

            tooltipPanel:SizeToContents()
            local x, y = input.GetCursorPos()
            tooltipPanel:SetPos(x + 10, y + 10)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced positioning with bounds checking
        function MODULE:TooltipLayout(tooltipPanel)
            if not IsValid(tooltipPanel) then return end

            tooltipPanel:SizeToContents()

            local x, y = input.GetCursorPos()
            local w, h = tooltipPanel:GetSize()
            local screenW, screenH = ScrW(), ScrH()

            -- Adjust position to stay on screen
            if x + w > screenW then
                x = screenW - w - 5
            end

            if y + h > screenH then
                y = screenH - h - 5
            end

            tooltipPanel:SetPos(x + 10, y + 10)
        end
        ```
]]
function TooltipLayout(tooltipPanel)
end

--[[
    Purpose:
        Called to paint tooltips.

    When Called:
        When tooltip panels are rendered.

    Parameters:
        tooltipPanel (Panel)
            The tooltip panel.
        width (number)
            The panel width.
        height (number)
            The panel height.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic background
        function MODULE:TooltipPaint(tooltipPanel, width, height)
            draw.RoundedBox(4, 0, 0, width, height, Color(0, 0, 0, 200))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Styled background
        function MODULE:TooltipPaint(tooltipPanel, width, height)
            draw.RoundedBox(4, 0, 0, width, height, Color(50, 50, 50, 255))
            draw.RoundedBox(4, 1, 1, width-2, height-2, Color(0, 0, 0, 200))
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced painting with borders and effects
        function MODULE:TooltipPaint(tooltipPanel, width, height)
            -- Main background
            draw.RoundedBox(4, 0, 0, width, height, Color(30, 30, 30, 250))

            -- Border
            surface.SetDrawColor(100, 100, 100, 255)
            surface.DrawOutlinedRect(0, 0, width, height, 1)

            -- Inner highlight
            draw.RoundedBox(4, 1, 1, width-2, height-2, Color(60, 60, 60, 100))

            -- Shadow effect
            draw.RoundedBox(4, 2, 2, width, height, Color(0, 0, 0, 50))
        end
        ```
]]
function TooltipPaint(tooltipPanel, width, height)
end

--[[
    Purpose:
        Called when items are transferred.

    When Called:
        When item transfer UI is activated.

    Parameters:
        itemID (number)
            The item ID.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic transfer
        function MODULE:TransferItem(itemID)
            -- Send transfer request to server
            net.Start("ItemTransfer")
                net.WriteString(itemID)
            net.SendToServer()
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Transfer with validation
        function MODULE:TransferItem(itemID)
            if not itemID then return end

            -- Check if item can be transferred
            if MODULE.CanTransferItem(itemID) then
                net.Start("ItemTransfer")
                    net.WriteString(itemID)
                net.SendToServer()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced transfer with UI feedback
        function MODULE:TransferItem(itemID)
            if not itemID then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Validate transfer conditions
            if not MODULE.CanTransferItem(itemID) then
                client:notify("Cannot transfer this item!")
                return
            end

            -- Show transfer animation
            MODULE.ShowTransferAnimation(itemID)

            -- Send transfer request
            net.Start("ItemTransfer")
                net.WriteString(itemID)
                net.WriteVector(client:GetPos())
            net.SendToServer()

            -- Log transfer attempt
            MODULE.LogItemTransfer(itemID, "initiated")
        end
        ```
]]
function TransferItem(itemID)
end

--[[
    Purpose:
        Called to try viewing models.

    When Called:
        When attempting to view item models.

    Parameters:
        entity (Entity)
            The entity to view.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic model viewing
        function MODULE:TryViewModel(entity)
            -- Open model viewer
            MODULE.OpenModelViewer(entity)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check entity validity
        function MODULE:TryViewModel(entity)
            if not IsValid(entity) then return end

            -- Check if entity has a model
            if entity:GetModel() then
                MODULE.OpenModelViewer(entity)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced model viewing with permissions
        function MODULE:TryViewModel(entity)
            if not IsValid(entity) then return end

            local client = LocalPlayer()
            if not IsValid(client) then return end

            -- Check permissions
            if not MODULE.CanViewModel(client, entity) then
                client:notify("You don't have permission to view this model!")
                return
            end

            -- Check model validity
            local model = entity:GetModel()
            if not model or model == "" then
                client:notify("This entity has no model to view!")
                return
            end

            -- Log model view attempt
            MODULE.LogModelView(entity, client)

            -- Open advanced model viewer
            MODULE.OpenAdvancedModelViewer(entity, {
                allowRotation = true,
                allowZoom = true,
                showStats = true,
                allowExport = MODULE.CanExportModels(client)
            })
        end
        ```
]]
function TryViewModel(entity)
end

--[[
    Purpose:
        Called when vendor interface is exited.

    When Called:
        When players close vendor menus.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic cleanup
        function MODULE:VendorExited()
            -- Close any open vendor panels
            if lia.gui.vendor then
                lia.gui.vendor:Remove()
            end
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Reset vendor state
        function MODULE:VendorExited()
            local client = LocalPlayer()

            -- Clear vendor interaction state
            client:setClientNetVar("currentVendor", nil)
            client:setClientNetVar("vendorMode", nil)

            -- Close vendor UI
            if lia.gui.vendor then
                lia.gui.vendor:Remove()
                lia.gui.vendor = nil
            end

            -- Reset cursor
            gui.EnableScreenClicker(false)
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive vendor exit with cleanup and analytics
        function MODULE:VendorExited()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local exitTime = CurTime()
            local char = client:getChar()

            -- Log vendor session end
            local sessionStart = client:getClientNetVar("vendorSessionStart", 0)
            local sessionDuration = exitTime - sessionStart

            if sessionDuration > 0 then
                lia.log.add(string.format("Vendor session ended - Duration: %.2f seconds", sessionDuration), FLAG_NORMAL)

                -- Track analytics
                MODULE.TrackVendorSession(client, sessionDuration)
            end

            -- Clear all vendor-related network variables
            client:setClientNetVar("currentVendor", nil)
            client:setClientNetVar("vendorMode", nil)
            client:setClientNetVar("vendorSessionStart", nil)
            client:setClientNetVar("vendorTransactionCount", nil)

            -- Close all vendor-related UI panels
            MODULE.CloseAllVendorPanels()

            -- Reset player state
            if char then
                char:setData("lastVendorInteraction", os.time())
            end

            -- Clean up any temporary vendor data
            MODULE.CleanupVendorTempData(client)

            -- Reset cursor and input states
            gui.EnableScreenClicker(false)
            MODULE.ResetVendorInputState()

            -- Handle any pending transactions
            MODULE.ProcessPendingVendorTransactions(client)

            -- Update player statistics
            MODULE.UpdatePlayerVendorStats(client, "exit")

            -- Notify server of exit
            net.Start("VendorExited")
                net.WriteFloat(sessionDuration)
            net.SendToServer()

            -- Reset any vendor-specific effects
            MODULE.ResetVendorEffects(client)

            -- Clear any vendor-related timers
            MODULE.ClearVendorTimers(client)

            -- Handle faction/vendor relationship updates
            if char then
                MODULE.UpdateFactionVendorRelationship(char, "exit")
            end

            -- Log detailed exit information
            lia.log.add(string.format("Player exited vendor interface - SteamID: %s, Character: %s, Session: %.2fs",
                client:SteamID(),
                char and char:getName() or "Unknown",
                sessionDuration), FLAG_NORMAL)

            -- Trigger post-exit hooks
            hook.Run("PostVendorExit", client, sessionDuration)

            -- Reset any active vendor animations
            MODULE.StopVendorAnimations(client)

            -- Clear any vendor-specific HUD elements
            MODULE.ClearVendorHUD(client)

            -- Handle any exit-specific achievements or rewards
            MODULE.CheckVendorExitAchievements(client, sessionDuration)
        end
        ```
]]
function VendorExited()
end

--[[
    Purpose:
        Called when voice chat is toggled.

    When Called:
        When voice chat state changes.

    Parameters:
        enabled (boolean)
            Whether voice is enabled.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic voice toggle logging
        function MODULE:VoiceToggled(enabled)
            print("Voice toggled:", enabled)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update voice state
        function MODULE:VoiceToggled(enabled)
            local client = LocalPlayer()
            client:setClientNetVar("voiceEnabled", enabled)

            if enabled then
                -- Show voice icon
                MODULE.ShowVoiceIcon()
            else
                -- Hide voice icon
                MODULE.HideVoiceIcon()
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Comprehensive voice management
        function MODULE:VoiceToggled(enabled)
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local char = client:getChar()

            -- Update voice state
            client:setClientNetVar("voiceEnabled", enabled)

            -- Log voice toggle
            lia.log.add(string.format("Voice %s for %s", enabled and "enabled" or "disabled", client:Name()), FLAG_NORMAL)

            if enabled then
                -- Handle voice activation
                MODULE.OnVoiceActivated(client)
                MODULE.ShowVoiceIcon()
                MODULE.UpdateVoiceRange(char)
            else
                -- Handle voice deactivation
                MODULE.OnVoiceDeactivated(client)
                MODULE.HideVoiceIcon()
            end

            -- Update voice settings
            char:setData("voiceEnabled", enabled)

            -- Trigger voice events
            hook.Run("VoiceStateChanged", client, enabled)
        end
        ```
]]
function VoiceToggled(enabled)
end

--[[
    Purpose:
        Called when weapon cycle sound plays.

    When Called:
        When weapons are cycled.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Play default cycle sound
        function MODULE:WeaponCycleSound()
            surface.PlaySound("weapons/smg1/switch_burst.wav")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Play sound based on current weapon
        function MODULE:WeaponCycleSound()
            local client = LocalPlayer()
            local weapon = client:GetActiveWeapon()

            if IsValid(weapon) then
                local soundPath = weapon.CycleSound or "weapons/smg1/switch_burst.wav"
                surface.PlaySound(soundPath)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced weapon cycling with custom sounds
        function MODULE:WeaponCycleSound()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local weapon = client:GetActiveWeapon()
            local char = client:getChar()

            if IsValid(weapon) then
                -- Get custom sound based on weapon type
                local soundPath = MODULE.GetWeaponCycleSound(weapon:GetClass()) or "weapons/smg1/switch_burst.wav"

                -- Apply volume and pitch modifications
                local volume = MODULE.GetWeaponSoundVolume(char, weapon)
                local pitch = MODULE.GetWeaponSoundPitch(char, weapon)

                -- Play the sound
                surface.PlaySound(soundPath)

                -- Log weapon cycling
                MODULE.LogWeaponCycle(client, weapon:GetClass())
            end
        end
        ```
]]
function WeaponCycleSound()
end

--[[
    Purpose:
        Called when weapon select sound plays.

    When Called:
        When weapons are selected.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Play default select sound
        function MODULE:WeaponSelectSound()
            surface.PlaySound("weapons/smg1/switch_single.wav")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Play sound based on current weapon
        function MODULE:WeaponSelectSound()
            local client = LocalPlayer()
            local weapon = client:GetActiveWeapon()

            if IsValid(weapon) then
                local soundPath = weapon.SelectSound or "weapons/smg1/switch_single.wav"
                surface.PlaySound(soundPath)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced weapon selection with custom sounds and effects
        function MODULE:WeaponSelectSound()
            local client = LocalPlayer()
            if not IsValid(client) then return end

            local weapon = client:GetActiveWeapon()
            local char = client:getChar()

            if IsValid(weapon) then
                -- Get custom sound based on weapon type and character
                local soundPath = MODULE.GetWeaponSelectSound(weapon:GetClass(), char) or "weapons/smg1/switch_single.wav"

                -- Apply sound modifications
                local volume = MODULE.GetWeaponSoundVolume(char, weapon)
                local pitch = MODULE.GetWeaponSoundPitch(char, weapon)

                -- Play the sound
                surface.PlaySound(soundPath)

                -- Add visual effects
                MODULE.AddWeaponSelectEffect(client, weapon)

                -- Update weapon statistics
                MODULE.UpdateWeaponSelectStats(client, weapon:GetClass())

                -- Log weapon selection
                MODULE.LogWeaponSelect(client, weapon:GetClass())
            end
        end
        ```
]]
function WeaponSelectSound()
end

--[[
    Purpose:
        Allows modification of PAC3 part data before it is attached to a player

    When Called:
        When a PAC3 part is being adjusted or attached to a player

    Parameters:
        wearer (Player) - The player who will wear the PAC3 part
        id (string) - The unique ID of the item/PAC3 part
        data (table) - The PAC3 part data table

    Returns:
        table or nil - Return modified data table, or nil to use original data

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Modify part color
    hook.Add("AdjustPACPartData", "MyAddon", function(wearer, id, data)
        if id == "my_custom_item" then
            data.Color = Color(255, 0, 0)
            return data
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Adjust part based on character
    hook.Add("AdjustPACPartData", "CharacterBasedPAC", function(wearer, id, data)
        local char = wearer:getChar()
        if not char then return end

        if id == "faction_badge" then
            local faction = char:getFaction()
            if faction == "police" then
                data.Color = Color(0, 0, 255)
            elseif faction == "medic" then
                data.Color = Color(255, 0, 0)
            end
            return data
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex PAC3 part modification system
    hook.Add("AdjustPACPartData", "AdvancedPACMod", function(wearer, id, data)
        local char = wearer:getChar()
        if not char then return end

        local item = lia.item.list[id]
        if not item or not item.pacAdjust then return end

        -- Let item handle its own adjustment
        local result = item:pacAdjust(data, wearer)
        if result ~= nil then return result end

        -- Apply faction-based modifications
        local faction = char:getFaction()
        local factionMods = {
            police = {Color = Color(0, 0, 255), Scale = 1.1},
            medic = {Color = Color(255, 0, 0), Scale = 0.9}
        }

        if factionMods[faction] then
            for key, value in pairs(factionMods[faction]) do
                data[key] = value
            end
        end

        -- Apply attribute-based modifications
        local con = char:getAttrib("con", 0)
        if con > 10 then
            data.Scale = (data.Scale or 1) * (1 + con * 0.01)
        end

        return data
    end)
    ```
]]
function AdjustPACPartData(wearer, id, data)
end

--[[
    Purpose:
        Retrieves adjusted PAC3 part data for a player

    When Called:
        When a PAC3 part needs to be retrieved for attachment

    Parameters:
        wearer (Player) - The player who will wear the PAC3 part
        id (string) - The unique ID of the item/PAC3 part

    Returns:
        table or nil - Return the adjusted part data table, or nil if part doesn't exist

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return cached part data
    hook.Add("GetAdjustedPartData", "MyAddon", function(wearer, id)
        local cached = myPartCache[id]
        if cached then
            return table.Copy(cached)
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Get and adjust part data
    hook.Add("GetAdjustedPartData", "PartDataRetrieval", function(wearer, id)
        if not partData[id] then return end

        local data = table.Copy(partData[id])
        return hook.Run("AdjustPACPartData", wearer, id, data) or data
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex part data retrieval with validation
    hook.Add("GetAdjustedPartData", "AdvancedPartData", function(wearer, id)
        local char = wearer:getChar()
        if not char then return end

        -- Check if part exists in cache
        if not partData[id] then return end

        -- Get base data
        local data = table.Copy(partData[id])

        -- Validate part compatibility with character
        local item = lia.item.list[id]
        if item and item.requiredFaction then
            if char:getFaction() ~= item.requiredFaction then
                return nil -- Part not compatible
            end
        end

        -- Apply adjustments
        data = hook.Run("AdjustPACPartData", wearer, id, data) or data

        -- Apply character-specific modifications
        if char:getData("customPACMods") then
            for key, value in pairs(char:getData("customPACMods")) do
                if data[key] ~= nil then
                    data[key] = value
                end
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
        Determines if character information can be displayed for a given name

    When Called:
        When the F1 menu or character info panel checks if it should display character information

    Parameters:
        name (string) - The name of the character to check

    Returns:
        boolean - Return false to prevent display, true or nil to allow

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Always allow display
    hook.Add("CanDisplayCharInfo", "MyAddon", function(name)
        return true
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Hide info for certain characters
    hook.Add("CanDisplayCharInfo", "HideCharInfo", function(name)
        local client = LocalPlayer()
        if not client then return true end

        local char = client:getChar()
        if not char then return true end

        -- Hide info for own character
        if char:getName() == name then
            return false
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex permission-based display system
    hook.Add("CanDisplayCharInfo", "PermissionBasedDisplay", function(name)
        local client = LocalPlayer()
        if not client then return true end

        local char = client:getChar()
        if not char then return true end

        -- Check if player has permission to view character info
        if not client:hasPrivilege("viewCharInfo") then
            return false
        end

        -- Check faction restrictions
        local targetChar = lia.char.find(name)
        if targetChar then
            local targetFaction = targetChar:getFaction()
            local myFaction = char:getFaction()

            -- Police can view all character info
            if myFaction == "police" then
                return true
            end

            -- Same faction can view each other
            if targetFaction == myFaction then
                return true
            end

            -- Check if target has privacy flag
            if targetChar:getData("hideInfo", false) then
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
        Allows modification of character list columns in the administration panel

    When Called:
        When the character list is being built in the administration panel

    Parameters:
        columns (table) - Table of column definitions to modify

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Add a custom column
    hook.Add("CharListColumns", "MyAddon", function(columns)
        columns[#columns + 1] = {
            field = "customField",
            format = function(val) return tostring(val) end
        }
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Add multiple columns with formatting
    hook.Add("CharListColumns", "CustomColumns", function(columns)
        table.insert(columns, {
            field = "reputation",
            format = function(val) return tostring(val) .. " rep" end
        })

        table.insert(columns, {
            field = "playtime",
            format = function(val) return string.NiceTime(val) end
        })
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex column system with conditional display
    hook.Add("CharListColumns", "AdvancedColumns", function(columns)
        local client = LocalPlayer()
        if not client then return end

        -- Only admins see certain columns
        if client:IsAdmin() then
            table.insert(columns, {
                field = "steamID",
                format = function(val) return val or "N/A" end
            })
        end

        -- Add faction-specific columns
        table.insert(columns, {
            field = "faction",
            format = function(val)
                local faction = lia.faction.indices[val]
                return faction and faction.name or val
            end
        })

        -- Add playtime with color coding
        table.insert(columns, {
            field = "playtime",
            format = function(val)
                local hours = val / 3600
                local color = hours > 100 and Color(0, 255, 0) or hours > 50 and Color(255, 255, 0) or Color(255, 0, 0)
                return string.NiceTime(val)
            end
        })
    end)
    ```
]]
function CharListColumns(columns)
end

--[[
    Purpose:
        Called when text is added to the chatbox

    When Called:
        After text has been added to the chatbox panel

    Parameters:
        ... (vararg) - Variable arguments passed from chat.AddText

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log chat messages
    hook.Add("ChatboxTextAdded", "MyAddon", function(...)
        print("Chat text added:", ...)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter or modify chat display
    hook.Add("ChatboxTextAdded", "ChatFilter", function(...)
        local args = {...}
        -- Check if message contains certain words
        for i, arg in ipairs(args) do
            if isstring(arg) and arg:find("spam") then
                return -- Don't display spam messages
            end
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex chat processing system
    hook.Add("ChatboxTextAdded", "AdvancedChat", function(...)
        local args = {...}
        local client = LocalPlayer()
        if not client then return end

        -- Extract message text
        local messageText = ""
        for _, arg in ipairs(args) do
            if isstring(arg) then
                messageText = messageText .. arg
            end
        end

        -- Check for mentions
        local playerName = client:Name()
        if messageText:find(playerName, 1, true) then
            -- Play notification sound
            surface.PlaySound("buttons/blip1.wav")

            -- Flash chat panel
            if IsValid(lia.gui.chat) then
                lia.gui.chat:Flash()
            end
        end

        -- Log important messages
        if messageText:find("admin", 1, true) or messageText:find("help", 1, true) then
            lia.log.add("Important chat: " .. messageText, FLAG_NORMAL)
        end
    end)
    ```
]]
function ChatboxTextAdded(...)
end

--[[
    Purpose:
        Filters character models available for selection

    When Called:
        When building the character model selection list

    Parameters:
        client (Player) - The client selecting a character model
        faction (table) - The faction data table
        data (table) - The model data
        idx (number/string) - The model index or identifier

    Returns:
        boolean or nil - Return false to exclude the model, true or nil to include

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Filter out specific models
    hook.Add("FilterCharModels", "MyAddon", function(client, faction, data, idx)
        if idx == "restricted_model" then
            return false
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Filter based on faction
    hook.Add("FilterCharModels", "FactionFilter", function(client, faction, data, idx)
        local char = client:getChar()
        if not char then return true end

        -- Only show certain models for specific factions
        if faction.uniqueID == "police" then
            if not data.isPoliceModel then
                return false
            end
        end

        return true
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex model filtering system
    hook.Add("FilterCharModels", "AdvancedFilter", function(client, faction, data, idx)
        local char = client:getChar()
        if not char then return true end

        -- Check faction restrictions
        if data.requiredFaction and data.requiredFaction ~= faction.uniqueID then
            return false
        end

        -- Check level requirements
        if data.requiredLevel then
            local charLevel = char:getData("level", 1)
            if charLevel < data.requiredLevel then
                return false
            end
        end

        -- Check permission requirements
        if data.requiredPermission then
            if not client:hasPrivilege(data.requiredPermission) then
                return false
            end
        end

        -- Check if model is unlocked
        if data.unlockable then
            local unlocked = char:getData("unlockedModels", {})
            if not table.HasValue(unlocked, idx) then
                return false
            end
        end

        return true
    end)
    ```
]]
function FilterCharModels(client, faction, data, idx)
end

--[[
    Purpose:
        Gets the injured status text for a character

    When Called:
        When drawing character information and checking injury status

    Parameters:
        character (Character) - The character to check

    Returns:
        table or nil - Return {textKey, color} table, or nil for no injured text

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Return basic injured text
    hook.Add("GetInjuredText", "MyAddon", function(character)
        if character:getData("injured", false) then
            return {"injured", Color(255, 0, 0)}
        end
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Check health-based injury
    hook.Add("GetInjuredText", "HealthInjury", function(character)
        local client = character:getPlayer()
        if not IsValid(client) then return end

        local health = client:Health()
        if health < 30 then
            return {"criticallyInjured", Color(255, 0, 0)}
        elseif health < 60 then
            return {"injured", Color(255, 165, 0)}
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex injury system with multiple states
    hook.Add("GetInjuredText", "AdvancedInjury", function(character)
        local client = character:getPlayer()
        if not IsValid(client) then return end

        local health = client:Health()
        local maxHealth = client:GetMaxHealth()
        local healthPercent = health / maxHealth

        -- Check for critical injury
        if healthPercent < 0.2 then
            return {"criticallyInjured", Color(255, 0, 0)}
        end

        -- Check for serious injury
        if healthPercent < 0.4 then
            return {"seriouslyInjured", Color(255, 100, 0)}
        end

        -- Check for moderate injury
        if healthPercent < 0.7 then
            return {"moderatelyInjured", Color(255, 200, 0)}
        end

        -- Check for stamina-based injury
        local stamina = client:getLocalVar("stamina", 100)
        if stamina < 10 then
            return {"exhausted", Color(100, 100, 255)}
        end

        -- Check for custom injury states
        local injuryState = character:getData("injuryState")
        if injuryState then
            local injuryData = {
                bleeding = {"bleeding", Color(200, 0, 0)},
                broken = {"brokenBone", Color(150, 150, 150)},
                poisoned = {"poisoned", Color(0, 200, 0)}
            }
            return injuryData[injuryState]
        end
    end)
    ```
]]
function GetInjuredText(character)
end

--[[
    Purpose:
        Called when keybinds have been initialized

    When Called:
        After all keybinds have been loaded and initialized

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log initialization
    hook.Add("InitializedKeybinds", "MyAddon", function()
        print("Keybinds initialized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Register custom keybinds
    hook.Add("InitializedKeybinds", "CustomKeybinds", function()
        lia.keybind.register("myCustomAction", {
            name = "My Custom Action",
            key = KEY_F1,
            onPressed = function()
                print("Custom action triggered")
            end
        })
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex keybind system
    hook.Add("InitializedKeybinds", "AdvancedKeybinds", function()
        -- Register multiple keybinds
        local keybinds = {
            {id = "quickUse", key = KEY_E, name = "Quick Use"},
            {id = "inventory", key = KEY_TAB, name = "Inventory"},
            {id = "radio", key = KEY_R, name = "Radio"}
        }

        for _, bind in ipairs(keybinds) do
            lia.keybind.register(bind.id, {
                name = bind.name,
                key = bind.key,
                onPressed = function()
                    hook.Run("OnKeybindPressed", bind.id)
                end
            })
        end

        -- Load saved keybind preferences
        local saved = lia.data.get("keybinds", {})
        for id, key in pairs(saved) do
            lia.keybind.set(id, key)
        end
    end)
    ```
]]
function InitializedKeybinds()
end

--[[
    Purpose:
        Called when options have been initialized

    When Called:
        After all options have been loaded and initialized

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log initialization
    hook.Add("InitializedOptions", "MyAddon", function()
        print("Options initialized")
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Register custom options
    hook.Add("InitializedOptions", "CustomOptions", function()
        lia.option.add("myCustomOption", {
            category = "My Category",
            type = "Boolean",
            default = true,
            onChanged = function(value)
                print("Option changed:", value)
            end
        })
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex option system
    hook.Add("InitializedOptions", "AdvancedOptions", function()
        -- Register multiple options
        local options = {
            {
                id = "myBoolean",
                category = "My Category",
                type = "Boolean",
                default = true
            },
            {
                id = "myNumber",
                category = "My Category",
                type = "Number",
                default = 50,
                min = 0,
                max = 100
            },
            {
                id = "myString",
                category = "My Category",
                type = "String",
                default = "default"
            }
        }

        for _, opt in ipairs(options) do
            lia.option.add(opt.id, opt)
        end

        -- Apply saved options
        local saved = lia.data.get("options", {})
        for id, value in pairs(saved) do
            lia.option.set(id, value)
        end
    end)
    ```
]]
function InitializedOptions()
end

--[[
    Purpose:
        Allows overriding the spawn time for a player

    When Called:
        When calculating spawn time for a player

    Parameters:
        client (Player) - The player spawning
        baseTime (number) - The base spawn time in seconds

    Returns:
        number or nil - Return modified spawn time, or nil to use base time

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Increase spawn time
    hook.Add("OverrideSpawnTime", "MyAddon", function(client, baseTime)
        return baseTime * 2
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Modify based on character
    hook.Add("OverrideSpawnTime", "CharBasedSpawn", function(client, baseTime)
        local char = client:getChar()
        if not char then return end

        local faction = char:getFaction()
        if faction == "medic" then
            return baseTime * 0.5 -- Medics spawn faster
        end

        return baseTime
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex spawn time system
    hook.Add("OverrideSpawnTime", "AdvancedSpawn", function(client, baseTime)
        local char = client:getChar()
        if not char then return end

        local modifiers = {
            base = baseTime
        }

        -- Faction modifiers
        local faction = char:getFaction()
        local factionMods = {
            medic = 0.5,
            police = 0.75,
            civilian = 1.0
        }
        modifiers.faction = factionMods[faction] or 1.0

        -- Attribute modifiers
        local con = char:getAttrib("con", 0)
        modifiers.attribute = 1.0 - (con * 0.01) -- 1% faster per constitution

        -- Death count modifiers
        local deathCount = char:getData("deathCount", 0)
        if deathCount > 5 then
            modifiers.death = 1.5 -- Longer spawn after multiple deaths
        end

        -- Calculate final time
        local finalTime = modifiers.base * modifiers.faction * modifiers.attribute * (modifiers.death or 1.0)
        return math.max(1, finalTime) -- Minimum 1 second
    end)
    ```
]]
function OverrideSpawnTime(client, baseTime)
end

--[[
    Purpose:
        Allows customization of the information displayed when looking at an item entity in the world

    When Called:
        When drawing entity information for an item entity that the player is looking at

    Parameters:
        self (Entity)
            The item entity being drawn
        item (table)
            The item table associated with the entity
        infoTable (table)
            Table of information entries to display (can be modified)
        alpha (number)
            The alpha value for the text rendering

    Returns:
        nil (modify infoTable in place)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add item name to display
        hook.Add("DrawItemEntityInfo", "MyAddon", function(self, item, infoTable, alpha)
            table.insert(infoTable, {
                text = item.name,
                yOffset = 0
            })
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom information based on item data
        hook.Add("DrawItemEntityInfo", "CustomItemInfo", function(self, item, infoTable, alpha)
            local itemData = item.data or {}
            if itemData.durability then
                table.insert(infoTable, {
                    text = "Durability: " .. itemData.durability .. "%",
                    yOffset = 50
                })
            end
            if itemData.owner then
                local ownerChar = lia.char.loaded[itemData.owner]
                if ownerChar then
                    table.insert(infoTable, {
                        text = "Owner: " .. ownerChar:getName(),
                        yOffset = 100
                    })
                end
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Complex item information display
        hook.Add("DrawItemEntityInfo", "AdvancedItemInfo", function(self, item, infoTable, alpha)
            local itemData = item.data or {}
            local yOffset = 0

            -- Add item name with quality color
            local quality = itemData.quality or "common"
            local qualityColors = {
                common = Color(255, 255, 255),
                uncommon = Color(0, 255, 0),
                rare = Color(0, 100, 255),
                epic = Color(150, 0, 255),
                legendary = Color(255, 165, 0)
            }
            table.insert(infoTable, {
                text = item.name,
                color = qualityColors[quality] or qualityColors.common,
                yOffset = yOffset
            })
            yOffset = yOffset + 50

            -- Add durability if applicable
            if itemData.durability then
                local durabilityColor = itemData.durability > 50 and Color(0, 255, 0) or
                                        itemData.durability > 25 and Color(255, 255, 0) or
                                        Color(255, 0, 0)
                table.insert(infoTable, {
                    text = "Durability: " .. itemData.durability .. "%",
                    color = durabilityColor,
                    yOffset = yOffset
                })
                yOffset = yOffset + 50
            end

            -- Add owner information
            if itemData.owner then
                local ownerChar = lia.char.loaded[itemData.owner]
                if ownerChar then
                    table.insert(infoTable, {
                        text = "Owner: " .. ownerChar:getName(),
                        yOffset = yOffset
                    })
                    yOffset = yOffset + 50
                end
            end

            -- Add custom description
            if itemData.customDesc then
                table.insert(infoTable, {
                    text = itemData.customDesc,
                    yOffset = yOffset
                })
            end
        end)
        ```
]]
function DrawItemEntityInfo(self, item, infoTable, alpha)
end

--[[
    Purpose:
        Allows customization of what information is displayed for entities in the admin ESP system

    When Called:
        When rendering ESP information for an entity in the admin ESP overlay

    Parameters:
        ent (Entity)
            The entity being rendered in ESP
        client (Player)
            The admin client viewing the ESP

    Returns:
        table or nil - Table with ESP information, or nil to use default rendering
            kind (string) - The category/type of entity
            label (string) - The main label text
            subLabel (string, optional) - Additional subtitle text
            baseColor (Color) - The base color for the ESP text
            customRender (function, optional) - Custom rendering function

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Custom ESP for specific entity class
        hook.Add("GetAdminESPTarget", "MyAddon", function(ent, client)
            if ent:GetClass() == "my_custom_entity" then
                return {
                    kind = "Custom Entity",
                    label = "My Custom Entity",
                    baseColor = Color(255, 0, 255)
                }
            end
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Custom ESP with entity data
        hook.Add("GetAdminESPTarget", "CustomESP", function(ent, client)
            if ent:GetClass() == "lia_storage" then
                local storageData = ent:getNetVar("storageData", {})
                return {
                    kind = "Storage",
                    label = storageData.name or "Storage Container",
                    subLabel = "Items: " .. (storageData.itemCount or 0),
                    baseColor = Color(0, 255, 255)
                }
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Complex ESP system with custom rendering
        hook.Add("GetAdminESPTarget", "AdvancedESP", function(ent, client)
            if ent:GetClass() == "my_vehicle" then
                local vehicleData = ent:getNetVar("vehicleData", {})
                local health = ent:Health()
                local maxHealth = ent:GetMaxHealth()
                local healthPercent = (health / maxHealth) * 100

                -- Determine color based on health
                local healthColor = healthPercent > 75 and Color(0, 255, 0) or
                                   healthPercent > 50 and Color(255, 255, 0) or
                                   healthPercent > 25 and Color(255, 165, 0) or
                                   Color(255, 0, 0)

                return {
                    kind = "Vehicle",
                    label = vehicleData.name or "Unknown Vehicle",
                    subLabel = string.format("Health: %d%% (%s)", healthPercent, vehicleData.owner or "No Owner"),
                    baseColor = healthColor,
                    customRender = function(pos, alpha)
                        -- Custom rendering logic here
                        draw.SimpleText("Custom Vehicle Info", "DermaDefault", pos.x, pos.y, healthColor, TEXT_ALIGN_CENTER)
                    end
                }
            end
        end)
        ```
]]
function GetAdminESPTarget(ent, client)
end

--[[
    Purpose:
        Allows adding custom dialog options to NPC conversation menus

    When Called:
        When an NPC dialog menu is being created and options are being loaded

    Parameters:
        client (Player)
            The client opening the dialog
        npc (Entity)
            The NPC entity
        canCustomize (boolean)
            Whether the client can customize the NPC

    Returns:
        table - Table of additional dialog options to add (key = option name, value = option data)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a custom dialog option
        hook.Add("GetNPCDialogOptions", "MyAddon", function(client, npc, canCustomize)
            return {
                ["Custom Option"] = {
                    text = "Ask about custom topic",
                    callback = function()
                        client:ChatPrint("NPC responds to custom topic!")
                    end
                }
            }
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add conditional dialog options
        hook.Add("GetNPCDialogOptions", "ConditionalOptions", function(client, npc, canCustomize)
            local char = client:getChar()
            if not char then return {} end

            local options = {}

            -- Add faction-specific option
            if char:getFaction() == "police" then
                options["Police Question"] = {
                    text = "Ask about recent crimes",
                    callback = function()
                        client:ChatPrint("The NPC tells you about recent criminal activity.")
                    end
                }
            end

            -- Add option based on character data
            if char:getData("hasCompletedQuest", false) then
                options["Quest Follow-up"] = {
                    text = "Ask about the quest",
                    callback = function()
                        client:ChatPrint("The NPC thanks you for completing the quest!")
                    end
                }
            end

            return options
        end)
        ```

    High Complexity:
        ```lua
        -- High: Complex dialog system with multiple conditions
        hook.Add("GetNPCDialogOptions", "AdvancedDialog", function(client, npc, canCustomize)
            local char = client:getChar()
            if not char then return {} end

            local npcID = npc:getNetVar("uniqueID", "")
            local options = {}

            -- Faction-based options
            local faction = char:getFaction()
            if faction == "police" and npcID == "citizen_npc" then
                options["Question Witness"] = {
                    text = "Question as a witness",
                    callback = function()
                        client:ChatPrint("The citizen provides witness testimony.")
                    end
                }
            end

            -- Reputation-based options
            local reputation = char:getData("npcReputation_" .. npcID, 0)
            if reputation >= 50 then
                options["Friendly Chat"] = {
                    text = "Have a friendly conversation",
                    callback = function()
                        client:ChatPrint("You have a pleasant conversation with the NPC.")
                        char:setData("npcReputation_" .. npcID, reputation + 5)
                    end
                }
            end

            -- Quest-related options
            local activeQuests = char:getData("activeQuests", {})
            for _, questID in ipairs(activeQuests) do
                if questID == "quest_" .. npcID then
                    options["Quest Progress"] = {
                        text = "Check quest progress",
                        callback = function()
                            local questData = char:getData("questData_" .. questID, {})
                            client:ChatPrint("Quest progress: " .. (questData.progress or 0) .. "%")
                        end
                    }
                end
            end

            -- Time-based options
            local hour = tonumber(os.date("%H"))
            if hour >= 6 and hour < 12 then
                options["Morning Greeting"] = {
                    text = "Good morning!",
                    callback = function()
                        client:ChatPrint("The NPC greets you warmly.")
                    end
                }
            end

            return options
        end)
        ```
]]
function GetNPCDialogOptions(client, npc, canCustomize)
end

--[[
    Purpose:
        Called when dual inventory panels are created (e.g., trading, storage access)

    When Called:
        When two inventory panels are opened simultaneously, such as during trading or accessing storage

    Parameters:
        panel1 (Panel)
            The first inventory panel
        panel2 (Panel)
            The second inventory panel
        inventory1 (Inventory)
            The first inventory instance
        inventory2 (Inventory)
            The second inventory instance

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Log when dual panels are created
        hook.Add("OnCreateDualInventoryPanels", "MyAddon", function(panel1, panel2, inventory1, inventory2)
            print("Dual inventory panels created")
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add custom buttons to dual inventory panels
        hook.Add("OnCreateDualInventoryPanels", "CustomButtons", function(panel1, panel2, inventory1, inventory2)
            -- Add transfer all button to panel1
            local transferBtn = vgui.Create("DButton", panel1)
            transferBtn:SetText("Transfer All")
            transferBtn:SetPos(10, 10)
            transferBtn:SetSize(100, 30)
            transferBtn.DoClick = function()
                -- Transfer all items from inventory1 to inventory2
                for _, item in pairs(inventory1:getItems()) do
                    inventory1:transfer(item:getID(), inventory2:getID())
                end
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Complex dual inventory system with custom UI
        hook.Add("OnCreateDualInventoryPanels", "AdvancedDualInventory", function(panel1, panel2, inventory1, inventory2)
            local client = LocalPlayer()
            local char = client:getChar()
            if not char then return end

            -- Add custom header to panel1
            local header1 = vgui.Create("DPanel", panel1)
            header1:SetPos(0, 0)
            header1:SetSize(panel1:GetWide(), 40)
            header1.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
                draw.SimpleText("Your Inventory", "DermaDefault", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Add custom header to panel2
            local header2 = vgui.Create("DPanel", panel2)
            header2:SetPos(0, 0)
            header2:SetSize(panel2:GetWide(), 40)
            header2.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
                local inv2Name = inventory2:getData("name", "Storage")
                draw.SimpleText(inv2Name, "DermaDefault", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Add weight display
            local weight1 = inventory1:getData("weight", 0)
            local maxWeight1 = inventory1:getData("maxWeight", 100)
            local weightLabel1 = vgui.Create("DLabel", panel1)
            weightLabel1:SetText(string.format("Weight: %d/%d", weight1, maxWeight1))
            weightLabel1:SetPos(10, panel1:GetTall() - 30)
            weightLabel1:SizeToContents()

            local weight2 = inventory2:getData("weight", 0)
            local maxWeight2 = inventory2:getData("maxWeight", 100)
            local weightLabel2 = vgui.Create("DLabel", panel2)
            weightLabel2:SetText(string.format("Weight: %d/%d", weight2, maxWeight2))
            weightLabel2:SetPos(10, panel2:GetTall() - 30)
            weightLabel2:SizeToContents()

            -- Add quick transfer buttons
            local quickTransfer = vgui.Create("DButton", panel1)
            quickTransfer:SetText("Quick Transfer")
            quickTransfer:SetPos(panel1:GetWide() - 110, panel1:GetTall() - 30)
            quickTransfer:SetSize(100, 25)
            quickTransfer.DoClick = function()
                -- Transfer selected items
                -- Implementation depends on your selection system
            end
        end)
        ```
]]
function AdminStickAddModels(modList, target)
end

--[[
    Purpose:
        Allows adding custom models to the adminstick model selector.

    When Called:
        When the adminstick model selector UI is opened and building the list of available models.

    Parameters:
        modList (table)
            A table containing model entries with 'name' and 'mdl' fields. Add new entries to this table.
        target (Player)
            The player whose model is being changed.

    Returns:
        nil

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a custom model to the adminstick selector
        hook.Add("AdminStickAddModels", "AddCustomModel", function(modList, target)
            table.insert(modList, {
                name = "Custom Model",
                mdl = "models/custom/model.mdl"
            })
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add multiple models with conditional logic
        hook.Add("AdminStickAddModels", "AddAdminModels", function(modList, target)
            -- Only add special models for admins
            if target:hasPrivilege("adminModels") then
                table.insert(modList, {
                    name = "Admin Model",
                    mdl = "models/admin/model.mdl"
                })

                table.insert(modList, {
                    name = "Super Admin Model",
                    mdl = "models/superadmin/model.mdl"
                })
            end

            -- Add seasonal models
            local currentMonth = os.date("*t").month
            if currentMonth == 12 then -- December
                table.insert(modList, {
                    name = "Christmas Model",
                    mdl = "models/christmas/model.mdl"
                })
            end
        end)
        ```
]]
function DoorDataReceived(door, syncData)
end

--[[
    Purpose:
        Called when door data is first received from the server

    When Called:
        When the client receives initial door synchronization data from the server

    Parameters:
        door (Entity) - The door entity that received data
        syncData (table) - The synchronized door data containing all door properties

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door data reception
    hook.Add("DoorDataReceived", "MyAddon", function(door, syncData)
        print("Received data for door: " .. tostring(door))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track door ownership changes
    hook.Add("DoorDataReceived", "TrackDoorOwnership", function(door, syncData)
        if syncData.owner then
            print("Door owned by: " .. tostring(syncData.owner))
        else
            print("Door is unowned")
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door data processing
    hook.Add("DoorDataReceived", "AdvancedDoorProcessing", function(door, syncData)
        -- Store door data for later use
        local doorData = {
            entity = door,
            name = syncData.name or "Door",
            price = syncData.price or 0,
            owner = syncData.owner,
            faction = syncData.faction,
            class = syncData.class,
            receivedAt = CurTime()
        }

        -- Add to custom door registry
        MyAddon.doorRegistry = MyAddon.doorRegistry or {}
        MyAddon.doorRegistry[door:EntIndex()] = doorData

        -- Notify other systems
        hook.Run("OnDoorDataProcessed", door, doorData)

        -- Update UI if door panel is open
        if MyAddon.doorPanel and MyAddon.doorPanel:IsValid() then
            MyAddon.doorPanel:UpdateDoorInfo(doorData)
        end
    end)
    ```
]]
function DoorDataUpdated(door, syncData)
end

--[[
    Purpose:
        Called when existing door data is updated

    When Called:
        When the client receives updated door synchronization data from the server

    Parameters:
        door (Entity) - The door entity whose data was updated
        syncData (table) - The updated synchronized door data

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log door updates
    hook.Add("DoorDataUpdated", "MyAddon", function(door, syncData)
        print("Door data updated: " .. tostring(door))
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Track ownership changes
    hook.Add("DoorDataUpdated", "TrackOwnershipChanges", function(door, syncData)
        local oldOwner = door:getNetVar("owner")
        local newOwner = syncData.owner

        if oldOwner ~= newOwner then
            print("Door ownership changed from " .. tostring(oldOwner) .. " to " .. tostring(newOwner))
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex door update handling
    hook.Add("DoorDataUpdated", "AdvancedDoorUpdates", function(door, syncData)
        -- Get previous data
        local oldData = MyAddon.doorRegistry and MyAddon.doorRegistry[door:EntIndex()] or {}

        -- Compare changes
        local changes = {}
        for key, newValue in pairs(syncData) do
            if oldData[key] ~= newValue then
                changes[key] = {
                    old = oldData[key],
                    new = newValue
                }
            end
        end

        -- Handle specific changes
        if changes.owner then
            hook.Run("OnDoorOwnershipChanged", door, changes.owner.old, changes.owner.new)
        end

        if changes.price then
            hook.Run("OnDoorPriceChanged", door, changes.price.old, changes.price.new)
        end

        -- Update registry
        if MyAddon.doorRegistry then
            MyAddon.doorRegistry[door:EntIndex()] = {
                entity = door,
                name = syncData.name or oldData.name or "Door",
                price = syncData.price or oldData.price or 0,
                owner = syncData.owner,
                faction = syncData.faction,
                class = syncData.class,
                updatedAt = CurTime()
            }
        end

        -- Refresh UI
        if MyAddon.doorPanel and MyAddon.doorPanel:IsValid() then
            MyAddon.doorPanel:RefreshDoorData(door)
        end
    end)
    ```
]]
function VendorFactionBuyScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        Called when a vendor's faction buy scale is updated

    When Called:
        When the client receives updated faction-specific buy pricing from the server

    Parameters:
        vendor (Entity) - The vendor entity whose scale was updated
        factionID (number) - The faction ID for which the scale applies
        scale (number) - The new buy price multiplier (1.0 = normal price, 0.8 = 20% discount, 1.2 = 20% markup)

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log scale updates
    hook.Add("VendorFactionBuyScaleUpdated", "MyAddon", function(vendor, factionID, scale)
        print("Vendor buy scale updated for faction " .. factionID .. ": " .. scale)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update UI displays
    hook.Add("VendorFactionBuyScaleUpdated", "UpdateVendorUI", function(vendor, factionID, scale)
        if MyAddon.vendorPanel and MyAddon.vendorPanel:IsValid() then
            MyAddon.vendorPanel:UpdateBuyPrices(vendor, factionID, scale)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex pricing system
    hook.Add("VendorFactionBuyScaleUpdated", "AdvancedPricing", function(vendor, factionID, scale)
        -- Store scale data
        vendor.factionBuyScales = vendor.factionBuyScales or {}
        vendor.factionBuyScales[factionID] = scale

        -- Get faction name
        local faction = lia.faction.indices[factionID]
        local factionName = faction and faction.name or ("Faction " .. factionID)

        -- Calculate price impact
        local priceChange = (scale - 1.0) * 100
        local changeType = priceChange > 0 and "increase" or "decrease"

        -- Notify player if they're affected
        local client = LocalPlayer()
        local char = client:getChar()
        if char and char:getFaction() == factionID then
            client:ChatPrint(string.format("Buy prices at %s %s by %.1f%%",
                vendor:getName(), changeType, math.abs(priceChange)))
        end

        -- Update cached prices
        if MyAddon.vendorPrices then
            MyAddon.vendorPrices:InvalidateCache(vendor, factionID)
        end

        -- Log for analytics
        lia.log.add("vendor_buy_scale_update", {
            vendor = vendor:getName(),
            faction = factionName,
            oldScale = vendor.factionBuyScales[factionID] or 1.0,
            newScale = scale,
            timestamp = os.time()
        })
    end)
    ```
]]
function VendorFactionSellScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        Called when a vendor's faction sell scale is updated

    When Called:
        When the client receives updated faction-specific sell pricing from the server

    Parameters:
        vendor (Entity) - The vendor entity whose scale was updated
        factionID (number) - The faction ID for which the scale applies
        scale (number) - The new sell price multiplier (1.0 = normal price, 0.8 = 20% less for items sold, 1.2 = 20% more for items sold)

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log scale updates
    hook.Add("VendorFactionSellScaleUpdated", "MyAddon", function(vendor, factionID, scale)
        print("Vendor sell scale updated for faction " .. factionID .. ": " .. scale)
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Update sell price displays
    hook.Add("VendorFactionSellScaleUpdated", "UpdateSellPrices", function(vendor, factionID, scale)
        if MyAddon.vendorPanel and MyAddon.vendorPanel:IsValid() then
            MyAddon.vendorPanel:UpdateSellPrices(vendor, factionID, scale)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Complex sell pricing system
    hook.Add("VendorFactionSellScaleUpdated", "AdvancedSellPricing", function(vendor, factionID, scale)
        -- Store scale data
        vendor.factionSellScales = vendor.factionSellScales or {}
        vendor.factionSellScales[factionID] = scale

        -- Get faction name
        local faction = lia.faction.indices[factionID]
        local factionName = faction and faction.name or ("Faction " .. factionID)

        -- Calculate profit impact
        local profitChange = (scale - 1.0) * 100
        local changeType = profitChange > 0 and "increase" or "decrease"

        -- Notify affected players
        local client = LocalPlayer()
        local char = client:getChar()
        if char and char:getFaction() == factionID then
            client:ChatPrint(string.format("Sell prices at %s %s by %.1f%%",
                vendor:getName(), changeType, math.abs(profitChange)))
        end

        -- Update economic calculations
        if MyAddon.economyTracker then
            MyAddon.economyTracker:UpdateFactionProfitability(factionID, vendor, scale)
        end

        -- Log transaction data
        lia.log.add("vendor_sell_scale_update", {
            vendor = vendor:getName(),
            faction = factionName,
            oldScale = vendor.factionSellScales[factionID] or 1.0,
            newScale = scale,
            timestamp = os.time()
        })
    end)
    ```
]]
function VendorMessagesUpdated(vendor)
end

--[[
    Purpose:
        Called when a vendor's messages are updated

    When Called:
        When the client receives updated vendor message data from the server

    Parameters:
        vendor (Entity) - The vendor entity whose messages were updated

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:

    ```lua
    -- Simple: Log message updates
    hook.Add("VendorMessagesUpdated", "MyAddon", function(vendor)
        print("Vendor messages updated: " .. vendor:getName())
    end)
    ```

    Medium Complexity:

    ```lua
    -- Medium: Refresh vendor UI
    hook.Add("VendorMessagesUpdated", "RefreshVendorUI", function(vendor)
        if MyAddon.vendorPanel and MyAddon.vendorPanel:IsValid() then
            MyAddon.vendorPanel:UpdateMessages(vendor.messages)
        end
    end)
    ```

    High Complexity:

    ```lua
    -- High: Advanced message handling system
    hook.Add("VendorMessagesUpdated", "AdvancedMessageHandling", function(vendor)
        -- Store message history
        local oldMessages = vendor.messages or {}
        local newMessages = vendor.messages or {}

        -- Detect new messages
        local addedMessages = {}
        for key, message in pairs(newMessages) do
            if not oldMessages[key] or oldMessages[key] ~= message then
                table.insert(addedMessages, {
                    key = key,
                    message = message,
                    timestamp = CurTime()
                })
            end
        end

        -- Process message types
        for _, msgData in ipairs(addedMessages) do
            if msgData.key == "greeting" then
                hook.Run("OnVendorGreetingChanged", vendor, msgData.message)
            elseif msgData.key == "farewell" then
                hook.Run("OnVendorFarewellChanged", vendor, msgData.message)
            elseif msgData.key:find("error") then
                hook.Run("OnVendorErrorMessageChanged", vendor, msgData.key, msgData.message)
            end
        end

        -- Update UI components
        if MyAddon.vendorPanel and MyAddon.vendorPanel:IsValid() then
            MyAddon.vendorPanel:UpdateMessages(newMessages)
        end

        -- Notify relevant systems
        if MyAddon.npcSystem then
            MyAddon.npcSystem:OnVendorMessagesUpdated(vendor, addedMessages)
        end

        -- Log message changes
        lia.log.add("vendor_messages_updated", {
            vendor = vendor:getName(),
            messageCount = table.Count(newMessages),
            timestamp = os.time()
        })
    end)
    ```
]]
function OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)
end
