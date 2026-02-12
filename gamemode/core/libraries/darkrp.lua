--[[
    Folder: Libraries
    File: darkrp.md
]]
--[[
    DarkRP

    The DarkRP compatibility library provides essential functions for maintaining compatibility
    with DarkRP-based gamemodes and addons. It includes utility functions for position
    validation, text wrapping, entity creation, chat command handling, and money formatting.
    The library operates primarily on the server side for position and entity management,
    while providing client-side text wrapping functionality. It also handles the conversion
    of Lilia factions to DarkRP team format and provides compatibility wrappers for common
    DarkRP functions. This ensures seamless integration with existing DarkRP content and
    maintains familiar API patterns for developers transitioning from DarkRP to Lilia.
]]
lia.darkrp = lia.darkrp or {}
DarkRP = DarkRP or {}
RPExtraTeams = RPExtraTeams or {}
DarkRP.disabledDefaults = DarkRP.disabledDefaults or {}
if SERVER then
    --[[
    Purpose:
        Determine whether a position is free of solid contents, players, NPCs, or props.

    When Called:
        Before spawning DarkRP-style shipments or entities to ensure the destination is clear.

    Parameters:
        position (Vector)
            World position to test.
        entitiesToIgnore (table|nil)
            Optional list of entities that should be excluded from the collision check.

    Returns:
        boolean
            true when the spot contains no blocking contents or entities; otherwise false.

    Realm:
        Server

    Example Usage:
        ```lua
        local spawnPos = ent:GetPos() + Vector(0, 0, 16)
        if lia.darkrp.isEmpty(spawnPos) then
            lia.darkrp.createEntity("Ammo Crate", {ent = "item_ammo_crate", model = "models/Items/ammocrate_smg1.mdl"})
        end
        ```
    ]]
    function lia.darkrp.isEmpty(position, entitiesToIgnore)
        entitiesToIgnore = entitiesToIgnore or {}
        local contents = util.PointContents(position)
        local isClear = contents ~= CONTENTS_SOLID and contents ~= CONTENTS_MOVEABLE and contents ~= CONTENTS_LADDER and contents ~= CONTENTS_PLAYERCLIP and contents ~= CONTENTS_MONSTERCLIP
        if not isClear then return false end
        local isEmpty = true
        for _, entity in ipairs(ents.FindInSphere(position, 35)) do
            if (entity:IsNPC() or entity:IsPlayer() or entity:isProp() or entity.NotEmptyPos) and not table.HasValue(entitiesToIgnore, entity) then
                isEmpty = false
                break
            end
        end
        return isClear and isEmpty
    end

    --[[
    Purpose:
        Locate the nearest empty position around a starting point within a search radius.

    When Called:
        Selecting safe fallback positions for DarkRP-style shipments or NPC spawns.

    Parameters:
        startPos (Vector)
            Origin position to test first.
        entitiesToIgnore (table|nil)
            Optional list of entities to ignore while searching.
        maxDistance (number)
            Maximum distance to search away from the origin.
        searchStep (number)
            Increment used when expanding the search radius.
        checkArea (Vector)
            Additional offset tested to ensure enough clearance (for hull height, etc.).

    Returns:
        Vector
            First empty position discovered; if none found, returns startPos.

    Realm:
        Server

    Example Usage:
        ```lua
        local spawnPos = lia.darkrp.findEmptyPos(requestPos, nil, 256, 16, Vector(0, 0, 32))
        npc:SetPos(spawnPos)
        ```
    ]]
    function lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)
        if lia.darkrp.isEmpty(startPos, entitiesToIgnore) and lia.darkrp.isEmpty(startPos + checkArea, entitiesToIgnore) then return startPos end
        for distance = searchStep, maxDistance, searchStep do
            for direction = -1, 1, 2 do
                local offset = distance * direction
                if lia.darkrp.isEmpty(startPos + Vector(offset, 0, 0), entitiesToIgnore) and lia.darkrp.isEmpty(startPos + Vector(offset, 0, 0) + checkArea, entitiesToIgnore) then return startPos + Vector(offset, 0, 0) end
                if lia.darkrp.isEmpty(startPos + Vector(0, offset, 0), entitiesToIgnore) and lia.darkrp.isEmpty(startPos + Vector(0, offset, 0) + checkArea, entitiesToIgnore) then return startPos + Vector(0, offset, 0) end
                if lia.darkrp.isEmpty(startPos + Vector(0, 0, offset), entitiesToIgnore) and lia.darkrp.isEmpty(startPos + Vector(0, 0, offset) + checkArea, entitiesToIgnore) then return startPos + Vector(0, 0, offset) end
            end
        end
        return startPos
    end

    --[[
    Purpose:
        Provide a DarkRP-compatible wrapper for Lilia's localized notify system.

    When Called:
        From DarkRP addons or compatibility code that expects DarkRP.notify to exist.

    Parameters:
        client (Player)
            Recipient of the notification.
        notifyType (number)
            Unused legacy parameter kept for API parity.
        duration (number)
            Unused legacy parameter kept for API parity.
        message (string)
            Localization key or message to pass to Lilia's notifier.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.darkrp.notify(ply, NOTIFY_GENERIC, 4, "You received a paycheck.")
        ```
    ]]
    function lia.darkrp.notify(client, notifyType, duration, message)
        client:notifyInfoLocalized(message)
    end
else
    local function wrapCharacters(text, remainingWidth, maxWidth)
        local accumulatedWidth = 0
        text = text:gsub(".", function(char)
            accumulatedWidth = accumulatedWidth + surface.GetTextSize(char)
            if accumulatedWidth >= remainingWidth then
                accumulatedWidth = surface.GetTextSize(char)
                remainingWidth = maxWidth
                return "\n" .. char
            end
            return char
        end)
        return text, accumulatedWidth
    end

    --[[
    Purpose:
        Wrap long text to a maximum line width based on the active surface font metrics.

    When Called:
        Preparing DarkRP-compatible messages for HUD or chat rendering without overflow.

    Parameters:
        text (string)
            Message to wrap.
        fontName (string)
            Name of the font to measure.
        maxLineWidth (number)
            Maximum pixel width allowed per line before inserting a newline.

    Returns:
        string
            Wrapped text with newline characters inserted.

    Realm:
        Client

    Example Usage:
        ```lua
        local wrapped = lia.darkrp.textWrap("A very long notice message...", "DermaDefault", 240)
        chat.AddText(color_white, wrapped)
        ```
    ]]
    function lia.darkrp.textWrap(text, fontName, maxLineWidth)
        local accumulatedWidth = 0
        surface.SetFont(fontName)
        local spaceWidth = surface.GetTextSize(" ")
        text = text:gsub("(%s?[%S]+)", function(word)
            local firstChar = string.sub(word, 1, 1)
            if firstChar == "\n" or firstChar == "\t" then accumulatedWidth = 0 end
            local wordWidth = surface.GetTextSize(word)
            accumulatedWidth = accumulatedWidth + wordWidth
            if wordWidth >= maxLineWidth then
                local wrappedWord, finalWidth = wrapCharacters(word, maxLineWidth - (accumulatedWidth - wordWidth), maxLineWidth)
                accumulatedWidth = finalWidth
                return wrappedWord
            elseif accumulatedWidth < maxLineWidth then
                return word
            end

            if firstChar == " " then
                accumulatedWidth = wordWidth - spaceWidth
                return "\n" .. string.sub(word, 2)
            end

            accumulatedWidth = wordWidth
            return "\n" .. word
        end)
        return text
    end
end

--[[
    Purpose:
        Format a currency amount using Lilia's currency system while matching DarkRP's API.

    When Called:
        Anywhere DarkRP.formatMoney is expected by compatibility layers or addons.

    Parameters:
        amount (number)
            Currency amount to format.

    Returns:
        string
            Localized and formatted currency string.

    Realm:
        Shared

    Example Usage:
        ```lua
        local paycheck = DarkRP.formatMoney(500)
        chat.AddText(L("paydayReceived", paycheck))
        ```
]]
function lia.darkrp.formatMoney(amount)
    return lia.currency.get(amount)
end

--[[
    Purpose:
        Register a DarkRP entity definition as a Lilia item for compatibility.

    When Called:
        While converting DarkRP shipments or entities into Lilia items at load time.

    Parameters:
        name (string)
            Display name for the item.
        data (table)
            Supported fields: cmd, ent, model, desc, price, category.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.darkrp.createEntity("Ammo Crate", {
            ent = "item_ammo_crate",
            model = "models/Items/ammocrate_smg1.mdl",
            price = 750,
            category = "Supplies"
        })
        ```
]]
function lia.darkrp.createEntity(name, data)
    local cmd = data.cmd or string.lower(name)
    local ITEM = lia.item.register(cmd, "base_entities", nil, nil, true)
    ITEM.name = name
    ITEM.model = data.model or ""
    ITEM.desc = data.desc or ""
    ITEM.category = data.category or L("entities")
    ITEM.entityid = data.ent or ""
    ITEM.price = data.price or 0
    lia.information(L("generatedDarkRPItem", name))
end

--[[
    Purpose:
        Provide an API stub for DarkRP category creation.

    When Called:
        Invoked by DarkRP.createCategory during addon initialization; intentionally no-op.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        ```lua
        -- API parity only; this function performs no actions.
        lia.darkrp.createCategory()
        ```
]]
function lia.darkrp.createCategory()
end

--[[
    Purpose:
        Placeholder to mirror DarkRP's removeChatCommand; retained for API compatibility.

    When Called:
        Invoked by addons expecting DarkRP.removeChatCommand to exist; does nothing.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Compatibility stub; no removal is performed.
        DarkRP.removeChatCommand("ooc")
        ```
]]
function DarkRP.removeChatCommand()
end

--[[
    Purpose:
        Register a DarkRP-style chat command using Lilia's command system.

    When Called:
        During addon or gamemode initialization to expose chat commands expected by DarkRP.

    Parameters:
        cmd (string)
            Chat command name without the leading slash.
        callback (function)
            Function invoked as callback(client, ...args); may return a string for error text.

    Realm:
        Shared

    Example Usage:
        ```lua
        DarkRP.defineChatCommand("dropmoney", function(client, amount)
            -- Custom logic here
        end)
        ```
]]
function DarkRP.defineChatCommand(cmd, callback)
    cmd = string.lower(cmd)
    lia.command.add(cmd, {
        onRun = function(client, args)
            local success, result = pcall(callback, client, unpack(args))
            if not success then return end
            if isstring(result) and result ~= "" then client:notifyErrorLocalized(result) end
            return result
        end
    })
end

--[[
    Purpose:
        Register a privileged DarkRP-style chat command that checks a required privilege.

    When Called:
        During addon or gamemode initialization for commands that need permission checks.

    Parameters:
        cmd (string)
            Chat command name without the leading slash.
        priv (string)
            Lilia privilege string required to run the command.
        callback (function)
            Function invoked as callback(client, ...args); may return a string for error text.

    Realm:
        Shared

    Example Usage:
        ```lua
        DarkRP.definePrivilegedChatCommand("givelicense", "ManageLicenses", function(client, target)
            -- Custom logic here
        end)
        ```
]]
function DarkRP.definePrivilegedChatCommand(cmd, priv, callback)
    cmd = string.lower(cmd)
    lia.command.add(cmd, {
        privilege = priv,
        onRun = function(client, args)
            local success, result = pcall(callback, client, unpack(args))
            if not success then return end
            if isstring(result) and result ~= "" then client:notifyErrorLocalized(result) end
            return result
        end
    })
end

local DarkRPVariables = {
    ["DarkRPNonOwnable"] = function(entity) entity:setNetVar("noSell", true) end,
    ["DarkRPTitle"] = function(entity, val) entity:setNetVar("name", val) end,
    ["DarkRPCanLockpick"] = function(entity, val) entity.noPick = tobool(val) end
}

DarkRP.createCategory = lia.darkrp.createCategory
DarkRP.createEntity = lia.darkrp.createEntity
DarkRP.formatMoney = lia.darkrp.formatMoney
DarkRP.isEmpty = lia.darkrp.isEmpty
DarkRP.findEmptyPos = lia.darkrp.findEmptyPos
DarkRP.notify = lia.darkrp.notify
DarkRP.textWrap = lia.darkrp.textWrap
hook.Add("EntityKeyValue", "liaDarkRPEntityKeyValue", function(entity, key, value) if entity:isDoor() and DarkRPVariables[key] then DarkRPVariables[key](entity, value) end end)
hook.Add("InitializedModules", "liaDarkRPModules", function()
    for index, faction in ipairs(lia.faction.indices) do
        RPExtraTeams[index] = faction
        RPExtraTeams[index].team = index
    end
end)
