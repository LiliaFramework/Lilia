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

    timer.Create("liaResolutionMonitor", 1, 0, function()
        local scrW, scrH = ScrW(), ScrH()
        if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
            hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
            LAST_WIDTH = scrW
            LAST_HEIGHT = scrH
        end
    end)
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
lia.config.stored = lia.config.stored or {}
function lia.config.add(key, value, desc, callback, data, noNetworking, schemaOnly)
    assert(isstring(key), "expected config key to be string, got " .. type(key))
    local oldConfig = lia.config.stored[key]
    local savedValue
    if oldConfig then
        savedValue = oldConfig.value
    else
        savedValue = value
    end

    lia.config.stored[key] = {
        data = data,
        value = savedValue,
        default = value,
        desc = desc,
        noNetworking = noNetworking,
        global = not schemaOnly,
        callback = callback
    }
end

function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then config.value = value end
    if noSave then lia.config.save() end
end

function lia.config.set(key, value)
    local config = lia.config.stored[key]
    if config then
        local oldValue = value
        config.value = value
        if SERVER then
            if not config.noNetworking then netstream.Start(nil, "cfgSet", key, value) end
            if config.callback then config.callback(oldValue, value) end
            lia.config.save()
        end
    end
end

function lia.config.get(key, default)
    local config = lia.config.stored[key]
    if config then
        if config.value ~= nil then
            if istable(config.value) and config.value.r and config.value.g and config.value.b then config.value = Color(config.value.r, config.value.g, config.value.b) end
            return config.value
        elseif config.default ~= nil then
            return config.default
        end
    end
    return default
end

function lia.config.load()
    if SERVER then
        local globals = lia.data.get("config", nil, true, true)
        local data = lia.data.get("config", nil, false, true)
        if globals then
            for k, v in pairs(globals) do
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = v
            end
        end

        if data then
            for k, v in pairs(data) do
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = v
            end
        end
    end

    hook.Run("InitializedConfig")
end

if SERVER then
    function lia.config.getChangedValues()
        local data = {}
        for k, v in pairs(lia.config.stored) do
            if v.default ~= v.value then data[k] = v.value end
        end
        return data
    end

    function lia.config.send(client)
        netstream.Start(client, "cfgList", lia.config.getChangedValues())
    end

    function lia.config.save()
        local globals = {}
        local data = {}
        for k, v in pairs(lia.config.getChangedValues()) do
            if lia.config.stored[k].global then
                globals[k] = v
            else
                data[k] = v
            end
        end

        lia.data.set("config", globals, true, true)
        lia.data.set("config", data, false, true)
    end

    netstream.Hook("cfgSet", function(client, key, value)
        if client:IsSuperAdmin() and type(lia.config.stored[key].default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
            lia.config.set(key, value)
            if istable(value) then
                local value2 = "["
                local count = table.Count(value)
                local i = 1
                for _, v in SortedPairs(value) do
                    value2 = value2 .. v .. (i == count and "]" or ", ")
                    i = i + 1
                end

                value = value2
            end

            lia.util.notifyLocalized("cfgSet", nil, client:Name(), key, tostring(value))
        end
    end)
else
    netstream.Hook("cfgList", function(data)
        for k, v in pairs(data) do
            if lia.config.stored[k] then lia.config.stored[k].value = v end
        end

        hook.Run("InitializedConfig", data)
    end)

    netstream.Hook("cfgSet", function(key, value)
        local config = lia.config.stored[key]
        if config then
            if config.callback then config.callback(config.value, value) end
            config.value = value
            local properties = lia.gui.properties
            if IsValid(properties) then
                local row = properties:GetCategory(L(config.data and config.data.category or "misc")):GetRow(key)
                if IsValid(row) then
                    if istable(value) and value.r and value.g and value.b then value = Vector(value.r / 255, value.g / 255, value.b / 255) end
                    row:SetValue(value)
                end
            end
        end
    end)
end

if CLIENT then
    hook.Add("CreateMenuButtons", "liaConfig", function(tabs)
        if IsValid(LocalPlayer()) and not LocalPlayer():IsSuperAdmin() or hook.Run("CanPlayerUseConfig", LocalPlayer()) == false then return end
        tabs["config"] = function(panel)
            local scroll = panel:Add("DScrollPanel")
            scroll:Dock(FILL)
            hook.Run("CreateConfigPanel", panel)
            local properties = scroll:Add("DProperties")
            properties:SetSize(panel:GetSize())
            lia.gui.properties = properties
            local buffer = {}
            for k, v in pairs(lia.config.stored) do
                local index = v.data and v.data.category or "misc"
                buffer[index] = buffer[index] or {}
                buffer[index][k] = v
            end

            for category, configs in SortedPairs(buffer) do
                category = L(category)
                for k, v in SortedPairs(configs) do
                    local form = v.data and v.data.form
                    local value = lia.config.stored[k].default
                    if form then
                        if form == "Int" then
                            value = math.Round(lia.config.get(k) or value)
                        elseif form == "Float" then
                            value = tonumber(lia.config.get(k)) or value
                        elseif form == "Boolean" then
                            value = tobool(lia.config.get(k)) or value
                        else
                            value = lia.config.get(k) or value
                        end
                    else
                        local formType = type(value)
                        if formType == "number" then
                            form = "Int"
                            value = tonumber(lia.config.get(k)) or value
                        elseif formType == "boolean" then
                            form = "Boolean"
                            value = tobool(lia.config.get(k))
                        else
                            form = "Generic"
                            value = lia.config.get(k) or value
                        end
                    end

                    if form == "Combo" then
                        v.data.data = v.data.data or {}
                        v.data.data.text = value
                        v.data.data.values = {}
                        for niceName, optionData in pairs(v.data.options) do
                            niceName = tonumber(niceName) and optionData or niceName
                            v.data.data.values[tonumber(niceName) and optionData or niceName] = optionData
                            if optionData == value then v.data.data.text = niceName end
                        end
                    end

                    if form == "Generic" and istable(value) and value.r and value.g and value.b then
                        value = Vector(value.r / 255, value.g / 255, value.b / 255)
                        form = "VectorColor"
                    end

                    local delay = 1
                    if (form == "Boolean") or (form == "Combo") then delay = 0 end
                    local row = properties:CreateRow(category, tostring(k))
                    row:Setup(form, v.data and v.data.data or {})
                    row:SetValue(value)
                    row:SetTooltip(v.desc)
                    row.DataChanged = function(this, newValue)
                        debug.Trace()
                        timer.Create("liaCfgSend" .. k, delay, 1, function()
                            if not IsValid(row) then return end
                            if form == "VectorColor" then
                                local vector = Vector(newValue)
                                newValue = Color(math.floor(vector.x * 255), math.floor(vector.y * 255), math.floor(vector.z * 255))
                            elseif form == "Int" or form == "Float" then
                                newValue = tonumber(newValue)
                                if form == "Int" then newValue = math.Round(newValue) end
                            elseif form == "Boolean" then
                                newValue = tobool(newValue)
                            end

                            netstream.Start("cfgSet", k, newValue)
                        end)
                    end

                    if form == "Combo" then row.SetValue = function() end end
                end
            end
        end
    end)
end

lia.config.language = "english"
lia.config.itemFormat = "<font=liaGenericFont>%s</font>\n<font=liaSmallFont>%s</font>"
lia.config.add("maxChars", 5, "The maximum number of characters a player can have.", nil, {
    data = {
        min = 1,
        max = 50
    },
    category = "characters"
})

lia.config.add("color", Color(75, 119, 190), "The main color theme for the framework.", function() if CLIENT then hook.Run("liaUpdateColors") end end, {
    category = "appearance"
})

lia.config.add("colorAutoTheme", "dark", "Whether secondary and background colours generated from the main color should be dark or light themed.\nGenerated colors will be estimates and not guaranteed to look good.\nDisable to enable manual tuning", function() if CLIENT then hook.Run("liaUpdateColors") end end, {
    form = "Combo",
    category = "appearance",
    options = {"dark", "light", "disabled"}
})

lia.config.add("colorSecondary", Color(55, 87, 140), "The secondary color for the framework, used for accents.", function() if CLIENT then hook.Run("liaUpdateColors") end end, {
    category = "appearance"
})

lia.config.add("colorBackground", Color(25, 40, 64), "The background color for the framework, used in derma backgrounds", function() if CLIENT then hook.Run("liaUpdateColors") end end, {
    category = "appearance"
})

lia.config.add("colorText", color_white, "The main text color for the framework.", function() if CLIENT then hook.Run("liaUpdateColors") end end, {
    category = "appearance"
})

lia.config.add("font", "Arial", "The font used to display titles.", function(oldValue, newValue) if CLIENT then hook.Run("LoadLiliaFonts", newValue, lia.config.get("genericFont"), lia.config.get("configFont")) end end, {
    category = "appearance"
})

lia.config.add("genericFont", "Segoe UI", "The font used to display generic texts.", function(oldValue, newValue) if CLIENT then hook.Run("LoadLiliaFonts", lia.config.get("font"), newValue, lia.config.get("configFont")) end end, {
    category = "appearance"
})

lia.config.add("configFont", "Segoe UI", "The font used to display config and admin menu texts.", function(oldValue, newValue) if CLIENT then hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"), newValue) end end, {
    category = "appearance"
})

lia.config.add("fontScale", 1.0, "The scale for the font.", function(oldValue, newValue) if CLIENT then hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"), lia.config.get("configFont")) end end, {
    form = "Float",
    data = {
        min = 0.1,
        max = 2.0
    },
    category = "appearance"
})

lia.config.add("chatRange", 280, "The maximum distance a person's IC chat message goes to.", nil, {
    form = "Float",
    data = {
        min = 10,
        max = 5000
    },
    category = "chat"
})

lia.config.add("chatColor", Color(255, 239, 150), "The default color for IC chat.", nil, {
    category = "chat"
})

lia.config.add("chatListenColor", Color(168, 240, 170), "The color for IC chat if you are looking at the speaker.", nil, {
    category = "chat"
})

lia.config.add("oocDelay", 10, "The delay before a player can use OOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("oocLimit", 0, "Character limit per OOC message. 0 means no limit", nil, {
    data = {
        min = 0,
        max = 1000
    },
    category = "chat"
})

lia.config.add("oocDelayAdmin", false, "Whether or not OOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("allowGlobalOOC", true, "Whether or not Global OOC is enabled.", nil, {
    category = "chat"
})

lia.config.add("loocDelay", 0, "The delay before a player can use LOOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("loocDelayAdmin", false, "Whether or not LOOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("chatShowTime", false, "Whether or not to show timestamps in front of chat messages.", nil, {
    category = "chat"
})

lia.config.add("spawnTime", 5, "The time it takes to respawn.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "characters"
})

lia.config.add("invW", 6, "How many slots in a row there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "characters"
})

lia.config.add("invH", 4, "How many slots in a column there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "characters"
})

lia.config.add("minDescLen", 16, "The minimum number of characters in a description.", nil, {
    data = {
        min = 0,
        max = 300
    },
    category = "characters"
})

lia.config.add("saveInterval", 300, "How often characters save in seconds.", nil, {
    data = {
        min = 60,
        max = 3600
    },
    category = "characters"
})

lia.config.add("walkSpeed", 130, "How fast a player normally walks.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetWalkSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "characters"
})

lia.config.add("runSpeed", 235, "How fast a player normally runs.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetRunSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "characters"
})

lia.config.add("walkRatio", 0.5, "How fast one goes when holding ALT.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1
    },
    category = "characters"
})

lia.config.add("punchStamina", 10, "How much stamina punches use up.", nil, {
    data = {
        min = 0,
        max = 100
    },
    category = "characters"
})

lia.config.add("defMoney", 0, "The amount of money that players start with.", nil, {
    category = "characters",
    data = {
        min = 0,
        max = 10000
    }
})

lia.config.add("allowExistNames", true, "Whether or not players can use an already existing name upon character creation.", nil, {
    category = "characters"
})

lia.config.add("allowVoice", false, "Whether or not voice chat is allowed.", nil, {
    category = "server"
})

lia.config.add("voiceDistance", 600.0, "How far can the voice be heard.", function(oldValue, newValue) lia.config.squaredVoiceDistance = newValue * newValue end, {
    form = "Float",
    category = "server",
    data = {
        min = 0,
        max = 5000
    }
})

lia.config.add("contentURL", "http://liascript.net/", "Your server's collection pack.", nil, {
    category = "server"
})

lia.config.add("moneyModel", "models/props_lab/box01a.mdl", "The model for money entities.", nil, {
    category = "server"
})

lia.config.add("salaryInterval", 300, "How often a player gets paid in seconds.", nil, {
    data = {
        min = 1,
        max = 3600
    },
    category = "characters"
})

local dist = lia.config.get("voiceDistance")
lia.config.squaredVoiceDistance = dist * dist
if CLIENT then
    local gradientD = lia.util.getMaterial("vgui/gradient-d")
    local gradientR = lia.util.getMaterial("vgui/gradient-r")
    local gradientL = lia.util.getMaterial("vgui/gradient-l")
    local populateConfig = {
        server = function(panel)
            local buffer = {}
            for k, v in pairs(lia.config.stored) do
                local index = v.data and v.data.category or "misc"
                buffer[index] = buffer[index] or {}
                buffer[index][k] = v
            end

            panel.data = buffer
        end,
        client = function(panel) end,
    }

    local serverIcon, clientIcon, check, uncheck
    hook.Add("EasyIconsLoaded", "liaConfigIcons", function()
        serverIcon = getIcon("icon-equalizer")
        clientIcon = getIcon("icon-child")
        check = getIcon("icon-ok-squared")
        uncheck = getIcon("icon-check-empty")
    end)

    local PANEL = {}
    function PANEL:Init()
        self:SetSize(100, 0)
        self:DockMargin(0, 0, 0, 0)
        self:Dock(LEFT)
        self:InvalidateLayout(true)
        local parent = self:GetParent()
        print(parent, lia.gui.config, lia.gui.config == parent)
        print(parent.populateConfigs)
        self:createConfigButton(serverIcon, "Server", function()
            local config = parent.configListPanel
            populateConfig.server(config)
            config:InvalidateChildren(true)
            config:populateConfigs()
        end)

        self:createConfigButton(clientIcon, "Client", function()
            local config = parent.configListPanel
            populateConfig.client(config)
            config:InvalidateChildren(true)
            config:populateConfigs()
        end)
    end

    function PANEL:createConfigButton(icon, name, func)
        local button = self:Add("DButton")
        button:Dock(TOP)
        button:DockMargin(0, 0, 0, 0)
        button:SetSize(self:GetWide(), 30)
        button:SetText("")
        local icon_label = button:Add("DLabel")
        icon_label:Dock(LEFT)
        icon_label:DockMargin(0, 0, 0, 0)
        icon_label:SetSize(30, 30)
        icon_label:SetText("")
        icon_label.Paint = function(_, w, h) lia.util.drawText(icon, w * 0.5, h * 0.5, color_white, 1, 1, "liaIconsSmallNew") end
        local text_label = button:Add("DLabel")
        text_label:SetText(name)
        text_label:SetContentAlignment(5)
        text_label:SetFont("liaMediumConfigFont")
        text_label:Dock(FILL)
        text_label:DockMargin(0, 0, 0, 0)
        button.DoClick = function()
            self:GetParent():ClearConfigs()
            func()
        end
        return button
    end

    function PANEL:Paint()
    end

    vgui.Register("liaConfigSelectPanel", PANEL, "DPanel")
    PANEL = {}
    function PANEL:Init()
        self:Dock(FILL)
        self:InvalidateParent(true)
        hook.Run("CreateConfigPanel", self)
        self.filter = self:Add("DTextEntry")
        self.filter:Dock(TOP)
        self.filter:DockMargin(0, 0, 0, 0)
        self.filter:SetSize(self:GetWide(), 30)
        self.filter:SetPlaceholderText("Filter configs")
        self.filter:SetUpdateOnType(true)
        self.filter.OnChange = function() self:filterConfigs(self.filter:GetValue()) end
        self.scroll = self:Add("DScrollPanel")
        self.scroll:Dock(FILL)
        self.scroll.Paint = function() end
        populateConfig.server(self)
        self:InvalidateChildren(true)
        self:populateConfigs()
    end

    local paintFunc = function(panel, w, h)
        local r, g, b = lia.config.get("color"):Unpack()
        surface.SetDrawColor(r, g, b, 255)
        surface.SetMaterial(gradientR)
        surface.DrawTexturedRect(0, 0, w / 2, h)
        surface.SetMaterial(gradientL)
        surface.DrawTexturedRect(w / 2, 0, w / 2, h)
    end

    local mathRound, mathFloor = math.Round, math.floor
    local labelSpacing = 0.25
    local configElement = {
        Int = function(name, config, parent)
            local panel = vgui.Create("DNumSlider")
            panel:SetSize(parent:GetWide(), 30)
            panel:InvalidateChildren(true)
            panel:SetMin(config.data.data and config.data.data.min or 0)
            panel:SetMax(config.data.data and config.data.data.max or 1)
            panel:SetDecimals(0)
            panel:SetValue(config.value)
            panel:SetText(name)
            panel.TextArea:SetFont("liaConfigFont")
            panel.Label:SetFont("liaConfigFont")
            panel.Label:SetTextInset(10, 0)
            panel.OnValueChanged = function(_, newValue) timer.Create("liaConfigChange" .. name, 1, 1, function() netstream.Start("cfgSet", name, mathFloor(newValue)) end) end
            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            panel.PerformLayout = function(this) this.Label:SetWide(parent:GetWide() * labelSpacing) end
            local oldMousePressed = panel.Scratch.OnMousePressed
            panel.Scratch.OnMousePressed = function(this, code) if code ~= MOUSE_RIGHT then oldMousePressed(this, code) end end
            return panel
        end,
        Float = function(name, config, parent)
            local panel = vgui.Create("DNumSlider")
            panel:SetSize(parent:GetWide(), 30)
            panel:InvalidateChildren(true)
            panel:SetMin(config.data.data and config.data.data.min or 0)
            panel:SetMax(config.data.data and config.data.data.max or 1)
            panel:SetDecimals(2)
            panel:SetValue(config.value)
            panel:SetText(name)
            panel.TextArea:SetFont("liaConfigFont")
            panel.Label:SetFont("liaConfigFont")
            panel.Label:SetTextInset(10, 0)
            panel.OnValueChanged = function(_, newValue) timer.Create("liaConfigChange" .. name, 1, 1, function() netstream.Start("cfgSet", name, mathRound(newValue, 2)) end) end
            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            panel.PerformLayout = function(this) this.Label:SetWide(parent:GetWide() * labelSpacing) end
            local oldMousePressed = panel.Scratch.OnMousePressed
            panel.Scratch.OnMousePressed = function(this, code) if code ~= MOUSE_RIGHT then oldMousePressed(this, code) end end
            return panel
        end,
        Generic = function(name, config, parent)
            local panel = vgui.Create("DPanel")
            panel:SetSize(parent:GetWide(), 30)
            panel:SetTall(30)
            local label = panel:Add("DLabel")
            label:Dock(LEFT)
            label:DockMargin(0, 0, 0, 0)
            label:SetWide(panel:GetWide() * labelSpacing)
            label:SetText(name)
            label:SetFont("liaConfigFont")
            label:SetContentAlignment(4)
            label:SetTextInset(10, 0)
            local entry = panel:Add("DTextEntry")
            entry:Dock(FILL)
            entry:DockMargin(0, 0, 0, 0)
            entry:SetText(tostring(config.value))
            entry.OnValueChange = function(_, newValue) netstream.Start("cfgSet", name, newValue) end
            entry.OnLoseFocus = function(this) timer.Simple(0, function() this:SetText(tostring(config.value)) end) end
            panel.SetValue = function(this, value) entry:SetText(tostring(value)) end
            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            return panel
        end,
        Boolean = function(name, config, parent)
            local panel = vgui.Create("DPanel")
            panel:SetSize(parent:GetWide(), 30)
            panel:SetTall(30)
            local button = panel:Add("DButton")
            button:Dock(FILL)
            button:DockMargin(0, 0, 0, 0)
            button:SetText("")
            button.Paint = function(_, w, h) lia.util.drawText(config.value and check or uncheck, w * 0.5, h * 0.5, color_white, 1, 1, "liaIconsSmallNew") end
            button.DoClick = function() netstream.Start("cfgSet", name, not config.value) end
            local label = button:Add("DLabel")
            label:Dock(LEFT)
            label:DockMargin(0, 0, 0, 0)
            label:SetWide(parent:GetWide())
            label:SetText(name)
            label:SetFont("liaConfigFont")
            label:SetContentAlignment(4)
            label:SetTextInset(10, 0)
            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            return panel
        end,
        Color = function(name, config, parent)
            local panel = vgui.Create("DPanel")
            panel:SetSize(parent:GetWide(), 30)
            panel:SetTall(30)
            local button = panel:Add("DButton")
            button:Dock(FILL)
            button:DockMargin(0, 0, 0, 0)
            button:SetText("")
            button.Paint = function(_, w, h)
                draw.RoundedBox(4, w / 2 - 9, h / 2 - 9, 18, 18, config.value)
                lia.util.drawText(config.value.r .. " " .. config.value.g .. " " .. config.value.b, w / 2 + 18, h / 2, lia.config.get("colorText"), 0, 1, "liaConfigFont")
            end

            button.DoClick = function(this)
                local pickerFrame = this:Add("DFrame")
                pickerFrame:SetSize(ScrW() * 0.15, ScrH() * 0.2)
                pickerFrame:SetPos(gui.MouseX(), gui.MouseY())
                pickerFrame:MakePopup()
                if IsValid(button.picker) then button.picker:Remove() end
                button.picker = pickerFrame
                local Mixer = pickerFrame:Add("DColorMixer")
                Mixer:Dock(FILL)
                Mixer:SetPalette(true)
                Mixer:SetAlphaBar(true)
                Mixer:SetWangs(true)
                Mixer:SetColor(config.value)
                pickerFrame.curColor = config.value
                local confirm = pickerFrame:Add("DButton")
                confirm:Dock(BOTTOM)
                confirm:DockMargin(0, 0, 0, 0)
                confirm:SetText("Apply")
                confirm:SetTextColor(pickerFrame.curColor)
                confirm.DoClick = function()
                    netstream.Start("cfgSet", name, pickerFrame.curColor)
                    pickerFrame:Remove()
                end

                Mixer.ValueChanged = function(_, value)
                    pickerFrame.curColor = value
                    confirm:SetTextColor(value)
                end
            end

            local label = button:Add("DLabel")
            label:Dock(LEFT)
            label:SetWide(parent:GetWide())
            label:SetText(name)
            label:SetFont("liaConfigFont")
            label:SetContentAlignment(4)
            label:SetTextInset(10, 0)
            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            return panel
        end,
        Combo = function(name, config, parent)
            local panel = vgui.Create("DPanel")
            panel:SetSize(parent:GetWide(), 30)
            panel:SetTall(30)
            local label = panel:Add("DLabel")
            label:Dock(LEFT)
            label:DockMargin(0, 0, 0, 0)
            label:SetWide(panel:GetWide() * labelSpacing)
            label:SetText(name)
            label:SetFont("liaConfigFont")
            label:SetContentAlignment(4)
            label:SetTextInset(10, 0)
            local combo = panel:Add("DComboBox")
            combo:Dock(FILL)
            combo:DockMargin(0, 0, 0, 0)
            combo:SetSortItems(false)
            combo:SetValue(tostring(config.value))
            combo.OnSelect = function(_, index, value) netstream.Start("cfgSet", name, value) end
            for _, v in ipairs(config.data.options) do
                combo:AddChoice(v)
            end

            panel.Paint = function(this, w, h) paintFunc(this, w, h) end
            panel.SetValue = function(this, value) combo:SetValue(tostring(value)) end
            return panel
        end,
    }

    local function typeConvert(value)
        local t = type(value)
        if t == "boolean" then
            return "Boolean"
        elseif t == "number" then
            if math.floor(value) == value then
                return "Int"
            else
                return "Float"
            end
        elseif t == "table" and value.r and value.g and value.b then
            return "Color"
        end
        return "Generic"
    end

    function PANEL:populateConfigs()
        local sorted = {}
        self.entries = {}
        self.categories = {}
        if not self.data then return end
        for k in pairs(self.data) do
            table.insert(sorted, k)
        end

        table.sort(sorted, function(a, b) return a:lower() < b:lower() end)
        self:InvalidateLayout(true)
        for _, category in ipairs(sorted) do
            local panel = self.scroll:Add("DPanel")
            panel:Dock(TOP)
            panel:DockMargin(0, 1, 0, 4)
            panel:DockPadding(0, 0, 0, 10)
            panel:SetSize(self:GetWide(), 30)
            panel:SetPaintBackground(false)
            panel.category = category
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:DockMargin(1, 1, 1, 4)
            label:SetSize(self:GetWide(), 30)
            label:SetFont("liaMediumConfigFont")
            label:SetContentAlignment(5)
            label:SetText(category:gsub("^%l", string.upper))
            for name, config in SortedPairs(self.data[category]) do
                local form = config.data and config.data.form
                local value = config.default
                if not form then form = typeConvert(value) end
                local entry = panel:Add(configElement[form or "Generic"](name, config, panel))
                entry:Dock(TOP)
                entry:DockMargin(0, 1, 5, 2)
                entry:SetTooltip(config.desc)
                entry.shown = true
                entry.name = name
                entry.config = config
                table.insert(self.entries, entry)
            end

            panel:SizeToChildren(false, true)
            table.insert(self.categories, panel)
        end
    end

    local function requestReset(panel)
        if panel.name and panel.config then
            Derma_Query("Reset " .. panel.name .. " to default? (" .. tostring(panel.config.default) .. ")", "Reset Config", "Yes", function()
                netstream.Start("cfgSet", panel.name, panel.config.default or nil)
                if panel.SetValue then panel:SetValue(panel.config.default) end
            end, "No")
        end

        if panel:GetParent() then requestReset(panel:GetParent()) end
    end

    hook.Add("VGUIMousePressed", "liaConfigReset", function(panel, code) if code == MOUSE_RIGHT then requestReset(panel) end end)
    local animTime = 0.3
    function PANEL:filterConfigs(filter)
        filter = filter:lower()
        for _, entry in ipairs(self.entries) do
            if not (entry.wide and entry.tall) then entry.wide, entry.tall = entry:GetSize() end
            local text = entry.name:lower()
            local category = entry.config.data.category:lower()
            local description = entry.config.desc:lower()
            if filter == "" or string.find(text, filter) or string.find(category, filter) or string.find(description, filter) then
                if not entry.shown then
                    entry:SetVisible(true)
                    entry.shown = true
                    entry:SizeTo(entry.wide, entry.tall, animTime, 0, -1, function() end)
                end
            else
                if entry.shown then
                    entry:SizeTo(entry.wide, 0, animTime, 0, -1, function()
                        entry:SetVisible(false)
                        entry.shown = false
                    end)
                end
            end
        end
    end

    function PANEL:Think()
        for _, category in ipairs(self.categories) do
            local shown = false
            for _, entry in ipairs(self.entries) do
                if entry.shown and entry.config.data.category:lower() == category.category:lower() then
                    shown = true
                    break
                end
            end

            if shown then
                category:SetVisible(true)
                category:SizeToChildren(false, true)
            else
                category:SetVisible(false)
                category:SetTall(0)
            end
        end

        self.scroll:InvalidateLayout(true)
        self.scroll:SizeToChildren(false, true)
    end

    function PANEL:Paint()
    end

    vgui.Register("liaConfigListPanel", PANEL, "DPanel")
    PANEL = {}
    function PANEL:Init()
        if lia.gui.config then lia.gui.config:Remove() end
        lia.gui.config = self
        self:InvalidateLayout(true)
    end

    function PANEL:ClearConfigs()
        if self.scroll then self.scroll:Clear() end
    end

    function PANEL:AddElements()
        self.configListPanel = self:Add("liaConfigListPanel")
    end

    local sin = math.sin
    function PANEL:Paint(w, h)
        local colorR, colorG, colorB = lia.config.get("color"):Unpack()
        local backgroundR, backgroundG, backgroundB = lia.config.get("colorBackground"):Unpack()
        lia.util.drawBlur(self, 10)
        if not self.startTime then self.startTime = CurTime() end
        local curTime = (self.startTime - CurTime()) / 4
        local alpha = 200 * ((sin(curTime - 1.8719) + sin(curTime - 1.8719 / 2)) / 4 + 0.44)
        surface.SetDrawColor(colorR, colorG, colorB, alpha)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(backgroundR, backgroundG, backgroundB, 255)
        surface.SetMaterial(gradientD)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetMaterial(gradientR)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    vgui.Register("liaConfigPanel", PANEL, "DPanel")
end