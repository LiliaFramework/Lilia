--[[
# DarkRP Library

This page documents the functions for working with DarkRP compatibility and utilities.

---

## Overview

The DarkRP library provides utilities for DarkRP compatibility and integration within the Lilia framework. It handles DarkRP-specific functions, entity spawning utilities, and provides compatibility layers for DarkRP addons and systems. The library includes utilities for finding empty positions, entity management, and other DarkRP-related functionality.
]]
lia.darkrp = lia.darkrp or {}
DarkRP = DarkRP or {}
RPExtraTeams = RPExtraTeams or {}
DarkRP.disabledDefaults = DarkRP.disabledDefaults or {}
if SERVER then
    --[[
        lia.darkrp.isEmpty

        Purpose:
            Checks if a given position in the world is empty, i.e., not occupied by solid contents, players, NPCs, props, or other blocking entities.
            Optionally ignores a list of entities.

        Parameters:
            position (Vector)           - The position to check for emptiness.
            entitiesToIgnore (table)    - (Optional) Table of entities to ignore during the check.

        Returns:
            boolean - True if the position is empty, false otherwise.

        Realm:
            Server.

        Example Usage:
            local pos = Vector(100, 200, 300)
            if lia.darkrp.isEmpty(pos) then
                print("Position is empty!")
            end

            -- Ignore a specific entity
            local ignoreEnt = Entity(1)
            if lia.darkrp.isEmpty(pos, {ignoreEnt}) then
                print("Position is empty, ignoring entity 1.")
            end
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
        lia.darkrp.findEmptyPos

        Purpose:
            Finds an empty position near a starting point, searching in a grid pattern up to a maximum distance.
            Useful for spawning entities without collisions.

        Parameters:
            startPos (Vector)           - The starting position to search from.
            entitiesToIgnore (table)    - (Optional) Table of entities to ignore during the check.
            maxDistance (number)        - The maximum distance to search from the starting point.
            searchStep (number)         - The step size for each search iteration.
            checkArea (Vector)          - The area offset to check for additional clearance.

        Returns:
            Vector - The found empty position, or the original startPos if none found.

        Realm:
            Server.

        Example Usage:
            local spawnPos = lia.darkrp.findEmptyPos(Vector(0,0,0), nil, 100, 10, Vector(0,0,40))
            if spawnPos then
                print("Found empty position at:", spawnPos)
            end
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
        lia.darkrp.notify

        Purpose:
            Sends a localized notification message to a client.

        Parameters:
            client (Player)     - The player to notify.
            _ (unused)          - Unused parameter for compatibility.
            _ (unused)          - Unused parameter for compatibility.
            message (string)    - The message key to localize and send.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            lia.darkrp.notify(player.GetByID(1), nil, nil, "jobChanged")
            -- Sends the localized "jobChanged" message to the first player.
    ]]
    function lia.darkrp.notify(client, _, _, message)
        client:notifyLocalized(message)
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
        lia.darkrp.textWrap

        Purpose:
            Wraps a string of text to fit within a specified maximum line width, using the given font.
            Handles word and character wrapping for long words.

        Parameters:
            text (string)           - The text to wrap.
            fontName (string)       - The font to use for measuring text width.
            maxLineWidth (number)   - The maximum width of each line in pixels.

        Returns:
            string - The wrapped text with newline characters inserted.

        Realm:
            Client.

        Example Usage:
            local wrapped = lia.darkrp.textWrap("This is a very long sentence that needs to be wrapped.", "DermaDefault", 200)
            print(wrapped)
    ]]
    function lia.darkrp.textWrap(text, fontName, maxLineWidth)
        local accumulatedWidth = 0
        surface.SetFont(fontName)
        local spaceWidth = surface.GetTextSize(' ')
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

            if firstChar == ' ' then
                accumulatedWidth = wordWidth - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            accumulatedWidth = wordWidth
            return '\n' .. word
        end)
        return text
    end
end

for index, faction in ipairs(lia.faction.indices) do
    RPExtraTeams[index] = faction
    RPExtraTeams[index].team = index
end

--[[
    lia.darkrp.formatMoney

    Purpose:
        Formats a numeric amount as a currency string using the configured currency symbol and names.

    Parameters:
        amount (number)   - The amount of money to format.

    Returns:
        string - The formatted currency string (e.g., "$100 Dollars").

    Realm:
        Shared.

    Example Usage:
        local moneyString = lia.darkrp.formatMoney(150)
        print(moneyString) -- "$150 Dollars" (depending on config)
]]
function lia.darkrp.formatMoney(amount)
    return lia.currency.get(amount)
end

--[[
    lia.darkrp.createEntity

    Purpose:
        Registers a new entity as an item in the Lilia system, using the provided data.
        Useful for integrating DarkRP entities as usable items.

    Parameters:
        name (string)     - The display name of the entity.
        data (table)      - Table containing entity data (cmd, model, desc, category, ent, price).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        lia.darkrp.createEntity("Money Printer", {
            cmd = "money_printer",
            model = "models/props_c17/consolebox01a.mdl",
            desc = "A device that prints money.",
            category = "Entities",
            ent = "money_printer",
            price = 2500
        })
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
    lia.darkrp.createCategory

    Purpose:
        Placeholder for creating a new category in the DarkRP system.
        (Currently does nothing.)

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- This function is a stub and does not perform any action.
        lia.darkrp.createCategory()
]]
function lia.darkrp.createCategory()
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