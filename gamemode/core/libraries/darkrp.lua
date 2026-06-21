--[[
    Folder: Developer - Libraries
    File: lia.darkrp.md
]]
--[[
    DarkRP

    DarkRP compatibility helpers for Lilia, including spawn position checks, DarkRP-style notifications, currency formatting, entity item generation, command registration adapters, door keyvalue handling, and RPExtraTeams synchronization.
]]
--[[
    Overview:
        The DarkRP compatibility library provides shim functions and tables expected by DarkRP-style addons while routing supported behavior through Lilia systems. It exposes `lia.darkrp` helpers for empty-position checks, text wrapping, notifications, currency formatting, entity item registration, and category compatibility, then maps selected helpers onto the global `DarkRP` table for addon compatibility.
]]
--[[
    Hooks:
        EntityKeyValue(Entity entity, string key, string value)

    Purpose:
        Applies supported DarkRP door keyvalues to Lilia door data when map entities receive key-value pairs.

    Parameters:
        entity (Entity)
            The entity receiving the keyvalue.

        key (string)
            The keyvalue name being applied.

        value (string)
            The keyvalue value being applied.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        InitializedModules()

    Purpose:
        Copies Lilia faction indices into `RPExtraTeams` and assigns each copied faction its DarkRP-compatible team index.

    Returns:
        nil

    Realm:
        Shared
]]
lia.darkrp = lia.darkrp or {}
DarkRP = DarkRP or {}
RPExtraTeams = RPExtraTeams or {}
DarkRP.disabledDefaults = DarkRP.disabledDefaults or {}
if SERVER then
    --[[
    Purpose:
        Checks whether a position is clear of solid contents and nearby blocking entities.

    Parameters:
        position (Vector)
            The world position to check.

        entitiesToIgnore (table|nil)
            Optional list of entities that should not cause the position to be considered occupied.

    Returns:
        boolean
            True if the position is clear, false otherwise.

    Example Usage:
        ```lua
        local position = lia.darkrp.isEmpty(client:GetPos(), {client})
        print(position)
        ```

    Realm:
        Server
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
        Finds the nearest clear position around a starting point by checking offsets along each axis.

    Parameters:
        startPos (Vector)
            The preferred world position.

        entitiesToIgnore (table|nil)
            Optional list of entities ignored by the occupancy checks.

        maxDistance (number)
            The maximum distance from the starting position to search.

        searchStep (number)
            The distance increment used while searching outward.

        checkArea (Vector)
            Additional offset checked from each candidate position to confirm clearance.

    Returns:
        Vector
            The first clear position found, or the starting position if no clear offset is found.

    Example Usage:
        ```lua
        local position = lia.darkrp.findEmptyPos(client:GetPos(), {client}, 600, 30, Vector(0, 0, 72))
        client:SetPos(position)
        ```

    Realm:
        Server
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
        Sends a DarkRP-compatible notification through Lilia's localized notification system.

    Parameters:
        client (Player)
            The player receiving the notification.

        notifyType (number|string|nil)
            DarkRP notification type value accepted for compatibility but not used by this shim.

        duration (number|nil)
            DarkRP notification duration accepted for compatibility but not used by this shim.

        message (string)
            The localization key or message passed to the notification system.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.darkrp.notify(client, 0, 4, "someLocalizationKey")
        ```

    Realm:
        Server
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
        Wraps text to fit within a maximum pixel width using Garry's Mod surface font measurements.

    Parameters:
        text (string)
            The text to wrap.

        fontName (string)
            The surface font used to measure the text.

        maxLineWidth (number)
            The maximum line width in pixels.

    Returns:
        string
            The wrapped text with newline breaks inserted where needed.

    Example Usage:
        ```lua
        local text = lia.darkrp.textWrap("Long text", "DermaDefault", 200)
        print(text)
        ```

    Realm:
        Client
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
        Formats a numeric amount using Lilia's configured currency formatter.

    Parameters:
        amount (number)
            The amount of money to format.

    Returns:
        string
            The formatted currency string.

    Example Usage:
        ```lua
        client:notifyInfo(lia.darkrp.formatMoney(250))
        print(lia.darkrp.formatMoney(1))
        ```

    Realm:
        Shared
]]
function lia.darkrp.formatMoney(amount)
    return lia.currency.get(amount)
end

--[[
    Purpose:
        Registers a DarkRP-style entity definition as a Lilia item using the `base_entities` item base.

    Parameters:
        name (string)
            The display name of the entity item.

        data (table)
            Entity definition data.

        data.cmd (string|nil)
            Optional item unique ID. Defaults to the lowercase entity name.

        data.model (string|nil)
            Optional item model path.

        data.desc (string|nil)
            Optional item description.

        data.category (string|nil)
            Optional item category. Defaults to the localized entities category.

        data.ent (string|nil)
            Optional entity class stored on the generated item.

        data.price (number|nil)
            Optional item price.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.darkrp.createEntity("Money Printer", {
            ent = "money_printer",
            model = "models/props_c17/consolebox01a.mdl",
            price = 500
        })
        ```

    Realm:
        Shared
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
        Provides a no-op DarkRP category compatibility function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.darkrp.createCategory()
        ```

    Realm:
        Shared
]]
function lia.darkrp.createCategory()
end

function DarkRP.removeChatCommand()
end

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