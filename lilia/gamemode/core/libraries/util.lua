--- Various useful helper functions.
-- @library lia.util

--- Finds all players within a box defined by minimum and maximum coordinates.
-- @realm client
-- @vector mins The minimum corner of the box
-- @vector maxs The maximum corner of the box
-- @return table A list of players within the box
function lia.util.FindPlayersInBox(mins, maxs)
    local entsList = ents.FindInBox(mins, maxs)
    local plyList = {}
    for _, v in pairs(entsList) do
        if IsValid(v) and v:IsPlayer() then plyList[#plyList + 1] = v end
    end
    return plyList
end

--- Finds all players within a sphere defined by an origin point and radius.
-- @realm client
-- @vector origin The center point of the sphere
-- @int radius The radius of the sphere
-- @return table A list of players within the sphere
function lia.util.FindPlayersInSphere(origin, radius)
    local plys = {}
    local r2 = radius ^ 2
    for _, client in player.Iterator() do
        if client:GetPos():DistToSqr(origin) <= r2 then plys[#plys + 1] = client end
    end
    return plys
end

--- Attempts to find a player by matching their name or Steam ID.
-- @realm shared
-- @string identifier Search query
-- @bool[opt=false] allowPatterns Whether or not to accept Lua patterns in `identifier`
-- @treturn player Player that matches the given search query - this will be `nil` if a player could not be found
function lia.util.findPlayer(identifier, allowPatterns)
    if string.match(identifier, "STEAM_(%d+):(%d+):(%d+)") then return player.GetBySteamID(identifier) end
    if not allowPatterns then identifier = string.PatternSafe(identifier) end
    for _, v in player.Iterator() do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

--- Finds items owned by a specified player.
-- @realm shared
-- @client client The player whose items are being searched for.
-- @treturn table A table containing all items owned by the given player.
function lia.util.findPlayerItems(client)
    local items = {}
    for _, item in pairs(ents.GetAll()) do
        if not item:isItem() then continue end
        if item:GetCreator() == client then table.insert(items, item) end
    end
    return items
end

--- Finds items of a specific class owned by a specified player.
-- @realm shared
-- @client client The player whose items are being searched for.
-- @string class The class of the items being searched for.
-- @treturn table A table containing all items of the specified class owned by the given player.
function lia.util.findPlayerItemsByClass(client, class)
    local items = {}
    for _, item in pairs(ents.GetAll()) do
        if not item:isItem() then continue end
        if item:GetCreator() == client and item:getNetVar("id") == class then table.insert(items, item) end
    end
    return items
end

--- Finds all entities of a specific class owned by a specified player.
--- If no class is specified, finds all entities owned by the player.
-- @realm shared
-- @client client The player whose entities are being searched for.
-- @string[opt] class The class of the entities being searched for. If not provided, all entities owned by the player are returned.
-- @treturn table A table containing all entities of the specified class (or all entities if no class is specified) owned by the given player.
function lia.util.findPlayerEntities(client, class)
    local items = {}
    for _, entity in pairs(ents.GetAll()) do
        if (not class or entity:GetClass() == class) and (entity:GetCreator() == client or (entity.client and (entity.client == client))) then table.insert(items, entity) end
    end
    return items
end

--- Checks to see if two strings are equivalent using a fuzzy manner. Both strings will be lowered, and will return `true` if
-- the strings are identical, or if `b` is a substring of `a`.
-- @realm shared
-- @string a First string to check
-- @string b Second string to check
-- @treturn bool Whether or not the strings are equivalent
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

--- Retrieves all online players with administrative permissions.
-- @treturn table Table containing all online players with administrative permissions
-- @realm shared
function lia.util.getAdmins()
    local staff = {}
    for _, client in player.Iterator() do
        local hasPermission = client:isStaff()
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

--- Finds a player by their SteamID64.
-- @string SteamID64 The SteamID64 of the player to find
-- @treturn Player The player object if found, nil otherwise
-- @realm shared
function lia.util.findPlayerBySteamID64(SteamID64)
    for _, client in player.Iterator() do
        if client:SteamID64() == SteamID64 then return client end
    end
    return nil
end

--- Finds a player by their SteamID.
-- @string SteamID The SteamID of the player to find
-- @treturn Player The player object if found, nil otherwise
-- @realm shared
function lia.util.findPlayerBySteamID(SteamID)
    for _, client in player.Iterator() do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

--- Checks if a position can fit a player's collision hull.
-- @vector pos The position to check
-- @vector[opt] mins The minimum size of the collision hull
-- @vector[opt] maxs The maximum size of the collision hull
-- @tab[opt] filter Entities to filter out from the collision check
-- @treturn bool True if the position can fit the collision hull, false otherwise
-- @realm shared
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

--- Retrieves all players within a certain radius from a given position.
-- @vector pos The center position
-- @int dist The maximum distance from the center
-- @treturn table Table containing players within the specified radius
-- @realm shared
function lia.util.playerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, client in player.Iterator() do
        if IsValid(client) and client:GetPos():DistToSqr(pos) < dist then t[#t + 1] = client end
    end
    return t
end

-- Returns a string that has the named arguments in the format string replaced with the given arguments.
-- @realm shared
-- @string format Format string
-- @tparam tab|... Arguments to pass to the formatted string. If passed a table, it will use that table as the lookup table for
-- the named arguments. If passed multiple arguments, it will replace the arguments in the string in order.
-- @usage print(lia.util.formatStringNamed("Hi, my name is {name}.", {name = "Bobby"}))
-- > Hi, my name is Bobby.
-- @usage print(lia.util.formatStringNamed("Hi, my name is {name}.", "Bobby"))
-- > Hi, my name is Bobby.
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
        return tostring((bArray and input[i] or input[word]) or word)
    end)
    return result
end

--- Returns a cached copy of the given material, or creates and caches one if it doesn't exist. This is a quick helper function.
-- if you aren't locally storing a `Material()` call.
-- @realm shared
-- @string materialPath Path to the material
-- @string[opt] materialParameters
-- @treturn[1] material The cached material
-- @treturn[2] nil If the material doesn't exist in the filesystem
function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

if SERVER then
    --- Sends a request to the client to display a table UI.
    -- @realm server
    -- @client client The player to whom the UI should be sent.
    -- @string title The title of the table UI.
    -- @tab columns A table defining the columns in the table. Each entry should be a table with fields `name`, `field`, and `width`. The `name` is the column header, `field` is the key used to retrieve the value from the row data, and `width` is the width of the column in pixels.
    -- @tab data A table containing rows of data. Each row is a table with keys corresponding to the `field` values defined in the `columns` table. Each key should have a value to be displayed in the respective column.
    -- @int[opt] frameWidth The width of the frame. Default is 900.
    -- @int[opt] frameHeight The height of the frame. Default is 600.
    -- @usage
    -- local columns = {
    --     {name = "ID", field = "id", width = 50},
    --     {name = "Name", field = "name", width = 150},
    -- }
    -- local data = {
    --     {id = 1, name = "Player1"},
    --     {id = 2, name = "Player2"}
    -- }
    -- lia.util.CreateTableUI(player, "Player List", columns, data)
    function lia.util.CreateTableUI(client, title, columns, data, frameWidth, frameHeight)
        if not IsValid(client) or not client:IsPlayer() then return end
        net.Start("CreateTableUI")
        net.WriteString(title or "Table List")
        net.WriteTable(columns)
        net.WriteTable(data)
        net.WriteUInt(frameWidth or 900, 16)
        net.WriteUInt(frameHeight or 600, 16)
        net.Send(client)
    end

    --- Finds empty spaces around an entity where another entity can be placed.
    -- @realm server
    -- @client entity The client to find empty spaces around
    -- @tab[opt] filter Entities to filter out from the collision check
    -- @int spacing Spacing between empty spaces (default is 32 units)
    -- @int size Size of the search grid (default is 3)
    -- @int height Height of the search grid (default is 36 units)
    -- @int tolerance Tolerance for collision checking (default is 5 units)
    -- @return Table containing positions of empty spaces
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
                local origin = position + Vecr(x * spacing, y * spacing, 0)
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
    --- Draws text with a shadow effect.
    -- @realm client
    -- @string text The text to draw
    -- @string font The font to use
    -- @int x The x-coordinate to draw the text at
    -- @int y The y-coordinate to draw the text at
    -- @color colortext The color of the text
    -- @color colorshadow The color of the shadow
    -- @int dist The distance of the shadow from the text
    -- @param xalign Horizontal alignment of the text (e.g., TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
    -- @param yalign Vertical alignment of the text (e.g., TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
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

    --- Draws text with an outline.
    -- @realm client
    -- @string text The text to draw
    -- @string font The font to use
    -- @int x The x-coordinate to draw the text at
    -- @int y The y-coordinate to draw the text at
    -- @color colour The color of the text
    -- @param xalign Horizontal alignment of the text (e.g., TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
    -- @int outlinewidth The width of the outline
    -- @color outlinecolour The color of the outline
    function lia.util.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
        local steps = (outlinewidth * 2) / 3
        if steps < 1 then steps = 1 end
        for _x = -outlinewidth, outlinewidth, steps do
            for _y = -outlinewidth, outlinewidth, steps do
                draw.DrawText(text, font, x + _x, y + _y, outlinecolour, xalign)
            end
        end
        return draw.DrawText(text, font, x, y, colour, xalign)
    end

    --- Draws a tip box with text.
    -- @realm client
    -- @int x The x-coordinate of the top-left corner
    -- @int y The y-coordinate of the top-left corner
    -- @int w The width of the tip box
    -- @int h The height of the tip box
    -- @string text The text to display inside the tip box
    -- @string font The font to use
    -- @color textCol The color of the text
    -- @color outlineCol The color of the outline
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
                y = y + (h * rectH)
            },
            {
                x = x + (w / 2) + (w * triW),
                y = y + (h * rectH)
            },
            {
                x = x + (w / 2),
                y = y + h
            },
            {
                x = x + (w / 2) - (w * triW),
                y = y + (h * rectH)
            },
            {
                x = x,
                y = y + (h * rectH)
            }
        }

        surface.SetDrawColor(outlineCol)
        surface.DrawPoly(verts)
        draw.SimpleText(text, font, x + (w / 2), y + (h / 2), textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    --- Draws some text with a shadow.
    -- @realm client
    -- @string text Text to draw
    -- @float x X-position of the text
    -- @float y Y-position of the text
    -- @color color Color of the text to draw
    -- @int[opt=TEXT_ALIGN_LEFT] alignX Horizontal alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @int[opt=TEXT_ALIGN_LEFT] alignY Vertical alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @string[opt="liaGenericFont"] font Font to use for the text
    -- @int[opt=color.a * 0.575] alpha Alpha of the shadow
    function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
        color = color or color_white
        return draw.TextShadow({
            text = text,
            font = font or "liaGenericFont",
            pos = {x, y},
            color = color,
            xalign = alignX or 0,
            yalign = alignY or 0
        }, 1, alpha or (color.a * 0.575))
    end

    --- Draws a textured rectangle with a specified material and color.
    -- @realm client
    -- @string material Material to use for the texture
    -- @color color Color of the texture to draw
    -- @int x X-position of the top-left corner of the rectangle
    -- @int y Y-position of the top-left corner of the rectangle
    -- @int w Width of the rectangle
    -- @int h Height of the rectangle
    function lia.util.drawTexture(material, color, x, y, w, h)
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(lia.util.getMaterial(material))
        surface.DrawTexturedRect(x, y, w, h)
    end

    --- Calls a named skin function with optional arguments on a panel.
    -- @realm client
    -- @string name Name of the skin function to call
    -- @panel[opt] panel Panel to apply the skin function to
    -- @param[opt] a Argument 1
    -- @param[opt] b Argument 2
    -- @param[opt] c Argument 3
    -- @param[opt] d Argument 4
    -- @param[opt] e Argument 5
    -- @param[opt] f Argument 6
    -- @param[opt] g Argument 7
    -- @return The result of the skin function call
    function lia.util.skinFunc(name, panel, a, b, c, d, e, f, g)
        local skin = (ispanel(panel) and IsValid(panel)) and panel:GetSkin() or derma.GetDefaultSkin()
        if not skin then return end
        local func = skin[name]
        if not func then return end
        return func(skin, panel, a, b, c, d, e, f, g)
    end

    --- Wraps text so it does not pass a certain width. This function will try and break lines between words if it can,
    -- otherwise it will break a word if it's too long.
    -- @realm client
    -- @string text Text to wrap
    -- @int width Maximum allowed width in pixels
    -- @string[opt="liaChatFont"] font Font to use for the text
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

    --- Blurs the content underneath the given panel. This will fall back to a simple darkened rectangle if the player has
    -- blurring disabled.
    -- @realm client
    -- @panel panel Panel to draw the blur for
    -- @float[opt=5] amount Intensity of the blur. This should be kept between 0 and 10 for performance reasons
    -- @float[opt=0.2] passes Quality of the blur. This should be kept as default
    -- @usage function PANEL:Paint(width, height)
    -- 	lia.util.drawBlur(self)
    -- end
    function lia.util.drawBlur(panel, amount, passes)
        amount = amount or 5
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255)
        local x, y = panel:LocalToScreen(0, 0)
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    --- Draws a blurred rectangle with the given position and bounds. This shouldn't be used for panels, see `lia.util.drawBlur`
    -- instead.
    -- @realm client
    -- @float x X-position of the rectangle
    -- @float y Y-position of the rectangle
    -- @float w Width of the rectangle
    -- @float h Height of the rectangle
    -- @float[opt=5] amount Intensity of the blur. This should be kept between 0 and 10 for performance reasons
    -- @float[opt=0.2] passes Quality of the blur. This should be kept as default
    -- @usage hook.Add("HUDPaint", "MyHUDPaint", function()
    -- 	lia.util.drawBlurAt(0, 0, ScrW(), ScrH())
    -- end)
    function lia.util.drawBlurAt(x, y, w, h, amount, passes)
        amount = amount or 5
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255)
        local scrW, scrH = ScrW(), ScrH()
        local x2, y2 = x / scrW, y / scrH
        local w2, h2 = (x + w) / scrW, (y + h) / scrH
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
        end
    end

    --- Displays a query notification panel with options.
    -- @realm client
    -- @string question The question or prompt to display
    -- @string option1 The text for the first option
    -- @string option2 The text for the second option
    -- @bool manualDismiss If true, the panel requires manual dismissal
    -- @int notifType The type of notification
    -- @func callback The function to call when an option is selected, with the option index and the notice panel as arguments
    -- @return The created notification panel
    function lia.util.notifQuery(question, option1, option2, manualDismiss, notifType, callback)
        if not callback or not isfunction(callback) then Error("A callback function must be specified") end
        if not question or not isstring(question) then Error("A question string must be specified") end
        if not option1 then option1 = "Yes" end
        if not option2 then option2 = "No" end
        if not manualDismiss then manualDismiss = false end
        local notice = CreateNoticePanel(10, manualDismiss)
        local i = table.insert(lia.notices, notice)
        notice.isQuery = true
        notice.text:SetText(question)
        notice:SetPos(0, (i - 1) * (notice:GetTall() + 4) + 4)
        notice:SetTall(36 * 2.3)
        notice:CalcWidth(120)
        notice:CenterHorizontal()
        notice.notifType = notifType or 7
        if manualDismiss then notice.start = nil end
        notice.opt1 = notice:Add("DButton")
        notice.opt1:SetAlpha(0)
        notice.opt2 = notice:Add("DButton")
        notice.opt2:SetAlpha(0)
        notice.oh = notice:GetTall()
        OrganizeNotices(false)
        notice:SetTall(0)
        notice:SizeTo(notice:GetWide(), 36 * 2.3, 0.2, 0, -1, function()
            notice.text:SetPos(0, 0)
            local function styleOpt(o)
                o.color = Color(0, 0, 0, 30)
                AccessorFunc(o, "color", "Color")
                function o:Paint(w, h)
                    if self.left then
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                    else
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                    end
                end
            end

            if notice.opt1 and IsValid(notice.opt1) then
                notice.opt1:SetAlpha(255)
                notice.opt1:SetSize(notice:GetWide() / 2, 25)
                notice.opt1:SetText(option1 .. " (F8)")
                notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
                notice.opt1:CenterHorizontal(0.25)
                notice.opt1:SetAlpha(0)
                notice.opt1:AlphaTo(255, 0.2)
                notice.opt1:SetTextColor(color_white)
                notice.opt1.left = true
                styleOpt(notice.opt1)
                function notice.opt1:keyThink()
                    if input.IsKeyDown(KEY_F8) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(1, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            if notice.opt2 and IsValid(notice.opt2) then
                notice.opt2:SetAlpha(255)
                notice.opt2:SetSize(notice:GetWide() / 2, 25)
                notice.opt2:SetText(option2 .. " (F9)")
                notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
                notice.opt2:CenterHorizontal(0.75)
                notice.opt2:SetAlpha(0)
                notice.opt2:AlphaTo(255, 0.2)
                notice.opt2:SetTextColor(color_white)
                styleOpt(notice.opt2)
                function notice.opt2:keyThink()
                    if input.IsKeyDown(KEY_F9) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(2, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            notice.lastKey = CurTime()
            notice.respondToKeys = true
            function notice:Think()
                if not self.respondToKeys then return end
                local queries = {}
                for _, v in pairs(lia.notices) do
                    if v.isQuery then queries[#queries + 1] = v end
                end

                for k, v in pairs(queries) do
                    if v == self and k > 1 then return end
                end

                if self.opt1 and IsValid(self.opt1) then self.opt1:keyThink() end
                if self.opt2 and IsValid(self.opt2) then self.opt2:keyThink() end
            end
        end)
        return notice
    end

    --- Displays a table UI on the client.
    -- @realm client
    -- @string title The title of the table UI.
    -- @tab columns A table defining the columns in the table. Each entry should be a table with fields `name` and `width`. The `name` is the column header, and `width` is the width of the column in pixels.
    -- @tab data A table containing rows of data. Each row is a table with keys corresponding to the `field` values defined in the `columns` table. Each key should have a value to be displayed in the respective column.
    -- @int[opt] frameWidth The width of the frame. Default is 900.
    -- @int[opt] frameHeight The height of the frame. Default is 600.
    -- @usage
    -- local columns = {
    --     {name = "ID", field = "id", width = 50},
    --     {name = "Name", field = "name", width = 150},
    -- }
    -- local data = {
    --     {id = 1, name = "Player1"},
    --     {id = 2, name = "Player2"}
    -- }
    -- lia.util.CreateTableUI("Player List", columns, data)
    function lia.util.CreateTableUI(title, columns, data, frameWidth, frameHeight)
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title or "Table List")
        frame:SetSize(frameWidth or 900, frameHeight or 600)
        frame:Center()
        frame:MakePopup()
        local listView = vgui.Create("DListView", frame)
        listView:Dock(FILL)
        local totalFixedWidth = 0
        local dynamicColumns = 0
        for _, colInfo in ipairs(columns) do
            if colInfo.width then
                totalFixedWidth = totalFixedWidth + colInfo.width
            else
                dynamicColumns = dynamicColumns + 1
            end
        end

        local availableWidth = frame:GetWide() - totalFixedWidth - 20
        local dynamicWidth = dynamicColumns > 0 and math.max(availableWidth / dynamicColumns, 50) or 0
        for _, colInfo in ipairs(columns) do
            local columnName = colInfo.name or "N/A"
            local columnWidth = colInfo.width or dynamicWidth
            listView:AddColumn(columnName):SetFixedWidth(columnWidth)
        end

        for _, row in ipairs(data) do
            local lineData = {}
            for _, colInfo in ipairs(columns) do
                local fieldName = colInfo.field or "N/A"
                table.insert(lineData, row[fieldName] or "N/A")
            end

            listView:AddLine(unpack(lineData))
        end
    end
end

lia.util.FindPlayer = lia.util.findPlayer
lia.util.StringMatches = lia.util.stringMatches
lia.util.GetAdmins = lia.util.getAdmins
lia.util.FindPlayerBySteamID64 = lia.util.findPlayerBySteamID64
lia.util.FindPlayerBySteamID = lia.util.findPlayerBySteamID
lia.util.CanFit = lia.util.canFit
lia.util.PlayerInRadius = lia.util.playerInRadius
lia.util.FindEmptySpace = lia.util.findEmptySpace
lia.util.DrawText = lia.util.drawText
lia.util.DrawTexture = lia.util.drawTexture
lia.util.SkinFunc = lia.util.skinFunc
lia.util.WrapText = lia.util.wrapText
lia.util.DrawBlur = lia.util.drawBlur
lia.util.DrawBlurAt = lia.util.drawBlurAt
lia.util.GetMaterial = lia.util.getMaterial