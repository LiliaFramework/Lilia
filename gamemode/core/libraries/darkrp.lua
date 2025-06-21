DarkRP = DarkRP or {}
RPExtraTeams = RPExtraTeams or {}
lia.darkrp = lia.darkrp or {}
if SERVER then
    --[[
        lia.darkrp.isEmpty(position, entitiesToIgnore)

        Description:
            Checks whether the specified position is free from players, NPCs,
            and props.

        Parameters:
            position (Vector) – World position to test.
            entitiesToIgnore (table) – Entities ignored during the check.

        Realm:
            Server

        Returns:
            boolean – True if the position is clear, false otherwise.
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
        lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)

        Description:
            Finds a nearby position that is unobstructed by players or props.

        Parameters:
            startPos (Vector) – The initial position to search from.
            entitiesToIgnore (table) – Entities ignored during the search.
            maxDistance (number) – Maximum distance to search in units.
            searchStep (number) – Step increment when expanding the search radius.
            checkArea (Vector) – Additional offset tested for clearance.

        Realm:
            Server

        Returns:
            Vector – A position considered safe for spawning.
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
        lia.darkrp.notify(client, _, _, message)

        Description:
            Forwards a notification message to the given client using
            lia's notify system.

        Parameters:
            client (Player) – The player to receive the message.
            _ – Unused parameter maintained for compatibility.
            _ – Unused parameter maintained for compatibility.
            message (string) – Text of the notification.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.darkrp.notify(client, _, _, message)
        client:notify(message)
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
        lia.darkrp.textWrap(text, fontName, maxLineWidth)

        Description:
            Wraps a text string so that it fits within the specified width
            when drawn with the given font.

        Parameters:
            text (string) – The text to wrap.
            fontName (string) – The font used to measure width.
            maxLineWidth (number) – Maximum pixel width before wrapping occurs.

        Realm:
            Client

        Returns:
            string – The wrapped text with newline characters inserted.
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
    lia.darkrp.formatMoney(amount)

    Description:
        Converts a numeric amount to a formatted currency string.

    Parameters:
        amount (number) – The value of money to format.

    Realm:
        Shared

    Returns:
        string – The formatted currency value.
]]
function lia.darkrp.formatMoney(amount)
    return lia.currency.get(amount)
end

--[[
    lia.darkrp.createEntity(name, data)

    Description:
        Registers a new DarkRP entity as an item so that it can be spawned
        through lia's item system.

    Parameters:
        name (string) – Display name of the entity.
        data (table) – Table containing entity definition fields such as
        model, description, and price.

    Realm:
        Shared

    Returns:
        None
]]
function lia.darkrp.createEntity(name, data)
    local cmd = data.cmd or string.lower(name)
    local ITEM = lia.item.register(cmd, "base_entities", nil, nil, true)
    ITEM.name = name
    ITEM.model = data.model or ""
    ITEM.desc = data.desc or ""
    ITEM.category = data.category or "Entities"
    ITEM.entityid = data.ent or ""
    ITEM.price = data.price or 0
    lia.information("Generated DarkRP entity as item " .. name)
end

--[[
    lia.darkrp.createCategory()

    Description:
        Placeholder for DarkRP category creation. Currently unused.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
function lia.darkrp.createCategory()
end

DarkRP.createCategory = lia.darkrp.createCategory
DarkRP.createEntity = lia.darkrp.createEntity
DarkRP.formatMoney = lia.darkrp.formatMoney
DarkRP.isEmpty = lia.darkrp.isEmpty
DarkRP.findEmptyPos = lia.darkrp.findEmptyPos
DarkRP.notify = lia.darkrp.notify
DarkRP.textWrap = lia.darkrp.textWrap
