--[[
    lia.util.FindPlayersInBox

    Purpose:
        Finds all valid player entities within a specified axis-aligned box.

    Parameters:
        mins (Vector) - The minimum corner of the box.
        maxs (Vector) - The maximum corner of the box.

    Returns:
        table - A table of player entities found within the box.

    Realm:
        Shared.

    Example Usage:
        local players = lia.util.FindPlayersInBox(Vector(0,0,0), Vector(100,100,100))
        for _, ply in ipairs(players) do
            print(ply:Nick())
        end
]]
function lia.util.FindPlayersInBox(mins, maxs)
    local entsList = ents.FindInBox(mins, maxs)
    local plyList = {}
    for _, v in pairs(entsList) do
        if IsValid(v) and v:IsPlayer() then plyList[#plyList + 1] = v end
    end
    return plyList
end

--[[
    lia.util.getBySteamID

    Purpose:
        Finds a player by their SteamID or SteamID64 string, only if they have a character.

    Parameters:
        steamID (string) - The SteamID or SteamID64 of the player.

    Returns:
        Player or nil - The player entity if found and has a character, otherwise none.

    Realm:
        Shared.

    Example Usage:
        local ply = lia.util.getBySteamID("STEAM_0:1:123456")
        if ply then
            print("Found player:", ply:Nick())
        end
]]
function lia.util.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    local sid = steamID
    if steamID:match("^%d+$") and #steamID >= 17 then sid = util.SteamIDFrom64(steamID) end
    for _, client in player.Iterator() do
        if client:SteamID() == sid and client:getChar() then return client end
    end
end

--[[
    lia.util.FindPlayersInSphere

    Purpose:
        Finds all players within a given radius of a point.

    Parameters:
        origin (Vector) - The center point of the sphere.
        radius (number) - The radius to search within.

    Returns:
        table - A table of player entities found within the sphere.

    Realm:
        Shared.

    Example Usage:
        local players = lia.util.FindPlayersInSphere(Vector(0,0,0), 256)
        for _, ply in ipairs(players) do
            print(ply:Nick())
        end
]]
function lia.util.FindPlayersInSphere(origin, radius)
    local plys = {}
    local r2 = radius ^ 2
    for _, client in player.Iterator() do
        if client:GetPos():DistToSqr(origin) <= r2 then plys[#plys + 1] = client end
    end
    return plys
end

--[[
    lia.util.findPlayer

    Purpose:
        Finds a player based on a string identifier, which can be a name, SteamID, SteamID64, or special symbol.
        Notifies the client if the player is not found.

    Parameters:
        client (Player)      - The player requesting the search (for notifications).
        identifier (string)  - The identifier to search for.

    Returns:
        Player or nil - The found player entity, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local ply = lia.util.findPlayer(client, "STEAM_0:1:123456")
        if ply then
            print("Found player:", ply:Nick())
        end
]]
function lia.util.findPlayer(client, identifier)
    local isValidClient = IsValid(client)
    if not isstring(identifier) or identifier == "" then
        if isValidClient then client:notifyLocalized("mustProvideString") end
        return nil
    end

    if string.match(identifier, "^STEAM_%d+:%d+:%d+$") then
        local ply = lia.util.getBySteamID(identifier)
        if IsValid(ply) then return ply end
        if isValidClient then client:notifyLocalized("plyNoExist") end
        return nil
    end

    if string.match(identifier, "^%d+$") and #identifier >= 17 then
        local sid = util.SteamIDFrom64(identifier)
        if sid then
            local ply = lia.util.getBySteamID(sid)
            if IsValid(ply) then return ply end
        end

        if isValidClient then client:notifyLocalized("plyNoExist") end
        return nil
    end

    if isValidClient and identifier == "^" then return client end
    if isValidClient and identifier == "@" then
        local trace = client:getTracedEntity()
        if IsValid(trace) and trace:IsPlayer() then return trace end
        client:notifyLocalized("lookToUseAt")
        return nil
    end

    local safe = string.PatternSafe(identifier)
    for _, ply in player.Iterator() do
        if lia.util.stringMatches(ply:Name(), safe) then return ply end
    end

    if isValidClient then client:notifyLocalized("plyNoExist") end
    return nil
end

--[[
    lia.util.findPlayerItems

    Purpose:
        Finds all item entities created by the specified player.

    Parameters:
        client (Player) - The player whose items to find.

    Returns:
        table - A table of item entities created by the player.

    Realm:
        Shared.

    Example Usage:
        local items = lia.util.findPlayerItems(client)
        for _, item in ipairs(items) do
            print(item:GetClass())
        end
]]
function lia.util.findPlayerItems(client)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client then table.insert(items, item) end
    end
    return items
end

--[[
    lia.util.findPlayerItemsByClass

    Purpose:
        Finds all item entities of a specific class created by the specified player.

    Parameters:
        client (Player) - The player whose items to find.
        class (string)  - The class (item ID) to filter by.

    Returns:
        table - A table of item entities matching the class and player.

    Realm:
        Shared.

    Example Usage:
        local medkits = lia.util.findPlayerItemsByClass(client, "medkit")
        for _, item in ipairs(medkits) do
            print(item:GetClass())
        end
]]
function lia.util.findPlayerItemsByClass(client, class)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client and item:getNetVar("id") == class then table.insert(items, item) end
    end
    return items
end

--[[
    lia.util.findPlayerEntities

    Purpose:
        Finds all entities of a given class created by or associated with the specified player.

    Parameters:
        client (Player) - The player whose entities to find.
        class (string or nil) - The class to filter by (optional).

    Returns:
        table - A table of entities matching the criteria.

    Realm:
        Shared.

    Example Usage:
        local ents = lia.util.findPlayerEntities(client, "prop_physics")
        for _, ent in ipairs(ents) do
            print(ent:GetClass())
        end
]]
function lia.util.findPlayerEntities(client, class)
    local entities = {}
    for _, entity in ents.Iterator() do
        if IsValid(entity) and (not class or entity:GetClass() == class) and (entity:GetCreator() == client or entity.client and entity.client == client) then table.insert(entities, entity) end
    end
    return entities
end

--[[
    lia.util.stringMatches

    Purpose:
        Checks if two strings match, case-insensitively and as substrings.

    Parameters:
        a (string) - The first string.
        b (string) - The second string.

    Returns:
        boolean - True if the strings match or one contains the other, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if lia.util.stringMatches("John Doe", "john") then
            print("Match found!")
        end
]]
function lia.util.stringMatches(a, b)
    if a and b then
        local a2, b2 = a:lower(), b:lower()
        if a == b then return true end
        if a2 == b2 then return true end
        if a:find(b) then return true end
        if a2:find(b2) then return true end
    end
    return false
end

--[[
    lia.util.getAdmins

    Purpose:
        Returns a table of all players who are considered staff (admins).

    Parameters:
        None.

    Returns:
        table - A table of player entities who are staff.

    Realm:
        Shared.

    Example Usage:
        local admins = lia.util.getAdmins()
        for _, admin in ipairs(admins) do
            print(admin:Nick())
        end
]]
function lia.util.getAdmins()
    local staff = {}
    for _, client in player.Iterator() do
        local hasPermission = client:isStaff()
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

--[[
    lia.util.findPlayerBySteamID64

    Purpose:
        Finds a player by their SteamID64.

    Parameters:
        SteamID64 (string) - The SteamID64 of the player.

    Returns:
        Player or nil - The player entity if found, otherwise none.

    Realm:
        Shared.

    Example Usage:
        local ply = lia.util.findPlayerBySteamID64("76561198000000000")
        if ply then
            print("Found player:", ply:Nick())
        end
]]
function lia.util.findPlayerBySteamID64(SteamID64)
    local SteamID = util.SteamIDFrom64(SteamID64)
    if not SteamID then return nil end
    return lia.util.findPlayerBySteamID(SteamID)
end

--[[
    lia.util.findPlayerBySteamID

    Purpose:
        Finds a player by their SteamID.

    Parameters:
        SteamID (string) - The SteamID of the player.

    Returns:
        Player or nil - The player entity if found, otherwise none.

    Realm:
        Shared.

    Example Usage:
        local ply = lia.util.findPlayerBySteamID("STEAM_0:1:123456")
        if ply then
            print("Found player:", ply:Nick())
        end
]]
function lia.util.findPlayerBySteamID(SteamID)
    for _, client in player.Iterator() do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

--[[
    lia.util.canFit

    Purpose:
        Checks if a hull of given size can fit at a position without colliding with the world or other objects.

    Parameters:
        pos (Vector)         - The position to check.
        mins (Vector)        - The minimum bounds of the hull (optional, defaults to Vector(16, 16, 0)).
        maxs (Vector)        - The maximum bounds of the hull (optional, defaults to mins).
        filter (Entity/table) - Entities to ignore in the trace (optional).

    Returns:
        boolean - True if the hull can fit, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if lia.util.canFit(Vector(0,0,0)) then
            print("Space is clear!")
        end
]]
function lia.util.canFit(pos, mins, maxs, filter)
    mins = mins ~= nil and mins or Vector(16, 16, 0)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 1),
        mask = MASK_PLAYERSOLID,
        filter = filter,
        endpos = pos,
        mins = mins.x > 0 and mins * -1 or mins,
        maxs = maxs ~= nil and maxs or mins
    })
    return not tr.Hit
end

--[[
    lia.util.playerInRadius

    Purpose:
        Returns all valid players within a certain radius of a position.

    Parameters:
        pos (Vector) - The center position.
        dist (number) - The radius to search (units).

    Returns:
        table - A table of player entities within the radius.

    Realm:
        Shared.

    Example Usage:
        local players = lia.util.playerInRadius(Vector(0,0,0), 128)
        for _, ply in ipairs(players) do
            print(ply:Nick())
        end
]]
function lia.util.playerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, client in player.Iterator() do
        if IsValid(client) and client:GetPos():DistToSqr(pos) < dist then t[#t + 1] = client end
    end
    return t
end

--[[
    lia.util.formatStringNamed

    Purpose:
        Formats a string using named or positional arguments, replacing {name} or {1}, {2}, etc.

    Parameters:
        format (string) - The format string containing placeholders.
        ...             - Arguments as a table (named) or as a list (positional).

    Returns:
        string - The formatted string.

    Realm:
        Shared.

    Example Usage:
        local str = lia.util.formatStringNamed("Hello, {name}!", {name = "John"})
        print(str) -- "Hello, John!"
]]
function lia.util.formatStringNamed(format, ...)
    local arguments = {...}
    local bArray = false
    local input
    if istable(arguments[1]) then
        input = arguments[1]
    else
        input = arguments
        bArray = true
    end

    local i = 0
    local result = format:gsub("{(%w-)}", function(word)
        i = i + 1
        return tostring(bArray and input[i] or input[word] or word)
    end)
    return result
end

--[[
    lia.util.getMaterial

    Purpose:
        Returns a cached Material object for the given path and parameters, creating it if necessary.

    Parameters:
        materialPath (string)        - The path to the material.
        materialParameters (string)  - Optional parameters for the material.

    Returns:
        IMaterial - The Material object.

    Realm:
        Client.

    Example Usage:
        local mat = lia.util.getMaterial("icon16/user.png")
        surface.SetMaterial(mat)
]]
function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

--[[
    lia.util.findFaction

    Purpose:
        Finds a faction by name or uniqueID, notifies the client if not found.

    Parameters:
        client (Player) - The player requesting the search (for notifications).
        name (string)   - The name or uniqueID of the faction.

    Returns:
        table or nil - The faction table if found, otherwise none.

    Realm:
        Shared.

    Example Usage:
        local faction = lia.util.findFaction(client, "overwatch")
        if faction then
            print("Faction found:", faction.name)
        end
]]
function lia.util.findFaction(client, name)
    if lia.faction.teams[name] then return lia.faction.teams[name] end
    for _, v in ipairs(lia.faction.indices) do
        if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(v.uniqueID, name) then return v end
    end

    client:notifyLocalized("invalidFaction")
    return nil
end

if system.IsLinux() then
    local cache = {}
    local function GetSoundPath(path, gamedir)
        if not gamedir then
            path = "sound/" .. path
            gamedir = "GAME"
        end
        return path, gamedir
    end

    local function f_IsWAV(f)
        f:Seek(8)
        return f:Read(4) == "WAVE"
    end

    local function f_SampleDepth(f)
        f:Seek(34)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_SampleRate(f)
        f:Seek(24)
        local bytes = {}
        for i = 1, 4 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[4], 24) + bit.lshift(bytes[3], 16) + bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Channels(f)
        f:Seek(22)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Duration(f)
        return (f:Size() - 44) / (f_SampleDepth(f) / 8 * f_SampleRate(f) * f_Channels(f))
    end

    liaSoundDuration = liaSoundDuration or SoundDuration
    function SoundDuration(str)
        local path, gamedir = GetSoundPath(str)
        local f = file.Open(path, "rb", gamedir)
        if not f then return 0 end
        local ret
        if cache[str] then
            ret = cache[str]
        elseif f_IsWAV(f) then
            ret = f_Duration(f)
        else
            ret = liaSoundDuration(str)
        end

        f:Close()
        return ret
    end
end

if SERVER then
    --[[
        lia.util.SendTableUI

        Purpose:
            Sends a table UI to a client for display, including title, columns, data, and options using the big table transfer system.

        Parameters:
            client (Player)      - The player to send the UI to.
            title (string)       - The title of the table.
            columns (table)      - The columns to display.
            data (table)         - The data rows to display.
            options (table)      - Optional actions for each row.
            characterID (number) - Optional character ID for context.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            lia.util.SendTableUI(client, "Player List", columns, data, options, charID)
    ]]
    function lia.util.SendTableUI(client, title, columns, data, options, characterID)
        if not IsValid(client) or not client:IsPlayer() then return end
        local localizedColumns = {}
        for i, colInfo in ipairs(columns or {}) do
            local localizedColInfo = table.Copy(colInfo)
            if localizedColInfo.name then localizedColInfo.name = L(localizedColInfo.name) end
            localizedColumns[i] = localizedColInfo
        end

        local tableUIData = {
            title = title and L(title) or L("tableListTitle"),
            columns = localizedColumns,
            data = data,
            options = options or {},
            characterID = characterID
        }

        lia.net.writeBigTable(client, "SendTableUI", tableUIData)
    end

    --[[
        lia.util.findEmptySpace

        Purpose:
            Finds empty positions around an entity where a hull of given size can fit, useful for spawning items or players.

        Parameters:
            entity (Entity)      - The entity to search around.
            filter (Entity/table) - Entities to ignore in the trace (optional).
            spacing (number)     - The distance between each check (optional, default 32).
            size (number)        - The number of positions to check in each direction (optional, default 3).
            height (number)      - The height of the hull (optional, default 36).
            tolerance (number)   - The Z offset for the trace (optional, default 5).

        Returns:
            table - A sorted table of valid positions (Vector) around the entity.

        Realm:
            Server.

        Example Usage:
            local positions = lia.util.findEmptySpace(ent)
            for _, pos in ipairs(positions) do
                print(pos)
            end
    ]]
    function lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)
        spacing = spacing or 32
        size = size or 3
        height = height or 36
        tolerance = tolerance or 5
        local position = entity:GetPos()
        local mins = Vector(-spacing * 0.5, -spacing * 0.5, 0)
        local maxs = Vector(spacing * 0.5, spacing * 0.5, height)
        local output = {}
        for x = -size, size do
            for y = -size, size do
                local origin = position + Vector(x * spacing, y * spacing, 0)
                local data = {}
                data.start = origin + mins + Vector(0, 0, tolerance)
                data.endpos = origin + maxs
                data.filter = filter or entity
                local trace = util.TraceLine(data)
                data.start = origin + Vector(-maxs.x, -maxs.y, tolerance)
                data.endpos = origin + Vector(mins.x, mins.y, height)
                local trace2 = util.TraceLine(data)
                if trace.StartSolid or trace.Hit or trace2.StartSolid or trace2.Hit or not util.IsInWorld(origin) then continue end
                output[#output + 1] = origin
            end
        end

        table.sort(output, function(a, b) return a:Distance(position) < b:Distance(position) end)
        return output
    end
else
    --[[
        lia.util.ShadowText

        Purpose:
            Draws text with a shadow at the specified position.

        Parameters:
            text (string)        - The text to draw.
            font (string)        - The font to use.
            x (number)           - The X position.
            y (number)           - The Y position.
            colortext (Color)    - The color of the text.
            colorshadow (Color)  - The color of the shadow.
            dist (number)        - The distance to offset the shadow.
            xalign (number)      - The horizontal alignment.
            yalign (number)      - The vertical alignment.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.ShadowText("Hello", "DermaDefault", 100, 100, color_white, color_black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    ]]
    function lia.util.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
        surface.SetFont(font)
        local _, h = surface.GetTextSize(text)
        if yalign == TEXT_ALIGN_CENTER then
            y = y - h / 2
        elseif yalign == TEXT_ALIGN_BOTTOM then
            y = y - h
        end

        draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
        draw.DrawText(text, font, x, y, colortext, xalign)
    end

    --[[
        lia.util.DrawTextOutlined

        Purpose:
            Draws text with an outline at the specified position.

        Parameters:
            text (string)         - The text to draw.
            font (string)         - The font to use.
            x (number)            - The X position.
            y (number)            - The Y position.
            colour (Color)        - The color of the text.
            xalign (number)       - The horizontal alignment.
            outlinewidth (number) - The width of the outline.
            outlinecolour (Color) - The color of the outline.

        Returns:
            number - The width of the drawn text.

        Realm:
            Client.

        Example Usage:
            lia.util.DrawTextOutlined("Outlined", "DermaDefault", 100, 100, color_white, TEXT_ALIGN_LEFT, 2, color_black)
    ]]
    function lia.util.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
        local steps = (outlinewidth * 2) / 3
        if steps < 1 then steps = 1 end
        for ox = -outlinewidth, outlinewidth, steps do
            for oy = -outlinewidth, outlinewidth, steps do
                draw.DrawText(text, font, x + ox, y + oy, outlinecolour, xalign)
            end
        end
        return draw.DrawText(text, font, x, y, colour, xalign)
    end

    --[[
        lia.util.DrawTip

        Purpose:
            Draws a tooltip-like tip box with a triangle pointer and text.

        Parameters:
            x (number)         - The X position.
            y (number)         - The Y position.
            w (number)         - The width of the tip.
            h (number)         - The height of the tip.
            text (string)      - The text to display.
            font (string)      - The font to use.
            textCol (Color)    - The color of the text.
            outlineCol (Color) - The color of the outline.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.DrawTip(100, 100, 200, 50, "Tip!", "DermaDefault", color_white, color_black)
    ]]
    function lia.util.DrawTip(x, y, w, h, text, font, textCol, outlineCol)
        draw.NoTexture()
        local rectH = 0.85
        local triW = 0.1
        local verts = {
            {
                x = x,
                y = y
            },
            {
                x = x + w,
                y = y
            },
            {
                x = x + w,
                y = y + h * rectH
            },
            {
                x = x + w / 2 + w * triW,
                y = y + h * rectH
            },
            {
                x = x + w / 2,
                y = y + h
            },
            {
                x = x + w / 2 - w * triW,
                y = y + h * rectH
            },
            {
                x = x,
                y = y + h * rectH
            }
        }

        surface.SetDrawColor(outlineCol)
        surface.DrawPoly(verts)
        draw.SimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    --[[
        lia.util.drawText

        Purpose:
            Draws text with a shadow at the specified position using draw.TextShadow.

        Parameters:
            text (string)      - The text to draw.
            x (number)         - The X position.
            y (number)         - The Y position.
            color (Color)      - The color of the text (optional, defaults to white).
            alignX (number)    - The horizontal alignment (optional).
            alignY (number)    - The vertical alignment (optional).
            font (string)      - The font to use (optional, defaults to "liaGenericFont").
            alpha (number)     - The alpha value for the shadow (optional).

        Returns:
            number - The width of the drawn text.

        Realm:
            Client.

        Example Usage:
            lia.util.drawText("Hello", 100, 100, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    ]]
    function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
        color = color or color_white
        return draw.TextShadow({
            text = text,
            font = font or "liaGenericFont",
            pos = {x, y},
            color = color,
            xalign = alignX or 0,
            yalign = alignY or 0
        }, 1, alpha or color.a * 0.575)
    end

    --[[
        lia.util.drawTexture

        Purpose:
            Draws a textured rectangle using a cached material.

        Parameters:
            material (string)   - The path to the material.
            color (Color)       - The color to draw with (optional, defaults to white).
            x (number)          - The X position.
            y (number)          - The Y position.
            w (number)          - The width.
            h (number)          - The height.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.drawTexture("icon16/user.png", color_white, 100, 100, 16, 16)
    ]]
    function lia.util.drawTexture(material, color, x, y, w, h)
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(lia.util.getMaterial(material))
        surface.DrawTexturedRect(x, y, w, h)
    end

    --[[
        lia.util.skinFunc

        Purpose:
            Calls a skin function for a panel, if it exists.

        Parameters:
            name (string)      - The name of the skin function.
            panel (Panel)      - The panel to pass to the skin function.
            a, b, c, d, e, f, g - Additional arguments to pass.

        Returns:
            any - The return value of the skin function, or nil if not found.

        Realm:
            Client.

        Example Usage:
            lia.util.skinFunc("Paint", panel, w, h)
    ]]
    function lia.util.skinFunc(name, panel, a, b, c, d, e, f, g)
        local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
        if not skin then return end
        local func = skin[name]
        if not func then return end
        return func(skin, panel, a, b, c, d, e, f, g)
    end

    --[[
        lia.util.wrapText

        Purpose:
            Wraps a string of text to fit within a specified width, using the given font.

        Parameters:
            text (string)   - The text to wrap.
            width (number)  - The maximum width in pixels.
            font (string)   - The font to use (optional, defaults to "liaChatFont").

        Returns:
            table, number - A table of wrapped lines and the maximum width.

        Realm:
            Client.

        Example Usage:
            local lines, maxW = lia.util.wrapText("This is a long message.", 200)
            for _, line in ipairs(lines) do
                print(line)
            end
    ]]
    function lia.util.wrapText(text, width, font)
        font = font or "liaChatFont"
        surface.SetFont(font)
        local exploded = string.Explode("%s", text, true)
        local line = ""
        local lines = {}
        local w = surface.GetTextSize(text)
        local maxW = 0
        if w <= width then
            text, _ = text:gsub("%s", " ")
            return {text}, w
        end

        for i = 1, #exploded do
            local word = exploded[i]
            line = line .. " " .. word
            w = surface.GetTextSize(line)
            if w > width then
                lines[#lines + 1] = line
                line = ""
                if w > maxW then maxW = w end
            end
        end

        if line ~= "" then lines[#lines + 1] = line end
        return lines, maxW
    end

    --[[
        lia.util.drawBlur

        Purpose:
            Draws a blur effect over the specified panel.

        Parameters:
            panel (Panel)    - The panel to blur.
            amount (number)  - The blur amount (optional, default 5).
            passes (number)  - The number of passes (optional, default 0.2).
            alpha (number)   - The alpha value (optional, default 255).

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.drawBlur(panel, 5, 1, 200)
    ]]
    function lia.util.drawBlur(panel, amount, passes, alpha)
        amount = amount or 5
        alpha = alpha or 255
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x, y = panel:LocalToScreen(0, 0)
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    --[[
        lia.util.drawBlurAt

        Purpose:
            Draws a blur effect over a specified rectangle on the screen.

        Parameters:
            x (number)       - The X position.
            y (number)       - The Y position.
            w (number)       - The width.
            h (number)       - The height.
            amount (number)  - The blur amount (optional, default 5).
            passes (number)  - The number of passes (optional, default 0.2).
            alpha (number)   - The alpha value (optional, default 255).

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.drawBlurAt(100, 100, 200, 100, 5, 1, 200)
    ]]
    function lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)
        amount = amount or 5
        alpha = alpha or 255
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x2, y2 = x / ScrW(), y / ScrH()
        local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
        end
    end

    --[[
        lia.util.requestArguments

        Purpose:
            Opens a UI to request multiple arguments from the user, supporting strings, numbers, booleans, and dropdowns.

        Parameters:
            title (string)         - The title of the UI.
            argTypes (table)       - A table describing the argument types and names.
            onSubmit (function)    - Callback function called with the result table.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            lia.util.requestArguments("Enter Info", {Name="string", Age="int"}, function(result) PrintTable(result) end)
    ]]
    function lia.util.requestArguments(title, argTypes, onSubmit)
        local count = table.Count(argTypes)
        local frameW, frameH = 600, 200 + count * 75
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            derma.SkinHook("Paint", "Frame", self, w, h)
            draw.SimpleText(title or "", "liaMediumFont", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
        end

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 40, 10, 10)
        surface.SetFont("liaSmallFont")
        local controls, watchers = {}, {}
        local validate
        local ordered = {}
        local grouped = {
            strings = {},
            dropdowns = {},
            bools = {},
            rest = {}
        }

        for name, typeInfo in pairs(argTypes) do
            local fieldType, dataTbl = typeInfo, nil
            if istable(typeInfo) then fieldType, dataTbl = typeInfo[1], typeInfo[2] end
            fieldType = string.lower(tostring(fieldType))
            local info = {
                name = name,
                fieldType = fieldType,
                dataTbl = dataTbl
            }

            if fieldType == "string" then
                table.insert(grouped.strings, info)
            elseif fieldType == "table" then
                table.insert(grouped.dropdowns, info)
            elseif fieldType == "boolean" then
                table.insert(grouped.bools, info)
            else
                table.insert(grouped.rest, info)
            end
        end

        for _, group in ipairs({grouped.strings, grouped.dropdowns, grouped.bools, grouped.rest}) do
            for _, v in ipairs(group) do
                table.insert(ordered, v)
            end
        end

        for _, info in ipairs(ordered) do
            local name, fieldType, dataTbl = info.name, info.fieldType, info.dataTbl
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetTall(70)
            panel.Paint = nil
            local label = vgui.Create("DLabel", panel)
            label:SetFont("liaSmallFont")
            label:SetText(name)
            label:SizeToContents()
            local textW = select(1, surface.GetTextSize(name))
            local ctrl
            local isBool = fieldType == "boolean"
            if isBool then
                ctrl = vgui.Create("liaCheckBox", panel)
            elseif fieldType == "table" then
                ctrl = vgui.Create("DComboBox", panel)
                if istable(dataTbl) then
                    for _, v in ipairs(dataTbl) do
                        if istable(v) then
                            ctrl:AddChoice(v[1], v[2])
                        else
                            ctrl:AddChoice(tostring(v))
                        end
                    end
                end
            elseif fieldType == "int" or fieldType == "number" then
                ctrl = vgui.Create("DTextEntry", panel)
                ctrl:SetFont("liaSmallFont")
                if ctrl.SetNumeric then ctrl:SetNumeric(true) end
            else
                ctrl = vgui.Create("DTextEntry", panel)
                ctrl:SetFont("liaSmallFont")
            end

            panel.PerformLayout = function(_, w, h)
                local ctrlH, ctrlW
                if isBool then
                    ctrlH, ctrlW = 22, 22
                else
                    ctrlH, ctrlW = 30, w * 0.7
                end

                local totalW = textW + 10 + ctrlW
                local xOff = (w - totalW) / 2
                label:SetPos(xOff, (h - label:GetTall()) / 2)
                ctrl:SetPos(xOff + textW + 10, (h - ctrlH) / 2)
                ctrl:SetSize(ctrlW, ctrlH)
            end

            controls[name] = {
                ctrl = ctrl,
                type = fieldType
            }

            watchers[#watchers + 1] = function()
                local function trigger()
                    validate()
                end

                ctrl.OnValueChange, ctrl.OnTextChanged, ctrl.OnChange, ctrl.OnSelect = trigger, trigger, trigger, trigger
            end
        end

        local btnPanel = vgui.Create("DPanel", frame)
        btnPanel:Dock(BOTTOM)
        btnPanel:SetTall(90)
        btnPanel:DockPadding(15, 15, 15, 15)
        btnPanel.Paint = nil
        local submit = vgui.Create("DButton", btnPanel)
        submit:Dock(LEFT)
        submit:DockMargin(0, 0, 15, 0)
        submit:SetWide(270)
        submit:SetText(L("submit"))
        submit:SetFont("liaSmallFont")
        submit:SetIcon("icon16/tick.png")
        submit:SetEnabled(false)
        local cancel = vgui.Create("DButton", btnPanel)
        cancel:Dock(RIGHT)
        cancel:SetWide(270)
        cancel:SetText(L("cancel"))
        cancel:SetFont("liaSmallFont")
        cancel:SetIcon("icon16/cross.png")
        cancel.DoClick = function() frame:Remove() end
        validate = function()
            for _, data in pairs(controls) do
                local ctl, ftype, ok = data.ctrl, data.type, true
                if ftype == "boolean" then
                    ok = true
                elseif ctl.GetSelected then
                    local txt = select(1, ctl:GetSelected())
                    ok = txt and txt ~= ""
                elseif ctl.GetValue then
                    local val = ctl:GetValue()
                    ok = val and val ~= ""
                end

                if not ok then
                    submit:SetEnabled(false)
                    return
                end
            end

            submit:SetEnabled(true)
        end

        for _, fn in ipairs(watchers) do
            fn()
        end

        validate()
        submit.DoClick = function()
            local result = {}
            for k, data in pairs(controls) do
                local ctl, ftype = data.ctrl, data.type
                if ftype == "boolean" then
                    result[k] = ctl:GetChecked()
                elseif ctl.GetSelected then
                    local txt, val = ctl:GetSelected()
                    result[k] = val or txt
                else
                    local val = ctl:GetValue()
                    result[k] = (ftype == "int" or ftype == "number") and tonumber(val) or val
                end
            end

            if isfunction(onSubmit) then onSubmit(result) end
            frame:Remove()
        end
    end

    --[[
        lia.util.CreateTableUI

        Purpose:
            Creates and displays a table UI frame with columns, data, and row options for the client.

        Parameters:
            title (string)      - The title of the table.
            columns (table)     - The columns to display.
            data (table)        - The data rows to display.
            options (table)     - Optional actions for each row.
            charID (number)     - Optional character ID for context.

        Returns:
            Panel, DListView - The frame and the list view created.

        Realm:
            Client.

        Example Usage:
            local frame, listView = lia.util.CreateTableUI("Player List", columns, data, options, charID)
    ]]
    function lia.util.CreateTableUI(title, columns, data, options, charID)
        local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title and L(title) or L("tableListTitle"))
        frame:SetSize(frameWidth, frameHeight)
        frame:Center()
        frame:MakePopup()
        local listView = vgui.Create("DListView", frame)
        listView:Dock(FILL)
        for _, colInfo in ipairs(columns or {}) do
            local localizedName = colInfo.name and L(colInfo.name) or L("na")
            local col = listView:AddColumn(localizedName)
            surface.SetFont(col.Header:GetFont())
            local textW = surface.GetTextSize(localizedName)
            local minWidth = textW + 16
            col:SetMinWidth(minWidth)
            col:SetWidth(colInfo.width or minWidth)
        end

        for _, row in ipairs(data) do
            local lineData = {}
            for _, colInfo in ipairs(columns) do
                table.insert(lineData, row[colInfo.field] or L("na"))
            end

            local line = listView:AddLine(unpack(lineData))
            line.rowData = row
        end

        listView.OnRowRightClick = function(_, _, line)
            if not IsValid(line) or not line.rowData then return end
            local rowData = line.rowData
            local menu = DermaMenu()
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for key, value in pairs(rowData) do
                    value = tostring(value or L("na"))
                    rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
                end

                rowString = rowString:sub(1, -4)
                SetClipboardText(rowString)
            end)

            for _, option in ipairs(istable(options) and options or {}) do
                menu:AddOption(option.name and L(option.name) or option.name, function()
                    if not option.net then return end
                    if option.ExtraFields then
                        local inputPanel = vgui.Create("DFrame")
                        inputPanel:SetTitle(L("optionsTitle", option.name))
                        inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                        inputPanel:Center()
                        inputPanel:MakePopup()
                        local form = vgui.Create("DForm", inputPanel)
                        form:Dock(FILL)
                        form:SetLabel("")
                        form.Paint = function() end
                        local inputs = {}
                        for fName, fType in pairs(option.ExtraFields) do
                            local label = vgui.Create("DLabel", form)
                            label:SetText(fName)
                            label:Dock(TOP)
                            label:DockMargin(5, 10, 5, 0)
                            form:AddItem(label)
                            if isstring(fType) and fType == "text" then
                                local entry = vgui.Create("DTextEntry", form)
                                entry:Dock(TOP)
                                entry:DockMargin(5, 5, 5, 0)
                                entry:SetPlaceholderText(L("typeFieldPrompt", fName))
                                form:AddItem(entry)
                                inputs[fName] = {
                                    panel = entry,
                                    ftype = "text"
                                }
                            elseif isstring(fType) and fType == "combo" then
                                local combo = vgui.Create("DComboBox", form)
                                combo:Dock(TOP)
                                combo:DockMargin(5, 5, 5, 0)
                                combo:SetValue(L("selectPrompt", fName))
                                form:AddItem(combo)
                                inputs[fName] = {
                                    panel = combo,
                                    ftype = "combo"
                                }
                            elseif istable(fType) then
                                local combo = vgui.Create("DComboBox", form)
                                combo:Dock(TOP)
                                combo:DockMargin(5, 5, 5, 0)
                                combo:SetValue(L("selectPrompt", fName))
                                for _, choice in ipairs(fType) do
                                    combo:AddChoice(choice)
                                end

                                form:AddItem(combo)
                                inputs[fName] = {
                                    panel = combo,
                                    ftype = "combo"
                                }
                            end
                        end

                        local submitButton = vgui.Create("DButton", form)
                        submitButton:SetText(L("submit"))
                        submitButton:Dock(TOP)
                        submitButton:DockMargin(5, 10, 5, 0)
                        form:AddItem(submitButton)
                        submitButton.DoClick = function()
                            local values = {}
                            for fName, info in pairs(inputs) do
                                if not IsValid(info.panel) then continue end
                                if info.ftype == "text" then
                                    values[fName] = info.panel:GetValue() or ""
                                elseif info.ftype == "combo" then
                                    values[fName] = info.panel:GetSelected() or ""
                                end
                            end

                            net.Start(option.net)
                            net.WriteInt(charID, 32)
                            net.WriteTable(rowData)
                            for _, fVal in pairs(values) do
                                if isnumber(fVal) then
                                    net.WriteInt(fVal, 32)
                                else
                                    net.WriteString(fVal)
                                end
                            end

                            net.SendToServer()
                            inputPanel:Close()
                            frame:Remove()
                        end
                    else
                        net.Start(option.net)
                        net.WriteInt(charID, 32)
                        net.WriteTable(rowData)
                        net.SendToServer()
                        frame:Remove()
                    end
                end)
            end

            menu:Open()
        end
        return frame, listView
    end
end