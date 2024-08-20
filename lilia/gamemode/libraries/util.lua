--- Various useful helper functions.
-- @library lia.util

--- Attempts to find a player by matching their name or Steam ID.
-- @realm shared
-- @string identifier Search query
-- @bool[opt=false] allowPatterns Whether or not to accept Lua patterns in `identifier`
-- @treturn player Player that matches the given search query - this will be `nil` if a player could not be found
function lia.util.findPlayer(identifier, allowPatterns)
    if string.isSteamID(identifier) then return player.GetBySteamID(identifier) end
    if not allowPatterns then identifier = string.PatternSafe(identifier) end
    for _, v in player.Iterator() do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

--- Finds all entities of a specific class owned by a specified player.
--- If no class is specified, finds all entities owned by the player.
-- @realm shared
-- @client client The player whose entities are being searched for.
-- @param[opt] class The class of the entities being searched for. If not provided, all entities owned by the player are returned.
-- @treturn table A table containing all entities of the specified class (or all entities if no class is specified) owned by the given player.
function lia.util.findPlayerEntities(client, class)
    local items = {}
    for _, entity in pairs(ents.GetAll()) do
        if (not class or entity:GetClass() == class) and (entity:GetCreator() == client or (entity.client and (entity.client == client))) then table.insert(items, entity) end
    end
    return items
end

--- Emits sounds one after the other from an entity.
-- @realm shared
-- @entity entity Entity to play sounds from
-- @tab sounds Sound paths to play
-- @float delay[opt=0] How long to wait before starting to play the sounds
-- @float spacing[opt=0.1] How long to wait between playing each sound
-- @int volume[opt=75] The sound level of each sound
-- @int pitch[opt=100] Pitch percentage of each sound
-- @treturn number How long the entire sequence of sounds will take to play
function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0
        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet
        timer.Simple(delay, function() if IsValid(entity) then entity:EmitSound(v, volume, pitch) end end)
        delay = delay + length + postSet + spacing
    end
    return delay
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
        local mins = Vector(-spacing * 0.5, -acing * 0.5, 0)
        local maxs = Vector(spacing * 0.5, sping * 0.5, height)
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


    --- Prints a message to a player's chat.
    -- @realm server
    -- @client target The player to receive the chat message
    -- @tab ... The message or messages to print
    function lia.util.chatNotify(target, ...)
        netstream.Start(target, "ChatPrint", {...})
    end
else
    --- Downloads a material from a URL and saves it to a specified path if it doesn't already exist.
    -- @realm client
    -- @string url The URL to download the material from
    -- @string path The path to save the material to
    function lia.util.DownloadMaterial(url, path)
        if not file.Exists(path, "DATA") then http.Fetch(url, function(result) if result then file.Write(path, result) end end) end
    end

    --- Calls a named skin function with optional arguments on a panel.
    -- @realm client
    -- @string name Name of the skin function to call
    -- @param[opt] panel Panel to apply the skin function to
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


    timer.Create("liaResolutionMonitor", 1, 0, function()
        local scrW, scrH = ScrW(), ScrH()
        if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
            hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
            LAST_WIDTH = scrW
            LAST_HEIGHT = scrH
        end
    end)


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
        local i = table.insert(lia.noticess, notice)
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
                for _, v in pairs(lia.noticess) do
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

    --- Draws some text with a shadow.
    -- @realm client
    -- @string text Text to draw
    -- @float x X-position of the text
    -- @float y Y-position of the text
    -- @color color Color of the text to draw
    -- @int[opt=TEXT_ALIGN_LEFT] alignX Horizontal alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @int[opt=TEXT_ALIGN_LEFT] alignY Vertical alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @string[opt="ixGenericFont"] font Font to use for the text
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

    local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()
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
        if useCheapBlur then
            surface.SetDrawColor(30, 30, 30, amount * 20)
            surface.DrawRect(x, y, w, h)
        else
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
        if useCheapBlur then
            surface.SetDrawColor(50, 50, 50, amount * 20)
            surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
        else
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
    end

    cvars.AddChangeCallback("lia_cheapblur", function(_, _, new) useCheapBlur = (tonumber(new) or 0) > 0 end)
end